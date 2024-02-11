local CONFIG = {
    maxLevel = 80, -- 脚本设置服务的最高等级（用于升级服务）
    mailSenderGUID = 1679, -- 发邮件的角色GUID 数据库的characters表
    strings = {
        insufficientFunds = "你没有足够的", -- 提示你没有足够的“货币”
        alreadyKnown = "你已经有了这个", -- 提示你这个“技能”“物品”
        tooHighLevel = "您已满级不能使用本服务", --提示
        mailBody = "感谢您的购买！", --邮件提示内容
        successfulPurchase = "购买成功！"--提示
    }
}
--------------------
local AIO = AIO or require("AIO") and require("Store_DataStruct")

local CURRENCY_TYPES = {   --货币类型
    [1] = "GOLD",
    [2] = "SUPPORT_ICON",
    [3] = "SCORE"
}

local SHOP_UI = {  --商品种类
    serviceHandlers = {
        [3] = "ItemHandler", --  商业材料
        [4] = "ItemsHandler", --  变身道具
        [5] = "MountHandler", --  坐骑宠物
        [6] = "BuffHandler", --  增益效果
        [7] = "SKILLHandler", --  专业技能
        [8] = "SpellHandler", --  魔法技能
        [9] = "transHandler", --  幻化装扮
        [10] = "TitleHandler", --  头衔称号
        [11] = "ServiceHandler", --  系统服务
        [12] = "LevelHandler", --  等级提升
        [13] = "GoldHandler", --  货币代币
    }
}

local KEYS = GetDataStructKeys(); --获取数值
local StoreHandler = AIO.AddHandlers("STORE_SERVER", {})
function StoreHandler.FrameData(player)
    AIO.Handle(player, "STORE_CLIENT", "FrameData", GetServiceData(), GetLinkData(), GetNavData(), GetCurrencyData(), player:GetGMRank())
end

function StoreHandler.UpdateCurrencies(player)
    -- 此项是显示在商城左下角货币数量的相关设置
    local tmp = {}
    for currencyId, currency in pairs(GetCurrencyData()) do
        local val = 0
        local currencyTypeText = CURRENCY_TYPES[currency[KEYS.currency.currencyType]]
        -- 处理不同的货币类型
        if (currencyTypeText == "GOLD") then
            -- 若是金币，则除10000以表示多少金
            val = math.floor(player:GetCoinage() / 10000)
        end

        if (currencyTypeText == "SUPPORT_ICON") then
            -- 若是其它，则直接显示数量
            val = player:GetItemCount(currency[KEYS.currency.data])
        end

        if (currencyTypeText == "SCORE") then
            --可以添加更多货币种类和说明
            val = player:GetItemCount(currency[KEYS.currency.data])
        end

        if (val > 9999) then
            --	如果值大于10k，则直接显示9999+
            val = "9999+"
        end

        table.insert(tmp, val)
    end
    AIO.Handle(player, "STORE_CLIENT", "UpdateCurrencies", tmp)
end

function StoreHandler.Purchase(player, serviceId)
    -- 此项是商城购买物品相关数据
    local services = GetServiceData()

    if (services[serviceId]) then
        -- 将id添加到服务子表中，不必更多的变量
        services[serviceId].ID = serviceId
        local typeId = services[serviceId][KEYS.service.serviceType]

        local serviceHandler = SHOP_UI[SHOP_UI.serviceHandlers[typeId]]
        if (serviceHandler) then
            local success = serviceHandler(player, services[serviceId])
            if (success) then
                -- 如果购买成功，更新UI中的玩家货币并记录购买
                StoreHandler.UpdateCurrencies(player)
                SHOP_UI.LogPurchase(player, services[serviceId])

                -- 购买成功声音
                player:PlayDirectSound(120, player)

                -- 购买成功提示
                player:SendAreaTriggerMessage(services[serviceId][KEYS.service.name] .. " " .. CONFIG.strings.successfulPurchase)
            end
        end
    end
end
function SHOP_UI.DeductCurrency(player, currencyId, amount)
    -- 此项是扣款相关数据
    local currency = GetCurrencyData()
    local currencyType = currency[currencyId][KEYS.currency.currencyType]
    local currencyName = currency[currencyId][KEYS.currency.name]
    local currencyData = currency[currencyId][KEYS.currency.data]

    if (CURRENCY_TYPES[currencyType] == "GOLD") then
        -- 如果是金币的扣除方式
        if (player:GetCoinage() < amount * 10000) then
            player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.insufficientFunds .. " " .. currencyName .. "|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end

        player:SetCoinage(player:GetCoinage() - (amount * 10000)) -- 余额金币=现有金币-商品金币
    end

    -- Token handling
    if (CURRENCY_TYPES[currencyType] == "SUPPORT_ICON") then
        -- 如果是其它代币的扣除方式
        if not (player:HasItem(currencyData, amount)) then
            player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.insufficientFunds .. " " .. currencyName .. "|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end

        player:RemoveItem(currencyData, amount) -- 移除商品所需要的代币数量
    end

    if (CURRENCY_TYPES[currencyType] == "SCORE") then
        -- 如果是其它代币的扣除方式
        if not (player:HasItem(currencyData, amount)) then
            player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.insufficientFunds .. " " .. currencyName .. "|r")
            player:PlayDirectSound(GetSoundEffect("notEnoughMoney", player:GetRace(), player:GetGender()), player)
            return false
        end

        player:RemoveItem(currencyData, amount) -- 移除商品所需要的代币数量
    end

    return true
end
function SHOP_UI.LogPurchase(player, data)
    --购买日志
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    WorldDBExecute("INSERT INTO store.store_logs(account, guid, serviceId, currencyId, cost) VALUES(" .. player:GetAccountId() .. ", " .. player:GetGUIDLow() .. ", " .. data.ID .. ", " .. currency .. ", " .. amount .. ");")
end

--3、物品
function SHOP_UI.ItemHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折

    for i = 0, 7 do
        --依次循环发放8套物品
        for j = 1, data[KEYS.service.rewardCount_1 + i] do
            if (data[KEYS.service.reward_1 + i] == 90002) then
                if (player:GetLevel() ~= 80) then
                    --一命模式玩家禁止使用该服务。
                    player:SendAreaTriggerMessage("|cFFFF0000满级才允许使用本服务！|r")
                    player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
                    return false
                end
            end
        end
    end

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币

    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    --for i = 0, 7 do
    --    player:AddItem(data[KEYS.service.reward_1 + i], data[KEYS.service.rewardCount_1 + i]) -- 发放所有物品
    --end

    for i = 0, 7 do
        --依次循环发放8套物品
        for j = 1, data[KEYS.service.rewardCount_1 + i] do
            --每套内物品一个一个发放，避免满了丢失
            if not player:AddItem(data[KEYS.service.reward_1 + i], 1) then
                --如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
                SendMail("商城快递：" .. data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1 + i], (data[KEYS.service.rewardCount_1 + i] - j + 1))
                break        --发放不成功结束对应套直接发放循环
            end
        end
    end

    player:SaveToDB() --保存数据
    return true
end
--4、变身道具
function SHOP_UI.ItemsHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]    --获取数据库相应数值，货币种类。售价-打折

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币

    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    --for i = 0, 7 do
    --    player:AddItem(data[KEYS.service.reward_1 + i], data[KEYS.service.rewardCount_1 + i]) -- 发放所有物品
    --end

    for i = 0, 7 do
        --依次循环发放8套物品
        for j = 1, data[KEYS.service.rewardCount_1 + i] do
            --每套内物品一个一个发放，避免满了丢失
            if not player:AddItem(data[KEYS.service.reward_1 + i], 1) then
                --如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
                SendMail("商城快递：" .. data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1 + i], (data[KEYS.service.rewardCount_1 + i] - j + 1))
                break        --发放不成功结束对应套直接发放循环
            end
        end
    end

    player:SaveToDB() --保存数据
    return true

end
--5、坐骑宠物
function SHOP_UI.MountHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]--获取数据库相应数值，货币种类。售价-打折

    local knownCount, rewardCount = 0, 0
    for i = 0, 7 do
        --轮流检查玩家是否有此物品或技能
        if (data[KEYS.service.reward_1 + i] > 0) then
            if (player:HasSpell(data[KEYS.service.reward_1 + i])) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1

            -- 部分坐骑例如奥的灰烬需要先学习专家级骑术才可以学习
            if (data[KEYS.service.reward_1 + i] == 40192 or data[KEYS.service.reward_1 + i] == 71342 or data[KEYS.service.reward_1 + i] == 58615) then
                if(player:HasSpell(34091)) then
                    -- 有专家骑术正常
                else
                    player:SendAreaTriggerMessage("|cFFFF0000购买该坐骑需要先学习专家级骑术！|r")
                    return false
                end
            end
        end
    end

    if (knownCount == rewardCount) then
        --如果都有，则购买失败并通知
        player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.alreadyKnown .. "技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币

    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    for i = 0, 7 do
        -- 学习所有技能
        if (data[KEYS.service.reward_1 + i] > 0) then
            player:LearnSpell(data[KEYS.service.reward_1 + i])
        end
    end
    player:SaveToDB() --保存数据
    return true
end
--6、增益效果
function SHOP_UI.BuffHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币

    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end
    for i = 0, 7 do
        -- 施放所有技能状态
        if (data[KEYS.service.reward_1 + i] > 0) then
            player:CastSpell(player, data[KEYS.service.reward_1 + i], true)
            -- 黑锋骑士团声望，自动完成前置任务
            if (data[KEYS.service.reward_1 + i] == 90031) then
                player:AddQuest(12896)
                player:CompleteQuest(12896)
                player:RewardQuest(12896)

                player:AddQuest(12897)
                player:CompleteQuest(12897)
                player:RewardQuest(12897)
            end

            -- 霍迪尔之子声望，自动完成前置任务
            if (data[KEYS.service.reward_1 + i] == 90032) then
                player:AddQuest(12956)
                player:CompleteQuest(12956)
                player:RewardQuest(12956)
            end
        end
    end
    return true
end
--7 专业技能
function SHOP_UI.SKILLHandler(player, data)
    --获取数据库相应数值，货币种类。售价-打折
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    -- 判断是否有学习该专业，如果没有学习则失败
    if (player:HasSpell(data[KEYS.service.reward_1])) then
        local knownCount, rewardCount = 0, 0
        for i = 0, 7 do
            --轮流检查玩家是否有此物品或技能
            if (data[KEYS.service.reward_1 + i] > 0) then
                if (player:HasSpell(data[KEYS.service.reward_1 + i])) then
                    knownCount = knownCount + 1
                end
                rewardCount = rewardCount + 1
            end
        end
        if (knownCount == rewardCount) then
            --如果都有，则购买失败并通知
            player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.alreadyKnown .. "技能|r")
            player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
            return false
        end
        local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币

        if not (deducted) then
            --若扣除失败，中止并通知
            return false
        end
        for i = 0, 7 do
            -- 学习所有技能
            if (data[KEYS.service.reward_1 + i] > 0) then
                player:LearnSpell(data[KEYS.service.reward_1 + i])
            end
        end
        player:AdvanceSkill(data[KEYS.service.flags], 450)
        return true
    else
        player:SendAreaTriggerMessage("|cFFFF0000您未学习该专业不能提升，请先到专业训练师处学习该专业!|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

end
--8、魔法技能
function SHOP_UI.SpellHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]--获取数据库相应数值，货币种类。售价-打折

    local knownCount, rewardCount = 0, 0
    for i = 0, 7 do
        --轮流检查玩家是否有此物品或技能
        if (data[KEYS.service.reward_1 + i] > 0) then
            if (player:HasSpell(data[KEYS.service.reward_1 + i])) then
                knownCount = knownCount + 1
            end
            rewardCount = rewardCount + 1
        end
    end

    if (knownCount == rewardCount) then
        --如果都有，则购买失败并通知
        player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.alreadyKnown .. "技能|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币

    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    for i = 0, 7 do
        -- 学习所有技能
        if (data[KEYS.service.reward_1 + i] > 0) then
            player:LearnSpell(data[KEYS.service.reward_1 + i])
        end
    end
    player:SaveToDB() --保存数据
    return true
end
--9、幻化装扮
function SHOP_UI.transHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]    --获取数据库相应数值，货币种类。售价-打折

    local knownitem, rewarditem = 0, 0    --轮流检查玩家是否有此物品或技能
    for i = 0, 7 do
        if (data[KEYS.service.reward_1 + i] > 0) then
            if (player:HasItem(data[KEYS.service.reward_1 + i])) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end

    if (knownitem == rewarditem) then
        --如果都有，则购买失败并通知
        player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.alreadyKnown .. "物品|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --扣除货币


    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    --for i = 0, 7 do
    --    player:AddItem(data[KEYS.service.reward_1 + i], data[KEYS.service.rewardCount_1 + i]) -- 发放所有物品
    --end

    for i = 0, 7 do
        --依次循环发放8套物品
        for j = 1, data[KEYS.service.rewardCount_1 + i] do
            --每套内物品一个一个发放，避免满了丢失
            if not player:AddItem(data[KEYS.service.reward_1 + i], 1) then
                --如果一个一个发放不成功,则合并为一个邮件发放剩余所有的
                SendMail("商城快递：" .. data[KEYS.service.name], CONFIG.strings.mailBody, player:GetGUIDLow(), 0, 61, 0, 0, 0, data[KEYS.service.reward_1 + i], (data[KEYS.service.rewardCount_1 + i] - j + 1))
                break        --发放不成功结束对应套直接发放循环
            end
        end
    end

    player:SaveToDB() --保存数据
    return true
end
--10、头衔称号
function SHOP_UI.TitleHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount] --获取数据库相应数值，货币种类。售价-打折

    local knownitem, rewarditem = 0, 0    --轮流检查玩家是否有此称号
    for i = 0, 7 do
        if (data[KEYS.service.reward_1 + i] > 0) then
            if (player:HasTitle(data[KEYS.service.reward_1 + i])) then
                knownitem = knownitem + 1
            end
            rewarditem = rewarditem + 1
        end
    end

    if (knownitem == rewarditem) then
        --如果都有，则购买失败并通知
        player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.alreadyKnown .. "称号|r")
        player:PlayDirectSound(GetSoundEffect("cantLearn", player:GetRace(), player:GetGender()), player)
        return false
    end

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount)--扣除货币


    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    player:SetKnownTitle(data[KEYS.service.reward_1])-- 发放所有称号
    player:SaveToDB() --保存数据
    return true
end
--11、系统服务
function SHOP_UI.ServiceHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    --获取数据库相应数值，货币种类。售价-打折

    --扣除货币
    local deducted = SHOP_UI.DeductCurrency(player, currency, amount)

    if not (deducted) then
        --若扣除失败，中止并通知
        return false
    end

    player:SetAtLoginFlag(data[KEYS.service.reward_1]) -- 设置系统服务（十六进制转十进制）
    -- 0x1, 1改名字。   0x2, 2遗忘所有法术。  0x8, 8变容貌 。 0x40, 64转阵营    0x80, 128变种族
    player:SendAreaTriggerMessage("|cFFFF0000您现在返回角色选择或者重新登录角色，即可进行修改！|r")
    return true
end
--12、等级提升
function SHOP_UI.LevelHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]--获取数据库相应数值，货币种类。售价-打折

    -- 判断如果是一命模式玩家，不允许使用该服务
    local guid = player:GetGUIDLow()
    local result = CharDBQuery("SELECT GUID,DEAD FROM character_survival_mode where mode in (2,3) and guid=" .. guid)
    if result then
        --一命模式玩家禁止使用该服务。
        player:SendAreaTriggerMessage("|cFFFF0000您当前生存模式不允许使用本服务！|r")
        player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
        return false
    end

    local result = CharDBQuery("SELECT GUID,DEAD FROM character_survival_mode where guid=" .. guid)
    if result then
        -- 选择模式后才允许直升等级
    else
        player:SendAreaTriggerMessage("|cFFFF0000请先选择生存模式后才允许使用本服务！|r")
        player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
        return false
    end

    if (player:GetLevel() >= CONFIG.maxLevel) then
        --当玩家等级大于或脚本设置的最高等级时，则中止服务。
        player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.tooHighLevel .. "|r")
        player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
        return false
    end

    if (data[KEYS.service.flags] == 1) then
        --如果数据库flag值设置为1
        if (player:GetLevel() >= data[KEYS.service.reward_1]) then
            --当玩家等级大于或等于提升等级时，则中止服务。（通常用于直升等级）
            player:SendAreaTriggerMessage("|cFFFF0000" .. CONFIG.strings.tooHighLevel .. "|r")
            player:PlayDirectSound(GetSoundEffect("cantUse", player:GetRace(), player:GetGender()), player)
            return false
        end
    end

    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) --否则 扣除货币
    if not (deducted) then
        --如果没有从玩家身上扣除货币，则中止并发送消息
        return false
    end

    local level = player:GetLevel() + data[KEYS.service.reward_1] --升级后的等级=现有等级+购买等级

    if (level > CONFIG.maxLevel) then
        --  如果升级后的等级，高于脚本设置的最高等级，那么取脚本设置的最高等级。
        level = CONFIG.maxLevel
    end

    if (data[KEYS.service.flags] == 1) then
        -- 如果数据库flag设置为1，则我们将玩家设置为直升等级，而不是提升等级
        level = data[KEYS.service.reward_1]
    end

    -- 如果是DK，则需要跳过出生任务
    local cl = player:GetClass() --获取玩家的职业
    if cl == 6 then
        -- 如果是DK
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
        player:SetLevel(level)--设定玩家为 升级后的等级
        player:SaveToDB() --保存数据
    else
        player:SetLevel(level)--设定玩家为 升级后的等级
        player:SaveToDB() --保存数据
    end
    return true

end
--13、货币代币
function SHOP_UI.GoldHandler(player, data)
    local currency, amount = data[KEYS.service.currency], data[KEYS.service.price] - data[KEYS.service.discount]
    --获取数据库相应数值，货币种类。售价-打折
    local deducted = SHOP_UI.DeductCurrency(player, currency, amount) -- 扣除货币
    if not (deducted) then
        --如果没有从玩家身上扣除货币，则中止并发送消息
        return false
    end
    -- 如果flag = 1表示兑换金币
    if (data[KEYS.service.flags] == 1) then
        player:ModifyMoney(data[KEYS.service.reward_1] * 10000)
    else
        for i = 0, 7 do
            player:AddItem(data[KEYS.service.reward_1 + i], data[KEYS.service.rewardCount_1 + i]) -- 可金币兑换其它货币
            i = i + 1
        end
    end
    return true
end
