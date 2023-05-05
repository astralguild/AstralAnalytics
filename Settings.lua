local ADDON_NAME, ADDON = ...

if not AstralAnalytics then
	AstralAnalytics = {}
end
if not AstralAnalytics.options then
	AstralAnalytics.options = {}
end
if not AstralAnalytics.spellIds then
	AstralAnalytics.spellIds = {}
end
if not AstralAnalytics.buffIds then
	AstralAnalytics.buffIds = {}
end
if not AstralAnalytics.scale then
	AstralAnalytics.scale = 1.0
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

	ADDON:AddDefaultSettings('reportLists', 'missingMark',
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddDefaultSettings('reportLists', 'missingBronze',
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
	ADDON:AddDefaultSettings('combatEvents', 'Interrupts', 
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
	ADDON:AddDefaultSettings('combatEvents', 'Taunt', 
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
	ADDON:AddDefaultSettings('combatEvents', 'Targeted Utility', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Misdirects', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Group Utility', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Raid Defensives', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Bloodlust', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'AoE Stops', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'AoE Control', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Externals', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Slows', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Major Defensives', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})
	ADDON:AddDefaultSettings('combatEvents', 'Toys', 
		{
		reportChannel = 'console',
		isEnabled = true,
		})

	ADDON:AddOptionCategory('Combat Events')
	ADDON:AddOption('Combat Events', 'Announce taunts', 'Taunt', AstralAnalytics.options.combatEvents.Taunt.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce interrupts', 'Interrupts', AstralAnalytics.options.combatEvents.Interrupts.isEnabled)
	ADDON:AddOption('Combat Events', 'Say own interrupts to group', 'selfInterrupt', AstralAnalytics.options.combatEvents.selfInterrupt.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce missed interrupts', 'missedInterrupts', AstralAnalytics.options.combatEvents.missedInterrupts.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce combat ressurection', 'Battle Res', AstralAnalytics.options.combatEvents['battleRes'].isEnabled)
	ADDON:AddOption('Combat Events', 'Announce CC casts', 'crowd', AstralAnalytics.options.combatEvents.crowd.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce CC breaks', 'cc_break', AstralAnalytics.options.combatEvents.cc_break.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce dispells', 'dispell', AstralAnalytics.options.combatEvents.dispell.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce targeted utility', 'Targeted Utility', AstralAnalytics.options.combatEvents['Targeted Utility'].isEnabled)
	ADDON:AddOption('Combat Events', 'Announce misdirects', 'Misdirects', AstralAnalytics.options.combatEvents.Misdirects.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce non-targeted utility', 'Group Utility', AstralAnalytics.options.combatEvents['Group Utility'].isEnabled)
	ADDON:AddOption('Combat Events', 'Announce Raid Defensives', 'Raid Defensives', AstralAnalytics.options.combatEvents['Raid Defensives'].isEnabled)
	ADDON:AddOption('Combat Events', 'Announce Bloodlust casts', 'Bloodlust', AstralAnalytics.options.combatEvents.Bloodlust.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce AoE Stops', 'AoE Stops', AstralAnalytics.options.combatEvents['AoE Stops'].isEnabled)
	ADDON:AddOption('Combat Events', 'Announce AoE Control', 'AoE Control', AstralAnalytics.options.combatEvents['AoE Control'].isEnabled)	
	ADDON:AddOption('Combat Events', 'Announce External Defensives', 'Externals', AstralAnalytics.options.combatEvents.Externals.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce Slows', 'Slows', AstralAnalytics.options.combatEvents.Slows.isEnabled)
	ADDON:AddOption('Combat Events', 'Announce Major Defensives', 'Major Defensives', AstralAnalytics.options.combatEvents['Major Defensives'].isEnabled)
	ADDON:AddOption('Combat Events', 'Announce toys', 'Toys', AstralAnalytics.options.combatEvents['Toys'].isEnabled)

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
	ADDON:AddOption('Buffs to report', 'Announce Mark of the Wild', 'missingMark', AstralAnalytics.options.reportLists.missingMark.isEnabled)
	ADDON:AddOption('Buffs to report', 'Announce Blessing of the Bronze', 'missingBronze', AstralAnalytics.options.reportLists.missingBronze.isEnabled)
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
			optionsMenu:AddEntry(entry, cat)
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

	AstralAnalytics.options.combatEvents.misdirects = nil
end


AAEvents:Register('ADDON_LOADED', LoadDefaultSettings, 'LoadDefaultSettings')