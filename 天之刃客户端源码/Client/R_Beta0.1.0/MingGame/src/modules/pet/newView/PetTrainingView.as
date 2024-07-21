package modules.pet.newView {
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.utils.ScaleShape;
	import com.net.connection.Connection;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.pet.PetDataManager;
	import modules.pet.PetMediator;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;
	import modules.pet.newView.items.PetList;
	import modules.pet.newView.items.PetTrainingModelPanel;
	import modules.system.SystemConfig;
	
	import proto.common.p_pet;
	import proto.common.p_pet_training_info;
	import proto.common.p_skin;
	import proto.line.m_pet_training_request_toc;
	import proto.line.m_pet_training_request_tos;

	public class PetTrainingView extends Sprite {
		private var petList:PetList;
		private var avatarBg:UIComponent;
		private var typeTF:TextField;
		private var levelTF:TextField;
		private var bandTF:TextField;
		private var colorTF:TextField;
		private var sexTF:TextField;
		private var petAvater:Avatar;
		private var educateTeam:NumericStepper;
		private var chargeTF:TextInput;
		private var educateBtn:UIComponent;
		private var modelTF:TextField;
		private var expTF:TextField;
		private var leaveTimeTF:TextField;
		private var expBar:ProgressBar;
		private var endBtn:UIComponent;
		private var tufeiBtn:UIComponent;
		private var moshiBtn:UIComponent;
		private var tufeiTF:TextField;
		
		private var hasInit:Boolean = false;
		
		private var _petTrainingInfo:p_pet_training_info;
		private var stateB:Sprite;
		private var stateA:Sprite;
		private var _petInfo:p_pet;

		public function PetTrainingView() {
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}

		private function addToStageHandler(event:Event):void {
			initView();
			onPetListUpdate();
			PetModule.getInstance().mediator.getTrainingInfo();
		}

		private function removedFromStageHandler(event:Event):void {
			stopTime();
		}

		private function initView():void {
			if(hasInit){
				return;
			}
			hasInit=true;
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
//			var tuiyiLink:TextField=ComponentUtil.createTextField("", startX, startY, null, 100, 25, avatarBg);
//			tuiyiLink.mouseEnabled=true;
//			tuiyiLink.htmlText=HtmlUtil.font(HtmlUtil.link("宠物退役", "", true), "#00ff00");
//			tuiyiLink.addEventListener(TextEvent.LINK, onTuiyiLink);
//
//			var fangshengLink:TextField=ComponentUtil.createTextField("", startX, startY + landing, null, 100, 25, avatarBg);
//			fangshengLink.mouseEnabled=true;
//			fangshengLink.htmlText=HtmlUtil.font(HtmlUtil.link("放生宠物", "", true), "#00ff00");
//			fangshengLink.addEventListener(TextEvent.LINK, onFangshengLink);
			
			grooveTF=ComponentUtil.createTextField("", startX, startY + landing, null, 200, 25, avatarBg);
			grooveTF.filters = Style.textBlackFilter;
			grooveTF.mouseEnabled=true;
//			grooveTF.htmlText=HtmlUtil.font(HtmlUtil.link("放生宠物", "", true), "#00ff00");
			grooveTF.addEventListener(TextEvent.LINK, onOpenRoomLink);

			var avatarImgBg:ScaleShape=new ScaleShape(Style.getUIBitmapData(GameConfig.T1_VIEWUI, "panelContentBg"));
			avatarImgBg.setScale9Grid(new Rectangle(10, 10, 270, 250));
			avatarImgBg.x=100;
			avatarImgBg.y=27;
			avatarImgBg.width=172;
			avatarImgBg.height=128;
			avatarBg.addChild(avatarImgBg);

			petAvater=new Avatar();
			petAvater.x=185;
			petAvater.y=128;
			avatarBg.addChild(petAvater);

			//--------------------------------------------
			//训练面板  状态1
			//--------------------------------------------
			stateA=new Sprite();
			addChild(stateA);

			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xfffd4b)
			var timeTF:TextField=ComponentUtil.createTextField("训练时间：", avatarBg.x + 108, avatarBg.y + avatarBg.height + 40, tf, 70, 25, stateA);
			timeTF.filters=Style.textBlackFilter
			educateTeam=new NumericStepper();
			educateTeam.minnum = 1;
			educateTeam.maxnum = 24;
			educateTeam.width=68;
			educateTeam.height = 25;
			educateTeam.x=avatarBg.x + 170;
			educateTeam.y=avatarBg.y+avatarBg.height + 39;
			educateTeam.value = 1;
			educateTeam.addEventListener(Event.CHANGE,educateTeamChangeHandler);
			stateA.addChild(educateTeam);
			ComponentUtil.createTextField("小时", educateTeam.x + educateTeam.width + 4, timeTF.y, tf, 70, 25, stateA).filters=Style.textBlackFilter;

			ComponentUtil.createTextField("费    用：", timeTF.x, timeTF.y + 30, tf, 70, 25, stateA).filters=Style.textBlackFilter;
			chargeTF=createTextInput(educateTeam.x, educateTeam.y + 30, 100, 24, stateA);

			var educateBtnSkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			educateBtn=ComponentUtil.createUIComponent(avatarBg.x + 144, avatarBg.y + avatarBg.height + 108, 80, 80, educateBtnSkin);
			educateBtn.useHandCursor=educateBtn.buttonMode=true;
			educateBtn.addEventListener(MouseEvent.CLICK, onEducateBtnClick);
			stateA.addChild(educateBtn);
			var educateNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_practice");
			educateNameBitmap.x=educateBtn.width - educateNameBitmap.width >> 1;
			educateNameBitmap.y=educateBtn.height - educateNameBitmap.height >> 1;
			educateBtn.addChild(educateNameBitmap)

			var noteTF:TextField=ComponentUtil.createTextField("", avatarBg.x + 2, avatarBg.y + avatarBg.height + 150, null, 130, 50, stateA);
			noteTF.htmlText=HtmlUtil.fontBr("说明：", "#59ecf4") + HtmlUtil.fontBr("宠物训练时也可以出战", "#64DF35");

			var helpSkin:ButtonSkin=Style.getButtonSkin("petHelp_1skin", "petHelp_2skin", "petHelp_3skin", "", GameConfig.PET_UI);
			var helpButton:UIComponent=ComponentUtil.createUIComponent(526, 340, 29, 31, helpSkin);
			helpButton.useHandCursor=helpButton.buttonMode=true;
			helpButton.addEventListener(MouseEvent.CLICK, skillHelpHandler);
			addChild(helpButton);

			//--------------------------------------------
			//训练面板  状态2
			//--------------------------------------------

			stateB=new Sprite();
			addChild(stateB);
			stateB.visible=false;

			modelTF=ComponentUtil.createTextField("", avatarBg.x + 108, avatarBg.y + avatarBg.height + 12, null, 200, 25, stateB);
			modelTF.filters=Style.textBlackFilter;

			expTF=ComponentUtil.createTextField("", modelTF.x, modelTF.y + 22, null, 200, 25, stateB);
			expTF.filters=Style.textBlackFilter;

			leaveTimeTF=ComponentUtil.createTextField("", expTF.x, expTF.y + 22, null, 200, 25, stateB);
			leaveTimeTF.filters=Style.textBlackFilter;

			expBar=new ProgressBar();
			expBar.bgSkin=Style.getSkin("expBarBg", GameConfig.T1_UI, new Rectangle(5, 5, 108, 4));
			expBar.bar=Style.getBitmap(GameConfig.T1_UI, "expBar");
			expBar.padding=3;
			expBar.x=avatarBg.x + 43;
			expBar.y=leaveTimeTF.y + 20;
			expBar.width=282;
			expBar.height=12;
			expBar.value=0.5;
			//expBar.htmlText="50%";
			stateB.addChild(expBar);
			
			var endBtnSkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			endBtn=ComponentUtil.createUIComponent(avatarBg.x + 30, avatarBg.y + avatarBg.height + 108, 80, 80, endBtnSkin);
			endBtn.useHandCursor=educateBtn.buttonMode=true;
			endBtn.addEventListener(MouseEvent.CLICK, onEndBtnClick);
			stateB.addChild(endBtn);
			var endNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_jsxl");
			endNameBitmap.x=endBtn.width - endNameBitmap.width >> 1;
			endNameBitmap.y=endBtn.height - endNameBitmap.height >> 1;
			endBtn.addChild(endNameBitmap);
			
			var tufeiBtnSkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			tufeiBtn=ComponentUtil.createUIComponent(avatarBg.x + 135, avatarBg.y + avatarBg.height + 108, 80, 80, tufeiBtnSkin);
			tufeiBtn.useHandCursor=educateBtn.buttonMode=true;
			tufeiBtn.addEventListener(MouseEvent.CLICK, onTufeiBtnClick);
			stateB.addChild(tufeiBtn);
			var tufeiNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_tfmj");
			tufeiNameBitmap.x=tufeiBtn.width - tufeiNameBitmap.width >> 1;
			tufeiNameBitmap.y=tufeiBtn.height - tufeiNameBitmap.height >> 1;
			tufeiBtn.addChild(tufeiNameBitmap);

			var moshiBtnSkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			moshiBtn=ComponentUtil.createUIComponent(avatarBg.x + 240, avatarBg.y + avatarBg.height + 108, 80, 80, moshiBtnSkin);
			moshiBtn.useHandCursor=educateBtn.buttonMode=true;
			moshiBtn.addEventListener(MouseEvent.CLICK, onMoshiBtnClick);
			stateB.addChild(moshiBtn);
			var moshiNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_ggms");
			moshiNameBitmap.x=moshiBtn.width - moshiNameBitmap.width >> 1;
			moshiNameBitmap.y=moshiBtn.height - moshiNameBitmap.height >> 1;
			moshiBtn.addChild(moshiNameBitmap);

			tufeiTF=ComponentUtil.createTextField("", avatarBg.x + 106, avatarBg.y + 172, null, 200, 25, stateB);
			tufeiTF.filters=Style.textBlackFilter;
			
			Dispatch.register(ModuleCommand.PET_TRAINING_INFO_UPDATE,onTrainingInfoUpdate);
			Dispatch.register(ModuleCommand.PET_CURRENT_INFO_CHANGE, setCurrentPetData);
		}
		
		private function onTrainingInfoUpdate():void{
			setCurRoom();
			setCurrentPetData();
		}
		
		private function onPetListUpdate():void{
			if(stage && petList){
				petList.update();
			}
		}
		
		public function update():void {

		}
		
		public function educateTeamChangeHandler(event:Event):void{
			updateMoney();
		}
		
		public function updateMoney():void{
			if(PetDataManager.currentPetInfo){
				chargeTF.text = MoneyTransformUtil.silverToOtherString(Math.pow(PetDataManager.currentPetInfo.level,1.4) * educateTeam.value); 
			}else{
				chargeTF.text = "";
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
				
				_petTrainingInfo = getPetTrainingInfoByID(PetDataManager.currentPetInfo.pet_id);
				if(_petTrainingInfo){
					stateA.visible = false;
					stateB.visible = true;
					updateTime(_petTrainingInfo.training_start_time,_petTrainingInfo.training_end_time);
					modelTF.htmlText=HtmlUtil.font("训练模式：","#fffd4b")+HtmlUtil.font(getModelTxt(_petTrainingInfo.training_mode),"#23dc45");
					expTF.htmlText=HtmlUtil.font("当前获得经验：","#fffd4b")+HtmlUtil.font(String(_petTrainingInfo.total_get_exp),"#23dc45");
				}else{
					stateB.visible = false;
					stateA.visible = true;
					updateMoney();
				}
			}
		}
		
		private function getModelTxt(value:int):String{
			var s:String = "";
			switch(value){
				case 1:s="正常（100%经验）";break;
				case 2:s="加强（120%经验）";break;
				case 3:s="VIP1(150%经验)";break;
				case 4:s="VIP2(180%经验)";break;
				case 5:s="VIP3(200%经验)";break;
			}
			return s;
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
		
		private var startTime:int;
		private var endTime:int;
		private function updateTime($startTime:int,$endTime:int):void{
			startTime = $startTime;
			endTime = $endTime;
			LoopManager.addToSecond(this,updateTimeStr);
		}
		
		private function stopTime():void{
			LoopManager.removeFromSceond(this);
		}
		
		private function updateTimeStr():void{
			var time:int = Math.max(endTime - SystemConfig.serverTime,0);
			leaveTimeTF.htmlText = HtmlUtil.font("剩余训练时间："+DateFormatUtil.formatTime(time),"#fffd4b");
			expBar.value = 1 - time/(endTime - startTime);
		}
		
		private function getPetTrainingInfoByID(petId:int):p_pet_training_info{
			if(PetDataManager.petTrainingInfoDic.hasOwnProperty(petId)){
				return PetDataManager.petTrainingInfoDic[petId];
			}
			return null;
		}
		
		private function onEducateBtnClick(event:MouseEvent):void {
			if(PetDataManager.currentPetInfo != null){
				var vo:m_pet_training_request_tos = new m_pet_training_request_tos();
				vo.op_type = 3;
				vo.pet_id = PetDataManager.currentPetInfo.pet_id;
				vo.training_hours = educateTeam.value;
				Connection.getInstance().sendMessage(vo);
			}else{
				Tips.getInstance().addTipsMsg("请先选中需要训练的宠物");
			}
		}

		private function onEndBtnClick(event:MouseEvent):void {
			var vo:m_pet_training_request_tos = new m_pet_training_request_tos();
			vo.op_type = 4;
			vo.pet_id = PetDataManager.currentPetInfo.pet_id;
			Connection.getInstance().sendMessage(vo);
		}

		private function onTufeiBtnClick(event:MouseEvent):void {
			var vo:m_pet_training_request_tos = new m_pet_training_request_tos();
			vo.op_type = 5;
			vo.pet_id = PetDataManager.currentPetInfo.pet_id;
			Connection.getInstance().sendMessage(vo);
		}
		
		private var _changeModel:PetTrainingModelPanel
		private var grooveTF:TextField;
		private function onMoshiBtnClick(event:MouseEvent):void {
			if(!_changeModel){
				_changeModel = new PetTrainingModelPanel();
			}
			_changeModel.update(_petTrainingInfo.training_mode);
			WindowManager.getInstance().popUpWindow(_changeModel);
			WindowManager.getInstance().centerWindow(_changeModel);
		}

		private function skillHelpHandler(event:MouseEvent):void {

		}

		private function createTextInput(x:int, y:int, w:int, h:int, $parent:DisplayObjectContainer):TextInput {
			var itf:TextFormat=new TextFormat("Tahoma", 12, 0xffb14b);
			var textInput:TextInput=ComponentUtil.createTextInput(x, y, w, h, $parent);
			textInput.textField.defaultTextFormat=itf;
			textInput.leftPadding=8;
			textInput.enabled=false;
			$parent.addChild(textInput);
			return textInput;
		}
		
		public function setCurRoom():void{
			if(PetDataManager.petTrainingInfo.length == PetDataManager.trainingRoom && PetDataManager.trainingRoom < 5){
				var str:String = HtmlUtil.font("训练位："+PetDataManager.petTrainingInfo.length+"/"+PetDataManager.trainingRoom+"（可同时训练"+PetDataManager.trainingRoom+"次宠物）  ","#fffd4b");
				grooveTF.htmlText = str + HtmlUtil.font(HtmlUtil.link("开启更多训练位","",true),"#00ff00");
			}else{
				grooveTF.htmlText = HtmlUtil.font("训练位："+PetDataManager.petTrainingInfo.length+"/"+PetDataManager.trainingRoom+"（可同时训练"+PetDataManager.trainingRoom+"次宠物）  ","#fffd4b");
			}
		}

		private function onTuiyiLink(event:TextEvent):void {

		}
		
		private var roomCost:Array = [0,0,20,50,100];
		private function onOpenRoomLink(event:TextEvent):void {
			Alert.show("你确定要花费"+roomCost[PetDataManager.trainingRoom+1]+"元宝开启第"+PetDataManager.trainingRoom+1+"个宠物训练空位吗？","提示",openRoomYesHandler);
		}
		
		private function openRoomYesHandler():void{
			var vo:m_pet_training_request_tos = new m_pet_training_request_tos();
			vo.op_type = 2;
			Connection.getInstance().sendMessage(vo);
		}
	}
}