local ADDON_NAME, ADDON = ...
local a = ADDON.a
local floor, min = math.floor, math.min

-- CONSTANTS
local BACKDROP = {
bgFile = "Interface/Tooltips/UI-Tooltip-Background",
edgeFile = nil, tile = true, tileSize = 16, edgeSize = 0,
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
	self.name:SetPoint('LEFT', self, 'LEFT', 4, 0)
	self.name:SetTextColor(1, 1, 1)
	self.name:SetText('Test')

	self.buff = {}
	self.buff[1] = CreateFrame('FRAME', nil, self)
	self.buff[1]:SetPoint('RIGHT', self, 'RIGHT', ADDON:Scale(-4), 0)
	self.buff[1]:SetSize(ADDON:Scale(12), ADDON:Scale(12))

	self.buff[1].texture = self.buff[1]:CreateTexture(nil, 'OVERLAY')
	self.buff[1].texture:SetAllPoints(self.buff[1])

	self.buff[1]:EnableMouse(true)

	self.buff[1]:Show()
	for i = 2, TOTAL_BUFFS do
		self.buff[i] = CreateFrame('FRAME', nil, self)
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
	self.unitID = unit.unitID
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
			if unit.buff[i] then
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

function pUT()
	print(#ADDON.row)
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

local AAFrame = CreateFrame('FRAME', 'AAFrame', UIParent)
AAFrame:SetFrameStrata('DIALOG')
AAFrame:SetSize(300, 440)
AAFrame:SetMinResize(250, 65)
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
cornerTexture:SetTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\Corner.tga')
cornerTexture:SetPoint('BOTTOMRIGHT', corner, 'BOTTOMRIGHT')

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
end)

AAFrame:SetScript('OnSizeChanged', function(self)
	if not AAFrameDrag:IsDragging() then return end
	local width = ADDON:Scale(self:GetWidth() - 10)
	local height = self:GetHeight() - ADDON:Scale(44)
	self.numFramesShown = min(floor(height/ADDON:Scale(19)), 40)

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
	local numFrames = self:GetParent().numFramesShown
	local height = ADDON:Scale(44 + (numFrames * 19))
	self:GetParent():SetHeight(height)
	self:GetParent():SetPoint('TOPLEFT', UIParent, 'TOPLEFT', self:GetParent().left, -ADDON:Scale((ADDON.screenHeight -(self:GetParent().top))))
	ADDON:UpdateRowsShown(numFrames)
	ADDON:UpdateFrameRows()
end)

a.AddEscHandler(AAFrame)

local AAFrameTitle = AAFrame:CreateFontString('$parentTitle', 'ARTWORK', 'AstralFontHeader')
AAFrameTitle:SetPoint('TOPLEFT', AAFrame, 'TOPLEFT', 8, -8)
AAFrameTitle:SetText('Astral Analytics')


-- Header Buttons
local closeButton = CreateFrame('BUTTON', nil, AAFrame)
closeButton:SetSize(15, 15)
closeButton:SetNormalFontObject(a.FONT.OBJECT.CENTRE)
closeButton:SetHighlightFontObject(a.FONT.OBJECT.HIGHLIGHT)
closeButton:SetText('X')
closeButton:SetScript('OnClick', function()
	AAFrame:Hide()
end)
closeButton:SetPoint('TOPRIGHT', AAFrame, 'TOPRIGHT', -5, -5)

local optionsButton = CreateFrame('BUTTON', nil, AAFrame)
optionsButton:SetSize(14, 14)
optionsButton:SetPoint('RIGHT', closeButton, 'LEFT', -5, 0)
optionsButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\menu3.tga')
optionsButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255)
	end)
optionsButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
	end)

local reportButton = CreateFrame('BUTTON', nil, AAFrame)
reportButton:SetSize(14, 14)
reportButton:SetNormalTexture('Interface\\AddOns\\AstralKeys\\Media\\speaker.tga')
reportButton:SetPoint('RIGHT', optionsButton, 'LEFT', -5, 0)
reportButton:SetScript('OnEnter', function(self)
	self:GetNormalTexture():SetVertexColor(126/255, 126/255, 126/255)
	end)
reportButton:SetScript('OnLeave', function(self)
	self:GetNormalTexture():SetVertexColor(1, 1, 1)
	end)
reportButton:SetScript('OnClick', function()
	ADDON:ReportList('missingFlask', AstralAnalytics.options.general.reportChannel)
	ADDON:ReportList('missingFood', AstralAnalytics.options.general.reportChannel)
	ADDON:ReportList('missingRune', AstralAnalytics.options.general.reportChannel)
	ADDON:ReportList('missingInt', AstralAnalytics.options.general.reportChannel)
	ADDON:ReportList('missingFort', AstralAnalytics.options.general.reportChannel)
	ADDON:ReportList('missingShout', AstralAnalytics.options.general.reportChannel)
	ADDON:ReportList('missingVantus', AstralAnalytics.options.general.reportChannel)
end)

function ADDON:CreateMainWindow()
	self.row = {}
	-- Create Header row
	self.row[0] = Row:CreateRow(AAFrame, 0)
	self.row[0]:SetPoint('TOPLEFT', AAFrame, 'TOPLEFT', 5, -20)
	MixIn(self.row[0], Row)
	self.row[0]:SetUnit('header')
	-- Create 20 rows by default
	for i = 1, 20 do
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

local function OnAddOnLoad(addon)
	if addon == ADDON_NAME then
		ADDON:SetUIScale()

		UnitEvents:Unregister('ADDON_LOADED', 'addon_loaded')
		ADDON:AddOptionCategory('Combat Events')
		ADDON:AddOption('Combat Events', 'Report taunts', 'taunt', AstralAnalytics.options.combatEvents.taunt)
		ADDON:AddOption('Combat Events', 'Report interrupts', 'interrupts', AstralAnalytics.options.combatEvents.interrupts)
		ADDON:AddOption('Combat Events', 'Report own interrupts', 'selfInterrupt', AstralAnalytics.options.combatEvents.selfInterrupt)
		ADDON:AddOption('Combat Events', 'Report combat ressurection', 'battleRes', AstralAnalytics.options.combatEvents.battleRes)
		ADDON:AddOption('Combat Events', 'Report CC casts', 'crowd', AstralAnalytics.options.combatEvents.crowd)
		ADDON:AddOption('Combat Events', 'Report CC breaks', 'cc_removed', AstralAnalytics.options.combatEvents.cc_break)
		ADDON:AddOption('Combat Events', 'Report dispells', 'dispell', AstralAnalytics.options.combatEvents.dispell)
		ADDON:AddOption('Combat Events', 'Report enrage removals', 'removeEnrage', AstralAnalytics.options.combatEvents.removeEnrage)
		ADDON:AddOption('Combat Events', 'Report targeted utility', 'utilityT', AstralAnalytics.options.combatEvents.utilityT)
		ADDON:AddOption('Combat Events', 'Report non-targeted utility', 'utilityNT', AstralAnalytics.options.combatEvents.utilityNT)
		ADDON:AddOption('Combat Events', 'Report Heroism casts', 'heroism', AstralAnalytics.options.combatEvents.heroism)

		ADDON:AddOptionCategory('General')
		ADDON:AddOption('General', 'Enable Raid Icons', 'raidIcons', AstralAnalytics.options.general.raidIcons)
		ADDON:AddOption('General', 'Report to Channel', 'reportChannel', AstralAnalytics.options.general.reportChannel)
		ADDON:AddOption('General', 'Auto report on ready check', 'autoReport', AstralAnalytics.options.general.autoReport)
		ADDON:AddOption('General', 'Sub groups', 'group', AstralAnalytics.options.general.group)

		ADDON:AddOptionCategory('Buffs to report')
		ADDON:AddOption('Buffs to report', 'Well Fed', 'missingFood', AstralAnalytics.options.buffsReported.missingFood)
		ADDON:AddOption('Buffs to report', 'Arcane Intellect', 'missingInt', AstralAnalytics.options.buffsReported.missingInt)
		ADDON:AddOption('Buffs to report', 'Fortitude', 'missingFort', AstralAnalytics.options.buffsReported.missingFort)
		ADDON:AddOption('Buffs to report', 'Battle Shout', 'missingShout', AstralAnalytics.options.buffsReported.missingShout)
		ADDON:AddOption('Buffs to report', 'Flask', 'missingFlask', AstralAnalytics.options.buffsReported.missingFlask)
		ADDON:AddOption('Buffs to report', 'Augment Rune', 'missingRune', AstralAnalytics.options.buffsReported.missingRune)
		ADDON:AddOption('Buffs to report', 'Vantus Rune', 'missingVantus', AstralAnalytics.options.buffsReported.missingVantus)

		for category, entries in pairs(ADDON.OPTIONS) do
			local cat
			if category == 'Combat Events' then
				cat = 'combatEvents'
			elseif category == 'Buffs to report' then
				cat = 'buffsReported'
			elseif category == 'General' then
				cat = 'general'
			end

			for _, entry in pairs(entries) do
				aa_dropdown:AddEntry(entry, cat)
			end
		end

		aa_dropdown_sub.dtbl[1]:SetText('Say')
		aa_dropdown_sub.dtbl[1].channel = 'SAY'
		aa_dropdown_sub.dtbl[2]:SetText('Party')
		aa_dropdown_sub.dtbl[2].channel = 'PARTY'
		aa_dropdown_sub.dtbl[3]:SetText('Raid')
		aa_dropdown_sub.dtbl[3].channel = 'RAID'
		aa_dropdown_sub.dtbl[4]:SetText('Smart')
		aa_dropdown_sub.dtbl[4].channel = 'smart'
		aa_dropdown_sub.dtbl[5]:SetText('Officer')
		aa_dropdown_sub.dtbl[5].channel = 'OFFICER'
		aa_dropdown_sub.dtbl[6]:SetText('Personal')
		aa_dropdown_sub.dtbl[6].channel = 'console'

		aa_dropdown_sub:UpdateChannels()

		for i = 1, 8 do
			aa_dropdown_subGroups.dtbl[i].isChecked = AstralAnalytics.options['group'][i]
		end
		aa_dropdown_subGroups:UpdateGroups()
	end
end

UnitEvents:Register('ADDON_LOADED', OnAddOnLoad, 'addon_loaded')

local mainMenu = CreateFrame('FRAME', 'aa_dropdown', UIParent)
mainMenu.dtbl = {}
mainMenu:Hide()
mainMenu:SetFrameStrata('TOOLTIP')
mainMenu:SetWidth(200)
mainMenu:SetHeight(40)
mainMenu:SetBackdrop(BACKDROP2)
mainMenu:SetBackdropBorderColor(0, 0, 0, 1)
mainMenu:SetBackdropColor(75/255, 75/255, 75/255)
mainMenu:SetPoint('TOPLEFT', optionsButton, 'BOTTOMLEFT', 0, -2)

local subMenu = CreateFrame('FRAME', 'aa_dropdown_sub', UIParent)
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
		if self.dtbl[i].channel == AstralAnalytics.options.general.reportChannel then
			self.dtbl[i].texture:Show()
		else
			self.dtbl[i].texture:Hide()
		end
	end
end

for i = 1, 6 do
	local btn = CreateFrame('BUTTON', nil, aa_dropdown_sub)
	btn.category = 'general'
	btn.option = 'reportChannel'
	btn.channel = ''
	btn:SetSize(140, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(a.FONT.OBJECT.LEFT)
	btn:SetText('channel')
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\check.tga')
	btn.texture:Hide()

	btn:SetScript('OnClick', function(self)
		AstralAnalytics.options[self.category][self.option] = self.channel
		self:GetParent():UpdateChannels()
		end)

	btn:SetPoint('TOPLEFT', aa_dropdown_sub, 'TOPLEFT', 5, -20*(i - 1) - 5)

	table.insert(aa_dropdown_sub.dtbl, btn)
end

local subMenuGroups = CreateFrame('FRAME', 'aa_dropdown_subGroups', UIParent)
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
		if AstralAnalytics.options.group[i] then
			self.dtbl[i].texture:Show()
		else
			self.dtbl[i].texture:Hide()
		end
	end
end

for i = 1, 8 do
	local btn = CreateFrame('BUTTON', nil, aa_dropdown_subGroups)
	btn.category = 'group'
	btn.option = i
	btn.isChecked = false
	btn:SetSize(140, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(a.FONT.OBJECT.LEFT)
	btn:SetText('Group ' .. i)
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\check.tga')
	btn.texture:Hide()

	btn:SetScript('OnClick', function(self)
		AstralAnalytics.options[self.category][self.option] = not AstralAnalytics.options[self.category][self.option]
		self:GetParent():UpdateGroups()
		ADDON:InitializeTableMembers()
		end)

	btn:SetPoint('TOPLEFT', aa_dropdown_subGroups, 'TOPLEFT', 5, -20*(i - 1) - 5)

	table.insert(aa_dropdown_subGroups.dtbl, btn)
end

local DropDownMenuMixin = {}

function DropDownMenuMixin:NewObject(entry, category)
	local btn = CreateFrame('BUTTON', nil, self)
	btn.category = category
	btn.option = entry.option
	btn:SetSize(190, 20)
	btn:SetBackdrop(BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(a.FONT.OBJECT.LEFT)
	btn:SetText(entry.label)
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralKeys\\Media\\check.tga')
	
	if entry.option ~= 'reportChannel' and entry.option ~= 'group' then
		if entry.value then
			btn.texture:Show()
		else
			btn.texture:Hide()
		end
		btn:SetScript('OnClick', function(self)
			AstralAnalytics.options[self.category][self.option] = not AstralAnalytics.options[self.category][self.option]
			self.texture:SetShown(AstralAnalytics.options[self.category][self.option])
			end)
	elseif entry.option == 'reportChannel' then
		btn.texture:Hide()
		btn.value = entry.value
		btn:SetScript('OnClick', function(self)
			aa_dropdown_sub:SetPoint('LEFT', self, 'RIGHT', 10, 0)
			aa_dropdown_sub:SetShown(not aa_dropdown_sub:IsShown())

		end)
	elseif entry.option == 'group' then
		btn.texture:Hide()
		btn.value = entry.value
		btn:SetScript('OnClick', function(self)
			aa_dropdown_subGroups:SetPoint('LEFT', self, 'RIGHT', 10, 0)
			aa_dropdown_subGroups:SetShown(not aa_dropdown_subGroups:IsShown())

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
	dtbl[#dtbl]:SetPoint('TOPLEFT', self, 'TOPLEFT', 5, -20*(#dtbl - 1) - 5)
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

local function InitializeWindow()
	ADDON:CreateMainWindow()
	-- Ensure frame is never smaller than min size on load, shit gets wonky sometimes
	local width = ADDON:Scale(math.max(250, AAFrame:GetWidth()))
	local height = ADDON:Scale(math.max(65, AAFrame:GetHeight()))
	AAFrame:SetSize(width, height)
	-- Re-use width to set width of rows
	width = width - ADDON:Scale(10)
	for i = 0, #ADDON.row do
		ADDON.row[i]:SetWidth(width)
	end
end

UnitEvents:Register('PLAYER_LOGIN', InitializeWindow, 'initWindow')