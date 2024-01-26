print(">>Script: OneLifeRankList loading...OK")

function ShowRankList(event, player, item)
    if (player:IsInCombat() == true) then
        player:SendAreaTriggerMessage("无法在战斗中查看排行榜!")
    else
        ShowRankMenu(item, player)
    end
end

function ShowRankMenu(item, player)
    local result = CharDBQuery("select guid,account,`name`,`level`,xp,areaId from one_life_list order by `level` desc,xp desc limit 10")
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
    player:GossipSendMenu(3550, item)
end

RegisterGameObjectGossipEvent(500000, 1, ShowRankList)