local ADDON_NAME, ADDON = ...

local GUIDsInGroup = {}

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

function ADDON:WipeTables()
	wipe(self.buffs.missingMark)
	wipe(self.buffs.missingFort)
	wipe(self.buffs.missingInt)
	wipe(self.buffs.missingShout)
	wipe(self.buffs.missingMark)
	wipe(self.buffs.missingBronze)
	wipe(self.buffs.missingFlask)
	wipe(self.buffs.missingFood)
	wipe(self.buffs.missingRune)
	wipe(self.buffs.missingVantus)
end

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
				if AstralAnalytics.options.group[subgroup] then
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
			if AstralAnalytics.options.group[subgroup] then
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
	self:UpdateFrameRows()
end

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

local function InitMembers()
	AAEvents:Unregister('PLAYER_ENTERING_WORLD', 'createUnits')
	local self = ADDON;
	self:InitializeTableMembers()
end
AAEvents:Register('PLAYER_ENTERING_WORLD', InitMembers, 'createUnits')
AAEvents:Register('GROUP_ROSTER_UPDATE', ADDON.InitializeTableMembers, 'GROUP_ROSTER_UPDATE_UPDATE_MEMBERS')