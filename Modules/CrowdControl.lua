local ADDON_NAME, ADDON = ...

local strformat = string.format
local bband = bit.band

ControlledUnits = {} -- Table for units currently under the affects of a crowd control
local CONSOLE_MSG_CROWD_BREAK = '%s on %s removed by %s with %s' -- [SPELL LINK] on RAIDICON DEST RAIDICON removed by RAIDICON UNIT RAIDICON with [SPELL LINK]
local CONSOLE_MSG_CROWD_EXPIRE = '%s expired on %s' -- [SPELL LINK] expired on DESTINATION
local CONSOLE_AURA_BROKEN_TEXT = '%s on %s removed by %s with %s' -- [SPELL LINK] on RAIDICON DEST RAIDICON removed by RAIDICON UNIT RAIDICON with [SPELL LINK]
local AUTO_ATTACK_SPELLID = 6603

local function UnitIsControlled(guid)
	if ControlledUnits[guid] then
		return true
	else
		return false
	end
end

local function AddUnitToControlledList(guid)
	if not type(guid) == 'string' then
		error('AddUnitToControlledList(guid) string expected, received ' .. type(guid))
	end	
	ControlledUnits[guid] = {}
end

local function RemoveUnitFromControlledList(guid)
	if not type(guid) == 'string' then
		error('RemoveUnitFromControlledList(guid) string expected, received ' .. type(guid))
	end
	if not ControlledUnits[guid] then
		return nil
	else
		local name, flags, timeStamp = unpack(ControlledUnits[guid])
		ControlledUnits[guid] = nil

		return name, flags, timeStamp
	end
end

local function SetControlledUnitLastHit(guid, data)
	if not type(guid) == 'string' then
		error('SetControlledUnitLastHit(guid, data) string expected, received ' .. type(guid))
	end
	if not type(data) == 'table' then
		error('SetControlledUnitLastHit(guid, data) table expected, received ' .. type(data))
	end
	if not ControlledUnits[guid] then
		return
	end

	ControlledUnits[guid] = data
end

local function CrowdControl_OnAuraApplied(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if AstralAnalytics.options.combatEvents.crowd.isEnabled and ADDON:IsSpellInCategory(spellID, 'Crowd Control') and (not AstralAnalytics.options.combatEvents[spellID] or AstralAnalytics.options.combatEvents[spellID] and AstralAnalytics.options.combatEvents[spellID].isEnabled) then
		local spellLink = GetSpellLink(spellID)
		ADDON:GetSubEventMethod(subEvent, spellID)(sourceName, sourceRaidFlags, spellLink, destName, destFlags, destRaidFlags)
		AddUnitToControlledList(destGUID)
	end
end

local function CrowdControl_OnDamageEvent(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, param12, param13, param14, param15, param16, param17)
	if not UnitIsControlled(destGUID) then return end
	SetControlledUnitLastHit(destGUID, {sourceName, sourceRaidFlags, timeStamp})
end

local function CrowdControl_OnAuraBreakSpell(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, ccBreakSpellID, param16, param17)
	if not UnitIsControlled(destGUID) then return end -- Unit not being controlled
	if not ADDON:IsSpellInCategory(spellID, 'Crowd Control') then return end -- Wasn't a CC spell being removed

	local ccBreakSpellLink = GetSpellLink(ccBreakSpellID)
	local spellLink = GetSpellLink(spellID)
	
	AstralSendMessage(strformat(CONSOLE_MSG_CROWD_BREAK, spellLink, WrapNameInColorAndIcons(destName, destFlags, destRaidFlags), WrapNameInColorAndIcons(sourceName, nil, sourceFlags), ccBreakSpellLink), 'console')
	RemoveUnitFromControlledList(destGUID)
end

local function CrowdControl_OnAuraRemovedEvent(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if not UnitIsControlled(destGUID) then return end -- Unit not being controlled
	if not ADDON:IsSpellInCategory(spellID, 'Crowd Control') then return end -- Wasn't a CC spell being removed
	local name, flags, timeStamp = RemoveUnitFromControlledList(destGUID)
	local spellLink = GetSpellLink(spellID)
	local ccBreakSpellLink = GetSpellLink(AUTO_ATTACK_SPELLID)
	if name then -- Someone broke the crowd control effect, report that information
		AstralSendMessage(strformat(CONSOLE_MSG_CROWD_BREAK, spellLink, WrapNameInColorAndIcons(destName, destFlags, destRaidFlags), WrapNameInColorAndIcons(name, nil, flags), ccBreakSpellLink), 'console')
	else
		AstralSendMessage(strformat(CONSOLE_MSG_CROWD_EXPIRE, spellLink, WrapNameInColorAndIcons(destName, destFlags, destRaidFlags)), 'console')
	end
end

local function CrowdControl_OnAuraRefresh(timeStamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, param13, param14, param15, param16, param17)
	if not UnitIsControlled(destGUID) then return end
	if not ADDON:IsSpellInCategory(spellID, 'Crowd Control') then return end

	local spellLink = GetSpellLink(spellID)
	ADDON:GetSubEventMethod('SPELL_AURA_APPLIED', spellID)(sourceName, sourceRaidFlags, spellLink, destName, destFlags, destRaidFlags)
end


CombatEvents:RegisterSubEventMethod('SWING_DAMAGE', 'Crowd_OnSwingDamage', CrowdControl_OnDamageEvent)
CombatEvents:RegisterSubEventMethod('SPELL_PERIODIC_DAMAGE', 'Crowd_OnPeriodicDamage', CrowdControl_OnDamageEvent)
CombatEvents:RegisterSubEventMethod('SPELL_DAMAGE', 'Crowd_OnSpellDamage', CrowdControl_OnDamageEvent)
CombatEvents:RegisterSubEventMethod('SPELL_AURA_BROKEN_SPELL', 'Crowd_OnAuraBrokenSpell', CrowdControl_OnAuraBreakSpell)
CombatEvents:RegisterSubEventMethod('RANGE_DAMAGE', 'Crowd_OnRangeDamage', CrowdControl_OnDamageEvent)
CombatEvents:RegisterSubEventMethod('SPELL_AURA_REMOVED', 'Crowd_AuraRemoved', CrowdControl_OnAuraRemovedEvent)
CombatEvents:RegisterSubEventMethod('SPELL_AURA_REFRESH', 'Crowd_AuraRefreshed', CrowdControl_OnAuraRefresh)
CombatEvents:RegisterSubEventMethod('SPELL_AURA_APPLIED', 'Crowd_AuraApplied', CrowdControl_OnAuraApplied)