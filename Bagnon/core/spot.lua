--[[
	spot.lua
		Searching functionality for Bagnon
--]]

BagnonSpot = {}

local function SearchBox_Create()
	local f = CreateFrame("EditBox", nil, UIParent)
	f:SetBackdrop{
		edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
		bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
		insets = {left = 2, right = 2, top = 2, bottom = 2},
		tile = true,
		tileSize = 16,
		edgeSize = 16,
	}
	f:SetBackdropColor(0, 0, 0, 0.8)
	f:SetBackdropBorderColor(1, 1, 1, 0.8)
	
	f:SetToplevel(true)
	f:SetFrameStrata('DIALOG')
	f:SetTextInsets(8, 8, 0, 0)
	f:SetFontObject("ChatFontNormal")

	f:SetScript("OnShow", function(self) self:SetFocus(); self:HighlightText() end)
	f:SetScript("OnTextChanged", function(self) BagnonSpot:SetTextSearch(self:GetText()) end)
	f:SetScript("OnEscapePressed", function(self) BagnonSpot:Hide() end)

	return f
end

--shows the search box
function BagnonSpot:Show(anchor)
	if self:GetAnchor() == anchor then
		self:Hide()
	else
		if not self.frame then
			self.frame = SearchBox_Create()
		end

		self.frame.anchor = anchor
		self.frame:Show()
		self.frame:SetPoint("TOPLEFT", anchor.title, "TOPLEFT", -8, 6)
		self.frame:SetPoint("BOTTOMRIGHT", anchor.title, "BOTTOMRIGHT", -4, -6)
		self:SetTextSearch(self.frame:GetText())
	end
end

--hides the search box
function BagnonSpot:Hide()
	if self.frame and self.frame:IsShown() then
		self.frame.anchor = nil
		self.frame:Hide()
		self:ClearTextSearch()
	end
end

--sets the text search to the given text
function BagnonSpot:SetTextSearch(text)
	if text and text ~= "" then
		self.textSearch = text:lower()
	else
		self.textSearch = nil
	end
	self:UpdateFrames()
end

function BagnonSpot:SetBagSearch(bag)
	self.bagSearch = bag
	self:UpdateFrames()
end

--clears all searches
function BagnonSpot:ClearTextSearch()
	self.textSearch = nil
	self:UpdateFrames()
end

function BagnonSpot:ClearAllSearches()
	self.textSearch = nil
	self.bagSearch = nil
	self:UpdateFrames()
end

--updates all highlighting for frames
function BagnonSpot:UpdateFrames()
	local bags = Bagnon:GetInventory()
	if bags and bags:IsShown() then
		bags:UpdateSearch()
	end

	local bank = Bagnon:GetBank()
	if bank and bank:IsShown() then
		bank:UpdateSearch()
	end
end


--[[ Access ]]--

function BagnonSpot:Searching()
	return (self.textSearch or self.bagSearch)
end

--returns the text of what we"re searching for
function BagnonSpot:GetSearch()
	return self.textSearch, self.bagSearch
end

--returns what frame the edit box is anchored to, if any
function BagnonSpot:GetAnchor()
	if self.frame then
		return self.frame.anchor
	end
end