local _, ADDON = ...

local function MixIn(D, T)
	for k,v in pairs(T) do
		if (type(v) == "function") and ((D[k] == nil)) then
			D[k] = v;
		end
	end
end

local mainMenu = CreateFrame('FRAME', 'optionsMenu', UIParent, "BackdropTemplate")
mainMenu.dtbl = {}
mainMenu:Hide()
mainMenu:SetFrameStrata('TOOLTIP')
mainMenu:SetWidth(200)
mainMenu:SetHeight(40)
mainMenu:SetBackdrop(ADDON.BACKDROP2)
mainMenu:SetBackdropBorderColor(0, 0, 0, 1)
mainMenu:SetBackdropColor(75/255, 75/255, 75/255)
mainMenu:SetPoint('TOPLEFT', optionsButton, 'BOTTOMLEFT', 0, -2)

local subMenu = CreateFrame('FRAME', 'aa_dropdown_sub', UIParent, "BackdropTemplate")
subMenu.dtbl = {}
subMenu:Hide()
subMenu:SetFrameStrata('TOOLTIP')
subMenu:SetWidth(150)
subMenu:SetHeight(130)
subMenu:SetBackdrop(ADDON.BACKDROP2)
subMenu:SetBackdropBorderColor(0, 0, 0, 1)
subMenu:SetBackdropColor(75/255, 75/255, 75/255)

local reportMenu = CreateFrame('FRAME', 'aa_reportDropdown', UIParent, "BackdropTemplate")
reportMenu.dtbl = {}
reportMenu:Hide()
reportMenu:SetFrameStrata('TOOLTIP')
reportMenu:SetWidth(200)
reportMenu:SetHeight(20)
reportMenu:SetBackdrop(ADDON.BACKDROP2)
reportMenu:SetBackdropBorderColor(0, 0, 0, 1)
reportMenu:SetBackdropColor(75/255, 75/255, 75/255)
reportMenu:SetPoint('TOPLEFT', reportMenuButton, 'BOTTOMLEFT', 0, -2)

reportMenuButton:SetScript('OnClick', function(self)
	reportMenu:SetShown(not reportMenu:IsShown())
	if not reportMenu:IsShown() then
		reportMenu:Hide()
	end
end)

local reportButton = CreateFrame('BUTTON', 'announceButton', reportMenu, "BackdropTemplate")
reportButton:SetSize(200, 20)
reportButton:SetBackdrop(ADDON.BACKDROP2)
reportButton:SetBackdropBorderColor(0, 0, 0, 0)
reportButton:SetBackdropColor(75/255, 75/255, 75/255)
reportButton:SetNormalFontObject(Lato_Regular_Normal)
reportButton:SetText("Check for Buffs")
reportButton:SetPoint('LEFT')

reportButton:SetScript('OnClick', function()
	ADDON:CheckForBuffs(true)
end)

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
	btn:SetBackdrop(ADDON.BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(Lato_Regular_Normal)
	btn:SetText('channel')
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\baseline-done-small@2x')
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
subMenuGroups:SetBackdrop(ADDON.BACKDROP2)
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
	btn:SetBackdrop(ADDON.BACKDROP2)
	btn:SetBackdropBorderColor(0, 0, 0, 0)
	btn:SetBackdropColor(75/255, 75/255, 75/255)
	btn:SetNormalFontObject(Lato_Regular_Normal)
	btn:SetText('Group ' .. i)
	btn:GetFontString():SetPoint('LEFT', btn, 'LEFT', 5, 0)

	btn.texture = btn:CreateTexture()
	btn.texture:SetSize(14, 14)
	btn.texture:SetPoint('RIGHT', btn, 'RIGHT')
	btn.texture:SetTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\baseline-done-small@2x')
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
	btn:SetBackdrop(ADDON.BACKDROP2)
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
	btn.texture:SetTexture('Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\baseline-done-small@2x')
	
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

MixIn(optionsMenu, DropDownMenuMixin)

optionsButton:SetScript('OnClick', function(self)
	optionsMenu:SetShown(not optionsMenu:IsShown())
	if not optionsMenu:IsShown() then
		aa_dropdown_sub:Hide()
		aa_dropdown_subGroups:Hide()
	end
end)

optionsMenu:SetScript('OnHide', function(self)
	aa_dropdown_sub:Hide()
	aa_dropdown_subGroups:Hide()
end)

ADDON:AddEscHandler(optionsMenu)

AAFrame:SetScript('OnHide', function(self)
	optionsMenu:Hide()
	reportMenu:Hide()
end)