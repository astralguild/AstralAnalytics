local ADDON_NAME, ADDON = ...

if not AstralAnalytics then
	AstralAnalytics = {
		['options'] = {
			['frame'] = {
			['locked'] = false,
			},
			['general'] = {
				['raidIcons' ] = true,
				['reportChannel'] = 'console',
				['autoReport'] = true,
			},
			['combatEvents'] = {
				['interrupts'] = true,
				['selfInterrupt'] = true,
				['crowd'] = true,
				['cc_break'] = true,
				['taunt'] = true,
				['battleRes'] = true,
				['dispell'] = true,
				['removeEnrage'] = true,
				['utilityT'] = true,
				['utilityNT'] = true,
				['heroism'] = true,
				},
			['buffsReported'] = {
				['missingFood'] = true,
				['missingInt'] = true,
				['missingFort'] = true,
				['missingShout'] = true,
				['missingFlask'] = true,
				['missingRune'] = true,
				['missingVantus'] = true,
			},
			['group'] = {
				[1] = true,
				[2] = true,
				[3] = true,
				[4] = true,
				[5] = true,
				[6] = true,
				[7] = true,
				[8] = true,
			},
		},
	}
end

ADDON.OPTIONS = {}

function ADDON:AddOptionCategory(category)
	self.OPTIONS[category] = {}
end

function ADDON:AddOption(category, label, dataPoint, initValue)
	table.insert(self.OPTIONS[category], {label = label, option = dataPoint, value = initValue})
end

--[[
ADDON:AddOptionCategory('Combat Events')
ADDON:AddOption('Combat Events', 'Report taunts', 'taunt', AstralAnalytics.options.combatEvents.taunt)
ADDON:AddOption('Combat Events', 'Report CC\'s Casts', 'cc_cast', AstralAnalytics.options.combatEvents.cc_cast)
ADDON:AddOption('Combat Events', 'Report CC\'s removed', 'cc_removed', AstralAnalytics.options.combatEvents.cc_removed)
ADDON:AddOption('Combat Events', 'Report dispells', 'dispell', AstralAnalytics.options.combatEvents.dispell)
ADDON:AddOption('Combat Events', 'Report enrage removals', 'removeEnrage', AstralAnalytics.options.combatEvents.removeEnrage)
ADDON:AddOption('Combat Events', 'Report targeted utility', 'utilityT', AstralAnalytics.options.combatEvents.utilityT)
ADDON:AddOption('Combat Events', 'Report non-targeted utility', 'utilityNT', AstralAnalytics.options.combatEvents.utilityNT)

ADDON:AddOptionCategory('General')
ADDON:AddOption('General', 'Enable Raid Icons', 'raidIcons', AstralAnalytics.options.raidIcons)
ADDON:AddOption('General', 'Report to Channel', 'reportChanneel', AstralAnalytics.options.reportChanneel)
ADDON:AddOption('General', 'Auto report on ready check', 'autoReport', AstralAnalytics.options.autoReport)

ADDON:AddOptionCategory('Buffs to report')
ADDON:AddOption('Buffs to report', 'Well Fed', 'food', AstralAnalytics.options.buffsReported.food)
ADDON:AddOption('Buffs to report', 'Arcane Intellect', 'int', AstralAnalytics.options.buffsReported.int)
ADDON:AddOption('Buffs to report', 'Fortitude', 'fort', AstralAnalytics.options.buffsReported.fort)
ADDON:AddOption('Buffs to report', 'Battle Shout', 'shout', AstralAnalytics.options.buffsReported.shout)
ADDON:AddOption('Buffs to report', 'Flask', 'flask', AstralAnalytics.options.buffsReported.flask)
ADDON:AddOption('Buffs to report', 'Augment Rune', 'rune', AstralAnalytics.options.buffsReported.rune)
ADDON:AddOption('Buffs to report', 'Vantus Rune', 'vantus', AstralAnalytics.options.buffsReported.vantus)
]]