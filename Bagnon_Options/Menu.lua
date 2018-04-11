--[[
	Menu.lua
--]]

BagnonMenu = CreateFrame('Frame', 'BagnonRightClickMenu', UIParent)
local L = LibStub('AceLocale-3.0'):GetLocale('Bagnon-Options')

local Menu = BagnonMenu
Menu.extraWidth = 20
Menu.extraHeight = 40
Menu:Hide()

function Menu:Load()
	self.panels = {}

	self:SetBackdrop{
		bgFile = 'Interface\\ChatFrame\\ChatFrameBackground',
		edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
		insets = {left = 11, right = 11, top = 12, bottom = 11},
		tile = true,
		tileSize = 32,
		edgeSize = 32,
	}
	self:SetBackdropColor(0, 0, 0, 0.8)

	self:EnableMouse(true)
	self:SetToplevel(true)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:SetFrameStrata('DIALOG')
	self:SetScript('OnMouseDown', self.StartMoving)
	self:SetScript('OnMouseUp', self.StopMovingOrSizing)

	--title text
	self.text = self:CreateFontString(nil, 'OVERLAY')
	self.text:SetPoint('TOP', 0, -15)
	self.text:SetFontObject('GameFontHighlight')
	self.text:SetText(L.Title)

	--close button
	self.close = CreateFrame('Button', nil, self, 'UIPanelCloseButton')
	self.close:SetPoint('TOPRIGHT', -5, -5)

	self:AddDisplayPanel()
	self:AddEventsPanel()
end

--place the frame at the player's cursor
function Menu:Display(parent)
	local x, y = GetCursorPosition()
	local s = UIParent:GetScale()

	self:Hide()
	self:ClearAllPoints()
	self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x/s - 32, y/s + 80)
	self.parent = parent
	self:ShowPanel(L.Display)
end

--shows a given panel
function Menu:ShowPanel(name)
	for i, panel in pairs(self.panels) do
		if panel.name == name then
			if self.dropdown then
				UIDropDownMenu_SetSelectedValue(self.dropdown, i)
			end
			panel:Show()
			self:SetWidth(max(220, panel.width + self.extraWidth))
			self:SetHeight(max(40, panel.height + self.extraHeight))
		else
			panel:Hide()
		end
	end
	self:Show()
end

function Menu:GetSelectedPanel()
	for i, panel in pairs(self.panels) do
		if panel:IsShown() then
			return i
		end
	end
	return 1
end

function Menu:AddPanel(name)
	local panel = self.Panel:Create(name, self)
	panel.name = name
	table.insert(self.panels, panel)

	if not self.dropdown and #self.panels > 1 then
		self.dropdown = self:CreatePanelSelector()
	end

	return panel
end

do
	local info = {}
	local function AddItem(text, value, func, checked)
		info.text = text
		info.func = func
		info.value = value
		info.checked = checked
		info.arg1 = text
		UIDropDownMenu_AddButton(info)
	end

	local function Dropdown_OnShow(self)
		UIDropDownMenu_SetWidth(110, self)
		UIDropDownMenu_Initialize(self, self.Initialize)
		UIDropDownMenu_SetSelectedValue(self, self:GetParent():GetSelectedPanel())
	end

	function Menu:CreatePanelSelector()
		local f = CreateFrame('Frame', self:GetName() .. 'PanelSelector', self, 'UIDropDownMenuTemplate')
		--getglobal(f:GetName() .. 'Text'):SetJustifyH('LEFT')

		f:SetScript('OnShow', Dropdown_OnShow)

		local function Item_OnClick(name)
			self:ShowPanel(name)
			UIDropDownMenu_SetSelectedValue(f, this.value)
		end

		function f.Initialize()
			local selected = self:GetSelectedPanel()
			for i,panel in ipairs(self.panels) do
				AddItem(panel.name, i, Item_OnClick, i == selected)
			end
		end

		f:SetPoint('TOPLEFT', 0, -36)
		for _,panel in pairs(self.panels) do
			panel:SetPoint('TOPLEFT', 10, -(32 + f:GetHeight() + 6))
		end

		self.extraHeight = (self.extraHeight or 0) + f:GetHeight() + 6

		return f
	end
end

--[[
	Panel Components
--]]

--a panel is a subframe of a menu, basically
local Panel = BagnonUtil:CreateWidgetClass('Frame')
Menu.Panel = Panel

Panel.width = 0
Panel.height = 0

function Panel:Create(name, parent)
	local f = self:New(CreateFrame('Frame', parent:GetName() .. name, parent))
	f.name = name

	if parent.dropdown then
		f:SetPoint('TOPLEFT', 10, -(32 + parent.dropdown:GetHeight() + 4))
	else
		f:SetPoint('TOPLEFT', 10, -32)
	end
	f:SetPoint('BOTTOMRIGHT', -10, 10)
	f:Hide()

	return f
end


--[[ Checkbuttons ]]--

--checkbutton
function Panel:CreateCheckButton(name)
	local button = CreateFrame('CheckButton', self:GetName() .. name, self, 'OptionsCheckButtonTemplate')
	getglobal(button:GetName() .. 'Text'):SetText(name)

	local prev = self.checkbutton
	if prev then
		button:SetPoint('TOP', prev, 'BOTTOM', 0, 2)
	else
		button:SetPoint('TOPLEFT', 0, 2)
	end
	self.height = self.height + 30
	self.checkbutton = button

	return button
end


--[[ Sliders ]]--

--basic slider
do
	local function Slider_OnMouseWheel(self, arg1)
		local step = self:GetValueStep() * arg1
		local value = self:GetValue()
		local minVal, maxVal = self:GetMinMaxValues()

		if step > 0 then
			self:SetValue(min(value+step, maxVal))
		else
			self:SetValue(max(value+step, minVal))
		end
	end

	local function Slider_OnShow(self)
		self.showing = true
		if self.OnShow then
			self:OnShow()
		end
		self.showing = nil
	end

	local function Slider_OnValueChanged(self, value)
		if not self.showing then
			self:UpdateValue(value)
		end

		if self.UpdateText then
			self:UpdateText(value)
		else
			self.valText:SetText(value)
		end
	end

	function Panel:CreateSlider(text, low, high, step, OnShow, UpdateValue, UpdateText)
		local name = self:GetName() .. text

		local slider = CreateFrame('Slider', name, self, 'OptionsSliderTemplate')
		slider:SetMinMaxValues(low, high)
		slider:SetValueStep(step)
		slider:EnableMouseWheel(true)
		slider:SetWidth(slider:GetWidth() + 20)

		getglobal(name .. 'Text'):SetText(text)
		getglobal(name .. 'Low'):SetText('')
		getglobal(name .. 'High'):SetText('')

		local text = slider:CreateFontString(nil, 'BACKGROUND')
		text:SetFontObject('GameFontHighlightSmall')
		text:SetPoint('LEFT', slider, 'RIGHT', 7, 0)
		slider.valText = text

		slider.OnShow = OnShow
		slider.UpdateValue = UpdateValue
		slider.UpdateText = UpdateText

		slider:SetScript('OnShow', Slider_OnShow)
		slider:SetScript('OnValueChanged', Slider_OnValueChanged)
		slider:SetScript('OnMouseWheel', Slider_OnMouseWheel)

		local prev = self.slider
		if prev then
			slider:SetPoint('BOTTOM', prev, 'TOP', 0, 12)
			self.height = self.height + 30
		else
			slider:SetPoint('BOTTOMLEFT', 4, 6)
			self.height = self.height + 36
		end
		self.slider = slider

		return slider
	end
end

--color selector
do
	local ColorSelect = BagnonUtil:CreateWidgetClass('Button')

	function ColorSelect:Create(name, parent, hasOpacity, SaveColor, LoadColor)
		local f = self:New(CreateFrame('Button', parent:GetName() .. name, parent))
		f:SetWidth(24); f:SetHeight(24)
		f:SetNormalTexture('Interface/ChatFrame/ChatFrameColorSwatch')

		f.SaveColor = SaveColor
		f.LoadColor = LoadColor
		f.hasOpacity = hasOpacity

		if hasOpacity then
			f.swatchFunc = function()
				local r, g, b = ColorPickerFrame:GetColorRGB()
				local a = 1 - OpacitySliderFrame:GetValue()
				f:SetColor(r, g, b, a)
			end

			f.opacityFunc = f.swatchFunc

			f.cancelFunc = function()
				f:SetColor(self.r, self.g, self.b, 1 - self.opacity)
			end
		else
			f.swatchFunc = function()
				f:SetColor(ColorPickerFrame:GetColorRGB())
			end
			f.cancelFunc = function()
				f:SetColor(self.r, self.g, self.b)
			end
		end

		local bg = f:CreateTexture(nil, 'BACKGROUND')
		bg:SetWidth(21); bg:SetHeight(21)
		bg:SetTexture(1, 1, 1)
		bg:SetPoint('CENTER')
		self.bg = bg

		local text = f:CreateFontString(nil, 'ARTWORK')
		text:SetFontObject('GameFontNormalSmall')
		text:SetPoint('LEFT', f, 'RIGHT', 2, 0)
		text:SetText(name)
		self.text = text

		f:RegisterForDrag('LeftButton')
		f:SetScript('OnClick', self.OnClick)
		f:SetScript('OnEnter', self.OnEnter)
		f:SetScript('OnLeave', self.OnLeave)
		f:SetScript('OnShow', self.OnShow)

		return f
	end

	function ColorSelect:SetColor(...)
		self:GetNormalTexture():SetVertexColor(...)
		self:SaveColor(...)
	end

	function ColorSelect:OnClick()
		if ColorPickerFrame:IsShown() then
			ColorPickerFrame:Hide()
		else
			self.r, self.g, self.b, self.opacity = self:LoadColor()
			self.opacity = 1 - self.opacity --correction, since the color menu is crazy

			UIDropDownMenuButton_OpenColorPicker(self)
			ColorPickerFrame:SetFrameStrata('TOOLTIP')
			ColorPickerFrame:Raise()
		end
	end

	function ColorSelect:OnShow()
		self:GetNormalTexture():SetVertexColor(self:LoadColor())
	end

	function ColorSelect:OnEnter()
		local color = NORMAL_FONT_COLOR
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	function ColorSelect:OnLeave()
		local color = HIGHLIGHT_FONT_COLOR
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	function Panel:CreateColorSelector(name, ...)
		return ColorSelect:Create(name, self, ...)
	end
end


--[[ Layout Panel ]]--

do
	local function GetRelativeCoords(frame, scale)
		local ratio = frame:GetScale() / scale
		return frame:GetLeft() * ratio, frame:GetTop() * ratio
	end

	function Menu:AddDisplayPanel()
		local layout = self:AddPanel(L.Display)

		local lock = layout:CreateCheckButton(L.Lock)
		lock:SetScript('OnClick', function(b) self.parent:Lock(b:GetChecked())  end)
		lock:SetScript('OnShow', function(b) b:SetChecked(self.parent:IsLocked()) end)

		local rev = layout:CreateCheckButton(L.ReverseSort)
		rev:SetScript('OnClick', function(b)
			self.parent.sets.reverseSort = b:GetChecked() or nil
			self.parent:SortBags()
			self.parent:Layout()
		end)
		rev:SetScript('OnShow', function(b) b:SetChecked(self.parent.sets.reverseSort) end)

		local top = layout:CreateCheckButton(L.Toplevel)
		top:SetScript('OnClick', function(b)
			self.parent.sets.topLevel = b:GetChecked() or nil
			self.parent:SetToplevel(b:GetChecked())
		end)
		top:SetScript('OnShow', function(b) b:SetChecked(self.parent.sets.topLevel) end)
		
		local showBorders = layout:CreateCheckButton(L.ShowBorders)
		showBorders:SetScript('OnShow', function(self) self:SetChecked(BagnonUtil:ShowingBorders()) end)
		showBorders:SetScript('OnClick', function(self) BagnonUtil:SetShowBorders(self:GetChecked()) end)

		--color picker
		local color = layout:CreateColorSelector(L.BackgroundColor, true)
		color.SaveColor = function(c, ...)
			self.parent:SetBackgroundColor(...)
		end
		color.LoadColor = function(c)
			return self.parent:GetBackgroundColor()
		end
		color:SetPoint('TOPLEFT', showBorders, 'BOTTOMLEFT', 4, 0)
		layout.height = layout.height + 30

		--sliders
		local STRATAS = {'LOW', 'MEDIUM', 'HIGH'}
		local strata = layout:CreateSlider(L.FrameLevel, 1, #STRATAS, 1)
		strata.OnShow = function(s)
			for i,v in pairs(STRATAS) do
				if v == self.parent:GetFrameStrata() then
					s:SetValue(i)
				end
			end
		end
		strata.UpdateValue = function(s, value)
			self.parent.sets.strata = STRATAS[value]
			self.parent:SetFrameStrata(STRATAS[value])
		end
		strata.UpdateText = function(s, value)
			s.valText:SetText(STRATAS[value])
		end

		local alpha = layout:CreateSlider(L.Opacity, 0, 100, 1)
		alpha.OnShow = function(s)
			s:SetValue((self.parent.sets.alpha or 1) * 100)
		end
		alpha.UpdateValue = function(s, value)
			self.parent.sets.alpha = value/100
			self.parent:SetAlpha(value/100)
		end

		local scale = layout:CreateSlider(L.Scale, 50, 150, 1)
		scale.OnShow = function(s)
			s:SetValue((self.parent.sets.scale or 1) * 100)
		end
		scale.UpdateValue = function(s, value)
			local f = self.parent
			f.sets.scale = value / 100

			local x, y = GetRelativeCoords(f, value/100)
			f:SetScale(value/100)
			f:ClearAllPoints()
			f:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x, y)
			f:SavePosition()
		end

		local spacing = layout:CreateSlider(L.Spacing, 0, 32, 1)
		spacing.OnShow = function(s)
			s:SetValue(select(2, self.parent:GetLayout()))
		end
		spacing.UpdateValue = function(s, value)
			self.parent:Layout(nil, value)
		end

		local cols = layout:CreateSlider(L.Cols, 4, 40, 1)
		cols.OnShow = function(s)
			s:SetValue(self.parent:GetLayout())
		end
		cols.UpdateValue = function(s, value)
			self.parent:Layout(value)
		end
	end
end


--[[  Display Panel ]]--

do
	local function EventButton_OnShow(self)
		local isBank = self:GetParent():GetParent().parent.isBank
		if isBank then
			self:SetChecked(Bagnon.sets[format('showBankAt%s', self.index)])
		else
			self:SetChecked(Bagnon.sets[format('showBagsAt%s', self.index)])
		end
	end

	local function EventButton_OnClick(self)
		local isBank = self:GetParent():GetParent().parent.isBank
		local valIndex = isBank and format('showBankAt%s', self.index) or format('showBagsAt%s', self.index)
		Bagnon.sets[valIndex] = self:GetChecked() or nil
	end

	local function EventButton_Create(panel, name, index)
		local b = panel:CreateCheckButton(name)
		b:SetScript('OnShow', EventButton_OnShow)
		b:SetScript('OnClick', EventButton_OnClick)
		b.index = index

		return b
	end

	function Menu:AddEventsPanel()
		local panel = self:AddPanel(L.Events)

		local replaceBags = panel:CreateCheckButton(L.ReplaceBags)
		replaceBags:SetScript('OnShow', function(self) self:SetChecked(BagnonUtil:ReplacingBags()) end)
		replaceBags:SetScript('OnClick', function(self) BagnonUtil:SetReplaceBags(self:GetChecked()) end)

		EventButton_Create(panel, L.AtBank, 'Bank')
		EventButton_Create(panel, L.AtVendor, 'Vendor')
		EventButton_Create(panel, L.AtAH, 'AH')
		EventButton_Create(panel, L.AtMail, 'Mail')
		EventButton_Create(panel, L.AtTrade, 'Trade')
		EventButton_Create(panel, L.AtCraft, 'Craft')
	end
end

Menu:Load()