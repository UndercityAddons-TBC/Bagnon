--[[
	Bagnon Localization file: German
		Credit goes to Sarkan on Curse and ArtureLeCoiffeur on ui.worldofwar.net
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Bagnon', 'deDE')
if not L then return end

--bindings
L.BagnonToggle = "Inventar umschalte"
L.BanknonToggle = "Bank umschalten"

--system messages
L.NewUser = "New user detected, default settings loaded"
L.Updated = "Updated to v%s"
L.UpdatedIncompatible = "Updating from an incompatible version, defaults loaded"

--errors
L.ErrorNoSavedBank = "Cannot open the bank, no saved information available"

--slash commands
L.Commands = "Befehle:"
L.ShowMenuDesc = "Shows the options menu"
L.ShowBagsDesc = "Toggles the inventory frame"
L.ShowBankDesc = "Toggles the bank frame"

--frame text
L.TitleBank = "Bankfach von %s"
L.TitleBags = "Inventar von %s"
L.ShowBags = "+ Taschen"
L.HideBags = "- Taschen"

--tooltips
L.TipShowMenu = "<Rechts-Klick> Um Einstellungs Men\195\188 zu zeigen"
L.TipShowSearch = "<Doppelklick> zum Suchen"
L.TipShowBag = "<Klick> zum zeigen"
L.TipHideBag = "<Klick> zum verstecken"
L.TipGoldOnRealm = "Total on %s"