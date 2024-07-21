package modules.needfire {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneData.RunVo;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Needfire;
	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.tile.Pt;
	import com.utils.DateFormatUtil;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.duplicate.views.DuplicateNPCPanel;
	import modules.duplicate.vo.ContentVO;
	import modules.duplicate.vo.TalkContentVO;
	import modules.duplicate.vo.TalkVO;
	import modules.family.FamilyLocator;
	import modules.family.FamilyModule;
	import modules.help.HelpManager;
	import modules.help.IntroduceConstant;
	import modules.market.MarketModule;
	import modules.mypackage.managers.PackManager;
	import modules.scene.SceneDataManager;
	import modules.shop.ShopModule;
	import modules.system.SystemConfig;
	
	import proto.common.p_map_bonfire;
	import proto.line.m_bonfire_add_fagot_toc;
	import proto.line.m_bonfire_add_fagot_tos;
	import proto.line.m_bonfire_get_toc;
	import proto.line.m_bonfire_get_tos;
	import proto.line.m_bonfire_rm_toc;
	import proto.line.m_bonfire_up_toc;
	import proto.line.m_family_set_bonfire_start_time_toc;
	import proto.line.m_family_set_bonfire_start_time_tos;

	public class NeedfieModule extends BaseModule {
		public var fires:Array=[];
		private var npcPanel:DuplicateNPCPanel;
		private var setting:NeedFireSettingPanel;
		private var state:int;
		private var selectFire:p_map_bonfire;
		private var familyFire:p_map_bonfire;
		private var currentTime:int;
		private var key:String = OnlyIDCreater.createID();
		private var open:Boolean = true;
		
		public function NeedfieModule() {
		}

		private static var instance:NeedfieModule;

		public static function getInstance():NeedfieModule {
			if (instance == null) {
				instance=new NeedfieModule();
			}
			return instance;
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.BONFIRE_ADD_FAGOT, bonfireAddFagot);
			addSocketListener(SocketCommand.BONFIRE_UP, bonfireUpdata);
			addSocketListener(SocketCommand.BONFIRE_RM, bonfireCrushOut);
			addSocketListener(SocketCommand.BONFIRE_GET, bonfireGet);
			addSocketListener(SocketCommand.FAMILY_SET_BONFIRE_START_TIME, familySetBonfireStartTime);
		}

		private function familySetBonfireStartTime(vo:m_family_set_bonfire_start_time_toc):void {
			if (vo.succ) {
				FamilyLocator.getInstance().familyInfo.hour=vo.hour;
				FamilyLocator.getInstance().familyInfo.minute=vo.minute;
				FamilyLocator.getInstance().familyInfo.seconds=vo.seconds;
				updataPanel(selectFire);
				Tips.getInstance().addTipsMsg(vo.reason);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function setStartTime(hour:int, minute:int, seconds:int=0):void {
			var vo:m_family_set_bonfire_start_time_tos=new m_family_set_bonfire_start_time_tos();
			vo.hour=hour;
			vo.minute=minute;
			vo.seconds=0;
			sendSocketMessage(vo);
		}

		public function bonfireGet(vo:m_bonfire_get_toc):void {
			if (vo.succ) {
				if (selectFire != null) {
					if (npcPanel) {
						updataPanel(vo.bonfire_info)
					}
				}
			}
		}

		public function getInfo(id:int):void {
			var vo:m_bonfire_get_tos=new m_bonfire_get_tos();
			vo.bonfire_id=id;
			sendSocketMessage(vo);
		}

		public function addFagot(id:int):void {
			var vo:m_bonfire_add_fagot_tos=new m_bonfire_add_fagot_tos();
			vo.bonfire_id=id;
			sendSocketMessage(vo);
		}

		public function bonfireAddFagot(vo:m_bonfire_add_fagot_toc):void {
			if (vo.succ) {
				updataPanel(vo.bonfire);
				BroadcastSelf.logger("成功添加木柴");
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		public function bonfireUpdata(vo:m_bonfire_up_toc):void {
			var l:uint=vo.bnfires.length;
			var p:p_map_bonfire;
			var has:Boolean=false;
			for (var i:int=0; i < l; i++) {
				p=vo.bnfires[i] as p_map_bonfire;
				if(p.id == 10300){
					familyFire = p;
					if(!SceneDataManager.isFamilyMap){
						break;
					}
				}
				has=false;
				for (var j:int=0; j < fires.length; j++) {
					if (fires[j].vo.id == p.id) {
						fires[j].vo=p;
						fires[j].play();
						has=true;
					}
					if (selectFire && p.id == selectFire.id) {
						openNPCPanel(p);
					}
				}
				if (!has) {
					var needfire:Needfire=new Needfire();
					needfire.vo=p;
					fires.push(needfire);
					GameScene.getInstance().addUnit(needfire, p.pos.tx, p.pos.ty);
					needfire.play();
				}
			}
		}

		public function bonfireCrushOut(vo:m_bonfire_rm_toc):void {
			var l:uint=fires.length;
			for (var i:int=0; i < l; i++) {
				if (fires[i].vo.id == vo.id) {
					fires[i].vo.state=2;
					fires[i].play();
					return;
				}
			}
		}

		public function openNPCPanel(vo:p_map_bonfire, p:Point=null):void {
			if (npcPanel == null) {
				npcPanel=new DuplicateNPCPanel();
				npcPanel.addEventListener(DuplicateNPCPanel.SHOW_CONTENT, onShowContent);
				npcPanel.addEventListener(DuplicateNPCPanel.OTHER, onOhter);
				npcPanel.addEventListener(DuplicateNPCPanel.FINISH, onFinish);
			}
			if (!WindowManager.getInstance().isPopUp(npcPanel)) {
				WindowManager.getInstance().openDistanceWindow(npcPanel);
				var myPoint:Point=SceneDataManager.getMyStagePoint();
				if (myPoint) {
					npcPanel.x=myPoint.x - npcPanel.width - 70;
					npcPanel.y=myPoint.y - npcPanel.height / 2;
					if (npcPanel.x < 0) {
						npcPanel.x=myPoint.x + npcPanel.width + 70;
					}
					if (npcPanel.y < 0) {
						npcPanel.y=myPoint.y;
					}
				} else {
					WindowManager.getInstance().centerWindow(npcPanel);
					npcPanel.x-=100 + npcPanel.width / 2;
				}
			}
			getInfo(vo.id);
			updataPanel(vo);
		}
		
		public function checkDrink():void{
			if(familyFire && familyFire.state == 1){
				if(!this.checkRange()){
					//Prompt.show("饮酒后在篝火边打坐获得经验 ","消息提示",FamilyModule.getInstance().enterFamilyMap,null,"确定","取消",[3]);
					Alert.show("饮酒后在篝火边打坐获得经验 <u><font color='#00FF00'><a href='event:'>关于篝火</a></font></u>", "", jumpBonfire, null, "立即前往", "关闭", null, true, false, null, openHelp,false);
				}else{
					if(!GlobalObjectManager.getInstance().isZazen){
						Dispatch.dispatch(ModuleCommand.SIT_DOWN);
					}
				}
			}else{
				//当在副本中时简单的提示一下，不在副本时就寻路到时间篝火处
				if(!SceneDataManager.isSubMap()){
					if(!checkRange()){
						Alert.show("饮酒后在篝火边打坐获得经验 <u><font color='#00FF00'><a href='event:'>关于篝火</a></font></u>", "", findBonfire, null, "立即前往", "关闭", null, true, false, null, openHelp,false);
					}else{
						if(!GlobalObjectManager.getInstance().isZazen){
							Dispatch.dispatch(ModuleCommand.SIT_DOWN);
						}
					}
				}
			}
		}
		
		private function checkRange():Boolean{
			var x:int = GlobalObjectManager.getInstance().getX();
			var y:int = GlobalObjectManager.getInstance().getY();
			var XV:int = 0;
			var YV:int = 0;
			switch(SceneDataManager.mapID){
				case 10300:
					 XV = Math.abs(46-x);
					 YV = Math.abs(55-y);
					 return XV*XV+YV*YV < 100;
				case 11100:
				case 12100:
				case 13100:
					XV = Math.abs(118-x);
					YV = Math.abs(35-y);
					return XV*XV+YV*YV < 100;
				default:
					return false;
			}
		}

		public function updataPanel(vo:p_map_bonfire):void {
			if (!vo) return;
			selectFire=vo;
			var talkVO:TalkVO=new TalkVO();
			if (vo.state == 1) {
				talkVO.name="燃烧的篝火";
			} else {
				talkVO.name="熄灭的篝火";
			}
			talkVO.talks=new Vector.<TalkContentVO>();

			var talkContent:TalkContentVO=new TalkContentVO();
			talkContent.contents=new Vector.<ContentVO>();
			talkContent.type=DuplicateNPCPanel.FINISH;
			
			var marketLink:ContentVO=new ContentVO();
			marketLink.type=DuplicateNPCPanel.LINK;
			marketLink.text="市场";
			marketLink.linkType=DuplicateNPCPanel.OTHER;
			marketLink.data={name: "openMarket", vo: vo};
			
			var bonfireHelpLink:ContentVO=new ContentVO();
			bonfireHelpLink.type=DuplicateNPCPanel.LINK;
			bonfireHelpLink.text="关于篝火";
			bonfireHelpLink.linkType=DuplicateNPCPanel.OTHER;
			bonfireHelpLink.data={name: "openHelp", vo: vo};
			
			var buyErGuoTouLink:ContentVO=new ContentVO();
			buyErGuoTouLink.type=DuplicateNPCPanel.LINK;
			buyErGuoTouLink.text="商城购买: 二锅头";
			buyErGuoTouLink.linkType=DuplicateNPCPanel.OTHER;
			buyErGuoTouLink.data={name: "buyErguotou", vo: vo};
			
			var buyNvErHongLink:ContentVO=new ContentVO();
			buyNvErHongLink.type=DuplicateNPCPanel.LINK;
			buyNvErHongLink.text="商城购买: 女儿红";
			buyNvErHongLink.linkType=DuplicateNPCPanel.OTHER;
			buyNvErHongLink.data={name: "buyNverhong", vo: vo};

			var setTimeLink:ContentVO=new ContentVO();
			setTimeLink.type=DuplicateNPCPanel.LINK;
			setTimeLink.text="设置点燃时间";
			setTimeLink.linkType=DuplicateNPCPanel.OTHER;
			setTimeLink.data={name: "setTime", vo: vo};

			var firewoodLink:ContentVO=new ContentVO();
			firewoodLink.type=DuplicateNPCPanel.LINK;
			firewoodLink.text="添加木柴（" + PackManager.getInstance().getGoodsNumByTypeId(11600016) + "）";
			firewoodLink.linkType=DuplicateNPCPanel.OTHER;
			firewoodLink.data={name: "firewood", vo: vo};
			var titleContent:ContentVO=new ContentVO();
			titleContent.type=DuplicateNPCPanel.CONTENT;			
			if(open){
				if (SceneDataManager.isFamilyMap) {
					if (vo.state == 1) {
						currentTime=vo.end_time - SystemConfig.serverTime;
						LoopManager.addToSecond(key,upDataTime);
						titleContent.text="喝酒状态下，在燃烧的篝火附近打坐可以获得大量经验。\n门派篝火每天自动点燃，"+
							"持续燃烧1小时，掌门可以修改点燃时间。\n\n<font color='#00FF00'>"+getAddRate()+"</font>\n<font color='#FFFF00'>"+
							"<font color='#00FF00'>"+getMemberAndFirewood()+"</font>\n<font color='#FFFF00'>"+
							"剩余时间："+DateFormatUtil.formatTime(currentTime)+"</font>"
						talkContent.contents.push(titleContent);
						talkVO.talks.push(talkContent);
						if (FamilyLocator.getInstance().isFamilyOwner(GlobalObjectManager.getInstance().user.attr.role_id)) {
							talkContent.contents.push(setTimeLink);
						}
						talkContent.contents.push(firewoodLink);
					} else {
						titleContent.text="喝酒状态下，在燃烧的篝火附近打坐可以获得大量经验。\n门派篝火每天自动点燃，"+
							"持续燃烧1小时，掌门可以修改点燃时间。\n\n<font color='#FFFF00'>"+getBurnTime()+"</font>"
						talkContent.contents.push(titleContent);
						talkVO.talks.push(talkContent);
						if (FamilyLocator.getInstance().isFamilyOwner(GlobalObjectManager.getInstance().user.attr.role_id)) {
							talkContent.contents.push(setTimeLink);
						}
					}
				} else {
					titleContent.text="在燃烧的篝火附近饮酒打坐，可获得大量经验。\n组队打坐可以获得更多经验，队伍人数越多，经验越多。"
					talkContent.contents.push(titleContent);
					talkVO.talks.push(talkContent);
				}	
			}else{
				titleContent.text="篝火功能即将开放"
				talkContent.contents.push(titleContent);
				talkVO.talks.push(talkContent);
			}
			if(GlobalObjectManager.getInstance().getLevel() >= 80){
				talkContent.contents.push(buyNvErHongLink);
			}
			if(GlobalObjectManager.getInstance().getLevel() >= 20 && 
			   GlobalObjectManager.getInstance().getLevel() < 80){
				talkContent.contents.push(buyErGuoTouLink);
			}
			talkContent.contents.push(marketLink);
			talkContent.contents.push(bonfireHelpLink);
			npcPanel.talkVO=talkVO;
		}
		
		private function getAddRate():String{
			return "当前经验加成："+ selectFire.rate+"%";
		}
		
		private function getMemberAndFirewood():String{
			return "当前人数："+selectFire.members+"  木柴："+selectFire.fagot;
		}
		
		private function getBurnTime():String{				
			var oldTime:int = FamilyLocator.getInstance().familyInfo.seconds; 
			var h:int = FamilyLocator.getInstance().familyInfo.hour;
			var m:int = FamilyLocator.getInstance().familyInfo.minute;
			if(Math.abs(oldTime - SystemConfig.serverTime) > 86400){
				return "篝火点燃时间："+formatTime(h,m);
			}else{
				var oldh:int = int(oldTime%86400/3600)+8;
				var oldm:int = int(oldTime%86400%3600/60);
				return "篝火今天点燃时间："+formatTime(oldh,oldm)+"\n篝火明天点燃时间："+formatTime(h,m);
			}
		}
		
		private function formatTime(h:int, m:int):String{
			var time:String = "";
			if (h < 10) {
				time=time + '0' + h;
			} else {
				time+=h;
			}
			if (m < 10) {
				time=time + '：0' + m;
			} else {
				time=time + '：' + m;
			}
			return time;
		} 
		
		private function upDataTime():void {
			updataPanel(selectFire);
		}

		private function onShowContent(event:Event):void {

		}

		private function onOhter(event:ParamEvent):void {
			switch(event.data.name){
				case "setTime":
						if (setting == null) {
							setting=new NeedFireSettingPanel();
							setting.initUI();
							setting.callback=setStartTime;
						}
						setting.reset(event.data.vo);
						WindowManager.getInstance().popUpWindow(setting);
						WindowManager.getInstance().centerWindow(setting);
						break;
				case "firewood":
						addFagot(event.data.vo.id);
						break;
				case "openHelp":
						HelpManager.getInstance().openIntroduce(IntroduceConstant.GOUHUO);
						break;
				case "openMarket":
						MarketModule.getInstance().openMarketView(301,[10800024,10800026,10800028,10800030,10800025,10800027,10800029,10800031]);
						break;
				case "buyErguotou":
						if(npcPanel){
							ShopModule.getInstance().requestShopItem(10105, 10800024, new Point(npcPanel .stage.mouseX-178, npcPanel.stage.mouseY-90));
						}
						break;
				case "buyNverhong":
						if(npcPanel){
							ShopModule.getInstance().requestShopItem(10105, 10800025, new Point(npcPanel.stage.mouseX-178, npcPanel.stage.mouseY-90));
						}
						break;
			}
		}

		private function onFinish(event:ParamEvent):void {
			if (event.data != null) {
				selectFire=null;
				LoopManager.removeFromSceond(key);
				if(setting){
					WindowManager.getInstance().removeWindow(setting);
				}
			}
		}
		
		
		private function openHelp(e:*):void{
			HelpManager.getInstance().openIntroduce(IntroduceConstant.GOUHUO);
		}
		
		private function jumpBonfire():void{
			FamilyModule.getInstance().enterFamilyMap(3);
			//sitDown();
		}
		
		private function findBonfire():void{
			var pt:Pt = new Pt();
			pt.x = 118;
			pt.z = 35;
			var runvo:RunVo = new RunVo();
			runvo.pt = pt;
			runvo.action = new HandlerAction(sitDown);
			runvo.cut = 3;
			switch(GlobalObjectManager.getInstance().getRoleFactionID()){
				case 1:
					runvo.mapid = 11100;
					break;
				case 2:
					runvo.mapid = 12100;
					break;
				case 3:
					runvo.mapid = 13100;
					break;
			}				
			Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, runvo);
		}
		
		private function sitDown():void{
			var myRole:MyRole=UnitPool.getMyRole();
			if(myRole.curState==RoleActState.NORMAL){
				Dispatch.dispatch(ModuleCommand.SIT_DOWN);
				Alert.show("饮酒后在篝火边打坐获得经验", "", null, null, "知道了", "", null, false, false, null, null,false);
			}
		}
	}
}