
--仅限服务端API
			  
local MeMethod = {}

--名字颜色(根据职业)
ClassColor = {
	[1]	=	"|cffC79C6E",	   --战士
	[2]	=	"|cffF58CBA",	   --骑士
	[3]	=	"|cffABD473",	   --猎人
	[4]	=	"|cffFFF569",	   --盗贼
	[5]	=	"|cffFFFFFF",	   --牧师
	[6]	=	"|cffC41F3B",	   --死骑
	[7]	=	"|cff2459FF",	   --萨满
	[8]	=	"|cff69CCF0",	   --法师
	[9]	=	"|cff9482C9",	   --术士
	[11]=	"|cffFF7D0A",      --小德
}

function MeMethod.SetLink(player)
    local Link = ""
	if (player) then
		Link = string.format("[%s%s|r]", ClassColor[player:GetClass()], player:GetName())
	end
	return Link
end

function MeMethod.SetHyperlink(player)
    local Link = ""
	if (player) then
		Link = string.format("|Hplayer:%s|h[%s%s|r]|h", player:GetName(), ClassColor[player:GetClass()], player:GetName())
	end
	return Link
end

return MeMethod