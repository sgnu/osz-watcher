# Read config.ini

# from https://serverfault.com/questions/186030/how-to-use-a-config-file-ini-conf-with-a-powershell-script
Get-Content "./config.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$downloads = $h.Get_Item("DownloadsPath")
$global:osu = Join-Path -Path $h.Get_Item("OsuPath") -ChildPath "\Songs"

# Keep this window running!

$newosz = {
    # modern browesers name partial downloads differently from their completed form
    $path = $Event.SourceEventArgs.FullPath
    $filename = [IO.Path]::GetFileName($path)   # get the file's name
    if ($filename -like "*.osz") {  # confirm the file is an .osz file
        $finalpath = [IO.Path]::Combine($global:osu, $filename) # combine the osu! path with the .osz file's name
        Add-Content "./log.txt" -Value "$(Get-Date) - $filename"    # add a message to the log file
        Move-Item -Path $path -Destination $finalpath   # move the .osz file to the osu! Songs directory
    }
}

# Set up file system watcher
$filewatcher = New-Object System.IO.FileSystemWatcher
$filewatcher.Path = $downloads
$filewatcher.IncludeSubdirectories = $false
$filewatcher.EnableRaisingEvents = $true

Register-ObjectEvent $filewatcher "Created" -Action $newosz # listen for new files being created in the downloads folder

while ($true) {
    Start-Sleep -Seconds 1
}