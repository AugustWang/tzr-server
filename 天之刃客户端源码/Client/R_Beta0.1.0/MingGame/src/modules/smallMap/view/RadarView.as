package modules.smallMap.view {
	import com.common.FlashObjectManager;
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.KeyUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	import modules.ModuleCommand;
	import modules.gm.GMModule;
	import modules.playerGuide.PlayerGuideModule;
	import modules.rank.RankModule;
	import modules.scene.SceneDataManager;
	import modules.smallMap.view.items.MapView;
	import modules.stat.StatConstant;
	import modules.stat.StatModule;
	import modules.system.SystemConfig;
	import modules.system.SystemModule;

	public class RadarView extends Sprite {
		public var map:MapView;
//		private var mapName:TextField;
		public var posTxt:TextField; //坐标点
		private var activityBtn:UIComponent;
		private var letterBtn:UIComponent;
		private var guaBtn:Button;
		private var soundBtn:Button;
		private var hideShowBtn:Button;
		private var netBtn:UIComponent;
		private var netBitmap:Bitmap;
		
		private var sound_bitmap:Bitmap;
		private var hideShow_bitmap:Bitmap;
		//变化界面按钮 F8
		private var changeBTN:Sprite;

		public function RadarView() {
			super();
			initView();
		}

		private function initView():void {
			map=new MapView;
			addChild(map);
			map.x=18;
			map.y=2;
			var mapHighLight:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"mapHighLight");
			mapHighLight.x=40;
			mapHighLight.y=4;
			addChild(mapHighLight);
			var mapMask:Shape=new Shape();
			addChild(mapMask);
			mapMask.graphics.beginFill(0, 0);
			mapMask.graphics.drawCircle(88, 72, 68);
			mapMask.graphics.endFill();
			map.mask=mapMask;
			var bgSprite:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"smallMapBg");
			addChild(bgSprite);
//			mapName=ComponentUtil.createTextField("", 15, 1, new TextFormat(null, null, 0xF6F5CD, null, null, null, null, null, "center"), 110, 22, this);
			posTxt=ComponentUtil.createTextField("", 50, 75, new TextFormat("Tahoma", 10, 0xffffff), 50, 18, this);
//			payBtn=createBtn("chongzhi", -7, 27, this); //充值
//			activityBtn=createBtn("activityIcon", -26, 50, this); //活动
//			var vipBtn:Sprite=createBtn("quanBg", -12, 84, this); // VIP
//			createBtn("vipBtn", 4, 8, vipBtn);
//			rankBtn=createBtn("quanBg", -1, 107, this); //排行榜
//			createBtn("ban", 6, 6, rankBtn);
//			guaBtn=createBtn("quanBg", 18, 125, this); //挂机
//			createBtn("gua", 6, 6, guaBtn);
//			mapBtn=createBtn("quanBg", 43, 135, this); //M按钮
//			createBtn("map", 8, 8, mapBtn);
//			letterBtn=createBtn("quanBg", 70, 135, this); //信件按钮
//			createBtn("letter_unread", 5, 7, letterBtn);
//			gmBtn=createBtn("quanBg", 95, 126, this); //GM
//			createBtn("gm", 4, 6, gmBtn);
//			officeBtn=createBtn("quanBg", 113, 107, this); //官网
//			createBtn("guan", 6, 6, officeBtn);
//			bbsBtn=createBtn("quanBg", 114, 26, this); //论坛按钮
//			createBtn("bbs", 6, 6, bbsBtn);
//			changeBTN=createBtn("quanBg", 123, 46, this); //变大变小界面按钮
//			createBtn("change", 8, 8, changeBTN);
			
			netBtn = new UIComponent();
			netBtn.width = netBtn.height = 13;
			netBitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"net_1");
			netBtn.setToolTip("网络状态：非常好",0);
			netBtn.x = 129;
			netBtn.y = 6;
			netBtn.addChild(netBitmap);
			addChild(netBtn);
			
			var activitySkin:Skin = Style.getButtonSkin("active_1skin","active_2skin","active_3skin","",GameConfig.T1_UI);
			activityBtn=createButton("","activityIcon", 6, 6, activitySkin,32,31); //活动
			letterBtn = createIconBtn(Style.getBitmap(GameConfig.T1_VIEWUI,"letter"),"letter_unread",1, 38);
			createLabelBtn("榜","ban", 0, 64);
			createLabelBtn("M","map", 4, 89);
			guaBtn = createLabelBtn("挂","gua", 18, 112);
			createLabelBtn("GM","gm", 40, 129);
			createLabelBtn("售","sell", 65, 135);
			
			hideShow_bitmap = new Bitmap();
			hideShow_bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"hidePlayer_on");
			hideShowBtn = createIconBtn(hideShow_bitmap,"hidePlayer", 92, 135,-8);
			createIconBtn(Style.getBitmap(GameConfig.T1_VIEWUI,"fullScreen_on"),"change",117, 128,2);
			
			sound_bitmap = new Bitmap();
			sound_bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"sound_on");
			soundBtn = createIconBtn(sound_bitmap,"sound", 137, 111,-4);
			
//			FlashObjectManager.setFlash(activityBtn);
			KeyUtil.getInstance().addKeyHandler(toOpenLetter, [InputKey.L]);
			KeyUtil.getInstance().addKeyHandler(toOpenSmallMap, [InputKey.M]);
			//LetterModule.getInstance().isNewLetter();//=================初始化请求所有信件
			configChanged();
		}
		
		public function pingValueChanged(value:int):void{
			if(value <= 500){
				netBitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"net_1");
				netBtn.setToolTip("网络状态：非常好",0);
			}else if(value > 500 && value < 1500){
				netBitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"net_2");
				netBtn.setToolTip("网络状态：一般",0);
			}else{
				netBitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"net_3");
				netBtn.setToolTip("网络状态：非常差",0);
			}
		}
		
		private function onClick(e:MouseEvent):void {
			Dispatch.dispatch(ModuleCommand.OPEN_SMALL_SCENE);
		}

		//创建周围的小图标
		private function createBtn(skinName:String, x:Number, y:Number, parent:Sprite):Sprite {
			var skin:Sprite=Style.getViewBg(skinName);
			skin.buttonMode=true;
			if (skinName == "quanBg") {
				skin.mouseEnabled=false;
			} else {
				skin.addEventListener(MouseEvent.CLICK, onClickBtn);
				skin.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
				skin.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			}
			skin.x=x;
			skin.y=y;
			skin.name=skinName;
			parent.addChild(skin);
			return skin;
		}
		
		private function createIconBtn(icon:DisplayObject,name:String,x:int,y:int,iconLeft:Number=0):Button{
			var bgSkin:Skin = Style.getButtonSkin("circle_1skin","circle_1skin","circle_1skin","",GameConfig.T1_UI);
			var btn:Button = createButton("",name,x,y,bgSkin);
			btn.icon = icon;
			btn.iconLeft = iconLeft;
			return btn;
		}
		
		private function createLabelBtn(label:String,name:String,x:int,y:int):Button{
			var bgSkin:Skin = Style.getButtonSkin("circle_1skin","circle_2skin","circle_3skin","",GameConfig.T1_UI);
			return createButton(label,name,x,y,bgSkin);
		}
		
		private function createButton(label:String,name:String,x:int,y:int,skin:Skin,w:Number=25,h:Number=25):Button{
			var btn:Button = new Button();
			btn.bgSkin = skin;
			btn.label = label;
			btn.x = x;
			btn.y = y;
			btn.width = w;
			btn.height = h;
			btn.textColor = 0xfed400;
			btn.addEventListener(MouseEvent.CLICK, onClickBtn);
			btn.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			btn.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			btn.leftPadding = 1
			btn.topPadding = -1;
			btn.name = name;
			addChild(btn);
			return btn;
		}
		
		private function onRollOver(e:MouseEvent):void {
			var name:String=e.target.name;
			if (name == "letter_unread") {
				ToolTipManager.getInstance().show("信件(L)", 0);
			} else if (name == "gm") {
				ToolTipManager.getInstance().show("联系GM", 0);
			} else if (name == "gua") {
				ToolTipManager.getInstance().show("挂机(Z)", 0);
			} else if (name == "map") {
				ToolTipManager.getInstance().show("地图(M)", 0);
			} else if (name == "ban") {
				ToolTipManager.getInstance().show("排行榜", 0);
			} else if (name == "sell") {
				ToolTipManager.getInstance().show("出售", 0);
			} else if (name == "sound") {
				ToolTipManager.getInstance().show("静音/开启", 0);
			} else if (name == "hidePlayer") {
				ToolTipManager.getInstance().show("隐藏/显示其他玩家", 0);
			}else if (name == "activityIcon") {
				if (GlobalObjectManager.getInstance().user.attr.level >= 20) {
					ToolTipManager.getInstance().show("每日活动列表", 0);
				} else {
					ToolTipManager.getInstance().show("参与活动可获得大量奖励，高额经验、极品道具全都有！", 0);
				}
			} else if (name == "change") {
				ToolTipManager.getInstance().show("(F8)切换屏幕", 0);
			}
		}

		private function onRollOut(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onClickBtn(e:MouseEvent):void {
			var value:int; //给后台统计
			switch (e.currentTarget.name) {
				case "activityIcon":
					FlashObjectManager.colseFlash(activityBtn);
					ActivityModule.getInstance().openActivityWin();
					value=StatConstant.VALUE_ACTIVITY;
					break;
				case "ban":
					value=StatConstant.VALUE_BANG;
					RankModule.getInstance().openRankWindow();
					break;
				case "gua":
					Dispatch.dispatch(ModuleCommand.OPEN_AUTOKILL_MONSTER);
					value=StatConstant.VALUE_GUA;
					break;
				case "map":
					Dispatch.dispatch(ModuleCommand.OPEN_SMALL_SCENE);
					value=StatConstant.VALUE_MAP;
					break;
				case "letter_unread":
					Dispatch.dispatch(ModuleCommand.OPEN_LETTER_LIST);
					value=StatConstant.VALUE_LETTER;
					FlashObjectManager.colseFlash(letterBtn);
					break;
				case "gm":
					GMModule.getInstance().openLetterWin();
					value=StatConstant.VALUE_GM;
					break;
				case "sound":
					musicHandler();
					break;
				case "hidePlayer":
					hideShowPlayerHandler();
					break;
				case "change":
					fullScreen();
					value=StatConstant.VALUE_CHANGE;
					break;
				case 'sell':
					Dispatch.dispatch(ModuleCommand.OPEN_BOSSGROUP_PANEL);
					break;
				default:
					break;
			}
			StatModule.getInstance().addButtonHandler(value);
		}

		public function flashSomeThing(str:String):void {
			switch (str) {
				case "gua":
					FlashObjectManager.setFlash(guaBtn);
					break;
				case "letter":
					FlashObjectManager.setFlash(letterBtn);
					break;
				default:
					break;
			}
		}

		public function stopflashSomeThing(str:String):void {
			switch (str) {
				case "gua":
					FlashObjectManager.colseFlash(guaBtn);
					break;
				case "letter":
					FlashObjectManager.colseFlash(letterBtn);
					break;
				default:
					break;
			}
		}
		
		private var showPlayer:Boolean = true;
		private function hideShowPlayerHandler():void{
			Dispatch.dispatch(ModuleCommand.HIDE_ROLES);
			showPlayer = !showPlayer;
			if(showPlayer){
				hideShow_bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"hidePlayer_on");
			}else{
				hideShow_bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"hidePlayer_off");
			}
		}
		
		private function musicHandler():void {
			SystemConfig.openBackSound=!SystemConfig.openBackSound;
			SystemConfig.openGameSound=SystemConfig.openBackSound;
			SystemModule.getInstance().changeBackMusic();
			SystemConfig.save();
		}
		
		public function configChanged():void {
			if(SystemConfig.openBackSound){
				sound_bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"sound_on");
			}else{
				sound_bitmap.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"sound_off");
			}
		}
		
		/**
		 *全屏
		 *
		 */
		private function fullScreen():void {
			if (PlayerGuideModule.getInstance().isMasking) {
				//如果真正遮罩期间，则不能进行全屏切换
				return;
			}
			var screenState:int=GlobalObjectManager.getInstance().screenState;
			if (screenState == 0) {
				ExternalInterface.call("intoFullScreen");
				GlobalObjectManager.getInstance().screenState=2;
			} else if (screenState == 1) {
				ExternalInterface.call("intoFullScreen");
				GlobalObjectManager.getInstance().screenState=2;
			} else if (screenState == 2) {
				ExternalInterface.call("exitFullScreen");
				GlobalObjectManager.getInstance().screenState=0;
			}
		}

		public function onSmallMapComplete(bmd:BitmapData):void {
			var mapID:int=SceneDataManager.mapID;
			map.changeView(mapID, bmd);
		}

		private function toOpenLetter():void {
			Dispatch.dispatch(ModuleCommand.OPEN_LETTER_LIST);
		}

		private function toOpenSmallMap():void {
			Dispatch.dispatch(ModuleCommand.OPEN_SMALL_SCENE);
		}
	}
}