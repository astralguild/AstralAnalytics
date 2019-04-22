local _, ADDON = ...

ADDON.BUFFS = {}

local CONSOLE_REMOVED_TEXT = 'Removed %s from being tracked.'

function ADDON:AddBuffCategory(category)
	if not category or type(category) ~= 'string' then
		error('ADDON:AddBuffCategory(category) string expected, recieved ' .. type(category))
	end
	if ADDON.BUFFS[category] then
		error('ADDON:AddBuffCategory(category) category already registered')
	end
	ADDON.BUFFS[category] = {}
end

function ADDON:AddBuffToCategory(spellID, category, raidList, buffName)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:AddBuffToCategory(spellID, category) spellID, number expected, recieved ' .. type(spellID))
	end
	if not category or type(category) ~= 'string' then
		error('ADDON:AddBuffToCategory(category, category) category, string expected, recieved ' .. type(category))
	end

	ADDON.BUFFS[category][spellID] = true and raidList or true
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
ADDON.BUFFS.CLASS_BUFFS[264760] = 'missingInt' -- War-Scroll of Intellect
ADDON.BUFFS.CLASS_BUFFS[21562] = 'missingFort' -- Power Word: Fortitude
ADDON.BUFFS.CLASS_BUFFS[264764] = 'missingFort' -- War-Scroll of Fortitude
ADDON.BUFFS.CLASS_BUFFS[6673] = 'missingShout' -- Battle Shout
ADDON.BUFFS.CLASS_BUFFS[264761] = 'missingShout' -- War-Scroll of Battle Shout

-- Food Buffs
ADDON.BUFFS.FOOD = {}
ADDON.BUFFS.FOOD[257428] = true -- Tier 2 Food Eat & Drink Buff
ADDON.BUFFS.FOOD[257427] = true -- Tier 1 Food Eat & Drink Buff

-- Flasks
ADDON.BUFFS.FLASKS = {}
ADDON.BUFFS.FLASKS[251837] = true -- Flask of Endless Fathoms
ADDON.BUFFS.FLASKS[251836] = true -- Flask of the Currents
ADDON.BUFFS.FLASKS[251839] = true -- Flask of the Undertow
ADDON.BUFFS.FLASKS[251838] = true -- Flask of the Vast Horizon
ADDON.BUFFS.FLASKS[276970] = true -- Mystical Flask/Cauldron -- NEEDS CHECKING

-- Augment Runes
ADDON.BUFFS.RUNES = {}
ADDON.BUFFS.RUNES[270058] = true -- Battle-Scarred Augment Rune

-- Vantus Runes
ADDON.BUFFS.VANTUS = {}
-- Uldir
ADDON.BUFFS.VANTUS[269407] = true -- Uldir, Zekvoz
ADDON.BUFFS.VANTUS[269276] = true -- Uldir, Taloc
ADDON.BUFFS.VANTUS[269405] = true -- Uldir, MOTHER
ADDON.BUFFS.VANTUS[269408] = true -- Uldir, Fetid
ADDON.BUFFS.VANTUS[269409] = true -- Uldir, Vectis
ADDON.BUFFS.VANTUS[269411] = true -- Uldir, Zul
ADDON.BUFFS.VANTUS[269412] = true -- Uldir, Mythrax
ADDON.BUFFS.VANTUS[269413] = true -- Uldir, G'huun
-- 
ADDON:AddBuffToCategory(285535, 'VANTUS', nil, 'Champion of the Light')
ADDON:AddBuffToCategory(285539, 'VANTUS', nil, 'Conclave of the Chosen')
ADDON:AddBuffToCategory(285536, 'VANTUS', nil, 'King Grong')
ADDON:AddBuffToCategory(289194, 'VANTUS', nil, 'Grong the Revenant')
ADDON:AddBuffToCategory(285541, 'VANTUS', nil, 'High Tinker Mekkatorque')
ADDON:AddBuffToCategory(285537, 'VANTUS', nil, 'Jadefire Masters')
ADDON:AddBuffToCategory(289196, 'VANTUS', nil, 'Jadefire Masters')
ADDON:AddBuffToCategory(285540, 'VANTUS', nil, 'King Rastakhan')
ADDON:AddBuffToCategory(285543, 'VANTUS', nil, 'Lady Jaina Proudmore')
ADDON:AddBuffToCategory(285538, 'VANTUS', nil, 'Opulence')
ADDON:AddBuffToCategory(285542, 'VANTUS', nil, 'Stormwall Blockade')