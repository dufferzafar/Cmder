# Cmder
<!-- ![Butler](/Data/butler.png) -->

A fork of the awesome [Cmder](https://github.com/bliker/cmder/) project.

Was customizing it for myself, thought I'd just share it.

I use Autohotkey to pass the current explorer directory as a parameter.
Without which it'll launch in the directory where "Cmder.bat" is placed.

I've added "msysgit", "gow", "putty" for myself. They are in the vendor folder. You can place other 3rd party stuff there too.

See the ".gitignore" file for the entire structure.

## Table of Contents

* [What has been changed?](#changelog)
* [Stuff to do](#todo)

## <a name="changelog"></a>Things changed


* Modified: ConEmu settings: <config/ConEmu.xml>
  * Tabs on top
  * No transparency
  * Runs in a single instance
  * Xterm highlighting instead of Monokai
  * Shows only active console icon in taskbar
  * No new tab confirmation
  * Removed the "-new_console:d:%USERPROFILE%" part to launch in any directory.

* Modified: init.bat <vendor/init.bat>
  * The %PATH% directory.

* Modified: alias.bat <config/alias.bat>
  * Run alias command without any parameters to list all aliases.

* Modified: Added some more aliases: <config/aliases>
  * clear = cls
  * Git Fun!

* Added: msysgit, gow, putty. <vendor/>

## <a name="hotkeys"></a>List of Hotkeys

Clink and ConEmu-Maximus5 together offer a wide range of hotkeys.

Here are some of the most used ones:

* `Alt + `` Hides the console.
* `Alt+H` : List Clink Hotkeys
* `Alt+Win+P` : ConEmu Settings

* `Ctrl+W` : Close current tab
* `Ctrl+Shift+W` : Close the current process of console

* `Ctrl+PgUp/PgDn` : Cycle through tabs 
* `Shift+PgUp/PgDn` : Scroll through buffer

## <a name="todo"></a>Todo

* `Ctrl+Shift+T` - Load last open tab


* Keyboard Text Selection

* Add Tools:
  * Update tools used in GOW
  * FAR
  * Commandline Sysinternals Tools
  * Nirsoft Utilities

* Setup
  * Launch in directory
  * Hotkey via AHK 
  * Inno Setup Script
