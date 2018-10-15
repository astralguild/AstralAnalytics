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
local CONSOLE_INTERRUPT_TEXT_MISSED = '%s missed %s on %s (Not Casting)'
local CONSOLE_INTERRUPT_TEXT_IMMUNE = '%s missed %s on %s (Immune)'

local CHAT_INTERRUPT_TEXT = 'Interrupted %s casting %s' -- INTERRUPTED UNIT's SPELL LINK

CombatEvents = Event:New()
CombatEvents.SubEventFunctions = {}

function CombatEvents:RegisterSubEventMethod(subEvent, name, func)
	if self:IsSubEventRegistered(subEvent, name) then
		error('duplicate name for subEvent')
	end

	if not self.SubEventFunctions[subEvent] then
		self.SubEventFunctions[subEvent] = {}
	end

	self.SubEventFunctions[subEvent][name]= func	
end

function CombatEvents:IsSubEventRegistered(subEvent, name)
	if not subEvent or not name then
		return nil
	end
	if self.SubEventFunctions[subEvent] then
		return true
	end

	return false
end


local COMBAT_FUNCS = {}

function ADDON:AddCombatFunction(subEvent, funcName, func)
	if not subEvent or type(subEvent) ~= 'string' then
		error('AddCombatFunction(subEvent, func): subEvent string expected, got ' ..  type(subEvent))
	end
	if not func and type(func) ~= 'func' then
		error('AddCombatFunction(subEvent, func): func string expected, got ' .. type(func))
	end
	if not COMBAT_FUNCS[subEvent] then
		COMBAT_FUNCS[subEvent] = {}
	end
end

local function GetRaidTargetString(targetFlags)
	if AstralAnalytics.options.general.raidIcons.isEnabled then -- Settings, enableIconsInReports.  Maybe have it be specific to what option it is?
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
		COMBAT_FUNCS[subEvent] = {}
	end

	CombatEvents:RegisterSubEvent(subEvent, func, name)
end

COMBAT_FUNCS['SPELL_INTERRUPT'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17)
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end
	local spellLink = GetSpellLink(param15)
	spellLink = spellLink or param16

	if AstralAnalytics.options.combatEvents.interrupts.isEnabled then
		AstralSendMessage(strformat(CONSOLE_INTERRUPT_TEXT, WrapNameInColorAndIcons(sourceName, nil, sourceRaidFlags), WrapNameInColorAndIcons(destName, destFlags, destRaidFlags), spellLink), 'console')
	end
	if AstralAnalytics.options.combatEvents.selfInterrupt.isEnabled and sourceFlags == 1297 and IsInGroup() then -- Flag for self
		local raidIndex = bband(destRaidFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
		local destIcon = RAID_ICON_STRING[RAID_TARGET_BIT[raidIndex]] or ''
		local chatType = (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and 'INSTANCE_CHAT') or (IsInRaid() and 'RAID') or 'PARTY'
		SendChatMessage(strformat(CHAT_INTERRUPT_TEXT, destIcon, destName, destIcon, spellLink), chatType)
	end
end

COMBAT_FUNCS['SPELL_AURA_APPLIED'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) > 4 then return end

	-- Unit gained a food buff, update their buffs and the buff list
	if param13 == 'Well Fed' or param13:find'Food' then
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
	if bband(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) < 5 then
		local spellLink = GetSpellLink(spellID)
		if bband(sourceFlags, COMBATLOG_OBJECT_TYPE_MASK) == 4096 then -- Unit is a friendly group member's pet
			if not sourceName then return end
			sourceName = sourceName .. ' <' .. ADDON:GetPetOwner(sourceName) .. '>'
		end
		if ADDON:IsSpellTracked(subEvent, spellID) then
			ADDON:GetSubEventMethod(subEvent, spellID)(sourceName, sourceRaidFlags, spellLink, destName, destFlags, destRaidFlags)
		end
		-- Missed interrupts
		if AstralAnalytics.options.combatEvents.missedInterrupts.isEnabled then
			if ADDON:IsSpellInCategory(spellID, 'INTERRUPTS') then
				local unit
				for i = 1, #ADDON.units do
					if ADDON.units[i].guid == sourceGUID then
						unit = ADDON.units[i].unitID
						break
					end
				end
				local name, notInterruptible
				name, _, _, _, _, _, _, notInterruptible = UnitCastingInfo(unit .. 'target')
				if not name then
					name, _, _, _, _, _, notInterruptible = UnitChannelInfo(unit .. 'target')
				end

				if not name then
					AstralSendMessage(strformat(CONSOLE_INTERRUPT_TEXT_MISSED, WrapNameInColorAndIcons(sourceName, nil, sourceRaidFlags), spellLink, WrapNameInColorAndIcons(destName, destFlags)), 'console')
				elseif name and notInterruptible then
					AstralSendMessage(strformat(CONSOLE_INTERRUPT_TEXT_IMMUNE, WrapNameInColorAndIcons(sourceName, nil, sourceRaidFlags), spellLink, WrapNameInColorAndIcons(destName, destFlags)), 'console')
				end
			end
		end
	end
end

local CONSOLE_MSG_SPELL_DISPELL = '%s removed %s from %s with %s'
COMBAT_FUNCS['SPELL_DISPEL'] = function(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if not AstralAnalytics.options.combatEvents.dispell.isEnabled then return end
	local dispellSpellLink = GetSpellLink(spellID)
	local removedSpellLink = GetSpellLink(param15)
	AstralSendMessage(strformat(CONSOLE_MSG_SPELL_DISPELL, WrapNameInColorAndIcons(sourceName, nil, sourceRaidFlags), removedSpellLink, WrapNameInColorAndIcons(destName, destFlags, destRaidFlags), dispellSpellLink), 'console')
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

	-- Names will default to Unknown if the information is not given from the client
	sourceName = sourceName or 'Unknown'
	destName = destName or 'Unknown'
	if COMBAT_FUNCS[subEvent] then
		COMBAT_FUNCS[subEvent](timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17)
	end

	if CombatEvents.SubEventFunctions[subEvent] then
		for _, method in pairs(CombatEvents.SubEventFunctions[subEvent]) do
			method(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17)
		end
	end
end

CombatEvents:Register('COMBAT_LOG_EVENT_UNFILTERED', ParseCombatLog, 'CombatLogParser')