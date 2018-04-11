--[[
	BagnonUtil
		A library of functions for accessing bag data
--]]

BagnonUtil = CreateFrame('Frame')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')
local currentPlayer = UnitName('player')
local typeContainer = select(3, GetAuctionItemClasses())
local typeQuiver = select(7, GetAuctionItemClasses())
local subTypeBag = select(1, GetAuctionItemSubClasses(3))
local subTypeSoulBag = select(2, GetAuctionItemSubClasses(3))


--[[ Bank ]]--

BagnonUtil:SetScript('OnEvent', function(self, event)
	self.atBank = (event == 'BANKFRAME_OPENED')
end)
BagnonUtil:RegisterEvent('BANKFRAME_OPENED')
BagnonUtil:RegisterEvent('BANKFRAME_CLOSED')

function BagnonUtil:AtBank()
	return self.atBank
end


--[[ Item/Bag Info Retrieval ]]--

function BagnonUtil:GetInvSlot(bag)
	return bag > 0 and ContainerIDToInventoryID(bag)
end

function BagnonUtil:GetBagSize(bag, player)
	if self:IsCachedBag(bag, player) then
		return (BagnonDB and BagnonDB:GetBagData(bag, player)) or 0
	end
	return (bag == KEYRING_CONTAINER and GetKeyRingSize()) or GetContainerNumSlots(bag)
end

function BagnonUtil:GetBagLink(bag, player)
	if self:IsCachedBag(bag, player) then
		return BagnonDB and (select(2, BagnonDB:GetBagData(bag, player)))
	end
	return GetInventoryItemLink('player', self:GetInvSlot(bag))
end

function BagnonUtil:GetItemLink(bag, slot, player)
	if self:IsCachedBag(bag, player) then
		return BagnonDB and (BagnonDB:GetItemData(bag, slot, player))
	end
	return GetContainerItemLink(bag, slot)
end

function BagnonUtil:GetItemCount(bag, slot, player)
	if self:IsCachedBag(bag, player) then
		if BagnonDB then
			local link, count = BagnonDB:GetItemData(bag, slot, player)
			if link then
				return count or 1
			end
		else
			return 0
		end
	end
	return select(2, GetContainerItemInfo(bag, slot))
end


--[[ Bag Type Checks ]]--

--returns true if the given bag is cached AND we have a way of reading data for it
function BagnonUtil:IsCachedBag(bag, player)
	return currentPlayer ~= (player or currentPlayer) or (not self:AtBank() and self:IsBankBag(bag))
end

function BagnonUtil:IsInventoryBag(bag)
	return bag == KEYRING_CONTAINER or (bag > -1 and bag < 5)
end

function BagnonUtil:IsBankBag(bag)
	return (bag == BANK_CONTAINER or bag > 4)
end

--returns if the given bag is an ammo bag/soul bag
--bankslots, the main bag, and the keyring cannot be ammo slots
function BagnonUtil:IsAmmoBag(bag, player)
	if bag <= 0 then return nil end

	local link = self:GetBagLink(bag, player)
	if link then
		local type, subType = select(6, GetItemInfo(link))
		return (type == typeQuiver or subType == subTypeSoulBag)
	end
end

--returns if the given bag is a profession bag (herb bag, engineering bag, etc)
--bankslots, the main bag, and the keyring cannot be ammo slots
function BagnonUtil:IsProfessionBag(bag, player)
	if bag <= 0 then return nil end

	local link = self:GetBagLink(bag, player)
	if link then
		local type, subType = select(6, GetItemInfo(link))
		return type == typeContainer and not(subType == subTypeBag or subType == subTypeSoulBag)
	end
end


--[[ Non bag related stuff ]]--

--creates a new class of objects that inherits from objects of <type>, ex 'Frame', 'Button', 'StatusBar'
--does not chain inheritance
function BagnonUtil:CreateWidgetClass(type)
	local class = CreateFrame(type)
	local mt = {__index = class}

	function class:New(o)
		if o then
			local type, cType = o:GetFrameType(), self:GetFrameType()
			assert(type == cType, format("'%s' expected, got '%s'", cType, type))
		end
		return setmetatable(o or CreateFrame(type), mt)
	end

	return class
end


--[[ Settings ]]--

function BagnonUtil:GetSets()
	return Bagnon.sets
end

function BagnonUtil:SetShowBorders(enable)
	self:GetSets().showBorders = enable or nil

	local bags = Bagnon:GetInventory()
	if bags and bags:IsShown() then
		bags:Regenerate()
	end

	local bank = Bagnon:GetBank()
	if bank and bank:IsShown() then
		bank:Regenerate()
	end
end

function BagnonUtil:ShowingBorders()
	return Bagnon.sets.showBorders
end

function BagnonUtil:SetReplaceBags(enable)
	if not StaticPopupDialogs['BAGNON_CONFIRM_RELOADUI'] then
		StaticPopupDialogs['BAGNON_CONFIRM_RELOADUI'] = {
			text = TEXT(L.ConfirmReloadUI),
			button1 = TEXT(ACCEPT),
			timeout = 0,
			hideOnEscape = 1,
		}
	end
	PlaySound('igMainMenuOption')
	StaticPopup_Show('BAGNON_CONFIRM_RELOADUI')
	
	Bagnon.updateReplaceBags = true
	Bagnon.replaceBags = enable or nil
end

function BagnonUtil:ReplacingBags()
	return Bagnon.sets.replaceBags
end

function BagnonUtil:ReplacingBank()
	return Bagnon.sets.showBankAtBank
end