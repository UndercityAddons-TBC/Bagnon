--[[
	item.lua
		An item button
--]]

BagnonItem = BagnonUtil:CreateWidgetClass('Button')
BagnonItem.SIZE = 37

--create a dummy item slot for tooltips and modified clicks of cached items
do
	local slot = CreateFrame('Button')
	slot:RegisterForClicks('anyUp')
	slot:Hide()

	local function Slot_OnEnter(self)
		local parent = self:GetParent()
		local link = parent.hasItem

		parent:LockHighlight()
		if parent.cached and link then
			BagnonItem.AnchorTooltip(self)
			GameTooltip:SetHyperlink(link)
			GameTooltip:Show()
		end
	end

	local function Slot_OnLeave(self)
		GameTooltip:Hide()
		self:Hide()
	end

	local function Slot_OnHide(self)
		local parent = self:GetParent()
		if parent then
			parent:UnlockHighlight()
		end
	end

	local function Slot_OnClick(self, button)
		self:GetParent():OnModifiedClick(button)
	end

	slot.UpdateTooltip = Slot_OnEnter
	slot:SetScript('OnClick', Slot_OnClick)
	slot:SetScript('OnEnter', Slot_OnEnter)
	slot:SetScript('OnLeave', Slot_OnLeave)
	slot:SetScript('OnShow', Slot_OnEnter)
	slot:SetScript('OnHide', Slot_OnHide)

	BagnonItem.dummySlot = slot
end


--[[
	The item widget
--]]

local itemID = 1
local unused = {}

function BagnonItem:Create()
	local item
	if BagnonUtil:ReplacingBags() then
		local button = self:GetBlizzard(itemID)
		if button then
			item = self:New(button)
		end
	end
	if not item then
		local button = CreateFrame('Button', format('BagnonItem%d', itemID), nil, 'ContainerFrameItemButtonTemplate')
		item = self:New(button)
	end
	item:ClearAllPoints()

	local border = item:CreateTexture(nil, 'OVERLAY')
	border:SetWidth(67); border:SetHeight(67)
	border:SetPoint('CENTER', item)
	border:SetTexture('Interface/Buttons/UI-ActionButton-Border')
	border:SetBlendMode('ADD')
	border:Hide()
	item.border = border

	item.cooldown = getglobal(item:GetName() .. 'Cooldown')
--	item.cooldown:SetFrameLevel(4)

	item:UnregisterAllEvents()
	item:SetScript('OnEvent', nil)
	item:SetScript('OnEnter', self.OnEnter)
	item:SetScript('OnHide', self.OnHide)
	item:SetScript('PostClick', self.PostClick)
	item.UpdateTooltip = nil

	itemID = itemID + 1

	return item
end

function BagnonItem:GetBlizzard(id)
	local bag = ceil(id / MAX_CONTAINER_ITEMS)
	local slot = (id-1) % MAX_CONTAINER_ITEMS + 1
	local item = getglobal(format('ContainerFrame%dItem%d', bag, slot))

	if item then
		item:SetID(0)
		return item
	end
end

function BagnonItem:Get()
	local item = next(unused)
	if item then
		unused[item] = nil
		return item
	end
	return self:Create()
end

function BagnonItem:Set(parent, bag, slot)
	self:SetParent(self:GetDummyBag(parent, bag))
	self:SetID(slot)
	self:Update()
end

function BagnonItem:Release()
	unused[self] = true

	self.cached = nil
	self.hasItem = nil
	self:SetParent(nil)
	self:Unfade()
	self:Hide()
end

function BagnonItem:GetDummyBag(parent, id)
	if not parent.dummyBags then
		parent.dummyBags = {}
	end

	local frame = parent.dummyBags[id]
	if not frame then
		frame = CreateFrame('Frame', nil, parent)
		frame:SetID(id)
		parent.dummyBags[id] = frame
	end

	return frame
end


--[[ Update Functions ]]--

-- Update the texture, lock status, and other information about an item
function BagnonItem:Update()
	local _, link, texture, count, locked, readable, quality
	local slot = self:GetID()
	local bag = self:GetBag()
	local player = self:GetPlayer()

	if BagnonUtil:IsCachedBag(bag, player) then
		if BagnonDB then
			link, count, texture, quality = BagnonDB:GetItemData(bag, slot, player)
			self.readable = nil
			self.cached = true
		end
	else
		texture, count, locked, _, readable = GetContainerItemInfo(bag, slot)
		self.readable = readable
		self.cached = nil
	end

	self.hasItem = texture and (link or GetContainerItemLink(bag, slot))

	SetItemButtonDesaturated(self, locked)
	SetItemButtonTexture(self, texture)
	SetItemButtonCount(self, count)

	self:UpdateBorder(quality)
	self:UpdateSlotBorder()
	self:UpdateCooldown()

	if GameTooltip:IsOwned(self) then
		self:UpdateTooltip()
	end
	if BagnonSpot:Searching() then
		self:UpdateSearch()
	end
end

--colors the item border based on the quality of the item.  hides it for common/poor items
function BagnonItem:UpdateBorder(quality)
	local border = self.border
	local link = self.hasItem

	if link and BagnonUtil:ShowingBorders() then
		if not quality then
			quality = select(3, GetItemInfo(link))
		end

		if quality and quality > 1 then
			local r, g, b = GetItemQualityColor(quality)
			border:SetVertexColor(r, g, b, 0.5)
			border:Show()
		else
			border:Hide()
		end
	else
		border:Hide()
	end
end

function BagnonItem:UpdateSlotBorder()
	local bag = self:GetBag()
	local player = self:GetPlayer()
	local normalTexture = getglobal(self:GetName() .. "NormalTexture")

	if bag == KEYRING_CONTAINER then
		normalTexture:SetVertexColor(1, 0.7, 0)
	elseif BagnonUtil:IsAmmoBag(bag, player) then
		normalTexture:SetVertexColor(1, 1, 0)
	elseif BagnonUtil:IsProfessionBag(bag , player) then
		normalTexture:SetVertexColor(0, 1, 0)
	else
		normalTexture:SetVertexColor(1, 1, 1)
	end
end

function BagnonItem:UpdateLock(locked)
	local locked = select(3, GetContainerItemInfo(self:GetBag(), self:GetID()))
	SetItemButtonDesaturated(self, locked)
end

function BagnonItem:UpdateCooldown()
	if (not self.cached) and self.hasItem then
		local start, duration, enable = GetContainerItemCooldown(self:GetBag(), self:GetID())
		CooldownFrame_SetTimer(self.cooldown, start, duration, enable)
	else
		self.cooldown:Hide()
	end
end


--[[ Spot Searching ]]--

function BagnonItem:UpdateSearch()
	local text, bag = BagnonSpot:GetSearch()

	if text or bag then
		if bag then
			if self:GetBag() ~= bag then
				self:Fade()
				return
			end
		end

		if text then
			local link = self.hasItem
			if link then
				--smart text search: will attempt to match type, subtype, and equip locations in addition to names
				local name, _, quality, itemLevel, minLevel, type, subType, _, equipLoc = GetItemInfo(link)
				local text = text:lower()
				local name = name:lower()

				if not(text == name or name:find(text)) then
					local type = type:lower()
					if not(text == type or type:find(text)) then
						local subType = subType:lower()
						if not(text == subType or subType:find(text)) then
							local equipLoc = getglobal(equipLoc) and getglobal(equipLoc):lower()
							if not(equipLoc and (text == equipLoc or equipLoc:find(text))) then
								self:Fade()
								return
							end
						end
					end
				end
			else
				self:Fade()
				return
			end
		end
		self:Unfade(true)
	else
		self:Unfade()
	end
end

function BagnonItem:Fade()
	local parent = self:GetParent()
	if parent then
		self:SetAlpha(0.3)
	end
	self:UnlockHighlight()
end

function BagnonItem:Unfade(highlight)
	self:SetAlpha(1)
	if highlight and not self.hasItem then
		self:LockHighlight()
	else
		self:UnlockHighlight()
	end
end


--[[ Frame Events ]]--

function BagnonItem:OnModifiedClick(button)
	if self.cached then
		if self.hasItem then
			if button == 'LeftButton' then
				if IsModifiedClick('DRESSUP') then
					DressUpItemLink((BagnonDB:GetItemData(self:GetBag(), self:GetID(), self:GetPlayer())))
				elseif IsModifiedClick('CHATLINK') then
					ChatFrameEditBox:Insert(BagnonDB:GetItemData(self:GetBag(), self:GetID(), self:GetPlayer()))
				end
			end
		end
	end
end

function BagnonItem:OnEnter()
	local bag, slot = self:GetBag(), self:GetID()
	if self.cached then
		self.dummySlot:SetParent(self)
		self.dummySlot:SetAllPoints(self)
		self.dummySlot:Show()
	else
		self.dummySlot:Hide()

		--boo for special case bank code
		if bag == BANK_CONTAINER then
			if self.hasItem then
				self:AnchorTooltip()
				GameTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(slot))
				GameTooltip:Show()
			end
		else
			ContainerFrameItemButton_OnEnter(self)
		end
	end
end
BagnonItem.UpdateTooltip = BagnonItem.OnEnter

function BagnonItem:OnHide()
	if self.hasStackSplit and self.hasStackSplit == 1 then
		StackSplitFrame:Hide()
	end
end


--[[ Convenience Functions ]]--

function BagnonItem:GetPlayer()
	local bag = self:GetParent()
	if bag then
		local frame = bag:GetParent()
		return frame and frame:GetPlayer()
	end
	return currentPlayer
end

function BagnonItem:GetBag()
	local bag = self:GetParent()
	return bag and bag:GetID()
end

function BagnonItem:AnchorTooltip()
	if self:GetRight() >= (GetScreenWidth() / 2) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end
end