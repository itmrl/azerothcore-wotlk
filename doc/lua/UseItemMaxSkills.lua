print(">>Script: UseItemMaxSkills loading...OK")

local itemid1 = 70001        --宗师级锻造
local itemid2 = 70002        --宗师级采矿
local itemid3 = 70003        --宗师级炼金术
local itemid4 = 70004        --宗师级裁缝
local itemid5 = 70005        --宗师级烹饪
local itemid6 = 70006        --宗师级制皮
local itemid7 = 70007        --宗师级钓鱼
local itemid8 = 70008        --宗师级附魔
local itemid9 = 70009        --宗师级珠宝加工
local itemid10 = 70010        --宗师级工程学
local itemid11 = 70011        --宗师级急救
local itemid12 = 70012        --宗师级草药学
local itemid13 = 70013        --宗师级剥皮
local itemid14 = 70014        --宗师级铭文学
local itemid15 = 70015        --直升70

local function Item_Event_jijiu(event, player, item, sender)
    --学习急救
    if player:HasSpell(27028) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid11) then
        if player:HasSpell(3273) then
            player:LearnSpell(3274) --中级急救
            player:LearnSpell(7924) --高级急救
            player:LearnSpell(10846) --专家急救
            player:LearnSpell(27028) --大师急救
            player:AdvanceSkill(129, 375)
            player:RemoveItem(itemid11, 1)
            player:SendNotification("您学会了急救技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_pengren(event, player, item, sender)
    --学习烹饪
    if player:HasSpell(33359) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid5) then
        if player:HasSpell(2550) then
            player:LearnSpell(3102) --中级烹饪
            player:LearnSpell(3413) --高级烹饪
            player:LearnSpell(18260) --专家烹饪
            player:LearnSpell(33359) --大师烹饪
            player:AdvanceSkill(185, 375)
            player:RemoveItem(itemid5, 1)
            player:SendNotification("您学会了烹饪技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_diaoyu(event, player, item, sender)
    --学习钓鱼
    if player:HasSpell(33095) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid7) then
        if player:HasSpell(7620) then
            player:LearnSpell(7731) --中级钓鱼
            player:LearnSpell(7732) --高级钓鱼
            player:LearnSpell(18248) --专家钓鱼
            player:LearnSpell(33095) --大师钓鱼
            player:AdvanceSkill(356, 375)
            player:RemoveItem(itemid7, 1)
            player:SendNotification("您学会了钓鱼技能,并达到了宗师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_caikuang(event, player, item, sender)
    --学习采矿
    if player:HasSpell(29354) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
        return
    elseif player:HasItem(itemid2) then
        if player:HasSpell(2575) then
            player:LearnSpell(2576) --中级采矿
            player:LearnSpell(3564) --高级采矿
            player:LearnSpell(10248) --专家采矿
            player:LearnSpell(29354) --大师采矿
            player:AdvanceSkill(186, 375)
            player:RemoveItem(itemid2, 1)
            player:SendNotification("您学会了采矿技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_duanzao(event, player, item, sender)
    --学习锻造
    if player:HasSpell(51300) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid1) then
        if player:HasSpell(2018) then
            player:LearnSpell(3100) --中级锻造
            player:LearnSpell(3538) --高级锻造
            player:LearnSpell(9785) --专家锻造
            player:LearnSpell(29844) --大师锻造
            player:AdvanceSkill(164, 375)
            player:RemoveItem(itemid1, 1)
            player:SendNotification("您学会了锻造技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_bopi(event, player, item, sender)
    --学习剥皮
    if player:HasSpell(50305) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid13) then
        if player:HasSpell(8613) then
            player:LearnSpell(8617) --中级剥皮
            player:LearnSpell(8618) --高级剥皮
            player:LearnSpell(10768) --专家剥皮
            player:LearnSpell(32678) --大师剥皮
            player:AdvanceSkill(393, 375)
            player:RemoveItem(itemid13, 1)
            player:SendNotification("您学会了剥皮技能,并达到了宗师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_zhipi(event, player, item, sender)
    --学习制皮
    if player:HasSpell(51302) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid6) then
        if player:HasSpell(2108) then
            player:LearnSpell(3104) --中级制皮
            player:LearnSpell(3811) --高级制皮
            player:LearnSpell(10662) --专家制皮
            player:LearnSpell(32549) --大师制皮
            player:AdvanceSkill(165, 375)
            player:RemoveItem(itemid6, 1)
            player:SendNotification("您学会了制品技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_caifeng(event, player, item, sender)
    --学习裁缝
    if player:HasSpell(26790) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid4) then
        if player:HasSpell(3908) then
            player:LearnSpell(3909) --中级裁缝
            player:LearnSpell(3910) --高级裁缝
            player:LearnSpell(12180) --专家裁缝
            player:LearnSpell(26790) --大师裁缝
            player:AdvanceSkill(197, 375)
            player:RemoveItem(itemid4, 1)
            player:SendNotification("您学会了裁缝技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_fumo(event, player, item, sender)
    --学习附魔
    if player:HasSpell(51313) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid8) then
        if player:HasSpell(7411) then
            player:LearnSpell(7412) --中级附魔
            player:LearnSpell(7413) --高级附魔
            player:LearnSpell(13920) --专家附魔
            player:LearnSpell(28029) --大师附魔
            player:AdvanceSkill(333, 375)
            player:RemoveItem(itemid8, 1)
            player:SendNotification("您学会了附魔技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_caiyao(event, player, item, sender)
    --学习采药
    if player:HasSpell(50300) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid12) then
        if player:HasSpell(2366) then
            player:LearnSpell(2368) --中级采药
            player:LearnSpell(3570) --高级采药
            player:LearnSpell(11993) --专家采药
            player:LearnSpell(28695) --大师采药
            player:AdvanceSkill(182, 375)
            player:RemoveItem(itemid12, 1)
            player:SendNotification("您学会了采药技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_lianjin(event, player, item, sender)
    --学习炼金
    if player:HasSpell(51304) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid3) then
        if player:HasSpell(2259) then
            player:LearnSpell(3101) --中级炼金
            player:LearnSpell(3464) --高级炼金
            player:LearnSpell(11611) --专家炼金
            player:LearnSpell(28596) --大师炼金
            player:AdvanceSkill(171, 375)
            player:RemoveItem(itemid3, 1)
            player:SendNotification("您学会了炼金技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_gongcheng(event, player, item, sender)
    --学习工程
    if player:HasSpell(51306) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid10) then
        if player:HasSpell(4036) then
            player:LearnSpell(4037) --中级工程
            player:LearnSpell(4038) --高级工程
            player:LearnSpell(12656) --专家工程
            player:LearnSpell(30350) --大师工程
            player:AdvanceSkill(202, 375)
            player:RemoveItem(itemid10, 1)
            player:SendNotification("您学会了工程技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_zhubao(event, player, item, sender)
    --学习珠宝
    if player:HasSpell(51311) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid9) then
        if player:HasSpell(25229) then
            player:LearnSpell(25230) --中级珠宝
            player:LearnSpell(28894) --高级珠宝
            player:LearnSpell(28895) --专家珠宝
            player:LearnSpell(28897) --大师珠宝
            player:AdvanceSkill(755, 375)
            player:RemoveItem(itemid9, 1)
            player:SendNotification("您学会了珠宝技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_Event_mingwen(event, player, item, sender)
    --学习铭文
    if player:HasSpell(45363) then
        player:SendNotification("你已经掌握此技能!不能重复学习！")
    elseif
    player:HasItem(itemid14) then
        if player:HasSpell(45357) then
            player:LearnSpell(45358) --中级铭文
            player:LearnSpell(45359) --高级铭文
            player:LearnSpell(45360) --专家铭文
            player:LearnSpell(45361) --大师铭文
            player:AdvanceSkill(773, 375)
            player:RemoveItem(itemid14, 1)
            player:SendNotification("您学会了铭文技能,并达到了大师级别!")
        else
            player:SendNotification("请选学习该专业技能！")
            return
        end
    end
end

local function Item_event_level(event, player, item, sender)
    local cl = player:GetClass() --获取玩家的职业
    local lv = player:GetLevel() --获取玩家的等级
    if (lv < 70) then
        -- 如果是DK
        if cl == 6 then
            local STARTER_QUESTS = { 12593, 12619, 12842, 12848, 12636, 12641, 12657, 12678, 12679, 12680, 12687, 12698, 12701, 12706, 12716, 12719, 12720, 12722, 12724, 12725, 12727, 12733, -1, 12751, 12754, 12755, 12756, 12757, 12779, 12801, 13165, 13166 };
            local specialSurpriseQuestId = -1
            local race = player:GetRace()
            local team = player:GetTeam()
            if race == 6 then
                specialSurpriseQuestId = 12739
            elseif race == 4 then
                specialSurpriseQuestId = 12743;
            elseif race == 3 then
                specialSurpriseQuestId = 12744;
            elseif race == 7 then
                specialSurpriseQuestId = 12745;
            elseif race == 11 then
                specialSurpriseQuestId = 12746;
            elseif race == 10 then
                specialSurpriseQuestId = 12747;
            elseif race == 2 then
                specialSurpriseQuestId = 12748;
            elseif race == 8 then
                specialSurpriseQuestId = 12749;
            elseif race == 5 then
                specialSurpriseQuestId = 12750;
            elseif race == 1 then
                specialSurpriseQuestId = 12742;
            end
            STARTER_QUESTS[23] = specialSurpriseQuestId;
            if team == 0 then
                STARTER_QUESTS[33] = 13188
            else
                STARTER_QUESTS[33] = 13189
            end
            --用一个for循环，依次对任务进行处理
            for k, v in ipairs(STARTER_QUESTS) do
                local quest_status = player:GetQuestStatus(v)
                if quest_status == 0 then
                    --没这个任务，自动加这个任务，然后完成
                    player:AddQuest(v)
                    player:CompleteQuest(v)
                    player:RewardQuest(v)
                end
            end
            player:AddItem(38664);
            player:AddItem(39322);
            player:AddItem(38632);
            player:SetLevel(70) --设置到70级
            player:SaveToDB() --保存到DB
            player:RemoveItem(itemid15, 1)
        else
            player:SetLevel(70) --设置到70级
            player:SaveToDB() --保存到DB
            player:RemoveItem(itemid15, 1)
        end
    else
        player:SendNotification("您已经满级不能使用该物品!")
        return
    end
end

RegisterItemEvent(itemid1, 2, Item_Event_duanzao) --宗师级锻造
RegisterItemEvent(itemid2, 2, Item_Event_caikuang) --宗师级采矿
RegisterItemEvent(itemid3, 2, Item_Event_lianjin) --宗师级炼金术
RegisterItemEvent(itemid4, 2, Item_Event_caifeng) --宗师级裁缝
RegisterItemEvent(itemid5, 2, Item_Event_pengren) --宗师级烹饪
RegisterItemEvent(itemid6, 2, Item_Event_zhipi) --宗师级制皮
RegisterItemEvent(itemid7, 2, Item_Event_diaoyu) --宗师级钓鱼
RegisterItemEvent(itemid8, 2, Item_Event_fumo) --宗师级附魔
RegisterItemEvent(itemid9, 2, Item_Event_zhubao) --宗师级珠宝加工
RegisterItemEvent(itemid10, 2, Item_Event_gongcheng) --宗师级工程学
RegisterItemEvent(itemid11, 2, Item_Event_jijiu) --宗师级急救
RegisterItemEvent(itemid12, 2, Item_Event_caiyao) --宗师级草药学
RegisterItemEvent(itemid13, 2, Item_Event_bopi) --宗师级剥皮
RegisterItemEvent(itemid14, 2, Item_Event_mingwen) --宗师级铭文学
RegisterItemEvent(itemid15, 2, Item_event_level)