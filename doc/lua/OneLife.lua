print(">>Script: OneLife loading...OK")

local oneLifePlayers = {}

--常规模式经验是一命模式的2倍
function OnAddXP(event, player, amount, victim)
    if player == nil then
        return amount * 2
    end
    if player:GetAccountId() == 1 then
        return amount / 6
    end
    if oneLifePlayers[player:GetGUIDLow()] ~= nil then
        local map = player:GetMap()
        local isDungeon = map:IsDungeon()
        if (isDungeon == true) then
            player:SendBroadcastMessage("【一命模式】时在副本中无法获取经验!!!")
            return 0
        else
            if player:IsInGroup() then
                local group = player:GetGroup()
                local members = group:GetMembers()
                local maxLevel = 1
                for k, v in pairs(members) do
                    if (v:GetLevel() >= maxLevel) then
                        maxLevel = v:GetLevel()
                    end
                end
                if (maxLevel - player:GetLevel() > 10) then
                    player:SendBroadcastMessage("【一命模式】时如果队伍中有大于自己等级10级的玩家不能获取经验!!!")
                    return 0
                else
                    return amount
                end
            else
                return amount
            end
        end
    end
    return amount * 2
end

--开启一命模式
function OnChat(event, player, msg, Type, lang)
    if player == nil then
        return
    end
    if msg == "onelife" then
        local guid = player:GetGUIDLow()
        if oneLifePlayers[guid] ~= nil then
            player:SendBroadcastMessage("已经是一命模式了！")
            return
        end
        if player:GetLevel() == 1 then
            CharDBQuery("INSERT INTO character_one_life (GUID,DEAD) VALUES (" .. guid .. ",0)")
            oneLifePlayers[guid] = 0
            player:SendBroadcastMessage("开启一命模式成功！")
            SendWorldMessage(getPlayerLink(player:GetName()) .. "开启了一命模式！")
            return
        else
            player:SendBroadcastMessage("开启一命模式失败！只有1级角色才能开启一命模式！")
            return
        end
    end
end

--被玩家杀死
function OnPlayerKill(event, killer, killed)
    if killed == nil then
        return
    end
    local guid = killed:GetGUIDLow()
    if oneLifePlayers[guid] == 0 then
        local killerInfo = ""
        if killer ~= nil then
            killerInfo = "击杀者：" .. getPlayerLink(killer:GetName())
        end
        onDeath(killed, killerInfo)
    end
end

--被怪物杀死
function OnCreatureKill(event, killer, killed)
    if killed == nil then
        return
    end
    local guid = killed:GetGUIDLow()
    if oneLifePlayers[guid] == 0 then
        local killerInfo = ""
        if killer ~= nil then
            --查询怪物中文名
            local name = getCreatureName(killer:GetEntry())
            if name ~= "" then
                killerInfo = "击杀者[" .. name .. "]"
            end
        end
        onDeath(killed, killerInfo)
    end
end

--死亡处理
function onDeath(player, killerInfo)
    SendWorldMessage("|cFFFF0000[系统公告]|r 玩家" .. getPlayerLink(player:GetName()) .. "在" .. player:GetLevel() .. "级于[" .. GetAreaName(player:GetAreaId(), 4) .. "]不幸牺牲，" .. killerInfo .. "，集体默哀3分钟！开席了...")
    local guid = player:GetGUIDLow()
    oneLifePlayers[guid] = 1
    player:SaveToDB()
    CharDBQuery("UPDATE character_one_life SET DEAD=1 WHERE GUID=" .. guid)
    CharDBQuery("INSERT INTO one_life_list(guid,account,`name`,`level`,xp,areaId) select guid,account,`name`,`level`,xp," .. player:GetAreaId() .. " as areaId from characters where guid = " .. guid)
end

--70解除一命
function OnLevelChange(event, player, oldLevel)
    if player == nil then
        return
    end
    -- 2级时判断是否开启一命模式，非一命模式自动奖励10个赞助币购买传家宝
    if player:GetLevel() == 2 then
        local guid = player:GetGUIDLow()
        if oneLifePlayers[guid] == nil then
            player:AddItem(80003, 10)
            player:SendBroadcastMessage("非一命模式奖励10个赞助币，可以在新手商人处购买传家宝！！！")
        end
    end
    if player:GetLevel() == 70 then
        local guid = player:GetGUIDLow()
        if oneLifePlayers[guid] ~= nil then
            oneLifePlayers[guid] = nil
            CharDBQuery("DELETE FROM character_one_life WHERE GUID=" .. guid)
            --发奖励
            player:SetAchievement(10000)
            SendMail("恭喜！一命挑战成功！", "亲爱的" .. player:GetName() .. "：\n\n  所有坎坷，终成坦途！愿你永远保持初心，热爱并享受这个世界！\n\n Forever仿官公益服", guid, 0, 61, 0, 10000000, 0, 80011, 1, 80012, 1, 80001, 200, 70102, 1)
            SendWorldMessage("|cFFFF0000[系统公告]|r" .. getPlayerLink(player:GetName()) .. "一命模式挑战成功！")
        end
    end
end

--上线检测
function OnLogin(event, player)
    if player == nil then
        return
    end
    if oneLifePlayers[player:GetGUIDLow()] == 1 then
        player:KickPlayer()
    elseif oneLifePlayers[player:GetGUIDLow()] == 0 then
        player:SendBroadcastMessage("当前角色为一命模式！注意安全！")
    end
end

--玩家名字链接
function getPlayerLink(name)
    return "|cffffffff|Hplayer:" .. name .. "|h[" .. name .. "]|h|r"
end

--获取怪物中文名字
function getCreatureName(entry)
    local result = WorldDBQuery("SELECT Name FROM creature_template_locale WHERE entry=" .. entry .. " and locale='zhCN'")
    local name = ""
    if result ~= nil then
        name = result:GetString(0)
    end
    return name
end

function OnResurrect(event, player)
    if player == nil then
        return
    end
    if oneLifePlayers[player:GetGUIDLow()] == 1 then
        player:KillPlayer()
        player:KickPlayer()
    end
end

--初始建表
CharDBQuery([[
CREATE TABLE IF NOT EXISTS `character_one_life` (
`GUID` INT(10) UNSIGNED NOT NULL COMMENT 'Player guidLow',
`DEAD` TINYINT(3) NOT NULL DEFAULT 0 COMMENT 'Is Dead',
PRIMARY KEY (`GUID`)
)
ENGINE=InnoDB;
]])

--初始加载
local result = CharDBQuery("SELECT GUID,DEAD FROM character_one_life")
if result then
    repeat
        local guid = result:GetUInt32(0)
        local dead = result:GetUInt32(1)
        oneLifePlayers[guid] = dead
    until not result:NextRow()
end

--事件注册
RegisterPlayerEvent(12, OnAddXP) --加经验的时候
RegisterPlayerEvent(18, OnChat) --聊天的时候
RegisterPlayerEvent(13, OnLevelChange) --等级变化的时候
RegisterPlayerEvent(3, OnLogin) --上线的时候
RegisterPlayerEvent(6, OnPlayerKill) --被玩家杀死的时候
RegisterPlayerEvent(8, OnCreatureKill) --被怪杀死的时候
RegisterPlayerEvent(36, OnResurrect) --复活的时候
