local ADDON_NAME, ADDON = ...
local strformat = string.format

local VARIABLE_STRINGS = {}
VARIABLE_STRINGS['sourceName'] = true
VARIABLE_STRINGS['destName'] = true
VARIABLE_STRINGS['sourceSpell'] = true
VARIABLE_STRINGS['destSpell'] = true
VARIABLE_STRINGS['destIcon'] = true
VARIABLE_STRINGS['sourceIcon'] = true

ADDON.SPELL_CATEGORIES = {}

function ADDON:AddSpellToCategory(spellID, spellCategory)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:AddSpellToCategory(spellID, spellCategory) spellID, string expected got ' .. type(spellID))
	end
	if not spellCategory or type(spellCategory) ~= 'string' then
		error('ADDON:AddSpellToCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
	end
	if not self.SPELL_CATEGORIES[spellCategory] then
		self.SPELL_CATEGORIES[spellCategory] = {}
	end
	table.insert(self.SPELL_CATEGORIES[spellCategory], spellID)
end

function ADDON:RetrieveSpellCategorySpells(spellCategory)
	if not spellCategory or type(spellCategory) ~= 'string' then
		error('ADDON:RetrieveSpellCategorySpells(spellCategory) spellCategory, string expected got ' .. type(spellCategory))
	end
	
	return self.SPELL_CATEGORIES[spellCategory]
end

function ADDON:IsSpellInCategory(spellID, spellCategory)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:IsSpellInCategory(spellID, spellCategory) spellID, string expected got ' .. type(spellID))
	end
	if not spellCategory or type(spellCategory) ~= 'string' then
		error('ADDON:IsSpellInCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
	end

	if self.SPELL_CATEGORIES[spellCategory] then
		for i = 1, #self.SPELL_CATEGORIES[spellCategory] do
			if self.SPELL_CATEGORIES[spellCategory][i] == spellID then
				return true
			end
		end
	end

	return false
end

function ADDON:AddSpellToSubEvent(subEvent, spellID, spellCategory, msgString)
	if not self[subEvent] then
		self[subEvent] = {}
	end

	if self[subEvent][spellID] then
		error('ADDON:AddSpellToSubEvent(subEvent, spellID, spellCategory, msgString) spellID already registered')
	end

	local string = msgString

	local ls = ''
	local commandList = ''
	for command in string:gmatch('<(%w+)>') do
		if command:find('Name') then
			local unitText = command:sub(1, command:find('Name')- 1)
			if unitText == 'dest' then
				commandList = strformat('%s, %s, %sFlags, %sRaidFlags', commandList, command, unitText, unitText)
			else
				commandList = strformat('%s, %s, %sRaidFlags', commandList, command, unitText)
			end
		else
			commandList = strformat('%s, %s', commandList, command)
		end
		ls = strformat('%s, %s', ls, command)
	end
	commandList = commandList:sub(commandList:find(',') + 1)

	local fstring = string:gsub('<(.-)>', '%%s')

	ls = ls:gsub('(%w+)', function(w)
		if w:find('Name') then
			local flagText = w:sub(1, w:find('Name')- 1) .. 'RaidFlags'
			local colourText = w:find('dest') and ADDON.COLOURS.TARGET or 'nil'
			return [[WrapNameInColorAndIcons(]] .. w .. [[, nil, (bit.band(COMBATLOG_OBJECT_AFFILIATION_MASK, destFlags) < 5 and nil or ']] .. colourText .. [['), ]] .. flagText .. [[)]]
		else
			return w
		end

	end)

	local codeString = [[
	if not AstralAnalytics.options.combatEvents[']] .. spellCategory .. [['] then return end
	local sourceName, sourceRaidFlags, spell, destName, destFlags, destRaidFlags = ...
	sourceName = sourceName or 'Unknown'
	destName = destName or 'Unknown'
	AstralSendMessage(string.format(']] .. fstring .. [[' ]] .. ls .. [[), 'console')]]

	local func, cerr = loadstring(codeString)
	if cerr then
		error(cerr)
	end

	self[subEvent][spellID] = {textString = msgString, method = func}
	self:AddSpellToCategory(spellID, spellCategory)
end

function ADDON:IsSpellTracked(subEvent, spellID)
	if not subEvent or type(subEvent) ~= 'string' then
		error('ADDON:IsSpellTracked(subEvent, spellID) subEvent, string expected got ' .. type(subEvent))
	end
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:IsSpellTracked(subEvent, spellID) spellID, number expected got ' .. type(spellID))
	end
	if self[subEvent] and self[subEvent][spellID] then
		return true
	else
		return false
	end
end

function ADDON:GetSubEventMethod(subEvent, spellID)
	if not subEvent or type(subEvent) ~= 'string' then
		error('ADDON:GetSubEventMethod(subEvent, spellID) subEvent, string expected got ' .. type(subEvent))
	end
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:GetSubEventMethod(subEvent, spellID) spellID, string expected got ' .. type(spellID))
	end

	return self[subEvent][spellID].method
end


--[[
SPELLS TO ADD
Pet taunts
dispells  <sourceName> removed <spell> from <destName> with <sourceSpell>  HELPFUL and HARMFUL
spellsteal
]]

-- Heroism
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 32182, 'heroism', '<sourceName> cast <spell>') -- Heroism
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 90355, 'heroism', '<sourceName> cast <spell>') -- Ancient Hysteria
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 160452, 'heroism', '<sourceName> cast <spell>') -- Netherwinds
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 264667, 'heroism', '<sourceName> cast <spell>') -- Primal Rage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 80353, 'heroism', '<sourceName> cast <spell>') -- Timewarp
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 2825, 'heroism', '<sourceName> cast <spell>') -- Bloodlust
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 178207, 'heroism', '<sourceName> cast <spell>') -- Drums of fury
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 230935, 'heroism', '<sourceName> cast <spell>') -- Drums of the Mountain

-- Battle res
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 20484, 'battleRes', '<sourceName> resurrected <destName> with <spell>') -- Rebirth
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 20707, 'battleRes', '<sourceName> resurrected <destName> with <spell>') -- Soulstone
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 61999, 'battleRes', '<sourceName> resurrected <destName> with <spell>') -- Raise Ally

-- Taunts
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 115546, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Provoke, Monk
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 355, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Taunt, Warrior
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 185245, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Torment, Demon Hunter
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 62124, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Hand of Reckoning, Paladin
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 6795, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Growl, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 49576, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Death Grip, Death Knight
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 56222, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Dark Command, Death Knight
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 2649, 'taunt', '<sourceName> taunted <destName> with <spell>') -- Growl, Hunter Pet

-- Crowd Controls
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 6770, 'crowd', '<sourceName> cast <spell> on <destName>') -- Sap, Rogue
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 2094, 'crowd', '<sourceName> cast <spell> on <destName>') -- Blind, Rogue
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 118, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 28272, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 28271, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 61780, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 61305, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 161372, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 61721, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 161354, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 126819, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 277792, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 277787, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 161353, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 161355, 'crowd', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 20066, 'crowd', '<sourceName> cast <spell> on <destName>') -- Repentance, Paladin
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 5782, 'crowd', '<sourceName> cast <spell> on <destName>') -- Fear, Warlock
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 6358, 'crowd', '<sourceName> cast <spell> on <destName>') -- Seduction, Warlock
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 115268, 'crowd', '<sourceName> cast <spell> on <destName>') -- Mesmerize, Warlock
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 710, 'crowd', '<sourceName> cast <spell> on <destName>') -- Banish, Warlock
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 115078, 'crowd', '<sourceName> cast <spell> on <destName>') -- Paralysis, Monk
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 217832, 'crowd', '<sourceName> cast <spell> on <destName>') -- Imprison, Demon Hunter
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 339, 'crowd', '<sourceName> cast <spell> on <destName>') -- Entangling Roots, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 132469, 'crowd', '<sourceName> cast <spell> on <destName>') -- Typhoon, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 9485, 'crowd', '<sourceName> cast <spell> on <destName>') -- Shackle Undead, Priest
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 51514, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 210875, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 211004, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 211010, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 211015, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 269352, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 277778, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 277784, 'crowd', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 3355, 'crowd', '<sourceName> cast <spell> on <destName>') -- Freezing Trap, Hunter

-- Targeted Utility Spells
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 29166, 'utilityT', '<sourceName> cast <spell> on <destName>') -- Innervate, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 34477, 'utilityT', '<sourceName> cast <spell> on <destName>') -- Misdirect, Hunter
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 73325, 'utilityT', '<sourceName> cast <spell> on <destName>') -- Leap of Faith, Priest
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 1022, 'utilityT', '<sourceName> cast <spell> on <destName>') -- Blessing of Protection, Paladin
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 57934, 'utilityT', '<sourceName> cast <spell> on <destName>') -- Tricks of the Trade, Rogue

-- Non-targeted Utility Spells
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 205636, 'utilityNT', '<sourceName> cast <spell>') -- Force of Nature, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 77761, 'utilityNT', '<sourceName> cast <spell>') -- Stampeding Roar, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 77764, 'utilityNT', '<sourceName> cast <spell>') -- Stampeding Roar, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 106898, 'utilityNT', '<sourceName> cast <spell>') -- Stampeding Roar, Druid
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 64901, 'utilityNT', '<sourceName> cast <spell>') -- Symbol of Hope, Priest
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 114018, 'utilityNT', '<sourceName> cast <spell>') -- Shroud of Concealment, Rogue
ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 192077, 'utilityNT', '<sourceName> cast <spell>') -- Wind Rush Totem, Shaman

-- Defensive Dispells
ADDON:AddSpellToCategory(527, 'SPELL_AURA_BROKEN_SPELL') -- Purify, Priest
ADDON:AddSpellToCategory(218164, 'SPELL_AURA_BROKEN_SPELL') -- Detox, Monk
ADDON:AddSpellToCategory(115450, 'SPELL_AURA_BROKEN_SPELL') -- Detox, Monk
ADDON:AddSpellToCategory(2908, 'SPELL_AURA_BROKEN_SPELL') -- Soothe, Druid
ADDON:AddSpellToCategory(88425, 'SPELL_AURA_BROKEN_SPELL') -- Nature's Cure, Druid
ADDON:AddSpellToCategory(213644, 'SPELL_AURA_BROKEN_SPELL') -- Cleanse Toxins, Paladin
ADDON:AddSpellToCategory(4987, 'SPELL_AURA_BROKEN_SPELL') -- Cleanse, Paladin
ADDON:AddSpellToCategory(475, 'SPELL_AURA_BROKEN_SPELL') -- Remove Curse, Mage
ADDON:AddSpellToCategory(77130, 'SPELL_AURA_BROKEN_SPELL') -- Purify Spirit, Shaman
ADDON:AddSpellToCategory(51886, 'SPELL_AURA_BROKEN_SPELL') -- Cleanse Spirit, Shaman


-- Offensive Dispells
ADDON:AddSpellToCategory(528, 'SPELL_AURA_BROKEN_SPELL') -- Dispel Magic, Priest
ADDON:AddSpellToCategory(30449, 'SPELL_AURA_BROKEN_SPELL') -- Spellsteal, Mage
ADDON:AddSpellToCategory(264028, 'SPELL_AURA_BROKEN_SPELL') -- Chi-Ji's Tranquility, Hunter Pet
ADDON:AddSpellToCategory(278326, 'SPELL_AURA_BROKEN_SPELL') -- Consume Magic, Demon Hunter
ADDON:AddSpellToCategory(370, 'SPELL_AURA_BROKEN_SPELL') -- Purge, Shaman


-- Interrupts
ADDON:AddSpellToCategory(1766, 'INTERRUPTS') -- Kick, Rogue
ADDON:AddSpellToCategory(106839, 'INTERRUPTS') -- Skull Bash
ADDON:AddSpellToCategory(78675, 'INTERRUPTS') -- Solar Beam ??? test this shit out
ADDON:AddSpellToCategory(183752, 'INTERRUPTS') -- Consume Magic
ADDON:AddSpellToCategory(147362, 'INTERRUPTS') -- Counter Shot
ADDON:AddSpellToCategory(187707, 'INTERRUPTS') -- Muzzle
ADDON:AddSpellToCategory(2139, 'INTERRUPTS') -- Counter Spell
ADDON:AddSpellToCategory(116705, 'INTERRUPTS') -- Spear Hand Strike
ADDON:AddSpellToCategory(96231, 'INTERRUPTS') -- Rebuke
ADDON:AddSpellToCategory(15487, 'INTERRUPTS') -- Silence
ADDON:AddSpellToCategory(57994, 'INTERRUPTS') -- Windshear
ADDON:AddSpellToCategory(6552, 'INTERRUPTS') -- Pummel
ADDON:AddSpellToCategory(171140, 'INTERRUPTS') -- Shadow Lock
ADDON:AddSpellToCategory(171138, 'INTERRUPTS') -- Shadow Lock
