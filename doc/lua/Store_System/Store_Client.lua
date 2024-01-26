--以下配置选项可以根据您的需要进行更改。

--配置选项中没有的任何内容都需要更改以下代码，

--你可以自行决定。

local CONFIG = {
    maxCategories = 11,
    strings = {
        categoryAccessDenied = "您无权访问此项目！",
    }
}

--------------------

local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local KEYS = {
    currency = {
        id = 0,
        currencyType = 1,
        name = 2,
        icon = 3,
        data = 4,
        tooltip = 5
    },
    category = {
        id = 1,
        name = 2,
        icon = 3,
        requiredRank = 4,
        flags = 5,
        enabled = 6
    },
    service = {
        id = 0,
        serviceType = 1,
        name = 2,
        tooltipName = 3,
        tooltipType = 4,
        tooltipText = 5,
        icon = 6,
        price = 7,
        currency = 8,
        hyperlink = 9,
        displayId = 10,
        discount = 11,
        flags = 12,
        reward_1 = 13,
        reward_2 = 14,
        reward_3 = 15,
        reward_4 = 16,
        reward_5 = 17,
        reward_6 = 18,
        reward_7 = 19,
        reward_8 = 20,
        rewardCount_1 = 21,
        rewardCount_2 = 22,
        rewardCount_3 = 23,
        rewardCount_4 = 24,
        rewardCount_5 = 25,
        rewardCount_6 = 26,
        rewardCount_7 = 27,
        rewardCount_8 = 28,
        new = 29,
        enabled = 30
    },
}

local scaleMulti = 1

-- Helpers --

local function CoordsToTexCoords(size, xTop, yTop, xBottom, yBottom)
    local magic = (1 / size) / 2
    local Top = (yTop / size) + magic
    local Left = (xTop / size) + magic
    local Bottom = (yBottom / size) - magic
    local Right = (xBottom / size) - magic

    return Left, Right, Top, Bottom
end

------------

local StoreHandler = AIO.AddHandlers("STORE_CLIENT", {})

function StoreHandler.FrameData(player, services, links, nav, currencies, rank)
    SHOP_UI["Data"].services = services
    SHOP_UI["Data"].links = links
    SHOP_UI["Data"].nav = nav
    SHOP_UI["Data"].currencies = currencies
    SHOP_UI["Vars"].accountRank = rank
    SHOP_UI.NavButtons_OnData()
    SHOP_UI.CurrencyBadges_OnData()
    SHOP_UI.ServiceBoxes_OnData()
end

function StoreHandler.UpdateCurrencies(player, currencies)
    for k, v in pairs(currencies) do
        SHOP_UI["Vars"]["playerCurrencies"][k] = v
    end
    SHOP_UI.CurrencyBadges_Update()
end

SHOP_UI = {
    ["Vars"] = {
        currentCategory = 1,
        currentCategoryFlags = 0,
        currentNavId = 1,
        currentPage = 1,
        maxPages = 1,
        accountRank = 0,
        ["playerCurrencies"] = {}
    },
    ["Data"] = {
        nav = {},
        services = {},
        links = {},
        currencies = {}
    }
}

--商城 主窗口 --
function SHOP_UI.MainFrame_Create()
    -- 创建主框架
    local shopFrame = CreateFrame("Frame", "SHOP_FRAME", UIParent)
    --shopFrame:SetPoint("LEFT", 40, 0)
    shopFrame:SetPoint("CENTER", 0, 0) --初始位置
    shopFrame:Hide()--初始隐藏

    shopFrame:SetToplevel(true) --置顶
    shopFrame:SetClampedToScreen(true) --镶嵌到屏幕
    shopFrame:SetMovable(true) --可移动
    shopFrame:EnableMouse(true) --启用鼠标
    shopFrame:RegisterForDrag("LeftButton")--左键拖动
    shopFrame:SetScript("OnDragStart", shopFrame.StartMoving)--拖动时 移动或调整大小
    shopFrame:SetScript("OnHide", shopFrame.StopMovingOrSizing)--隐藏时停止 移动或调整大小
    shopFrame:SetScript("OnDragStop", shopFrame.StopMovingOrSizing) --拖动停止时停止移动或调整大小





    -- 背景纹理的像素大小，然后缩放
    shopFrame:SetSize(1024 * scaleMulti, 658 * scaleMulti)

    --背景贴图
    shopFrame.Background = shopFrame:CreateTexture(nil, "BACKGROUND")
    shopFrame.Background:SetSize(shopFrame:GetSize())
    shopFrame.Background:SetPoint("CENTER", shopFrame, "CENTER")
    shopFrame.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    shopFrame.Background:SetTexCoord(CoordsToTexCoords(1024, 0, 0, 1024, 658))

    --标题--
    shopFrame.Title = shopFrame:CreateFontString()
    shopFrame.Title:SetFont("Fonts\\FRIZQT__.TTF", 14)
    shopFrame.Title:SetShadowOffset(1, -1)
    shopFrame.Title:SetPoint("TOP", shopFrame, "TOP", 0, -3)
    shopFrame.Title:SetText("|cffedd100魔兽商城|r")

    -- create navigation button placeholders, pass parent as arg导航
    SHOP_UI.NavButtons_Create(shopFrame)

    -- create page buttons创建页面按钮
    SHOP_UI.PageButtons_Create(shopFrame)

    -- create service box placeholders, pass parent as arg创建服务框占位符
    SHOP_UI.ServiceBoxes_Create(shopFrame)

    -- create currency badge placeholders创建货币徽章占位符
    SHOP_UI.CurrencyBadges_Create(shopFrame)

    -- create placeholder preview frame创建占位符预览框
    SHOP_UI.ModelFrame_Create(shopFrame)

    -- Request all service data 请求所有服务数据
    AIO.Handle("STORE_SERVER", "FrameData")
    AIO.Handle("STORE_SERVER", "UpdateCurrencies")

    -- 屏蔽主菜单直接激活在线商城
    --MainMenuMicroButton:SetScript(
    --    "OnClick",
    --    function()
    --        if GameMenuFrame:IsShown() then
    --            MainFrame_Toggle()
    --        end
    --    end
    --)

    shopFrame.CloseButton = CreateFrame("Button", nil, shopFrame, "UIPanelCloseButton")
    shopFrame.CloseButton:SetSize(30, 30)
    shopFrame.CloseButton:SetPoint("TOPRIGHT", shopFrame, "TOPRIGHT", 5, 5)
    shopFrame.CloseButton:EnableMouse(true)
    shopFrame.CloseButton:SetScript(
        "OnClick",
        function()
            MainFrame_Toggle()
        end
    )

    shopFrame:SetScript(
        "OnShow",
        function()
            AIO.Handle("STORE_SERVER", "UpdateCurrencies")
            PlaySound("AuctionWindowOpen", "Master")
        end
    )

    shopFrame:SetScript(
        "OnHide",
        function()
            -- also hide the preview window
            SHOP_UI["MODEL_FRAME"]:Hide()
            PlaySound("AuctionWindowClose", "Master")
        end
    )

    -- make frame close on escape
    tinsert(UISpecialFrames, shopFrame:GetName())

    SHOP_UI["FRAME"] = shopFrame
end

-- 购买导航按钮
function SHOP_UI.NavButtons_Create(parent)
    SHOP_UI["NAV_BUTTONS"] = {}
    local offset = -5
    for i = 1, 12 do
        local navButton = CreateFrame("Button", nil, parent)

        -- default variables
        navButton.NavId = i

        -- Main button
        local size = 220

        navButton:SetSize(size * scaleMulti, (size / 4) * scaleMulti)
        navButton:SetPoint("LEFT", parent, "LEFT", 17, 232 + offset) --位置

        navButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        navButton:SetHighlightTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        navButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 768, 897, 1023, 960))
        navButton:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 768, 960, 1023, 1023))

        -- 标题
        navButton.Name = navButton:CreateFontString()
        navButton.Name:SetFont("Fonts\\FRIZQT__.TTF", 14)
        navButton.Name:SetShadowOffset(1, -1)
        navButton.Name:SetPoint("CENTER", navButton, "CENTER", 8, 0)

        -- 图标
        navButton.Icon = navButton:CreateTexture(nil, "BACKGROUND")
        navButton.Icon:SetSize(33, 33)
        navButton.Icon:SetPoint("LEFT", navButton, "LEFT", 9, -1)

        -- 上下间隔（包含导航条本身高度）
        offset = offset - 50

        navButton:SetScript("OnClick", SHOP_UI.NavButtons_OnClick)

        -- push button to shop table for later access
        SHOP_UI["NAV_BUTTONS"][i] = navButton

        -- Default hide all the buttons
        navButton:Hide()
    end

    SHOP_UI.NavButtons_OnData()
end

function SHOP_UI.NavButtons_OnClick(self)
    -- check whether the player has the correct rank to open a tab
    if (self.RequiredRank > SHOP_UI["Vars"].accountRank) then
        UIErrorsFrame:AddMessage(CONFIG.strings.categoryAccessDenied, 1.0, 0.0, 0.0, 2);
        PlaySound("igPlayerInviteDecline", "Master")
        return ;
    end

    PlaySound("uChatScrollButton", "Master")
    -- Set the category id, selected navigation id and always set current page to 1
    SHOP_UI["Vars"].currentCategory = self.CategoryId
    SHOP_UI["Vars"].currentCategoryFlags = self.CategoryFlags
    SHOP_UI["Vars"].currentNavId = self.NavId
    SHOP_UI["Vars"].currentPage = 1

    -- Update frame elements
    SHOP_UI.NavButtons_UpdateSelect()
    SHOP_UI.ServiceBoxes_Update()
    SHOP_UI.PageButtons_Update()
end

function SHOP_UI.NavButtons_UpdateSelect()
    -- reset all buttons to normal unselected texture
    for i = 1, CONFIG.maxCategories do
        SHOP_UI["NAV_BUTTONS"][i]:UnlockHighlight()
    end

    -- lock the highlight state for the currently selected category
    SHOP_UI["NAV_BUTTONS"][SHOP_UI["Vars"].currentNavId]:LockHighlight()
end

function SHOP_UI.NavButtons_OnData()
    -- index used to determine category position
    index = 1

    -- some categories could be disabled/mismatched indexes
    for _, v in pairs(SHOP_UI["Data"].nav) do
        -- if we have more than max, break
        if index > CONFIG.maxCategories then
            break
        end

        -- if category is enabled then process button
        if (v[KEYS.category.enabled] == 1) then
            -- Fetch button and assign vars
            local button = SHOP_UI["NAV_BUTTONS"][index]
            button.CategoryId = v[KEYS.category.id]
            button.NameText = v[KEYS.category.name]
            button.IconTexture = v[KEYS.category.icon]
            button.RequiredRank = v[KEYS.category.requiredRank]
            button.CategoryFlags = v[KEYS.category.flags]

            -- Update elements
            button.Icon:SetTexture("Interface/Icons/" .. button.IconTexture .. ".blp")
            button.Name:SetFormattedText("|cffdbe005%s|r", button.NameText)

            -- Show button
            button:Show()

            -- increment index
            index = index + 1
        end
    end

    -- We should now set the correct "initial" data for the first indexed category
    local button = SHOP_UI["NAV_BUTTONS"][1]
    SHOP_UI["Vars"].currentCategory = button.CategoryId
    SHOP_UI["Vars"].currentCategoryFlags = button.CategoryFlags
    SHOP_UI["Vars"].currentNavId = button.NavId

    SHOP_UI.NavButtons_UpdateSelect()
end

function SHOP_UI.OnPurchaseConfirm(data)
    AIO.Handle("STORE_SERVER", "Purchase", data)
end

StaticPopupDialogs["CONFIRM_STORE_PURCHASE"] = {
    text = "确定要购买 %s?",
    button1 = "是",
    button2 = "否",
    OnAccept = function(self, data)
        SHOP_UI.OnPurchaseConfirm(data)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function SHOP_UI.ServiceBoxes_Create(parent)
    --商品列表
    SHOP_UI["SERVICE_BUTTONS"] = {}
    for i = 1, 8 do
        -- service option box frame
        local service = CreateFrame("Button", nil, parent)

        -- define variables, these are required for the frame scripts
        service.ServiceId = 0
        service.Name = ""
        service.Count = ""
        service.TooltipName = nil
        service.TooltipText = nil
        service.TooltipType = ""
        service.TooltipHyperlink = 0

        -- determine box coordinates
        local row1_y = 110
        local row2_y = -155
        local x_offsets = { -140, 35, 210, 375 }
        local BoxCoordX, BoxCoordY
        if i <= 4 then
            BoxCoordY = row1_y
        else
            BoxCoordY = row2_y
        end
        BoxCoordX = x_offsets[(i - 1) % 4 + 1]

        service:SetSize(160, 260)
        service:SetPoint("CENTER", parent, "CENTER", BoxCoordX, BoxCoordY)
        service:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service:SetHighlightTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 0, 658, 215, 1023))
        service:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 215, 658, 430, 1023))

        -- 图标
        service.Icon = service:CreateTexture(nil, "BACKGROUND")
        service.Icon:SetSize(40, 40)
        service.Icon:SetPoint("CENTER", service, "CENTER", 0, 70)

        -- 数量

        service.CountFont = service:CreateFontString()
        service.CountFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
        service.CountFont:SetShadowOffset(1, -1)
        service.CountFont:SetPoint("CENTER", service.Icon, "CENTER", 27, -15)

        -- 名字
        service.NameFont = service:CreateFontString()
        service.NameFont:SetFont("Fonts\\FRIZQT__.TTF", 13)
        service.NameFont:SetShadowOffset(1, -1)
        service.NameFont:SetPoint("CENTER", service, "CENTER", 0, 16)

        -- 价格
        service.PriceFont = service:CreateFontString()
        service.PriceFont:SetFont("Fonts\\FRIZQT__.TTF", 15)
        service.PriceFont:SetShadowOffset(1, -1)
        service.PriceFont:SetPoint("CENTER", service, "CENTER", -3, -35)

        -- 价格图标
        service.currencyIcon = service:CreateTexture(nil, "OVERLAY")
        service.currencyIcon:SetSize(15, 15)
        service.currencyIcon:SetPoint("LEFT", service.PriceFont, "RIGHT", 0, 0)

        --折扣--

        service.DicountFont = service:CreateFontString()
        service.DicountFont:SetFont("Fonts\\FRIZQT__.TTF", 10)
        service.DicountFont:SetShadowOffset(1, -1)
        service.DicountFont:SetPoint("CENTER", service.PriceFont, "CENTER", -30, 0)

        --折扣图标--

        --	service.Background = service:CreateTexture(nil, "BACKGROUND")
        --	service.Background:SetSize(65, 30)
        --	service.Background:SetPoint("CENTER", service, "RIGHT", -35, 114)
        --	service.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        --	service.Background:SetTexCoord(CoordsToTexCoords(1024, 862, 765, 961, 815))

        --折扣线--
        service.DiscountSlash = service:CreateTexture(nil, "OVERLAY")
        service.DiscountSlash:SetSize(18, 18)
        service.DiscountSlash:SetPoint("CENTER", service.DicountFont)
        service.DiscountSlash:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service.DiscountSlash:SetTexCoord(CoordsToTexCoords(1024, 992, 804, 1023, 835))

        --折扣条--



        service.Banner = CreateFrame("Frame", nil, service)
        service.Banner:SetSize(80, 25)
        service.Banner:SetPoint("TOPRIGHT", service, "TOPRIGHT", 1, 4)

        -- 折扣背景--
        service.Banner.Background = service.Banner:CreateTexture(nil, "BACKGROUND")
        service.Banner.Background:SetSize(80, 25)
        service.Banner.Background:SetPoint("CENTER", service.Banner)
        service.Banner.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        -- service.Banner.Background:SetTexCoord(CoordsToTexCoords(1024, 961, 835, 1023, 866))
        service.Banner.Background:SetTexCoord(CoordsToTexCoords(1024, 862, 765, 961, 815))
        --折扣背景文字--
        service.BannerText = service.Banner:CreateFontString()
        service.BannerText:SetFont("Fonts\\FRIZQT__.TTF", 15)
        service.BannerText:SetShadowOffset(1, -1)
        service.BannerText:SetPoint("CENTER", service.Banner.Background, "CENTER", 0, 3)

        --新品标签--
        service.newTag = service:CreateTexture(nil, "OVERLAY")
        service.newTag:SetSize(65, 30)
        service.newTag:SetPoint("CENTER", service, "LEFT", 35, 114)
        service.newTag:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service.newTag:SetTexCoord(CoordsToTexCoords(1024, 862, 816, 961, 866))

        -- 购买标签
        service.buyButton = CreateFrame("Button", nil, service)
        service.buyButton:SetSize(100, 28)
        service.buyButton:SetPoint("CENTER", service, "CENTER", 0, -85)
        service.buyButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service.buyButton:SetHighlightTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service.buyButton:SetPushedTexture("Interface/Store_UI/Frames/StoreFrame_Main")
        service.buyButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 849, 837, 873))
        service.buyButton:GetHighlightTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 849, 837, 873))
        service.buyButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, 709, 873, 837, 897))

        --购买文字
        service.buyButton.ButtonText = service.buyButton:CreateFontString()
        service.buyButton.ButtonText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        service.buyButton.ButtonText:SetPoint("CENTER", service.buyButton, 0, 2)
        service.buyButton.ButtonText:SetText("购 买")

        service.buyButton:SetScript(
            "OnClick",
            function(self)
                local dialog = StaticPopup_Show("CONFIRM_STORE_PURCHASE", self:GetParent().Name)     -- dialog contains the frame object
                if (dialog) then
                    dialog.data = self:GetParent().ServiceId
                end

                PlaySound("STORE_CONFIRM", "Master")
            end
        )

        -- 提示信息
        -- this requires a few predefined variables tied to the tab object, we override these in the update function
        service:SetScript(
            "OnEnter",
            function(self)
                if (self.TooltipName or self.TooltipText or self.TooltipType) then
                    GameTooltip:SetOwner(self, "ANCHOR_NONE")
                    GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
                    if (self.TooltipName) then
                        GameTooltip:AddLine("|cffffffff" .. self.TooltipName .. "|r") -- Tooltip Insidename
                    end
                    if (self.TooltipType == "item" or self.TooltipType == "spell") then
                        GameTooltip:SetHyperlink(self.TooltipType .. ":" .. self.TooltipHyperlink)
                    end
                    if (self.TooltipText) then
                        GameTooltip:AddLine(self.TooltipText)
                    end
                    GameTooltip:Show()
                end
            end
        )

        service:SetScript(
            "OnLeave",
            function(self)
                GameTooltip:Hide()
            end
        )

        service:SetScript(
            "OnClick",
            function(self)
                --	if(self.Type == 9 and service.Flags == 1) then
                if (self.Type == 9) then
                    --哪一个导航条 可预览幻化装扮
                    SHOP_UI.ModelFrame_ShowPlayer(self.Rewards)
                elseif ((self.Type == 3 or self.Type == 4 or self.Type == 5) and self.DisplayId > 0) then
                    -- 哪一个导航条 可预览 坐骑 宠物 变身模型
                    SHOP_UI.ModelFrame_ShowCreature(self.DisplayId)
		else
		    SHOP_UI["MODEL_FRAME"].playerModel:Hide()
		    SHOP_UI["MODEL_FRAME"]:Hide()
                end
                -- Parchment page sound
                PlaySound(836)
            end
        )

        service:Hide()
        SHOP_UI["SERVICE_BUTTONS"][i] = service
    end

    SHOP_UI.ServiceBoxes_OnData()
end

local function GetCategoryServiceIds()
    local services = {}

    -- check all values
    for k, v in pairs(SHOP_UI["Data"].links) do
        if (v[1] == SHOP_UI["Vars"].currentCategory) then
            table.insert(services, v[2])
        end
    end

    -- if category flag is set to 1, automatically populate all discounted items
    if (SHOP_UI["Vars"].currentCategoryFlags == 1) then

        for k, v in pairs(SHOP_UI["Data"].services) do
            if (v[KEYS.service.discount] > 0) then
                table.insert(services, k)
            end
        end
    end

    -- if category flag is set to 2, automatically populate all new items
    if (SHOP_UI["Vars"].currentCategoryFlags == 2) then

        for k, v in pairs(SHOP_UI["Data"].services) do
            if (v[KEYS.service.new] == 1) then
                table.insert(services, k)
            end
        end
    end

    return services
end

local function GetServiceData(serviceIds)
    local serviceData = {}
    local tmp = {}
    local serviceTable = SHOP_UI["Data"].services

    -- iterate over all services
    for _, v in pairs(serviceIds) do
        local service = serviceTable[v]
        if (service) then
            service.ID = v
            -- If the service is flagged as new, push directly to the service table as front of queue
            -- Otherwise, push to temp table to be pushed onto the end of the queue
            if (service[KEYS.service.new] == 1) then
                table.insert(serviceData, service)
            else
                table.insert(tmp, service)
            end
        end
    end

    -- push normal priority items to the end of the service table
    for _, v in pairs(tmp) do
        table.insert(serviceData, v)
    end

    return serviceData
end

function SHOP_UI.ServiceBoxes_Update()
    local category = SHOP_UI["Vars"].currentCategory
    local currentPage = SHOP_UI["Vars"].currentPage

    -- Fetch all service ID's for the selected category
    local categoryServices = GetCategoryServiceIds()

    -- Fetch all the service data values by the service ID's
    local services = GetServiceData(categoryServices)

    -- Get the service per page index
    local startIndex = (currentPage - 1) * 8 + 1
    local endIndex = startIndex + 8 - 1
    local maxPages = math.ceil(#services / 8)
    if (maxPages < 1) then
        maxPages = 1
    end
    SHOP_UI["Vars"].maxPages = maxPages

    -- Update boxes by page index
    local index = 1
    for i, serviceData in ipairs(services) do
        if i >= startIndex and i <= endIndex then
            -- Get service data
            local service = SHOP_UI["SERVICE_BUTTONS"][index]
            service.ServiceId = serviceData.ID
            service.Type = serviceData[KEYS.service.serviceType]
            service.Name = serviceData[KEYS.service.name]
            service.Count = serviceData[KEYS.service.rewardCount_1] --数量
            service.TooltipName = serviceData[KEYS.service.tooltipName]
            service.TooltipType = serviceData[KEYS.service.tooltipType]
            service.TooltipText = serviceData[KEYS.service.tooltipText]
            service.IconTexture = serviceData[KEYS.service.icon]
            service.Price = serviceData[KEYS.service.price]
            service.Currency = serviceData[KEYS.service.currency]
            service.TooltipHyperlink = serviceData[KEYS.service.hyperlink]
            service.DisplayId = serviceData[KEYS.service.displayId]
            service.Discount = serviceData[KEYS.service.discount]
            service.Flags = serviceData[KEYS.service.flags]
            service.New = serviceData[KEYS.service.new]

            service.CountFont:SetFormattedText("|cffffffff%s|r", "x" .. service.Count)--数量






            service.Rewards = {}
            for i = 0, 7 do
                table.insert(service.Rewards, serviceData[KEYS.service.reward_1 + i])
            end

            local currencyData = SHOP_UI["Data"].currencies
            local currencyIcon = currencyData[service.Currency][KEYS.currency.icon]

            -- update tab data
            service.Icon:SetTexture("Interface/Icons/" .. service.IconTexture)
            service.NameFont:SetFormattedText("|cffffffff%s|r", service.Name)
            service.DicountFont:SetFormattedText("|cffdbe005%i|r", service.Price)
            service.currencyIcon:SetTexture("Interface/Store_UI/Currencies/" .. currencyIcon)





            -- calculate discount percentage
            local discountPct = math.floor(((service.Price - service.Discount) - service.Price) / service.Price * 100)
            service.BannerText:SetFormattedText("|cffffffff %i%%|r", discountPct)

            -- if service is discounted, then show all the discount frames and override the price text. otherwise hide.
            if service.Discount > 1 then
                service.PriceFont:SetFormattedText("|cff1eff00%i|r", (service.Price - service.Discount))
                service.DicountFont:Show()
                service.DiscountSlash:Show()
                service.Banner:Show() --折扣背景
                service.BannerText:Show() --折扣率文字
            else
                service.PriceFont:SetFormattedText("|cffdbe005%i|r", service.Price)
                service.DicountFont:Hide()
                service.DiscountSlash:Hide()
                service.Banner:Hide()
                service.BannerText:Hide()
            end

            -- If service is tagged as new, show new tag
            if service.New == 1 then
                service.newTag:Show()
            else
                service.newTag:Hide()
            end

            -- Show service box
            service:Show()

            -- increment shown idnex
            index = index + 1
        end
    end

    -- Hide unused boxes per page
    -- if index < 8 then
        for i = index, 8 do
            SHOP_UI["SERVICE_BUTTONS"][i]:Hide()
        end
    -- end
end

function SHOP_UI.ServiceBoxes_OnData()
    SHOP_UI.ServiceBoxes_Update()
    SHOP_UI.PageButtons_Update()
end

function SHOP_UI.PageButtons_Create(parent)
    local backButton = CreateFrame("Button", nil, parent)
    backButton:SetSize(25, 25)
    backButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -100, -28)

    -- Set back button textures
    local backTopX, backTopY, backBotX, backBotY = 837, 866, 868, 897
    backButton:SetDisabledTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    backButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    backButton:SetPushedTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    backButton:GetDisabledTexture():SetTexCoord(CoordsToTexCoords(1024, backTopX, backTopY, backBotX, backBotY))
    backButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, backTopX + 31, backTopY, backBotX + 31, backBotY))
    backButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, backTopX + 62, backTopY, backBotX + 62, backBotY))

    backButton:SetScript(
        "OnClick",
        function()
            SHOP_UI.PageButtons_OnClick(-1)
        end
    )

    local pageText = parent:CreateFontString()
    pageText:SetFont("Fonts\\FRIZQT__.TTF", 13)
    pageText:SetShadowOffset(1, -1)
    pageText:SetPoint("LEFT", backButton, "RIGHT", 20, 0)

    local forwardButton = CreateFrame("Button", nil, parent)
    forwardButton:SetSize(25, 25)
    forwardButton:SetPoint("LEFT", backButton, "RIGHT", 65, 0)

    -- Set back button textures
    local forwTopX, forwTopY, forwBotX, forwBotY = 930, 866, 961, 897
    forwardButton:SetDisabledTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    forwardButton:SetNormalTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    forwardButton:SetPushedTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    forwardButton:GetDisabledTexture():SetTexCoord(CoordsToTexCoords(1024, forwTopX, forwTopY, forwBotX, forwBotY))
    forwardButton:GetNormalTexture():SetTexCoord(CoordsToTexCoords(1024, forwTopX + 31, forwTopY, forwBotX + 31, forwBotY))
    forwardButton:GetPushedTexture():SetTexCoord(CoordsToTexCoords(1024, forwTopX + 62, forwTopY, forwBotX + 62, forwBotY))

    forwardButton:SetScript(
        "OnClick",
        function()
            SHOP_UI.PageButtons_OnClick(1)
        end
    )

    SHOP_UI["PAGING_ELEMENTS"] = { backButton, forwardButton, pageText }
    SHOP_UI.PageButtons_Update()
end

function SHOP_UI.PageButtons_OnClick(val)
    local currentPage = SHOP_UI["Vars"].currentPage
    local maxPages = SHOP_UI["Vars"].maxPages

    if (currentPage + val < 1 or currentPage + val > maxPages) then
        return
    end

    PlaySound("igSpellBookOpen", "Master")
    SHOP_UI["Vars"].currentPage = currentPage + val
    SHOP_UI.ServiceBoxes_Update()
    SHOP_UI.PageButtons_Update()
end

function SHOP_UI.PageButtons_Update()
    local currentPage = SHOP_UI["Vars"].currentPage
    local maxPages = SHOP_UI["Vars"].maxPages

    -- Hide if we don't have enough elements for paging
    if (maxPages == 1) then
        SHOP_UI["PAGING_ELEMENTS"][1]:Hide()
        SHOP_UI["PAGING_ELEMENTS"][2]:Hide()
        SHOP_UI["PAGING_ELEMENTS"][3]:Hide()
        return
    end

    SHOP_UI["PAGING_ELEMENTS"][1]:Show()
    SHOP_UI["PAGING_ELEMENTS"][2]:Show()
    SHOP_UI["PAGING_ELEMENTS"][3]:Show()

    -- If the current page is the first page, disable back button
    if (currentPage == 1) then
        SHOP_UI["PAGING_ELEMENTS"][1]:Disable()
    else
        SHOP_UI["PAGING_ELEMENTS"][1]:Enable()
    end

    -- if the current page is the last page, disable forward button
    if (currentPage == maxPages) then
        SHOP_UI["PAGING_ELEMENTS"][2]:Disable()
    else
        SHOP_UI["PAGING_ELEMENTS"][2]:Enable()
    end

    -- Update the text to reflect the correct page count
    SHOP_UI["PAGING_ELEMENTS"][3]:SetFormattedText("|cffffffff%i / %i|r", currentPage, maxPages)
end

function SHOP_UI.CurrencyBadges_Create(parent)
    SHOP_UI["CURRENCY_BUTTONS"] = {}

    -- Create a frame for the currency buttons to exist on
    local currencyBackdrop = CreateFrame("Frame", nil, parent)
    currencyBackdrop:SetSize(180, 20)
    currencyBackdrop:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 10, 30)

    for i = 1, 3 do
        -- Button frame
        local currencyButton = CreateFrame("Button", nil, currencyBackdrop)
        currencyButton:SetSize(14, 14)

        -- 货币数量显示位置
        currencyButton.Amount = currencyButton:CreateFontString()
        currencyButton.Amount:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
        currencyButton.Amount:SetPoint("CENTER", currencyButton, "CENTER", 20, 7)

        -- 货币图标
        currencyButton.Icon = currencyButton:CreateTexture(nil, "OVERLAY")
        currencyButton.Icon:SetSize(14, 14)
        currencyButton.Icon:SetPoint("LEFT", currencyButton.Amount, "RIGHT", 0, 0)

        currencyButton:SetScript(
            "OnEnter",
            function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 18, 0)
                GameTooltip:AddLine("|cffffffff" .. self.currencyName .. "|r")
                if (self.currencyTooltip) then
                    GameTooltip:AddLine(self.currencyTooltip)
                end
                GameTooltip:Show()
            end
        )

        currencyButton:SetScript(
            "OnLeave",
            function(self)
                GameTooltip:Hide()
            end
        )

        -- hide the button by default
        currencyButton:Hide()

        -- push button to table for later use
        SHOP_UI["CURRENCY_BUTTONS"][i] = currencyButton
    end
end

function SHOP_UI.CurrencyBadges_OnData()
    local index = 1
    local shownCount = 0
    for k, v in pairs(SHOP_UI["Data"].currencies) do
        if index > 4 then
            break ;
        end

        local button = SHOP_UI["CURRENCY_BUTTONS"][index]
        button.currencyId = k
        button.currencyType = v[KEYS.currency.currencyType]
        button.currencyName = v[KEYS.currency.name]
        button.currencyIcon = v[KEYS.currency.icon]
        button.currencyTooltip = v[KEYS.currency.tooltip]
        button.shown = true

        -- Show the button
        button:Show()

        -- Keep track of indexes and whether or not a button is shown
        shownCount = shownCount + 1
        index = index + 1
    end

    -- we now want to update the currency buttons position to dynamically scale based on configured currencies
    for i = 1, shownCount do
        local button = SHOP_UI["CURRENCY_BUTTONS"][i]
        -- calculate the amount of additional padding to add to the total width of the frame
        local padding = 10 * (shownCount - 1)
        -- calculate spacing based on number of visible buttons and parent width, and add the additional padding
        local spacing = (150 + padding) / shownCount
        -- calculate total width
        local total_width = (shownCount - 1) * spacing
        -- offset to center the button along x-axis
        local offset_x = -total_width / 2
        -- calculate the x coordinate of the button
        local x = offset_x + (i - 1) * spacing

        -- and finally set the button position with the calculated x value
        button:SetPoint("CENTER", button:GetParent(), "CENTER", x, 0)
    end

    SHOP_UI.CurrencyBadges_Update()
end

function SHOP_UI.CurrencyBadges_Update()
    for _, button in pairs(SHOP_UI["CURRENCY_BUTTONS"]) do
        if (button.shown) then
            button.currencyValue = SHOP_UI["Vars"]["playerCurrencies"][button.currencyId]
            button.Amount:SetText(button.currencyValue)
            button.Icon:SetTexture("Interface/Store_UI/Currencies/" .. button.currencyIcon)
        end
    end
end

function SHOP_UI.ModelFrame_Create(parent)
    --预览窗口
    local modelFrame = CreateFrame("Frame", nil, parent)
    modelFrame:SetSize(300, 658)
    modelFrame:SetPoint("LEFT", parent, "RIGHT", 0, 0)
    modelFrame:Hide()

    --标题--
    modelFrame.Title = modelFrame:CreateFontString()
    modelFrame.Title:SetFont("Fonts\\FRIZQT__.TTF", 14)
    modelFrame.Title:SetShadowOffset(1, -1)
    modelFrame.Title:SetPoint("TOP", modelFrame, "TOP", 0, -3)
    modelFrame.Title:SetText("|cffedd100预 览|r")



    -- Background texture
    modelFrame.Background = modelFrame:CreateTexture(nil, "BACKGROUND")
    modelFrame.Background:SetSize(modelFrame:GetSize())
    modelFrame.Background:SetPoint("CENTER", modelFrame, "CENTER")
    modelFrame.Background:SetTexture("Interface/Store_UI/Frames/StoreFrame_Main")
    modelFrame.Background:SetTexCoord(CoordsToTexCoords(1024, 430, 658, 701, 1023))

    modelFrame:SetScript(
        "OnHide",
        function()
            PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "Master")
        end
    )

    modelFrame:SetScript(
        "OnShow",
        function()
            PlaySound("INTERFACESOUND_CHARWINDOWOPEN", "Master")
        end
    )

    -- Close button
    modelFrame.CloseButton = CreateFrame("Button", nil, modelFrame, "UIPanelCloseButton")
    modelFrame.CloseButton:SetSize(28, 28)
    modelFrame.CloseButton:SetPoint("TOPRIGHT", modelFrame, "TOPRIGHT", 4, 3)
    modelFrame.CloseButton:EnableMouse(true)
    modelFrame.CloseButton:SetScript(
        "OnClick",
        function()
            PlaySound("INTERFACESOUND_CHARWINDOWCLOSE", "Master")
            modelFrame:Hide()
        end
    )

    -- 显示区域
    modelFrame.playerModel = CreateFrame("DressUpModel", nil, modelFrame)  --装备类
    modelFrame.playerModel:SetPoint("CENTER", modelFrame, "CENTER", 0, -25)
    modelFrame.playerModel:SetSize(255, 550)

    -- Enable model frame mouse dragging
    local turnSpeed = 34
    local dragSpeed = 100
    local zoomSpeed = 0.5
    modelFrame.playerModel:SetPosition(0, 0, 0)
    modelFrame.playerModel:EnableMouse(true)
    modelFrame.playerModel:EnableMouseWheel(true)
    modelFrame.playerModel:SetScript(
        "OnMouseDown",
        function(self, button)
            local startPos = {
                GetCursorPosition()
            }
            if button == "LeftButton" then
                self:SetScript(
                    "OnUpdate",
                    function(self)
                        local curX = ({
                            GetCursorPosition()
                        })[1]
                        self:SetFacing(
                            ((curX - startPos[1]) / turnSpeed) + self:GetFacing()
                        )
                        startPos[1] = curX
                    end
                )
            end
        end
    )

    modelFrame.playerModel:SetScript(
        "OnMouseUp",
        function(self, button)
            self:SetScript("OnUpdate", nil)
        end
    )

    modelFrame.playerModel:SetScript(
        "OnMouseWheel",
        function(self, zoom)
            local pos = {
                self:GetPosition()
            }
            if zoom == 1 then
                pos[1] = pos[1] + zoomSpeed
            else
                pos[1] = pos[1] - zoomSpeed
            end

            if (pos[1] > 1) then
                pos[1] = 1
            elseif (pos[1] < -0.5) then
                pos[1] = -0.5
            end

            self:SetPosition(pos[1], pos[2], pos[3])
        end
    )

    -- Creature Model frame
    modelFrame.creatureModel = CreateFrame("PlayerModel", nil, modelFrame) --宠物坐骑模型类
    modelFrame.creatureModel:SetPoint("CENTER", modelFrame, "CENTER", 0, -25)
    modelFrame.creatureModel:SetSize(255, 550)

    -- Enable model frame mouse dragging
    local turnSpeed = 34
    local dragSpeed = 100
    local zoomSpeed = 0.5
    modelFrame.creatureModel:SetPosition(0, 0, 0)
    modelFrame.creatureModel:EnableMouse(true)
    modelFrame.creatureModel:EnableMouseWheel(true)
    modelFrame.creatureModel:SetScript(
        "OnMouseDown",
        function(self, button)
            local startPos = {
                GetCursorPosition()
            }
            if button == "LeftButton" then
                self:SetScript(
                    "OnUpdate",
                    function(self)
                        local curX = ({
                            GetCursorPosition()
                        })[1]
                        self:SetFacing(
                            ((curX - startPos[1]) / turnSpeed) + self:GetFacing()
                        )
                        startPos[1] = curX
                    end
                )
            end
        end
    )

    modelFrame.creatureModel:SetScript(
        "OnMouseUp",
        function(self, button)
            self:SetScript("OnUpdate", nil)
        end
    )

    modelFrame.creatureModel:SetScript(
        "OnMouseWheel",
        function(self, zoom)
            local pos = {
                self:GetPosition()
            }
            if zoom == 1 then
                pos[1] = pos[1] + zoomSpeed
            else
                pos[1] = pos[1] - zoomSpeed
            end

            if (pos[1] > 1) then
                pos[1] = 1
            elseif (pos[1] < -0.5) then
                pos[1] = -0.5
            end

            self:SetPosition(pos[1], pos[2], pos[3])
        end
    )

    -- Rotate left button
    modelFrame.leftButton = CreateFrame("Button", nil, modelFrame)
    modelFrame.leftButton:SetSize(35, 35)
    modelFrame.leftButton:SetFrameLevel(modelFrame:GetFrameLevel() + 2)
    modelFrame.leftButton:SetPoint("CENTER", modelFrame, "BOTTOM", -30, 40)
    modelFrame.leftButton:SetNormalTexture("Interface/buttons/ui-rotationleft-button-up.blp")
    modelFrame.leftButton:SetHighlightTexture("Interface/buttons/ui-common-mousehilight.blp")
    modelFrame.leftButton:SetPushedTexture("Interface/buttons/ui-rotationleft-button-down.blp")

    modelFrame.leftButton:SetScript(
        "OnMouseDown",
        function(self, button)
            PlaySound("igInventoryRotateCharacter")
            self:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    if (modelFrame.playerModel:IsShown()) then
                        modelFrame.playerModel:SetFacing(modelFrame.playerModel:GetFacing() + 0.03)
                    end

                    if (modelFrame.creatureModel:IsShown()) then
                        modelFrame.creatureModel:SetFacing(modelFrame.creatureModel:GetFacing() + 0.03)
                    end
                end
            )
        end
    )

    modelFrame.leftButton:SetScript(
        "OnMouseUp",
        function(self, button)
            self:SetScript("OnUpdate", nil)
        end
    )

    -- Rotate right button
    modelFrame.rightButton = CreateFrame("Button", nil, modelFrame)
    modelFrame.rightButton:SetSize(35, 35)
    modelFrame.rightButton:SetFrameLevel(modelFrame:GetFrameLevel() + 2)
    modelFrame.rightButton:SetPoint("CENTER", modelFrame, "BOTTOM", 30, 40)
    modelFrame.rightButton:SetNormalTexture("Interface/buttons/ui-rotationright-button-up.blp")
    modelFrame.rightButton:SetHighlightTexture("Interface/buttons/ui-common-mousehilight.blp")
    modelFrame.rightButton:SetPushedTexture("Interface/buttons/ui-rotationright-button-down.blp")

    modelFrame.rightButton:SetScript(
        "OnMouseDown",
        function(self, button)
            PlaySound("igInventoryRotateCharacter")
            self:SetScript(
                "OnUpdate",
                function(self, elapsed)
                    if (modelFrame.playerModel:IsShown()) then
                        modelFrame.playerModel:SetFacing(modelFrame.playerModel:GetFacing() - 0.03)
                    end

                    if (modelFrame.creatureModel:IsShown()) then
                        modelFrame.creatureModel:SetFacing(modelFrame.creatureModel:GetFacing() - 0.03)
                    end
                end
            )
        end
    )

    modelFrame.rightButton:SetScript(
        "OnMouseUp",
        function(self, button)
            self:SetScript("OnUpdate", nil)
        end
    )

    SHOP_UI["MODEL_FRAME"] = modelFrame
end

function SHOP_UI.ModelFrame_ShowPlayer(displayId)
    -- hacky ass model frame handling
    -- hide model frames
    if (SHOP_UI["MODEL_FRAME"].creatureModel:IsShown()) then
        SHOP_UI["MODEL_FRAME"].creatureModel:Hide()
    end

    SHOP_UI["MODEL_FRAME"].playerModel:Hide()
    SHOP_UI["MODEL_FRAME"]:Hide()

    -- set the correct unit and show frame
    SHOP_UI["MODEL_FRAME"].playerModel:SetUnit("player")
    SHOP_UI["MODEL_FRAME"].playerModel:Show()
    SHOP_UI["MODEL_FRAME"]:Show()

    if (displayId) then
        for _, id in pairs(displayId) do
            if (id > 0) then
                SHOP_UI["MODEL_FRAME"].playerModel:TryOn(id)
            end
        end
    end

    PlaySound("INTERFACESOUND_GAMESCROLLBUTTON", "Master")
end

function SHOP_UI.ModelFrame_ShowCreature(displayId)
    -- hacky ass model frame handling
    -- hide model frames
    if (SHOP_UI["MODEL_FRAME"].playerModel:IsShown()) then
        SHOP_UI["MODEL_FRAME"].playerModel:Hide()
    end

    SHOP_UI["MODEL_FRAME"].creatureModel:Hide()
    SHOP_UI["MODEL_FRAME"]:Hide()

    -- set the correct unit and show frame
    SHOP_UI["MODEL_FRAME"].creatureModel:SetCreature(displayId)
    SHOP_UI["MODEL_FRAME"].creatureModel:Show()
    SHOP_UI["MODEL_FRAME"]:Show()

    PlaySound("INTERFACESOUND_GAMESCROLLBUTTON", "Master")
end

function MainFrame_Toggle()
    if SHOP_UI["FRAME"]:IsShown() and SHOP_UI["FRAME"]:IsVisible() then
        SHOP_UI["FRAME"]:Hide()
    else
        SHOP_UI["FRAME"]:Show()
    end
end

local function ModifyGameMenuFrame()
    --商店按钮
    -- 商店按钮大小
    local frame = _G["GameMenuFrame"]
    frame:SetSize(195, 270)

    -- 商店按钮位置
    local videoButton = _G["GameMenuButtonOptions"]
    videoButton:SetPoint("CENTER", frame, "TOP", 0, -70)

    -- 在游戏菜单中添加商店按钮
    local storeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate");
    storeButton:SetPoint("CENTER", frame, 0, 165)
    storeButton:SetSize(144, 21)
    storeButton.Text = storeButton:CreateFontString()
    storeButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
    storeButton.Text:SetShadowOffset(1, -1)
    storeButton.Text:SetPoint("CENTER", storeButton, "CENTER", 0, 1)
    storeButton.Text:SetText("|cffdbe005魔兽商城");--名字

    -- 点击打开商店框架并隐藏逃生菜单
    storeButton:SetScript("OnClick", function()
        HideUIPanel(frame)
        MainFrame_Toggle()
    end)
end

-- 加载时开始创建框架
SHOP_UI.MainFrame_Create()

-- 修改游戏菜单框以添加商店按钮
ModifyGameMenuFrame()
