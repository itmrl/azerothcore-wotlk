local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local LuckHandlers = AIO.AddHandlers("LuckDrawUI", {})

--物品变量(对应服务端).改动需跟服务端一致.复制即可
local ShopData = {
    { 44128, 1 }, --ss  极低毛皮
    { 84002, 1 }, --sss   小温斯顿
    { 36908, 1 }, --ss  雪莲花
    { 40752, 2 }, --s   英雄纹章
    { 80001, 1 }, --ss  赞助币
    { 90306, 1 }, --sss 暴雪巨熊
    { 80002, 2 }, --s   积分
    { 40753, 1 }, --ss  勇气纹章
    { 90310, 1 }, --s   熔岩猎豹
    { 43102, 1 }, --ss  冰冻宝珠
    { 36912, 2 }, --s   萨隆邪铁
    { 34055, 1 }, --ss  强效宇宙精华
    { 36906, 2 }, --s   冰棘草
    { 90307, 1 }, --ssss 暖日绒猫
    { 36910, 1 }, --ss  泰坦神铁
    { 34054, 2 }, --s   无限之尘
};

--显示的图标Link
local IconLinkData = {
    { GetItemIcon(ShopData[1][1]), "|Hitem:" .. ShopData[1][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[2][1]), "|Hitem:" .. ShopData[2][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[3][1]), "|Hitem:" .. ShopData[3][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[4][1]), "|Hitem:" .. ShopData[4][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[5][1]), "|Hitem:" .. ShopData[5][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[6][1]), "|Hitem:" .. ShopData[6][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[7][1]), "|Hitem:" .. ShopData[7][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[8][1]), "|Hitem:" .. ShopData[8][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[9][1]), "|Hitem:" .. ShopData[9][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[10][1]), "|Hitem:" .. ShopData[10][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[11][1]), "|Hitem:" .. ShopData[11][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[12][1]), "|Hitem:" .. ShopData[12][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[13][1]), "|Hitem:" .. ShopData[13][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[14][1]), "|Hitem:" .. ShopData[14][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[15][1]), "|Hitem:" .. ShopData[15][1] .. ":0:0:0:0:0:0:0:1" },
    { GetItemIcon(ShopData[16][1]), "|Hitem:" .. ShopData[16][1] .. ":0:0:0:0:0:0:0:1" },
};

local linkSW = false
local Number = nil

local LuckFrame = CreateFrame("Frame", "LuckFrame", UIParent)
LuckFrame:SetSize(700, 400)
LuckFrame:RegisterForDrag("LeftButton")
LuckFrame:SetPoint("CENTER")
LuckFrame:SetToplevel(true)
LuckFrame:SetClampedToScreen(true)
LuckFrame:SetMovable(true)
LuckFrame:EnableMouse(true)
LuckFrame:SetScript("OnDragStart", LuckFrame.StartMoving)
LuckFrame:SetScript("OnHide", LuckFrame.StopMovingOrSizing)
LuckFrame:SetScript("OnDragStop", LuckFrame.StopMovingOrSizing)
LuckFrame:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

LuckFrame:EnableMouseWheel(true)

tinsert(UISpecialFrames, "LuckFrame")

LuckFrame:Hide()

-- 初始框
local LuckFrameOnShow = CreateFrame("Button", "LuckFrameOnShow", UIParent)
LuckFrameOnShow:SetSize(44, 44)
LuckFrameOnShow:SetPoint("CENTER", 300, -240)
LuckFrameOnShow:SetMovable(true)
LuckFrameOnShow:EnableMouse(true)
LuckFrameOnShow:RegisterForDrag("LeftButton")
LuckFrameOnShow:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
LuckFrameOnShow:SetBackdrop({ bgFile = "Interface\\ICONS\\INV_Misc_FireDancer_01" })--INV_Misc_FireDancer_01
LuckFrameOnShow:SetScript("OnDragStart", LuckFrameOnShow.StartMoving)
LuckFrameOnShow:SetScript("OnDragStop", LuckFrameOnShow.StopMovingOrSizing)
LuckFrameOnShow:SetScript("OnMouseUp",
    function(self)
        if (LuckFrame:IsShown()) then
            LuckFrame:Hide()
        else
            LuckFrame:Show()
        end
    end)

LuckFrameOnShow:SetScript("OnEnter",
    function(self)
        GameTooltip:SetOwner(LuckFrameOnShow, "ANCHOR_LEFT")
        GameTooltip.default = 1;
        GameTooltip:SetText("|cFFFF0033幸运抽奖功能|r\n|cFFFFCC66按住拖动图标|r\n|cFF99FF33单击打开功能|r\n|cFF00CCFF再次单击关闭|r\n|cFF00CCFF按 Esc 键退出|r")
        GameTooltip:Show()
    end)

LuckFrameOnShow:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide()
    end)

LuckFrameOnShow:Show()

-- 关闭按钮
local LuckbuttonClose = CreateFrame("Button", "LuckbuttonClose", LuckFrame, "UIPanelCloseButton")
LuckbuttonClose:SetPoint("TOPRIGHT", 15, 15)
LuckbuttonClose:EnableMouse(true)
LuckbuttonClose:SetSize(36, 36)

-- 标题模块
local LuckTitleBar = CreateFrame("Frame", "LuckTitleBar", LuckFrame, nil)
LuckTitleBar:SetSize(150, 30)
LuckTitleBar:SetPoint("TOP", 0, 25)
LuckTitleBar:EnableMouse(true)
LuckTitleBar:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        edgeSize = 16,
        tileSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

--标题模块文字描述
local LuckTitleText = LuckTitleBar:CreateFontString("LuckTitleText")
LuckTitleText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 18)
LuckTitleText:SetPoint("CENTER", 0, 0)
LuckTitleText:SetText("|cffFFC125幸运抽奖|r")


--小图标框1-20
local LuckbuttonIcon1 = CreateFrame("Button", "LuckbuttonIcon1", LuckFrame, nil)
local LuckbuttonIcon2 = CreateFrame("Button", "LuckbuttonIcon2", LuckFrame, nil)
local LuckbuttonIcon3 = CreateFrame("Button", "LuckbuttonIcon3", LuckFrame, nil)
local LuckbuttonIcon4 = CreateFrame("Button", "LuckbuttonIcon4", LuckFrame, nil)
local LuckbuttonIcon5 = CreateFrame("Button", "LuckbuttonIcon5", LuckFrame, nil)
local LuckbuttonIcon6 = CreateFrame("Button", "LuckbuttonIcon6", LuckFrame, nil)
local LuckbuttonIcon7 = CreateFrame("Button", "LuckbuttonIcon7", LuckFrame, nil)
local LuckbuttonIcon8 = CreateFrame("Button", "LuckbuttonIcon8", LuckFrame, nil)
local LuckbuttonIcon9 = CreateFrame("Button", "LuckbuttonIcon9", LuckFrame, nil)
local LuckbuttonIcon10 = CreateFrame("Button", "LuckbuttonIcon10", LuckFrame, nil)
local LuckbuttonIcon11 = CreateFrame("Button", "LuckbuttonIcon11", LuckFrame, nil)
local LuckbuttonIcon12 = CreateFrame("Button", "LuckbuttonIcon12", LuckFrame, nil)
local LuckbuttonIcon13 = CreateFrame("Button", "LuckbuttonIcon13", LuckFrame, nil)
local LuckbuttonIcon14 = CreateFrame("Button", "LuckbuttonIcon14", LuckFrame, nil)
local LuckbuttonIcon15 = CreateFrame("Button", "LuckbuttonIcon15", LuckFrame, nil)
local LuckbuttonIcon16 = CreateFrame("Button", "LuckbuttonIcon16", LuckFrame, nil)

local LuckString1 = LuckbuttonIcon1:CreateFontString("LuckString1")
local LuckString2 = LuckbuttonIcon2:CreateFontString("LuckString2")
local LuckString3 = LuckbuttonIcon3:CreateFontString("LuckString3")
local LuckString4 = LuckbuttonIcon4:CreateFontString("LuckString4")
local LuckString5 = LuckbuttonIcon5:CreateFontString("LuckString5")
local LuckString6 = LuckbuttonIcon6:CreateFontString("LuckString6")
local LuckString7 = LuckbuttonIcon7:CreateFontString("LuckString7")
local LuckString8 = LuckbuttonIcon8:CreateFontString("LuckString8")
local LuckString9 = LuckbuttonIcon9:CreateFontString("LuckString9")
local LuckString10 = LuckbuttonIcon10:CreateFontString("LuckString10")
local LuckString11 = LuckbuttonIcon11:CreateFontString("LuckString11")
local LuckString12 = LuckbuttonIcon12:CreateFontString("LuckString12")
local LuckString13 = LuckbuttonIcon13:CreateFontString("LuckString13")
local LuckString14 = LuckbuttonIcon14:CreateFontString("LuckString14")
local LuckString15 = LuckbuttonIcon15:CreateFontString("LuckString15")
local LuckString16 = LuckbuttonIcon16:CreateFontString("LuckString16")

local LuckCountStr1 = LuckbuttonIcon1:CreateFontString("LuckCountStr1")
local LuckCountStr2 = LuckbuttonIcon2:CreateFontString("LuckCountStr2")
local LuckCountStr3 = LuckbuttonIcon3:CreateFontString("LuckCountStr3")
local LuckCountStr4 = LuckbuttonIcon4:CreateFontString("LuckCountStr4")
local LuckCountStr5 = LuckbuttonIcon5:CreateFontString("LuckCountStr5")
local LuckCountStr6 = LuckbuttonIcon6:CreateFontString("LuckCountStr6")
local LuckCountStr7 = LuckbuttonIcon7:CreateFontString("LuckCountStr7")
local LuckCountStr8 = LuckbuttonIcon8:CreateFontString("LuckCountStr8")
local LuckCountStr9 = LuckbuttonIcon9:CreateFontString("LuckCountStr9")
local LuckCountStr10 = LuckbuttonIcon10:CreateFontString("LuckCountStr10")
local LuckCountStr11 = LuckbuttonIcon11:CreateFontString("LuckCountStr11")
local LuckCountStr12 = LuckbuttonIcon12:CreateFontString("LuckCountStr12")
local LuckCountStr13 = LuckbuttonIcon13:CreateFontString("LuckCountStr13")
local LuckCountStr14 = LuckbuttonIcon14:CreateFontString("LuckCountStr14")
local LuckCountStr15 = LuckbuttonIcon15:CreateFontString("LuckCountStr15")
local LuckCountStr16 = LuckbuttonIcon16:CreateFontString("LuckCountStr16")

for i = 1, 16, 1 do
    _G["LuckbuttonIcon" .. i]:SetSize(52, 52)
    _G["LuckbuttonIcon" .. i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square")
    _G["LuckString" .. i]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
    _G["LuckString" .. i]:SetAllPoints(_G["LuckbuttonIcon" .. i])
    _G["LuckbuttonIcon" .. i]:SetFontString(_G["LuckString" .. i])
    _G["LuckbuttonIcon" .. i]:SetText("|T" .. IconLinkData[i][1] .. ":48|t")

    _G["LuckCountStr" .. i]:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12, "OUTLINE")
    _G["LuckCountStr" .. i]:SetPoint("CENTER", _G["LuckbuttonIcon" .. i], 0, -10)
    _G["LuckCountStr" .. i]:SetText("|cFFFF6600" .. ShopData[i][2] .. "|r")
end

LuckbuttonIcon1:SetPoint("TOPLEFT", 20, -50)
LuckbuttonIcon2:SetPoint("TOPLEFT", 20, -100)
LuckbuttonIcon3:SetPoint("TOPLEFT", 20, -150)
LuckbuttonIcon4:SetPoint("TOPLEFT", 20, -200)
LuckbuttonIcon5:SetPoint("TOPLEFT", 20, -250)
LuckbuttonIcon6:SetPoint("TOPLEFT", 70, -250)
LuckbuttonIcon7:SetPoint("TOPLEFT", 120, -250)
LuckbuttonIcon8:SetPoint("TOPLEFT", 170, -250)
LuckbuttonIcon9:SetPoint("TOPLEFT", 220, -250)
LuckbuttonIcon10:SetPoint("TOPLEFT", 220, -200)
LuckbuttonIcon11:SetPoint("TOPLEFT", 220, -150)
LuckbuttonIcon12:SetPoint("TOPLEFT", 220, -100)
LuckbuttonIcon13:SetPoint("TOPLEFT", 220, -50)
LuckbuttonIcon14:SetPoint("TOPLEFT", 170, -50)
LuckbuttonIcon15:SetPoint("TOPLEFT", 120, -50)
LuckbuttonIcon16:SetPoint("TOPLEFT", 70, -50)

--提示1
local LuckStrCmTextS = LuckFrame:CreateFontString("LuckStrCmText")
LuckStrCmText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
LuckStrCmText:SetPoint("TOPLEFT", 20, -10)

--中间显示框
local LuckbuttonCenter = CreateFrame("Button", "LuckbuttonCenter", LuckFrame)
LuckbuttonCenter:SetSize(80, 80)
LuckbuttonCenter:SetPoint("TOPLEFT", LuckFrame, 110, -140)
LuckbuttonCenter:SetBackdrop({ bgFile = "Interface\\BUTTONS\\UI-EmptySlot", })

--中间
local LuckFontTest = LuckbuttonCenter:CreateFontString("LuckFontTest")
LuckFontTest:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
LuckFontTest:SetAllPoints(LuckbuttonCenter)
LuckbuttonCenter:SetFontString(LuckFontTest)

--提示2
local LuckStrCmTextX = LuckFrame:CreateFontString("LuckStrCmTextX")
LuckStrCmTextX:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
LuckStrCmTextX:SetPoint("TOPLEFT", 20, -300)
LuckStrCmTextX:SetText("|cffFFC125鼠标滑过可查看奖品信息.请保证背包空间充足|r")

--提示3
local LuckStrCmTextH = LuckFrame:CreateFontString("LuckStrCmTextH")
LuckStrCmTextH:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
LuckStrCmTextH:SetPoint("TOPLEFT", 80, -320)
LuckStrCmTextH:Hide()

local LuckStrCmTextKJ = LuckFrame:CreateFontString("LuckStrCmTextKJ")
LuckStrCmTextKJ:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
LuckStrCmTextKJ:SetPoint("TOPLEFT", 80, -340)
LuckStrCmTextKJ:SetText("|cFFFF66FF本次奖品已发放到背包|r")
LuckStrCmTextKJ:Hide()

function LuckHandlers.StartLuck(player, flag)
    if (flag == 0) then
        LuckStrCmTextH:SetText("|cFF00FF00正在抽奖中...剩余次数 [1]|r")
    else
        LuckStrCmTextH:SetText("|cFF00FF00正在抽奖中...剩余次数 [10]|r")
    end

    linkSW = false
    LuckStrCmTextKJ:Hide()
    StartButtonLuckOne:Hide()
    StartButtonLuckTen:Hide()
    LuckStrCmTextH:Show()
    LuckbuttonCenter:UnlockHighlight()
end

--抽奖按钮-单次
local StartButtonLuckOne = CreateFrame("Button", "StartButtonLuckOne", LuckFrame, "UIPanelButtonTemplate")
StartButtonLuckOne:SetSize(100, 25)
StartButtonLuckOne:SetPoint("TOPLEFT", 10, -360)
StartButtonLuckOne:EnableMouse(true)
StartButtonLuckOne:SetScript("OnClick",
    function(self)
        AIO.Handle("LuckDrawUI", "SelectItem", 0)
    end)

local FontStringLuckOne = StartButtonLuckOne:CreateFontString("FontStringLuckOne")
FontStringLuckOne:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
StartButtonLuckOne:SetFontString(FontStringLuckOne)
StartButtonLuckOne:SetText("开始抽奖(单次)")

--抽奖按钮-十连
local StartButtonLuckTen = CreateFrame("Button", "StartButtonLuckTen", LuckFrame, "UIPanelButtonTemplate")
StartButtonLuckTen:SetSize(100, 25)
StartButtonLuckTen:SetPoint("TOPLEFT", 180, -360)
StartButtonLuckTen:EnableMouse(true)
StartButtonLuckTen:SetScript("OnClick",
    function(self)
        AIO.Handle("LuckDrawUI", "SelectItem", 1)
    end)

local FontStringLuckTen = StartButtonLuckTen:CreateFontString("FontStringLuckTen")
FontStringLuckTen:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
StartButtonLuckTen:SetFontString(FontStringLuckTen)
StartButtonLuckTen:SetText("开始抽奖(十连)")

LuckFrame:SetScript("OnShow",
    function(self)
        AIO.Handle("LuckDrawUI", "ShowItemLink")
        linkSW = false
        LuckStrCmTextKJ:Hide()
        LuckbuttonCenter:UnlockHighlight()
        LuckbuttonCenter:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square")
        LuckbuttonCenter:SetText("")
        for i = 1, 16, 1 do
            _G["LuckbuttonIcon" .. i]:UnlockHighlight()
            _G["LuckbuttonIcon" .. i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square")
        end
    end)

function LuckHandlers.ShowUseItemLink(player, S1, S2, S3)
    LuckStrCmText:SetText("|cffFFC125专业材料.稀有货币.新品坐骑.人品爆发即可拥有|r\n\n|cffFFC125每次抽奖需要消耗|r |T" .. GetItemIcon(S1) .. ":16|t " .. S3 .. " x |CFFFF0000" .. S2 .. "|r")
end

function LuckHandlers.StartCenter(player, P)
    for i = 1, 16, 1 do
        _G["LuckbuttonIcon" .. i]:UnlockHighlight()
        _G["LuckbuttonIcon" .. i]:SetHighlightTexture("Interface\\BUTTONS\\OldButtonHilight-Square")
        if (tonumber(P) == i) then
            LuckbuttonCenter:SetText("|T" .. IconLinkData[i][1] .. ":80|t")
            _G["LuckbuttonIcon" .. i]:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight")
            _G["LuckbuttonIcon" .. i]:LockHighlight()
        end
    end
end

for i = 1, 16, 1 do
    --鼠标显示图标
    _G["LuckbuttonIcon" .. i]:SetScript("OnEnter",
        function(self)
            GameTooltip:SetOwner(_G["LuckbuttonIcon" .. i], "ANCHOR_LEFT")
            GameTooltip:SetHyperlink(IconLinkData[i][2])
            GameTooltip:Show()
        end)

    _G["LuckbuttonIcon" .. i]:SetScript("OnLeave",
        function(self)
            GameTooltip:Hide()
        end)
end

function LuckHandlers.ShowButtonState(player, K, F, C)
    Number = tonumber(K)
    linkSW = true
    LuckbuttonCenter:SetHighlightTexture("Interface\\BUTTONS\\CheckButtonHilight")
    LuckbuttonCenter:LockHighlight()
    LuckStrCmTextKJ:Show()
    if (F == 0) then
        LuckStrCmTextH:Hide()
        StartButtonLuckTen:Show()
        StartButtonLuckOne:Show()
    else
        if (C > 0) then
            LuckStrCmTextH:Show()
            LuckStrCmTextH:SetText("|cFF00FF00正在抽奖中...剩余次数 [" .. C .. "]|r")
        else
            LuckStrCmTextH:Hide()
            StartButtonLuckTen:Show()
            StartButtonLuckOne:Show()
        end
    end
end

function LuckHandlers.StartUpdateTx(player)
    LuckStrCmTextKJ:Hide()
end

LuckbuttonCenter:SetScript("OnEnter",
    function(self)
        if (linkSW == true) then
            GameTooltip:SetOwner(LuckbuttonCenter, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(IconLinkData[Number][2])
            GameTooltip:Show()
        end
    end)

LuckbuttonCenter:SetScript("OnLeave",
    function(self)
        GameTooltip:Hide()
    end)

--滚动框外框
local LuckScrollOut = CreateFrame("Frame", "LuckScrollOut", LuckFrame)
LuckScrollOut:SetSize(380, 360)
LuckScrollOut:SetPoint("RIGHT", -30, -10)
LuckScrollOut:SetBackdrop(
    {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
LuckScrollOut:EnableMouseWheel(true)

--提示4
local LuckScrollMsgText = LuckScrollOut:CreateFontString("LuckScrollMsgText")
LuckScrollMsgText:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 15)
LuckScrollMsgText:SetPoint("TOP", LuckScrollOut, 0, 20)
LuckScrollMsgText:SetText("|cFF00FF00抽奖滚动信息|r")

--滚动条
local LuckScrollBar = CreateFrame("Slider", "LuckScrollBar", LuckScrollOut, "OptionsSliderTemplate")
LuckScrollBar:SetSize(20, 370)
LuckScrollBar:SetPoint("RIGHT", LuckScrollOut, 20, 0)
LuckScrollBar:EnableMouseWheel(true)
LuckScrollBar:SetOrientation("VERTICAL")
_G[LuckScrollBar:GetName() .. "High"]:Hide()
_G[LuckScrollBar:GetName() .. "Low"]:Hide()
LuckScrollBar:SetMinMaxValues(1, 100)
LuckScrollBar:SetValue(1)
LuckScrollBar:SetValueStep(9)

LuckScrollBar:SetScript("OnMouseWheel",
    function(self, delta)
        local Value = self:GetValue()
        if (delta < 0) then
            self:SetValue(Value + 10)
        else
            self:SetValue(Value - 10)
        end
    end)

--滚动消息内
local LuckScrollMsg = CreateFrame("ScrollingMessageFrame", "LuckScrollMsg", LuckScrollOut, "ChatFrameTemplate")
LuckScrollMsg:SetSize(370, 350)
LuckScrollMsg:SetPoint("CENTER")
LuckScrollMsg:SetFont("Interface\\Fonts\\FRIZQT_.TTF", 12)
LuckScrollMsg:SetSpacing(10)
LuckScrollMsg:SetFrameStrata("HIGH")
LuckScrollMsg:SetFading(false)
LuckScrollMsg:SetInsertMode("BOTTOM")
LuckScrollMsg:ScrollToTop()
LuckScrollMsg:SetMaxLines(100)
LuckScrollMsg:Show()

function LuckHandlers.UpdateScrollMsg(player, ScrollMsg)
    if (LuckScrollMsg:GetNumMessages() >= LuckScrollMsg:GetMaxLines()) then
        LuckScrollMsg:Clear()
        LuckScrollMsg:AddMessage(ScrollMsg)
    else
        LuckScrollMsg:AddMessage(ScrollMsg)
    end
end

LuckScrollBar:SetScript("OnValueChanged",
    function(self, value)
        if (value < 100) then
            LuckScrollMsg:ScrollUp()
        else
            LuckScrollMsg:ScrollDown()
        end
    end)

--鼠标轮滑向下=-1 向上=1
LuckScrollOut:SetScript("OnMouseWheel",
    function(self, delta)
        local Value = LuckScrollBar:GetValue()
        if (delta < 0) then
            LuckScrollMsg:ScrollDown()
            LuckScrollBar:SetValue(Value + 10)
        else
            LuckScrollMsg:ScrollUp()
            LuckScrollBar:SetValue(Value - 10)
        end
    end)

--鼠标轮滑向下=-1 向上=1
LuckFrame:SetScript("OnMouseWheel",
    function(self, delta)
        local Value = LuckScrollBar:GetValue()
        if (delta < 0) then
            LuckScrollMsg:ScrollDown()
            LuckScrollBar:SetValue(Value + 10)
        else
            LuckScrollMsg:ScrollUp()
            LuckScrollBar:SetValue(Value - 10)
        end
    end)

