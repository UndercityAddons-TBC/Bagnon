--[[
	Bagnon Localization file: French Language
		Credit goes to namAtsar
--]]

local L = LibStub('AceLocale-3.0'):NewLocale('Bagnon', 'frFR')
if not L then return end

--bindings
L.BagnonToggle = "Afficher Bagnon";
L.BanknonToggle = "Afficher Banknon";

--system messages
L.NewUser = "Charg\195\169"
L.Updated = "Configs \195\160 jour v%s"
L.UpdatedIncompatible = "Updating from an incompatible version, defaults loaded"

--errors
L.ErrorNoSavedBank = "Cannot open the bank, no saved information available"

--slash commands
L.Commands = "Commandes:"
L.ShowMenuDesc = "Show the options menu"
L.ShowBagsDesc = "Toggle the inventory frame"
L.ShowBankDesc = "Toggle the bank frame"

--frame text
L.TitleBags = "Sac de %s"
L.TitleBank = "Banque de %s"
L.ShowBags = "Montrer Sacs"
L.HideBags = "Cacher Sacs"

--tooltips
L.TipShowMenu = "<Clic-Droit> pour ouvrir le menu de Config"
L.TipShowSearch = "<Double-Click> to Search"
L.TipShowBag = "<Clic> pour montrer"
L.TipHideBag = "<Clic> pour cacher"
L.TipGoldOnRealm = "Total on %s"