--[[ nExtras is just a few addons that i enjoy to use when I play WoW
the config will alow you to turn off any one of the addons you chose
not to use. All Credit for said addons are listed with them.]]

cfg = {

	-- Bigger TradeSkill UI
	['BTSUI'] = {
		['enable'] = true,
	},
	-- Chat Options
	['chat'] = {
		['enable'] = false,			-- enables !Beautycase border for chat
	},
	
	-- Crafting Bind On Pickup Options
	['CBOP'] = {
		["enable"] = true,
	},
	
	-- Font Options
	['font'] = {
		["enable"] = true,			-- enable font module
		["style"] = "Expressway",	-- style of font to use
		["size"] = 15,				-- size of font
	},
	
	-- Merchant Options
	['merchant'] = {
		['enable'] = true,			-- enable merchant module.
		['sellMisc'] = true, 		-- allows the user to add spacific items to sell at merchant (please see the local filter in merchant.lua)
		['autoSellGrey'] = true,	-- autosell grey items at merchant.
		['autoRepair'] = true,		-- autorepair at merchant.
		['gpay'] = false,			-- let your guild pay for your repairs if they allow.
	},
	
	-- Quest Options
	['quest'] = {
		['enable'] = true,			-- enable quest module.
		['autocomplete'] = false,	-- enable the autoaccept quest and autocomplete quest if no reward.
	},
	
	['vendor'] = {
		['enable'] = true,
	},
	
	['vellum'] = {
		['enable'] = true,
	},

}

local LSM = LibStub("LibSharedMedia-3.0")

--Register Media
LSM:Register("font", "Expressway", [[Interface\AddOns\nExtras\Media\Expressway.ttf]])

-- Load All SharedMedia
cfg.font.style = LSM:Fetch("font", cfg.font.style)

--------------
-- Chat Addon
--------------
if cfg.chat.enable then

	local _G = _G

	if (IsAddOnLoaded('!Beautycase')) then
		do	
			for i = 1, NUM_CHAT_WINDOWS do
				local cf = _G['ChatFrame'..i]
				if cf then
					cf:CreateBeautyBorder(12)
					cf:SetBeautyBorderPadding( 5, 5, 5, 5, 5, 8, 5, 8)
				end
			end
			
			local ct = _G['ChatFrame2']
			if ct then
				ct:CreateBeautyBorder(12)
				ct:SetBeautyBorderPadding(5, 29, 5, 29, 5, 8, 5, 8)
			end
		end
	end
end

---------------------------------------
-- Crafting Bind On Pickup Warning Box
---------------------------------------
-- Credit for CBOP goes to oscarucb for his BOP Craft Confirm addon.
-- You can find the original addon at http://www.wowace.com/addons/bopcraftconfirm/files/
-- Edited by Cokedriver

if cfg.CBOP.enable then

	local addonName, vars = ...
	nExtras = vars
	local addon = nExtras
	local settings

	local L = setmetatable({}, { __index = function(t,k)
		local v = tostring(k)
		rawset(t, k, v)
		return v
	end })

	local defaults = {
	  debug = false,
	  always = {
	  },
	}

	local function chatMsg(msg) 
		 DEFAULT_CHAT_FRAME:AddMessage(addonName..": "..msg)
	end
	local function debug(msg) 
	  if settings and settings.debug then
		 chatMsg(msg)
	  end
	end

	addon.scantt = CreateFrame("GameTooltip", addonName.."_Tooltip", UIParent, "GameTooltipTemplate")

	local function OnEvent(frame, event, name, ...)
	  if event == "ADDON_LOADED" and string.upper(name) == string.upper(addonName) then
		 debug("ADDON_LOADED: "..name)
		 nEDB = nEDB or {}
		 settings = nEDB
		 for k,v in pairs(defaults) do
		   if settings[k] == nil then
			 settings[k] = defaults[k]
		   end
		 end
	  end
	end
	local frame = CreateFrame("Button", addonName.."HiddenFrame", UIParent)
	frame:RegisterEvent("ADDON_LOADED");
	frame:SetScript("OnEvent", OnEvent);

	local blizzard_DoTradeSkill
	local save_idx, save_cnt, save_link
	local function bopcc_DoTradeSkill(idx,cnt)   
	   local link = GetTradeSkillItemLink(idx)
	   debug(link,idx,cnt)   

	   if not link then
		 blizzard_DoTradeSkill(idx,cnt)
		 return
	   end

	   local bop
	   addon.scantt:ClearLines()
	   addon.scantt:SetOwner(UIParent, "ANCHOR_NONE");
	   addon.scantt:SetHyperlink(link)
	   for i=1,addon.scantt:NumLines() do
		 local line = getglobal(addon.scantt:GetName() .. "TextLeft"..i)
		 local text = line and line:GetText()
		 if text and text:find(ITEM_BIND_ON_PICKUP) then
		   bop = ITEM_BIND_ON_PICKUP
		   break
		 elseif text and text:find(ITEM_BIND_TO_ACCOUNT) then
		   bop = ITEM_BIND_TO_ACCOUNT
		   break
		 elseif text and text:find(ITEM_BIND_TO_BNETACCOUNT) then
		   bop = ITEM_BIND_TO_BNETACCOUNT
		   break
		 elseif text and (text:find(ITEM_BIND_ON_USE) or text:find(ITEM_BIND_ON_EQUIP)) then
		   break
		 end
	   end

	   if settings and settings.always and settings.always[link] then
		  debug("Confirm suppressed: "..link)
		  bop = nil
	   end

	   if bop then
		 save_idx = idx
		 save_cnt = cnt
		 save_link = link
		 StaticPopupDialogs["BOPCRAFTCONFIRM_CONFIRM"].text =  
			save_link.."\n"..bop.."\n"..L["Crafting this item will bind it to you."]
		 StaticPopup_Show("BOPCRAFTCONFIRM_CONFIRM")
	   else
		 blizzard_DoTradeSkill(idx,cnt)
	   end
	end

	blizzard_DoTradeSkill = _G["DoTradeSkill"]
	_G["DoTradeSkill"] = bopcc_DoTradeSkill

	local function isValid()
	   if not save_idx or not save_link then return false end
	   local link = GetTradeSkillItemLink(save_idx)
	   return link == save_link
	end

	local function CraftConfirmed()
	   local link = save_link or "<unknown>"
	   if not isValid() then -- trade window changed
		 debug("CraftConfirmed: Aborting "..link)
		 return
	   end
	   debug("CraftConfirmed: "..link)
	   blizzard_DoTradeSkill(save_idx,save_cnt)
	end

	local function AlwaysConfirmed(_,reason)
	  if reason == "override" then 
		 debug("AlwaysConfirmed: override abort")
		 return
	  end
	  local link = save_link or "<unknown>"
	  if not isValid() then -- trade window changed
		 debug("AlwaysConfirmed: Aborting "..link)
		 return
	  end
	  debug("AlwaysConfirmed: "..save_link)
	  settings.always[save_link] = true
	  CraftConfirmed()
	end

	StaticPopupDialogs["BOPCRAFTCONFIRM_CONFIRM"] = {
	  preferredIndex = 3, -- prevent taint
	  text = "dummy",
	  button1 = OKAY,
	  button2 = ALWAYS.." "..OKAY,
	  button3 = CANCEL,
	  OnAccept = CraftConfirmed,
	  OnCancel = AlwaysConfirmed, -- second button
	  timeout = 0,
	  hideOnEscape = false, -- this clicks always
	  -- enterClicksFirstButton = true, -- this doesnt work (needs a hardware mouse click event?)
	  showAlert = true,
	}
end
	
--------------------
-- Change Game Font
--------------------
-- Credit Game Font goes to Elv for his ElvUI project.
-- You can find his Addon at http://tukui.org/dl.php
-- Editied by Cokedriver

if cfg.font.enable then

	SlashCmdList['RELOADUI'] = function()
		ReloadUI()
	end
	SLASH_RELOADUI1 = '/rl'

	-- Font Setup
	local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
		obj:SetFont(font, size, style)
		if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
		if sox and soy then obj:SetShadowOffset(sox, soy) end
		if r and g and b then obj:SetTextColor(r, g, b)
		elseif r then obj:SetAlpha(r) end
	end

	local NORMAL     = cfg.font.style
	local COMBAT     = cfg.font.style
	local NUMBER     = cfg.font.style
	local _, editBoxFontSize, _, _, _, _, _, _, _, _ = GetChatWindowInfo(1)

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 14, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = NORMAL
	DAMAGE_TEXT_FONT   = COMBAT
	STANDARD_TEXT_FONT = NORMAL


	-- Base fonts
	SetFont(GameTooltipHeader,                  NORMAL, cfg.font.size)
	SetFont(GameFontNormalMed3,					NORMAL, 15)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, cfg.font.size, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, 15, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, cfg.font.size*1.1, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, cfg.font.size) --chat editbox uses this
	SetFont(NumberFont_Shadow_Small,            NORMAL, cfg.font.size)
	SetFont(QuestFont,                          NORMAL, cfg.font.size)
	SetFont(QuestFont_Large,                    NORMAL, 14)
	SetFont(SystemFont_Large,                   NORMAL, 15)
	SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, "OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Med1,                    NORMAL, cfg.font.size)
	SetFont(SystemFont_Med3,                    NORMAL, cfg.font.size*1.1)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, "THICKOUTLINE")
	SetFont(SystemFont_Outline_Small,           NUMBER, cfg.font.size, "OUTLINE")
	SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, cfg.font.size)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, cfg.font.size*1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,            NORMAL, cfg.font.size*0.9)
	SetFont(SystemFont_Small,                   NORMAL, cfg.font.size)
	SetFont(SystemFont_Tiny,                    NORMAL, cfg.font.size)
	SetFont(Tooltip_Med,                        NORMAL, cfg.font.size)
	SetFont(Tooltip_Small,                      NORMAL, cfg.font.size)
	SetFont(ZoneTextString,						NORMAL, 32, "OUTLINE")
	SetFont(SubZoneTextString,					NORMAL, 25, "OUTLINE")
	SetFont(PVPInfoTextString,					NORMAL, 22, "OUTLINE")
	SetFont(PVPArenaTextString,					NORMAL, 22, "OUTLINE")
	SetFont(CombatTextFont,                     COMBAT, 100, "OUTLINE") -- number here just increase the font quality.
end

------------
-- Merchant
------------
-- Credit for Merchant goes to Tuks for his Tukui project.
-- You can find his Addon at http://tukui.org/dl.php
-- Editied by Cokedriver

if cfg.merchant.enable then

	local filter = {
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

	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		if cfg.merchant.autoSellGrey or cfg.merchant.sellMisc then
			local c = 0
			for b=0,4 do
				for s=1,GetContainerNumSlots(b) do
					local l,lid = GetContainerItemLink(b, s), GetContainerItemID(b, s)
					if l and lid then
						local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))
						if cfg.merchant.autoSellGrey and select(3, GetItemInfo(l))==0 then
							UseContainerItem(b, s)
							PickupMerchantItem()
							c = c+p
						end
						if cfg.merchant.sellMisc and filter[ lid ] then
							UseContainerItem(b, s)
							PickupMerchantItem()
							c = c+p
						end
					end
				end
			end
			if c>0 then
				local g, s, c = math.floor(c/10000) or 0, math.floor((c%10000)/100) or 0, c%100
				DEFAULT_CHAT_FRAME:AddMessage("Your grey item's have been sold for".." |cffffffff"..g.."|cffffd700g|r".." |cffffffff"..s.."|cffc7c7cfs|r".." |cffffffff"..c.."|cffeda55fc|r"..".",255,255,0)
			end
		end
		if not IsShiftKeyDown() then
			if CanMerchantRepair() and cfg.merchant.autoRepair then	
				guildRepairFlag = 0
				local cost, possible = GetRepairAllCost()
				-- additional checks for guild repairs
				if (IsInGuild()) and (CanGuildBankRepair()) then
					 if cost <= GetGuildBankWithdrawMoney() then
						guildRepairFlag = 1
					 end
				end
				if cost>0 then
					if (possible or guildRepairFlag) then
						RepairAllItems(guildRepairFlag)
						local c = cost%100
						local s = math.floor((cost%10000)/100)
						local g = math.floor(cost/10000)
						if cfg.merchant.gpay == "true" and guildRepairFlag == 1 then
							DEFAULT_CHAT_FRAME:AddMessage("Your guild payed ".." |cffffffff"..g.."|cffffd700g|r".." |cffffffff"..s.."|cffc7c7cfs|r".." |cffffffff"..c.."|cffeda55fc|r".." to repair your items.",255,255,0)
						else
							DEFAULT_CHAT_FRAME:AddMessage("You payed ".." |cffffffff"..g.."|cffffd700g|r".." |cffffffff"..s.."|cffc7c7cfs|r".." |cffffffff"..c.."|cffeda55fc|r".." to repair your items.",255,255,0)
						end	
					else
						DEFAULT_CHAT_FRAME:AddMessage("You don't have enough money for repair!",255,0,0)
					end
				end		
			end
		end
	end)
	f:RegisterEvent("MERCHANT_SHOW")
end

---------
-- Quest 
---------
-- Credit for Quest goes to nightcracker for his ncQuest addon.
-- You can find his addon at http://www.wowinterface.com/downloads/info14972-ncQuest.html
-- Editied by Cokedriver

if cfg.quest.enable then

	local f = CreateFrame("Frame")

	local function MostValueable()
		local bestp, besti = 0
		for i=1,GetNumQuestChoices() do
			local link, name, _, qty = GetQuestItemLink("choice", i), GetQuestItemInfo("choice", i)
			local price = link and select(11, GetItemInfo(link))
			if not price then
				return
			elseif (price * (qty or 1)) > bestp then
				bestp, besti = (price * (qty or 1)), i
			end
		end
		if besti then		
			local btn = _G["QuestInfoItem"..besti]
			if (btn.type == "choice") then
				btn:GetScript("OnClick")(btn)
			end
		end
	end
	
	f:RegisterEvent("QUEST_ITEM_UPDATE")
	f:RegisterEvent("GET_ITEM_INFO_RECEIVED")	
	f:RegisterEvent("QUEST_ACCEPT_CONFIRM")    
	f:RegisterEvent("QUEST_DETAIL")
	f:RegisterEvent("QUEST_COMPLETE")
	f:SetScript("OnEvent", function(self, event, ...)
		if cfg.quest.autocomplete ~= false then
			if (event == "QUEST_DETAIL") then
				AcceptQuest()
				CompleteQuest()
			elseif (event == "QUEST_COMPLETE") then
				if (GetNumQuestChoices() and GetNumQuestChoices() < 1) then
					GetQuestReward()
				else
					MostValueable()
				end
			elseif (event == "QUEST_ACCEPT_CONFIRM") then
				ConfirmAcceptQuest()
			end
		else
			if (event == "QUEST_COMPLETE") then
				if (GetNumQuestChoices() and GetNumQuestChoices() < 1) then
					GetQuestReward()
				else
					MostValueable()
				end
			end
		end
	end)

end


if cfg.vendor.enable then

	local timeout = CreateFrame("Frame")
	timeout:Hide()

	local f = LibStub("tekShiner").new(QuestRewardScrollChildFrame)
	f:Hide()


	f:RegisterEvent("QUEST_COMPLETE")
	f:RegisterEvent("QUEST_ITEM_UPDATE")
	f:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	f:SetScript("OnEvent", function(self, ...)
		self:Hide()
		local bestp, besti = 0
		for i=1,GetNumQuestChoices() do
			local link, name, _, qty = GetQuestItemLink("choice", i), GetQuestItemInfo("choice", i)
			if not link then
				timeout:Show()
				return
			end
			local price = link and select(11, GetItemInfo(link))
			if not price then return
			elseif (price * (qty or 1)) > bestp then bestp, besti = (price * (qty or 1)), i end
		end

		if besti then
			self:ClearAllPoints()
			self:SetAllPoints("QuestInfoItem"..besti.."IconTexture")
			self:Show()
		end
	end)


	local elapsed
	timeout:SetScript("OnShow", function() elapsed = 0 end)
	timeout:SetScript("OnHide", function() f:GetScript("OnEvent")(f) end)
	timeout:SetScript("OnUpdate", function(self, elap)
		elapsed = elapsed + elap
		if elapsed < 1 then return end
		self:Hide()
	end)

	if QuestInfoItem1:IsVisible() then f:GetScript("OnEvent")(f) end
	
end


---------------------------------------
-- Bigger Trade Skill UI
---------------------------------------
-- Credit for BTSUI goes to Robsato for his Bigger Tradeskill UI addon.
-- You can find the original addon at http://www.wowinterface.com/downloads/info20508-BiggerTradeskillUI.html
-- Edited by Cokedriver

if cfg.BTSUI.enable then
	local addonName, BTSUi = ...

	TRADE_SKILLS_DISPLAYED = 25


	-- Add skill buttons if needed
	for i=1, TRADE_SKILLS_DISPLAYED do
		if (not _G["TradeSkillSkill"..i]) then
			-- Create a new button
			local newSkillButton = CreateFrame("Button", "TradeSkillSkill"..i, TradeSkillSkill1:GetParent(), "TradeSkillSkillButtonTemplate")
			newSkillButton:SetPoint("TOPLEFT", _G["TradeSkillSkill"..(i-1)], "BOTTOMLEFT")
		end
	end   


	-- Resize the main window
	TradeSkillFrame:SetWidth(550)
	TradeSkillFrame:SetHeight(525)

	-- Hide Horizontal bar in the default UI
	TradeSkillHorizontalBarLeft:Hide()

	-- Move skillbar
	TradeSkillRankFrame:ClearAllPoints()
	TradeSkillRankFrame:SetPoint("TOPRIGHT", TradeSkillRankFrame:GetParent(), "TOPRIGHT", -37, -33)

	-- Setup search box
	TradeSkillFrameSearchBox:ClearAllPoints()
	TradeSkillFrameSearchBox:SetPoint("TOPLEFT", TradeSkillFrameSearchBox:GetParent(), "TOPLEFT", 75, -56)
	TradeSkillFrameSearchBox:SetPoint("RIGHT", TradeSkillRankFrame, "LEFT", -8, 0)

	-- Add a clear button to the searchbox like all other search boxes have
	local clearButton = CreateFrame("Button", "TradeSkillFrameSearchBoxClearButton", TradeSkillFrameSearchBox)
	clearButton:SetWidth(17)
	clearButton:SetHeight(17)
	clearButton:SetPoint("RIGHT", TradeSkillFrameSearchBox, "RIGHT", -3, 0)
	clearButton:SetScript("OnEnter", function(self) self.texture:SetAlpha(1.0) end)
	clearButton:SetScript("OnLeave", function(self) self.texture:SetAlpha(0.5) end)
	clearButton:SetScript("OnMouseDown", function(self) 
			if self:IsEnabled() then
				self.texture:SetPoint("TOPLEFT", 1, -1);
			end
		end)
	clearButton:SetScript("OnMouseUp", function(self) self.texture:SetPoint("TOPLEFT", 0, 0) end)
	clearButton:SetScript("OnClick", function(self) 
			PlaySound("igMainMenuOptionCheckBoxOn")
			local editBox = self:GetParent()
			if editBox.clearFunc then
				editBox.clearFunc(editBox)
			end

			editBox:SetText("")
			if not editBox:HasFocus() then
				editBox:GetScript("OnEditFocusLost")(editBox)
			end
			editBox:ClearFocus()
		end)

	local clearButtonTexture = clearButton:CreateTexture("BTSUiClearButton", "ARTWORK")
	clearButtonTexture:SetTexture("Interface\\FriendsFrame\\ClearBroadcastIcon")
	clearButtonTexture:SetPoint("TOPLEFT", TradeSkillFrameSearchBoxClearButton, "TOPLEFT", 0, 0)
	clearButtonTexture:SetWidth(17)
	clearButtonTexture:SetHeight(17)

	clearButton.texture = clearButtonTexture


	function BTSUi.ShowClearButtonWhenNeeded(self)
		local text = self:GetText();
		if (text == SEARCH) then
			if self:HasFocus() then self:SetText("") end
			TradeSkillFrameSearchBoxClearButton:Hide()
		else
			TradeSkillFrameSearchBoxClearButton:Show()
		end 
	end

	-- Hooks for updating the visibility of the clear button
	TradeSkillFrameSearchBox:HookScript("OnEditFocusLost", BTSUi.ShowClearButtonWhenNeeded)
	TradeSkillFrameSearchBox:HookScript("OnTextChanged", BTSUi.ShowClearButtonWhenNeeded)
	TradeSkillFrameSearchBox:HookScript("OnEditFocusGained", BTSUi.ShowClearButtonWhenNeeded)


	-- Blizzard FilterButton
	TradeSkillFilterButton:Hide()

	-- Mats filter
	if (not BTSUiHaveMatsCheck) then
		CreateFrame("CheckButton", "BTSUiHaveMatsCheck", TradeSkillFrame, "UICheckButtonTemplate ")
	end 

	BTSUiHaveMatsCheck:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 66, -29)
	BTSUiHaveMatsCheck:SetWidth(24)
	BTSUiHaveMatsCheck:SetHeight(24)
	BTSUiHaveMatsCheckText:SetText(CRAFT_IS_MAKEABLE)
	BTSUiHaveMatsCheckText:SetWidth(80)
	BTSUiHaveMatsCheckText:SetJustifyH("LEFT")
	BTSUiHaveMatsCheck:SetHitRectInsets(0, -1 * BTSUiHaveMatsCheckText:GetWidth() , 0, 0) -- Increase click area so text is also clickable

	BTSUiHaveMatsCheck:SetScript("OnClick", function(self)
		TradeSkillFrame.filterTbl.hasMaterials = not TradeSkillFrame.filterTbl.hasMaterials
		TradeSkillOnlyShowMakeable(TradeSkillFrame.filterTbl.hasMaterials)
		TradeSkillUpdateFilterBar()
	end)   

	function BTSUi.TradeSkillOnlyShowMakeable(show)
		BTSUiHaveMatsCheck:SetChecked(show)
	end

	-- Skillup filter
	if (not BTSUiOnlySkillupCheck) then
		CreateFrame("CheckButton", "BTSUiOnlySkillupCheck", TradeSkillFrame, "UICheckButtonTemplate")
	end 

	BTSUiOnlySkillupCheck:SetPoint("LEFT", BTSUiHaveMatsCheck, "RIGHT", 80, 0)
	BTSUiOnlySkillupCheck:SetWidth(24)
	BTSUiOnlySkillupCheck:SetHeight(24)
	BTSUiOnlySkillupCheckText:SetText(TRADESKILL_FILTER_HAS_SKILL_UP)
	BTSUiOnlySkillupCheckText:SetWidth(80)
	BTSUiOnlySkillupCheckText:SetJustifyH("LEFT")
	BTSUiOnlySkillupCheck:SetHitRectInsets(0, -1 * BTSUiOnlySkillupCheckText:GetWidth() , 0, 0) -- Increase click area so text is also clickable

	BTSUiOnlySkillupCheck:SetScript("OnClick", function(self)
		  TradeSkillFrame.filterTbl.hasSkillUp = not TradeSkillFrame.filterTbl.hasSkillUp
		  TradeSkillOnlyShowSkillUps(TradeSkillFrame.filterTbl.hasSkillUp)
		  TradeSkillUpdateFilterBar()
	end)

	function BTSUi.TradeSkillOnlyShowSkillUps(show)
		BTSUiOnlySkillupCheck:SetChecked(show)
	end

	-- Subclass filter
	if not BTSUiSubClassFilterDropDown then
	   CreateFrame("Button", "BTSUiSubClassFilterDropDown", TradeSkillFrame, "UIDropDownMenuTemplate")
	end

	BTSUiSubClassFilterDropDown:ClearAllPoints()
	BTSUiSubClassFilterDropDown:SetPoint("TOPLEFT", TradeSkillRankFrame, "BOTTOMLEFT", -20, -4)
	BTSUiSubClassFilterDropDown:Show()
	BTSUiSubClassFilterDropDownButton:SetHitRectInsets(-110, 0, 0, 0) -- To make Text part of combobox clickable

	UIDropDownMenu_SetWidth(BTSUiSubClassFilterDropDown, 115); -- Need to set the width explicitly so text will be truncated correctly

	-- Slot filter
	if not BTSUiSlotFilterDropDown then
	   CreateFrame("Button", "BTSUiSlotFilterDropDown", TradeSkillFrame, "UIDropDownMenuTemplate")
	end

	BTSUiSlotFilterDropDown:ClearAllPoints()
	BTSUiSlotFilterDropDown:SetPoint("TOP", BTSUiSubClassFilterDropDown, "TOP")
	BTSUiSlotFilterDropDown:SetPoint("RIGHT", TradeSkillFrame, "RIGHT", 9, 0)
	BTSUiSlotFilterDropDown:Show()
	BTSUiSlotFilterDropDownButton:SetHitRectInsets(-110, 0, 0, 0) -- To make Text part of combobox clickable

	UIDropDownMenu_SetWidth(BTSUiSlotFilterDropDown, 115); -- Need to set the width explicitly so text will be truncated correctly

	-- Add a vertical bar between the recipelist and the details pane
	-- Usually the scrollbar will be over it, but when there is no scrollbar this one shows and looks better
	if (not BTSUiVerticalBarTop) then
	   BTSUiVerticalBarTop = TradeSkillFrame:CreateTexture("BTSUiVerticalBarTop", "BACKGROUND")
	end
	BTSUiVerticalBarTop:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-VerticalBar")
	BTSUiVerticalBarTop:SetTexCoord(0, 0.1875, 0, 1.0) 
	BTSUiVerticalBarTop:SetPoint("TOPLEFT", TradeSkillDetailScrollFrame, "TOPLEFT", -7, 0)
	BTSUiVerticalBarTop:SetWidth(8)
	BTSUiVerticalBarTop:SetHeight(128)

	if (not BTSUiVerticalBarMiddle) then
	   BTSUiVerticalBarMiddle = TradeSkillFrame:CreateTexture("BTSUiVerticalBarMiddle", "BACKGROUND")
	end
	BTSUiVerticalBarMiddle:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-VerticalBar")
	BTSUiVerticalBarMiddle:SetTexCoord(0.421875, 0.5625, 0, 1.0) 
	BTSUiVerticalBarMiddle:SetPoint("TOPLEFT", BTSUiVerticalBarTop, "BOTTOMLEFT", 0, 0)
	BTSUiVerticalBarMiddle:SetWidth(7)
	BTSUiVerticalBarMiddle:SetHeight(159)

	if (not BTSUiVerticalBarBottom) then
	   BTSUiVerticalBarBottom = TradeSkillFrame:CreateTexture("BTSUiVerticalBarBottom", "BACKGROUND")
	end
	BTSUiVerticalBarBottom:SetTexture("Interface\\FriendsFrame\\UI-ChannelFrame-VerticalBar")
	BTSUiVerticalBarBottom:SetTexCoord(0.8125, 1, 0, 1.0) 
	BTSUiVerticalBarBottom:SetPoint("TOPLEFT", BTSUiVerticalBarMiddle, "BOTTOMLEFT", 0, 0)
	BTSUiVerticalBarBottom:SetWidth(8)
	BTSUiVerticalBarBottom:SetHeight(128)

	-- Detail frame with the ingredients
	TradeSkillDetailScrollFrame:ClearAllPoints()
	TradeSkillDetailScrollFrame:SetPoint("RIGHT", TradeSkillFrame, "RIGHT", -31, 0)
	TradeSkillDetailScrollFrame:SetPoint("LEFT", TradeSkillFrame, "RIGHT", -218, 0)
	TradeSkillDetailScrollFrame:SetPoint("TOP", TradeSkillFrame, "TOP", 0, -86)
	TradeSkillDetailScrollFrame:SetPoint("BOTTOM", TradeSkillFrame, "BOTTOM", 0, 30)

	-- Re-anchor icons, text and stuff
	TradeSkillDetailHeaderLeft:SetPoint("TOPLEFT", TradeSkillDetailScrollChildFrame, "TOPLEFT", 3, -5)
	TradeSkillDetailHeaderLeft:SetWidth(140)
	TradeSkillDetailHeaderLeft:SetTexCoord(0, 0.56, 0, 1)
	TradeSkillDetailHeaderLeft:Show()

	TradeSkillSkillIcon:SetPoint("TOPLEFT", TradeSkillDetailHeaderLeft, "TOPLEFT", 8, -6)

	TradeSkillSkillName:SetPoint("TOPLEFT", TradeSkillDetailHeaderLeft, "TOPLEFT", 50, -4)
	TradeSkillSkillName:SetPoint("RIGHT", TradeSkillDetailScrollFrame, "RIGHT", -5, 0)
	TradeSkillSkillName:SetHeight(40)

	-- Description and requirements swapped places cause it looks better.
	-- Note that the anchors get reset when the recipe detail display is updated
	-- So need to reapply this when that happens (hook TradeSkillFrame_SetSelection)
	-- The values in the hook function are leading when they are different from here
	TradeSkillDescription:SetPoint("TOPLEFT", TradeSkillDetailHeaderLeft, "BOTTOMLEFT", 5, 5)
	TradeSkillDescription:SetWidth(180)  -- Set a width that matches the real width for the autosizing 
										 -- to work. Smaller widths seem to add height, bigger widths 
										 -- will cut off the text instead of expanding the textheight

	-- Recolor label so it looks better
	TradeSkillRequirementLabel:SetTextColor(TradeSkillReagentLabel:GetTextColor())
	TradeSkillRequirementLabel:SetShadowColor(TradeSkillReagentLabel:GetShadowColor())
	TradeSkillRequirementLabel:SetPoint("TOPLEFT", TradeSkillDescription, "BOTTOMLEFT", 0, -15)
	TradeSkillRequirementText:SetPoint("TOPLEFT", TradeSkillRequirementLabel, "BOTTOMLEFT", 0, 0)

	TradeSkillReagentLabel:SetPoint("TOPLEFT", TradeSkillRequirementText, "BOTTOMLEFT", 0, -15)

	-- Reposition reagent buttons
	_G["TradeSkillReagent1"]:SetPoint("RIGHT", TradeSkillDetailScrollFrame, "RIGHT")
	for i=2, MAX_TRADE_SKILL_REAGENTS do
	   local reagentButton = _G["TradeSkillReagent"..i]
	   
	   reagentButton:ClearAllPoints()
	   reagentButton:SetPoint("TOPLEFT", _G["TradeSkillReagent"..(i-1)], "BOTTOMLEFT", 0, -3)
	   reagentButton:SetPoint("RIGHT", TradeSkillDetailScrollFrame, "RIGHT")
	end

	-- Background for reagents/detailarea
	-- Note that the background is also needed to hide a part of the original
	-- horizontal bar that I can't figure out how to hide.
	local detailBackground = TradeSkillDetailScrollFrame:CreateTexture("BTSUiTexDetailBackground","BACKGROUND")
	detailBackground:SetPoint("TOPLEFT", TradeSkillDetailScrollFrame)
	detailBackground:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -10, 29)
	detailBackground:SetTexCoord(0, 0.2, 0, 1)  -- Mess with TexCoords so the texture does not look too compressed/stretched
	detailBackground:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated")
	--detailBackground:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment")
	--detailBackground:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble")


	-- Scrollbar of the recipe list
	TradeSkillListScrollFrame:ClearAllPoints()
	TradeSkillListScrollFrame:SetPoint("TOPRIGHT", TradeSkillDetailScrollFrame, "TOPLEFT", -28, 0)
	TradeSkillListScrollFrame:SetPoint("BOTTOMRIGHT", TradeSkillDetailScrollFrame, "BOTTOMLEFT", -28, 0)

	if (not BTSUiTradeSkillListScrollBarMiddle) then
	   -- Use horrible random name for texture. When using a proper name like BTSUiTradeSkillListScrollBarMiddle
	   -- the top and bottom parts of the scrollbar disappear
	   BTSUiTradeSkillListScrollBarMiddle = TradeSkillListScrollFrame:CreateTexture("BTSUi_kjfeowjpfa", "BACKGROUND")
	end
	BTSUiTradeSkillListScrollBarMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	BTSUiTradeSkillListScrollBarMiddle:SetTexCoord(0, 0.45, 0.1640625, 1)
	BTSUiTradeSkillListScrollBarMiddle:SetPoint("TOPRIGHT", TradeSkillListScrollFrame, "TOPRIGHT", 27, -110)
	BTSUiTradeSkillListScrollBarMiddle:SetPoint("BOTTOMRIGHT", TradeSkillListScrollFrame, "BOTTOMRIGHT", 27, 120)
	BTSUiTradeSkillListScrollBarMiddle:SetWidth(29)

	-- Scrollbar of the recipe details list
	if (not BTSUiDetailScrollBarMiddle) then
	   -- Use horrible random name for texture. When using a proper name like BTSUiTradeSkillListScrollBarMiddle
	   -- the top and bottom parts of the scrollbar disappear
	   BTSUiDetailScrollBarMiddle = TradeSkillDetailScrollFrame:CreateTexture("BTSUi_afiepipnp", "BACKGROUND")
	   -- Additional blackish background for in the scrollbar, just because it looks better
	   BTSUiDetailScrollBarMiddleBackground = TradeSkillDetailScrollFrame:CreateTexture("BTSUiMiddle2Background", "BACKGROUND")
	end
	BTSUiDetailScrollBarMiddle:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
	BTSUiDetailScrollBarMiddle:SetTexCoord(0, 0.44, 0.1640625, 1)
	BTSUiDetailScrollBarMiddle:SetPoint("TOPRIGHT", TradeSkillDetailScrollFrame, "TOPRIGHT", 28, -110)
	BTSUiDetailScrollBarMiddle:SetPoint("BOTTOMRIGHT", TradeSkillDetailScrollFrame, "BOTTOMRIGHT", 28, 120)
	BTSUiDetailScrollBarMiddle:SetWidth(29)
	BTSUiDetailScrollBarMiddle:SetParent(TradeSkillDetailScrollFrameScrollBar)  -- Reparent to make it hide properly

	BTSUiDetailScrollBarMiddleBackground:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble")
	BTSUiDetailScrollBarMiddleBackground:SetAllPoints(TradeSkillDetailScrollFrameScrollBar)
	BTSUiDetailScrollBarMiddleBackground:SetParent(TradeSkillDetailScrollFrameScrollBar)  -- Reparent to make it hide properly
	BTSUiDetailScrollBarMiddleBackground:SetTexCoord(0, 0.2, 0, 1)

	-- Reposition Create all button, decrement, and editbox.
	-- The others are already at the right place
	TradeSkillCreateAllButton:ClearAllPoints()
	TradeSkillCreateAllButton:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMLEFT", 216, 4)



	-- Functions for dropdowns, these are based on the old (3.3.5 patch) Blizzard code
	-- Changes are mostly updates to use TradeSkillSetFilter to get the new Filterbar working

	function BTSUi.TradeSkillInvSlotDropDown_Initialize()
		BTSUi.TradeSkillFilterFrame_LoadInvSlots(GetTradeSkillSubClassFilteredSlots(0));
	end


	function BTSUi.TradeSkillFilterFrame_LoadInvSlots(...)
		local allChecked = GetTradeSkillInvSlotFilter(0);
		local filterCount = select("#", ...);

		local info = UIDropDownMenu_CreateInfo();

		info.text = ALL_INVENTORY_SLOTS;
		info.func = BTSUi.TradeSkillInvSlotDropDownButton_OnClick;
		info.checked = allChecked;

		UIDropDownMenu_AddButton(info);

		local checked;
		for i=1, filterCount, 1 do
			if ( allChecked and filterCount > 1 ) then
				UIDropDownMenu_SetText(BTSUiSlotFilterDropDown, ALL_INVENTORY_SLOTS);
			else
				checked = GetTradeSkillInvSlotFilter(i);
				if ( checked ) then
					UIDropDownMenu_SetText(BTSUiSlotFilterDropDown, select(i, ...));
				end
			end

			info.text = select(i, ...);
			info.func = BTSUi.TradeSkillInvSlotDropDownButton_OnClick;
			info.checked = checked;

			UIDropDownMenu_AddButton(info);
		end
	end


	function BTSUi.TradeSkillFilterFrame_InvSlotName(...)
		for i=1, select("#", ...), 1 do
			if ( GetTradeSkillInvSlotFilter(i) ) then
				return select(i, ...);
			end
		end
	end


	function BTSUi.TradeSkillInvSlotDropDownButton_OnClick(self)
		local selectedId = self:GetID()
		local selectedName = self:GetText()

		UIDropDownMenu_SetSelectedID(BTSUiSlotFilterDropDown, selectedId);

		-- The other dropdown goes back to the "All xxx" option
		UIDropDownMenu_SetSelectedID(BTSUiSubClassFilterDropDown, 1);
		UIDropDownMenu_SetText(BTSUiSubClassFilterDropDown, ALL_SUBCLASSES);

		BTSUi.TradeSkillSetFilter(0, selectedId-1, "", selectedName)
	end


	function BTSUi.TradeSkillSetFilter(selectedSubclassId, selectedSlotId, selectedSubclassName, selectedSlotName, subclassCategory)
	--print(selectedSubclassId, "-", selectedSlotId, "-", selectedSubclassName, "-", selectedSlotName, "-", subclassCategory)
		TradeSkillSetFilter(selectedSubclassId, selectedSlotId, selectedSubclassName, selectedSlotName, subclassCategory)
	end


	function BTSUi.TradeSkillSubClassDropDown_Initialize()
		BTSUi.TradeSkillFilterFrame_LoadSubClasses(GetTradeSkillSubClasses());
	end


	function BTSUi.TradeSkillFilterFrame_LoadSubClasses(...)
		local selectedID = UIDropDownMenu_GetSelectedID(BTSUiSubClassFilterDropDown);
		local numSubClasses = select("#", ...);
		local allChecked = GetTradeSkillSubClasses(0);

		-- the first button in the list is going to be an "all subclasses" button
		local info = UIDropDownMenu_CreateInfo();
		info.text = ALL_SUBCLASSES;
		info.func = BTSUi.TradeSkillSubClassDropDownButton_OnClick;
		info.checked = allChecked and (selectedID == nil or selectedID == 1);
		info.value = 0;
		UIDropDownMenu_AddButton(info);
		if ( info.checked ) then
			UIDropDownMenu_SetText(BTSUiSubClassFilterDropDown, ALL_SUBCLASSES);
		end

		-- Add buttons for each subclass
		local checked;

		for i=1, select("#", ...), 1 do
			-- if there are no filters then don't check any individual subclasses
			if (allChecked) then
				checked = nil;
			else
				checked = GetTradeSkillSubClasses(i);
				if ( checked ) then
					UIDropDownMenu_SetText(BTSUiSubClassFilterDropDown, select(i, ...));
				end
			end
			info.text = select(i, ...);
			info.func = BTSUi.TradeSkillSubClassDropDownButton_OnClick;
			info.checked = checked;
			info.value = i;

			if (info.text) then -- The subclasses like "Everyday Cooking" that Pandaren Cuisine has returns nil on the text. Don't add those
				UIDropDownMenu_AddButton(info);
			end
		end
	end


	function BTSUi.TradeSkillSubClassDropDownButton_OnClick(self)
		UIDropDownMenu_SetSelectedID(BTSUiSubClassFilterDropDown, self:GetID());

		-- The other dropdown goes back to the "All xxx" option
		UIDropDownMenu_SetSelectedID(BTSUiSlotFilterDropDown, 1);
		UIDropDownMenu_SetText(BTSUiSlotFilterDropDown, ALL_INVENTORY_SLOTS);

		BTSUi.TradeSkillSetFilter(self.value, 0, self:GetText(), "", 0)
	end


	-- This is needed to detect switching between professions and resetting the slot/subclass filters
	-- so that no invalid values are selected (for example Plate on the Firstaid profession when switching from BS)
	-- Also taken from the old code btw
	function BTSUi.TradeSkillFrame_Update()
		local name, rank, maxRank = GetTradeSkillLine();
				
		if ( BTSUi.CURRENT_TRADESKILL ~= name ) then
	--		StopTradeSkillRepeat();

			if ( BTSUi.CURRENT_TRADESKILL ~= "" ) then
				-- To fix problem with switching between two tradeskills
				UIDropDownMenu_Initialize(BTSUiSlotFilterDropDown, BTSUi.TradeSkillInvSlotDropDown_Initialize)
				UIDropDownMenu_SetSelectedID(BTSUiSlotFilterDropDown, 1);

				UIDropDownMenu_Initialize(BTSUiSubClassFilterDropDown, BTSUi.TradeSkillSubClassDropDown_Initialize)
				UIDropDownMenu_SetSelectedID(BTSUiSubClassFilterDropDown, 1);
			end
			BTSUi.CURRENT_TRADESKILL = name;
		end
	end


	-- Controls get reanchored in the TradeSkillFrame_SetSelection function
	-- Basically reanchor everything in the detail frame to my liking
	function BTSUi.TradeSkillFrame_SetSelection()

		local anchorTo = TradeSkillDetailHeaderLeft
		local anchorOffsetX = 5
		local anchorOffsetY = 5

		-- Add Auctionator AH button on the left side so people with small screens can still see it while at the AH
		-- since the BiggerTradeSkillUI can be partly offscreen then
		if (Auctionator_Search) then
			Auctionator_Search:ClearAllPoints()
			Auctionator_Search:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", anchorOffsetX, 10)

			anchorTo = Auctionator_Search
			anchorOffsetX = 0
			anchorOffsetY = -10
		end

		-- Cooldown
		if (TradeSkillSkillCooldown:GetText()) then
			TradeSkillSkillCooldown:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", anchorOffsetX, anchorOffsetY+5) -- +5 looks better

			anchorTo = TradeSkillSkillCooldown
			anchorOffsetX = 0
			anchorOffsetY = -15
		end

		-- Description
		if (strlen(TradeSkillDescription:GetText()) <= 2) then  -- <= 2 because there is the text " " in it when empty
			TradeSkillDescription:Hide()
		else
			TradeSkillDescription:Show()
			TradeSkillDescription:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", anchorOffsetX, anchorOffsetY)

			anchorTo = TradeSkillDescription
			anchorOffsetX = 0
			anchorOffsetY = -15
		end

		-- Requirements
		if (TradeSkillRequirementText:GetText()) then
			TradeSkillRequirementLabel:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", anchorOffsetX, anchorOffsetY)

			anchorTo = TradeSkillRequirementText
			anchorOffsetX = 0
			anchorOffsetY = -15
		end

		-- Reagents
		TradeSkillReagentLabel:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", anchorOffsetX, anchorOffsetY)
	end


	-- Hook functions
	hooksecurefunc("TradeSkillFrame_Update", BTSUi.TradeSkillFrame_Update)
	hooksecurefunc("TradeSkillFrame_SetSelection", BTSUi.TradeSkillFrame_SetSelection)
	hooksecurefunc("TradeSkillOnlyShowMakeable", BTSUi.TradeSkillOnlyShowMakeable)
	hooksecurefunc("TradeSkillOnlyShowSkillUps", BTSUi.TradeSkillOnlyShowSkillUps)


	-- Update the filterdropdowns when the Filterbar is closed
	local originalTradeSkillFilterBarExitButtonOnHideHandler = TradeSkillFilterBarExitButton:GetScript("OnHide")
	TradeSkillFilterBarExitButton:SetScript("OnHide", function(...)

		if (originalTradeSkillFilterBarExitButtonOnHideHandler) then
			originalTradeSkillFilterBarExitButtonOnHideHandler(...)
		end

		UIDropDownMenu_Initialize(BTSUiSlotFilterDropDown, BTSUi.TradeSkillInvSlotDropDown_Initialize)
		UIDropDownMenu_SetSelectedID(BTSUiSlotFilterDropDown, 1);

		UIDropDownMenu_Initialize(BTSUiSubClassFilterDropDown, BTSUi.TradeSkillSubClassDropDown_Initialize)
		UIDropDownMenu_SetSelectedID(BTSUiSubClassFilterDropDown, 1);

	end
	)

end

if cfg.vellum.enable then
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
end