print(">>Script: LoginNotice loading...OK")

local TEAM_ALLIANCE = 0
local TEAM_HORDE = 1
--职业
local CLASS_WARRIOR = 1        --战士
local CLASS_PALADIN = 2        --圣骑士
local CLASS_HUNTER = 3         --猎人
local CLASS_ROGUE = 4          --盗贼
local CLASS_PRIEST = 5         --牧师
local CLASS_DEATH_KNIGHT = 6   --死亡骑士
local CLASS_SHAMAN = 7         --萨满
local CLASS_MAGE = 8           --法师
local CLASS_WARLOCK = 9        --术士
local CLASS_DRUID = 11         --德鲁伊

--职业表
local ClassName = {
    [CLASS_WARRIOR] = "战士",
    [CLASS_PALADIN] = "圣骑士",
    [CLASS_HUNTER] = "猎人",
    [CLASS_ROGUE] = "盗贼",
    [CLASS_PRIEST] = "牧师",
    [CLASS_DEATH_KNIGHT] = "死亡骑士",
    [CLASS_SHAMAN] = "萨满",
    [CLASS_MAGE] = "法师",
    [CLASS_WARLOCK] = "术士",
    [CLASS_DRUID] = "德鲁伊",
}

local function GetPlayerInfo(player)
    --得到玩家信息
    local Pclass = ClassName[player:GetClass()] or "? ? ?" --得到职业
    local Pname = player:GetName()
    local Pteam = ""
    local team = player:GetTeam()
    if (team == TEAM_ALLIANCE) then
        Pteam = "|cFF0070d0联盟|r"
    elseif (team == TEAM_HORDE) then
        Pteam = "|cFFF000A0部落|r"
    end
    return string.format("%s%s玩家[|cFF00FF00|Hplayer:%s|h%s|h|r]", Pteam, Pclass, Pname, Pname)
end

local function PlayerFirstLogin(event, player)
    if (player:GetGMRank() >= 3) then

    else
        --玩家首次登录
        SendWorldMessage("|cFFFF0000[系统公告]欢迎|r" .. GetPlayerInfo(player) .. " |cFFFF0000来到Forever WLK仿官公益服，请文明游戏！|r")
    end
end

local function PlayerLogin(event, player)
    if (player:GetGMRank() >= 3) then

    else
        --玩家登录
        SendWorldMessage("|cFFFF0000[系统公告]|r欢迎" .. GetPlayerInfo(player) .. " 上线了！")
    end
end

local function PlayerLogout(event, player)
    if (player:GetGMRank() >= 3) then

    else
        --玩家登出
        SendWorldMessage("|cFFFF0000[系统公告]|r" .. GetPlayerInfo(player) .. " 下线了！")
    end

end
--首次登录
RegisterPlayerEvent(30, PlayerFirstLogin)
--登录
RegisterPlayerEvent(3, PlayerLogin)
--登出
RegisterPlayerEvent(4, PlayerLogout)
