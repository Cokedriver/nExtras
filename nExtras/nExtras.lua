local nExtras = LibStub("AceAddon-3.0"):NewAddon("nExtras", "AceEvent-3.0")
local L = setmetatable({}, { __index = function(t,k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })
------------------------------------------------------------------------
--	 nExtras Core Config
------------------------------------------------------------------------

local db
local defaults = {
	profile = {
	
		enable = true,

		fontSize = 15,
		flashgathernodes = true,
		
		-- Font Options
		font = {
			enable = true,			-- enable font module
		},
		
		-- Merchant Options
		merchant = {
			enable = true,			-- enable merchant module.
			sellMisc = true, 		-- allows the user to add spacific items to sell at merchant (please see the local filter in merchant.lua)
			autoSellGrey = true,	-- autosell grey items at merchant.
			autoRepair = true,		-- autorepair at merchant.
			gpay = false,			-- let your guild pay for your repairs if they allow.
		},
		
		-- Quest Options
		quest = {
			enable = true,			-- enable quest module.
			autocomplete = false,	-- enable the autoaccept quest and autocomplete quest if no reward.
		},
		
		vellum = {
			enable = true,
		},
		
		expires = {
			pve = true,
			pvp = true,
		},
	}
}

------------------------------------------------------------------------
--	 nExtras Functions
------------------------------------------------------------------------



function nExtras:OnInitialize()
	-- Assuming the .toc says ## SavedVariables: MyAddonDB
	self.db = LibStub("AceDB-3.0"):New("nEDB", defaults, true)
	db = self.db.profile
	
	if not db.enable then return end
	
	self:Fonts();
end

function nExtras:OnEnable()
	db = self.db.profile

	self:FlashGatherNods();
	self:Merchant();
	self:Vellum();
end

function nExtras:Fonts()
	--------------------
	-- Change Game Font
	--------------------
	-- Credit Game Font goes to Elv for his ElvUI project.
	-- You can find his Addon at http://tukui.org/dl.php
	-- Editied by Cokedriver
	
	if db.font.enable ~= true then return end

	local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
		obj:SetFont(font, size, style)
		if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
		if sox and soy then obj:SetShadowOffset(sox, soy) end
		if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function()
	
		local NORMAL 		= [[Interface\AddOns\nExtras\Media\NORMAL.ttf]]
		local BOLD 			= [[Interface\AddOns\nExtras\Media\BOLD.ttf]]
		local BOLDITALIC 	= [[Interface\AddOns\nExtras\Media\ITALIC.ttf]]
		local ITALIC 		= [[Interface\AddOns\nExtras\Media\BOLDITALIC.ttf]]
		local NUMBER 		= [[Interface\AddOns\nExtras\Media\NORMAL.ttf]]	


		UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 15
		CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

		UNIT_NAME_FONT     = NORMAL
		DAMAGE_TEXT_FONT   = NUMBER
		STANDARD_TEXT_FONT = NORMAL

		-- Base fonts
		SetFont(AchievementFont_Small,                BOLD, db.fontSize)
		SetFont(FriendsFont_Large,                  NORMAL, db.fontSize, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(FriendsFont_Normal,                 NORMAL, db.fontSize, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(FriendsFont_Small,                  NORMAL, db.fontSize, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(FriendsFont_UserText,               NUMBER, db.fontSize, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(GameTooltipHeader,                    BOLD, db.fontSize, "OUTLINE")
		SetFont(GameFont_Gigantic,                    BOLD, 32, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(InvoiceFont_Med,                    ITALIC, db.fontSize, nil, 0.15, 0.09, 0.04)
		SetFont(InvoiceFont_Small,                  ITALIC, db.fontSize, nil, 0.15, 0.09, 0.04)
		SetFont(MailFont_Large,                     ITALIC, db.fontSize, nil, 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
		SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, db.fontSize, "OUTLINE")
		SetFont(NumberFont_Outline_Huge,            NUMBER, 30, "THICKOUTLINE", 30)
		SetFont(NumberFont_Outline_Large,           NUMBER, 17, "OUTLINE")
		SetFont(NumberFont_Outline_Med,             NUMBER, db.fontSize, "OUTLINE")
		SetFont(NumberFont_Shadow_Med,              NORMAL, db.fontSize)
		SetFont(NumberFont_Shadow_Small,            NORMAL, db.fontSize)
		SetFont(QuestFont_Shadow_Small,             NORMAL, 14)
		SetFont(QuestFont_Large,                    NORMAL, 16)
		SetFont(QuestFont_Shadow_Huge,                BOLD, 19, nil, nil, nil, nil, 0.54, 0.4, 0.1)
		SetFont(QuestFont_Super_Huge,                 BOLD, 24)
		SetFont(ReputationDetailFont,                 BOLD, db.fontSize, nil, nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(SpellFont_Small,                      BOLD, 14)
		SetFont(SystemFont_InverseShadow_Small,       BOLD, db.fontSize)
		SetFont(SystemFont_Large,                   NORMAL, 17)
		SetFont(SystemFont_Med1,                    NORMAL, 14)
		SetFont(SystemFont_Med2,                    ITALIC, db.fontSize, nil, 0.15, 0.09, 0.04)
		SetFont(SystemFont_Med3,                    NORMAL, db.fontSize)
		SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 22, "THICKOUTLINE")
		SetFont(SystemFont_OutlineThick_Huge4,  BOLDITALIC, 27, "THICKOUTLINE")
		SetFont(SystemFont_OutlineThick_WTF,    BOLDITALIC, 31, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
		SetFont(SystemFont_Outline_Small,           NUMBER, db.fontSize, "OUTLINE")
		SetFont(SystemFont_Shadow_Huge1,              BOLD, 20)
		SetFont(SystemFont_Shadow_Huge3,              BOLD, 25)
		SetFont(SystemFont_Shadow_Large,            NORMAL, 17)
		SetFont(SystemFont_Shadow_Med1,             NORMAL, db.fontSize)
		SetFont(SystemFont_Shadow_Med2,             NORMAL, db.fontSize)
		SetFont(SystemFont_Shadow_Med3,             NORMAL, db.fontSize)
		SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 22, "OUTLINE")
		SetFont(SystemFont_Shadow_Small,              BOLD, 14)
		SetFont(SystemFont_Small,                   NORMAL, 14)
		SetFont(SystemFont_Tiny,                    NORMAL, 12)
		SetFont(Tooltip_Med,                        NORMAL, db.fontSize)
		SetFont(Tooltip_Small,                        BOLD, 14)
		SetFont(ChatBubbleFont,						NORMAL, db.fontSize)
		

		-- Derived fonts
		SetFont(BossEmoteNormalHuge,     BOLDITALIC, 27, "THICKOUTLINE")
		SetFont(CombatTextFont,              NORMAL, 26)
		SetFont(ErrorFont,                   ITALIC, 16, nil, 60)
		SetFont(QuestFontNormalSmall,          BOLD, db.fontSize, nil, nil, nil, nil, 0.54, 0.4, 0.1)
		SetFont(WorldMapTextFont,        BOLDITALIC, 31, "THICKOUTLINE",  40, nil, nil, 0, 0, 0, 1, -1)

		for i=1,7 do
			local f = _G["ChatFrame"..i]
			local font, size = f:GetFont()
			f:SetFont(NORMAL, size)
		end

		-- I have no idea why the channel list is getting fucked up
		-- but re-setting the font obj seems to fix it
		for i=1,MAX_CHANNEL_BUTTONS do
			local f = _G["ChannelButton"..i.."Text"]
			f:SetFontObject(GameFontNormalSmallLeft)
			-- function f:SetFont(...) error("Attempt to set font on ChannelButton"..i) end
		end

		for _,butt in pairs(PaperDollTitlesPane.buttons) do butt.text:SetFontObject(GameFontHighlightSmallLeft) end

	end)
end

function nExtras:Merchant()
	------------
	-- Merchant
	------------
	-- Credit for Merchant goes to Tuks for his Tukui project.
	-- You can find his Addon at http://tukui.org/dl.php
	-- Editied by Cokedriver
	
	if db.merchant.enable ~= true then return end
	
	local MerchantFilter = {
		[6289]  = true, -- Raw Longjaw Mud Snapper
		[6291]  = true, -- Raw Brilliant Smallfish
		[6308]  = true, -- Raw Bristle Whisker Catfish
		[6309]  = true, -- 17 Pound Catfish
		[6310]  = true, -- 19 Pound Catfish
		[41808] = true, -- Bonescale Snapper
		[42336] = true, -- Bloodstone Band
		[42337] = true, -- Sun Rock Ring
		[43244] = true, -- Crystal Citrine Necklace
		[43571] = true, -- Sewer Carp
		[43572] = true, -- Magic Eater		
	}

	local Merchant_Frame = CreateFrame("Frame")
	Merchant_Frame:SetScript("OnEvent", function()
		if db.merchant.autoSellGrey or db.merchant.sellMisc then
			local Cost = 0
			
			for Bag = 0, 4 do
				for Slot = 1, GetContainerNumSlots(Bag) do
					local Link, ID = GetContainerItemLink(Bag, Slot), GetContainerItemID(Bag, Slot)
					
					if (Link and ID) then
						local Price = 0
						local Mult1, Mult2 = select(11, GetItemInfo(Link)), select(2, GetContainerItemInfo(Bag, Slot))
						
						if (Mult1 and Mult2) then
							Price = Mult1 * Mult2
						end
						
						if (db.merchant.autoSellGrey and select(3, GetItemInfo(Link)) == 0 and Price > 0) then
							UseContainerItem(Bag, Slot)
							PickupMerchantItem()
							Cost = Cost + Price
						end
						
						if db.merchant.sellMisc and MerchantFilter[ID] then
							UseContainerItem(Bag, Slot)
							PickupMerchantItem()
							Cost = Cost + Price
						end
					end
				end
			end
			
			if (Cost > 0) then
				local Gold, Silver, Copper = math.floor(Cost / 10000) or 0, math.floor((Cost % 10000) / 100) or 0, Cost % 100
				
				DEFAULT_CHAT_FRAME:AddMessage("Your grey item's have been sold for".." |cffffffff"..Gold.."|cffffd700g|r".." |cffffffff"..Silver.."|cffc7c7cfs|r".." |cffffffff"..Copper.."|cffeda55fc|r"..".",255,255,0)
			end
		end
		
		if (not IsShiftKeyDown()) then
			if (CanMerchantRepair() and db.merchant.autoRepair) then
				local Cost, Possible = GetRepairAllCost()
				
				if (Cost > 0) then
					if (IsInGuild() and db.merchant.UseGuildRepair) then
						local CanGuildRepair = (CanGuildBankRepair() and (Cost <= GetGuildBankWithdrawMoney()))
						
						if CanGuildRepair then
							RepairAllItems(1)
							
							return
						end
					end
					
					if Possible then
						RepairAllItems()
						
						local Copper = Cost % 100
						local Silver = math.floor((Cost % 10000) / 100)
						local Gold = math.floor(Cost / 10000)
						if guildRepairFlag == 1 then
							DEFAULT_CHAT_FRAME:AddMessage("Your guild payed".." |cffffffff"..Gold.."|cffffd700g|r".." |cffffffff"..Silver.."|cffc7c7cfs|r".." |cffffffff"..Copper.."|cffeda55fc|r".." to repair your gear.",255,255,0)
						else
							DEFAULT_CHAT_FRAME:AddMessage("You payed".." |cffffffff"..Gold.."|cffffd700g|r".." |cffffffff"..Silver.."|cffc7c7cfs|r".." |cffffffff"..Copper.."|cffeda55fc|r".." to repair your gear.",255,255,0)
						end
					else
						DEFAULT_CHAT_FRAME:AddMessage(L.Merchant.NotEnoughMoney, 255, 0, 0)
					end
				end
			end
		end		
	end)
	Merchant_Frame:RegisterEvent("MERCHANT_SHOW")
end


function nExtras:Vellum()

	if db.vellum.enable ~= true then return end

	-- This is Velluminous from Tekkub
	-- You can find the main addon at https://github.com/TekNoLogic/Velluminous
	------------------------------------------------------------------------------------

	if not TradeSkillFrame then
		print("What the fuck?  Velluminous cannot initialize.  BAIL!  BAIL!  BAIL!")
		return
	end


	local butt = CreateFrame("Button", nil, TradeSkillCreateButton, "SecureActionButtonTemplate")
	butt:SetAttribute("type", "macro")
	butt:SetAttribute("macrotext", "/click TradeSkillCreateButton\n/use item:38682")

	butt:SetText("Vellum")

	butt:SetPoint("RIGHT", TradeSkillCreateButton, "LEFT")

	butt:SetWidth(80) butt:SetHeight(22)

	-- Fonts --
	butt:SetDisabledFontObject(GameFontDisable)
	butt:SetHighlightFontObject(GameFontHighlight)
	butt:SetNormalFontObject(GameFontNormal)

	-- Textures --
	butt:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	butt:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	butt:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
	butt:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	butt:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
	butt:GetHighlightTexture():SetBlendMode("ADD")

	local hider = CreateFrame("Frame", nil, TradeSkillCreateAllButton)
	hider:SetScript("OnShow", function() butt:Hide() end)
	hider:SetScript("OnHide", function() butt:Show() end)
	------------------------------------------------------------------------------------
end


function nExtras:FlashGatherNods()
	if (IsAddOnLoaded('Zygor Guides Viewer 4')) then return end

	
	function AssignButtonTexture(obj,tx,num,total)
		self.ChainCall(obj):SetNormalTexture(CreateTexWithCoordsNum(obj,tx,num,total,1,4))
			:SetPushedTexture(CreateTexWithCoordsNum(obj,tx,num,total,2,4))
			:SetHighlightTexture(CreateTexWithCoordsNum(obj,tx,num,total,3,4))
			:SetDisabledTexture(CreateTexWithCoordsNum(obj,tx,num,total,4,4))
	end

	function self.ChainCall(obj)  local T={}  setmetatable(T,{__index=function(self,fun)  if fun=="__END" then return obj end  return function(self,...) assert(obj[fun],fun.." missing in object") obj[fun](obj,...) return self end end})  return T  end

	local flash_interval = 0.25

	local flash = nil
	local MinimapNodeFlash = function(s)
		flash = not flash
		Minimap:SetBlipTexture("Interface\\AddOns\\nExtras\\Media\\objecticons_"..(flash and "on" or "off"))
	end

	local q = 0
	do
		local flashFrame = CreateFrame("FRAME","PointerExtraFrame")
		local ant_last=GetTime()
		local flash_last=GetTime()
		flashFrame:SetScript("OnUpdate",function(self,elapsed)
			local t=GetTime()

			-- Flashing node dots. Prettier than the standard, too. And slightly bigger.
			if db.flashgathernodes then
				if t-flash_last>=flash_interval then
					MinimapNodeFlash()
					flash_last=t-(t-flash_last)%flash_interval
				end
			else
				Minimap:SetBlipTexture("Interface\\AddOns\\nExtras\\Media\\objecticons_on")		
			end
		end)

		flashFrame:SetPoint("CENTER",UIParent)
		flashFrame:Show()
		self.ChainCall(flashFrame:CreateTexture("PointerDotOn","OVERLAY")) :SetTexture("Interface\\AddOns\\nExtras\\Media\\objecticons_on") :SetSize(50,50) :SetPoint("CENTER") :SetNonBlocking(true) :Show()
		self.ChainCall(flashFrame:CreateTexture("PointerDotOff","OVERLAY")) :SetTexture("Interface\\AddOns\\nExtras\\Media\\objecticons_off") :SetSize(50,50) :SetPoint("RIGHT") :SetNonBlocking(true) :Show()
	end
end