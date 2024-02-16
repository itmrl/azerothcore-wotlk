print(">>Script: QuestStone loading...OK")

itemEntry = 90004

local function ShowQuestMenu(event, player, item)
    if (player:IsInCombat() == true) then
        player:SendAreaTriggerMessage("无法在战斗中使用!")
    else
        ShowQuestMenu(event, player, item)
    end
    return false
end

function ShowQuestMenu(event, player, item)
    player:GossipMenuAddItem(0,"-------------异常任务清单--------------", 0, 1);
    local result = CharDBQuery("select id,`name`,`level` from quest_error order by `level` asc")
    if result then
        repeat
            local id = result:GetUInt32(0)
            local name = result:GetString(1)
            local level = result:GetUInt32(2)
            player:GossipMenuAddItem(8, "["..level.."] "..name, 0, id);
        until not result:NextRow()
    end
    player:GossipSendMenu(3550, item)
    return false
end

local function OneQuestSelect(event, player, item, sender, intid, code)
    local questId = intid
    if player:HasQuest(questId) then
        player:CompleteQuest(questId)
        player:SendBroadcastMessage("任务完成！")
    else
        player:SendBroadcastMessage("您尚未领取该任务！")
    end
    player:GossipComplete()
end

RegisterItemGossipEvent(itemEntry, 1, ShowQuestMenu)
RegisterItemGossipEvent(itemEntry, 2, OneQuestSelect)

