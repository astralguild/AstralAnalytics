local ADDON_NAME, ADDON = ...
local strformat = string.format
ADDON.a = _G['AstralEngine']
local RAID_TARGET_BIT = {}
RAID_TARGET_BIT[1] = 1
RAID_TARGET_BIT[2] = 2
RAID_TARGET_BIT[4] = 3
RAID_TARGET_BIT[8] = 4
RAID_TARGET_BIT[16] = 5
RAID_TARGET_BIT[32] = 6
RAID_TARGET_BIT[64] = 7
RAID_TARGET_BIT[128] = 8

ADDON.COLOURS = {}
ADDON.COLOURS.TARGET = 'FFFF0000'
ADDON.COLOURS.ADDON =  '008888FF'
ADDON.ADDON_NAME_COLOURED = WrapTextInColorCode('[AA]', ADDON.COLOURS.ADDON)

local uiScale
local mult

function AstralSendMessage(msg, channel)
	if not msg or type(msg) ~= 'string' then
		error('ADDON:SendMessage(msg, channel) msg expected, got ' .. type(msg))
	end

	local channel = channel or AstralAnalytics.options.general.reportChannel
	if channel == 'smart' then
		channel= IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and 'INSTANCE_CHAT' or IsInRaid() and 'RAID' or 'PARTY'
	end
	if channel == 'console' then
		print(strformat('%s %s', ADDON.ADDON_NAME_COLOURED, msg))
	else
		SendChatMessage(msg, channel)
	end
end

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
	local class 
	if not unit:find('<') then
		class = class or select(2, UnitClass(unit))
	else
		class = select(2, UnitClass(unit:match('<(%w+)>')))
	end
	local nameColor = hexColor ~= 'nil' and hexColor  or select(4, GetClassColor(class)) -- Hex color code
	if not nameColor then
		if AstralAnalytics.options.general.raidIcons then
			return strformat('%s %s %s', icon, unit, icon)
		else
			return unit
		end
	else
		if AstralAnalytics.options.general.raidIcons then
			return strformat('%s %s %s', icon, WrapTextInColorCode(unit, nameColor), icon)
		else
			return WrapTextInColorCode(unit, nameColor)
		end
	end
end

function ADDON:ColouredName(unit, class, hexColor)
	if not unit or type(unit) ~= 'string' then
		error('unit expected, got ' .. type(unit))
	end
	local class = class or select(2, UnitClass(unit))
	local nameColor = hexColor or select(4, GetClassColor(class)) -- Hex color code
	if not nameColor then
		return unit
	else
		return WrapTextInColorCode(unit, nameColor)
	end
end

function ADDON:SetUIScale()
	self.screenHeight = UIParent:GetHeight()
	self.scale = string.match( GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" )
	uiScale = UIParent:GetScale()
	mult = 768/self.scale/uiScale
end

function ADDON:Scale(x)
	return mult * floor(x/mult+.5)
end

local scanTool = CreateFrame( "GameTooltip", "AstralScanTool", nil, "GameTooltipTemplate" )
scanTool:SetOwner(WorldFrame, "ANCHOR_NONE" )
local scanText = _G["AstralScanToolTextLeft2"] -- This is the line with <[Player]'s Pet>

function ADDON:GetPetOwner(petName)
   AstralScanTool:ClearLines()
   AstralScanTool:SetUnit(petName)
   local ownerText = scanText:GetText()
   if not ownerText then return nil end
   local owner, _ = string.split("'",ownerText)
   
   return owner -- This is the pet's owner
end