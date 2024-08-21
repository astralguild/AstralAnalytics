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
	local spellName = C_Spell.GetSpellInfo(spellID).name
	AstralSendMessage(string.format(CONSOLE_REMOVED_TEXT, spellName), 'console')
end

-- Class Buffs
ADDON.BUFFS.CLASS_BUFFS = {}
ADDON.BUFFS.CLASS_BUFFS[1459] = 'missingInt' -- Arcane Intellect
ADDON.BUFFS.CLASS_BUFFS[21562] = 'missingFort' -- Power Word: Fortitude
ADDON.BUFFS.CLASS_BUFFS[6673] = 'missingShout' -- Battle Shout
ADDON.BUFFS.CLASS_BUFFS[1126] = 'missingMark' -- Mark of the Wild

ADDON.BUFFS.CLASS_BUFFS[381732] = 'missingBronze' -- Blessing of the Bronze (Death's Advance)
ADDON.BUFFS.CLASS_BUFFS[381741] = 'missingBronze' -- Blessing of the Bronze (Fel Rush / Infernal Strike)
ADDON.BUFFS.CLASS_BUFFS[381746] = 'missingBronze' -- Blessing of the Bronze (Tiger Dash / Dash)
ADDON.BUFFS.CLASS_BUFFS[381748] = 'missingBronze' -- Blessing of the Bronze (Hover)
ADDON.BUFFS.CLASS_BUFFS[381749] = 'missingBronze' -- Blessing of the Bronze (Aspect of the Cheetah)
ADDON.BUFFS.CLASS_BUFFS[381750] = 'missingBronze' -- Blessing of the Bronze (Shimmer / Blink)
ADDON.BUFFS.CLASS_BUFFS[381751] = 'missingBronze' -- Blessing of the Bronze (Chi Torpedo / Roll)
ADDON.BUFFS.CLASS_BUFFS[381752] = 'missingBronze' -- Blessing of the Bronze (Divine Steed)
ADDON.BUFFS.CLASS_BUFFS[381753] = 'missingBronze' -- Blessing of the Bronze (Leap of Faith)
ADDON.BUFFS.CLASS_BUFFS[381754] = 'missingBronze' -- Blessing of the Bronze (Sprint)
ADDON.BUFFS.CLASS_BUFFS[381756] = 'missingBronze' -- Blessing of the Bronze (Spiritwalker's Grace / Spirit Walk / Gust of Wind)
ADDON.BUFFS.CLASS_BUFFS[381757] = 'missingBronze' -- Blessing of the Bronze (Demonic Circle: Teleport)
ADDON.BUFFS.CLASS_BUFFS[381758] = 'missingBronze' -- Blessing of the Bronze (Heroic Leap)

-- Food Buffs
ADDON.BUFFS.FOOD = {}
ADDON.BUFFS.FOOD[257428] = true -- Tier 2 Food Eat & Drink Buff
ADDON.BUFFS.FOOD[257427] = true -- Tier 1 Food Eat & Drink Buff

-- Flasks
ADDON.BUFFS.FLASKS = {}

ADDON:AddBuffToCategory(374000, 'FLASKS') -- Iced Phial of Corrupting Rage
ADDON:AddBuffToCategory(371339, 'FLASKS') -- Phial of Elemental Chaos
ADDON:AddBuffToCategory(371172, 'FLASKS') -- Phial of Tepid Versatility
ADDON:AddBuffToCategory(373257, 'FLASKS') -- Phial of Glacial Fury
ADDON:AddBuffToCategory(371386, 'FLASKS') -- Phial of Charged Isolation
ADDON:AddBuffToCategory(371354, 'FLASKS') -- Phial of the Eye in the Storm
ADDON:AddBuffToCategory(370652, 'FLASKS') -- Phial of Static Empowerment
ADDON:AddBuffToCategory(371204, 'FLASKS') -- Phial of Still Air

-- Augment Runes
ADDON.BUFFS.RUNES = {}
ADDON:AddBuffToCategory(393438, 'RUNES') -- Draconic Augment Rune

-- Vantus Runes
ADDON.BUFFS.VANTUS = {}

-- Amirdrassil - Tier 3 Runes
ADDON:AddBuffToCategory(425943, 'VANTUS') -- Gnarlroot
ADDON:AddBuffToCategory(425944, 'VANTUS') -- Igira
ADDON:AddBuffToCategory(425945, 'VANTUS') -- Volcoross
ADDON:AddBuffToCategory(425946, 'VANTUS') -- Council
ADDON:AddBuffToCategory(425947, 'VANTUS') -- Larodar
ADDON:AddBuffToCategory(425951, 'VANTUS') -- Smolderon
ADDON:AddBuffToCategory(425948, 'VANTUS') -- Tindral
ADDON:AddBuffToCategory(425949, 'VANTUS') -- Fyrakk

-- Amirdrassil - Tier 2 Runes
ADDON:AddBuffToCategory(425934, 'VANTUS') -- Gnarlroot
ADDON:AddBuffToCategory(425935, 'VANTUS') -- Igira
ADDON:AddBuffToCategory(425936, 'VANTUS') -- Volcoross
ADDON:AddBuffToCategory(425937, 'VANTUS') -- Council
ADDON:AddBuffToCategory(425938, 'VANTUS') -- Larodar
ADDON:AddBuffToCategory(425940, 'VANTUS') -- Smolderon
ADDON:AddBuffToCategory(425941, 'VANTUS') -- Tindral
ADDON:AddBuffToCategory(425942, 'VANTUS') -- Fyrakk

-- Amirdrassil - Tier 1 Runes
ADDON:AddBuffToCategory(425905, 'VANTUS') -- Gnarlroot
ADDON:AddBuffToCategory(425906, 'VANTUS') -- Igira
ADDON:AddBuffToCategory(425907, 'VANTUS') -- Volcoross
ADDON:AddBuffToCategory(425908, 'VANTUS') -- Council
ADDON:AddBuffToCategory(425909, 'VANTUS') -- Larodar
ADDON:AddBuffToCategory(425911, 'VANTUS') -- Smolderon
ADDON:AddBuffToCategory(425912, 'VANTUS') -- Tindral
ADDON:AddBuffToCategory(425913, 'VANTUS') -- Fyrakk