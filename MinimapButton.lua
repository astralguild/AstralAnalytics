local _, ADDON = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralAnalytics", "AceConsole-3.0")

local AstralAnalyticsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralAnalytics", {
	type = "data source",
	text = "AstralAnalytics",
	icon = 801132,
	OnClick = function() ADDON:ToggleMainWindow() end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Astral Analytics")
	end,
})

ADDON.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AstralAnalyticsMinimap", {
		profile = {
			minimap = {
				hide = not true --AstralAnalyticsSettings.optoins.showMiniMap,
			},
		},
	})
	ADDON.icon:Register("AstralAnalytics", AstralAnalyticsLDB, self.db.profile.minimap)
end