-- Code source TukUI - visit www.tukui.org for more info.

if nExtras.merchant.enable ~= true then return end

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
	if nExtras.merchant.autoSellGrey or nExtras.merchant.sellMisc then
		local c = 0
		for b=0,4 do
			for s=1,GetContainerNumSlots(b) do
				local l,lid = GetContainerItemLink(b, s), GetContainerItemID(b, s)
				if l and lid then
					local p = select(11, GetItemInfo(l))*select(2, GetContainerItemInfo(b, s))
					if nExtras.merchant.autoSellGrey and select(3, GetItemInfo(l))==0 then
						UseContainerItem(b, s)
						PickupMerchantItem()
						c = c+p
					end
					if nExtras.merchant.sellMisc and filter[ lid ] then
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
		if CanMerchantRepair() and nExtras.merchant.autoRepair then
			local cost, possible = GetRepairAllCost()
			if cost>0 then
				if possible then
					RepairAllItems()
					local c = cost%100
					local s = math.floor((cost%10000)/100)
					local g = math.floor(cost/10000)
					DEFAULT_CHAT_FRAME:AddMessage("Your items have been repaired for".." |cffffffff"..g.."|cffffd700g|r".." |cffffffff"..s.."|cffc7c7cfs|r".." |cffffffff"..c.."|cffeda55fc|r"..".",255,255,0)
				else
					DEFAULT_CHAT_FRAME:AddMessage("You don't have enough money for repair!",255,0,0)
				end
			end
		end
	end
end)
f:RegisterEvent("MERCHANT_SHOW")