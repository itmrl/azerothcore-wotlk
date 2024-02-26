print(">>Script: Online loading...OK")
local Time = {--设置系统发放奖励的时间间隔 下面分别是秒，分钟，时(PS:时间间隔最少1分钟(或者60秒)要不出bug)
    ["s"] = 0,
    ["m"] = 60,
    ["h"] = 0,
}

--玩家只要达到上面所设置的在线时间的百分比就可以领取奖励。例如如果设置10分钟领，按这里默认的80的话就是只要累计达到8分半钟就可以了
local OnlineTimePCT = 100

local jf_entry = 80005
local jf = 1
local pOnlineTime = {}
local pRewardCount = {}

local function Online_Reward_MSG()

end

local function _Time(s, m, h)
    if m ~= -1 and h ~= -1 then
        local _t = (s + 60 * m + 3600 * h)
        return _t
    elseif m == -1 and h == -1 then
        local _h = math.floor(s / 60 / 60)
        local _m = math.floor(s / 60 - _h * 60)
        local _s = math.floor(s - _m * 60 - _h * 60 * 60)
        return _s, _m, _h
    end
end

local function Online_Reward()
    for _, p in pairs(GetPlayersInWorld()) do
        local pGuid = p:GetGUIDLow()
        if pOnlineTime[pGuid] == nil then
            pOnlineTime[pGuid] = p:GetTotalPlayedTime()
        end
        if pRewardCount[pGuid] == nil then
            pRewardCount[pGuid] = 0
        end
        if  pRewardCount[pGuid] < 10 then
            local _OnlineTime = p:GetTotalPlayedTime() - pOnlineTime[pGuid]
            local s, m, h = _Time(_OnlineTime, -1, -1)
            p:AddItem(jf_entry, jf)
            p:SendBroadcastMessage("累积在线60分钟,成功获取" .. GetItemLink(jf_entry) .. " x " .. jf)
            pOnlineTime[pGuid] = pOnlineTime[pGuid] + _OnlineTime
            pRewardCount[pGuid] = pRewardCount[pGuid] + 1
        else
            p:SendBroadcastMessage("今日已累积获取10次在线泡点奖励，无法再次获取！")
        end
    end
    CreateLuaEvent(Online_Reward, _Time(Time.s, Time.m, Time.h) * 1000, 1)
    CreateLuaEvent(Online_Reward_MSG, (_Time(Time.s, Time.m, Time.h) - 60) * 1000, 1)
end

local function Online_Clean()
    pRewardCount = {}
end

local function Online_Onlogin(_, p)
    local pGuid = p:GetGUIDLow()
    if pOnlineTime[pGuid] == nil then
        pOnlineTime[pGuid] = p:GetTotalPlayedTime()
    end
end

CreateLuaEvent(Online_Clean, _Time(0, 0, 24) * 1000, 0)
RegisterPlayerEvent(3, Online_Onlogin)
CreateLuaEvent(Online_Reward, _Time(Time.s, Time.m, Time.h) * 1000, 1)
CreateLuaEvent(Online_Reward_MSG, (_Time(Time.s, Time.m, Time.h) - 60) * 1000, 1)
