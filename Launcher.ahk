/**
 * Tested by dufferZafar on Windows 8 Pro Build 9920
 */
#SingleInstance Force

/**
 * Configure your paths
 */

CmderPath := "F:\[Softwares]\[PowerPack]\Cmder"
FavDir := "D:\I, Coder\@ GitHub"

; This variable is used by the init script of the Cmder project
EnvSet, CMDER_ROOT, %CmderPath%

/**
 * Real Code Starts
 *
 * AHK newbies stay away :p
 */

; Create a group of windows
; Note: Groups are used to club different windows together
GroupAdd, Explorer_Group, ahk_class CabinetWClass
GroupAdd, Explorer_Group, ahk_class ExploreWClass

GroupAdd, Desktop_Group, ahk_class WorkerW

; Attach hotkeys
Hotkey, !^c, RunCmder
Hotkey, !^x, RunBash

Return
; End of Auto-Execute section

/**
 * Opens command prompt in the current folder.
 */

RunCmder:
   Path := GetPath()
   Run, %CmderPath%/vendor/conemu/ConEmu64.exe /Single /Dir "%Path%" /Title Cmder /Icon "%CmderPath%\Cmder.ico" /LoadCfgFile "%CmderPath%\config\ConEmu.xml"
Return

RunBash:
   Path := GetPath()
   Run, %CmderPath%/vendor/conemu/ConEmu64.exe /Single /Dir "%Path%" /Title Cmder /Icon "%CmderPath%\Cmder.ico" /LoadCfgFile "%CmderPath%\config\ConEmu.xml" /cmd %CmderPath%\vendor\msysgit\bin\sh.exe -l -i
Return

GetPath() {
   Global FavDir

   If WinActive("ahk_class PX_WINDOW_CLASS")
   {
      FilePath := GetPathFromSublime()
      SplitPath, FilePath, , Dir ; The Directory
   }
   Else
      Dir := GetCurrentFolderPath()

   Dir := (Dir = "") ? FavDir : Dir

   Return Dir
}

/**
 * Extracts the current file's path from sublime text.
 */
GetPathFromSublime() {
   WinGetTitle, wTitle, ahk_class PX_WINDOW_CLASS
   ; wTitle := "D:\I, Coder\@ GitHub\win-butler\Test.ahk (WinButler) - Sublime Text"

   StringTrimRight, File, wTitle, 15

   If FileExist(File)
      ScriptPath := File
   Else
   {
      pos := InStr(wTitle, "(", False, 0)
      ScriptPath := SubStr(wTitle, 1, pos-1)
   }

   Return %ScriptPath%
}

/**
 * Get the path of currently open folder.
 *
 * Use Path := (Path = "") ? "C:\" : Path
 * to handle exceptions and set a default path
 *
 * Todo: Handle CLSID for special folders
 */
GetCurrentFolderPath() {
   If WinActive("ahk_group Explorer_Group")
   {
      hWnd := WinExist("A")
      shellApp := ComObjCreate("Shell.Application")

      for Item in shellApp.Windows
      {
         If (Item.hwnd = hWnd)
         {
            sfv := Item.Document ; ShellFolderView
            path := sfv.Folder.Self.Path
         }
      }
      If InStr(path, ".library-ms")
         Return ""
      Else
         Return path
   }
   Else If WinActive("ahk_group Desktop_Group")
      Return %A_Desktop%
   Else
      Return ""
}
