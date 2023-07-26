local ADDON_NAME, ADDON = ...

local a = LibStub("AceAddon-3.0"):NewAddon(ADDON, ADDON_NAME, "AceConsole-3.0")

local AstralAnalyticsLDB = LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
	type = "data source",
	text = ADDON_NAME,
	icon = "Interface\\AddOns\\AstralAnalytics\\Media\\Texture\\Asset_54x2",
	OnClick = function() ADDON:ToggleMainWindow() end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Astral Analytics")
	end,
})

ADDON.icon = LibStub("LibDBIcon-1.0")

function a:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AstralAnalyticsMinimap", {
		profile = {
			minimap = {
				hide = AstralAnalytics.minimapIcon,
			},
		},
	})
	ADDON.icon:Register(ADDON_NAME, AstralAnalyticsLDB, self.db.profile.minimap)
	a:RegisterChatCommand('astral', AstralAnalyticsHandleChatCommand)
	a:RegisterChatCommand('aa', AstralOpenMainWindow)
	ADDON:LoadBuffs()
	ADDON:LoadSpells()
end

function AstralOpenMainWindow(input)
	ADDON:ToggleMainWindow()
end

function AstralAnalyticsHandleChatCommand(input)
	local args = {strsplit(' ', input)}

	--TODO: less fragile arg handling
	if args[1] == 'addspell' then
		ADDON:Print('adding spell')
		ADDON:AddSpellToCategory(tonumber(args[2]), args[3]);

	elseif args[1] == 'addsubspell' then
		ADDON:AddSpellToSubEvent(tonumber(args[2]), args[3], args[4], args[5])

	elseif args[1] == 'addbuff' then
		ADDON:AddBuffToCategory(tonumber(args[2]), args[3])

	elseif(args[1] == 'addtaunt') then
		ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', tonumber(args[2]), 'Taunt', '<sourceName> taunted <destName> with <spell>')

	elseif(args[1] == 'addheroism') then
		ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', tonumber(args[2]), 'Bloodlust', '<sourceName> cast <spell>')

	elseif(args[1] == 'addtargetedutility') then
		ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', tonumber(args[2]), 'Individual Utility', '<sourceName> cast <spell> on <destName>')

	elseif(args[1] == 'adduntargetedutility') then
		ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', tonumber(args[2]), 'Group Utility', '<sourceName> cast <spell>')

	elseif(args[1] == 'lusted') then
		if ADDON.LastLusted and ADDON.LastLusted.func ~= nil then
			local l = ADDON.LastLusted
			local s, sr, sl, dn, df, drf = l.sourceName, l.sourceRaidFlags, l.spellLink, l.destName, l.destFlags, l.destRaidFlags
			l.func(s, sr, sl, dn, df, drf)
		end

	elseif(args[1] == 'minimap') then
		AstralAnalytics.minimapIcon = not AstralAnalytics.minimapIcon
		if AstralAnalytics.minimapIcon then
			ADDON.icon:Show(ADDON_NAME)
		else
			ADDON.icon:Hide(ADDON_NAME)
		end

	-- TODO add some more print messages for new commands
	else
		ADDON:Print("Example usage:")
		ADDON:Print("/astral addbuff 354393 VANTUS")
		ADDON:Print("/astral addspell 47528 INTERRUPT")
		ADDON:Print("/astral addtaunt 49576")
		ADDON:Print("/astral addheroism 80353")
		ADDON:Print("/astral addres 20707")
		ADDON:Print("/astral addtargetedutility 1022")
		ADDON:Print("/astral adduntargetedutility 77761")
	end
end

function ADDON:AddEscHandler(frame)
	if not frame and type(frame) ~= 'table' then
		error('frame expcted, got '.. type(frame))
	end
	if frame:GetScript('OnKeyDown') then
		frame:HookScript('OnKeyDown', function(self, key)
			if key == 'ESCAPE' then
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			end
		end)
	else
		frame:EnableKeyboard(true)
		frame:SetPropagateKeyboardInput(true)
		frame:SetScript('OnKeyDown', function(self, key)
			if key == 'ESCAPE' then
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			end
		end)
	end
	if frame:GetScript('OnShow') then
		frame:HookScript('OnShow', function(self)
			self:SetPropagateKeyboardInput(true)
		end)
	else
		frame:SetScript('OnShow', function(self)
			self:SetPropagateKeyboardInput(true)
		end)
	end
end