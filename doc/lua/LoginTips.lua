print(">>Script: LoginTips loading...OK")

--注册玩家登陆事件，其中player代表的是玩家变量
function LoginTips(event, player)
    player:GossipComplete()
    player:GossipClearMenu()
    player:GossipMenuAddItem(40, "登录提醒", 0, 1, false, "|TInterface/FlavorImages/BloodElfLogo-small:64:64:0:-30|t\n \n \n \n|cFF0000FF欢迎来到Forever仿官公益服！|r\n\n本服生存模式分为【普通模式】和【一命模式】\n\n普通模式【2级自动送新手币，可以在新手商人处购买传家宝，经验6倍】\n\n一命模式【不可以购买传家宝，死亡后不可复活，经验3倍】\n\n默认为【普通模式】，【一命模式】开启命令onelife")    
    player:GossipSendMenu(100, player, 1999)
end
RegisterPlayerEvent(3, LoginTips)

