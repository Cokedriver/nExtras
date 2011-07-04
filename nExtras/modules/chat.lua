if nExtras.chat.enable ~= true then return end

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