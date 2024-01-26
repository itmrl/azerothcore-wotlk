print(">>Script: DungeonReset loading...OK")

local itemId01 = 90201        --英雄地狱火城墙
local itemId02 = 90202        --英雄鲜血熔炉
local itemId03 = 90202        --英雄破碎大厅

-- 英雄地狱火城墙
local function ResetDungeon01(event, player, item, sender)
    player:UnbindInstance(543, 1)
    player:SendAreaTriggerMessage("英雄地狱火城墙副本重置成功")
end

-- 英雄鲜血熔炉
local function ResetDungeon02(event, player, item, sender)
    player:UnbindInstance(542, 1)
    player:SendAreaTriggerMessage("英雄鲜血熔炉副本重置成功")
end

-- 英雄破碎大厅
local function ResetDungeon03(event, player, item, sender)
    player:UnbindInstance(540, 1)
    player:SendAreaTriggerMessage("英雄破碎大厅副本重置成功")
end

RegisterItemEvent(itemId01, 2, ResetDungeon01)
RegisterItemEvent(itemId02, 2, ResetDungeon02)
RegisterItemEvent(itemId03, 2, ResetDungeon03)