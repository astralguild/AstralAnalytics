local ADDON_NAME, ADDON = ...
local bband, strformat, mfloor = bit.band, string.format, math.floor

local TOTAL_BUFFS = 9 -- Total number of buffs being tracked
local MIN_FOOD_VALUE = 14
local LOW_FLASK_TIME = 900 -- Time, in seconds, for minimum flask duration before reporting their time is low.

Units_Missing_Food = {} -- Used to store unitIDs of people missing keys. Is updated via UNIT_AURA event.

local UNIT_BUFF_FIELDS = {}
UNIT_BUFF_FIELDS['name'] = 1
UNIT_BUFF_FIELDS['icon'] = 2
UNIT_BUFF_FIELDS['count'] = 3
UNIT_BUFF_FIELDS['debuffType'] = 4
UNIT_BUFF_FIELDS['duration'] = 5
UNIT_BUFF_FIELDS['expirationTime'] = 6
UNIT_BUFF_FIELDS['unitCaster'] = 7
UNIT_BUFF_FIELDS['spellID'] = 10
UNIT_BUFF_FIELDS['isBossAura'] = 12

ADDON.units = {}
ADDON.buffs = {}
ADDON.buffs.missingMark = {}
ADDON.buffs.missingFort = {}
ADDON.buffs.missingInt = {}
ADDON.buffs.missingShout = {}
ADDON.buffs.missingMark = {}
ADDON.buffs.missingBronze = {}
ADDON.buffs.missingFlask = {}
ADDON.buffs.missingFood = {}
ADDON.buffs.missingRune = {}
ADDON.buffs.missingVantus = {}
ADDON.buffs.lowFlaskTime = {}

local LIST_NAMES = {}
LIST_NAMES['missingFort'] = 'Missing Fortitude'
LIST_NAMES['missingInt'] = 'Missing Arcane Intellect'
LIST_NAMES['missingShout'] = 'Missing Battle Shout'
LIST_NAMES['missingMark'] = 'Missing Mark of the Wild'
LIST_NAMES['missingBronze'] = 'Missing Blessing of the Bronze'
LIST_NAMES['missingFlask'] = 'Missing Flask'
LIST_NAMES['missingFood'] = 'Missing Food'
LIST_NAMES['missingRune'] = 'Missing Augment Rune'
LIST_NAMES['missingVantus'] = 'Missing Vantus Rune'
LIST_NAMES['lowFlaskTime'] = 'Low Flask'

local function GroupMembers(reversed, forceParty)
    local unit  = (not forceParty and IsInRaid()) and 'raid' or 'party'
    local numGroupMembers = forceParty and GetNumSubgroupMembers()  or GetNumGroupMembers()
    local i = reversed and numGroupMembers or (unit == 'party' and 0 or 1)
    return function()
        local ret 
        if i == 0 and unit == 'party' then 
            ret = 'player'
        elseif i <= numGroupMembers and i > 0 then
            ret = unit .. i
        end
        i = i + (reversed and -1 or 1)
        return ret
    end
end

local name, icon, count, debuffType, duration, expirationTime, unitCaster, spellId, isBossAura

function ADDON:AuraInfo(unit, returnField, filter)
	local index = 1
	return function()
		if returnField then
			local ret =  select(UNIT_BUFF_FIELDS[returnField], UnitAura(unit, index, filter))
			index = index + 1
			return ret, (index - 1)
		else
			name, icon, count, debuffType, duration, expirationTime, unitCaster, spellId, isBossAura = UnitAura(unit, index, filter)
			index = index + 1
			return name, icon, count, debuffType, duration, expirationTime, unitCaster, spellId, isBossAura, (index - 1)
		end
	end
end

function ADDON:WipeTables()
	wipe(self.buffs.missingFort)
	wipe(self.buffs.missingInt)
	wipe(self.buffs.missingShout)
	wipe(self.buffs.missingMark)
	wipe(self.buffs.missingBronze)
	wipe(self.buffs.missingFlask)
	wipe(self.buffs.missingFood)
	wipe(self.buffs.missingRune)
	wipe(self.buffs.missingVantus)
	wipe(self.buffs.lowFlaskTime)
	wipe(Units_Missing_Food)
end

local GUIDsInGroup = {}

function ADDON:InitializeTableMembers()
	local self = ADDON;
	for GUID in pairs(GUIDsInGroup) do
		GUIDsInGroup[GUID] = false
	end

	for unitID in GroupMembers() do
		if not UnitExists(unitID) then break end
		local subgroup = 1
		if unitID:find('raid') then
			_, _, subgroup = GetRaidRosterInfo(unitID:match('%d+'))
		end
		local GUID = UnitGUID(unitID)

		local tempUnit
		for k, unit in ipairs(self.units) do
			if unit.guid == GUID then
				if AstralAnalytics.options.group[subgroup].isEnabled then
					tempUnit = unit
				else
					table.remove(self.units, k)
					GUIDsInGroup[GUID] = nil
				end
				break
			end
		end
		if tempUnit then
			GUIDsInGroup[GUID] = true
			tempUnit.unitID = unitID
			if not tempUnit.class then
				tempUnit.class = select(2, UnitClass(unitID))
			end
			tempUnit.subgroup = subgroup
		else
			if AstralAnalytics.options.group[subgroup].isEnabled then
				GUIDsInGroup[GUID] = true
				table.insert(self.units, {unitID = unitID, guid = GUID, name = UnitName(unitID), class = select(2, UnitClass(unitID)), subgroup = subgroup, buff = {}})
			end
		end
	end
	for i = #self.units, 1, -1 do
		if not GUIDsInGroup[self.units[i].guid] then
			table.remove(self.units, i)
		end
	end
	self:CheckForBuffs(false)
	self:SortUnits()
	ADDON:UpdateFrameRows()
end

local function InitMembers()
	AAEvents:Unregister('PLAYER_ENTERING_WORLD', 'createUnits')
	local self = ADDON;
	self:InitializeTableMembers()
end
AAEvents:Register('PLAYER_ENTERING_WORLD', InitMembers, 'createUnits')

AAEvents:Register('GROUP_ROSTER_UPDATE', ADDON.InitializeTableMembers, 'GROUP_ROSTER_UPDATE_UPDATE_MEMBERS')

function ADDON:PopulateMissingTables()
	local self = ADDON;
	for k, unit in ipairs(self.units) do
		table.insert(self.buffs.missingMark, unit)
		table.insert(self.buffs.missingFort, unit)
		table.insert(self.buffs.missingInt, unit)
		table.insert(self.buffs.missingShout, unit)
		table.insert(self.buffs.missingMark, unit)
		table.insert(self.buffs.missingBronze, unit)
		table.insert(self.buffs.missingFlask, unit)
		table.insert(self.buffs.missingFood, unit)
		table.insert(self.buffs.missingRune, unit)
		table.insert(self.buffs.missingVantus, unit)
		Units_Missing_Food[unit.unitID] = true
	end
end

local function UpdateUnitName(unitID)
	if not unitID then return end
	if not (unitID:find('raid') or unitID:find('party')) then return end

	for _, unit in pairs(ADDON.units) do
		if unit.unitID == unitID then
			unit.name = UnitName(unitID)
			unit.class = select(2, UnitClass(unitID))
		end
	end
	ADDON:SortUnits()
	ADDON:UpdateFrameRows()
end
AAEvents:Register('UNIT_NAME_UPDATE', UpdateUnitName, 'UpdateUnitName')

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

function ADDON:CheckForBuffs(sendReport)
	local self = ADDON;
	self:WipeTables()
	self:PopulateMissingTables()
	local name, icon, duration, expirationTime, spellId, amount

	-- Check for buffs now
	for _, unit in pairs(self.units) do
		-- nil out all previous buff info
		unit.numMissing = TOTAL_BUFFS -- Total buffs being tracked
		unit.buff = {}
		for i = 1, 40 do
			name, icon, _, _, duration, expirationTime, _, _, _, spellId, _, _, _, _, _, amount = UnitBuff(unit.unitID, i)
			if not name then break end

			if self.BUFFS.FLASKS[spellId] then
				local timeLeft = expirationTime - GetTime()
				unit.buff[4] = {spellId, icon, timeLeft} -- FLask
				unit.numMissing = unit.numMissing - 1
				self:HasBuff(unit.guid, self.buffs.missingFlask)
				if timeLeft <= LOW_FLASK_TIME then
					table.insert(self.buffs.lowFlaskTime, unit)
				end
			-- Check of Augment Rune
			elseif self.BUFFS.RUNES[spellId] then
				unit.buff[2] = {spellId, icon} -- Augment Rune
				unit.numMissing = unit.numMissing - 1
				self:HasBuff(unit.guid, self.buffs.missingRune)
			-- Check for vantus
			elseif self.BUFFS.VANTUS[spellId] then
				unit.buff[1] = {spellId, icon} -- Vantus Rune
				unit.numMissing = unit.numMissing - 1
				self:HasBuff(unit.guid, self.buffs.missingVantus)
			elseif name == 'Well Fed' and amount and amount >= MIN_FOOD_VALUE then
				unit.buff[3] = {spellId, icon} -- Well Fed
				unit.numMissing = unit.numMissing - 1
				self:HasBuff(unit.guid, self.buffs.missingFood)
			elseif name == 'Food & Drink' then
				if not unit.buff[3] or (unit.buff[3] and unit.buff[3][2] ~= 136000) then
					unit.buff[3] = {spellId, icon}
					if Units_Missing_Food[unit.unitID] then
						Units_Missing_Food[unit.unitID] = nil
					end
				end
			elseif self.BUFFS.CLASS_BUFFS[spellId] then
				self:HasBuff(unit.guid, self.buffs[self.BUFFS.CLASS_BUFFS[spellId]])
				if spellId == 1459 or spellId == 264760 then -- Arance Intellect
					unit.buff[6] = {spellId, icon}
				elseif spellId == 21562 or spellId == 264764 then -- Fortitude
					unit.buff[7] = {spellId, icon}
				elseif spellId == 6673 or spellId == 264761 then -- Battle Shout
					unit.buff[5] = {spellId, icon}
				elseif spellId == 1126 then -- Mark of the Wild
					unit.buff[8] = {spellId, icon}
				elseif spellId == 381732 -- Blessing of the Bronze
						or spellId == 381741
						or spellId == 381746
						or spellId == 381748
						or spellId == 381749
						or spellId == 381750
						or spellId == 381751
						or spellId == 381752
						or spellId == 381753
						or spellId == 381754
						or spellId == 381756
						or spellId == 381757
						or spellId == 381758 then
					unit.buff[9] = {spellId, icon}
				end
				unit.numMissing = unit.numMissing - 1
			end
		end

		if not unit.buff[3] or (unit.buff[3] and unit.buff[3][2] ~= 136000) then
			Units_Missing_Food[unit.unitID] = true
		end
	end
	if sendReport then
		self:ReportList('missingFlask', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingFood', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingRune', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingInt', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingFort', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingShout', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingMark', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingBronze', AstralAnalytics.options.general.announceChannel)
		self:ReportList('missingVantus', AstralAnalytics.options.general.announceChannel)
		self:ReportList('lowFlaskTime', AstralAnalytics.options.general.announceChannel)
	end
end

function ADDON:UpdateUnitBuff(guid)
	local self = ADDON;

	local unit
	for _, target in ipairs(self.units) do
		if target.guid == guid then
			unit = target
			break
		end
	end
	if not unit then return end

	for list in pairs(self.buffs) do
		local found = false
		for _, target in ipairs(self.buffs[list]) do
			if target.guid == unit.guid then
				found = true
				break
			end
		end
		if not found then
			table.insert(self.buffs[list], unit)
		end
	end

	wipe(unit.buff)
	unit.numMissing = TOTAL_BUFFS
	local name, icon, duration, expirationTime, spellId, amount
	for i = 1, 40 do
		name, icon, _, _, duration, expirationTime, _, _, _, spellId, _, _, _, _, _, amount = UnitBuff(unit.unitID, i)
		if not name then break end

		if self.BUFFS.FLASKS[spellId] then -- Flask buff
			local timeLeft = expirationTime - GetTime()
			unit.buff[4] = {spellId, icon, timeLeft} -- FLask
			unit.numMissing = unit.numMissing - 1
			self:HasBuff(unit.guid, self.buffs.missingFlask)
			if timeLeft <= LOW_FLASK_TIME then
				table.insert(self.buffs.lowFlaskTime, unit)
			end
		-- Check of Augment Rune
		elseif self.BUFFS.RUNES[spellId] then
			unit.buff[2] = {spellId, icon} -- Augment Rune
			unit.numMissing = unit.numMissing - 1
			self:HasBuff(unit.guid, self.buffs.missingRune)
		-- Check for vantus
		elseif self.BUFFS.VANTUS[spellId] then
			unit.buff[1] = {spellId, icon} -- Vantus Rune
			unit.numMissing = unit.numMissing - 1
			self:HasBuff(unit.guid, self.buffs.missingVantus)
		elseif name == 'Well Fed' and amount and amount >= MIN_FOOD_VALUE then
			unit.buff[3] = {spellId, icon} -- Well Fed
			unit.numMissing = unit.numMissing - 1
			self:HasBuff(unit.guid, self.buffs.missingFood)
		elseif name == 'Food & Drink' then
			if not unit.buff[3] or (unit.buff[3] and unit.buff[3][2] ~= 136000) then
				unit.buff[3] = {spellId, icon}
				if Units_Missing_Food[unit.unitID] then
					Units_Missing_Food[unit.unitID] = nil
				end
			end
		elseif self.BUFFS.CLASS_BUFFS[spellId] then
			self:HasBuff(unit.guid, self.buffs[self.BUFFS.CLASS_BUFFS[spellId]])
			if spellId == 1459 or spellId == 264760 then -- Arance Intellect
				unit.buff[6] = {spellId, icon}
			elseif spellId == 21562 or spellId == 264764 then -- Fortitude
				unit.buff[7] = {spellId, icon}
			elseif spellId == 6673 or spellId == 264761 then -- Battle Shout
				unit.buff[5] = {spellId, icon}
			elseif spellId == 1126 then -- Mark of the Wild
				unit.buff[8] = {spellId, icon}
			elseif spellId == 381732 -- Blessing of the Bronze
					or spellId == 381741
					or spellId == 381746
					or spellId == 381748
					or spellId == 381749
					or spellId == 381750
					or spellId == 381751
					or spellId == 381752
					or spellId == 381753
					or spellId == 381754
					or spellId == 381756
					or spellId == 381757
					or spellId == 381758 then
				unit.buff[9] = {spellId, icon}
			end
			unit.numMissing = unit.numMissing - 1
		end
	end
	if not unit.buff[3] or (unit.buff[3] and unit.buff[3][2] ~= 136000) then
		Units_Missing_Food[unit.unitID] = true
	end
end

local function UpdateUnitAura(unitID)
	if not Units_Missing_Food[unitID] then return end

	for _, unit in pairs(ADDON.units) do
		if unit.unitID == unitID then
			ADDON:UpdateUnitBuff(unit.guid)
			ADDON:SortUnits()
			ADDON:UpdateFrameRows()
			break
		end
	end
end

AAEvents:Register('UNIT_AURA', UpdateUnitAura, 'UpdateUnitAura')

function ADDON:ReportList(list, msgChannel)
	local msgChannel = msgChannel or 'SMART'
	local msg

	if AstralAnalytics.options.general['announceOwnGuild'].isEnabled then
		local inGuildGroup = InGuildParty()
		if not inGuildGroup then return end
	end

	if not AstralAnalytics.options.reportLists[list].isEnabled then return end

	if #self.buffs[list] > 0 then
		if msgChannel == 'console' then
			if list ~= 'lowFlaskTime' then
				msg = self:ColouredName(self.buffs[list][1].name, self.buffs[list][1].class)
				for i = 2, #self.buffs[list] do
					msg = string.format('%s, %s', msg, self:ColouredName(self.buffs[list][i].name, self.buffs[list][i].class))
				end
			else
				msg = strformat('%s (%dm)', self:ColouredName(self.buffs[list][1].name, self.buffs[list][1].class), mfloor(self.buffs[list][1].buff[4][3]/60))
				for i = 2, #self.buffs[list] do
					msg = strformat('%s, %s (%dm)', msg, self:ColouredName(self.buffs[list][i].name, self.buffs[list][i].class), mfloor(self.buffs[list][i].buff[4][3]/60))
				end
			end
		else
			if list ~= 'lowFlaskTime' then
				msg = self.buffs[list][1].name
				for i = 2, #self.buffs[list] do
					msg = strformat('%s, %s', msg, self.buffs[list][i].name)
				end
			else
				msg = strformat('%s (%dm)', self.buffs[list][1].name, mfloor(self.buffs[list][1].buff[4][3]/60))
				for i = 2, #self.buffs[list] do
					msg = strformat('%s, %s (%dm)', self.buffs[list][i].name, mfloor(self.buffs[list][i].buff[4][3]/60))
				end
			end
		end
	else
		msg = 'None'
	end
	AstralSendMessage(string.format('%s (%d): %s', LIST_NAMES[list], #self.buffs[list], msg), msgChannel)
end

function ADDON:HasBuff(guid, missingList)
	for k, targetUnit in ipairs(missingList) do
		if targetUnit.guid == guid then
			table.remove(missingList, k)
			break
		end
	end
end

function ADDON:SortUnits()
	local self = ADDON;

	table.sort(self.units, function(a, b)
		if a.numMissing > b.numMissing then
			return true
		elseif a.numMissing < b.numMissing then
			return false
		else
			return a.name < b.name
		end
	end)
end

function ADDON:OnReadyCheck()
	local self = ADDON;
	self:CheckForBuffs(AstralAnalytics.options.general.autoAnnounce.isEnabled)
	self:SortUnits()
	self:UpdateFrameRows()
	if AstralAnalytics.options.general.showOnReadyCheck.isEnabled then
		AAFrame:Show()
	end
end

AAEvents:Register('READY_CHECK', ADDON.OnReadyCheck, 'ADDON_OnReadyCheck')

AAEvents:Register('ENCOUNTER_START', function() AAFrame:Hide() end, 'enoucnter_HideFrame')