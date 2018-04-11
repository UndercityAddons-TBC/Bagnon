--[[
	BagnonBag
		A bag button object
--]]

BagnonBag = BagnonUtil:CreateWidgetClass('Button')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')

local SIZE = 32
local NORMAL_TEXTURE_SIZE = 64 * (SIZE/36)
local KEY_WIDTH = 18 * (SIZE/36)
local id = 1

function BagnonBag:Create(parent, bagID)
	local bag = (bagID == KEYRING_CONTAINER and self:CreateKey()) or self:CreateBag(bagID)
	bag:SetParent(parent)
	bag:SetID(bagID)
	bag:Update()

	return bag
end

function BagnonBag:CreateBag(bagID)
	local bag = self:New(CreateFrame('Button', format('BagnonBag%d', id)))
	local name = bag:GetName()
	bag:SetWidth(SIZE)
	bag:SetHeight(SIZE)

	local icon = bag:CreateTexture(name .. 'IconTexture', 'BORDER')
	icon:SetAllPoints(bag)

	local count = bag:CreateFontString(name .. 'Count', 'OVERLAY')
	count:SetFontObject('NumberFontNormalSmall')
	count:SetJustifyH('RIGHT')
	count:SetPoint('BOTTOMRIGHT', -2, 2)

	local normalTexture = bag:CreateTexture(name .. 'NormalTexture')
	normalTexture:SetTexture('Interface/Buttons/UI-Quickslot2')
	normalTexture:SetWidth(NORMAL_TEXTURE_SIZE)
	normalTexture:SetHeight(NORMAL_TEXTURE_SIZE)
	normalTexture:SetPoint('CENTER', 0, -1)
	bag:SetNormalTexture(normalTexture)

	local pushedTexture = bag:CreateTexture()
	pushedTexture:SetTexture('Interface/Buttons/UI-Quickslot-Depress')
	pushedTexture:SetAllPoints(bag)
	bag:SetPushedTexture(pushedTexture)

	local highlightTexture = bag:CreateTexture()
	highlightTexture:SetTexture('Interface/Buttons/ButtonHilight-Square')
	highlightTexture:SetAllPoints(bag)
	bag:SetHighlightTexture(highlightTexture)

	bag:RegisterForClicks('anyUp')
	bag:RegisterForDrag('LeftButton')

	bag:SetScript('OnEnter', self.OnEnter)
	bag:SetScript('OnLeave', self.OnLeave)
	bag:SetScript('OnClick', self.OnClick)
	bag:SetScript('OnDragStart', self.OnDrag)
	bag:SetScript('OnReceiveDrag', self.OnClick)

	if bagID > 0 then
		bag:SetScript('OnEvent', self.OnEvent)
		bag:SetScript('OnShow', self.UpdateEvents)
		bag:SetScript('OnHide', self.UpdateEvents)
		bag:UpdateEvents()
		bag:Update()
	else
		SetItemButtonTexture(bag, 'Interface/Buttons/Button-Backpack-Up')
		SetItemButtonTextureVertexColor(bag, 1, 1, 1)
	end

	id = id + 1
	return bag
end

function BagnonBag:CreateKey()
	local bag = self:New(CreateFrame('Button', format('BagnonBag%d', id)))
	local name = bag:GetName()

	bag:SetWidth(KEY_WIDTH); bag:SetHeight(SIZE)

	local normalTexture = bag:CreateTexture(name .. 'NormalTexture')
	normalTexture:SetTexture('Interface/Buttons/UI-Button-KeyRing')
	normalTexture:SetAllPoints(bag)
	normalTexture:SetTexCoord(0, 0.5625, 0, 0.609375)
	bag:SetNormalTexture(normalTexture)

	local pushedTexture = bag:CreateTexture()
	pushedTexture:SetTexture('Interface/Buttons/UI-Button-KeyRing-Down')
	pushedTexture:SetAllPoints(bag)
	pushedTexture:SetTexCoord(0, 0.5625, 0, 0.609375)
	bag:SetPushedTexture(pushedTexture)

	local highlightTexture = bag:CreateTexture()
	highlightTexture:SetTexture('Interface/Buttons/UI-Button-KeyRing-Highlight')
	highlightTexture:SetAllPoints(bag)
	highlightTexture:SetTexCoord(0, 0.5625, 0, 0.609375)
	bag:SetHighlightTexture(highlightTexture)

	bag:RegisterForClicks('anyUp')
	bag:RegisterForDrag('LeftButton')

	bag:SetScript('OnEnter', self.OnEnter)
	bag:SetScript('OnLeave', self.OnLeave)
	bag:SetScript('OnClick', self.OnClick)
	bag:SetScript('OnReceiveDrag', self.OnClick)
	bag:SetScript('OnDragStart', self.OnDrag)

	id = id + 1
	return bag
end


--[[ Events ]]--

function BagnonBag:OnEvent(event)
	if event == 'BANKFRAME_OPENED' or event == 'BANKFRAME_CLOSED' then
		self:Update()
	elseif not BagnonUtil:IsCachedBag(self:GetID(), self:GetPlayer()) then
		if event == 'ITEM_LOCK_CHANGED' then
			self:UpdateLock()
		elseif event == 'CURSOR_UPDATE' then
			self:UpdateCursor()
		elseif event == 'BAG_UPDATE' or event == 'PLAYERBANKSLOTS_CHANGED' then
			self:Update()
		elseif event == 'PLAYERBANKBAGSLOTS_CHANGED' then
			self:Update()
		end
	end
end

function BagnonBag:UpdateEvents()
	if not self:IsVisible() then
		self:UnregisterAllEvents()
	else
		if BagnonUtil:IsBankBag(self:GetID()) then
			self:RegisterEvent('BANKFRAME_OPENED')
			self:RegisterEvent('BANKFRAME_CLOSED')
		end
		self:RegisterEvent('ITEM_LOCK_CHANGED')
		self:RegisterEvent('CURSOR_UPDATE')
		self:RegisterEvent('BAG_UPDATE')
		self:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
		self:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED')
	end
end


--[[ Update ]]--

function BagnonBag:Update()
	self:UpdateLock()
	self:UpdateTexture()

	-- Update repair all button status
	if MerchantRepairAllIcon then
		local repairAllCost, canRepair = GetRepairAllCost()
		if canRepair then
			SetDesaturation(MerchantRepairAllIcon, nil)
			MerchantRepairAllButton:Enable()
		else
			SetDesaturation(MerchantRepairAllIcon, true)
			MerchantRepairAllButton:Disable()
		end
	end
end

function BagnonBag:UpdateLock()
	if self:GetID() > 0 then
		local bagID = self:GetID()
		local player = self:GetPlayer()

		if IsInventoryItemLocked(BagnonUtil:GetInvSlot(bagID)) and not BagnonUtil:IsCachedBag(bagID, player) then
			getglobal(self:GetName() .. 'IconTexture'):SetDesaturated(true)
		else
			getglobal(self:GetName() .. 'IconTexture'):SetDesaturated(false)
		end
	end
end

function BagnonBag:UpdateCursor()
	local invID = BagnonUtil:GetInvSlot(self:GetID())
	if CursorCanGoInSlot(invID) then
		self:LockHighlight()
	else
		self:UnlockHighlight()
	end
end

--actually, update texture and count
function BagnonBag:UpdateTexture()
	local bagID = self:GetID()
	if bagID > 0 then
		local player = self:GetPlayer()

		if BagnonUtil:IsCachedBag(bagID, player) then
			if BagnonDB then
				local link, count, texture = select(2, BagnonDB:GetBagData(self:GetID(), player))
				if link then
					self.hasItem = true
					SetItemButtonTexture(self, texture)
					SetItemButtonTextureVertexColor(self, 1, 1, 1)
				else
					SetItemButtonTexture(self, 'Interface/PaperDoll/UI-PaperDoll-Slot-Bag')

					--color red if the bag can be purchased
					local numBankSlots = BagnonDB:GetNumBankSlots(player)
					if numBankSlots and bagID > (numBankSlots + 4) then
						SetItemButtonTextureVertexColor(self, 1, 0.1, 0.1)
					else
						SetItemButtonTextureVertexColor(self, 1, 1, 1)
					end

					self.hasItem = nil
				end
				self:SetCount(count)
			end
		else
			local texture = GetInventoryItemTexture('player', BagnonUtil:GetInvSlot(self:GetID()))
			if texture then
				self.hasItem = true

				SetItemButtonTexture(self, texture)
				SetItemButtonTextureVertexColor(self, 1, 1, 1)
			else
				self.hasItem = nil

				--color red if the bag can be purchased
				SetItemButtonTexture(self, 'Interface/PaperDoll/UI-PaperDoll-Slot-Bag')
				if bagID > (GetNumBankSlots() + 4) then
					SetItemButtonTextureVertexColor(self, 1, 0.1, 0.1)
				else
					SetItemButtonTextureVertexColor(self, 1, 1, 1)
				end
			end
			self:SetCount(GetInventoryItemCount('player', BagnonUtil:GetInvSlot(self:GetID())))
		end
	end
end

function BagnonBag:SetCount(count)
	local text = getglobal(self:GetName() .. 'Count')
	if self:GetID() > 0 then
		local count = count or 0
		if count > 1 then
			if count > 999 then
				text:SetFormattedText('%.1fk', count/1000)
			else
				text:SetText(count)
			end
			text:Show()
		else
			text:Hide()
		end
	else
		text:Hide()
	end
end


--[[ Frame Events ]]--

function BagnonBag:OnShow()
	self:UpdateTexture()
	self:UpdateEvents()
end

function BagnonBag:OnClick()
	local player = self:GetPlayer()
	local bagID = self:GetID()

	if BagnonUtil:IsCachedBag(bagID, player) then
		local frame = self:GetParent():GetParent()
		frame:ShowBag(bagID, not frame:ShowingBag(bagID))
	else
		if CursorHasItem() then
			if bagID == KEYRING_CONTAINER then
				PutKeyInKeyRing()
			elseif bagID == BACKPACK_CONTAINER then
				PutItemInBackpack()
			else
				PutItemInBag(ContainerIDToInventoryID(bagID))
			end
		elseif bagID > (GetNumBankSlots() + 4) then
			self:PurchaseSlot()
		else
			local frame = self:GetParent():GetParent()
			frame:ShowBag(bagID, not frame:ShowingBag(bagID))
		end
	end
end

function BagnonBag:OnDrag()
	local player = self:GetPlayer()
	local bagID = self:GetID()

	if not(BagnonUtil:IsCachedBag(bagID, player) or bagID <= 0) then
		PlaySound('BAGMENUBUTTONPRESS')
		PickupBagFromSlot(BagnonUtil:GetInvSlot(bagID))
	end
end

--tooltip functions
function BagnonBag:OnEnter()
	local player = self:GetPlayer()
	local bagID = self:GetID()
	local hasBag

	self:AnchorTooltip()

	--backpack tooltip
	if bagID == BACKPACK_CONTAINER then
		hasBag = true
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1, 1, 1)
	--bank specific code
	elseif bagID == BANK_CONTAINER then
		hasBag = true
		GameTooltip:SetText('Bank', 1, 1, 1)
	--keyring specific code...again
	elseif bagID == KEYRING_CONTAINER then
		hasBag = true
		GameTooltip:SetText(KEYRING, 1, 1, 1)
	--cached bags
	elseif BagnonUtil:IsCachedBag(bagID, player) then
		if BagnonDB then
			local link = select(2, BagnonDB:GetBagData(bagID, player))
			if link then
				hasBag = true
				GameTooltip:SetHyperlink(link)
			else
				local numBankSlots = BagnonDB:GetNumBankSlots(player)
				if numBankSlots and bagID > (numBankSlots + 4) then
					GameTooltip:SetText(BANK_BAG_PURCHASE, 1, 1, 1)
				else
					GameTooltip:SetText(EQUIP_CONTAINER, 1, 1, 1)
				end
			end
		end
	--non cached bags
	else
		--show the bag tooltip for filled bag slots
		if GameTooltip:SetInventoryItem('player', BagnonUtil:GetInvSlot(bagID)) then
			hasBag = true
		--no bag, show the purchase thing for purchasble bag slots, otherwise show the empty container text
		else
			if bagID > (GetNumBankSlots() + 4) then
				GameTooltip:SetText(BANK_BAG_PURCHASE, 1, 1, 1)
				GameTooltip:AddLine('<Click> to Purchase')
				SetTooltipMoney(GameTooltip, GetBankSlotCost(GetNumBankSlots()))
			else
				GameTooltip:SetText(EQUIP_CONTAINER, 1, 1, 1)
			end
		end
	end

	if hasBag then
		if self:GetParent():GetParent():ShowingBag(bagID) then
			GameTooltip:AddLine(L.TipHideBag)
		else
			GameTooltip:AddLine(L.TipShowBag)
		end
		BagnonSpot:SetBagSearch(bagID)
	end
	GameTooltip:Show()
end
BagnonBag.UpdateTooltip = BagnonBag.OnEnter

function BagnonBag:OnLeave()
	GameTooltip:Hide()
	BagnonSpot:SetBagSearch(nil)
end


--[[ Utility Functions ]]--

function BagnonBag:GetPlayer()
	if self:GetParent() then
		return self:GetParent():GetParent():GetPlayer()
	end
end

--place the tooltip
function BagnonBag:AnchorTooltip()
	if self:GetRight() > (GetScreenWidth()/2) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	else
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	end
end

--show the purchase slot dialog
function BagnonBag:PurchaseSlot()
	if not StaticPopupDialogs['CONFIRM_BUY_BANK_SLOT_BAGNON'] then
		StaticPopupDialogs['CONFIRM_BUY_BANK_SLOT_BAGNON'] = {
			text = TEXT(CONFIRM_BUY_BANK_SLOT),
			button1 = TEXT(YES),
			button2 = TEXT(NO),

			OnAccept = function()
				PurchaseSlot()
			end,

			OnShow = function()
				MoneyFrame_Update(this:GetName().. 'MoneyFrame', GetBankSlotCost(GetNumBankSlots()))
			end,

			hasMoneyFrame = 1,
			timeout = 0,
			hideOnEscape = 1,
		}
	end

	PlaySound('igMainMenuOption')
	StaticPopup_Show('CONFIRM_BUY_BANK_SLOT_BAGNON')
end