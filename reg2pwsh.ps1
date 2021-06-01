function parse-regstring {
    PARAM (
    [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [System.String]$regstring,
    [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [System.String]$stringtype
    )

        [array]$hex=$regstring -split'[,\\]' | where {-not ([string]::IsNullOrWhiteSpace($_))} | %{$_.trimstart()}
        $bytes=0..($hex.count-1) | where {$_ % 2 -ne 1} | foreach-object {$hex[$_]}
        $text=@()
        foreach ($byte in $bytes) {
            switch ($stringtype)
            {
                'expandstring' {if ($byte -ne '00') {$text+=[char][int]('0x'+$byte)}}
                'multistring' {if ($byte -ne '00') {$text+=[char][int]('0x'+$byte)} else {$text+="\0"}}
            }
        }
        $text=$text -join ""
        $text
    }

function parse-qword {
    PARAM (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] [System.String]$qword
    )
    [array]$qword=$qword -split'[,]'
    $qword=for ($i=$qword.count-1;$i -ge 0;$i--) {$qword[$i]}
    $hexvalue=$qword -join ""
    $hexvalue=$hexvalue.trimstart("0")
    $hexvalue
}

function parse-binary {
    PARAM (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] [System.String]$binary
    )
    [array]$hex=$binary -split'[,\\]' | where {-not ([string]::IsNullOrWhiteSpace($_))} | %{$_.trimstart()}
    $hex=$hex -join ""
    $hex
}

function reg2pwsh {
    PARAM (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)] [System.String]$regfile
    )
    $parent=split-path $regfile -parent
    $regname=[System.IO.Path]::GetFileNameWithoutExtension($regfile)
    $regcontent=Get-Content $regfile | Where-Object {![string]::IsNullOrEmpty($_) -and $_ -notlike 'Windows Reg*'} | ForEach-Object {$_.Trim()}
    $reglines = for ($i = 0; $i -lt $regcontent.Count; $i++) {
        $i2 = $i
        while ($regcontent[$i2].EndsWith("\")) {
            $regcontent[$i] = $regcontent[$i].Substring(0, $regcontent[$i].Length - 1) + $regcontent[($i2 + 1)]
            $i2++
        }
        $regcontent[$i]
        $i = $i2
    }
    $commands=@()
    $addedpath=@()
    foreach ($regline in $reglines){
        if ($regline -match '\[' -and $regline -match '\]' -and $regline -match 'HKEY') {
            switch ($regline)
                {
                    {$regline -match "HKEY_CLASSES_ROOT"} {$regline=$regline -replace "HKEY_CLASSES_ROOT","HKCR:"}
                    {$regline -match "HKEY_CURRENT_USER"} {$regline=$regline -replace "HKEY_CURRENT_USER","HKCU:"}
                    {$regline -match "HKEY_LOCAL_MACHINE"} {$regline=$regline -replace "HKEY_LOCAL_MACHINE","HKLM:"}
                    {$regline -match "HKEY_USERS"} {$regline=$regline -replace "HKEY_USERS","HKU:"}
                    {$regline -match "HKEY_CURRENT_CONFIG"} {$regline=$regline -replace "HKEY_CURRENT_CONFIG","HKCC:"}
                }
            if ($regline -match '\[-HK') {
                $path=$regline -replace '\[-|\]'
                $commands+=[string]"Remove-Item -Path "+"`"$path`""+" -Force -Recurse"
            }
            else {
                $path=$regline -replace '\[|\]'
                if ($addedpath -notcontains $path) {
                    $commands+=[string]"New-Item -Path "+"`"$path`""+" -Force -ErrorAction SilentlyContinue | Out-Null"
                    $addedpath+=$path
                }
            }
        }
        elseif ($regline -match "`"([^`"=]+)`"=") {
            [System.Boolean]$delete=$false
            $name=($regline | select-string -pattern "`"([^`"=]+)`"").matches.value | select-object -first 1
            switch ($regline)
            {
                {$regline -match "=-"} {$commands+=[string]"Remove-ItemProperty -Path "+"`"$path`""+" -Name "+$name;$delete=$true}
                {$regline -match '"="'} {
                    $type="string"
                    $value=$regline -replace "`"([^`"=]+)`"="
                }
                {$regline -match "dword"} {
                    $type="dword"
                    $value=$regline -replace "`"([^`"=]+)`"=dword:"
                    $value="0x"+$value
                }
                {$regline -match "qword"} {
                    $type="qword"
                    $value=$regline -replace "`"([^`"=]+)`"=qword:"
                    $value="0x"+$value
                }
                {$regline -match "hex\(2\)"} {
                    $type="expandstring"
                    $value=$regline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:"
                    $value=parse-regstring $value "expandstring"
                    break
                }
                {$regline -match "hex\(7\)"} {
                    $type="multistring"
                    $value=$regline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:"
                    $value=parse-regstring $value "multistring"
                    break
                }
                {$regline -match "hex\(b\)"} {
                    $type="qword"
                    $value=$regline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:"
                    $value=parse-qword $value
                    $value="0x"+$value
                    break
                }
                {$regline -match "hex"} {
                    $type="binary"
                    $value=$regline -replace "`"[^`"=]+`"=hex(\([2,7,b]\))?:"
                    $value=parse-binary $value
                    $value="0x"+$value
                }
            }
            if ($delete -eq $false) {$commands+=[string]"Set-ItemProperty -Path "+"`"$path`""+" -Name "+$name+" -Type "+$type+" -Value "+$value}
        }
    }
    $commands | out-file -path "${parent}\${regname}_reg.ps1"
}
$regfile=Read-Host "Please input full path to the .reg file that needs conversion"
reg2pwsh $regfile