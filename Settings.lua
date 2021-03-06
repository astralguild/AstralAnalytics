local ADDON_NAME, ADDON = ...

if not AstralAnalytics then
	AstralAnalytics = {}
	AstralAnalytics.options = {}
	AstralAnalytics.last_spellID_searched = 0
end

function ADDON:AddDefaultSettings(category, name, data)
	if not category or type(category) ~= 'string' then
		error('AddDefaultSettings(category, name, data) category: string expected, received ' .. type(category))
	end
	if data == nil then
		error('AddDefaultSettings(data, name, data) data expected, received ' .. type(data))
	end

	if not AstralAnalytics.options[category] then
		AstralAnalytics.options[category] = {}
	end

	if not AstralAnalytics.options[category][name] then
		AstralAnalytics.options[category][name] = data
	else
		if type(data) == 'table' then
			for newKey, newValue in pairs(data) do
				local found = false
				for oldKey in pairs(AstralAnalytics.options[category][name]) do
					if oldKey == newKey then
						found = true
						break
					end
				end

				if not found then
					AstralAnalytics.options[category][name][newKey] = newValue
				end
			end
		end
	end
end

ADDON.OPTIONS = {}
function ADDON:AddOptionCategory(category)
	self.OPTIONS[category] = {}
end

function ADDON:AddOption(category, label, dataPoint, initValue)
	table.insert(self.OPTIONS[category], {label = label, option = dataPoint, value = initValue})
end

local function LoadDefaultSettings(addon)
	if addon ~= ADDON_NAME then return end
	ADDON:SetUIScale()

	-- Default Frame options
	ADDON:AddDefaultSettings('frame', 'locked', true)

	-- Default General Options
	ADDON:AddDefaultSettings('general', 'raidIcons', 
		{
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('general', 'autoAnnounce', 
		{
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('general', 'announceOwnGuild',
	{
		isEnabled = true,
	})
	ADDON:AddDefaultSettings('general', 'announceChannel', 'console')

	-- Default Groups selected to track
	for i = 1, 8 do
		ADDON:AddDefaultSettings('group', i, 
		{
		isEnabled = true,
		})
	end

	-- Default settings for report options
	ADDON:AddDefaultSettings('reportLists', 'lowFlaskTime',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingFood',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingFort',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingFlask',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingShout',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingRune',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingVantus',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingInt',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	-- Default combat event settings
	ADDON:AddDefaultSettings('combatEvents', 'interrupts', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'missedInterrupts', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'selfInterrupt', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'crowd', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'cc_break', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'taunt', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'battleRes', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'dispell', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'removeEnrage', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'utilityT', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'utilityNT', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'heroism', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddOptionCategory('Combat Events')
	ADDON:AddOption('Combat Events', 'Announce taunts', 'taunt', AstralAnalytics.options.combatEvents.taunt.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce interrupts', 'interrupts', AstralAnalytics.options.combatEvents.interrupts.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce own interrupts', 'selfInterrupt', AstralAnalytics.options.combatEvents.selfInterrupt.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce missed interrupts', 'missedInterrupts', AstralAnalytics.options.combatEvents.missedInterrupts.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce combat ressurection', 'battleRes', AstralAnalytics.options.combatEvents.battleRes.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce CC casts', 'crowd', AstralAnalytics.options.combatEvents.crowd.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce CC breaks', 'cc_removed', AstralAnalytics.options.combatEvents.cc_break.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce dispells', 'dispell', AstralAnalytics.options.combatEvents.dispell.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce enrage removals', 'removeEnrage', AstralAnalytics.options.combatEvents.removeEnrage.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce targeted utility', 'utilityT', AstralAnalytics.options.combatEvents.utilityT.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce non-targeted utility', 'utilityNT', AstralAnalytics.options.combatEvents.utilityNT.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce Heroism casts', 'heroism', AstralAnalytics.options.combatEvents.heroism.isEnabled)

	ADDON:AddOptionCategory('General')
	ADDON:AddOption('General', 'Wrap Names in Raid Icons', 'raidIcons', AstralAnalytics.options.general.raidIcons.isEnabled)
	ADDON:AddOption('General', 'Announce to Channel', 'announceChannel', AstralAnalytics.options.general.reportChannel)
	ADDON:AddOption('General', 'Announce on ready check', 'autoAnnounce', AstralAnalytics.options.general.autoAnnounce.isEnabled)
	ADDON:AddOption('General', 'Announce if in Guild Group', 'announceOwnGuild', AstralAnalytics.options.general.announceOwnGuild.isEnabled)
	ADDON:AddOption('General', 'Sub groups', 'group', AstralAnalytics.options.general.group)

	ADDON:AddOptionCategory('Buffs to report')
	ADDON:AddOption('Buffs to report', 'Announce Well Fed', 'missingFood', AstralAnalytics.options.reportLists.missingFood.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Arcane Intellect', 'missingInt', AstralAnalytics.options.reportLists.missingInt.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Fortitude', 'missingFort', AstralAnalytics.options.reportLists.missingFort.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Battle Shout', 'missingShout', AstralAnalytics.options.reportLists.missingShout.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Flask', 'missingFlask', AstralAnalytics.options.reportLists.missingFlask.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Augment Rune', 'missingRune', AstralAnalytics.options.reportLists.missingRune.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Vantus Rune', 'missingVantus', AstralAnalytics.options.reportLists.missingVantus.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Low Flask Time', 'lowFlaskTime', AstralAnalytics.options.reportLists.lowFlaskTime.isEnabled)

	for category, entries in pairs(ADDON.OPTIONS) do
		local cat
		if category == 'Combat Events' then
			cat = 'combatEvents'
		elseif category == 'Buffs to report' then
			cat = 'reportLists'
		elseif category == 'General' then
			cat = 'general'
		end

		for _, entry in pairs(entries) do
			aa_dropdown:AddEntry(entry, cat)
		end
	end

	aa_dropdown_sub.dtbl[1]:SetText('Say')
	aa_dropdown_sub.dtbl[1].channel = 'SAY'
	aa_dropdown_sub.dtbl[2]:SetText('Party')
	aa_dropdown_sub.dtbl[2].channel = 'PARTY'
	aa_dropdown_sub.dtbl[3]:SetText('Raid')
	aa_dropdown_sub.dtbl[3].channel = 'RAID'
	aa_dropdown_sub.dtbl[4]:SetText('Smart')
	aa_dropdown_sub.dtbl[4].channel = 'SMART'
	aa_dropdown_sub.dtbl[5]:SetText('Officer')
	aa_dropdown_sub.dtbl[5].channel = 'OFFICER'
	aa_dropdown_sub.dtbl[6]:SetText('Personal')
	aa_dropdown_sub.dtbl[6].channel = 'console'

	aa_dropdown_sub:UpdateChannels()

	for i = 1, 8 do
		aa_dropdown_subGroups.dtbl[i].isChecked = AstralAnalytics.options['group'][i].isEnabled
	end
	aa_dropdown_subGroups:UpdateGroups()
	AAEvents:Unregister('ADDON_LOADED', 'LoadDefaultSettings')
end


AAEvents:Register('ADDON_LOADED', LoadDefaultSettings, 'LoadDefaultSettings')