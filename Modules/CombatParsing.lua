local ADDON_NAME, ADDON = ...
local strformat = string.format
local bband = bit.band

-- Static, local stuff
local RAID_TARGET_BIT = {}
RAID_TARGET_BIT[1] = 1
RAID_TARGET_BIT[2] = 2
RAID_TARGET_BIT[4] = 3
RAID_TARGET_BIT[8] = 4
RAID_TARGET_BIT[16] = 5
RAID_TARGET_BIT[32] = 6
RAID_TARGET_BIT[64] = 7
RAID_TARGET_BIT[128] = 8

local RAID_ICON_STRING = {}
RAID_ICON_STRING[1] = '{star}'
RAID_ICON_STRING[2] = '{circle}'
RAID_ICON_STRING[3] = '{diamond}'
RAID_ICON_STRING[4] = '{triangle}'
RAID_ICON_STRING[5] = '{moon}'
RAID_ICON_STRING[6] = '{square}'
RAID_ICON_STRING[7] = '{cross}'
RAID_ICON_STRING[8] = '{skull}'

-- String format message texts
local CONSOLE_INTERRUPT_TEXT = '%s interrupted %s casting %s' -- RAIDICON UNIT RAIDICON interrupted RAIDICON TARGET RAIDICON with SPELL LINK
local CONSOLE_AURA_BROKEN_TEXT = '%s on %s removed by %s with %s' -- [ADDON]: [SPELL LINK] on RAIDICON DEST RAIDICON removed by RAIDICON UNIT RAIDICON with [SPELL LINK]

local CHAT_INTERRUPT_TEXT = 'Interrupted %s %s\'s %s %s' -- INTERRUPTED UNIT's SPELL LINK


CombatEvents = Event:New()

function CombatEvents:RegisterSubEvent(subEvent, func, name)
	if self:IsSubEventRegistered(subEvent, name) then
		error('duplicate name for subEvent')
	end

	local obj = {}
	obj.name = name or 'anonymous'
	obj.method = func

	return obj
end

function CombatEvents:IsSubEventRegistered(subEvent, name)
	if not subEvent or not name then
		return nil
	end

	for _, obj in self.COMBAT_FUNCS[subEvent] do
		if obj.name == name then
			return true
		end		
	end

	return false
end


local COMBAT_FUNCS = {}
--[[
function ADDON:AddCombatFunction(subEvent, funcString, hookType)
	if not subEvent and type(subEvent) ~= 'string' then
		error('AddCombatFunction(subEvent, func): subEvent string expected, got ' ..  type(subEvent))
	end
	if not funcString and type(funcString) ~= 'string' then
		error('AddCombatFunction(subEvent, funcString): funcString string expected, got ' .. type(funcString))
	end
	if not COMBAT_FUNCS[subEvent] then
		COMBAT_FUNCS[subEvent] = {}
		COMBAT_FUNCS[subEvent].funcStrings = {}
		COMBAT_FUNCS[subEvent].method = ''
	end
	table.insert(COMBAT_FUNCS[subEvent].funcStrings, funcString)

	local newFuncString = ''
	for i = 1, #COMBAT_FUNCS[subEvent].funcStrings do
		newFuncString = strformat('%s%s', newFuncString, COMBAT_FUNCS[subEvent].funcStrings[i])
	end

	COMBAT_FUNCS[subEvent].method = loadstring(newFuncString)
end
]]
--[[
function WrapNameInColorAndIcons(unit, class, hexColor, raidFlags)
	if not unit or type(unit) ~= 'string' then
		error('unit expected, got ' .. type(unit))
	end

	local icon = ''
	if true then -- Settings, enableIconsInReports.  Maybe have it be specific to what option it is?
		local bitRaid = bit.band(raidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)	
		local raidIndex = bitRaid and RAID_TARGET_BIT[bitRaid] or nil

		if raidIndex then
			icon = _G['COMBATLOG_ICON_RAIDTARGET' .. raidIndex]
		end
	end

	local class = class or select(2, UnitClass(unit))
	local nameColor = hexColor ~= 'nil' and hexColor  or select(4, GetClassColor(class)) -- Hex color code
	if not nameColor then
		return strformat('%s%s%s', icon, unit, icon)
	else
		return strformat('%s%s%s', icon, WrapTextInColorCode(unit, nameColor), icon)
	end
end]]

local function GetRaidTargetString(targetFlags)
	if AstralAnalytics.options.general.raidIcons then -- Settings, enableIconsInReports.  Maybe have it be specific to what option it is?
		local bitRaid = bband(targetFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)	
		local raidIndex = bitRaid and RAID_TARGET_BIT[bitRaid] or nil

		if raidIndex then
			return _G['COMBATLOG_ICON_RAIDTARGET' .. raidIndex]
		end
	end

	return ''
end

local function NewFunctionObject(func, name)
	local self = {}
	self.name = name
	self.method = func

	return self
end

function ADDON:AddCombatFunction(subEvent, func, name)
	if not subEvent and type(subEvent) ~= 'string' then
		error('AddCombatFunction(subEvent, func): subEvent string expected, got ' ..  type(subEvent))
	end
	if not func and type(func) ~= 'function' then
		error('AddCombatFunction(subEvent, func): func, function expected, got ' .. type(func))
	end

	if not COMBAT_FUNCS[subEvent] then
		COMBAT_FUNCS[subevent] = {}
	end

	CombatEvents:RegisterSubEvent(subEvent, func, name)
end

COMBAT_FUNCS['SPELL_INTERRUPT'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17)
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end
	local spellLink = GetSpellLink(param15)
	spellLink = spellLink or param16

	if AstralAnalytics.options.combatEvents.interrupts then 	
		local destIcon = GetRaidTargetString(destRaidFlags)
		local sourceIcon = GetRaidTargetString(sourceRaidFlags)

		AstralSendMessage(strformat(CONSOLE_INTERRUPT_TEXT, WrapNameInColorAndIcons(sourceName, nil, 'nil', sourceRaidFlags), WrapNameInColorAndIcons(destName, nil, ADDON.COLOURS.TARGET, destRaidFlags), spellLink), 'console')
	end
	if AstralAnalytics.options.combatEvents.selfInterrupt and sourceFlags == 1297 and IsInGroup() then -- Flag for self
		local raidIndex = bband(destRaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
		local destIcon = RAID_ICON_STRING[RAID_TARGET_BIT[raidIndex]] or ''
		local chatType = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and 'INSTANCE_CHAT') or (IsInRaid() and 'RAID') or 'PARTY'
		SendChatMessage(strformat(CHAT_INTERRUPT_TEXT, destIcon, destName, destIcon, spellLink), chatType)
	end
end

COMBAT_FUNCS['SPELL_AURA_BROKEN_SPELL'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ccSpellID, param13, param14, param15, param16, param17)
	if not AstralAnalytics.options.combatEvents.cc_break then return end
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end

	if ADDON:IsSpellTracked('SPELL_CAST_SUCCESS', ccSpellID) and ADDON:IsSpellInCategory(ccSpellID, 'crowd') then  -- Only fire if the spellID is a form of CC we are tracking | Bodge for now. Think of a better way to check stuff.
		local ccSpellLink = GetSpellLink(ccSpellID)
		local breakSpellLink = GetSpellLink(param15)
		AstralSendMessage(strformat(CONSOLE_AURA_BROKEN_TEXT, ccSpellLink, WrapNameInColorAndIcons(destName, nil, ADDON.COLOURS.TARGET, destRaidFlags), WrapNameInColorAndIcons(sourceName, nil, nil, sourceRaidFlags), breakSpellLink), 'console')
	end
end

COMBAT_FUNCS['SPELL_AURA_BROKEN'] = function(...) -- No idea when this fires, saw it fire on a water walk tho?
	-- Something goes here?
end

COMBAT_FUNCS['SPELL_AURA_APPLIED'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end
	if AstralAnalytics.options.combatEvents.cc_cast and ADDON:IsSpellTracked(subEvent, spellID) then
		local spellLink = GetSpellLink(spellID)
		local destIcon = GetRaidTargetString(destRaidFlags)
		local sourceIcon = GetRaidTargetString(sourceRaidFlags)
		ADDON:GetSubEventMethod(subEvent, spellID)(sourceName, sourceRaidFlags, spellLink, destName, destFlags, destRaidFlags)
		return
	end

	if param13 == 'Well Fed' then
		ADDON:UpdateUnitBuff(destGUID)
		ADDON:SortUnits()
		ADDON:UpdateFrameRows()
	else
		for k, table in pairs(ADDON.BUFFS) do
			if table[spellID] then
				ADDON:UpdateUnitBuff(destGUID)
				ADDON:SortUnits()
				ADDON:UpdateFrameRows()
				break
			end
		end
	end
end

COMBAT_FUNCS['SPELL_CAST_SUCCESS'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end

	if bband(sourceFlags, COMBATLOG_OBJECT_TYPE_MASK) == 4096 then
		sourceName = sourceName .. ' <' .. ADDON:GetPetOwner(sourceName) .. '>'
	end
	--[[if spellID == 19577 then
		tprint({timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17})
	end]]
	if ADDON:IsSpellTracked(subEvent, spellID) then
		local spellLink = GetSpellLink(spellID)
		local destIcon = GetRaidTargetString(destRaidFlags)
		local sourceIcon = GetRaidTargetString(sourceRaidFlags)
		ADDON:GetSubEventMethod(subEvent, spellID)(sourceName, sourceRaidFlags, spellLink, destName, destFlags, destRaidFlags)
	end
end

local CONSOLE_MSG_SPELL_DISPELL = '%s removed %s from %s with %s'
COMBAT_FUNCS['SPELL_DISPEL'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if not AstralAnalytics.options.combatEvents.dispell then return end
	--tprint({timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17})
	local dispellSpellLink = GetSpellLink(spellID)
	local removedSpellLink = GetSpellLink(param15)
	AstralSendMessage(strformat(CONSOLE_MSG_SPELL_DISPELL, WrapNameInColorAndIcons(sourceName, nil, nil, sourceRaidFlags), removedSpellLink, WrapNameInColorAndIcons(destName, nil, (bband(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) < 5 and nil or ADDON.COLOURS.TARGET), destRaidFlags), dispellSpellLink))
end

COMBAT_FUNCS['UNIT_DIED'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if bband(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end
end

COMBAT_FUNCS['SPELL_AURA_REMOVED'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if bband(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end

	if param13 == 'Well Fed' then
		ADDON:UpdateUnitBuff(destGUID)
		ADDON:SortUnits()
		ADDON:UpdateFrameRows()
	else			
		for _, table in pairs(ADDON.BUFFS) do
			if table[spellID] then
				ADDON:UpdateUnitBuff(destGUID)
				ADDON:SortUnits()
				ADDON:UpdateFrameRows()
				break
			end
		end
	end
end

local timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17
local function ParseCombatLog()
	timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17 = CombatLogGetCurrentEventInfo()
	if ADDON[subEvent] then
		local spellLink = GetSpellLink(spellID)
		local destIcon = GetRaidTargetString(destRaidFlags)
		local sourceIcon = GetRaidTargetString(sourceRaidFlags)
	end

	sourceName = sourceName or 'Unknown'
	destName = destName or 'Unknown'
	if COMBAT_FUNCS[subEvent] then
		COMBAT_FUNCS[subEvent](timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17)
	end
end
CombatEvents:Register('COMBAT_LOG_EVENT_UNFILTERED', ParseCombatLog, 'CombatLogParser')