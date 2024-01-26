print(">>Script: AutoJoinGuildOnLogin loading...OK")

local guildid = {
    --自动加入的工会名称
    [0] = '八荒六合唯我独尊', --联盟
    [1] = '八荒六合唯我独尊'--部落
}
local guildrank = {--默认加入的等级，等级可以在guild_rank表查看字段rid，一般默认为会长、官员、精英、会员、新人，依次为0，1，2，3，4
    [0] = 4, --联盟
    [1] = 4 --部落
}
--注册玩家登陆事件，其中player代表的是玩家变量
function AutoJoinGuildOnLogin(event, player)
    if player:GetLevel() >= 1 then
        if not player:IsInGuild() then
            local newguild = GetGuildByName(guildid[player:GetTeam()])
            if newguild == nil then
            else
                newguild:AddMember(player, guildrank[player:GetTeam()])  --AddMember(玩家,等级)像工会添加成员
                player:SendBroadcastMessage('你已加入工会[' .. guildid[player:GetTeam()] .. ']')--在客户端打印一行提示，这个比较常用，可以用来输出很多东西
            end
        end
    end
end
--注册玩家登陆事件,在玩家登陆角色的时候触发，3代表是登陆，AutoJoinGuildOnLogin 代表需要出发的具体代码
RegisterPlayerEvent(3, AutoJoinGuildOnLogin)

