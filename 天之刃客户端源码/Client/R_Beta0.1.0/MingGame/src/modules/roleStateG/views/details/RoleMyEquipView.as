package modules.roleStateG.views.details {
	import com.common.FilterCommon;
	import com.common.FlashObjectManager;
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemEvent;
	import com.common.dragManager.DragItemManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.ToolTip;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarII;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUtils.RoleActState;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.chat.ChatModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.EquipVO;
	import modules.roleStateG.views.EquipItem;
	
	import proto.common.p_role;
	import proto.common.p_role_base;

	/**
	 * 装备容器
	 *
	 */
	public class RoleMyEquipView extends Sprite {
		public static const EVENT_DO_LEVEL_UP:String="EVENT_DO_LEVEL_UP";
		public static const EVENT_ADD_PROPERY:String="EVENT_ADD_PROPERY";
		public static const EVENT_SHOW_CLOTH:String="EVENT_SHOW_CLOTH";
		public static const EVENT_SHOW_EQUIP_RING:String="EVENT_SHOW_EQUIP_RING";
		public static const PADDING_TOP:int=33;
		public static const LEFT_X:int=18;
		public static const RIGHT_X:int=241;
		public static const V_PADDING:int=4;
		private var equipBg:UIComponent;
		private var attrBg:UIComponent;
		private var roleNameTF:TextField;
		private var levelTF:TextField;
		private var categoryTF:TextField;
		private var wugongTF:TextField;
		private var wufangTF:TextField;
		private var fagongTF:TextField;
		private var fafangTF:TextField;
		private var expBar:ProgressBar;
		private var shengmingTF:TextField;
		private var faliTF:TextField;
		private var zhongjiTF:TextField;
		private var sanbiTF:TextField;
		private var mingzhongTF:TextField;
		private var pojiaTF:TextField;
		private var xingyunzhiTF:TextField;
		private var shanghaixishouTF:TextField;
		private var bingdongkangxingTF:TextField;
		private var xuanyunkangxingTF:TextField;
		private var zhongdukangxingTF:TextField;
		private var liliangTF:TextField;
		private var zhiliTF:TextField;
		private var shengfaTF:TextField;
		private var dingliTF:TextField;
		private var tizhiTF:TextField;
		private var liliangAddTF:TextField;
		private var zhiliAddTF:TextField;
		private var shenfaAddTF:TextField;
		private var dingliAddTF:TextField;
		private var tizhiAddTF:TextField;
		private var shuxingdianTF:TextField;
		private var buttonBackBg:Sprite;
		private var liliangAddBtn:Button;
		private var zhiliAddBtn:Button;
		private var shenfaAddBtn:Button;
		private var dingliAddBtn:Button;
		private var tizhiAddBtn:Button;
		private var liliangReduceBtn:Button;
		private var zhiliReduceBtn:Button;
		private var shenfaReduceBtn:Button;
		private var dingliReduceBtn:Button;
		private var tizhiReduceBtn:Button;
		private var step:RoleNumberSteper;
		private var remainderPropertyInt:int;
		private var liliangChange:int;
		private var zhiliChange:int;
		private var shenfaChange:int;
		private var dingliChange:int;
		private var tizhiChange:int;
		private var propertyRecommend:Button;
		private var propertyConfim:Button;
		private var btns:Array=[];
		private var _liliangAdd:int;
		private var _zhiliAdd:int;
		private var _shenfaAdd:int;
		private var _dingliAdd:int;
		private var _tizhiAdd:int;
		private var remainderPropertyOld:int;
		private var firstUpdate:Boolean=true;
		private var upgradeBtn:Button;
		private var avatar:AvatarII;

		private var _roleVo:p_role;

		public function RoleMyEquipView() {
			setupUI();
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			super();
		}

		public function get tizhiAdd():int {
			return _tizhiAdd;
		}

		public function set tizhiAdd(value:int):void {
			_tizhiAdd=value;
			if(_tizhiAdd==0){
				tizhiAddTF.htmlText="";
			}else{
				tizhiAddTF.htmlText=HtmlUtil.font("+"+_tizhiAdd,"#00ff00");
			}
		}

		public function get dingliAdd():int {
			return _dingliAdd;
		}

		public function set dingliAdd(value:int):void {
			_dingliAdd=value;
			if(_dingliAdd==0){
				dingliAddTF.htmlText="";
			}else{
				dingliAddTF.htmlText=HtmlUtil.font("+"+_dingliAdd,"#00ff00");
			}
		}

		public function get shenfaAdd():int {
			return _shenfaAdd;
		}

		public function set shenfaAdd(value:int):void {
			_shenfaAdd=value;
			if(_shenfaAdd==0){
				shenfaAddTF.htmlText="";
			}else{
				shenfaAddTF.htmlText=HtmlUtil.font("+"+_shenfaAdd,"#00ff00");
			}
		}

		public function get zhiliAdd():int {
			return _zhiliAdd;
		}

		public function set zhiliAdd(value:int):void {
			_zhiliAdd=value;
			if(_zhiliAdd==0){
				zhiliAddTF.htmlText="";
			}else{
				zhiliAddTF.htmlText=HtmlUtil.font("+"+_zhiliAdd,"#00ff00");
			}
		}

		public function get liliangAdd():int {
			return _liliangAdd;
		}

		public function set liliangAdd(value:int):void {
			_liliangAdd=value;
			if(_liliangAdd==0){
				liliangAddTF.htmlText="";
			}else{
				liliangAddTF.htmlText=HtmlUtil.font("+"+_liliangAdd,"#00ff00");
			}
		}

		private function onRemoveFromStage(event:Event):void {
			avatar.stop();
		}

		private function onAddedToStage(event:Event):void {
			if (avatar.hasInit) {
				avatar.play(AvatarConstant.ACTION_STAND, 4, ThingFrameFrequency.STAND);
			}
			remainderPropertyOld=GlobalObjectManager.getInstance().user.base.remain_attr_points;
			clearProperty();
			update();
		}

		private function setupUI():void {
			equipBg=ComponentUtil.createUIComponent(9, 7, 280, 350);
			Style.setBorderSkin(equipBg);
			addChild(equipBg);

			attrBg=ComponentUtil.createUIComponent(equipBg.x + equipBg.width + 2, 7, 172, 350);
			Style.setBorderSkin(attrBg);
			addChild(attrBg);

			roleNameTF=ComponentUtil.createTextField("", 0, 15, Style.centerTextFormat, equipBg.width, 20, equipBg);

			var roleInfoBg:Image=new Image();
			roleInfoBg.x=10;
			roleInfoBg.y=5;
			roleInfoBg.mouseChildren=roleInfoBg.mouseEnabled=false;
			roleInfoBg.source=GameConfig.getBackImage("roleInfoBg");
			equipBg.addChild(roleInfoBg);

			var roleBg:Image=new Image();
			roleBg.x=60;
			roleBg.y=74;
			roleBg.mouseChildren=roleBg.mouseEnabled=false;
			roleBg.source=GameConfig.getBackImage("equipRoleBg");
			equipBg.addChild(roleBg);

			avatar=new AvatarII();
			avatar.x=137;
			avatar.y=210;
			avatar.isPerson=true;
			equipBg.addChild(avatar);

			levelTF=ComponentUtil.createTextField("", roleBg.x + 4, roleBg.y + 4, null, 100, 30, equipBg);
			levelTF.filters=Style.textBlackFilter;

			categoryTF=ComponentUtil.createTextField("", roleBg.x + 120, roleBg.y + 4, null, 100, 30, equipBg);
			categoryTF.filters=Style.textBlackFilter;

			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			tiao.width=250;
			tiao.y=285;
			tiao.x=15;
			equipBg.addChild(tiao);

			wugongTF=ComponentUtil.createTextField("", 10, tiao.y + 6, null, 150, 20, equipBg);
			wufangTF=ComponentUtil.createTextField("", 126, tiao.y + 6, null, 150, 20, equipBg);
			fagongTF=ComponentUtil.createTextField("", 10, tiao.y + 24, null, 150, 20, equipBg);
			fafangTF=ComponentUtil.createTextField("", 126, tiao.y + 24, null, 150, 20, equipBg);

			var expTF:TextField=ComponentUtil.createTextField("经验：", 10, tiao.y + 42, null, 100, 20, equipBg);
			expTF.textColor=0x64DFEE;

			expBar=new ProgressBar();
			expBar.bgSkin=Style.getSkin("expBarBg", GameConfig.T1_UI);
			expBar.bar=Style.getBitmap(GameConfig.T1_UI, "expBar");
			expBar.padding=3;
			expBar.x=46;
			expBar.y=expTF.y + 3;
			expBar.width=149;
			expBar.height=12;
			expBar.value=0.5;
			equipBg.addChild(expBar);

			var duanzhaoBtn:Button=ComponentUtil.createButton("锻造", 212, tiao.y + 8, 60, 25, equipBg);
			Style.setYellowButtonStyle(duanzhaoBtn);
			duanzhaoBtn.addEventListener(MouseEvent.CLICK, onDuanzhaoBtnClick);
			upgradeBtn=ComponentUtil.createButton("升级", 212, tiao.y + 35, 60, 25, equipBg);
			upgradeBtn.addEventListener(MouseEvent.CLICK, onUpgrateBtnClick);

			for (var i:int=1; i <= 6; i++) {
				createEquipItem(i, LEFT_X, PADDING_TOP + (i - 1) * (36 + V_PADDING));
			}
			for (i=7; i <= 12; i++) {
				createEquipItem(i, RIGHT_X, PADDING_TOP + (i - 6 - 1) * (36 + V_PADDING));
			}
			createEquipItem(13, roleBg.x + 24, roleBg.y + 172);
			createEquipItem(14, roleBg.x + 114, roleBg.y + 172);

			//-------------------------------------------------------------------
			// 属性
			//-------------------------------------------------------------------
			var startY:int=12;
			var linding:int=22;

			shengmingTF=ComponentUtil.createTextField("", 8, 12, null, 150, 25, attrBg);
			faliTF=ComponentUtil.createTextField("", 8, startY + linding, null, 150, 25, attrBg);

			var attrTiao1:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			attrTiao1.width=162;
			attrTiao1.y=faliTF.y + 26;
			attrTiao1.x=5;
			attrBg.addChild(attrTiao1);

			startY=attrTiao1.y + 10;

			zhongjiTF=ComponentUtil.createTextField("", 8, startY, null, 150, 25, attrBg);
			sanbiTF=ComponentUtil.createTextField("", 8, startY + linding, null, 150, 25, attrBg);
			mingzhongTF=ComponentUtil.createTextField("", 8, startY + linding * 2, null, 150, 25, attrBg);
			pojiaTF=ComponentUtil.createTextField("", 8, startY + linding * 3, null, 150, 25, attrBg);
			xingyunzhiTF=ComponentUtil.createTextField("", 8, startY + linding * 4, null, 150, 25, attrBg);
			shanghaixishouTF=ComponentUtil.createTextField("", 8, startY + linding * 5, null, 150, 25, attrBg);
			bingdongkangxingTF=ComponentUtil.createTextField("", 8, startY + linding * 6, null, 150, 25, attrBg);
			xuanyunkangxingTF=ComponentUtil.createTextField("", 8, startY + linding * 7, null, 150, 25, attrBg);
			zhongdukangxingTF=ComponentUtil.createTextField("", 8, startY + linding * 8, null, 150, 25, attrBg);

			var attrTiao2:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			attrTiao2.width=162;
			attrTiao2.y=xingyunzhiTF.y + 26;
			attrTiao2.x=5;
			attrBg.addChild(attrTiao2);

			startY=attrTiao2.y + 10;

			liliangTF=ComponentUtil.createTextField("", 8, startY, null, 150, 25, attrBg);
			liliangAddTF=ComponentUtil.createTextField("", 85, startY, null, 150, 25, attrBg);
			zhiliTF=ComponentUtil.createTextField("", 8, startY + linding, null, 150, 25, attrBg);
			zhiliAddTF=ComponentUtil.createTextField("", 85, startY + linding, null, 150, 25, attrBg);
			shengfaTF=ComponentUtil.createTextField("", 8, startY + linding * 2, null, 150, 25, attrBg);
			shenfaAddTF=ComponentUtil.createTextField("", 85, startY + linding * 2, null, 150, 25, attrBg);
			dingliTF=ComponentUtil.createTextField("", 8, startY + linding * 3, null, 150, 25, attrBg);
			dingliAddTF=ComponentUtil.createTextField("", 85, startY + linding * 3, null, 150, 25, attrBg);
			tizhiTF=ComponentUtil.createTextField("", 8, startY + linding * 4, null, 150, 25, attrBg);
			tizhiAddTF=ComponentUtil.createTextField("", 85, startY + linding * 4, null, 150, 25, attrBg);
			shuxingdianTF=ComponentUtil.createTextField("", 8, startY + linding * 5, null, 150, 25, attrBg);

			buttonBackBg=new Sprite();
			buttonBackBg.x=115;
			buttonBackBg.y=196;
			buttonBackBg.mouseEnabled=false;
			attrBg.addChild(buttonBackBg);

			liliangAddBtn=createButton("0", 0, 0, buttonBackBg, "add");
			zhiliAddBtn=createButton("1", 0, linding, buttonBackBg, "add");
			shenfaAddBtn=createButton("2", 0, linding * 2, buttonBackBg, "add");
			dingliAddBtn=createButton("3", 0, linding * 3, buttonBackBg, "add");
			tizhiAddBtn=createButton("4", 0, linding * 4, buttonBackBg, "add");
			liliangReduceBtn=createButton("5", 24, 0, buttonBackBg, "reduce");
			zhiliReduceBtn=createButton("6", 24, linding, buttonBackBg, "reduce");
			shenfaReduceBtn=createButton("7", 24, linding * 2, buttonBackBg, "reduce");
			dingliReduceBtn=createButton("8", 24, linding * 3, buttonBackBg, "reduce");
			tizhiReduceBtn=createButton("9", 24, linding * 4, buttonBackBg, "reduce");

			propertyRecommend=ComponentUtil.createButton("推荐", 78, 322, 45, 24, attrBg);
			propertyRecommend.addEventListener(MouseEvent.CLICK, onRecommendProperty);
			propertyConfim=ComponentUtil.createButton("确定", propertyRecommend.x + propertyRecommend.width + 1, 322, 45, 24, attrBg);
			propertyConfim.addEventListener(MouseEvent.CLICK, onComfirmProperty);

			step=new RoleNumberSteper;
			attrBg.addChild(step);

			DragItemManager.instance.addEventListener(DragItemEvent.START_DRAG, onStartDrag);
			DragItemManager.instance.addEventListener(DragItemEvent.STOP_DRAG, onStopDrag);

			remainderPropertyInt=GlobalObjectManager.getInstance().user.base.remain_attr_points;
		}

		private function onDuanzhaoBtnClick(event:MouseEvent):void {
			Dispatch.dispatch(ModuleCommand.OPEN_STOVE_WINDOW);
		}

		private function onUpgrateBtnClick(event:MouseEvent):void {
			if (GlobalObjectManager.getInstance().user.base.status == RoleActState.TRAINING) {
				BroadcastSelf.getInstance().appendMsg(HtmlUtil.font("在训练营闭关修炼中，无法升级", "#ff0000"));
			} else {
				var p:p_role_base=GlobalObjectManager.getInstance().user.base;
				this.dispatchEvent(new ParamEvent(EVENT_DO_LEVEL_UP, null, true));
			}
		}

		private function createButton(id:String, xValue:int, yValue:int, parent:Sprite, type:String="add"):Button {
			var btn:Button=new Button();
			btn.name=id;
			btn.width=16;
			btn.height=15;
			btn.label="";
			if (type == "add") {
				Style.setaddBtnStyle(btn);
			} else {
				Style.setreduceBtnStyle(btn);
			}
			btn.x=xValue;
			btn.y=yValue;
			btn.addEventListener(MouseEvent.CLICK, addproperty);
			parent.addChild(btn);
			btns.push(btn);
			return btn;
		}

		public function update():void {
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			_roleVo=roleVO;
			avatar.category=roleVO.attr.category;
			avatar.sex=roleVO.base.sex;
			if (avatar.hasInit) {
				avatar.updataSkin(roleVO.attr.skin);
			} else {
				avatar.initSkin(roleVO.attr.skin);
			}
			avatar.play(AvatarConstant.ACTION_STAND, 4, ThingFrameFrequency.STAND);

			roleNameTF.htmlText=HtmlUtil.font(roleVO.base.role_name, "#51EAEF", 14);
			levelTF.htmlText=HtmlUtil.font(roleVO.attr.level + "级", "#FFFF66", 13);
			categoryTF.htmlText=HtmlUtil.font(GameConstant.CATEGORY[roleVO.attr.category], "#FFFF66", 13);

			wugongTF.htmlText=HtmlUtil.wapper("物攻：", roleVO.base.min_phy_attack + " - " + roleVO.base.max_phy_attack, "#FFFF66", "#E992F1");
			wufangTF.htmlText=HtmlUtil.wapper("物防：", roleVO.base.phy_defence, "#FFFF66", "#E992F1");
			fagongTF.htmlText=HtmlUtil.wapper("法攻：", roleVO.base.min_magic_attack + " - " + roleVO.base.max_magic_attack, "#FFFF66", "#E992F1");
			fafangTF.htmlText=HtmlUtil.wapper("法防：", roleVO.base.magic_defence, "#FFFF66", "#E992F1");

			expBar.value=roleVO.attr.exp / roleVO.attr.next_level_exp;
			expBar.htmlText=int(roleVO.attr.exp / roleVO.attr.next_level_exp* 100) + "%";
			expBar.addEventListener(MouseEvent.ROLL_OVER, onExpBarRollOver);
			expBar.addEventListener(MouseEvent.ROLL_OUT, onExpBarRollOut);

			shengmingTF.htmlText=HtmlUtil.wapper("生命：", roleVO.fight.hp + " / " + roleVO.base.max_hp, "#63C6D0", "#E992F1");
			faliTF.htmlText=HtmlUtil.wapper("法力：", roleVO.fight.mp + " / " + roleVO.base.max_mp, "#63C6D0", "#E992F1");

			zhongjiTF.htmlText=HtmlUtil.wapper("重击：", roleVO.base.double_attack / 100 + "%", "#63C6D0", "#E992F1");
			sanbiTF.htmlText=HtmlUtil.wapper("闪避：", roleVO.base.miss, "#63C6D0", "#E992F1");
			mingzhongTF.htmlText=HtmlUtil.wapper("命中：", roleVO.base.hit_rate / 100 + "%", "#63C6D0", "#E992F1");
			pojiaTF.htmlText=HtmlUtil.wapper("破甲：", roleVO.base.no_defence, "#63C6D0", "#E992F1");
			xingyunzhiTF.htmlText=HtmlUtil.wapper("幸运值：", roleVO.base.luck, "#63C6D0", "#E992F1");

			if (remainderPropertyOld != roleVO.base.remain_attr_points || firstUpdate) {
				remainderPropertyOld=roleVO.base.remain_attr_points;
				clearProperty();
				firstUpdate=false;
			}

			if (roleVO.base.str - roleVO.base.base_str > 0) {
				liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.base_str + liliangAdd + "+" + (roleVO.base.str - roleVO.base.base_str), "#1FC54C", "#E992F1");
			} else {
				liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.base_str + liliangAdd, "#1FC54C", "#E992F1");
			}
			if (roleVO.base.int2 - roleVO.base.base_int > 0) {
				zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.base_int + zhiliAdd + "+" + (roleVO.base.int2 - roleVO.base.base_int), "#1FC54C", "#E992F1");
			} else {
				zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.base_int + zhiliAdd, "#1FC54C", "#E992F1");
			}
			if (roleVO.base.dex - roleVO.base.base_dex > 0) {
				shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.base_dex + shenfaAdd + "+" + (roleVO.base.dex - roleVO.base.base_dex), "#1FC54C", "#E992F1");
			} else {
				shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.base_dex + shenfaAdd, "#1FC54C", "#E992F1");
			}
			if (roleVO.base.men - roleVO.base.base_men > 0) {
				dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.base_men + dingliAdd + "+" + (roleVO.base.men - roleVO.base.base_men), "#1FC54C", "#E992F1");
			} else {
				dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.base_men + dingliAdd, "#1FC54C", "#E992F1");
			}
			if (roleVO.base.con - roleVO.base.base_con > 0) {
				tizhiTF.htmlText=HtmlUtil.wapper("体质：", roleVO.base.base_con + tizhiAdd + "+" + (roleVO.base.con - roleVO.base.base_con), "#1FC54C", "#E992F1");
			} else {
				tizhiTF.htmlText=HtmlUtil.wapper("体质：", roleVO.base.base_con + tizhiAdd, "#1FC54C", "#E992F1");
			}
			//remainderPropertyInt=roleVO.base.remain_attr_points;
			shuxingdianTF.htmlText=HtmlUtil.wapper("属性点：", remainderPropertyInt, "#1FC54C", "#E992F1");
			resetProBtn(); //设置加减按钮
			updateEquips();
			checkLevelBtn();
		}

		private function onExpBarRollOver(event:MouseEvent):void {
			ToolTipManager.getInstance().show("经验：" + _roleVo.attr.exp + "/" + _roleVo.attr.next_level_exp);
		}

		private function onExpBarRollOut(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function checkLevelBtn():void {
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			var exp:Number=GlobalObjectManager.getInstance().user.attr.exp;
			var next_level_exp:int=GlobalObjectManager.getInstance().user.attr.next_level_exp;
			if (level < 9) {
				upgradeBtn.visible=false;
			} else {
				upgradeBtn.visible=true;
				if (exp >= next_level_exp && GlobalObjectManager.getInstance().user.base.status != RoleActState.DEAD) {
					upgradeBtn.enabled=true;
				} else {
					upgradeBtn.enabled=false;
				}
				if (level >= 120) {
					upgradeBtn.enabled=false;
				}
			}
		}

		private function resetProBtn():void {
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			if (roleVO.base.remain_attr_points <= 0) {
				propertyRecommend.enabled=false;
				FlashObjectManager.colseFlash(propertyConfim);
				propertyConfim.enabled=false;
				for (i=0; i < 10; i++) {
					btns[i].enabled=false;
					btns[i].visible=false;
				}
			} else {
				propertyRecommend.enabled=true;
				propertyRecommend.visible=true;
				propertyConfim.enabled=true;
				propertyConfim.visible=true;
				for (i=0; i < 10; i++) {
					btns[i].enabled=true;
					btns[i].visible=true;
				}
			}

			if (remainderPropertyInt <= 0) {
				for (var i:int=0; i < 5; i++) {
					btns[i].enabled=false;
					btns[i].visible=false;
				}
				if (liliangAdd > 0 || zhiliAdd > 0 || shenfaAdd > 0 || dingliAdd > 0 || tizhiAdd > 0) {
					propertyConfim.enabled=true;
					FlashObjectManager.setFlash(propertyConfim);
				} else {
					propertyConfim.enabled=false;
				}
			} else {
				for (i=0; i < 5; i++) {
					btns[i].enabled=true;
					btns[i].visible=true;
				}
				FlashObjectManager.colseFlash(propertyConfim);
				if (liliangAdd == 0 && zhiliAdd == 0 && shenfaAdd == 0 && dingliAdd == 0 && tizhiAdd == 0) {
					propertyConfim.enabled=false;
				} else {
					propertyConfim.enabled=true;
				}

			}
			btns[5].enabled=liliangAdd > 0;
			btns[6].enabled=zhiliAdd > 0;
			btns[7].enabled=shenfaAdd > 0;
			btns[8].enabled=dingliAdd > 0;
			btns[9].enabled=tizhiAdd > 0;
			if (!btns[5].enabled && !btns[6].enabled && !btns[7].enabled && !btns[8].enabled && !btns[9].enabled) {
				btns[5].visible=false;
				btns[6].visible=false;
				btns[7].visible=false;
				btns[8].visible=false;
				btns[9].visible=false;
			} else {
				btns[5].visible=true;
				btns[6].visible=true;
				btns[7].visible=true;
				btns[8].visible=true;
				btns[9].visible=true;
			}
		}

		private function addproperty(e:MouseEvent):void {
			var btn:Button=e.currentTarget as Button;
			var s:int=int(btn.name);
			var type:int=s % 5 + 1;
			var isAdd:Boolean=s < 5;

			if (isAdd == true) {
				if (remainderPropertyInt >= 30) {
					step.reset(btn.x + 20, btn.y + 196, remainderPropertyInt, type, isAdd, changProperty);
				} else {
					changProperty(1, type, isAdd);
				}
			} else {
				//力量
				if (type == 1 && liliangChange >= 30) {
					step.reset(btn.x + 20, btn.y + 208, liliangChange, type, isAdd, changProperty);
				} else if (type == 2 && zhiliChange >= 30) {
					step.reset(btn.x + 20, btn.y + 208, zhiliChange, type, isAdd, changProperty);
				} else if (type == 3 && shenfaChange >= 30) {
					step.reset(btn.x + 20, btn.y + 208, shenfaChange, type, isAdd, changProperty);
				} else if (type == 4 && dingliChange >= 30) {
					step.reset(btn.x + 20, btn.y + 208, dingliChange, type, isAdd, changProperty);
				} else if (type == 5 && tizhiChange >= 30) {
					step.reset(btn.x + 20, btn.y + 208, tizhiChange, type, isAdd, changProperty);
				} else {
					changProperty(1, type, isAdd);
				}
			}
		}

		private function changProperty(value:int, type:int, add:Boolean=true):void {
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			switch (type) {
				case 1:
					if (add == true) {
						if (remainderPropertyInt > 0) {
							liliangAdd+=value;
							remainderPropertyInt-=value;
						}
					} else {
						if (liliangAdd > 0) {
							liliangAdd-=value;
							remainderPropertyInt+=value;
						}
					}
					if (roleVO.base.str - roleVO.base.base_str > 0) {
						liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.base_str + liliangAdd + "+" + (roleVO.base.str - roleVO.base.base_str), "#1FC54C", "#E992F1");
					} else {
						liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.base_str + liliangAdd, "#1FC54C", "#E992F1");
					}
					break;
				case 2:
					if (add == true) {
						if (remainderPropertyInt > 0) {
							zhiliAdd+=value;
							remainderPropertyInt-=value;
						}
					} else {
						if (zhiliAdd > 0) {
							zhiliAdd-=value;
							remainderPropertyInt+=value;
						}
					}
					if (roleVO.base.int2 - roleVO.base.base_int > 0) {
						zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.base_int + zhiliAdd + "+" + (roleVO.base.int2 - roleVO.base.base_int), "#1FC54C", "#E992F1");
					} else {
						zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.base_int + zhiliAdd, "#1FC54C", "#E992F1");
					}
					break;
				case 3:
					if (add == true) {
						if (remainderPropertyInt > 0) {
							shenfaAdd+=value;
							remainderPropertyInt-=value;
						}
					} else {
						if (shenfaAdd > 0) {
							shenfaAdd-=value;
							remainderPropertyInt+=value;
						}
					}
					if (roleVO.base.dex - roleVO.base.base_dex > 0) {
						shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.base_dex + shenfaAdd + "+" + (roleVO.base.dex - roleVO.base.base_dex), "#1FC54C", "#E992F1");
					} else {
						shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.base_dex + shenfaAdd, "#1FC54C", "#E992F1");
					}
					break;
				case 4:
					if (add == true) {
						if (remainderPropertyInt > 0) {
							dingliAdd+=value;
							remainderPropertyInt-=value;
						}
					} else {
						if (dingliAdd > 0) {
							dingliAdd-=value;
							remainderPropertyInt+=value;
						}
					}
					if (roleVO.base.men - roleVO.base.base_men > 0) {
						dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.base_men + dingliAdd + "+" + (roleVO.base.men - roleVO.base.base_men), "#1FC54C", "#E992F1");
					} else {
						dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.base_men + dingliAdd, "#1FC54C", "#E992F1");
					}
					break;
				case 5:
					if (add == true) {
						if (remainderPropertyInt > 0) {
							tizhiAdd+=value;
							remainderPropertyInt-=value;
						}
					} else {
						if (tizhiAdd > 0) {
							tizhiAdd-=value;
							remainderPropertyInt+=value;
						}
					}
					if (roleVO.base.con - roleVO.base.base_con > 0) {
						tizhiTF.htmlText=HtmlUtil.wapper("体质：", roleVO.base.base_con + tizhiAdd + "+" + (roleVO.base.con - roleVO.base.base_con), "#1FC54C", "#E992F1");
					} else {
						tizhiTF.htmlText=HtmlUtil.wapper("体质：", roleVO.base.base_con + tizhiAdd, "#1FC54C", "#E992F1");
					}
					break;
				default:
					break;
			}
			shuxingdianTF.htmlText=HtmlUtil.wapper("属性点：", remainderPropertyInt, "#1FC54C", "#E992F1");
			resetProBtn(); //设置加减按钮
		}

		private function onRecommendProperty(event:MouseEvent):void {
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			var categoryID:int=roleVO.attr.category;
			liliangAdd=zhiliAdd=shenfaAdd=dingliAdd=tizhiAdd=0;
			liliangAddTF.htmlText=zhiliAddTF.htmlText=shenfaAddTF.htmlText=dingliAddTF.htmlText=tizhiAddTF.htmlText="";
			if (categoryID == 1) {
				shenfaAdd=roleVO.base.remain_attr_points;
				if (roleVO.base.dex - roleVO.base.base_dex > 0) {
					shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.base_dex + shenfaAdd + "+" + (roleVO.base.dex - roleVO.base.base_dex), "#1FC54C", "#E992F1");
				} else {
					shengfaTF.htmlText=HtmlUtil.wapper("身法：", roleVO.base.base_dex + shenfaAdd, "#1FC54C", "#E992F1");
				}
			} else if (roleVO.attr.category == 2) {
				liliangAdd=roleVO.base.remain_attr_points;
				if (roleVO.base.str - roleVO.base.base_str > 0) {
					liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.base_str + liliangAdd + "+" + (roleVO.base.str - roleVO.base.base_str), "#1FC54C", "#E992F1");
				} else {
					liliangTF.htmlText=HtmlUtil.wapper("力量：", roleVO.base.base_str + liliangAdd, "#1FC54C", "#E992F1");
				}
			} else if (roleVO.attr.category == 3) {
				zhiliAdd=roleVO.base.remain_attr_points;
				if (roleVO.base.int2 - roleVO.base.base_int > 0) {
					zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.base_int + zhiliAdd + "+" + (roleVO.base.int2 - roleVO.base.base_int), "#1FC54C", "#E992F1");
				} else {
					zhiliTF.htmlText=HtmlUtil.wapper("智力：", roleVO.base.base_int + zhiliAdd, "#1FC54C", "#E992F1");
				}
			} else if (roleVO.attr.category == 4) {
				dingliAdd=roleVO.base.remain_attr_points;
				if (roleVO.base.men - roleVO.base.base_men > 0) {
					dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.base_men + dingliAdd + "+" + (roleVO.base.men - roleVO.base.base_men), "#1FC54C", "#E992F1");
				} else {
					dingliTF.htmlText=HtmlUtil.wapper("定力：", roleVO.base.base_men + dingliAdd, "#1FC54C", "#E992F1");
				}
			}
			remainderPropertyInt=0;
			shuxingdianTF.htmlText=HtmlUtil.wapper("属性点：", remainderPropertyInt, "#1FC54C", "#E992F1");
			resetProBtn();
		}

		private function onComfirmProperty(e:MouseEvent):void {
			if (liliangAdd == 0 && zhiliAdd == 0 && shenfaAdd == 0 && dingliAdd == 0 && tizhiAdd == 0) {
				Alert.show("属性点未分配", "提示", null, null, "确定", "取消", null, false);
				return;
			}
			if (liliangAdd > 0)
				doAddProperty(liliangAdd, 1);
			if (zhiliAdd > 0)
				doAddProperty(zhiliAdd, 2);
			if (shenfaAdd > 0)
				doAddProperty(shenfaAdd, 3);
			if (dingliAdd > 0)
				doAddProperty(dingliAdd, 4);
			if (tizhiAdd > 0)
				doAddProperty(tizhiAdd, 5);

			//Dispatch.dispatch(GuideConstant.CLOSE_ATTR_TIP);

		}

		private function doAddProperty(value:int, type:int):void {
			var e:ParamEvent=new ParamEvent(EVENT_ADD_PROPERY, {"type": type, "value": value}, true);
			this.dispatchEvent(e);
		}

		private function updateEquips():void {
			removeAllEquips();
			var equips:Array=GlobalObjectManager.getInstance().user.attr.equips;
			for (var i:int=0; i < equips.length; i++) {
				var equip:EquipVO=ItemConstant.wrapperItemVO(equips[i]) as EquipVO;
				if (equip != null) {
					var equipBox:EquipItem=getChildByName(equip.loadposition + "") as EquipItem;
					if (equipBox)
						equipBox.updateContent(equip);
				}
			}
		}

		private function removeAllEquips():void {
			for (var i:int=1; i <= 14; i++) {
				var equipBox:EquipItem=getChildByName(i.toString()) as EquipItem;
				if (equipBox) {
					equipBox.updateContent(null);
				}
			}
		}

		private function putRoleEquip(position:int, equip:EquipVO):void {
			var equipBox:EquipItem=getChildByName(position.toString()) as EquipItem;
			equipBox.data=equip;
		}

		public function getEquipItemByName(index:int):EquipItem {
			return this.getChildByName(index.toString()) as EquipItem
		}

		private var equipPos:Array=[0, 1, 2, 3, 4, 6, 5, 9, 10, 11, 12, 13, 8, 7, 14];

		private function createEquipItem(pos:int, xValue:Number, yValue:Number):void {
			var equipItem:EquipItem=new EquipItem();
			equipItem.name=equipPos[pos].toString();
			equipItem.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			equipItem.doubleClickEnabled=true;
			equipItem.addEventListener(MouseEvent.DOUBLE_CLICK, onItemDoubleClick);
			equipItem.position=equipPos[pos];
			equipItem.x=xValue;
			equipItem.y=yValue;
			addChild(equipItem);
		}

		private function mouseDownHandler(event:MouseEvent):void {
			var equipItem:EquipItem=event.currentTarget as EquipItem;
			if (event.ctrlKey && equipItem.data) {
				ChatModule.getInstance().showGoods(equipItem.data.oid);
			} else if (equipItem.data && !DragItemManager.isDragging()) {
				DragItemManager.instance.startDragItem(this, equipItem.getContent(), DragConstant.EQUIP_ITEM, equipItem.data);
			}
		}

		private function onItemDoubleClick(event:MouseEvent):void {
			var equipItem:EquipItem=event.currentTarget as EquipItem;
			if (equipItem.data && !DragItemManager.isDragging()) {
				PackageModule.getInstance().unLoadEquip(equipItem.data.oid);
			}
		}

		private function onStartDrag(event:DragItemEvent):void {
			var equipVO:EquipVO=event.dragData as EquipVO;
			if (equipVO) {
				setFilter([new GlowFilter(0xffffff, 1, 6, 6, 4)], equipVO);
			}
		}

		private function onStopDrag(event:DragItemEvent):void {
			var equipVO:EquipVO=event.dragData as EquipVO;
			if (equipVO) {
				setFilter([], equipVO);
			}
		}

		public function setFilter(filters:Array, equipVO:EquipVO):void {
			var pos:Array=ItemConstant.getPostionByPutWhere(equipVO.putWhere);
			for each (var position:int in pos) {
				var equipItem:EquipItem=getChildByName((position + 1).toString()) as EquipItem;
				if (equipItem) {
					equipItem.filters=filters;
				}
			}
		}

		public function clearProperty():void {
			var roleVO:p_role=GlobalObjectManager.getInstance().user;
			remainderPropertyInt=roleVO.base.remain_attr_points;
			liliangAdd=0;
			zhiliAdd=0;
			shenfaAdd=0;
			dingliAdd=0;
			tizhiAdd=0;
			liliangAddTF.htmlText="";
			zhiliAddTF.htmlText="";
			shenfaAddTF.htmlText="";
			dingliAddTF.htmlText="";
			tizhiAddTF.htmlText="";
		}
	}
}