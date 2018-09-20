local ADDON_NAME, ADDON = ...

if not AstralAnalytics then
	AstralAnalytics = {}
	AstralAnalytics.options = {}
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
	ADDON:AddDefaultSettings('general', 'raidIcons', true)
	ADDON:AddDefaultSettings('general', 'autoAnnounce', true)
	ADDON:AddDefaultSettings('general', 'announceChannel', 'console')

	-- Default Groups selected to track
	for i = 1, 8 do
		ADDON:AddDefaultSettings('group', i, true)
	end

	-- Default settings for report options
	ADDON:AddDefaultSettings('reportLists', 'lowFlaskTime', 
		{
		reportChannel = 'console', 
		isEnabled = true
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
		isEnabled = true
		})

	ADDON:AddDefaultSettings('reportLists', 'missingShout', 
		{
		reportChannel = 'console', 
		isEnabled = true
		})

	ADDON:AddDefaultSettings('reportLists', 'missingRune', 
		{
		reportChannel = 'console', 
		isEnabled = true
		})

	ADDON:AddDefaultSettings('reportLists', 'missingVantus', 
		{
		reportChannel = 'console', 
		isEnabled = true
		})

	ADDON:AddDefaultSettings('reportLists', 'missingInt', 
		{
		reportChannel = 'console', 
		isEnabled = true
		})

	-- Default combat event settings
	ADDON:AddDefaultSettings('combatEvents', 'interrupts', true)
	ADDON:AddDefaultSettings('combatEvents', 'selfInterrupt', true)
	ADDON:AddDefaultSettings('combatEvents', 'crowd', true)
	ADDON:AddDefaultSettings('combatEvents', 'cc_break', true)
	ADDON:AddDefaultSettings('combatEvents', 'taunt', true)
	ADDON:AddDefaultSettings('combatEvents', 'battleRes', true)
	ADDON:AddDefaultSettings('combatEvents', 'dispell', true)
	ADDON:AddDefaultSettings('combatEvents', 'removeEnrage', true)
	ADDON:AddDefaultSettings('combatEvents', 'utilityT', true)
	ADDON:AddDefaultSettings('combatEvents', 'utilityNT', true)
	ADDON:AddDefaultSettings('combatEvents', 'heroism', true)
	ADDON:AddDefaultSettings('combatEvents', 'missedInterrupts', true)

	ADDON:AddOptionCategory('Combat Events')
	ADDON:AddOption('Combat Events', 'Report taunts', 'taunt', AstralAnalytics.options.combatEvents.taunt)
	ADDON:AddOption('Combat Events', 'Report interrupts', 'interrupts', AstralAnalytics.options.combatEvents.interrupts)
	ADDON:AddOption('Combat Events', 'Report own interrupts', 'selfInterrupt', AstralAnalytics.options.combatEvents.selfInterrupt)
	ADDON:AddOption('Combat Events', 'Report combat ressurection', 'battleRes', AstralAnalytics.options.combatEvents.battleRes)
	ADDON:AddOption('Combat Events', 'Report CC casts', 'crowd', AstralAnalytics.options.combatEvents.crowd)
	ADDON:AddOption('Combat Events', 'Report CC breaks', 'cc_removed', AstralAnalytics.options.combatEvents.cc_break)
	ADDON:AddOption('Combat Events', 'Report dispells', 'dispell', AstralAnalytics.options.combatEvents.dispell)
	ADDON:AddOption('Combat Events', 'Report enrage removals', 'removeEnrage', AstralAnalytics.options.combatEvents.removeEnrage)
	ADDON:AddOption('Combat Events', 'Report targeted utility', 'utilityT', AstralAnalytics.options.combatEvents.utilityT)
	ADDON:AddOption('Combat Events', 'Report non-targeted utility', 'utilityNT', AstralAnalytics.options.combatEvents.utilityNT)
	ADDON:AddOption('Combat Events', 'Report Heroism casts', 'heroism', AstralAnalytics.options.combatEvents.heroism)

	ADDON:AddOptionCategory('General')
	ADDON:AddOption('General', 'Enable Raid Icons', 'raidIcons', AstralAnalytics.options.general.raidIcons)
	ADDON:AddOption('General', 'Report to Channel', 'reportChannel', AstralAnalytics.options.general.reportChannel)
	ADDON:AddOption('General', 'Auto report on ready check', 'autoReport', AstralAnalytics.options.general.autoReport)
	ADDON:AddOption('General', 'Sub groups', 'group', AstralAnalytics.options.general.group)

	ADDON:AddOptionCategory('Buffs to report')
	ADDON:AddOption('Buffs to report', 'Well Fed', 'missingFood', AstralAnalytics.options.reportLists.missingFood)
	ADDON:AddOption('Buffs to report', 'Arcane Intellect', 'missingInt', AstralAnalytics.options.reportLists.missingInt)
	ADDON:AddOption('Buffs to report', 'Fortitude', 'missingFort', AstralAnalytics.options.reportLists.missingFort)
	ADDON:AddOption('Buffs to report', 'Battle Shout', 'missingShout', AstralAnalytics.options.reportLists.missingShout)
	ADDON:AddOption('Buffs to report', 'Flask', 'missingFlask', AstralAnalytics.options.reportLists.missingFlask)
	ADDON:AddOption('Buffs to report', 'Augment Rune', 'missingRune', AstralAnalytics.options.reportLists.missingRune)
	ADDON:AddOption('Buffs to report', 'Vantus Rune', 'missingVantus', AstralAnalytics.options.reportLists.missingVantus)

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
	aa_dropdown_sub.dtbl[4].channel = 'smart'
	aa_dropdown_sub.dtbl[5]:SetText('Officer')
	aa_dropdown_sub.dtbl[5].channel = 'OFFICER'
	aa_dropdown_sub.dtbl[6]:SetText('Personal')
	aa_dropdown_sub.dtbl[6].channel = 'console'

	aa_dropdown_sub:UpdateChannels()

	for i = 1, 8 do
		aa_dropdown_subGroups.dtbl[i].isChecked = AstralAnalytics.options['group'][i]
	end
	aa_dropdown_subGroups:UpdateGroups()
	AAEvents:Unregister('ADDON_LOADED', 'LoadDefaultSettings')
end


AAEvents:Register('ADDON_LOADED', LoadDefaultSettings, 'LoadDefaultSettings')