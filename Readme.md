# Cmder

![Screenshot](/screen.jpg)

A fork of the awesome [Cmder](https://github.com/bliker/cmder/) project.

I was customizing it for myself, thought I'd just share it.

I use Autohotkey to pass the current explorer directory as a parameter.
Without which it'll launch in the directory where "Cmder.bat" is placed.

I've added "msysgit", "gow", "putty", "vim" for myself. They are in the vendor folder. You can place other 3rd party stuff there too.

See the ".gitignore" file for the entire structure.

## Table of Contents

* [What has been changed?](#changelog)
* [Stuff to do](#todo)

## <a name="changelog"></a>Things changed

* ConEmu - Version 13.12.19.0
* Clink - Version 0.4

* Modified: ConEmu settings: <config/ConEmu.xml>
  * Tabs on top
  * No transparency
  * Runs in a single instance
  * Xterm highlighting instead of Monokai
  * Shows only active console icon in taskbar
  * No new tab confirmation
  * Removed the "-new_console:d:%USERPROFILE%" part to launch in any directory.

* Modified: Initiation script <vendor/init.bat>
  * The %PATH% directory.

* Modified: Alias command <config/alias.bat>
  * Run alias command without any parameters to list all aliases.

* Modified: Alias list <config/aliases>
  * Lots of git related aliases.

* Added: msysgit, gow, putty. <vendor/>

* Added: .bashrc for Bash. 

  Create a symlink in your %UserProfile% directory to this file and you are done. 'chdir' to your %UserProfile% and issue something like:

    mklink .bashrc "%FolderWhereYouDownloadedCmderTo%\config\.bashrc"

## <a name="hotkeys"></a>List of Hotkeys

Clink and ConEmu-Maximus5 together offer a wide range of hotkeys.

Here are some of the most used ones:

* `Alt+~` : Hides the console.
* `Alt+H` : List Clink Hotkeys
* `Alt+Win+P` : ConEmu Settings

* `Up/Dn` : Cycle through history

* `Ctrl+W` : Close current tab
* `Ctrl+Shift+W` : Close the current process of console

* `PgUp/PgDn` : Scroll buffer by page
* `Shift+Up/Dn` : Scroll buffer by line
* `Ctrl+PgUp/PgDn` : Cycle through tabs 

## <a name="todo"></a>Todo

* Dotfiles from github
* Better Git Commit aliases

* [Git Churn](https://github.com/garybernhardt/dotfiles/blob/f0c0ff92209e5aed4fa3ef6faf056eb9944a8f12/bin/git-churn)
* [hr](https://github.com/LuRsT/hr/blob/master/hr)

* Autohotkey Based Launcher
  * The default launcher is broken, as the conemu path has changed.

* Clink Lua:
  * Git - (branch:dirttype)

* Prompt modifications in .bashrc

* Add Tools:
  * MinGW
  * GnuWin32
  * Nirsoft Utilities
  * Update tools used in GOW
  * Commandline Sysinternals Tools

* Commands:
  * unalias

* `Ctrl+Shift+T` - Load last open tab
* Keyboard Text Selection

* Portable Install Setup
  * Launch in directory
  * Hotkey via AHK 
  * Inno Setup Script
