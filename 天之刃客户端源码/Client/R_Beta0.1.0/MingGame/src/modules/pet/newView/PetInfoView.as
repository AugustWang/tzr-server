package modules.pet.newView {
	import com.common.FlashObjectManager;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.utils.ScaleShape;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.forgeshop.views.items.WuxingItemRender;
	import modules.mypackage.ItemConstant;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;
	import modules.pet.newView.items.PetList;
	import modules.pet.view.PetAptitudeView;
	import modules.pet.view.PetNumberSteper;
	import modules.pet.view.PetReNameView;
	import modules.playerGuide.PlayerGuideModule;
	
	import proto.common.p_pet;
	import proto.common.p_pet_attr_assign;
	import proto.common.p_skin;
	import proto.line.m_pet_add_life_tos;
	import proto.line.m_pet_attr_assign_tos;
	import proto.line.m_pet_change_name_toc;
	import proto.line.m_pet_refining_exp_tos;

	public class PetInfoView extends UIComponent {
		
		public static const CALL_BACK_EVENT:String="CALL_BACK_EVENT";
		public static const SUMMON_EVENT:String="SUMMON_EVENT";
		public static const THROW_EVENT:String="THROW_EVENT";
		public static const PET_STORE_EVENT:String="PET_STORE_EVENT";
		public static const PROPERTY_EVENT:String="PROPERTY_EVENT";
		
		public static var upDownAbled:Boolean=true;
		public static var summonAbled:Boolean=true; //限制按钮时间
		public static var callBackAbled:Boolean=true;
		public static var retireAbled:Boolean=true; //限制点击
		private static var summonTimeID:int;
		private static var callBackTimeID:int;
		
		//重置时间限制
		public static function setSummonAbledFalse():void {
			summonAbled=false;
			LoopManager.clearTimeout(summonTimeID);
			summonTimeID=LoopManager.setTimeout(function s():void {
				summonAbled=true
			}, 10000);
		}
		
		public static function setCallBackAbledFalse():void {
			callBackAbled=false;
			LoopManager.clearTimeout(callBackTimeID);
			callBackTimeID=LoopManager.setTimeout(function s():void {
				callBackAbled=true
			}, 5000);
		}
		
		private var petList:PetList
		private var avatarBg:UIComponent;
		private var typeTF:TextField;
		private var levelTF:TextField;
		private var bandTF:TextField;
		private var colorTF:TextField;
		private var sexTF:TextField;
		private var petAvater:Avatar;
		private var fightBtn:UIComponent;
		private var mingziInput:TextInput;
		private var shoumingInput:TextInput;
		private var shengmingzhiInput:TextInput;
		private var waigongInput:TextInput;
		private var waifangInput:TextInput;
		private var zhongjiInput:TextInput;
		private var neigongInput:TextInput;
		private var neifangInput:TextInput;
		private var liliangInput:TextInput;
		private var zhiliInput:TextInput;
		private var minjieInput:TextInput;
		private var jingshenInput:TextInput;
		private var tizhiInput:TextInput;
		private var qiannengTF:TextField;
		private var expBar:ProgressBar;

		private var btns:Array=[];
		private var qianneng:int;
		private var liliangC:int;
		private var zhiliC:int;
		private var minjieC:int;
		private var jingshenC:int;
		private var tizhiC:int;
		private var step:PetNumberSteper;

		private var _aptitudePanel:PetAptitudePanel;
		public var _petInfo:p_pet;
		private var propertyConfim:Button;
		private var fightNameBitmap:Bitmap;
		private var petReNameView:PetReNameView;

		public function PetInfoView() {
			initView();
		}

		private function initView():void {
			//----------------------------------------------
			// 宠物列表
			//----------------------------------------------
			petList=new PetList();
			petList.x=16;
			petList.y=8;
			addChild(petList);

			//----------------------------------------------
			// 宠物形象
			//----------------------------------------------
			avatarBg=ComponentUtil.createUIComponent(petList.x + petList.width + 3, 8, 372, 180);
			Style.setBorderSkin(avatarBg);
			addChild(avatarBg);

			var startX:int=12;
			var startY:int=10;
			var landing:int=16;
			typeTF=ComponentUtil.createTextField("", startX, startY, null, 100, 25, avatarBg);
			levelTF=ComponentUtil.createTextField("", startX, startY + landing, null, 100, 25, avatarBg);
			bandTF=ComponentUtil.createTextField("", startX, startY + landing * 2, null, 100, 25, avatarBg);
			colorTF=ComponentUtil.createTextField("", startX, startY + landing * 3, null, 100, 25, avatarBg);
			sexTF=ComponentUtil.createTextField("", startX, startY + landing * 4, null, 100, 25, avatarBg);

			startY=136;
			var tuiyiLink:TextField=ComponentUtil.createTextField("", startX, startY, null, 100, 25, avatarBg);
			tuiyiLink.mouseEnabled = true;
			tuiyiLink.htmlText=HtmlUtil.font(HtmlUtil.link("宠物退役", "", true), "#00ff00");
			tuiyiLink.addEventListener(TextEvent.LINK, onTuiyiLink);

			var fangshengLink:TextField=ComponentUtil.createTextField("", startX, startY + landing, null, 100, 25, avatarBg);
			fangshengLink.mouseEnabled = true;
			fangshengLink.htmlText=HtmlUtil.font(HtmlUtil.link("放生宠物", "", true), "#00ff00");
			fangshengLink.addEventListener(TextEvent.LINK, onFangshengLink);

			var avatarImgBg:ScaleShape=new ScaleShape(Style.getUIBitmapData(GameConfig.PET_UI, "petAvatarBg"));
			avatarImgBg.setScale9Grid(new Rectangle(10, 10,120, 104));
			avatarImgBg.x=100;
			avatarImgBg.y=27;
			avatarImgBg.width=172;
			avatarImgBg.height=128;
			avatarBg.addChild(avatarImgBg);
			
			var petBg:Bitmap = Style.getBitmap(GameConfig.PET_UI, "petBG");
			petBg.x = 125;
			petBg.y = 32;
			avatarBg.addChild(petBg);

			petAvater=new Avatar();
			petAvater.x=185;
			petAvater.y=128;
			avatarBg.addChild(petAvater);
			
			var fightSkin:ButtonSkin = Style.getButtonSkin("petBtn_1skin","petBtn_2skin","petBtn_3skin","",GameConfig.PET_UI);
			fightBtn = ComponentUtil.createUIComponent(280, 55, 80, 80,fightSkin);
			fightBtn.useHandCursor = fightBtn.buttonMode = true;
			fightBtn.addEventListener(MouseEvent.CLICK,onFightBtnClick);
			avatarBg.addChild(fightBtn);
			fightNameBitmap = Style.getBitmap(GameConfig.PET_UI,"name_cz");
			fightNameBitmap.x = fightBtn.width - fightNameBitmap.width >> 1;
			fightNameBitmap.y = fightBtn.height - fightNameBitmap.height >> 1;
			fightBtn.addChild(fightNameBitmap)

			//----------------------------------------------
			// 宠物属性
			//----------------------------------------------
			var nameTextFormat:TextFormat=new TextFormat("Tahoma", 12, 0xfffd4b);

			startY=avatarBg.y + avatarBg.height + 8;
			startX=avatarBg.x;
			landing=32;

			ComponentUtil.createTextField("名   称：", startX, startY, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			mingziInput=createTextInput(startX + 48, startY - 2, 158, 24, this);
			ComponentUtil.createTextField("寿   命：", startX, startY + landing, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			shoumingInput=createTextInput(startX + 48, startY + landing - 2, 158, 24, this);
			ComponentUtil.createTextField("生命值：", startX, startY + landing * 2, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			shengmingzhiInput=createTextInput(startX + 48, startY + landing * 2 - 2, 84, 24, this);
			ComponentUtil.createTextField("外   功：", startX, startY + landing * 3, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			waigongInput=createTextInput(startX + 48, startY + landing * 3 - 2, 84, 24, this);
			ComponentUtil.createTextField("外   防：", startX, startY + landing * 4, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			waifangInput=createTextInput(startX + 48, startY + landing * 4 - 2, 84, 24, this);

			var changeNameBtn:Button=ComponentUtil.createButton("改名", startX + 210, startY - 2, 50, 24, this);
			changeNameBtn.addEventListener(MouseEvent.CLICK, onUpgradeBtnClick);

			var addLifeBtn:Button=ComponentUtil.createButton("延寿", startX + 210, startY + landing - 2, 50, 24, this);
			addLifeBtn.addEventListener(MouseEvent.CLICK, onAddLifeBtnClick);

			startX=avatarBg.x + 132;
			startY=startY + landing * 2;

			ComponentUtil.createTextField("重   击：", startX, startY, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			zhongjiInput=createTextInput(startX + 48, startY - 2, 84, 24, this);
			ComponentUtil.createTextField("内   攻：", startX, startY + landing, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			neigongInput=createTextInput(startX + 48, startY + landing - 2, 84, 24, this);
			ComponentUtil.createTextField("内   防：", startX, startY + landing * 2, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			neifangInput=createTextInput(startX + 48, startY + landing * 2 - 2, 84, 24, this);

			startX=avatarBg.x + 264;
			startY=avatarBg.y + avatarBg.height + 8;
			landing=25;
			ComponentUtil.createTextField("力量：", startX, startY, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			liliangInput=createTextInput(startX + 36, startY - 2, 38, 24, this);
			ComponentUtil.createTextField("智力：", startX, startY + landing, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			zhiliInput=createTextInput(startX + 36, startY + landing - 2, 38, 24, this);
			ComponentUtil.createTextField("敏捷：", startX, startY + landing * 2, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			minjieInput=createTextInput(startX + 36, startY + landing * 2 - 2, 38, 24, this);
			ComponentUtil.createTextField("精神：", startX, startY + landing * 3, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			jingshenInput=createTextInput(startX + 36, startY + landing * 3 - 2, 38, 24, this);
			ComponentUtil.createTextField("体质：", startX, startY + landing * 4, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			tizhiInput=createTextInput(startX + 36, startY + landing * 4 - 2, 38, 24, this);
			qiannengTF=ComponentUtil.createTextField("潜能：", startX, startY + landing * 5 + 2, nameTextFormat, 100, 25, this);
			qiannengTF.filters=Style.textBlackFilter;

			for (var i:int=0; i < 10; i++) {
				var btnType:String=i < 5 ? "add" : "reduce";
				var bx:Number=int(i / 5) * 20 + startX + 76;
				var by:Number=int(i % 5) * landing + startY + 2;
				var addBtn:Button=createButton("", bx, by, this, btnType);
				addBtn.name=i + "";
				addBtn.addEventListener(MouseEvent.CLICK, addproperty);
				btns.push(addBtn);
			}
			step=new PetNumberSteper;
			this.addChild(step);

			var tuijianBtn:Button=ComponentUtil.createButton("推荐", startX + 62, startY + landing * 5, 45, 24, this);
			tuijianBtn.addEventListener(MouseEvent.CLICK, onTuijianBtnClick);
			tuijianBtn.visible=false;
			propertyConfim=ComponentUtil.createButton("确定", startX + 66, startY + landing * 5, 45, 24, this);
			propertyConfim.addEventListener(MouseEvent.CLICK, onQuedingBtnClick);


			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			tiao.width=360;
			tiao.x=avatarBg.x;
			tiao.y=startY + landing * 5 + 28;
			addChild(tiao);

			expBar=new ProgressBar();
			expBar.bgSkin=Style.getSkin("expBarBg", GameConfig.T1_UI, new Rectangle(5, 5, 108, 4));
			expBar.bar=Style.getBitmap(GameConfig.T1_UI, "expBar");
			expBar.padding=3;
			expBar.x=avatarBg.x + 2;
			expBar.y=tiao.y + 10;
			expBar.width=298;
			expBar.height=12;
			expBar.value=0;
			expBar.htmlText="0%";
			expBar.addEventListener(MouseEvent.ROLL_OVER,onExpBarRollOver);
			expBar.addEventListener(MouseEvent.ROLL_OUT,onExpBarRollOut);
			addChild(expBar);

			var chakanzizhiBtn:Button=ComponentUtil.createButton("查看资质", expBar.x + expBar.width + 3, tiao.y + 4, 66, 24, this);
			Style.setYellowButtonStyle(chakanzizhiBtn);
			chakanzizhiBtn.addEventListener(MouseEvent.CLICK, onChakanzizhiBtnClick);

			Dispatch.register(ModuleCommand.PET_CURRENT_INFO_CHANGE, setCurrentPetData);
			Dispatch.register(ModuleCommand.PET_INFO_UPDATE,onPetInfoUpdate);
			Dispatch.register(ModuleCommand.PET_LIST_CHANGED,onPetListUpdate);
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function onExpBarRollOver(event:MouseEvent):void{
			if(_petInfo){
				ToolTipManager.getInstance().show("经验："+_petInfo.exp+"/"+_petInfo.next_level_exp);
			}
		}
		
		private function onExpBarRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private function addedToStageHandler(event:Event):void{
			onPetListUpdate();
			setCurrentPetData();
		}
		
		private function onPetListUpdate():void{
			if(stage && petList){
				petList.update();
			}
		}
		
		private function onTuiyiLink(event:TextEvent):void {
			if (retireAbled == true) { //限制不能快速点
				if (_petInfo == null) {
					Alert.show("请选择要退役的宠物", "提示", null, null, "确定", "", null, false);
				} else {
					retireAbled=false;
					var vo:m_pet_refining_exp_tos=new m_pet_refining_exp_tos;
					vo.pet_id=_petInfo.pet_id;
					PetModule.getInstance().send(vo);
				}
			}
		}

		private function onFangshengLink(event:TextEvent):void {
			if (_petInfo == null) {
				Alert.show("请选择要放生的宠物", "提示", null, null, "确定", "", null, false);
				return;
			}
			var evt:ParamEvent=new ParamEvent(THROW_EVENT, _petInfo);
			this.dispatchEvent(evt);
		}

		private function onFightBtnClick(event:MouseEvent):void {
			if(PetDataManager.isBattle){
				if (GlobalObjectManager.getInstance().isDead == true) {
					Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召回宠物");
					return;
				}
				if (callBackAbled == false) {
					Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
					return;
				}
				var evt:ParamEvent=new ParamEvent(CALL_BACK_EVENT);
				this.dispatchEvent(evt);
				setCallBackAbledFalse(); //限制时间
				setSummonAbledFalse();
			}else{
				if (GlobalObjectManager.getInstance().isDead == true) {
					Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召唤宠物");
					return;
				}
				if (summonAbled == false) {
					Tips.getInstance().addTipsMsg("10秒后才能再次召唤宠物");
					return;
				}
				if (_petInfo == null) {
					Alert.show("请选择要出战的宠物", "提示", null, null, "确定", "", null, false);
					return;
				}
				var summonEvt:ParamEvent=new ParamEvent(SUMMON_EVENT, _petInfo.pet_id);
				this.dispatchEvent(summonEvt);
				setSummonAbledFalse(); //限制按钮时间
				setCallBackAbledFalse();
				if (PlayerGuideModule.getInstance().currentType == PlayerGuideModule.PET_WINDOW) {
					PetModule.getInstance().mediator.getPanel().closeWindow();
				}
			}
		}

		private function onUpgradeBtnClick(event:MouseEvent):void {
			if (_petInfo == null) {
				Tips.getInstance().addTipsMsg("请先选中要改名的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == _petInfo.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "改名", toCallBack, null, "召回宠物");
				return;
			}
			if (!petReNameView) {
				petReNameView=new PetReNameView();
				petReNameView.x=(1002 - petReNameView.width) * 0.5;
				petReNameView.y=(GlobalObjectManager.GAME_HEIGHT - petReNameView.height) * 0.5;
			}
			petReNameView.pet_id=_petInfo.pet_id;
			petReNameView.pet_name=_petInfo.pet_name;
			petReNameView.x=this.stage.mouseX + 30;
			petReNameView.y=this.stage.mouseY - 50;
			WindowManager.getInstance().openDialog(petReNameView);
		}
		
		private function toCallBack(e:MouseEvent=null):void {
			if (GlobalObjectManager.getInstance().isDead == true) {
				Dispatch.dispatch(ModuleCommand.TIPS, "死亡状态下不能召回宠物");
				return;
			}
			if (callBackAbled == false) {
				Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
				return;
			}
			var evt:ParamEvent=new ParamEvent(CALL_BACK_EVENT);
			this.dispatchEvent(evt);
			setCallBackAbledFalse(); //限制时间
			setSummonAbledFalse(); //限制按钮时间
		}

		private function onAddLifeBtnClick(event:MouseEvent):void {
			if (_petInfo == null) {
				Tips.getInstance().addTipsMsg("请先选中要延寿的宠物");
				return;
			}
			Alert.show("花费1元宝可延长宠物寿命200点\n也可在宠物商店购买延寿丹进行延寿", "提示", toAddLife, null, "确定", "", null, false, true, null);
		}
		
		private function toAddLife():void {
			var vo:m_pet_add_life_tos=new m_pet_add_life_tos;
			vo.pet_id=_petInfo.pet_id;
			vo.add_type=0;
			PetModule.getInstance().send(vo);
		}

		private function onTuijianBtnClick(event:MouseEvent):void {

		}

		private function onQuedingBtnClick(event:MouseEvent):void {
			if (liliangC == 0 && zhiliC == 0 && minjieC == 0 && jingshenC == 0 && tizhiC == 0) {
				Alert.show("属性点未分配", "提示", null, null, "确定", "取消", null, false);
				return;
			}
			var vo:m_pet_attr_assign_tos=new m_pet_attr_assign_tos;
			vo.pet_id=_petInfo.pet_id;
			var liliang:p_pet_attr_assign=new p_pet_attr_assign;
			var zhili:p_pet_attr_assign=new p_pet_attr_assign;
			var minjie:p_pet_attr_assign=new p_pet_attr_assign;
			var jingshen:p_pet_attr_assign=new p_pet_attr_assign;
			var tizhi:p_pet_attr_assign=new p_pet_attr_assign;
			liliang.assign_type=1;
			liliang.assign_value=liliangC;
			zhili.assign_type=2;
			zhili.assign_value=zhiliC;
			minjie.assign_type=3;
			minjie.assign_value=minjieC;
			jingshen.assign_type=4;
			jingshen.assign_value=jingshenC;
			tizhi.assign_type=5;
			tizhi.assign_value=tizhiC;
			vo.assign_info=[liliang, zhili, minjie, jingshen, tizhi];
			var evt:ParamEvent=new ParamEvent(PROPERTY_EVENT, vo);
			this.dispatchEvent(evt);
		}

		public function onPetInfoUpdate(pet:p_pet):void{
			if(stage && _petInfo && _petInfo.pet_id == pet.pet_id){
				setCurrentPetData();	
			}
		}
		
		public function setCurrentPetData():void {
			if(PetDataManager.currentPetInfo){
				_petInfo=PetDataManager.currentPetInfo;
				typeTF.htmlText=HtmlUtil.font("类型：" + PetConfig.getPetMsg(_petInfo.type_id), "#70dfe1");
				levelTF.htmlText=HtmlUtil.font("等级：" + _petInfo.level + "级", "#70dfe1");
				bandTF.htmlText=HtmlUtil.font(_petInfo.bind ? "绑定" : "不绑定", "#70dfe1");
				colorTF.htmlText=HtmlUtil.font("颜色：", "#70dfe1") + HtmlUtil.font(ItemConstant.COLOR_NAME[_petInfo.color], ItemConstant.COLOR_VALUES[_petInfo.color]);
				sexTF.htmlText=HtmlUtil.font(_petInfo.sex == 1 ? "性别：雄" : "性别：雌", "#70dfe1");
	
				updateSkin(_petInfo.type_id);
	
				mingziInput.text=_petInfo.pet_name;
				shoumingInput.text=String(_petInfo.life);
				shengmingzhiInput.text=String(_petInfo.max_hp);
				if(_petInfo.phy_attack_grow_add != 0){
					waigongInput.textField.htmlText=HtmlUtil.font(String(_petInfo.phy_attack - _petInfo.phy_attack_grow_add),"#ffb14b") +HtmlUtil.font("+" + _petInfo.phy_attack_grow_add,"#00ff00");
				}else{
					waigongInput.textField.htmlText=HtmlUtil.font(String(_petInfo.phy_attack),"#ffb14b");
				}
				if(_petInfo.phy_defence_grow_add != 0){
					waifangInput.textField.htmlText=HtmlUtil.font(String(_petInfo.phy_defence - _petInfo.phy_defence_grow_add),"#ffb14b") +HtmlUtil.font("+" + _petInfo.phy_defence_grow_add,"#00ff00");
				}else{
					waifangInput.textField.htmlText=HtmlUtil.font(String(_petInfo.phy_defence),"#ffb14b");
				}
				if(_petInfo.magic_attack_grow_add != 0){
					neigongInput.textField.htmlText=HtmlUtil.font(String(_petInfo.magic_attack - _petInfo.magic_attack_grow_add),"#ffb14b") +HtmlUtil.font("+" + _petInfo.magic_attack_grow_add,"#00ff00");
				}else{
					neigongInput.textField.htmlText=HtmlUtil.font(String(_petInfo.magic_attack),"#ffb14b");
				}
				if(_petInfo.magic_defence_grow_add != 0){
					neifangInput.textField.htmlText=HtmlUtil.font(String(_petInfo.magic_defence - _petInfo.magic_defence_grow_add),"#ffb14b") +HtmlUtil.font("+" + _petInfo.magic_defence_grow_add,"#00ff00");
				}else{
					neifangInput.textField.htmlText=HtmlUtil.font(String(_petInfo.magic_defence),"#ffb14b");
				}
				zhongjiInput.text=Math.floor(_petInfo.double_attack / 100) + "%";
	
				liliangInput.text=String(_petInfo.str);
				zhiliInput.text=String(_petInfo.int2);
				minjieInput.text=String(_petInfo.dex);
				jingshenInput.text=String(_petInfo.men);
				tizhiInput.text=String(_petInfo.con);
				qiannengTF.text="潜能：" + _petInfo.remain_attr_points;
	
				expBar.value=_petInfo.exp / _petInfo.next_level_exp;
				expBar.htmlText=HtmlUtil.font(int(_petInfo.exp/_petInfo.next_level_exp*100)+"%", "#FFFFFF");
	
				if (_aptitudePanel && _aptitudePanel.parent) {
					_aptitudePanel.update(_petInfo);
				}
				
				clearProperty();
				updateAttrBtn();
				updateStateBtn();
			}
		}

		private function updateSkin(typeId:int):void {
			var skin:p_skin=new p_skin();
			skin.skinid=PetConfig.getPetSkin(typeId);
			if (petAvater.skinData == null) {
				petAvater.initSkin(skin);
			} else {
				petAvater._bodyLayer.y=0;
				petAvater.updataSkin(skin);
			}
			petAvater.play(AvatarConstant.ACTION_STAND, 6, PetDataManager.getStandSpeed(skin.skinid));
			petAvater.visible=true;
			if (skin.skinid == 10086 || skin.skinid == 10089 || skin.skinid == 10090 || skin.skinid == 10092 || skin.skinid == 10108) {
				skin.skinid == 10108 ? petAvater._bodyLayer.y=66 : petAvater._bodyLayer.y=40;
			}
		}

		private function updateAttrBtn():void {
			if (qianneng <= 0) {
				for (var i:int=0; i < 5; i++) {
					btns[i].visible=false;
				}
				if (liliangC > 0 || zhiliC > 0 || minjieC > 0 || jingshenC > 0 || tizhiC > 0) {
					FlashObjectManager.setFlash(propertyConfim);
				}
			} else {
				for (i=0; i < 5; i++) {
					btns[i].visible=true;
				}
				FlashObjectManager.colseFlash(propertyConfim);
			}
			btns[5].visible=liliangC > 0;
			btns[6].visible=zhiliC > 0;
			btns[7].visible=minjieC > 0;
			btns[8].visible=jingshenC > 0;
			btns[9].visible=tizhiC > 0;
			for (i=0; i < btns.length; i++) {
				if (btns[i].visible == true) {
					if (propertyConfim.visible == false) {
						propertyConfim.visible=true;
					}
					return;
				}
			}
			propertyConfim.visible=false;
		}
		
		private function updateStateBtn():void{
			if (PetDataManager.isBattle == false) {
				fightNameBitmap.bitmapData = Style.getBitmap(GameConfig.PET_UI,"name_cz").bitmapData;
			} else {
				fightNameBitmap.bitmapData = Style.getBitmap(GameConfig.PET_UI,"name_sh").bitmapData;
			}
		}

		private function createButton(id:String, xValue:int, yValue:int, $parent:DisplayObjectContainer, type:String="add"):Button {
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
			$parent.addChild(btn);
			btn.visible = false;
			return btn;
		}

		private function addproperty(event:MouseEvent):void {
			var btn:Button=event.currentTarget as Button;
			var s:int=int(btn.name);
			var type:int=s % 5 + 1;
			var isAdd:Boolean=s < 5;
			if (isAdd == true && qianneng >= 30) {
				step.reset(btn.x + 20, btn.y, qianneng, type, changProperty);
			} else {
				changProperty(type, isAdd);
			}
		}

		private function changProperty(type:int, add:Boolean, value:int=1):void {
			switch (type) {
				case 1:
					if (add == true) {
						if (qianneng > 0) {
							liliangC+=value;
							qianneng-=value;
						}
					} else {
						if (liliangC > 0) {
							liliangC-=value;
							qianneng+=value;
						}
					}
					liliangInput.text=String(_petInfo.str + liliangC);
					break;
				case 2:
					if (add == true) {
						if (qianneng > 0) {
							zhiliC+=value;
							qianneng-=value;
						}
					} else {
						if (zhiliC > 0) {
							zhiliC-=value;
							qianneng+=value;
						}
					}
					zhiliInput.text=String(_petInfo.int2 + zhiliC);
					break;
				case 3:
					if (add == true) {
						if (qianneng > 0) {
							minjieC+=value;
							qianneng-=value;
						}
					} else {
						if (minjieC > 0) {
							minjieC-=value;
							qianneng+=value;
						}
					}
					minjieInput.text=String(_petInfo.dex + minjieC);
					break;
				case 4:
					if (add == true) {
						if (qianneng > 0) {
							jingshenC+=value;
							qianneng-=value;
						}
					} else {
						if (jingshenC > 0) {
							jingshenC-=value;
							qianneng+=value;
						}
					}
					jingshenInput.text=String(_petInfo.men + jingshenC);
					break;
				case 5:
					if (add == true) {
						if (qianneng > 0) {
							tizhiC+=value;
							qianneng-=value;
						}
					} else {
						if (tizhiC > 0) {
							tizhiC-=value;
							qianneng+=value;
						}
					}
					tizhiInput.text=String(_petInfo.con + tizhiC);
					break;
				default:
					break;
			}
			qiannengTF.text="潜能：" + qianneng;
			updateAttrBtn(); //设置加减按钮
		}

		private function onComfirmProperty(e:MouseEvent):void {
			if (liliangC == 0 && zhiliC == 0 && minjieC == 0 && jingshenC == 0 && tizhiC == 0) {
				Alert.show("属性点未分配", "提示", null, null, "确定", "取消", null, false);
				return;
			}
			var vo:m_pet_attr_assign_tos=new m_pet_attr_assign_tos;
			vo.pet_id=_petInfo.pet_id;
			var liliang:p_pet_attr_assign=new p_pet_attr_assign;
			var zhili:p_pet_attr_assign=new p_pet_attr_assign;
			var minjie:p_pet_attr_assign=new p_pet_attr_assign;
			var jingshen:p_pet_attr_assign=new p_pet_attr_assign;
			var tizhi:p_pet_attr_assign=new p_pet_attr_assign;
			liliang.assign_type=1;
			liliang.assign_value=liliangC;
			zhili.assign_type=2;
			zhili.assign_value=zhiliC;
			minjie.assign_type=3;
			minjie.assign_value=minjieC;
			jingshen.assign_type=4;
			jingshen.assign_value=jingshenC;
			tizhi.assign_type=5;
			tizhi.assign_value=tizhiC;
			vo.assign_info=[liliang, zhili, minjie, jingshen, tizhi];
			var evt:ParamEvent=new ParamEvent(PROPERTY_EVENT, vo);
			this.dispatchEvent(evt);
		}

		public function clearProperty():void {
			qianneng=_petInfo.remain_attr_points;
			liliangC=0;
			zhiliC=0;
			minjieC=0;
			jingshenC=0;
			tizhiC=0;
		}

		private function onChakanzizhiBtnClick(event:MouseEvent):void {
			if (!_aptitudePanel) {
				_aptitudePanel=new PetAptitudePanel();
			}
			_aptitudePanel.y=-59;
			_aptitudePanel.x=PetModule.getInstance().mediator.getPanel().width;
			this.addChild(_aptitudePanel);
			_aptitudePanel.update(_petInfo);
		}

		private function createTextInput(x:int, y:int, w:int, h:int, $parent:DisplayObjectContainer):TextInput {
			var itf:TextFormat=new TextFormat("Tahoma", 12, 0xffb14b);
			var textInput:TextInput=ComponentUtil.createTextInput(x, y, w, h, $parent);
			textInput.textField.defaultTextFormat=itf;
			textInput.leftPadding=4;
			textInput.enabled=false;
			$parent.addChild(textInput);
			return textInput;
		}
		
		//--------------------------------------
		//原版迁移的方法
		//--------------------------------------
		public function get list():List{
			return petList as List;
		}
		
		public function resetSummonBtn(useSummon:Boolean):void {
			updateStateBtn();
		}
		
		public function doEmpty():void{
			if(petList){
				petList.update();
			}
		}
		
		public function updateLife(pet_id:int, life:int):void {
			if (_petInfo == null || _petInfo.pet_id != pet_id) {
				return;
			} else {
				shoumingInput.text=String(life);
			}
		}
		
		public function updateName(vo:m_pet_change_name_toc):void {
			if(petList){
				petList.update();
			}
		}
	}
}