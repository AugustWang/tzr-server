-record(r_letter_template,{key,content}).
-define(LETTER_TEMPLATE,
        [%%等级信件
         {r_letter_template,1001,
            "亲爱的玩家朋友：\n        恭喜你升到10级，10级以后需要在人物属性界面点击“<font color=\"#f53f3c\">+</font>”按钮分配属性。\n        现在的你可以：\n        1、完成主线任务，获得大量经验和物品奖励。\n        2、去横涧山打怪练级（组队前往更有效率）。\n        3、加入门派、找个师父，和志同道合的人一起闯荡江湖。\n        祝你开心游戏！\n<p align=\"right\">小帮手</p>"},
           {r_letter_template,1002,
            "亲爱的玩家朋友：\n        你太厉害了！轻轻松松就升到<font color=\"#f53f3c\">16</font>级！\n        现在你可以在<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>王都—常遇春</u></font></a>接受“<font color=\"#f53f3c\">五行</font>”系列任务获得五行属性（五行相生相克的玩家组队时会有可观的属性加成）。\n        祝你开心游戏！\n<p align=\"right\">小帮手</p>"},                    
           {r_letter_template,1003,
            "亲爱的玩家朋友：\n        你果然不同凡响！这么快升到<font color=\"#f53f3c\">20</font>级！\n        你已脱离新手保护期，可以进入高级城市冒险了。在角色头像附近可以切换“PK模式”，与其他玩家进行切磋。\n        加入门派，每天完成“<font color=\"#f53f3c\">拉镖任务</font>”，获得丰厚奖励。\n        祝您开心游戏！\n<p align=\"right\">小帮手</p>"},
           {r_letter_template,1004,
            "亲爱的玩家朋友：\n        你知道<font color=\"#f53f3c\">大明宝藏</font>吗？\n        王都NPC<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>宝藏传送员</u></font></a>，每天13:00-13:30准时开启大明宝藏。\n        加入门派，每天完成“<font color=\"#f53f3c\">拉镖任务</font>”，在门派地图内击败<font color=\"#f53f3c\">门派Boss</font>，可以获得丰厚奖励。\n        祝您开心游戏！\n<p align=\"right\">小帮手</p>"},
           {r_letter_template,1005,
            "亲爱的玩家朋友：\n        你已经25级，按E打开天工炉探索它的神奇之处吧！\n        快速升级的秘诀：\n        <font color=\"#f53f3c\">循环任务</font>，连续完成一定次数，将获得丰厚的翻倍奖励！\n        升级的另一个捷径：太平村，找<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>张三丰</u></font></a>进行<font color=\"#f53f3c\">离线挂机</font>，轻松不费事。\n        祝您开心游戏！\n<p align=\"right\">小帮手</p>"},
           {r_letter_template,1006,
            "亲爱的玩家朋友：\n        真厉害！升到<font color=\"#f53f3c\">26</font>级了，两个<font color=\"#f53f3c\">升级秘诀</font>必须告诉你： \n        1、<b>参加“<font color=\"#f53f3c\">讨伐敌营</font>”副本</b>\n        开启时间：每天01:00-02:00，10:00-11:00，19:30-20:30，22:00-23:00。\n        玩法介绍：等级≥25，已加入门派，组成3人以上队伍。平江、鄱阳湖、杏花岭将刷新出大量开启副本的NPC——明军统领。由队长点击明军统领开启。\n        祝您开心游戏！\n<p align=\"right\">小帮手</p>"},
           {r_letter_template,1007,
            "亲爱的玩家朋友：\n        都28级了，你有徒弟了吗？ \n        <a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>王都-李梦阳</u></font></a>处，可以收徒。快捷键“O”查看『师徒』。徒弟升级贡献了师德值，师德值可以换经验、消除PK值哦。\n        <font color=\"#f53f3c\">升级秘诀</font>告诉你：到王都找<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>武学宗师-张三丰</u></font></a>进行<b><font color=\"#f53f3c\">离线挂机</font></b>，轻松不费事。\n        祝您在天之刃中开心游戏！"},
           {r_letter_template,1008,
            "亲爱的玩家朋友：\n        太强了！升到31级了，想知道<font color=\"#f53f3c\">赚钱的秘诀吗</font>？我来告诉你吧！ \n        1、有门派，就可以跑商了。找王都NPC<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>夏原吉</u></font></a>领取商票，进行商贸，可以获得大量银子。\n        2、有门派，就可以拉镖了。国王发布<font color=\"#f53f3c\">国运</font>后，国运拉镖获得的银子奖励25%为银子。不容错过哦。\n        3、王都NPC<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>宝藏传送员</u></font></a>，每天13:00-13:30准时开启<font color=\"#f53f3c\">大明宝藏<font color=\"#f53f3c\">，不得不去！\n        祝您在天之刃中玩得开心！\n<p align=\"right\">小帮手</p>"},
           {r_letter_template,1009,
            "亲爱的玩家朋友：\n        相当厉害升到39级了，先透露下40级内容吧！ \n        1、可以通过<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>边防大将军—沐英</u></font></a>去其他国家了。\n        2、<font color=\"#f53f3c\">刺探军情</font>任务，相当危险，不过银子奖励相当丰厚！\n        3、<font color=\"#f53f3c\">守卫国土</font>任务，有丰富的经验奖励哦！\n        加油升级吧。"},
           {r_letter_template,1010,
            "亲爱的玩家朋友：\n        你太厉害了！轻轻松松就升到<font color=\"#f53f3c\">16</font>级！\n        通过完成任务快速升到18级，就可以领取你的第一匹坐骑啦！领取坐骑后还可以通过角色面板的坐骑界面进一步提升移动速度哦。\n        祝你开心游戏！\n<p align=\"right\">小帮手</p>"},                    
           {r_letter_template,1011,
            "亲爱的玩家朋友：\n        升到25级了，两个<font color=\"#f53f3c\">好玩的副本</font>必须告诉你：\n        <b>1、<font color=\"#f53f3c\">讨伐敌营</font>，迅速攀升</b>\n        加入门派后，组成3人以上队伍就可到<font color=\"#f53f3c\">王都</font>寻找明军统领。每天01:00-02:00，10:00-11:00，19:30-20:30，22:00-23:00，由队长点击明军统领开启。\n        <b>2、<font color=\"#f53f3c\">大明宝藏</font>，惊喜不断</b>\n        王都NPC<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>宝藏传送员</u></font></a>，每天开启<font color=\"#f53f3c\">大明宝藏</font>，银票、经验果实、玫瑰、药材、原料等等大放送，不得不去！\n        祝您在天之刃中开心游戏！"},                    
           {r_letter_template,1012,
            "亲爱的玩家朋友：\n        太强了！升到30级了，想知道<font color=\"#f53f3c\">赚钱的秘诀吗</font>？悄悄告诉你： \n        1、有门派，就可以跑商了。找王都NPC<a href=\"event:N|~s\"><font  color=\"#f53f3c\"><u>夏原吉</u></font></a>领取商票，进行商贸，可以获得大量银子。\n        2、有门派，就可以拉镖了。<font color=\"#f53f3c\">19:00-19:40国运期间</font>，拉镖获得的银两奖励中<font color=\"#f53f3c\">15%</font>为银子。不容错过哦。\n        祝您在天之刃中玩得开心！"},
         
         %%门派信件
         {r_letter_template,2001,
          "尊敬的掌门/长老：\n      您的门派<font  color=\"#3be450\"> ~s </font>目前拥有门派资金<font  color=\"#3be450\">~w</font>锭<font  color=\"#3be450\">~w</font>两<font  color=\"#3be450\">~w</font>文，繁荣度<font  color=\"#3be450\">~w</font>点，每天维护门派所需门派资金<font  color=\"#3be450\">~w</font>两，门派繁荣度<font  color=\"#3be450\">~w</font>点，您的门派面临着降级、或者被收回门派地图的风险。\n      建议您积极组织门派帮众参与<font  color=\"#3be450\">门派Boss</font>、<font  color=\"#3be450\">门派拉镖</font>、<font  color=\"#3be450\">商贸</font>等活动，提升门派繁荣度、门派资金。\n\n<p align=\"right\">门派管理员</p>"},
         {r_letter_template,2002,
          "亲爱的[<font color=\"#FFFF00\">~s</font>]:\n      由于你的门派日常维护资金或繁荣度不足，你的门派已降至<font color=\"#FFFF00\">~w</font>级，~s\n      建议你积极组织门派帮众参与<font  color=\"#FFFF00\">门派Boss</font>、<font  color=\"#FFFF00\">门派拉镖</font>、<font  color=\"#FFFF00\">商贸</font>等活动，提升门派繁荣度、门派资金。\n\n<p align=\"right\">门派管理员</p>"},
         {r_letter_template,2003,
          "掌门<font  color=\"#3be450\"> ~s </font>：\n      你好！你已经连续6天没有上线了，如果下次连续超过7天不登陆，则掌门身份将被转交给其他帮众。\n\n<p align=\"right\">~s门派</p>"},
         {r_letter_template,2004,
          "掌门<font  color=\"#3be450\"> ~s </font>：\n      你好！由于你已经连续7天没有上线，掌门已经转交给了[<font  color=\"#3be450\"> ~s </font>]玩家了。\n\n<p align=\"right\">~s门派</p>"},
         {r_letter_template,2005,
          "亲爱的[~s]:\n      恭喜你成功创建了门派 <font color=\"#ffff00\">~s</font>。\n      在门派地图里，可以每天开启<font color=\"#ff0000\"> 门派Boss</font>，获得海量经验。\n\n<p align=\"right\">门派管理员</p>"},
         {r_letter_template,2006,
          "亲爱的[<font color=\"#FFFF00\">~s</font>]：\n      欢迎你加入门派<font color=\"#FFFF00\"> ~s </font>！\n      希望你门派中踊跃发言、积极参加门派活动，我们一起闯荡天之刃，成就我们的英雄传奇！\n\n<p align=\"right\">门派管理员</p>"},
         {r_letter_template,2007,
          "你已经被<font color=\"#FFFF00\">[~s]</font>开除出~s门派了"},
         {r_letter_template,2008,         
          "<font color=\"#ffff00\">~s：</font>\n       我们门派<font color=\"#3be450\">~s</font>已经成功并入门派<font color=\"#3be450\">~s</font>，我们将和门派<font color=\"#3be450\">~s</font>的所有帮众朋友们一起闯出新的天地，成就我们共同的天之刃！\n                                        <font color=\"#3be450\">~s</font>掌门<font color=\"#ffff00\">~s</font>"},
                 
         %%后台信件
         {r_letter_template,3001,
          "系统赠送了你 ~p个 [~s]元宝，原因为:~s。请点开背包查收。"},
         {r_letter_template,3002,
          "系统赠送了你 ~s [~s] 银两，原因为:~s。请点开背包查收。"},
         
         %%其他信件
         {r_letter_template,4001,
          "你被【~s】的玩家<font color=\"#fff47c\">[~s]</font>打败了。"},
         {r_letter_template,4002,
          "<font color=\"#00FF00\">~s</font>:\n      你PK值过高，已经红名，为了国民安全，你已被守护者擒获送入监狱。只有当你PK值小于18点，不再红名时，我才会放你出去。望你在狱中洗心革面，早日出狱。\n\n<p align=\"right\">监狱长 </p>"},
         {r_letter_template,4003,
          "<FONT COLOR=\"#ffffff\">你委托的任务<b><font color=\"#ffcc00\">~w</font></b>已完成，获得奖励：<br /><font color=\"#ffcc00\" color=\"#ffcc00\">~w~w</FONT></FONT>"},
         {r_letter_template,4004,
          "<font color=\"#FFFF00\">[~s]</font>\n      由于你恶意杀死本国玩家3次以上，PK值超过了18，已经红名，将受到以下惩罚：不绑定道具、银子的掉落概率增加；装备损坏速度加快；商店购买价格上涨；不能使用NPC传送功能；而且当PK值大于<font color=\"#3BE450\">30</font>点时，死亡后将被送入监狱。\n     PK值下降方式：随身商店购买清心丸、在线挂机。望你净心修炼，不要再恶意杀生了。\n\n<p align=\"right\">监狱长</p>"}, 
         {r_letter_template,4005,
          "亲爱的~s:\n      你的摊位托管<font color=\"#ff0000\">已经到期</font>，你可以打开背包界面，点击摊位按钮进行回收。\n\n<p align=\"right\">店小二</p>"}, 
         {r_letter_template,4006,
          "亲爱的~s:\n      你的摊位托管时间<font color=\"#ff0000\">即将结束</font>，如果您想继续托管，请进行续期操作。\n\n<p align=\"right\">店小二</p>"},
         {r_letter_template,4007,
          "你被~s的玩家<font color=\"#FFFF00\">[~s]</font>杀死，【商票】丢失，本次商贸失败。"},
         {r_letter_template,4008,
          "你遭受了死亡的巨大打击，【商票】丢失，本次商贸失败。"},
         {r_letter_template,4009,
          "吾徒:\n      你的此次训练已经结束了，共修炼了<font color=\"#00ff00\">~w</font>分钟，获得了<font color=\"#00ff00\">~w</font>经验，望你继续潜心修炼，早日达到武学高峰。\n\n<p align=\"right\">张三丰</p>"},
         {r_letter_template,4010,
          "亲爱的[<font color=\"#ffff00\">~s</font>]:\n      恭喜你与[<font color=\"#ffff00\">~s</font>]结为“<font color=\"#ff0000\">~s</font>”，同国好友同屏组队时可同时提升物攻和法攻 <font color=\"#ff0000\">~w</font>。\n      好友度增加方式：双方野外刷怪组队每天最多可增加10点，好友窗口聊天每天最多可增加10点，好友升级祝福等方式。\n\n<p align=\"right\">天之刃</p>"},
         {r_letter_template,4011,
          "尊敬的~s：\n       恭喜你率领门派赢得本次王座争霸战，请你立即前往<a href=\"event:N|~s\"><font  color=\"#3be450\"><u>国家事务官 • 张居正</u></font></a>处提取国王凭证——<font  color=\"#ffff00\">国王玉玺</font>，更好的实行国王权利，同时通知你的官员们去领取其他官职凭证。"},
         {r_letter_template,4012,
          "尊敬的~s:~n  由于您的门派战功卓著，获得本次王座争霸战的资格，请您在今日20:30之前前往王都*王宫侍卫处报名参与。王座争霸战将决定~s的权力归属。~n                                   ~s宫侍卫 ~n                                      ~w月~w日"},
         {r_letter_template,4013,
           "亲爱的[~s]： ~n      您好！恭喜您在本服成功进行第一次充值，您可以在活动面板（游戏右上角处）-> 礼包-> 领取价值 1888 元宝的【首充大礼包】1个。 ~n~n~n" ++
            "<a href='event:openShouchongWin'><u><font color='#FFFF00'>点此进入，领取礼包！</font></u></a>~n~n" ++
            "                                  《天之刃》 运营团队~n"
			++ "                                  ~p年~p月~p日"
			},
		 {r_letter_template,4014,
		  "亲爱的~s\n      恭喜你在钱庄的元宝求购委托(求购数量~w，单价~w两)获得成交，您获得元宝~w。\n\n<p align=\"right\">钱庄-沈万三</p>"},
         {r_letter_template,4015,
          "亲爱的~s:\n      恭喜你在钱庄的元宝出售委托(出售数量~w，单价~w两)获得成交，成交数量~w，扣除手续费后，您获得银子~s。\n\n<p align=\"right\">钱庄-沈万三</p>"},
         {r_letter_template,4016,
          "尊贵的《天之刃》玩家：\n\t\t由于您在活动期间（~s）以迅雷不及掩耳之势完成讨伐敌营，特此奖励您 ~s 一张，请从 <font color=\"#FF0000\">本信件</font> 中提取。\n\t\t感谢您对我们游戏的支持！\n<p align=\"right\">《天之刃》运营团队</p>"},
         {r_letter_template,4017,
          "尊敬的 ~s: ~n    你通过充值获得 ~p 元宝"},
         {r_letter_template,4018,
          "亲爱的玩家：    \n        您好！现赠送您明天的元宵活动道具“调料包”，赶快去采集药草来炼制汤圆吧！祝您元宵节快乐，团团圆圆过元宵！\n                                                       《天之刃》运营团队 \n                                                       2011年2月16日"},
         %% 场景大战副本物品信件
         {r_letter_template,4019,
          "亲爱的玩家：    \n        由于背包空间不足，您在<font color=\"#3be450\">~s</font>副本得到的物品已通过此邮件寄出，请尽快提取。\n\n<p align=\"right\">《天之刃》</p>"},
		  %% 场景大战副本物品信件
         {r_letter_template,4020,
          "亲爱的玩家：    \n        由于背包空间不足，您在<font color=\"#3be450\">~s</font>副本得到的物品已通过此邮件寄出，请尽快提取。\n\n<p align=\"right\">~s</p>"},
		 {r_letter_template,4021,
          "亲爱的[~s]：\n      本次调整后技能学习不再需要经验，并且返回以前学习技能消耗的经验，根据你学习的技能情况，本次获得返回经验为：~w"},
		  {r_letter_template,4022,
          "尊敬的[~s]:~n  由于您的门派战功卓著，获得本次王座争霸战的资格，战斗将于20:30开始，请你的门派做好准备，争夺~s的权力归属。~n                                   ~s宫侍卫 ~n                                      ~w月~w日"},
         {r_letter_template,4023,
          "亲爱的玩家：\n      护镖已超过30分钟，你的镖车已被回收，请到 <a href=\"event:N|~s\"><font color=\"#f53f3c\"><u>王都-镖师</u></font></a>[63,35] 处重新领取镖车"},
         {r_letter_template,4024,
          "亲爱的玩家：\n      护镖已超过30分钟，你的镖车已被回收，请到 王都-镖师 处重新领取镖车"},
         {r_letter_template,4025,
          "亲爱的[~s]：\n      您在战役中有奖励未领取"},
         {r_letter_template,4026,
          "亲爱的[~s]：\n      您在战役中获得~w点额外声望奖励"},
         %% 师徒信件
         {r_letter_template,5001,
          "亲爱的[~s]：\n      恭喜你的爱徒[~s]完成了60级目标，荣誉出师。愿你与爱徒在游戏中共进退，谱写属于你们的天之刃。\n\n请领取恩师奖励：恩师礼包×1。"},
         {r_letter_template,5002,
          "亲爱的[~s]：\n      恭喜你升至60级,成功出师。愿你与恩师在游戏中共进退，谱写属于你们的天之刃。\n\n请领取出师奖励：高徒礼包×1。"},
         {r_letter_template,5003,
          "<font color=\"#ffff00\">~s：</font>\n      你的徒弟[<font color=\"#ffff00\">~s</font>]心意已决，与你解除了师徒关系。\n      收徒的好处：\n       徒弟升级，可获得师德值。\n      1）师德值可以换取经验或用来消除PK值。\n      2）与徒弟组队，有5%的经验加成。\n      3）如果徒弟60级出师，将获得恩师礼包。\n      <a href=\"event:teacher\"><font  color=\"#00ff00\"><u>查看更多徒弟</u></font></a>\n\n<p align=\"right\">李梦阳</p>"},
         {r_letter_template,5004,
          "<font color=\"#ffff00\">~s：</font>\n      你的导师[<font color=\"#ffff00\">~s</font>]心意已决，将你开除师门，你们已经脱离了师徒关系。请前往王都—师徒管理员处，寻访其他名师吧。\n      拜师的好处：师傅在线，自己可以获得组队经验加成。\n       60级出师，还可以获得出师礼包。\n\n<p align=\"right\">李梦阳</p>"},
         {r_letter_template,5005,
          "亲爱的[<font color=\"#ffff00\">~s</font>]:\n      恭喜你与[<font color=\"#ffff00\">~s</font>]结为“<font color=\"#ff0000\">~s</font>”。\n      好友度增加方式：双方野外刷怪组队每天最多可增加10点，好友窗口聊天每天最多可增加10点，好友升级祝福等方式。\n\n<p align=\"right\">天之刃</p>"}
        ]).










