Function Register-Watcher {
    param ($folder)
    $filter = "*.*" #all files
    $watcher = New-Object IO.FileSystemWatcher $folder, $filter -Property @{ 
        IncludeSubdirectories = $true
        EnableRaisingEvents = $true
    }

    $changeAction = [scriptblock]::Create('
        $path = $Event.SourceEventArgs.FullPath
        $name = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $timeStamp = $Event.TimeGenerated
        Write-Host "The file $name was $changeType at $timeStamp"
    ')

    Register-ObjectEvent $Watcher -EventName "Changed" -Action $changeAction
}
Register-Watcher $Args[0]
