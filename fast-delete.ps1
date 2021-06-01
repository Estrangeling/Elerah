function Parallel-Delete {
		param(
		[Parameter(Valuefrompipeline=$true, Mandatory=$true, Position=0)] [array]$filelist,
		[Parameter(Valuefrompipeline=$true, Mandatory=$true, Position=1)] [int]$number
		)
		0..($filelist.count-1) | Where-Object {$_ % 16 -eq $number} | foreach {Remove-Item -Path $filelist[$_]}
	}

	Function Fast-Delete {
		Param(
		[Parameter(Valuefrompipeline=$True, Mandatory=$True)] [String]$Directory0
		)
		Write-Warning "This Process Will Delete Everything In The Target Directory:  $Directory0, Do You Want To Confirm Deletion?" -Warningaction Inquire
		$Directory=$Directory0
		While ((Get-Childitem -Path $Directory0 -Depth 0 -Force).Count -Ne 0) {
			If ((Get-Childitem -Path $Directory -Directory -Force -Depth 0).Count -Ne 0) {
				$Directory=(Get-Childitem -Path $Directory -Directory -Force -Depth 0).Fullname | Select-Object -Index 0
			}
			If ((Get-Childitem -Path $Directory -File -Force).Count -Ne 0) {
				If ((Get-Childitem -Path $Directory -File -Force).Count -Ge 128) {
					[array]$filelist=(Get-Childitem -Path $Directory -File -Force).Fullname
					0..15 | foreach-object {Invoke-Command -ScriptBlock { Parallel-Delete $filelist $_}}
					} else {
					(Get-Childitem -Path $Directory -File -Force).Fullname | Foreach {Remove-Item -Path $_}
				}
			}
			$Directory1=$Directory
			$Directory=$Directory | Split-Path -Parent
			Remove-Item -Path $Directory1
			}
		Remove-Item -Path $Directory0 -erroraction silentlycontinue
	}
	$Directory0=Read-Host "Please input target directory to be deleted"
	Fast-Delete $Directory0