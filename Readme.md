# Cmder
<!-- ![Butler](/Data/butler.png) -->

A fork of the awesome [Cmder](https://github.com/bliker/cmder/) project.

Was customizing it for myself, thought I'd just share it.

I use Autohotkey to pass the current explorer directory as a parameter.
Without which it'll launch in the directory where "Cmder.bat" is placed.

I've added "msysgit", "gow", "putty" for myself. They are in the vendor folder. You can place other 3rd party stuff there too.

See the ".gitignore" file for the entire structure.

## Table of Contents

* [Todo](#todo)
* [What has been changed?](#changelog)

## <a name="todo"></a>Todo

* Ctrl+PgUp/PgDn should be used to Cycle through Tabs as Shift+PgUp/PgDn is already available for scrolling the window.

* Ctrl+Shift+T - Load last open tab

* Enabled Keyboard Text Selection.

* Add Commandline Sysinternals Tools
* Nirsoft Utilities

* Learn Inno Setup Script to create a Setup?

## <a name="changelog"></a>Changelog

* Modified: ConEmu settings: <config/ConEmu.xml>
  * Xterm Highlighting
  * Tabs on top
  * No Transparency.
  * <kbd>Alt + `</kbd> Hides the console. So does <kbd>Esc</kbd>.
  * Removed the "-new_console:d:%USERPROFILE%" part.

* Modified: init.bat <vendor/init.bat>
  * The %PATH% directory.

* Modified: Added some more aliases: <config/aliases>
  * clear = cls
  * Git Fun!

* Added: msysgit, gow, putty.
