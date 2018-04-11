--[[
	money.lua
		Money frames for Bagnon windows
--]]

BagnonMoneyFrame = {}

local id = 0
function BagnonMoneyFrame:Create(parent)
	local frame = CreateFrame('Frame', format('BagnonMoney%s', id), parent, 'SmallMoneyFrameTemplate')
	frame:SetScript('OnShow', self.Update)
	frame.Update = self.Update
	frame:Update()

	local click = CreateFrame('Button', nil, frame)
	click:SetFrameLevel(frame:GetFrameLevel() + 3)
	click:SetAllPoints(frame)

	click:SetScript('OnClick', self.OnClick)
	click:SetScript('OnEnter', self.OnEnter)
	click:SetScript('OnLeave', self.OnLeave)

	id = id + 1
	return frame
end

function BagnonMoneyFrame:Update()
	local player = self:GetParent():GetPlayer()
	if player == UnitName('player') or not BagnonDB then
		MoneyFrame_Update(self:GetName(), GetMoney())
	else
		MoneyFrame_Update(self:GetName(), BagnonDB:GetMoney(player))
	end
end

--frame events
function BagnonMoneyFrame:OnClick()
	local parent = self:GetParent()
	local name = parent:GetName()

	if MouseIsOver(getglobal(name .. 'GoldButton')) then
		OpenCoinPickupFrame(COPPER_PER_GOLD, MoneyTypeInfo[parent.moneyType].UpdateFunc(), parent)
		parent.hasPickup = 1
	elseif MouseIsOver(getglobal(name .. 'SilverButton')) then
		OpenCoinPickupFrame(COPPER_PER_SILVER, MoneyTypeInfo[parent.moneyType].UpdateFunc(), parent)
		parent.hasPickup = 1
	elseif MouseIsOver(getglobal(name .. 'CopperButton')) then
		OpenCoinPickupFrame(1, MoneyTypeInfo[parent.moneyType].UpdateFunc(), parent)
		parent.hasPickup = 1
	end
end

function BagnonMoneyFrame:OnEnter()
	if BagnonDB then
		GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
		GameTooltip:SetText(format('Total on %s', GetRealmName()))

		local money = 0
		for player in BagnonDB:GetPlayers() do
			money = money + BagnonDB:GetMoney(player)
		end

		SetTooltipMoney(GameTooltip, money)
		GameTooltip:Show()
	end
end

function BagnonMoneyFrame:OnLeave()
	GameTooltip:Hide()
end