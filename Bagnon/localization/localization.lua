--[[
	Bagnon Localization Information: English Language
		This file must be present to have partial translations
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Bagnon', 'enUS', true)

L.BagnonToggle = "Toggle Inventory"
L.BanknonToggle = "Toggle Bank"

--system messages
L.NewUser = "New user detected, default settings loaded"
L.Updated = "Updated to v%s"
L.UpdatedIncompatible = "Updating from an incompatible version, defaults loaded"

--errors
L.ErrorNoSavedBank = "Cannot open the bank, no saved information available"
L.vBagnonLoaded = format("vBagnon and Bagnon are incompatible. Click %s to disable vBagnon and reload your UI", TEXT(ACCEPT))

--slash commands
L.Commands = "Commands:"
L.ShowBagsDesc = "Toggles the inventory frame"
L.ShowBankDesc = "Toggles the bank frame"
L.ShowVersionDesc = 'Prints the current verison'

--frame text
L.TitleBank = "%s's Bank"
L.TitleBags = "%s's Inventory"
L.ShowBags = "Show Bags"
L.HideBags = "Hide Bags"

--tooltips
L.TipShowMenu = "<Right-Click> to Configure"
L.TipShowSearch = "<Double-Click> to Search"
L.TipShowBag = "<Click> to Show"
L.TipHideBag = "<Click> to Hide"
L.TipGoldOnRealm = "Total on %s"

L.ConfirmReloadUI = 'This option will be set the next time you log in'