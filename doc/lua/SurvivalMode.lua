print(">>Script: SurvivalMode loading...OK")
local NPC_ENTRY = 9000008

local survivalModePlayers = {}
local survivalDeadPlayers = {}

-- 常规模式经验倍率
local normalXpRate = 6
-- 硬核模式经验倍率
local hardXpRate = 3
-- 地狱模式经验倍率
local hellXpRate = 1

-- 满级等级
local fullLevel = 80

-- 发送邮件的角色ID
local emailSendGuid = 1

-- 职业颜色
local ClassColor = {
    [1] = "FFC79C6E",  -- 战士
    [2] = "FFF58CBA",  -- 骑士
    [3] = "FFABD473",  -- 猎人
    [4] = "FFFFF569",  -- 盗贼
    [5] = "FFFFFFFF",  -- 牧师
    [6] = "FFC41F3B",  -- 死骑
    [7] = "FF0070DE",  -- 萨满
    [8] = "FF69CCF0",  -- 法师
    [9] = "FF9482C9",  -- 术士
    [11] = "FFFF7d0A", -- 小德
}

-- 得到玩家信息
local function GetPlayerInfo(player)
    local Pcolor = ClassColor[player:GetClass()] or "FF00FF00"    --职业颜色
    local Pname = player:GetName()
    return string.format("[|c%s|Hplayer:%s|h%s|h|r]", Pcolor, Pname, Pname)
end

-- 服务器经验设置为1倍
local function OnAddXP(event, player, amount, victim, source)
    if player == nil then
        return 0
    end
    local guid = player:GetGUIDLow()

    if guid == 1405 then
        return amount * 1.5
    end

    if survivalModePlayers[guid] == nil then      -- 如果未选择生存模式，则无法获取经验
        if player:GetLevel() ~= fullLevel then
            player:SendBroadcastMessage("请在新手村找【生存模式大使】选择生存模式，否则无法获取经验!")
            return 0
        else
            return amount
        end
    elseif survivalModePlayers[guid] == 1 then    -- 常规模式，不限制副本和组队
        return amount * normalXpRate
    elseif survivalModePlayers[guid] == 2 then    -- 硬核模式，限制副本和组队经验，队伍中存在超过5级玩家没有经验，副本中无法获取经验
        local map = player:GetMap()
        local isDungeon = map:IsDungeon()
        if (isDungeon == true) then
            player:SendBroadcastMessage("【硬核模式】时在副本中无法获取经验!!!")
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
                if (maxLevel - player:GetLevel() > 5) then
                    player:SendBroadcastMessage("【硬核模式】时如果队伍中有大于自己等级5级的玩家不能获取经验!!!")
                    return 0
                else
                    return amount * hardXpRate
                end
            else
                return amount * hardXpRate
            end
        end
    elseif survivalModePlayers[guid] == 3 then   -- 地狱模式，限制副本和组队经验，队伍中存在超过5级玩家没有经验，副本中无法获取经验
        local map = player:GetMap()
        local isDungeon = map:IsDungeon()
        if (isDungeon == true) then
            player:SendBroadcastMessage("【地狱模式】时在副本中无法获取经验!!!")
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
                if (maxLevel - player:GetLevel() > 5) then
                    player:SendBroadcastMessage("【地狱模式】时如果队伍中有大于自己等级5级的玩家不能获取经验!!!")
                    return 0
                else
                    return amount * hellXpRate
                end
            else
                return amount * hellXpRate
            end
        end
    end
    player:SendBroadcastMessage("未知情况无法获取经验，请联系管理员！")
    return 0
end

-- 满级80解除模式
local function OnLevelChange(event, player, oldLevel)
    if player == nil then
        return
    end
    if player:GetLevel() == fullLevel then
        local guid = player:GetGUIDLow()
        if survivalModePlayers[guid] ~= nil then
            if survivalModePlayers[guid] == 1 then
                SendWorldMessage("|cFFFF0000[系统公告]|r 玩家 " .. GetPlayerInfo(player) .. " |cFF0000FF【常规模式】|r挑战成功。")
                CharDBQuery("UPDATE character_survival_mode set mode=11,TOTALTIME="..player:GetTotalPlayedTime().." WHERE GUID=" .. guid)
                player:RemoveSpell(90501)
                player:AddItem(80010)
            elseif survivalModePlayers[guid] == 2 then
                -- 硬核成就
                player:SetAchievement(10000)
                SendWorldMessage("|cFFFF0000[系统公告]|r 玩家 " .. GetPlayerInfo(player) .. " |cFF4B0082【硬核模式】|r挑战成功。")
                SendMail("恭喜！硬核模式挑战成功！", "亲爱的" .. player:GetName() .. "：\n\n  所有坎坷，终成坦途！愿你永远保持初心，热爱并享受这个世界！\n\n Forever WLK仿官公益服", guid, emailSendGuid, 61, 0, 10000000, 0, 23162, 1, 23162, 1, 80002, 200, 80001, 80)
                CharDBQuery("UPDATE character_survival_mode set mode=12,TOTALTIME="..player:GetTotalPlayedTime().." WHERE GUID=" .. guid)
                player:RemoveSpell(90502)
                player:AddItem(80010)
            elseif survivalModePlayers[guid] == 3 then
                -- 地狱成就
                player:SetAchievement(10001)
                SendWorldMessage("|cFFFF0000[系统公告]|r 玩家 " .. GetPlayerInfo(player) .. " |cFFB22222【地狱模式】|r挑战成功。")
                SendMail("恭喜！地狱模式挑战成功！", "亲爱的" .. player:GetName() .. "：\n\n  所有坎坷，终成坦途！愿你永远保持初心，热爱并享受这个世界！\n\n Forever WLK仿官公益服", guid, emailSendGuid, 61, 0, 20000000, 0, 23162, 1, 23162, 1, 23162, 1, 23162, 1, 80002, 300, 80001, 150)
                CharDBQuery("UPDATE character_survival_mode set mode=13,TOTALTIME="..player:GetTotalPlayedTime().." WHERE GUID=" .. guid)
                player:RemoveSpell(90503)
                player:AddItem(80010)
            end
            survivalModePlayers[guid] = nil
            survivalDeadPlayers[guid] = nil
        end
    end
end

-- 上线检测
local function OnLogin(event, player)
    if player == nil then
        return
    end
    local guid = player:GetGUIDLow()
    if survivalDeadPlayers[guid] == 1 then
        player:KickPlayer()
    elseif survivalDeadPlayers[guid] == 0 then
        if survivalModePlayers[guid] == 1 then
            player:SendBroadcastMessage("当前角色为【常规模式】！")
        elseif survivalModePlayers[guid] == 2 then
            player:SendBroadcastMessage("当前角色为【硬核模式】！注意安全！")
        elseif survivalModePlayers[guid] == 3 then
            player:SendBroadcastMessage("当前角色为【地狱模式】！注意安全！")
        end
    end
end

-- 死亡处理
local function onDeath(player, killerInfo)
    SendWorldMessage("|cFFFF0000[系统公告]|r 玩家" .. GetPlayerInfo(player) .. "在" .. player:GetLevel() .. "级于[" .. GetAreaName(player:GetAreaId(), 4) .. "]不幸牺牲，" .. killerInfo .. "，集体默哀3分钟！开席了...")
    local guid = player:GetGUIDLow()
    local accountId = player:GetAccountId()
    survivalDeadPlayers[guid] = 1
    player:SaveToDB()
    CharDBQuery("UPDATE character_survival_mode SET DEAD=1 WHERE GUID=" .. guid)
    CharDBQuery("INSERT INTO one_life_list(guid,account,`name`,`level`,xp,areaId) select guid,account,`name`,`level`,xp," .. player:GetAreaId() .. " as areaId from characters where guid = " .. guid)
end

-- 被玩家杀死
local function OnPlayerKill(event, killer, killed)
    if killed == nil then
        return
    end
    local guid = killed:GetGUIDLow()
    if survivalModePlayers[guid] == 2 or survivalModePlayers[guid] == 3 then
        if survivalDeadPlayers[guid] == 0  then
            local killerInfo = ""
            if killer ~= nil then
                killerInfo = "击杀者：" .. GetPlayerInfo(killer)
            end
            onDeath(killed, killerInfo)
        end
    end
end

-- 获取怪物中文名字
local function getCreatureName(entry)
    local result = WorldDBQuery("SELECT Name FROM creature_template_locale WHERE entry=" .. entry .. " and locale='zhCN'")
    local name = ""
    if result ~= nil then
        name = result:GetString(0)
    end
    return name
end

-- 被怪物杀死
local function OnCreatureKill(event, killer, killed)
    if killed == nil then
        return
    end
    local guid = killed:GetGUIDLow()
    if survivalModePlayers[guid] == 2 or survivalModePlayers[guid] == 3 then
        if survivalDeadPlayers[guid] == 0  then
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
end

-- 复活
local function OnResurrect(event, player)
    if player == nil then
        return
    end
    if survivalDeadPlayers[player:GetGUIDLow()] == 1 then
        player:KillPlayer()
        player:KickPlayer()
    end
end

local function OneMenu(event, player, creature)
    local guid = player:GetGUIDLow()
    if player:GetLevel() == fullLevel then
        player:GossipMenuAddItem(0, "————————|n您已经满级了，不能选择生存模式！|n————————|n|n", 0, 999)
    else
        if survivalModePlayers[guid] == nil then
            player:GossipMenuAddItem(0, "————————|n您尚未选择生存模式|n————————|n|n", 0, 999)
            player:GossipMenuAddItem(0, "|TInterface\\icons\\achievement_reputation_01:30:30:0:0|t 开启|cFF0000FF【常规模式】|r", 0, 1, false, "重要提示\n 选择模式前请仔细阅读生存模式说明！")
            player:GossipMenuAddItem(0, "|TInterface\\icons\\Ability_Warrior_TitansGrip:30:30:0:0|t 开启|cFF4B0082【硬核模式】|r", 0, 2, false, "重要提示\n 选择模式前请仔细阅读生存模式说明！")
            player:GossipMenuAddItem(0, "|TInterface\\icons\\Ability_Creature_Cursed_02:30:30:0:0|t 开启|cFFB22222【地狱模式】|r", 0, 3, false, "重要提示\n 选择模式前请仔细阅读生存模式说明！")
        elseif survivalModePlayers[guid] == 1 then
            player:GossipMenuAddItem(0, "————————|n您现在是：|cFF0000FF【常规模式】|n————————|n|n", 0, 999)
        elseif survivalModePlayers[guid] == 2 then
            player:GossipMenuAddItem(0, "————————|n您现在是：|cFF4B0082【硬核模式】|n————————|n|n", 0, 999)
        elseif survivalModePlayers[guid] == 3 then
            player:GossipMenuAddItem(0, "————————|n您现在是：|cFFB22222【地狱模式】|n————————|n|n", 0, 999)
        end
        player:GossipMenuAddItem(0, "|TInterface\\icons\\Spell_ChargePositive:30:30:0:0|t 生存模式说明", 0, 5)
    end
    player:GossipSendMenu(1, creature)
end

local function OneSelect(event, player, creature, sender, intid, code)
    if (intid == 1) then
        local guid = player:GetGUIDLow()
        if survivalModePlayers[guid] ~= nil then
            player:SendBroadcastMessage("您已经选择了生存模式！")
            return
            player:GossipComplete()
        else
            CharDBQuery("INSERT INTO character_survival_mode (GUID,MODE) VALUES (" .. guid .. ",1)")
            survivalModePlayers[guid] = 1
            survivalDeadPlayers[guid] = 0
            -- 常规模式奖励10个新人币购买传家宝
            player:AddItem(80003,10)
            player:SendBroadcastMessage("开启【常规模式】成功！")
            if player:GetLevel() ~= 70 then
                SendWorldMessage("|cFFFF0000[系统公告]|r 玩家 " .. GetPlayerInfo(player) .. " 开启了|cFF0000FF【常规模式】|r。")
            end
            player:GossipComplete()
        end
    elseif (intid == 2) then
        local limitLevel = 1
        local cl = player:GetClass() --获取玩家的职业
        if cl == 6 then
            limitLevel = 55
        end
        if player:GetLevel() == limitLevel then
            local guid = player:GetGUIDLow()
            if survivalModePlayers[guid] ~= nil then
                player:SendBroadcastMessage("您已经选择了生存模式！")
                player:GossipComplete()
                return
            else
                -- 判断是否为DK，如果是DK则需要判断该角色所属账户下是否有超55级且存活的一命角色，如果有则允许
                local accountId = player:GetAccountId()
                local cl = player:GetClass() --获取玩家的职业
                if cl == 6 then
                    local result = CharDBQuery("SELECT t1.guid,t1.level,t2.mode,t2.dead FROM characters t1 inner join character_survival_mode t2 on t1.guid = t2.guid where t2.mode in (2,3) and t2.dead = 0 and t1.level>=55 and t1.account="..accountId)
                    if result then
                        if result:GetRowCount() == 0 then
                            player:SendBroadcastMessage("DK开启【硬核模式】必须该账号下存在至少1个一命角色(未死亡)且等级不小于55级！")
                            player:GossipComplete()
                            return
                        else
                            -- 将非DK的一命(未死亡)且等级不小于55级角色的标识为死亡
                            local result = CharDBQuery("SELECT t1.guid,t1.level,t2.mode,t2.dead FROM characters t1 inner join character_survival_mode t2 on t1.guid = t2.guid where t2.mode in (2,3) and t2.dead = 0 and t1.class!=6 and t1.level>=55 and t1.account="..accountId)
                            if result then
                                repeat
                                    local gid = result:GetUInt32(0)
                                    survivalDeadPlayers[gid] = 1
                                    CharDBQuery("UPDATE character_survival_mode SET DEAD=1 WHERE GUID=" .. gid)
                                until not result:NextRow()
                            end
                            player:GossipComplete()
                        end
                    else
                        player:SendBroadcastMessage("DK开启【硬核模式】必须该账号下存在至少1个一命角色(未死亡)且等级不小于55级！")
                        player:GossipComplete()
                        return
                    end
                end
                CharDBQuery("INSERT INTO character_survival_mode (GUID,MODE) VALUES (" .. guid .. ",2)")
                survivalModePlayers[guid] = 2
                survivalDeadPlayers[guid] = 0
                player:SendBroadcastMessage("开启【硬核模式】成功！")
                player:GossipComplete()
                SendWorldMessage("|cFFFF0000[系统公告]|r 玩家 " .. GetPlayerInfo(player) .. " 开启了|cFF4B0082【硬核模式】|r, 升级之路充满坎坷，祝您一切顺利！。")
            end
        else
            player:SendBroadcastMessage("开启【硬核模式】失败，只有1级非DK或者55级DK角色才能开启【硬核模式】！")
            return
            player:GossipComplete()
        end
    elseif (intid == 3) then
        local limitLevel = 1
        local cl = player:GetClass() --获取玩家的职业
        if cl == 6 then
            limitLevel = 55
        end
        if player:GetLevel() == limitLevel then
            local guid = player:GetGUIDLow()
            if survivalModePlayers[guid] ~= nil then
                player:SendBroadcastMessage("您已经选择了生存模式！")
                player:GossipComplete()
                return
            else
                -- 判断是否为DK，如果是DK则需要判断该角色所属账户下是否有超55级且存活的一命角色，如果有则允许
                local accountId = player:GetAccountId()
                local cl = player:GetClass() --获取玩家的职业
                if cl == 6 then
                    local result = CharDBQuery("SELECT t1.guid,t1.level,t2.mode,t2.dead FROM characters t1 inner join character_survival_mode t2 on t1.guid = t2.guid where t2.mode in (2,3) and t2.dead = 0 and t1.level>=55 and t1.account="..accountId)
                    if result then
                        if result:GetRowCount() == 0 then
                            player:SendBroadcastMessage("DK开启【地狱模式】必须该账号下存在至少1个一命角色(未死亡)且等级不小于55级！")
                            player:GossipComplete()
                            return
                        else
                            -- 将非DK的一命(未死亡)且等级不小于55级角色的标识为死亡
                            local result = CharDBQuery("SELECT t1.guid,t1.level,t2.mode,t2.dead FROM characters t1 inner join character_survival_mode t2 on t1.guid = t2.guid where t2.mode in (2,3) and t2.dead = 0 and t1.class!=6 and t1.level>=55 and t1.account="..accountId)
                            if result then
                                repeat
                                    local gid = result:GetUInt32(0)
                                    survivalDeadPlayers[gid] = 1
                                    CharDBQuery("UPDATE character_survival_mode SET DEAD=1 WHERE GUID=" .. gid)
                                until not result:NextRow()
                            end
                            player:GossipComplete()
                        end
                    else
                        player:SendBroadcastMessage("DK开启【地狱模式】必须该账号下存在至少1个一命角色(未死亡)且等级不小于55级！")
                        player:GossipComplete()
                        return
                    end
                end
                CharDBQuery("INSERT INTO character_survival_mode (GUID,MODE) VALUES (" .. guid .. ",3)")
                survivalModePlayers[guid] = 3
                survivalDeadPlayers[guid] = 0
                player:SendBroadcastMessage("开启【地狱模式】成功！")
                SendWorldMessage("|cFFFF0000[系统公告]|r 玩家 " .. GetPlayerInfo(player) .. " 开启了|cFF4B0082【地狱模式】|r, 升级之路充满坎坷，祝您一切顺利！。")
                player:GossipComplete()
            end
        else
            player:SendBroadcastMessage("开启【地狱模式】失败，只有1级非DK或者55级DK角色才能开启【地狱模式】！")
            return
            player:GossipComplete()
        end
    elseif (intid == 5) then
        local x, y, z, o = player:GetX(), player:GetY(), player:GetZ(), player:GetO(), player:GetAreaId()
        player:GossipComplete()
        player:GossipClearMenu()
        player:GossipMenuAddItem(30, "游戏生存模式说明", 0, 1, false, "|TInterface/FlavorImages/BloodElfLogo-small:64:64:0:-30|t\n\n|c0096FF96★游戏生存模式说明★|r\n\n\n\n|cFF0000FF【常规模式】|r：经验6倍，死亡后可以复活，可以购买传家宝，副本中可以获取经验。\n\n|cFF4B0082【硬核模式】|r：经验3倍，死亡后无法复活，无法购买传家宝，副本中无法获取经验，满级后获取专属称号及专家模式奖励。\n\n|cFFB22222【地狱模式】|r：经验1倍，死亡后无法复活，无法购买传家宝，副本中无法获取经验，满级后获取专属称号及地狱模式奖励。\n\n DK开启【硬核模式】【地狱模式】必须该账号下存在至少1个一命角色(未死亡)且等级不小于55级，开启后账号下其他一命角色标识为死亡！ \n\n  一命模式复活条件：服务器集体卡顿、宕机，法师闪现、战士冲锋等卡虚空情况且有截图证明的。个人原因掉线，一些特殊任务比如视灵药剂、地狱火黑暗之门等情况导致死亡的均不予复活！")
        player:GossipSendMenu(100, player, 0)
    else
        player:GossipComplete()
    end
end

--初始建表
CharDBQuery([[
CREATE TABLE IF NOT EXISTS `character_survival_mode` (
`GUID` INT(10) UNSIGNED NOT NULL COMMENT 'Player guidLow',
`MODE` TINYINT(3) NOT NULL COMMENT '生存模式：1-普通模式、2-硬核模式、3-地狱模式',
`DEAD` TINYINT(3) NOT NULL DEFAULT 0 COMMENT '是否死亡：1-已死亡、0-未死亡',
`TOTALTIME` INT(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '游戏时间',
PRIMARY KEY (`GUID`)
)
ENGINE=InnoDB;
]])

CharDBQuery([[
CREATE TABLE IF NOT EXISTS `one_life_list` (
 `guid` int unsigned NOT NULL,
 `account` int unsigned NOT NULL COMMENT 'Account Identifier',
 `name` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
 `level` tinyint unsigned NOT NULL,
 `xp` int unsigned NOT NULL,
 `areaId` int unsigned NULL,
 PRIMARY KEY (`guid`) USING BTREE
)
ENGINE=InnoDB;
]])

--初始加载
local result = CharDBQuery("SELECT GUID,MODE,DEAD FROM character_survival_mode where mode < 10")
if result then
    repeat
        local guid = result:GetUInt32(0)
        local mode = result:GetUInt32(1)
        local dead = result:GetUInt32(2)
        survivalModePlayers[guid] = mode
        survivalDeadPlayers[guid] = dead
    until not result:NextRow()
end

--事件注册
RegisterPlayerEvent(3, OnLogin) --上线的时候
RegisterPlayerEvent(6, OnPlayerKill) --被玩家杀死的时候
RegisterPlayerEvent(8, OnCreatureKill) --被怪杀死的时候
RegisterPlayerEvent(12, OnAddXP) --加经验的时候
RegisterPlayerEvent(13, OnLevelChange) --等级变化的时候
RegisterPlayerEvent(36, OnResurrect) --复活的时候
RegisterCreatureGossipEvent(NPC_ENTRY, 1, OneMenu)
RegisterCreatureGossipEvent(NPC_ENTRY, 2, OneSelect)
