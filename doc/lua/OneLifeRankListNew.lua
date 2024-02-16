print(">>Script: OneLifeRankList loading...OK")

function ShowRankList(event, player, item)
    if (player:IsInCombat() == true) then
        player:SendAreaTriggerMessage("无法在战斗中查看排行榜!")
    else
        ShowRankMenu(item, player)
    end
end

function ShowRankMenu(item, player)
    player:GossipMenuAddItem(1,"--------【硬核模式噶榜】---------", 0, 1);
    player:GossipMenuAddItem(1,"--------【地狱模式噶榜】---------", 0, 2);
    player:GossipSendMenu(3550, item)
end


local function OneSelect(event, player, item, sender, intid, code)
    if (intid == 1) then
        player:GossipMenuAddItem(0,"--------硬核模式英雄榜单---------", 0, 1);
        local result = CharDBQuery("select t1.guid,t1.account,t1.`name`,t1.`level`,t1.xp,t1.areaId,t2.`MODE` from one_life_list t1 inner join character_survival_mode t2 on t1.guid = t2.guid where t2.mode in (2) order by `level` desc,xp desc limit 10")
        if result then
            local num = 1
            repeat
                local guid = result:GetUInt32(0)
                local account = result:GetUInt32(1)
                local name = result:GetString(2)
                local level = result:GetUInt32(3)
                local xp = result:GetUInt32(4)
                local areaId = result:GetUInt32(5)
                player:GossipMenuAddItem(8, " |cFFCC0000第" .. num .. "名 " .. name .. "，" .. level .. "级，葬于[" .. GetAreaName(areaId, 4) .. "]", 0, 1);
                num = num + 1
            until not result:NextRow()
        end
        player:GossipSendMenu(3551, item)
    elseif (intid == 2) then
        player:GossipMenuAddItem(0,"--------地狱模式英雄榜单---------", 0, 1);
        local result = CharDBQuery("select t1.guid,t1.account,t1.`name`,t1.`level`,t1.xp,t1.areaId,t2.`MODE` from one_life_list t1 inner join character_survival_mode t2 on t1.guid = t2.guid where t2.mode in (3) order by `level` desc,xp desc limit 10")
        if result then
            local num = 1
            repeat
                local guid = result:GetUInt32(0)
                local account = result:GetUInt32(1)
                local name = result:GetString(2)
                local level = result:GetUInt32(3)
                local xp = result:GetUInt32(4)
                local areaId = result:GetUInt32(5)
                player:GossipMenuAddItem(8, " |cFFCC0000第" .. num .. "名 " .. name .. "，" .. level .. "级，葬于[" .. GetAreaName(areaId, 4) .. "]", 0, 11);
                num = num + 1
            until not result:NextRow()
        end
        player:GossipSendMenu(3551, item)
    end
end

RegisterGameObjectGossipEvent(500000, 1, ShowRankList)
RegisterGameObjectGossipEvent(500000, 2, OneSelect)
