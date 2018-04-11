--[[
	BagFrame.lua
--]]

BagnonBagFrame = BagnonUtil:CreateWidgetClass('Frame')
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon')


--[[ Toggle Frame ]]--

local function Toggle_OnClick(self)
	self:GetParent():ShowBags(not self:GetParent().shown, true)
end

local function Toggle_Create(parent, shown)
	local toggle = CreateFrame('Button', nil, parent)
	toggle:SetPoint('BOTTOMLEFT')

	local text = toggle:CreateFontString()
	text:SetPoint('BOTTOMLEFT')
	text:SetJustifyH('LEFT')
	text:SetFontObject('GameFontNormal')

	toggle:SetFontString(text)
	toggle:SetTextColor(1, 0.82, 0)
	toggle:SetHighlightTextColor(1, 1, 1)

	toggle:RegisterForClicks('anyUp')
	toggle:SetScript('OnClick', Toggle_OnClick)
	toggle:SetPoint('BOTTOMLEFT')
	toggle:SetHeight(18)
	toggle:SetWidth(18)

	return toggle
end


--[[ Usable Functions ]]--

local id = 1
function BagnonBagFrame:Create(parent, bags, shown)
	local frame = self:New(CreateFrame('Frame', nil, parent))

	--add bags
	frame.bags = {}
	for i,bagID in ipairs(bags) do
		frame.bags[i] = BagnonBag:Create(frame, bagID)
	end

	--add toggle
	frame.toggle = Toggle_Create(frame, shown)

	--update display
	frame:ShowBags(shown)

	id = id + 1
	return frame
end

function BagnonBagFrame:Layout()
	local width = self:GetToggleWidth()
	local height = 18

	if self.shown then
		local bagWidth = 0
		for i, bag in ipairs(self.bags) do
			bag:Show()
			bag:ClearAllPoints()
			if i > 1 then
				bag:SetPoint('BOTTOMLEFT', self.bags[i-1], 'BOTTOMRIGHT', 2, 0)
			else
				height = height + bag:GetHeight()
				bag:SetPoint('TOPLEFT', 2, 0)
			end
			bagWidth = bagWidth + bag:GetWidth() + 2
		end
		width = max(bagWidth, width)
	else
		for _,bag in ipairs(self.bags) do
			bag:Hide()
		end
	end

	self:SetWidth(width)
	self:SetHeight(height)
end

function BagnonBagFrame:ShowBags(show, updateParent)
	self.shown = show
	self.toggle:SetText(show and L.HideBags or L.ShowBags)
	self.toggle:SetWidth(self.toggle:GetTextWidth())
	self:Layout()

	if updateParent then
		self:GetParent():Layout()
	end
end

function BagnonBagFrame:Update()
	for _,bag in pairs(self.bags) do
		if bag:GetID() > 0 then
			bag:Update()
		end
	end
end

function BagnonBagFrame:GetToggleWidth()
	return self.toggle:GetTextWidth()
end