print(">>Script: LoginTips loading...OK")

--注册玩家登陆事件，其中player代表的是玩家变量
function LoginTips(event, player)
    player:GossipComplete()
    player:GossipClearMenu()
    player:GossipMenuAddItem(40, "登录提醒", 0, 1, false, "|TInterface/FlavorImages/BloodElfLogo-small:64:64:0:-30|t\n \n \n \n|cFF0000FF欢迎来到Forever WLK仿官公益服！|r\n\n本服禁止使用加速、飞天、挂机等脚本，发现封号处理！\n\n本服禁止利用游戏BUG刷金币、材料，发现封号处理！\n\n本服不出售金币，允许玩家之间交易。禁止私下交易(私下交易没收金币)，须找管理担保，同时收取20%的担保费用！\n\n禁止出售游戏账号，不听劝告者封号处理！")
    player:GossipSendMenu(100, player, 1999)
end
RegisterPlayerEvent(3, LoginTips)
