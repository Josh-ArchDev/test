## Specify the sort order parameter: Name, Size, Date Modified
$sortOrder = "Item Type";

(New-Object -ComObject shell.application).toggleDesktop();
Start-Sleep -Milliseconds 500;

$WshShell = New-Object -ComObject WScript.Shell;
Start-Sleep -Milliseconds 500;

$WshShell.SendKeys("+{F10}");
Start-Sleep -Milliseconds 500;

$WshShell.SendKeys("o");
$WshShell.SendKeys($sortOrder.Substring(0, 1));