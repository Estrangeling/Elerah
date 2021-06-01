param(
  [parameter(mandatory=$true)] [validatenotnullorempty()]$execs
)

if (!(test-path $home\pinnedshortcuts)) {new-item $home\pinnedshortcuts -type "directory" > $null}
$execs  = $execs -split "\|"

foreach ($exec in $execs) {
  $path = ($exec -split "::")[0]
  $name = ($exec -split "::")[1]

  if ($path -notmatch "[C-Zc-z]:(\\[^(<>:`"\/\\|?*\x00-\x1f\x7f)]+)+") {$path=(where.exe $path)[0]}

  $shortcutpath         		= "$home\desktop\$name.lnk"
  $wshshell             		= new-object -comobject wscript.shell
  $shortcut             		= $wshshell.createshortcut($shortcutpath)
  $shortcut.TargetPath  		= $path
  $shortcut.WorkingDirectory	= "C:\Windows\System32"
  $shortcut.save()

  $bytes                		= [system.io.file]::readallbytes($shortcutpath)
  $bytes[0x15]         			= $bytes[0x15] -bor 0x20
  [system.io.file]::writeallbytes($shortcutpath,$bytes)

  copy-item -path $shortcutpath -destination $home\pinnedshortcuts
}

$template         = get-content "$psscriptroot\template.xml"
$pinnedshortcuts  = (get-childitem -path $home\pinnedshortcuts -filter "*.lnk").fullname | %{"`t`t<taskbar:DesktopApp DesktopApplicationLinkPath=`"{0}`" />" -f $_}
$template         = $template | % {$_;if ($_ -match "<taskbar:taskbarpinlist>") {$pinnedshortcuts}}

$template | out-file  -path "$home\pinnedshortcuts\pinnedshortcuts.xml"
import-startlayout    -layoutpath $home\pinnedshortcuts\pinnedshortcuts.xml -mountpath c:\
get-process           -name "explorer" | stop-process & explorer.exe