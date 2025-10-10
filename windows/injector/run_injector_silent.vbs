Set WshShell = CreateObject("WScript.Shell")
' Run the command hidden (0), wait until it finishes (True)
WshShell.Run "ShellJectorLocal.exe -proc cs2.exe -dll Osiris.dll", 0, True