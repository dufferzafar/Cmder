# Cmder
<!-- ![Butler](/Data/butler.png) -->

A fork of the awesome [Cmder](https://github.com/bliker/cmder/) project.

Was customizing it for myself, thought I'd just share it.

I now use AHK to pass the current explorer directory as a parameter.

I've added "msysgit", "gow", "putty" for myself. They are in the vendor folder. You can place other 3rd party stuff in the same folder.

See the ".gitignore" file for the entire structure.

## Table of Contents

* [Todo](#todo)
* [What has been changed?](#changelog)

## <a name="todo"></a>Todo

* Learn Inno Setup Script to create a Setup?

## <a name="changelog"></a>Changelog

* Modified: ConEmu settings:
  * Xterm Highlighting
  * Tabs on top
  * No Transparency Level.
  * <kbd>Alt + `</kbd> Hides the console. So does <kbd>Esc</kbd>.
  * Removed the "-new_console:d:%USERPROFILE%" part.

* Modified: init.bat
  * The %PATH% directory.

* Modified: Added some more aliases:
  * gs, ga

* Added: msysgit, gow, putty.
