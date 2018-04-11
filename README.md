### Overview
**Bagnon** is a highly customizable bag replacement addon designed to help the player find items as quickly and as easily as possible. Beyond the basic all-bags-in-one functionality, Bagnon provides features such as:
- Ability to view the items of any character, from anywhere
- Inventory, bank, vault and guild bank support
- Coloring based on item quality and more
- Intelligent item search engine
- Tooltip item counts
- Item rulesets
- Databroker support

### Installation
The ZIP file you downloaded should contain a top-level directory (e.g. *Bagnon-master*), inside of which should be the following 4 subdirectories:
1. ***Bagnon***
1. ***Bagnon_Forever***
1. ***Bagnon_Options***
1. ***Bagnon_Tooltips***

- Extract each of these 4 subdirectories and place them (and their contents) into <***WoW-Game-Folder***>*/Interface/Addons/*
- Start/restart your game.

### Original Addon
The official Bagnon Addon website is:
	https://github.com/tullamods/Bagnon

### ChangeLog

Bagnon Version History

1.5.2
Fixed a toc issue

1.5.1
Fixed a bug with bag hooks

1.5.0
Redesigned the options menu.

1.4.9
Fixed some errors causing Bagnon_Forever to not load properly
Updated the esES translation (thanks Ferroginus)
Minor tweaks

1.4.8
Removed the errant tooltips.lua from the Bagnon toc
Removed a source of taint from the CloseAllBags hook
Fixed a bug causing the bank frame to not properly close when closing it manually
Updated the zhTW translation (thanks matini)

1.4.7
Added more nil checks to Bagnon Tooltips

1.4.6
Fixed a bug allowing your items to be picked up when viewing cached data
Fixed a bug causing the bank frame to not be able to be viewed
Split off ownership tooltips into the addon Bagnon Tooltips.

1.4.5
Fixed a bug when creating a new frame with default settings

1.4.4
Bagnon_Forever has been changed to be load on demand, with Bagnon listing it as an optional dependency.
Rewrote a good portion of the code.
Fixed a bug causing cooldowns to not properly update.
Fixed some layering issues.
Gave empty bag slots a texture
Purchsable bag slots are now colored red
Clicking on a purchasable bag will now bring up the purchase dialog
Removed the old purchase frame
Added zhTW localization (thanks to matini)

1.4.3
Bagnon_Forever: Fixed an error with compression causing suffix data to not be properly saved

1.4.2
Fixed an issue with using equip compare on cached item slots introduced by 1.4.1

1.4.1
Fixed an error when clicking trade skill item links
Fixed a bug where linking a cached item would sometimes produce double links

1.4.0
Updated for 2.2
Reduced CPU usage significantly when showing the bank/bags
Recoded Bagnon Forever to get a bit better compression.  Bag data has been reset

1.3b
Fixed a bug causing the main options menu to not work

1.3
Updated for 2.1

1.2
Rewrote the code for hooking the bag slots, and automatic display

1.1
Clicking on the keyring button will now properly show the inventory window
Added a check to disable vBagnon if Bagnon is running

1.0
Initial release
