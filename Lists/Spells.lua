local ADDON_NAME, ADDON = ...
local strformat = string.format

ADDON.SPELL_CATEGORIES = {}

function ADDON:LoadSpells()
	if (AstralAnalytics.spellIds == nil) then
		AstralAnalytics.spellIds = {}
	end
	LoadPresets()
	for key, value in pairs(AstralAnalytics.spellIds) do
		if key ~= nil then
			if key == 'Taunt' then
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Taunt', '<sourceName> taunted <destName> with <spell>')
				end
			elseif key == 'Bloodlust' then
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Bloodlust', '<sourceName> cast <spell>')
				end
			elseif key == 'Targeted Utility' then
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Targeted Utility', '<sourceName> cast <spell> on <destName>')
				end
			elseif key == 'Misdirects' then
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Misdirects', '<sourceName> cast <spell> on <destName>')
				end
			elseif key == 'Group Utility' then
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', spellId, 'Group Utility', '<sourceName> cast <spell>')
				end
			elseif key == 'crowd' then
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToCategory(spellId, 'Crowd Control')
				end
			else
				for spellId, _ in pairs(value) do
					ADDON:AddSpellToCategory(spellId, key)
				end
			end
		end
	end
end

function ADDON:AddSpellToCategory(spellID, spellCategory)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:AddSpellToCategory(spellID, spellCategory) spellID, number expected got ' .. type(spellID))
	end
	if not spellCategory or type(spellCategory) ~= 'string' then
		error('ADDON:AddSpellToCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
	end
	if not self.SPELL_CATEGORIES[spellCategory] then
		self.SPELL_CATEGORIES[spellCategory] = {}
	end
	if self.SPELL_CATEGORIES[spellCategory][spellID] ~= nil then
		ADDON:Print('AstralAnalytics:AddSpellToCategory(spellID, spellCategory) spellId already exists ' .. type(spellID))
	end
	table.insert(self.SPELL_CATEGORIES[spellCategory], spellID)
	if (AstralAnalytics.spellIds[spellCategory] == nil) then
		AstralAnalytics.spellIds[spellCategory] = {}
	end
	AstralAnalytics.spellIds[spellCategory][spellID] = true
end

function ADDON:RemoveSpellFromCategory(spellID, spellCategory)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:AddSpellToCategory(spellID, spellCategory) spellID, number expected got ' .. type(spellID))
	end
	if not spellCategory or type(spellCategory) ~= 'string' then
		error('ADDON:AddSpellToCategory(spellID, spellCategory) spellCategory, string expected got ' .. type(spellCategory))
	end
	if self.SPELL_CATEGORIES[spellCategory][spellID] ~= nil then
		ADDON:Print('AstralAnalytics:AddSpellToCategory(spellID, spellCategory) spellId already does not exist ' .. type(spellID))
	end
	AstralAnalytics.spellIds[spellCategory][spellID] = nil
end

function ADDON:RetrieveSpellCategorySpells(spellCategory)
	if not spellCategory or type(spellCategory) ~= 'string' then
		error('ADDON:RetrieveSpellCategorySpells(spellCategory) spellCategory, string expected got ' .. type(spellCategory))
	end
	
	return self.SPELL_CATEGORIES[spellCategory]
end

function ADDON:IsSpellInCategory(spellID, spellCategory)
	if not spellID or type(spellID) ~= 'number' then
		error('ADDON:IsSpellInCategory(spellID, spellCategory) spellID, number expected got ' .. type(spellID))
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
		ADDON:Print('AstralAnalytics:AddSpellToSubEvent(subEvent, spellID, spellCategory, msgString) spellID already registered')
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
			if w:find('dest') then
				return [[WrapNameInColorAndIcons(]] .. w .. [[, destFlags, ]] .. flagText .. [[)]]
			else
				return [[WrapNameInColorAndIcons(]] .. w .. [[, nil, ]] .. flagText .. [[)]]
			end
			--local colourText = w:find('dest') and ADDON.COLOURS.TARGET or 'nil'
			--return [[WrapNameInColorAndIcons(]] .. w .. [[, destFlags, ]] .. flagText .. [[)]]
		else
			return w
		end

	end)

	local codeString = [[
	if not AstralAnalytics.options.combatEvents[']] .. spellCategory .. [['] then return end
	local sourceName, sourceRaidFlags, spell, destName, destFlags, destRaidFlags = ...
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

function LoadPresets()
	-- Heroism
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 32182, 'Bloodlust', '<sourceName> cast <spell>') -- Heroism
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 90355, 'Bloodlust', '<sourceName> cast <spell>') -- Ancient Hysteria
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 160452, 'Bloodlust', '<sourceName> cast <spell>') -- Netherwinds
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 264667, 'Bloodlust', '<sourceName> cast <spell>') -- Primal Rage
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 80353, 'Bloodlust', '<sourceName> cast <spell>') -- Timewarp
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 2825, 'Bloodlust', '<sourceName> cast <spell>') -- Bloodlust
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 178207, 'Bloodlust', '<sourceName> cast <spell>') -- Drums of fury
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 230935, 'Bloodlust', '<sourceName> cast <spell>') -- Drums of the Mountain

	-- Battle res
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 20484, 'battleRes', '<sourceName> resurrected <destName> with <spell>') -- Rebirth
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 20707, 'battleRes', '<sourceName> cast <spell> on <destName>') -- Soulstone
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 61999, 'battleRes', '<sourceName> resurrected <destName> with <spell>') -- Raise Ally
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 207399, 'battleRes', '<sourceName> cast <spell>') -- Ancestral Protection Totem

	-- Taunts
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 115546, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Provoke, Monk
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 355, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Taunt, Warrior
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 185245, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Torment, Demon Hunter
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 62124, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Hand of Reckoning, Paladin
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 6795, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Growl, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 49576, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Death Grip, Death Knight
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 56222, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Dark Command, Death Knight
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 2649, 'Taunt', '<sourceName> taunted <destName> with <spell>') -- Growl, Hunter Pet
	-- need to check provoke

	-- Targeted Utility Spells
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 29166, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Innervate, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 73325, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Leap of Faith, Priest
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 327661, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Fae Guardians, Priest
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 10060, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Power Infusion, Priest
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 328282, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Blessing of Spring, Paladin
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 328620, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Blessing of Summer, Paladin
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 328622, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Blessing of Autumn, Paladin
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 328281, 'Targeted Utility', '<sourceName> cast <spell> on <destName>') -- Blessing of Winter, Paladin

	-- Misdirects
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 57934, 'Misdirects', '<sourceName> cast <spell> on <destName>') -- Tricks of the Trade, Rogue
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 34477, 'Misdirects', '<sourceName> cast <spell> on <destName>') -- Misdirect, Hunter

	-- Non-targeted Utility Spells
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 205636, 'Group Utility', '<sourceName> cast <spell>') -- Force of Nature, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 77761, 'Group Utility', '<sourceName> cast <spell>') -- Stampeding Roar, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 77764, 'Group Utility', '<sourceName> cast <spell>') -- Stampeding Roar, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 106898, 'Group Utility', '<sourceName> cast <spell>') -- Stampeding Roar, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 64901, 'Group Utility', '<sourceName> cast <spell>') -- Symbol of Hope, Priest
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 114018, 'Group Utility', '<sourceName> cast <spell>') -- Shroud of Concealment, Rogue
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 192077, 'Group Utility', '<sourceName> cast <spell>') -- Wind Rush Totem, Shaman

	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 119381, 'AoE CC', '<sourceName> cast <spell>') -- Leg Sweep, Monk
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 115750, 'AoE CC', '<sourceName> cast <spell>') -- Blinding Light, Paladin
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 179057, 'AoE CC', '<sourceName> cast <spell>') -- Chaos Nova, Demon Hunter
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 99, 'AoE CC', '<sourceName> cast <spell>') -- Incapacitating Roar, Warrior
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 30283, 'AoE CC', '<sourceName> cast <spell>') -- Shadowfury, Warlock
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 192058, 'AoE CC', '<sourceName> cast <spell>') -- Capacitator Totem, Shaman
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 207167, 'AoE CC', '<sourceName> cast <spell>') -- Blinding Sleet, Death Knight
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 205369, 'AoE CC', '<sourceName> cast <spell>') -- Mind Bomb, Priest
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 31661, 'AoE CC', '<sourceName> cast <spell>') -- Dragon's Breath, Mage
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 132469, 'AoE CC', '<sourceName> cast <spell>') -- Typhoon, Druid
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 51490, 'AoE CC', '<sourceName> cast <spell>') -- Thunderstorm, Shaman

	-- Defensive Dispells
	ADDON:AddSpellToCategory(527, 'Dispel') -- Purify, Priest
	ADDON:AddSpellToCategory(218164, 'Dispel') -- Detox, Monk
	ADDON:AddSpellToCategory(115450, 'Dispel') -- Detox, Monk
	ADDON:AddSpellToCategory(88423, 'Dispel') -- Nature's Cure, Druid
	ADDON:AddSpellToCategory(213644, 'Dispel') -- Cleanse Toxins, Paladin
	ADDON:AddSpellToCategory(4987, 'Dispel') -- Cleanse, Paladin
	ADDON:AddSpellToCategory(475, 'Dispel') -- Remove Curse, Mage
	ADDON:AddSpellToCategory(77130, 'Dispel') -- Purify Spirit, Shaman
	ADDON:AddSpellToCategory(51886, 'Dispel') -- Cleanse Spirit, Shaman


	-- Offensive Dispells
	ADDON:AddSpellToCategory(528, 'Dispel') -- Dispel Magic, Priest
	ADDON:AddSpellToCategory(30449, 'Dispel') -- Spellsteal, Mage
	ADDON:AddSpellToCategory(334350, 'Dispel') -- Chi-Ji's Tranquility, Hunter Pet
	ADDON:AddSpellToCategory(278326, 'Dispel') -- Consume Magic, Demon Hunter
	ADDON:AddSpellToCategory(370, 'Dispel') -- Purge, Shaman

	-- Purges
	ADDON:AddSpellToCategory(5938, 'Soothe') -- Shiv, Rogue
	ADDON:AddSpellToCategory(2908, 'Soothe') -- Soothe, Druid
	ADDON:AddSpellToCategory(19801, 'Soothe') -- Tranquilizing Shot, Druid

	-- Interrupts
	ADDON:AddSpellToCategory(1766, 'Interrupts') -- Kick, Rogue
	ADDON:AddSpellToCategory(106839, 'Interrupts') -- Skull Bash
	ADDON:AddSpellToCategory(97547, 'Interrupts') -- Solar Beam 
	ADDON:AddSpellToCategory(183752, 'Interrupts') -- Consume Magic
	ADDON:AddSpellToCategory(147362, 'Interrupts') -- Counter Shot
	ADDON:AddSpellToCategory(187707, 'Interrupts') -- Muzzle
	ADDON:AddSpellToCategory(2139, 'Interrupts') -- Counter Spell
	ADDON:AddSpellToCategory(116705, 'Interrupts') -- Spear Hand Strike
	ADDON:AddSpellToCategory(96231, 'Interrupts') -- Rebuke
	ADDON:AddSpellToCategory(15487, 'Interrupts') -- Silence
	ADDON:AddSpellToCategory(57994, 'Interrupts') -- Windshear
	ADDON:AddSpellToCategory(6552, 'Interrupts') -- Pummel
	ADDON:AddSpellToCategory(171140, 'Interrupts') -- Shadow Lock
	ADDON:AddSpellToCategory(171138, 'Interrupts') -- Shadow Lock
	ADDON:AddSpellToCategory(183752, 'Interrupts') -- Disrupt
	ADDON:AddSpellToCategory(347008, 'Interrupts') -- Axe Toss
	ADDON:AddSpellToCategory(47528, 'Interrupts') -- Mind Freeze

		-- Add spells to be tracked as crowd controls
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 6770, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Sap, Rogue
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 2094, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Blind, Rogue
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 118, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 28272, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 28271, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 61780, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 61305, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 161372, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 61721, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 161354, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 126819, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 277792, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 277787, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 161353, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 161355, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Polymorph, Mage
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 20066, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Repentance, Paladin
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 5782, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Fear, Warlock
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 6358, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Seduction, Warlock
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 115268, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Mesmerize, Warlock
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 710, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Banish, Warlock
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 115078, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Paralysis, Monk
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 217832, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Imprison, Demon Hunter
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 339, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Entangling Roots, Druid
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 9484, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Shackle Undead, Priest
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 51514, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 210875, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 211004, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 211010, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 211015, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 269352, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 277778, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 277784, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Hex, Shaman
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 3355, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Freezing Trap, Hunter
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 334275, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Curse of Exhaustion, Warlock
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 186387, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Bursting Shot, Hunter
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 45524, 'Crowd Control', '<sourceName> cast <spell> on <destName>') -- Chains of Ice, Death Knight

	-- Externals
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 1022, 'Externals', '<sourceName> cast <spell> on <destName>') -- Blessing of Protection, Paladin
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 204018, 'Externals', '<sourceName> cast <spell> on <destName>') -- Blessing of Spellwarding, Paladin
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 6940, 'Externals', '<sourceName> cast <spell> on <destName>') -- Blessing of Sacrifice, Paladin
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 633, 'Externals', '<sourceName> cast <spell> on <destName>') -- Lay on Hands, Paladin
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 47788, 'Externals', '<sourceName> cast <spell> on <destName>') -- Guardian Spirit, Priest
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 2050, 'Externals', '<sourceName> cast <spell> on <destName>') -- Holy Word Serenity, Priest
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 116849, 'Externals', '<sourceName> cast <spell> on <destName>') -- Life Cocoon, Monk
	ADDON:AddSpellToSubEvent('SPELL_AURA_APPLIED', 102342, 'Externals', '<sourceName> cast <spell> on <destName>') -- Ironbark, Druid

	-- Slows
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 45524, 'Slows', '<sourceName> cast <spell> on <destName>') -- Chains of Ice, Death Knight
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 334275, 'Slows', '<sourceName> cast <spell> on <destName>') -- Curse of Exhaustion, Warlock
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 12323, 'Slows', '<sourceName> cast <spell>') -- Piercing Howl, Warrior
	ADDON:AddSpellToSubEvent('SPELL_CAST_SUCCESS', 1715, 'Slows', '<sourceName> cast <spell> on <destName>') -- Hamstring, Warrior

	ADDON:RemoveSpellFromCategory(34477, 'Targeted Utility') -- tricks of the trade
	ADDON:RemoveSpellFromCategory(57934, 'Targeted Utility') -- misdirect
	ADDON:RemoveSpellFromCategory(31935, 'Interrupts') -- avengers shield
	ADDON:RemoveSpellFromCategory(1022, 'Targeted Utility') -- bop
	ADDON:RemoveSpellFromCategory(204018, 'Targeted Utility') -- bos
	ADDON:RemoveSpellFromCategory(132469, 'Crowd Control') -- duplicate typhoon
	ADDON:RemoveSpellFromCategory(334275, 'Crowd Control') -- coe
	ADDON:RemoveSpellFromCategory(45524, 'Crowd Control') -- coi
	ADDON:RemoveSpellFromCategory(12323, 'AoE CC') -- piercing howl
	AstralAnalytics.spellIds['Dispel'] = nil
	AstralAnalytics.spellIds['Soothe'] = nil
	AstralAnalytics.spellIds['AoC CC'] = nil
end
