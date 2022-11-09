local _, ADDON = ...

ADDON.BUFFS = {}

local CONSOLE_REMOVED_TEXT = 'Removed %s from being tracked.'

function ADDON:LoadBuffs()
	if(AstralAnalytics.buffIds == nil) then
		AstralAnalytics.buffIds = {}
	end
	for key, value in pairs(AstralAnalytics.buffIds) do
		ADDON.BUFFS[value][key] = true
	end
end

function ADDON:AddBuffCategory(category)
	if not category or type(category) ~= 'string' then
		error('ADDON:AddBuffCategory(category) string expected, recieved ' .. type(category))
	end
	if ADDON.BUFFS[category] then
		error('ADDON:AddBuffCategory(category) category already registered')
	end
	ADDON.BUFFS[category] = {}
end

function ADDON:AddBuffToCategory(spellID, category)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:AddBuffToCategory(spellID, category) spellID, number expected, recieved ' .. type(spellID))
	end
	if not category or type(category) ~= 'string' then
		error('ADDON:AddBuffToCategory(category, category) category, string expected, recieved ' .. type(category))
	end

	ADDON.BUFFS[category][spellID] = true
	AstralAnalytics.buffIds[spellID] = category
end

function ADDON:RemoveBuffFromCategory(spellID, category)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:RemoveBuffFromCategory(spellID, category) spellID, number expected, recieved ' .. type(spellID))
	end
	if not category or type(category) ~= 'string' then
		error('ADDON:RemoveBuffFromCategory(category, category) category, string expected, recieved ' .. type(category))
	end
	ADDON.BUFFS[category][spellID] = nil
	local spellName = GetSpellInfo(spellID)
	AstralSendMessage(string.format(CONSOLE_REMOVED_TEXT, spellName), 'console')
end

-- Class Buffs
ADDON.BUFFS.CLASS_BUFFS = {}
ADDON.BUFFS.CLASS_BUFFS[1459] = 'missingInt' -- Arcane Intellect
ADDON.BUFFS.CLASS_BUFFS[21562] = 'missingFort' -- Power Word: Fortitude
ADDON.BUFFS.CLASS_BUFFS[6673] = 'missingShout' -- Battle Shout
ADDON.BUFFS.CLASS_BUFFS[1126] = 'missingMark'

-- Food Buffs
ADDON.BUFFS.FOOD = {}
ADDON.BUFFS.FOOD[257428] = true -- Tier 2 Food Eat & Drink Buff
ADDON.BUFFS.FOOD[257427] = true -- Tier 1 Food Eat & Drink Buff

-- Flasks
ADDON.BUFFS.FLASKS = {}
ADDON:AddBuffToCategory(307185, 'FLASKS') --Spectral Flask of Power
ADDON:AddBuffToCategory(307166, 'FLASKS') --Cauldron version of SFoP

-- Augment Runes
ADDON.BUFFS.RUNES = {}
ADDON:AddBuffToCategory(347901, 'RUNES') --Veiled Augment Rune
ADDON:AddBuffToCategory(367405, 'RUNES') --Eternal Augment Rune

-- Vantus Runes
ADDON.BUFFS.VANTUS = {}
-- SoD
ADDON:AddBuffToCategory(354384, 'VANTUS')
ADDON:AddBuffToCategory(354385, 'VANTUS')
ADDON:AddBuffToCategory(354386, 'VANTUS')
ADDON:AddBuffToCategory(354387, 'VANTUS')
ADDON:AddBuffToCategory(354388, 'VANTUS')
ADDON:AddBuffToCategory(354389, 'VANTUS')
ADDON:AddBuffToCategory(354390, 'VANTUS')
ADDON:AddBuffToCategory(354391, 'VANTUS')
ADDON:AddBuffToCategory(354392, 'VANTUS')
ADDON:AddBuffToCategory(354393, 'VANTUS')

--SotFO
ADDON:AddBuffToCategory(367126, 'VANTUS')
ADDON:AddBuffToCategory(367132, 'VANTUS')
ADDON:AddBuffToCategory(367124, 'VANTUS')
ADDON:AddBuffToCategory(367143, 'VANTUS')
ADDON:AddBuffToCategory(367134, 'VANTUS')
ADDON:AddBuffToCategory(367140, 'VANTUS')
ADDON:AddBuffToCategory(367130, 'VANTUS')
ADDON:AddBuffToCategory(367121, 'VANTUS')
ADDON:AddBuffToCategory(367128, 'VANTUS')
ADDON:AddBuffToCategory(367136, 'VANTUS')
ADDON:AddBuffToCategory(359893, 'VANTUS') -- vigilant guardian???  Verify later