local addonName, ADDON = ...

ADDON.AAOptionsFrame = CreateFrame('FRAME', 'AAOptionsFrame', UIParent)
	ADDON.AAOptionsFrame:SetFrameStrata('DIALOG')
	ADDON.AAOptionsFrame:SetFrameLevel(5)
	ADDON.AAOptionsFrame:SetHeight(380)
	ADDON.AAOptionsFrame:SetWidth(620)
	ADDON.AAOptionsFrame:SetPoint('CENTER', UIParent, 'CENTER')
	ADDON.AAOptionsFrame:SetMovable(true)
	ADDON.AAOptionsFrame:EnableMouse(true)
	ADDON.AAOptionsFrame:RegisterForDrag('LeftButton')
	ADDON.AAOptionsFrame:EnableKeyboard(true)
	ADDON.AAOptionsFrame:SetPropagateKeyboardInput(true)
	ADDON.AAOptionsFrame:SetClampedToScreen(true)
	ADDON.AAOptionsFrame.background =  ADDON.AAOptionsFrame:CreateTexture(nil, 'BACKGROUND')
	ADDON.AAOptionsFrame.background:SetAllPoints( ADDON.AAOptionsFrame)
	ADDON.AAOptionsFrame.background:SetColorTexture(0, 0, 0, 1)
	ADDON.AAOptionsFrame:Hide()

	ADDON.AAOptionsFrame:SetScript('OnKeyDown', function(self, key)
	if key == 'ESCAPE' then
		self:SetPropagateKeyboardInput(false)
			ADDON.AAOptionsFrame:Hide()
	end
end)

ADDON.SpellRow = {}
ADDON.SpellRow.__index = ADDON.SpellRow

function ADDON.SpellRow:CreateRow(parent, index, spell)
	local frame = CreateFrame('BUTTON', 'spellIdRow' .. index, parent)
	frame:SetSize(ADDON:Scale(290), ADDON:Scale(20))

	frame.background = frame:CreateTexture(nil, 'BACKGROUND')
	frame.background:SetAllPoints(frame)
	frame.background:SetTexture([[Interface\AddOns\AstralAnalytics\Media\Texture\Flat.tga]])
	frame.background:SetAlpha(.6)
	frame.background:Show()

	frame.name = frame:CreateFontString(nil, 'OVERLAY', 'AstralFontBigger')
	frame.name:SetPoint('LEFT', frame, 'LEFT', 4, -1)
	frame.name:SetTextColor(1, 1, 1)

	return frame
end

function ADDON.SpellRow:SetSpell(self, spell)
	local name, rank, icon = GetSpellInfo(spell)
	self.name:SetText("|T"..icon..":20|t" .. name .. " (" .. spell .. ")")
	self:Show()
end

function ADDON.SpellRow:ClearSpell(self)
	self.name:SetText('')
	self:Hide()
end