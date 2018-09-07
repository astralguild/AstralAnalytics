local _, ADDON = ...

local addon = LibStub("AceAddon-3.0"):NewAddon("AstralOverseer", "AceConsole-3.0")

local AstralOverseerLDB = LibStub("LibDataBroker-1.1"):NewDataObject("AstralOverseer", {
	type = "data source",
	text = "AstralOverseer",
	icon = 801132,
	OnClick = function() ADDON:ToggleMainWindow() end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Astral Overseer")
	end,
})

ADDON.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("AstralOverseerMinimap", {
		profile = {
			minimap = {
				hide = not true --AstralOverseerSettings.optoins.showMiniMap,
			},
		},
	})
	ADDON.icon:Register("AstralOverseer", AstralOverseerLDB, self.db.profile.minimap)
end