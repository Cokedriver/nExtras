if nExtras.chat.enable ~= true then return end

if (IsAddOnLoaded("nChat")) then
	do 
		ChatFrame1:CreateBeautyBorder(12)
		ChatFrame1:SetBeautyBorderPadding( 5, 5, 5, 5, 5, 8, 5, 8)
		ChatFrame2:CreateBeautyBorder(12)
		ChatFrame2:SetBeautyBorderPadding(5, 29, 5, 29, 5, 8, 5, 8)
		ChatFrame3:CreateBeautyBorder(12)
		ChatFrame3:SetBeautyBorderPadding(5, 5, 5, 5, 5, 8, 5, 8)
		ChatFrame4:CreateBeautyBorder(12)
		ChatFrame4:SetBeautyBorderPadding(5, 5, 5, 5, 5, 8, 5, 8)
		ChatFrame5:CreateBeautyBorder(12)
		ChatFrame5:SetBeautyBorderPadding(5, 5, 5, 5, 5, 8, 5, 8)
	end
end