local ADDON_NAME, ADDON = ...

local ADDON = LibStub("AceAddon-3.0"):NewAddon(ADDON, "AstralAnalytics", "AceConsole-3.0")

function ADDON:OnInitialize()
	ADDON:RegisterChatCommand('astral', HandleChatCommand)
	ADDON:RegisterChatCommand('aa', OpenMainWindow)
	ADDON:LoadBuffs()
	ADDON:LoadSpells()
end

function OpenMainWindow(input)
	ADDON:ToggleMainWindow()
end

function HandleChatCommand(input)
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