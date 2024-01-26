print(">>Script: GMItem loading...OK")

local itemid1 = 70100        --改名
local itemid2 = 70101        --更换种族
local itemid3 = 70102        --专家级骑术
local itemid4 = 70103        --更改性别
local itemid5 = 70104        --更改阵营

local function ResetPlayer(player, flag, text)
    player:SetAtLoginFlag(flag)
    player:SendAreaTriggerMessage("你现在返回角色选择或者重新登录角色，即可进行修改" .. text .. "。")
end

local function ResetName(event, player, item, sender)
    ResetPlayer(player, 0x1, "名字")
    player:RemoveItem(itemid1, 1)
end

local function ResetRace(event, player, item, sender)
    ResetPlayer(player, 0x80, "种族")
    player:RemoveItem(itemid2, 1)
end

local function LearnExpertSkill(event, player, item, sender)
    player:LearnSpell(34091)
    player:RemoveItem(itemid3, 1)
end

local function ResetFace(event, player, item, sender)
    ResetPlayer(player, 0x80, "容貌")
    player:RemoveItem(itemid4, 1)
end

local function ResetFaction(event, player, item, sender)
    ResetPlayer(player, 0x40, "阵营")
    player:RemoveItem(itemid5, 1)
end

RegisterItemEvent(itemid1, 2, ResetName)        --改名
RegisterItemEvent(itemid2, 2, ResetRace)          --更换种族
RegisterItemEvent(itemid3, 2, LearnExpertSkill)    --专家级骑术
RegisterItemEvent(itemid4, 2, ResetFace)          --更改容貌
RegisterItemEvent(itemid5, 2, ResetFaction)    --更改阵营