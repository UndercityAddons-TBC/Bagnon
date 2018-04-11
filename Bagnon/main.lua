--[[
	Bagnon
		Handles settings management, and bank and inventory viewing
--]]

Bagnon = LibStub('AceAddon-3.0'):NewAddon('Bagnon', 'AceEvent-3.0', 'AceConsole-3.0')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local CURRENT_VERSION = GetAddOnMetadata("Bagnon", "Version")

--bindings
BINDING_HEADER_BAGNON = "Bagnon"
BINDING_NAME_BAGNON_TOGGLE = L.BagnonToggle
BINDING_NAME_BANKNON_TOGGLE = L.BanknonToggle


--[[ Startup and settings management ]]--

function Bagnon:OnInitialize()
	local defaults = {
		inventory = {
			bags = {0, 1, 2, 3, 4},
			bg = {r = 0, g = 0.2, b = 0, a = 0.5},
		},

		bank = {
			bags = {-1, 5, 6, 7, 8, 9, 10, 11},
			bg = {r = 0, g = 0, b = 0.2, a = 0.5},
		},

		replaceBags = 1,

		showBorders = 1,
		showBagsAtMail = 1,
		showBagsAtVendor = 1,
		showBagsAtBank = 1,
		showBagsAtAH = 1,
		showBankAtBank = 1,

		version = CURRENT_VERSION,
	}

	if not(BagnonSets and BagnonSets.version) then
		BagnonSets = defaults
		self:Print(L.NewUser)
	else
		local cMajor, cMinor = CURRENT_VERSION:match("(%d+)%.(%d+)")
		local major, minor = BagnonSets.version:match("(%d+)%.(%d+)")

		if major ~= cMajor then
			BagnonSets = defaults
			self:Print(L.UpdatedIncompatible)
		elseif minor ~= cMinor then
			self:UpdateSettings()
		end

		if BagnonSets.version ~= CURRENT_VERSION then
			self:UpdateVersion()
		end
	end
	self.sets = BagnonSets
	
	self:RegisterEvent('PLAYER_LOGOUT')
end

function Bagnon:UpdateSettings()
	self:UpdateVersion()
end

function Bagnon:UpdateVersion()
	BagnonSets.version = CURRENT_VERSION
	self:Print(format(L.Updated, BagnonSets.version))
end

function Bagnon:OnEnable()
	BankFrame:UnregisterEvent("BANKFRAME_OPENED")

	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("TRADE_SHOW")
	self:RegisterEvent("TRADE_CLOSED")
	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("AUCTION_HOUSE_SHOW")
	self:RegisterEvent("AUCTION_HOUSE_CLOSED")
	self:RegisterEvent("MAIL_SHOW")
	self:RegisterEvent("MAIL_CLOSED")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("MERCHANT_CLOSED")

	self:RegisterSlashCommands()
	self:HookBagClicks()
end

function Bagnon:PLAYER_LOGOUT()
	if self.updateReplaceBags then
		self.sets.replaceBags = self.replaceBags
	end
end


--[[ Inventory Frame Display ]]--

function Bagnon:CreateInventory()
	local bags = BagnonFrame:Create(L.TitleBags, self.sets.inventory, {0, 1, 2, 3, 4, -2})
	table.insert(UISpecialFrames, bags:GetName())

	local OnShow = bags:GetScript("OnShow")
	bags:SetScript("OnShow", function(self)
		PlaySound("igBackPackOpen")
		OnShow(self)
	end)

	local OnHide = bags:GetScript("OnHide")
	bags:SetScript("OnHide", function(self)
		PlaySound("igBackPackClose")
		OnHide(self)
	end)

	if not bags:IsUserPlaced() then
		bags:SetPoint('RIGHT', UIParent)
	end

	self.bags = bags

	return bags
end

function Bagnon:ShowInventory(auto)
	local bags = self.bags
	if bags then
		if not bags:IsVisible() then
			bags:Show()
			bags.manOpened = not auto
		end
	else
		bags = self:CreateInventory()
		bags.manOpened = not auto
	end
end

function Bagnon:HideInventory(auto)
	local bags = self.bags
	if bags and not(auto and bags.manOpened) then
		bags:Hide()
	end
end

function Bagnon:ToggleInventory(auto)
	local bags = self.bags
	if bags and bags:IsVisible() then
		self:HideInventory(auto)
	else
		self:ShowInventory(auto)
	end
end

function Bagnon:InventoryHasBag(id)
	local bags = self.sets.inventory.bags
	for _, bag in pairs(bags) do
		if bag == id then
			return true
		end
	end
end

function Bagnon:GetInventory()
	return self.bags
end


--[[ Bank Frame Display ]]--

function Bagnon:CreateBank()
	local bank = BagnonFrame:Create(L.TitleBank, self.sets.bank, {-1, 5, 6, 7, 8, 9, 10, 11}, true)
	table.insert(UISpecialFrames, bank:GetName())

	local OnShow = bank:GetScript("OnShow")
	bank:SetScript("OnShow", function(self)
		PlaySound("igBagnonMenuOpen")
		OnShow(self)
	end)

	local OnHide = bank:GetScript("OnHide")
	bank:SetScript("OnHide", function(self)
		PlaySound("igBagnonMenuClose")
		CloseBankFrame()
		OnHide(self)
	end)

	if not bank:IsUserPlaced() then
		bank:SetPoint('LEFT', 0, 100)
	end

	self.bank = bank

	return bank
end

function Bagnon:ShowBank(auto)
	if BagnonDB or BagnonUtil:AtBank() then
		local bank = self.bank
		if bank then
			if not bank:IsVisible() then
				bank:Show()
				bank.manOpened = not auto
			end
		else
			bank = self:CreateBank()
			bank.manOpened = not auto
		end
	else
		UIErrorsFrame:AddMessage(L.ErrorNoSavedBank)
	end
end

function Bagnon:HideBank(auto)
	local bank = self.bank
	if bank and not(auto and bank.manOpened) then
		bank:Hide()
	end
end

function Bagnon:ToggleBank(auto)
	local bank = self.bank
	if bank and bank:IsVisible() then
		return self:HideBank(auto)
	else
		return self:ShowBank(auto)
	end
end

function Bagnon:BankHasBag(id)
	local bags = self.sets.bank.bags
	for _, bag in pairs(bags) do
		if bag == id then
			return true
		end
	end
end

function Bagnon:GetBank()
	return self.bank
end


--[[
	Frame Hiding/Showing - bag clicks
		These functions allow bagnon/banknon to be shown by clicking ona bag, or by using a bag"s hotkey
--]]

local function FrameOpened(id, auto)
	if Bagnon:InventoryHasBag(id) or (BagnonUtil:ReplacingBags() and BagnonUtil:IsInventoryBag(id)) then
		Bagnon:ShowInventory(auto)
		return true
	end

	if Bagnon:BankHasBag(id) or (BagnonUtil:ReplacingBank() and BagnonUtil:IsBankBag(id)) then
		Bagnon:ShowBank(auto)
		return true
	end
end

local function FrameClosed(id, auto)
	if Bagnon:InventoryHasBag(id) or (BagnonUtil:ReplacingBags() and BagnonUtil:IsInventoryBag(id)) then
		Bagnon:HideInventory(auto)
		return true
	end

	if Bagnon:BankHasBag(id) or (BagnonUtil:ReplacingBank() and BagnonUtil:IsBankBag(id)) then
		Bagnon:HideBank(auto)
		return true
	end
end

local function FrameToggled(id, auto)
	if Bagnon:InventoryHasBag(id) or (BagnonUtil:ReplacingBags() and BagnonUtil:IsInventoryBag(id)) then
		Bagnon:ToggleInventory(auto)
		return true
	end

	if Bagnon:BankHasBag(id) or (BagnonUtil:ReplacingBank() and BagnonUtil:IsBankBag(id)) then
		Bagnon:ToggleBank(auto)
		return true
	end
end

function Bagnon:HookBagClicks()
	local oOpenBackpack = OpenBackpack
	OpenBackpack = function()
		if not FrameOpened(0) then
			oOpenBackpack(true)
		end
	end

	local oCloseBackpack = CloseBackpack
	CloseBackpack = function()
		if not FrameClosed(0) then
			oCloseBackpack(true)
		end
	end

	local oToggleBackpack = ToggleBackpack
	ToggleBackpack = function()
		if not FrameToggled(0) then
			oToggleBackpack()
		end
	end

	local oOpenAllBags = OpenAllBags
	OpenAllBags = function(force)
		if BagnonUtil:ReplacingBags() then
			if force then
				Bagnon:ShowInventory()
			else
				Bagnon:ToggleInventory()
			end
		else
			oOpenAllBags(force)
		end
	end

	--secure'd!
	hooksecurefunc('CloseAllBags', function() 
		if BagnonUtil:ReplacingBags() then
			Bagnon:HideInventory()
		end
	end)

	local oToggleBag = ToggleBag
	ToggleBag = function(id)
		if not FrameToggled(id) then
			oToggleBag(id)
		end
	end

	local bToggleKeyRing = ToggleKeyRing
	ToggleKeyRing = function()
		if not FrameToggled(KEYRING_CONTAINER) then
			bToggleKeyRing()
		end
	end
end

--[[
	Automatic Frame Display
		These functions control the display of bagnon/banknon when an event happens, like opeing the AH
--]]

local function ShowBlizBank()
	BankFrameTitleText:SetText(UnitName("npc"))
	SetPortraitTexture(BankPortraitTexture, "npc")
	ShowUIPanel(BankFrame)

	if not BankFrame:IsVisible() then
		CloseBankFrame()
	end
	UpdateBagSlotStatus()
end

local function ShowAtEvent(event, showBlizBank)
	if Bagnon.sets[format("showBagsAt%s", event)] then
		Bagnon:ShowInventory(true)
	end

	if Bagnon.sets[format("showBankAt%s", event)] then
		Bagnon:ShowBank(true)
	end

	if showBlizBank then
		ShowBlizBank()
	end
end

local function HideAtEvent(event)
	if Bagnon.sets[format("showBagsAt%s", event)] then
		Bagnon:HideInventory(true)
	end

	if Bagnon.sets[format("showBankAt%s", event)] then
		Bagnon:HideBank(true)
	end
end

function Bagnon:BANKFRAME_OPENED()
	ShowAtEvent("Bank", not(BagnonUtil:ReplacingBank()))
end

function Bagnon:BANKFRAME_CLOSED()
	HideAtEvent("Bank")
end

function Bagnon:TRADE_SHOW()
	ShowAtEvent("Trade")
end

function Bagnon:TRADE_CLOSED()
	HideAtEvent("Trade")
end

function Bagnon:TRADE_SKILL_SHOW()
	ShowAtEvent("Craft")
end

function Bagnon:TRADE_SKILL_CLOSE()
	HideAtEvent("Craft")
end

function Bagnon:AUCTION_HOUSE_SHOW()
	ShowAtEvent("AH")
end

function Bagnon:AUCTION_HOUSE_CLOSED()
	HideAtEvent("AH")
end

function Bagnon:MAIL_SHOW()
	ShowAtEvent("Mail")
end

function Bagnon:MAIL_CLOSED()
	HideAtEvent("Mail")
end

function Bagnon:MERCHANT_SHOW()
	ShowAtEvent("Vendor")
end

function Bagnon:MERCHANT_CLOSED()
	HideAtEvent("Vendor")
end


--[[  Slash Commands ]]--

function Bagnon:RegisterSlashCommands()
	self:RegisterChatCommand('bagnon', 'OnCmd')
	self:RegisterChatCommand('bgn', 'OnCmd')
end

function Bagnon:OnCmd(cmd)
	if cmd ~= '' then
		cmd = cmd:lower()
		if cmd == 'bank' then
			self:ToggleBank()
		elseif cmd == 'bags' then
			self:ToggleInventory()
		elseif cmd == 'version' then
			self:PrintVersion()
		else
			self:PrintHelp()
		end
	else
		self:ShowMenu()
	end
end

function Bagnon:PrintVersion()
	self:Print(self.sets.version)
end

function Bagnon:PrintHelp(cmd)
	local function PrintCmd(cmd, desc)
		DEFAULT_CHAT_FRAME:AddMessage(format(' - |cFF33FF99%s|r: %s', cmd, desc))
	end

	self:Print(L.Commands)
	PrintCmd('bags', L.ShowBagsDesc)
	PrintCmd('bank', L.ShowBankDesc)
	PrintCmd('version', L.ShowVersionDesc)
end

function Bagnon:ShowMenu()
	local enabled = select(4, GetAddOnInfo("Bagnon_Options"))
	if enabled then
		if BagnonOptions then
			if BagnonOptions:IsShown() then
				BagnonOptions:Hide()
			else
				BagnonOptions:Show()
			end
		else
			LoadAddOn("Bagnon_Options")
		end
	else
		self:ShowHelp()
	end
end


--[[ Tooltips ]]--

function Bagnon:SetShowOwners(enable)
	self.sets.showOwners = (enable and 1) or nil
end

function Bagnon:ShowingOwners()
	return self.sets.showOwners
end