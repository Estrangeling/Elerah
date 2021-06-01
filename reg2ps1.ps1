Function reg2ps1 {

    [CmdLetBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)] [ValidateNotNullOrEmpty()]
        [Alias("FullName")]
        [string]$path,
        $Encoding = "utf8"
    )

    Begin {
        $hive = @{
            "HKEY_CLASSES_ROOT"   = "HKCR:"
            "HKEY_CURRENT_CONFIG" = "HKCC:"
            "HKEY_CURRENT_USER"   = "HKCU:"
            "HKEY_LOCAL_MACHINE"  = "HKLM:"
            "HKEY_USERS"          = "HKU:"
        }
        [system.boolean]$isfolder = $false
        $addedpath = @()
    }
    Process {
        if (test-path $path -pathtype container) { $files = (get-childitem -path $path -recurse -force -file -filter "*.reg").fullname; $isfolder = $true }
        else { if ($path.endswith(".reg")) { $files = $path } }
        foreach ($File in $Files) {
            $Commands = @()
            foreach ($root in $hive.keys) {
                if ((Get-Content -Path $file -Raw) -match $root -and $hive[$root] -notin ('HKCU:', 'HKLM:')) {
                    $commands += "New-PSDrive -Name $($hive[$root].replace(':', '')) -PSProvider Registry -Root $root"
                }
            }
            [string]$text = $nul
            $FileContent = Get-Content $File | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_.Trim() }
            $joinedlines = @()
            foreach ($line in $FileContent) {
                if ($line.EndsWith("\")) {
                    $text = $text + ($line -replace "\\$").trim()
                }
                else {
                    $joinedlines += $text + $line
                    [string]$text = $nul
                }
            }

            foreach ($joinedline in $joinedlines) {
                if ($joinedline -match "\[HKEY(.*)+\]") {
                    $key = $joinedline -replace '\[-?|\]'
                    $hivename = $key.split('\')[0]
                    $key = '"' + ($key -replace $hivename, $hive.$hivename) + '"'
                    if ($joinedline.StartsWith("[-HKEY")) {
                        $Commands += 'Remove-Item -Path {0} -Force -Recurse' -f $key
                    }
                    else {
                        if ($key -notin $addedpath) {
                            $Commands += 'New-Item -Path {0} -ErrorAction SilentlyContinue | Out-Null' -f $key
                            $addedpath += $key
                        }
                    }
                }
                elseif ($joinedline -match "`"([^`"=]+)`"=") {
                    [System.Boolean]$delete = $false
                    $name = ($joinedline | select-string -pattern "`"([^`"=]+)`"").matches.value | select-object -first 1
                    switch ($joinedline) {
                        { $joinedline -match "=-" } { $Commands += 'Remove-ItemProperty -Path {0} -Name {1} -Force' -f $key, $Name; $delete = $true }
                        { $joinedline -match '"="' } {
                            $type = "String"
                            $value = $joinedline -replace "`"([^`"=]+)`"="
                        }
                        { $joinedline -match "dword" } {
                            $type = "Dword"
                            $value = $joinedline -replace "`"([^`"=]+)`"=dword:"
                            $value = "0x" + $value
                        }
                        { $joinedline -match "qword" } {
                            $type = "Qword"
                            $value = $joinedline -replace "`"([^`"=]+)`"=qword:"
                            $value = "0x" + $value
                        }
                        { $joinedline -match "hex(\([2,7,b]\))?:" } {
                            $value = ($joinedline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:").split(",")
                            $hextype = ($joinedline | select-string -pattern "hex(\([2,7,b]\))?").matches.value
                            switch ($hextype) {
                                { $hextype -match 'hex(\([2,7])\)' } {
                                    $ValueEx = '$value = for ($i = 0; $i -lt $value.count; $i += 2) {if ($value[$i] -ne "00") {[string][char][int]("0x" + $value[$i])}'
                                    switch ($hextype) {
                                        'hex(2)' { $type = "ExpandString"; invoke-expression $($ValueEx + '}') }
                                        'hex(7)' { $type = "MultiString"; invoke-expression $($ValueEx + ' else {","}}'); $value = 0..$($value.count - 3) | % { $value[$_] } }
                                    }
                                    $value = $value -join ""
                                    if ($type -eq "ExpandString") { $value = '"' + $value + '"' }
                                    else {$value = foreach ($seg in $value.split(',')) {'"' + $seg + '"'}; $value = $value -join ','}
                                }
                                'hex(b)' {
                                    $type = "Qword"
                                    $value = for ($i = $value.count - 1; $i -ge 0; $i--) { $value[$i] }
                                    $value = '0x' + ($value -join "").trimstart('0')
                                }
                                'hex' {
                                    $type = "Binary"
                                    $value = $value | %{'0x' + $_}
                                    $value = '([byte[]]$(' + $($value -join ",") + '))'
                                }
                            }
                        }
                    }
                    if (!$delete) {
                        $Commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3} -Force' -f $key, $name, $type, $value
                    }
                }
                elseif ($joinedline -match "@=") {
                    $name = '"(Default)"'; $type = 'string'; $value = $joinedline -replace '@='
                    $commands += 'Set-ItemProperty -Path {0} -Name {1} -Type {2} -Value {3}' -f $key, $name, $type, $value
                }
            
            }
            $Commands | out-file -path $($file.replace('.reg', '_reg.ps1')) -encoding $encoding
        }
        if ($isfolder) {
            $allcommands = (get-childitem -path $path -recurse -force -file -filter "*_reg.ps1").fullname | where-object { $_ -notmatch "allcommands_reg" } | foreach-object { get-content $_ }
            $allcommands | out-file -path "${path}\allcommands_reg.ps1" -encoding $encoding
        }
    }
}
$path = $args[0]
reg2ps1 $path