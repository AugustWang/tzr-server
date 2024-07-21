package modules.navigation.views {
	import com.common.FlashObjectManager;
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.effect.FlickerEffect;
	import com.common.effect.GlowTween;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUtils.RoleActState;
	import com.utils.ComponentUtil;
	import com.utils.GraphicsUtil;
	import com.utils.HtmlUtil;
	import com.utils.KeyUtil;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.bigExpresion.BigExpresionModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.friend.FriendsModule;
	import modules.friend.views.messageBox.MessageBox;
	import modules.help.HelpManager;
	import modules.market.MarketModule;
	import modules.mount.mountModule;
	import modules.mypackage.PackageModule;
	import modules.mypackage.views.GoodsToolTip;
	import modules.nearPlayer.NearPlayerModule;
	import modules.npc.NPCActionType;
	import modules.playerGuide.PlayerGuideModule;
	import modules.roleStateG.RoleStateModule;
	import modules.stat.StatConstant;
	import modules.stat.StatModule;
	import modules.system.SystemConfig;
	import modules.vip.VipModule;
	
	import proto.common.p_goods;


	/**
	 * 工具栏目，包括（物品栏和功能快捷方式栏目）
	 */
	public class NavBar extends Sprite {
		private var navDatas:Array;
		private var dic:Dictionary;
		public var downgoodsBox:HotKeyBox;
		public var upgoodsBox:HotKeyBox;
		private var _expBar:Bitmap; //经验条
		private var _expTxt:TextField;
		private var _expBarBg:Sprite;
		private var innerBg:Sprite;
		public var _friendsIcon:Sprite;
		private var _gt:GlowTween;
		public var jinengBtn:Sprite
		public var shopBtn:UIComponent;
		public var pet:Sprite;

		private var role:Sprite;
		private var society:Sprite;
		private var musicOn:Sprite;
		private var musicOff:Sprite;
		private var downUp:UIComponent;
		private var sprite4:Sprite;
		public var bag:Sprite; //背包
		private var refining:Sprite; //天式炉
		private var teamBtn:Sprite; //组队
		private var market:Sprite; //
		private var usePurple:Boolean; //用紫色
		private var _lixianSprite:Sprite;
		private var levelUpBtn:UIComponent;
		
		public function NavBar() {
			super();
			navDatas=[{ label: "toolbar_role", id: 0, tooltip: "人物(C)" }, 
				{ label: "toolbar_skill", id: 2, tooltip: "技能(V)" },
				{ label: "toolbar_pack", id: 3, tooltip: "背包(B)" }, 
				{ label: "toolbar_pet", id: 9, tooltip: "宠物(X)" }, 
				{ label: "toolbar_friends", id: 6, tooltip: "好友(R)" }, 
				{ label: "toolbar_society", id: 8, tooltip: "社交(O)" }, 
				{ label: "toolbar_tgl",	id: 4, tooltip: "锻造(E)\n材料加工、装备精炼" }, 
				{ label: "toolbar_task", id: 1, tooltip: "任务(Q)" }, 
				{ label: "toolbar_team",	id: 10, tooltip: "组队(H)" }, 
				{ label: "toolbar_flight", id: 12, tooltip: "战役(D)" }];

			initView();
		}

		private function initView():void {
			this.mouseEnabled=false;
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"toolbarBg");
			addChild(bg);
			downgoodsBox=new HotKeyBox();
			downgoodsBox.x=64;
			downgoodsBox.y=7;
			addChild(downgoodsBox);

			upgoodsBox=new HotKeyBox();
			upgoodsBox.showNumber(false);
			upgoodsBox.setBg(Style.getBitmap(GameConfig.T1_VIEWUI,"skillItemsBg"));
			upgoodsBox.x=340;//int((width - upgoodsBox.width) * 0.5);
			upgoodsBox.y=-52;
			var userId:int=GlobalObjectManager.getInstance().user.attr.role_id;
			var visible:Boolean=GlobalObjectManager.getInstance().getObject(userId + "upBarState", true) == 1;
			upgoodsBox.visible=visible;
			addChild(upgoodsBox);

			innerBg=new Sprite();
			innerBg.x=62;
			innerBg.y=48;
			GraphicsUtil.drawRect(innerBg.graphics,0,0,831,6,0);
			innerBg.addEventListener(MouseEvent.MOUSE_OVER, showExp);
			innerBg.addEventListener(MouseEvent.MOUSE_OUT, hideExp);
			innerBg.addEventListener(MouseEvent.CLICK, openRoleDetail);
			addChild(innerBg);

			_expBar=new Bitmap();
			_expBar.bitmapData=Style.getUIBitmapData(GameConfig.T1_VIEWUI, "playerExp");
			_expBar.x=62;
			_expBar.y=48;
			addChild(_expBar);

			var outBg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"playerOutBg");
			outBg.x=62;
			outBg.y=48;
			addChild(outBg);
			
			dic=new Dictionary();

			role=createItem(430, navDatas[0]);
			GraphicsUtil.drawRect(role.graphics,0,0,role.width,role.height,0);
			
			bag = createItem(478, navDatas[2]);
			GraphicsUtil.drawRect(bag.graphics,0,0,bag.width,bag.height,0);
			
			jinengBtn=createItem(526, navDatas[1]);
			GraphicsUtil.drawRect(jinengBtn.graphics,0,0,jinengBtn.width,jinengBtn.height,0);
			
			pet=createItem(571, navDatas[3]);
			createItem(616, navDatas[7]);
			teamBtn=createItem(661, navDatas[8]);
			GraphicsUtil.drawRect(teamBtn.graphics,0,0,role.width,role.height,0);
			
			_friendsIcon=createItem(706, navDatas[4]);
			GraphicsUtil.drawRect(_friendsIcon.graphics,0,0,_friendsIcon.width,_friendsIcon.height,0);
			
			society=createItem(760, navDatas[5]);
			GraphicsUtil.drawRect(society.graphics,0,0,society.width,society.height,0);
			
			refining=createItem(810, navDatas[6]);

			createItem(855, navDatas[9]);
			
			var shopBg:Bitmap = Style.getBitmap(GameConfig.T1_UI,"shopBg");
			shopBg.x=905;
			shopBg.y = -38;
			addChild(shopBg);
			
			shopBtn=new UIComponent();
			shopBtn.useHandCursor=shopBtn.buttonMode=true;
			shopBtn.x=942;//840;
			shopBtn.y = -4;
			shopBtn.bgSkin=Style.getButtonSkin("shop_1skin", "shop_2skin", "shop_3skin", null, GameConfig.T1_UI); //GameConfig.T1_UI
			addChild(shopBtn);
			shopBtn.addEventListener(MouseEvent.CLICK, clickShop);
			shopBtn.addEventListener(MouseEvent.ROLL_OVER, shopRollOver);
			shopBtn.addEventListener(MouseEvent.ROLL_OUT, shopRollOut);

			//系统按钮
			var systemSprite:UIComponent=createBtn("setting", 974, -32, "system");//892
			addChild(systemSprite);
			
			//大表情
			var faceSprite:UIComponent=createBtn("bigFace", 917, -21, "bigFace");//892
			addChild(faceSprite);
			
			//NPC
			var tf:TextFormat = Style.textFormat;
			tf.color = 0xffff00;
			tf.bold = true;
			var vipText:TextField=ComponentUtil.createTextField("",909,16,tf,35,25,this);
			vipText.mouseEnabled = true;
			vipText.htmlText = HtmlUtil.link("VIP","vip");
			vipText.filters = [new GlowFilter(0x000000,1,2,2,3)];
			vipText.addEventListener(TextEvent.LINK,npcLinkHandler);
			addChild(vipText);
			
			//兑
			var prestigeText:TextField=ComponentUtil.createTextField("",946,-34,tf,35,25,this);
			prestigeText.mouseEnabled = true;
			prestigeText.htmlText = HtmlUtil.link("兑","prestige");
			prestigeText.filters = [new GlowFilter(0x000000,1,2,2,3)];
			prestigeText.addEventListener(TextEvent.LINK,prestigeLinkHandler);
			addChild(prestigeText);
						
			downUp=new UIComponent();
			downUp.useHandCursor=downUp.buttonMode=true;
			downUp.x=414;
			downUp.y=15;
			downUp.bgSkin=Style.getButtonSkin("hotDownUp_1skin", "hotDownUp_2skin", "hotDownUp_3skin", null, GameConfig.T1_UI);
			downUp.addEventListener(MouseEvent.CLICK, onUpClick);
			downUp.setToolTip("扩展快捷栏");
			addChild(downUp);
			
			levelUpBtn = new UIComponent();
			levelUpBtn.buttonMode = levelUpBtn.useHandCursor = true;
			levelUpBtn.x = 897;
			levelUpBtn.y = 45;
			levelUpBtn.setToolTip("点击升级");
			levelUpBtn.bgSkin = Style.getButtonSkin("levelUp_1skin","levelUp_2skin","levelUp_3skin","",GameConfig.T1_UI);
			levelUpBtn.addEventListener(MouseEvent.CLICK,clickLevelHandler);
			addChild(levelUpBtn);

			KeyUtil.getInstance().addKeyHandler(onOpenRole, [InputKey.C]);
			//市场
			KeyUtil.getInstance().addKeyHandler(openMarket,[InputKey.N]);
			KeyUtil.getInstance().addKeyHandler(onOpenMission, [InputKey.Q]);
			KeyUtil.getInstance().addKeyHandler(onOpenSkill, [InputKey.V]);
			KeyUtil.getInstance().addKeyHandler(onOpenPack, [InputKey.B]);
			KeyUtil.getInstance().addKeyHandler(onOpenTGL, [InputKey.E]);
			KeyUtil.getInstance().addKeyHandler(onOpenShop, [InputKey.S]);
			KeyUtil.getInstance().addKeyHandler(onOpenSNS, [InputKey.R]);
			KeyUtil.getInstance().addKeyHandler(onOpenCommunity, [InputKey.O]);
			KeyUtil.getInstance().addKeyHandler(onOpenSystem, [InputKey.ESCAPE]);
			KeyUtil.getInstance().addKeyHandler(onOpenBTWindow, [InputKey.K]);
			KeyUtil.getInstance().addKeyHandler(onOpenNearWindow, [InputKey.F]);
			KeyUtil.getInstance().addKeyHandler(onMountChange, [InputKey.T]);
			KeyUtil.getInstance().addKeyHandler(onOpenPet, [InputKey.X]);
			KeyUtil.getInstance().addKeyHandler(onAchievement, [InputKey.H]); //成就快捷键
			KeyUtil.getInstance().addKeyHandler(fullScreen, [InputKey.F8]);
			KeyUtil.getInstance().addKeyHandler(openAchievementPanel, [InputKey.Z]);
			
			ToolTipManager.registerToolTip("goodsToolTip", GoodsToolTip);
			LoopManager.addToSecond(this, loopSHandler);
		}
		
		private function npcLinkHandler(event:TextEvent):void{
			VipModule.getInstance().onOpenVipPannel();	
		}
		
		private function prestigeLinkHandler(event:TextEvent):void{
			Dispatch.dispatch(ModuleCommand.OPEN_PRESTIGE_PANEL);
		}
		
		private function clickLevelHandler(event:MouseEvent):void{
			if(usePurple){
				if (GlobalObjectManager.getInstance().user.base.status == RoleActState.TRAINING) {
					BroadcastSelf.logger(HtmlUtil.font("在训练营闭关修炼中，无法升级", "#ff0000"));
				} else {
					RoleStateModule.getInstance().mediator.myDetailCase.toRequestLevelUp(null);
				}
			}
		}
		
		private function openMarket():void
		{
			//测试市场用的
			MarketModule.getInstance().openMarketView();
		}
		
		private function fullScreen():void {
			if ( PlayerGuideModule.getInstance().isMasking ) {
				//如果真正遮罩期间，则不能进行全屏切换
				return;
			}
			
			//flash.system.fscommand("fullscreen", "true");
			var screenState:int = GlobalObjectManager.getInstance().screenState;
			if (screenState == 0) {
				ExternalInterface.call("intoFullScreen");
				GlobalObjectManager.getInstance().screenState = 2;
			} else if (screenState == 1) {
				ExternalInterface.call("intoFullScreen");
				GlobalObjectManager.getInstance().screenState = 2;
			} else if (screenState == 2) {
				ExternalInterface.call("exitFullScreen");
				GlobalObjectManager.getInstance().screenState = 0;
			}
		}
		
		private function openAchievementPanel():void{
			Dispatch.dispatch(ModuleCommand.OPEN_ACHIEVEMENT_PANEL);	
		}
		
		private var _lastDateFlash:int;
		private function loopSHandler():void
		{
			var now:Date = new Date;
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			if (now.getHours() == 0 && now.getDate() != _lastDateFlash && roleLevel > 15) {
				FlashObjectManager.setFlash(_lixianSprite);
				_lastDateFlash = now.getDate();
			}
		}

		private function openRoleDetail(evt:MouseEvent):void {
			if (_expBar.scaleX < 1)
				return;
			Dispatch.dispatch(ModuleCommand.ROLE_OPEN_MY_DETAIL, 1);
		}

		private function onOpenRole():void {
			sendCommand(0);
		}

		private function onOpenMission():void {
			sendCommand(1);
		}

		private function onOpenSkill():void {
			sendCommand(2);
		}

		private function onOpenPack():void {
			sendCommand(3);
		}

		private function onOpenTGL():void {
			sendCommand(4);
		}

		private function onOpenShop():void {
			sendCommand(5);
		}

		private function onOpenSNS():void {
			sendCommand(6);
		}

		private function onOpenCommunity():void {
			sendCommand(8);
		}

		private function onOpenPet():void {
			sendCommand(9);
		}

		private function onAchievement():void {
			sendCommand(10);
		}

		private function onOpenSystem():void {
			CursorManager.getInstance().hideCursor(CursorName.HAMMER);
			if (WindowManager.getInstance().hasWindow()) {
				WindowManager.getInstance().removeTopWindow();
			} else {
				sendCommand(7);
			}
		}

		private function onOpenBTWindow():void {
			PackageModule.getInstance().openBTWindow();
		}

		private function onOpenNearWindow():void {
			NearPlayerModule.getInstance().showView();
		}

		private function onMountChange():void {
			//查找坐骑的信息 正在骑着的
			var length:int=GlobalObjectManager.getInstance().user.attr.equips.length;
			for (var i:int=0; i < length; i++) {
				if (GlobalObjectManager.getInstance().user.attr.equips[i].loadposition == 15) {
					//当前正在使用的坐骑
					var currentMount:p_goods=GlobalObjectManager.getInstance().user.attr.equips[i];
					//坐骑过期
					if(SystemConfig.serverTime >= currentMount.end_time && currentMount.end_time != 0)
					{
						//如果他正在骑马中，先让它下马
						if( GlobalObjectManager.getInstance().isMount ){
							var mountID:int = GlobalObjectManager.getInstance().getMountID();
							PackageModule.getInstance().mountDown( mountID );
						}
						
						mountModule.getInstance().openTipView(currentMount);
						return;
					}
				}
			}
			PackageModule.getInstance().mountFromHotKey();
		}

		private var skillFlick:FlickerEffect;

		public function flickSkill():void {
			if (skillFlick == null) {
				skillFlick=new FlickerEffect;
			}
			if (skillFlick.running() == false) {
				skillFlick.start(jinengBtn.getChildAt(0));
			}
		}

		public function stopFlickSkill():void {
			if (skillFlick) {
				skillFlick.stop();
				jinengBtn.getChildAt(0).visible=true;
			}
		}

		private var roleFlick:FlickerEffect;

		public function flickRole():void {
			if (roleFlick == null) {
				roleFlick=new FlickerEffect;
			}
			if (roleFlick.running() == false) {
				roleFlick.start(role.getChildAt(0), 16);
			}
		}

		public function stopFlickRole():void {
			if (roleFlick) {
				roleFlick.stop();
				role.getChildAt(0).visible=true;
			}
		}
		
		private var bagFlick:FlickerEffect;
		
		public function flickBag():void {
			if (bagFlick == null) {
				bagFlick=new FlickerEffect;
			}
			if (bagFlick.running() == false) {
				bagFlick.start(bag.getChildAt(0), 16);
			}
		}
		
		public function stopBag():void {
			if (bagFlick) {
				bagFlick.stop();
				bag.getChildAt(0).visible=true;
			}
		}

		private function onUpClick(event:MouseEvent):void {
			upgoodsBox.visible=!upgoodsBox.visible;
			saveUpBarState();
		}

		private function saveUpBarState():void {
			var state:int=upgoodsBox.visible ? 1 : 0;
			var userId:int=GlobalObjectManager.getInstance().user.attr.role_id;
			GlobalObjectManager.getInstance().addObject(userId + "upBarState", state, true);
		}

		private function showExp(evt:MouseEvent):void {
			var lvl:int=GlobalObjectManager.getInstance().user.attr.level;
			var currentRoleExp:Number=GlobalObjectManager.getInstance().user.attr.exp
			var ExpNextLevel:Number=GlobalObjectManager.getInstance().user.attr.next_level_exp;
			if (lvl == 154) {
				ToolTipManager.getInstance().show("已经满级");
			} else {
				ToolTipManager.getInstance().show("经验：" + currentRoleExp + "/" + ExpNextLevel);
			}
		}

		private function hideExp(evt:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function get blackShape():Object {
			var blackShape:Shape=new Shape();
			blackShape.graphics.beginFill(0x0, 0.3);
			blackShape.graphics.drawRect(0, 0, 50, 8);
			blackShape.graphics.endFill();
			return blackShape;
		}

		private var flickEffect:FlickerEffect;

		public function flickFriend():void {
			if (flickEffect == null) {
				flickEffect=new FlickerEffect();
			}
			if (flickEffect.running() == false) {
				flickEffect.start(_friendsIcon.getChildAt(0));
			}
		}

		public function stopFlick():void {
			if (flickEffect) {
				flickEffect.stop();
				_friendsIcon.getChildAt(0).visible=true;
			}
		}

		private var societyflick:FlickerEffect;

		public function flickSociety():void {
			if (societyflick == null) {
				societyflick=new FlickerEffect();
			}
			if (societyflick.running() == false) {
//				societyflick.start(pet.getChildAt(0));
				societyflick.start(society.getChildAt(0));
			}
//			societySp.

		}

		public function stopSocietyFlick():void {
			if (societyflick) {
				societyflick.stop();
				society.getChildAt(0).visible=true; //society ;pet.getChildAt(0)
			}


		}

		/**
		 *设置经验
		 * @param value
		 *
		 */
		public function setExpProgress(value:Number):void {
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			var nextLevelExp:Number=GlobalObjectManager.getInstance().user.attr.next_level_exp;
			if (level < 120 && value >= nextLevelExp) {
				innerBg.buttonMode=true;
				if (usePurple == false) {
					_expBar.bitmapData=Style.getUIBitmapData(GameConfig.T1_VIEWUI, "zsplayerExp");
					usePurple=true;
				}
			} else {
				innerBg.buttonMode=false;
				if (usePurple == true) {
					_expBar.bitmapData=Style.getUIBitmapData(GameConfig.T1_VIEWUI, "playerExp");
					usePurple=false;
				}
			}
			var percent:Number=value / nextLevelExp;
			if (percent > 1)
				percent=1;
			if (percent < 0)
				percent=0;
			_expBar.scaleX=percent;
		}

		public function createItem(xValue:int,data:Object):Sprite {
			var btn:Sprite=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,data.label);
			btn.useHandCursor=btn.buttonMode=true;
			btn.name=data.label;
			btn.y=49-btn.height;
			btn.x=xValue;
			dic[btn]=data;
			btn.addEventListener(MouseEvent.CLICK, clickHandler);
			btn.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			btn.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addChild(btn);
			return btn;
		}
		
		public var navItemY:Number=0;
		private function onRollOver(event:MouseEvent):void {
			var data:Object=dic[event.currentTarget].tooltip;
			if (event.currentTarget == _friendsIcon) {
				if (flickEffect && flickEffect.running()) {
					MessageBox.getInstance().show();
					return;
				}
			}
			ToolTipManager.getInstance().show(data, 0); 
			var navItem:Sprite = event.currentTarget as Sprite;
			navItemY = navItem.y;
			navItem.y = navItemY-3;
			navItem.filters = [new GlowFilter(0xffffff,0.5,3,3,3,1,true)];
		}
		
		private function onRollOut(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
			if (event.currentTarget == _friendsIcon) {
				MessageBox.getInstance().hide();
			}
			var navItem:Sprite = event.currentTarget as Sprite;
			navItem.y = navItemY;
			navItem.filters = null;
		}

		private function clickHandler(event:MouseEvent):void {
			var data:int=dic[event.currentTarget].id;
			sendCommand(data, "2");
//			TaskModule.getInstance().colseFlash(event.currentTarget as DisplayObject)
//			if(GoodView.tipsView){
//				if(GoodView.tipsView.parent)GoodView.tipsView.parent.removeChild(GoodView.tipsView);
//			}
		}

		private function clickShop(e:MouseEvent):void {
			var dic_id:int=5;
			sendCommand(dic_id, "2");
//			if(GoodView.tipsView){
//				if(GoodView.tipsView.parent)GoodView.tipsView.parent.removeChild(GoodView.tipsView);
//			}
		}

		private function shopRollOver(event:MouseEvent):void {
			var data:Object="商城(S)";
			//{label: "toolbar_shop", id: 5, tooltip: "商店(S)"};
			//dic[event.currentTarget].tooltip;

			ToolTipManager.getInstance().show(data, 0);
//			event.currentTarget.filters=[new GlowFilter(0xffffff, 1, 3, 3, 6)];
		}

		private function shopRollOut(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function sendCommand(commandId:int, fromType:String="1"):void {
			var value:int;
			switch (commandId) {
				case 0:
					if (roleFlick && roleFlick.running()) {
						RoleStateModule.getInstance().showExtDetail();
						roleFlick.stop();
						role.getChildAt(0).visible=true;
					} else {
						Dispatch.dispatch(ModuleCommand.OPEN_OR_CLOSE_MY_DETAIL);
						value=StatConstant.VALUE_ROLE;
					}
					break;
				case 1:
					Dispatch.dispatch(ModuleCommand.OPEN_MISSION_PANNEL);
					value=StatConstant.VALUE_MISSION;
					break;
				case 2:
					Dispatch.dispatch(ModuleCommand.ONEP_SKILL_TREE);
					value=StatConstant.VALUE_SKILL;
					break;
				case 3:
					Dispatch.dispatch(ModuleCommand.OPEN_PACK_PANEL);
					value=StatConstant.VALUE_PACK;
					break
				case 4:
					Dispatch.dispatch(ModuleCommand.OPEN_STOVE_WINDOW);
					value=StatConstant.VALUE_TGL;
					break;
				case 5:
					Dispatch.dispatch(ModuleCommand.OPEN_SHOP_PANEL);
					value=StatConstant.VALUE_SHOP;
					break;
				case 6:
					Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_LIST);
					value=StatConstant.VALUE_FRIEND;
					break;
				case 7:
					Dispatch.dispatch(ModuleCommand.OPEN_SYSTEM_WINDOW);
					value=StatConstant.VALUE_SETTING;
					break;
				case 8:
					if (societyflick && societyflick.running()) {
						FriendsModule.getInstance().openFamliyRequestPanel();
						stopSocietyFlick();
					} else {
						FriendsModule.getInstance().openFamilyPanel();
					}
					value=StatConstant.VALUE_SH;
					break;
				case 9:
					//宠物.
					Dispatch.dispatch(ModuleCommand.OPEN_OR_CLOSE_PET_MAIN);
					break;
				case 10:
					Dispatch.dispatch(ModuleCommand.OPEN_TEAM_PANEL);
					break;
				case 11:
					Tips.getInstance().addTipsMsg("此功能暂未开放，敬请期待！");
					break;
				case 12:
					Dispatch.dispatch(NPCActionType.NA_87);
					break;
				case 13:
					Dispatch.dispatch(ModuleCommand.AUTO_HIT_MONSTER);
					break;
				case 14:
					onMountChange();
					break;
				case 15:
					openMarket();
					break;
			}
			if (fromType == "2") {
				StatModule.getInstance().addButtonHandler(value);
			} else {
				StatModule.getInstance().addKeyHandler(value);
			}
		}

		///////////////////////////////////　经验条闪的，可能会用

		private function createBtn(skinName:String, x:Number=0, y:Number=0, listenName:String=""):UIComponent {
			var btn:UIComponent = new UIComponent();
			btn.bgSkin = Style.getSkin(skinName,GameConfig.T1_VIEWUI);
			btn.buttonMode=true
			btn.x=x;
			btn.y=y;
			btn.name=skinName;
			if (listenName != "")
				dic[btn]={name: listenName};
			btn.addEventListener(MouseEvent.CLICK, clickFunc);
			btn.addEventListener(MouseEvent.MOUSE_OVER, onOveHandler);
			btn.addEventListener(MouseEvent.MOUSE_OUT, onOutHandler);
			return btn;
		}

		private function clickFunc(e:MouseEvent):void {
			var value:int=-1;
			ToolTipManager.getInstance().hide();
			switch (dic[e.target].name) {
				case 'society':
					var dic_id:int=1;
					sendCommand(dic_id, "2");
					break;
				case 'team':
					onOpenNearWindow();
					break;
				case 'lixian':
					Dispatch.dispatch(ModuleCommand.OPEN_TRAIN);
					FlashObjectManager.colseFlash(_lixianSprite);
					break;
				case 'help':
					HelpManager.getInstance().openHelpView();
				case 'bigFace':
					BigExpresionModule.getInstance().openBigExpresionView();
					break;
				case 'system':
					sendCommand(7);
					break;
			}
			StatModule.getInstance().addButtonHandler(value);
		}

		private function onOveHandler(evt:MouseEvent):void {
			switch (dic[evt.target].name) {
				case 'team':
					ToolTipManager.getInstance().show("附近玩家(F)", 0);
					break;
				case 'society':
					ToolTipManager.getInstance().show("任务(Q)", 0); //  社会(O)
					break;
				case 'lixian':
					ToolTipManager.getInstance().show("离线挂机", 0);
					break;
				case 'help':
					ToolTipManager.getInstance().show("玩家帮助", 0);
				case 'bigFace':
					ToolTipManager.getInstance().show("大表情", 0);
					break;

			}
		}

		private function onOutHandler(evt:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}
		
		public function getPackRect():Rectangle{
			var p:Point = bag.localToGlobal(new Point(0,0));
			return new Rectangle(p.x,p.y,bag.width,bag.height);
		}
		
	}
}