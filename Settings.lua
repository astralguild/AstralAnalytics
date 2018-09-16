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