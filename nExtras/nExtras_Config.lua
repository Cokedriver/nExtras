nExtras = {
	autogreed = {
		enable = true,			-- Enables Auto Disenchant module.
		disenchant = true,		-- if true Auto Disenchant on Green any level. If false Auto Disenchant on Green at MAX LEVEL.
	},
	macros = {					-- allows macros up to 1023.
		enable = false,			-- enables macro module.
	},
	merchant = {
		enable = true,			-- enable merchant module.
		sellMisc = true, 		-- allows the user to add spacific items to sell at merchant (please see the local filter in merchant.lua)
		autoSellGrey = true,	-- autosell grey items at merchant.
		autoRepair = true,		-- autorepair at merchant.
	},
	hyperlink = {				-- adds a mouseover to linked items in chat.
		enable = true,
	},
	quest = {
		enable = true,			-- enable quest module.
		autocomplete = true,	-- Enable the autoaccept quest and autocomplete quest if no reward.
	},
	selfbuffs = {
		enable = true,			-- enable selbuffs module.
		sound = true,			-- sound warning
	},	
}