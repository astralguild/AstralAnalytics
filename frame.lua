local ADDON_NAME, ADDON = ...
local a = ADDON.a
local floor, min = math.floor, math.min

-- CONSTANTS
local BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = nil, tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}
local BACKDROP2 = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 1,
insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Local variables
local offset, shownOffset = 0, 0
local sortedTable = {}

local TOTAL_BUFFS = 7 -- Hard coded for now. Will Change later to match the tracked buffs

local BUFF_TEXTURES = {}
BUFF_TEXTURES[1] = 1528795 -- Vantus
BUFF_TEXTURES[2] = 840006 --134425 -- Augment
BUFF_TEXTURES[3] = 133943 -- Food
BUFF_TEXTURES[4] = 236878 -- Flask
BUFF_TEXTURES[5] = 132333 -- Shout
BUFF_TEXTURES[6] = 135932 -- Int
BUFF_TEXTURES[7] = 135987 -- Fort

--[[
BUFF LIST FROM RIGHT TO LEFT
1 VANTUS RUNE
2 AUGMENT RUNE
3 FOOD
4 FLASK
5 SHOUT
6 INTELLECT
7 FORT
]]

local function MixIn(D, T)	
	for k,v in pairs(T) do
		if (type(v) == "function") and ((D[k] == nil)) then
			D[k] = v;
		end
	end
end

local Row = {}
Row.__index = Row

function Row:CreateRow(parent, index)
	if ADDON.row[index] then
		return ADDON.row[index]
	end
	local self = CreateFrame('BUTTON', '%parentButton' .. index, parent)
	self:SetSize(ADDON:Scale(290), ADDON:Scale(16))

	self.background = self:CreateTexture(nil, 'BACKGROUND')
	self.background:SetAllPoints(self)
	self.background:SetTexture([[Interface\AddOns\AstralAnalytics\Media\Texture\Flat.tga]])
	self.background:SetAlpha(.6)
	self.background:Show()

	self.name = self:CreateFontString(nil, 'OVERLAY', 'AstralFontNormal')
	self.name:SetPoint('LEFT', self, 'LEFT', 4, -1)
	self.name:SetTextColor(1, 1, 1)
	self.name:SetText('Test')

	self.buff = {}
	self.buff[1] = CreateFrame('FRAME', nil, self)
	self.buff[1].spellID = 0
	self.buff[1]:SetPoint('RIGHT', self, 'RIGHT', ADDON:Scale(-4), 0)
	self.buff[1]:SetSize(ADDON:Scale(12), ADDON:Scale(12))

	self.buff[1].texture = self.buff[1]:CreateTexture(nil, 'OVERLAY')
	self.buff[1].texture:SetAllPoints(self.buff[1])

	self.buff[1]:EnableMouse(true)
	self.buff[1]:SetScript('OnEnter', function(self)
			if self.unitID == 'header' then return nil end
			AstralToolTip:SetOwner(self, "ANCHOR_CURSOR")
			AstralToolTip:SetBackdrop(BACKDROP2)
			AstralToolTip:SetBackdropColor(0, 0, 0, .8)
			AstralToolTip:SetBackdropBorderColor(0, 0, 0)
			for spellID, index in ADDON:AuraInfo(self:GetParent().unitID, 'spellID') do
				if spellID == self.spellID then
					AstralToolTip:SetUnitBuff(self:GetParent().unitID, index)
					break
				end
			end
			AstralToolTip:Show()
			end)
		self.buff[1]:SetScript('OnLeave', function(self) AstralToolTip:Hide() end)

	self.buff[1]:Show()
	for i = 2, TOTAL_BUFFS do
		self.buff[i] = CreateFrame('FRAME', nil, self)
		self.buff[i].spellID = 0
		self.buff[i]:EnableMouse(true)
		self.buff[i]:SetScript('OnEnter', function(self)
			if self.unitID == 'header' then return nil end
			AstralToolTip:SetOwner(self, "ANCHOR_CURSOR")
			AstralToolTip:SetBackdrop(BACKDROP2)
			AstralToolTip:SetBackdropColor(0, 0, 0, .8)
			AstralToolTip:SetBackdropBorderColor(0, 0, 0)
			for spellID, index in ADDON:AuraInfo(self:GetParent().unitID, 'spellID') do
				if spellID == self.spellID then
					AstralToolTip:SetUnitBuff(self:GetParent().unitID, index)
					break
				end
			end
			AstralToolTip:Show()
			end)
		self.buff[i]:SetScript('OnLeave', function(self) AstralToolTip:Hide() end)
		self.buff[i]:SetPoint('RIGHT', self.buff[i-1], 'LEFT', ADDON:Scale(-4), 0)
		self.buff[i]:SetSize(ADDON:Scale(12), ADDON:Scale(12))

		self.buff[i].texture = self.buff[i]:CreateTexture(nil, 'OVERLAY')
		self.buff[i].texture:SetAllPoints(self.buff[i])

		self.buff[i]:EnableMouse(true)

		self.buff[i]:Show()
	end

	return self
end

function Row:SetUnit(unit)
	if (not unit or type(unit) ~= 'table') and unit ~= 'header' then
		error('Row:SetUnit(unit) table expected, received ' .. type(unit))
	end
	self.unitID = unit.unitID or unit
	self.name:SetText(unit.name)

	if unit == 'header' then
		self.background:SetColorTexture(0, 0, 0, 0)
		for i = 1, #self.buff do
			self.buff[i]:Show()
			self.buff[i].texture:SetTexture(BUFF_TEXTURES[i])
		end
	else
		self.guid = unit and UnitGUID(unit.unitID) or ''
		local r, g, b = GetClassColor(unit.class)
		self.background:SetGradientAlpha("HORIZONTAL",r/1.5,g/1.5,b/1.5,1,r/1.5,g/2,b/1.5,.1)

		for i = 1, TOTAL_BUFFS do
			self.buff[i].texture:SetTexture(BUFF_TEXTURES[i])
			if unit.buff[i] then
				self.buff[i].spellID = unit.buff[i][1]
				self.buff[i].texture:SetTexture(unit.buff[i][2])
				self.buff[i].texture:Show()
			else
				self.buff[i].texture:Hide()
			end
		end

	end
	self:SetShown(true)
end

function Row:ClearUnit()
	self.unitID = ''
	self.guid = ''
	self.name:SetText('')
	self:Hide()
end

function Row:UpdateUnitBuffs(unit)
	if not unit or type(unit) ~= 'table' then
		error('Row:UpdateUnitBuffs(unit) table expacted, received ' .. type(unit))
	end
	for i = 1, TOTAL_BUFFS do
		if unit.buff[i] then
			self.buff[i].texture:SetTexture(unit.buff[i][2])
			self.buff[i].texture:Show()
		else
			self.buff[i].texture:Hide()
		end
	end
end

function Row:ClearAllBuffs()
	for k, v in pairs(self.buffs) do
		v:SetTexture(nil)
		v:Hide()
	end
end

function ADDON:ClearUnitBuffs(guid)
	for _, unit in pairs(self.row) do
		if unit.guid == guid then
			unit:ClearAllBuffs()
		end
		break
	end
end

function ADDON:UpdateFrameRows()
	local numGroup = #self.units

	local indexEnd = min(numGroup, AAFrame.numFramesShown)
	for i = 1, indexEnd do
		self.row[i]:SetUnit(self.units[i])
	end

	for i = indexEnd + 1, #self.row do
		self.row[i]:ClearUnit()
	end
end

function ADDON:UpdateRowsShown(numFrames)
	if numFrames > #self.row then
		for i = 1, numFrames do
			if not self.row[i] then
				self.row[i] = Row:CreateRow(AAFrame, i)
				self.row[i]:SetPoint('TOPLEFT', self.row[i-1], 'BOTTOMLEFT', 0, self:Scale(-3))
				MixIn(self.row[i], Row)
			else
				self.row[i]:Show()
			end
		end
	else
		for i = 1, numFrames do
			self.row[i]:Show()
		end
		for i = numFrames + 1, #self.row do
			self.row[i]:Hide()
		end
	end
end

local AAFrame = CreateFrame('FRAME', 'AAFrame', UIParent, "BackdropTemplate")
AAFrame:SetFrameStrata('DIALOG')
AAFrame:SetSize(330, 440)
AAFrame:SetMinResize(300, 139)
AAFrame:SetPoint('CENTER', UIParent, 'CENTER')
AAFrame:EnableMouse(true)
AAFrame:SetResizable(true)
AAFrame:SetBackdrop(BACKDROP)
AAFrame:SetBackdropColor(0, 0, 0, 1)
AAFrame:SetMovable(true)
AAFrame:RegisterForDrag('LeftButton')
AAFrame:SetClampedToScreen(true)
AAFrame:EnableKeyboard(true)
AAFrame:SetPropagateKeyboardInput(true)
AAFrame:Hide()
AAFrame.elapsed = 0

function AAFrame:AdjustHeight(height)
	self:SetHeight(height)
	AAFrameMenuBar:AdjustHeight(height)
end

local menuBar = CreateFrame('FRAME', '$parentMenuBar', AAFrame)
menuBar.timeSinceUpdate = 0
menuBar:SetWidth(30)
menuBar:SetHeight(440)
menuBar:SetPoint('TOPLEFT', AAFrame, 'TOPLEFT')
menuBar.texture = menuBar:CreateTexture(nil, 'BACKGROUND')
menuBar.texture:SetSize(30, 440)
menuBar.texture:SetPoint('TOPLEFT', menuBar, 'TOPLEFT')
menuBar.texture:SetColorTexture(33/255, 33/255, 33/255, 0.8)

function menuBar:AdjustHeight(height)
	self:SetHeight(height)
	self.texture:SetHeight(height)
end

local AstralToolTip = CreateFrame( "GameTooltip", "AstralToolTip", AAFrame, "GameTooltipTemplate")
AstralToolTip:SetOwner(AAFrame, "ANCHOR_CURSOR")
AstralToolTip:SetBackdrop(BACKDROP)

local corner = CreateFrame('FRAME', '$parentDrag', AAFrame)
corner:SetFrameStrata('DIALOG')
corner:SetFrameLevel(AAFrame:GetFrameLevel() + 10)
corner:SetSize(8, 8)
corner:SetPoint('BOTTOMRIGHT', AAFrame, 'BOTTOMRIGHT', -3, 3)
corner:RegisterForDrag('LeftButton')
corner:EnableMouse(true)
corner:SetMovable(true)
corner:SetClampedToScreen(true)

local cornerTexture = corner:CreateTexture('ARTWORK')
cornerTexture:SetSize(8, 8)
cornerTexture:SetTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\Corner')
cornerTexture:SetPoint('BOTTOMRIGHT', corner, 'BOTTOMRIGHT')

local MIN_RESIZE_TIME = 0.01
local function MenuBarResize_OnUpdate(self, elapsed)
	self.timeSinceUpdate = self.timeSinceUpdate + elapsed
	if self.timeSinceUpdate > MIN_RESIZE_TIME then
		AAFrameMenuBar.texture:SetHeight(self:GetHeight())
		self.timeSinceUpdate = 0
	end
end

AAFrame:SetScript('OnDragStart', function(self)
	self:StartMoving()
	end)

AAFrame:SetScript('OnDragStop', function(self)
	self:StopMovingOrSizing()
	end)

corner:SetScript('OnDragStart', function(self)
	local left, bottom, width, height = self:GetParent():GetRect()
	self:GetParent().left = left
	self:GetParent().bottom = bottom
	self:GetParent().top = (bottom + height)
	self:GetParent():StartSizing()
	AAFrameMenuBar:SetScript('OnUpdate', MenuBarResize_OnUpdate)
end)

AAFrame:SetScript('OnSizeChanged', function(self)
	if not AAFrameDrag:IsDragging() then return end
	local width = ADDON:Scale(self:GetWidth() - 10 - 30) -- 30 is for left menubar
	local height = self:GetHeight() - ADDON:Scale(44)
	self.numFramesShown = min(floor(height/ADDON:Scale(19)), 40)
	AAFrameMenuBar:SetHeight(self:GetHeight())

	if ADDON.row then
		for i = 0, #ADDON.row do
			ADDON.row[i]:SetWidth(width)
		end
		ADDON:UpdateRowsShown(self.numFramesShown)
		ADDON:UpdateFrameRows()
	end
	end)

corner:SetScript('OnDragStop', function(self)
	self:GetParent():StopMovingOrSizing()
	AAFrameMenuBar:StopMovingOrSizing()
	local numFrames = self:GetParent().numFramesShown
	local height = ADDON:Scale(44 + (numFrames * 19))
	self:GetParent():AdjustHeight(height)
	AAFrameMenuBar:SetScript('OnUpdate', nil)
	self:GetParent():ClearAllPoints()
	self:GetParent():SetPoint('TOPLEFT', UIParent, 'TOPLEFT', self:GetParent().left, -ADDON:Scale((UIParent:GetHeight() -(self:GetParent().top))))
	ADDON:UpdateRowsShown(numFrames)
	ADDON:UpdateFrameRows()
end)

a.AddEscHandler(AAFrame)

local AAFrameLogo = AAFrameMenuBar:CreateTexture(nil, 'ARTWORK')
AAFrameLogo:SetSize(20, 20)
AAFrameLogo:SetTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\Asset_54x2')
AAFrameLogo:SetPoint('TOPLEFT', AAFrameMenuBar, 'TOPLEFT', 6, -10)

local AAFrameTitle = AAFrame:CreateFontString('$parentTitle', 'ARTWORK', 'InterUIBlack_Large')
AAFrameTitle:SetPoint('LEFT', AAFrameLogo, 'RIGHT', 12, -1)
AAFrameTitle:SetText('Astral Analytics')

local divider = menuBar:CreateTexture(nil, 'ARTWORK')
divider:SetSize(16, 1)
divider:SetColorTexture(.6, .6, .6, .8)
divider:SetPoint('TOP', AAFrameLogo, 'BOTTOM', 0, -14)

-- Header Buttons
local closeButton = CreateFrame('BUTTON', '$parentCloseButton', AAFrame)
closeButton:SetPoint('TOPRIGHT', AAFrame, 'TOPRIGHT', -5, -5)
closeButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-close-24px@2x')
closeButton:SetSize(10, 10)
closeButton:GetNormalTexture():SetVertexColor(.8, .8, .8, 0.8)
closeButton:SetScript('OnClick', function()
	AAFrame:Hide()
end)
closeButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
end)
closeButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
end)

local reportButton = CreateFrame('BUTTON', nil, AAFrame)
reportButton:SetSize(12, 12)
reportButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-volume_up-24px@2x')
reportButton:SetPoint('TOP', divider, 'BOTTOM', 0, -14)
reportButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
	end)
reportButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	end)
reportButton:SetScript('OnClick', function()
	ADDON:CheckForBuffs(true)
end)

local optionsButton = CreateFrame('BUTTON', nil, AAFrame)
optionsButton:SetSize(14, 14)
optionsButton:SetPoint('TOP', reportButton, 'BOTTOM', 0, -14)
optionsButton:SetNormalTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\menu3')
optionsButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255, 0.8)
	end)
optionsButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(0.8, 0.8, 0.8, 0.8)
	end)

local logo_Astral = CreateFrame('BUTTON', nil, menuBar)
logo_Astral:SetSize(32, 32)
logo_Astral:SetPoint('BOTTOMLEFT', menuBar, 'BOTTOMLEFT', 0, 3)
logo_Astral:SetAlpha(0.8)
logo_Astral:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\Logo@2x')

logo_Astral:SetScript('OnClick', function()
	--astralGuildInfo:SetShown(not astralGuildInfo:IsShown())
	end)

logo_Astral:SetScript('OnEnter', function(self)
	self:SetAlpha(1)
	end)

logo_Astral:SetScript('OnLeave', function(self)
	self:SetAlpha(0.8)
	end)

function ADDON:CreateMainWindow()
	self.row = {}
	-- Create Header row
	self.row[0] = Row:CreateRow(AAFrame, 0)
	self.row[0]:SetPoint('TOPLEFT', AAFrame, 'TOPLEFT', 35, -20)
	MixIn(self.row[0], Row)
	self.row[0]:SetUnit('header')
	-- Create 20 rows by default
	for i = 1, 20 do
		local xOffSet = i == 1 and 30 or 0
		self.row[i] = Row:CreateRow(AAFrame, i)
		self.row[i]:SetPoint('TOPLEFT', self.row[i-1], 'BOTTOMLEFT', 0, self:Scale(-3))
		MixIn(self.row[i], Row)
	end

	local height = AAFrame:GetHeight() - ADDON:Scale(44)
	AAFrame.numFramesShown = min(floor(height/ADDON:Scale(19)), 40)

	self:UpdateRowsShown(AAFrame.numFramesShown)

	local height = ADDON:Scale(44 + (AAFrame.numFramesShown * 19))
	AAFrame:SetHeight(height)
end

--[[
BUFF LIST FROM RIGHT TO LEFT
1 VANTUS RUNE
2 AUGMENT RUNE
3 FOOD
4 FLASK
5 SHOUT
6 INTELLECT
7 FORT
]]

function ADDON:UpdateWindowHeader()
	local numShown = 1
	for i = 1, #self.buffsTracked do
		headerIcons[i].isEnabled = self.buffsTracked[i].isEnabled
		headerIcons[i]:SetTexture(AstralOverseer.buffsWatched[i].texture)
		if numShown == 1 then
			if headerIcons[i]:IsShown() then 
				headerIcons[i]:SetPoint('TOPRIGHT', AAFrameContentHeader, 'TOPRIGHT')
				numShown = numShown + 1
			end
		else
			if headerIcons[i]:IsShown() then 
				headerIcons[i]:SetPoint('TOPRIGHT', AAFrameContentHeader, 'TOPRIGHT')
				numShown = numShown + 1
			end
		end
	end
end

function ADDON:ToggleMainWindow()
	AAFrame:SetShown(not AAFrame:IsShown())
end

local mainMenu = CreateFrame('FRAME', 'aa_dropdown', UIParent, "BackdropTemplate")
mainMenu.dtbl = {}
mainMenu:Hide()
mainMenu:SetFrameStrata('TOOLTIP')
mainMenu:SetWidth(200)
mainMenu:SetHeight(40)
mainMenu:SetBackdrop(BACKDROP2)
mainMenu:SetBackdropBorderColor(0, 0, 0, 1)
mainMenu:SetBackdropColor(75/255, 75/255, 75/255)
mainMenu:SetPoint('TOPLEFT', optionsButton, 'BOTTOMLEFT', 0, -2)

local subMenu = CreateFrame('FRAME', 'aa_dropdown_sub', UIParent, "BackdropTemplate")
subMenu.dtbl = {}
subMenu:Hide()
subMenu:SetFrameStrata('TOOLTIP')
subMenu:SetWidth(150)
subMenu:SetHeight(130)
subMenu:SetBackdrop(BACKDROP2)
subMenu:SetBackdropBorderColor(0, 0, 0, 1)
subMenu:SetBackdropColor(75/255, 75/255, 75/255)

function subMenu:UpdateChannels()
	for i = 1, 6 do
		if self.dtbl[i].channel == AstralAnalytics.options.general.announceChannel then
			self.dtbl[i].texture:Show()
		else
			self.dtbl[i].texture:Hide()
		end
	end
end

for i = 1, 6 do
	local btn = CreateFrame('BUTTON', nil, aa_dropdown_sub, "BackdropTemplate")
	btn.category = 'general'
	btn.option = 'announceChannel'
	btn.channel = ''
	btn:SetSize(140, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(Lato_Regular_Normal)
	btn:SetText('channel')
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-done-small@2x')
	btn.texture:Hide()

	btn:SetScript('OnClick', function(self)
		AstralAnalytics.options[self.category][self.option] = self.channel
		self:GetParent():UpdateChannels()
		end)

	btn:SetPoint('TOPLEFT', aa_dropdown_sub, 'TOPLEFT', 5, -20*(i - 1) - 5)

	table.insert(aa_dropdown_sub.dtbl, btn)
end

local subMenuGroups = CreateFrame('FRAME', 'aa_dropdown_subGroups', UIParent, "BackdropTemplate")
subMenuGroups.dtbl = {}
subMenuGroups:Hide()
subMenuGroups:SetFrameStrata('TOOLTIP')
subMenuGroups:SetWidth(150)
subMenuGroups:SetHeight(170)
subMenuGroups:SetBackdrop(BACKDROP2)
subMenuGroups:SetBackdropBorderColor(0, 0, 0, 1)
subMenuGroups:SetBackdropColor(75/255, 75/255, 75/255)

function subMenuGroups:UpdateGroups()
	for i = 1, 8 do
		if AstralAnalytics.options.group[i].isEnabled then
			self.dtbl[i].texture:Show()
		else
			self.dtbl[i].texture:Hide()
		end
	end
end

for i = 1, 8 do
	local btn = CreateFrame('BUTTON', nil, aa_dropdown_subGroups, "BackdropTemplate")
	btn.category = 'group'
	btn.option = i
	btn.isChecked = false
	btn:SetSize(140, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(Lato_Regular_Normal)
	btn:SetText('Group ' .. i)
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-done-small@2x')
	btn.texture:Hide()

	btn:SetScript('OnClick', function(self)
		AstralAnalytics.options[self.category][self.option].isEnabled = not AstralAnalytics.options[self.category][self.option].isEnabled
		self:GetParent():UpdateGroups()
		ADDON:InitializeTableMembers()
		end)

	btn:SetPoint('TOPLEFT', aa_dropdown_subGroups, 'TOPLEFT', 5, -20*(i - 1) - 5)

	table.insert(aa_dropdown_subGroups.dtbl, btn)
end

local DropDownMenuMixin = {}

local btnWidth = 190
function DropDownMenuMixin:NewObject(entry, category)
	local btn = CreateFrame('BUTTON', nil, self, "BackdropTemplate")
	btn.category = category
	btn.option = entry.option
	btn:SetSize(btnWidth, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(Lato_Regular_Normal)
	btn:SetText(entry.label)
	
	local fontString = btn:GetFontString()
	fontString:SetPoint('LEFT', btn, 'LEFT', 5, 0)
	local textWidth = fontString:GetStringWidth()
	if textWidth > (btnWidth - 24) then -- 10 for padding, 14 for check texture
		btnWidth = textWidth + 24
		btn:GetParent():SetWidth(textWidth + 29)
		btn:SetWidth(btnWidth)
		local btns = btn:GetParent().dtbl
		for i = 1, #btns do
			btns[i]:SetWidth(btnWidth)
		end
	end
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\Texture\\baseline-done-small@2x')
	
	if entry.option ~= 'announceChannel' and entry.option ~= 'group' then
		if entry.value then
			btn.texture:Show()
		else
			btn.texture:Hide()
		end
		btn:SetScript('OnClick', function(self)
			AstralAnalytics.options[self.category][self.option].isEnabled = not AstralAnalytics.options[self.category][self.option].isEnabled
			self.texture:SetShown(AstralAnalytics.options[self.category][self.option].isEnabled)
			end)
	elseif entry.option == 'announceChannel' then
		btn.texture:Hide()
		btn.value = entry.value
		btn:SetScript('OnClick', function(self)
			aa_dropdown_sub:SetPoint('LEFT', self, 'RIGHT', 10, 0)
			aa_dropdown_sub:SetShown(not aa_dropdown_sub:IsShown())
			if aa_dropdown_sub:IsShown() then
				aa_dropdown_subGroups:Hide()
			end

		end)
	elseif entry.option == 'group' then
		btn.texture:Hide()
		btn.value = entry.value
		btn:SetScript('OnClick', function(self)
			aa_dropdown_subGroups:SetPoint('LEFT', self, 'RIGHT', 10, 0)
			aa_dropdown_subGroups:SetShown(not aa_dropdown_subGroups:IsShown())
			if aa_dropdown_subGroups:IsShown() then
				aa_dropdown_sub:Hide()
			end
		end)
	end

	return btn
end

function DropDownMenuMixin:AddEntry(entry, category)
	local dtbl = self.dtbl
	dtbl[#dtbl + 1] = self:NewObject(entry, category)
	self:SetHeight((#dtbl -1) * 20 + 30)

	if onClick then
		dtbl[#dtbl]:HookScript('OnClick', function(self)
				
			self:GetParent():Update()
			abr_dropdownMenu:Hide() end)
	end
	dtbl[#dtbl]:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, -20*(#dtbl - 1) - 5)
end

MixIn(aa_dropdown, DropDownMenuMixin)

optionsButton:SetScript('OnClick', function(self)
	aa_dropdown:SetShown(not aa_dropdown:IsShown())
	if not aa_dropdown:IsShown() then
		aa_dropdown_sub:Hide()
		aa_dropdown_subGroups:Hide()
	end
	end)

aa_dropdown:SetScript('OnHide', function(self)
	aa_dropdown_sub:Hide()
	aa_dropdown_subGroups:Hide()
	end)
a.AddEscHandler(aa_dropdown)

AAFrame:SetScript('OnHide', function(self)
	aa_dropdown:Hide()
end)

local function InitializeWindow()
	ADDON:CreateMainWindow()
	-- Ensure frame is never smaller than min size on load, shit gets wonky sometimes
	local width = ADDON:Scale(math.max(250, AAFrame:GetWidth()))
	local height = ADDON:Scale(math.max(65, AAFrame:GetHeight()))
	AAFrame:SetSize(width, height)
	AAFrameMenuBar:AdjustHeight(height)
	-- Re-use width to set width of rows
	width = width - ADDON:Scale(10)
	for i = 0, #ADDON.row do
		ADDON.row[i]:SetWidth(width - 30) -- 30 is for menubar width
	end
end

AAEvents:Register('PLAYER_LOGIN', InitializeWindow, 'initWindow')