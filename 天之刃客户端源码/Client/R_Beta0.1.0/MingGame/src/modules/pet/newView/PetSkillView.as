package modules.pet.newView {
	import com.common.FilterCommon;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.ButtonSkin;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.PetSkillVO;
	import modules.pet.newView.items.PetGoodsItem;
	import modules.pet.newView.items.PetList;
	import modules.pet.newView.items.PetListItemRander;
	import modules.pet.newView.items.PetSkillLearnItem;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_pet;
	import proto.common.p_pet_skill;
	import proto.line.m_pet_add_skill_grid_tos;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_forget_skill_tos;
	import proto.line.m_pet_learn_skill_toc;
	import proto.line.m_pet_learn_skill_tos;

	public class PetSkillView extends Sprite {
		public static const SKILL_COLUMN:int=6;
		public static const SKILL_ROW:int=2;
		public static const SUPER_SKILL_COUNT:int=4;

		private static const succRate:Array=[100, 50, 40, 30, 28, 26, 25, 23, 22, 20, 20];
		private static const skillType:Array=[[62123101, 12], [62111201, 12], [62111301, 12], [62123102, 12], [62123202, 12], [62123302, 12], [62123103, 12], [62123203, 12], [62123303, 12], [62123104, 12], [62123204, 12], [62123304, 12], [62123105, 12], [62123205, 12], [62123305, 12], [62111401, 12], [62123402, 12], [62123403, 12], [62123404, 12], [62123405, 12], [62113101, 13], [62113201, 13], [62113301, 13], [62113102, 13], [62113202, 13], [62113302, 13], [62113103, 13], [62113203, 13], [62113303, 13], [62113104, 13], [62113204, 13], [62113304, 13], [62113105, 13], [62113205, 13], [62113305, 13], [62113401, 13], [62113402, 13], [62113403, 13], [62113404, 13], [62113405, 13], [61131101, 11], [61131201, 11], [61131301, 11], [61132101, 11], [61132201, 11], [61132301, 11], [61131401, 11], [61132401, 11], [61331101, 1], [61331201, 1], [61331301, 1], [61332101, 1], [61332201, 1], [61332301, 1], [61331401, 1], [61332401, 1], [63236101, 2], [63236201, 2], [63236301, 2]];

		private var petList:PetList;
		private var skillContainer:Sprite;
		private var superSkillCotainer:Sprite;
		private var successRate:TextInput;
		private var studyMoney:TextInput;
		private var skillBookDataGrid:DataGrid;
		private var buyBookNoticeTxt:TextField;

		private var hasInit:Boolean=false;
		private var skillItems:Vector.<PetSkillLearnItem>;
		private var superSkillItems:Vector.<PetSkillLearnItem>;

		private var currentBookItem:BaseItemVO;
		private var selectedBorder:Bitmap;
		private var theSelected:PetSkillLearnItem;
		public function PetSkillView() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}

		private function addToStageHandler(event:Event):void {
			initView();
			update();
			onPetListUpdate();
		}

		private function initView():void {
			if (hasInit) {
				return;
			}
			hasInit=true;
			petList=new PetList();
			petList.x=15;
			petList.y=8;
			addChild(petList);

			var skillBG:UIComponent=ComponentUtil.createUIComponent(petList.x + petList.width + 2, petList.y, 375, 184);
			Style.setBorderSkin(skillBG);
			addChild(skillBG);

			createSkillLabel("", 7, 4, skillBG);
			createSkillLabel("", 7, 95, skillBG);
			var jinengBitmap:Bitmap = Style.getBitmap(GameConfig.PET_UI,"name_jineng");
			jinengBitmap.x = 9;
			jinengBitmap.y = 27;
			skillBG.addChild(jinengBitmap);
			
			var shenjiBitmap:Bitmap = Style.getBitmap(GameConfig.PET_UI,"name_shenji");
			shenjiBitmap.x = 9;
			shenjiBitmap.y = 118;
			skillBG.addChild(shenjiBitmap);

			skillContainer=new Sprite();
			skillContainer.x=46;
			skillContainer.y=5;
			skillBG.addChild(skillContainer);

			var size:int=SKILL_COLUMN * SKILL_ROW;
			skillItems=new Vector.<PetSkillLearnItem>;
			for (var i:int=1; i <= size; i++) {
				skillItems.push(createSkillItem(0, 0, skillContainer));
			}
			LayoutUtil.layoutGrid(skillContainer, SKILL_COLUMN, 10, 1);

			superSkillCotainer=new Sprite();
			superSkillCotainer.x=skillContainer.x;
			superSkillCotainer.y=skillContainer.y + skillContainer.height + 27;
			skillBG.addChild(superSkillCotainer);

			superSkillItems=new Vector.<PetSkillLearnItem>;
			for (i=1; i <= SUPER_SKILL_COUNT; i++) {
				superSkillItems.push(createSkillItem(0, 0, superSkillCotainer));
			}
			LayoutUtil.layoutHorizontal(superSkillCotainer, 10);

			var clearPetSkillsText:TextField=ComponentUtil.createTextField("", skillBG.x, skillBG.y + skillBG.height + 5, null, 200, 20, this);
			clearPetSkillsText.mouseEnabled=true;
			clearPetSkillsText.filters=FilterCommon.FONT_BLACK_FILTERS;
			clearPetSkillsText.htmlText=HtmlUtil.link(HtmlUtil.font("遗忘所有普通技能", "#00ff00"), "clearAll", true) + "     " + HtmlUtil.link(HtmlUtil.font("遗忘选择技能", "#00ff00"), "clearselect", true);
			clearPetSkillsText.addEventListener(TextEvent.LINK, clearPetSkillHandler);

			successRate=createTextInput("成功率：", skillBG.x + 45, clearPetSkillsText.y + 30);
			studyMoney=createTextInput("费   用：", skillBG.x + 45, successRate.y + 30);
			studyMoney.text = "5两"

			var studySkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			var studyButton:UIComponent=ComponentUtil.createUIComponent(skillBG.x + 72, studyMoney.y + 30, 84, 78, studySkin);
			studyButton.useHandCursor=studyButton.buttonMode=true;
			studyButton.addEventListener(MouseEvent.CLICK, studySkillHandler);
			addChild(studyButton);
			var studyNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_xx");
			studyNameBitmap.x=studyButton.width - studyNameBitmap.width >> 1;
			studyNameBitmap.y=studyButton.height - studyNameBitmap.height >> 1;
			studyButton.addChild(studyNameBitmap)

			var helpSkin:ButtonSkin=Style.getButtonSkin("petHelp_1skin", "petHelp_2skin", "petHelp_3skin", "", GameConfig.PET_UI);
			var helpButton:UIComponent=ComponentUtil.createUIComponent(studyButton.x + 105, studyButton.y + 50, 29, 31, helpSkin);
			helpButton.useHandCursor=helpButton.buttonMode=true;
			helpButton.addEventListener(MouseEvent.CLICK, skillHelpHandler);
			addChild(helpButton);

			skillBookDataGrid=new DataGrid();
			skillBookDataGrid.list.listSkin = Style.getBorderListSkin();
			skillBookDataGrid.list.autoJustSize = true;
			Style.setBorderSkin(skillBookDataGrid);
			skillBookDataGrid.x=clearPetSkillsText.x + clearPetSkillsText.width + 15;
			skillBookDataGrid.y=clearPetSkillsText.y;
			skillBookDataGrid.itemHeight=46;
			skillBookDataGrid.itemRenderer=PetGoodsItem;
			skillBookDataGrid.width=155;
			skillBookDataGrid.height=170;
			skillBookDataGrid.addColumn("技能书", skillBookDataGrid.width);
			skillBookDataGrid.list.addEventListener(ItemEvent.ITEM_CLICK, onSkillItemClick);
			addChild(skillBookDataGrid);

			buyBookNoticeTxt=ComponentUtil.createTextField("", 6, 23, Style.textFormat, 146, 100, skillBookDataGrid);
			buyBookNoticeTxt.htmlText="你的背包中没有宠物技能\n书,可到<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>宠物驯养师</u></font></a>或<a href=\"event:goto_pet_shop\"><font color='#00FF00'><u>宠物\n商城</u></font></a>购买";
			buyBookNoticeTxt.addEventListener(TextEvent.LINK, gotoPetNpc);
			buyBookNoticeTxt.mouseEnabled=true;
			
			Dispatch.register(ModuleCommand.PET_CURRENT_INFO_CHANGE, update);
			Dispatch.register(ModuleCommand.PET_INFO_UPDATE,onPetInfoUpdate);
			Dispatch.register(ModuleCommand.PET_SKILLS_UPDATE,onPetSkillUpdate);
			Dispatch.register(ModuleCommand.PET_LIST_CHANGED,onPetListUpdate);
		}
	
		private function onPetListUpdate():void{
			if(stage && petList){
				petList.update();
			}
		}
		
		private function studySkillHandler(e:MouseEvent):void {
			if (!PetDataManager.currentPetInfo) {
				Tips.getInstance().addTipsMsg("请先选择要学习技能的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == PetDataManager.currentPetInfo.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "提悟", exeCallBack, null, "召回宠物");
				return;
			}
			currentBookItem = skillBookDataGrid.list.selectedItem as BaseItemVO;
			if (!currentBookItem) {
				Tips.getInstance().addTipsMsg("请先选择要学习的技能");
				return;
			}
			
			//			vo.pet_id=headerContent.selectedItem.pet_id;
			var type_id:int=currentBookItem.typeId;
			var skill:SkillVO=SkillDataManager.getSkill(SkillDataManager.skillBooks[type_id]);
			if (skill == null) {
				Tips.getInstance().addTipsMsg("框中的物品必须为宠物技能书");
				return;
			}
			var oldSameSkill:String=checkSameSkill(skill.sid);
			if (oldSameSkill != "") {
				var param:Array=[PetDataManager.currentPetInfo.pet_id, skill.sid];
				var str:String="学习该技能将替换已有的<font color=\"#00FF00\">【" + oldSameSkill + "】</font>技能";
				Alert.show(str, "提示", toLearnSkill, null, "确定", "取消", param, true, false, null);
				return;
			} else if (PetDataManager.currentPetInfo.skills.length >= PetDataManager.currentPetInfo.max_skill_grid) {
				Tips.getInstance().addTipsMsg("宠物可学技能栏已满，请在技能界面扩展技能栏");
				return;
			}
			toLearnSkill(PetDataManager.currentPetInfo.pet_id, skill.sid);
		}
		
		private function exeCallBack():void {
			if (PetInfoView.callBackAbled == false) {
				Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
				return;
			}
			var vo:m_pet_call_back_tos=new m_pet_call_back_tos;
			vo.pet_id=PetDataManager.thePet.pet_id;
			Connection.getInstance().sendMessage(vo);
			PetInfoView.setSummonAbledFalse(); //限制按钮时间
			PetInfoView.setCallBackAbledFalse();
		}
		
		private function toLearnSkill(pet_id:int, skill_id:int):void {
			var vo:m_pet_learn_skill_tos=new m_pet_learn_skill_tos;
			vo.pet_id=pet_id;
			vo.skill_id=skill_id;
			PetModule.getInstance().send(vo);
		}
		
		private function onSkillItemClick(event:ItemEvent):void{
			currentBookItem = BaseItemVO(event.selectItem);
			updatesuccessRate();
		}

		private function gotoPetNpc(e:TextEvent):void {
			if (e.text == "goto_pet_shop") {
				Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP);
			}
			if (e.text == "goto_pet_npc") {
				ChatModule.getInstance().chat.gotoPetNpc();
			}
		}

		private function skillHelpHandler(event:MouseEvent):void {

		}

		private function clearPetSkillHandler(event:TextEvent):void {
			if (event.text == "clearAll") {
				if (!PetDataManager.currentPetInfo) {
					Tips.getInstance().addTipsMsg("请先选择要遗忘技能的宠物");
					return;
				}
				Alert.show("确定要花费3锭银子遗忘所有技能吗?", "遗忘技能", forgetSkill, null, "确定", "取消", [PetDataManager.currentPetInfo.pet_id, 0]);
			} else {
				if (!PetDataManager.currentPetInfo) {
					Tips.getInstance().addTipsMsg("请先选择要遗忘技能的宠物");
					return;
				}
				if (theSelected) { //有没有选中的技能
					if (theSelected.data) {
						Alert.show("确定要花费1锭20两银子遗忘技能【" + theSelected.data.skill.name + "】吗?", "遗忘技能", forgetSkill, null, "确定", "取消", [PetDataManager.currentPetInfo.pet_id, theSelected.data.skill.sid]);
					}
				} else {
					Tips.getInstance().addTipsMsg("请先选择要遗忘的技能");
				}
			}
		}
		
		private function forgetSkill(pet_id:int, skill_id:int):void {
			var vo:m_pet_forget_skill_tos=new m_pet_forget_skill_tos;
			vo.pet_id=pet_id;
			vo.skill_id=skill_id;
			Connection.getInstance().sendMessage(vo);
		}

		private function createTextInput(proName:String, startX:int, startY:int):TextInput {
			var title:TextField=ComponentUtil.createTextField(proName, startX, startY, Style.themeTextFormat, NaN, 20, this);
			title.textColor=0xfffd4b;
			title.filters=FilterCommon.FONT_BLACK_FILTERS;
			title.width=title.textWidth + 4;
			var textInput:TextInput=ComponentUtil.createTextInput(startX + title.width + 5, startY, 80, 25, this);
			textInput.textField.textColor=0xffb14b;
			textInput.enabled=false;
			textInput.leftPadding=8;
			return textInput;
		}

		private function createSkillItem(x:int, y:int, parent:DisplayObjectContainer):PetSkillLearnItem {
			var skillItem:PetSkillLearnItem=new PetSkillLearnItem();
			skillItem.x=x;
			skillItem.y=y;
			skillItem.addEventListener(MouseEvent.CLICK,clickSkillHandler);
			parent.addChild(skillItem);
			return skillItem;
		}

		private function createSkillLabel(name:String, x:int, y:int, parent:DisplayObjectContainer):void {
			var nameBG:Bitmap=Style.getBitmap(GameConfig.PET_UI, "petSkillNameBG");
			nameBG.x=x;
			nameBG.y=y;
			parent.addChild(nameBG);
			var nameText:TextField=ComponentUtil.createTextField(name, x + 3, y + 21, null, 20, 35, parent);
			nameText.multiline=true;
			nameText.filters=FilterCommon.FONT_BLACK_FILTERS;
		}

		private function clickSkillHandler(e:MouseEvent):void {
			var tar:PetSkillLearnItem=e.target as PetSkillLearnItem;
			if (theSelected != tar && tar.data != null) {
				theSelected=tar;
				if(selectedBorder == null){
					selectedBorder = Style.getBitmap(GameConfig.T1_VIEWUI, "skillBorder");
				}
				if (selectedBorder.parent != null) {
					selectedBorder.parent.removeChild(selectedBorder);
				}
				selectedBorder.x=-4;
				selectedBorder.y=-4;
				theSelected.addChild(selectedBorder);
			}
		}
		
		private function onDragSkill(event:MouseEvent):void {

		}
		
		private function onPetInfoUpdate(pet:p_pet):void{
			update();	
		}
		
		private function onPetSkillUpdate(pet:p_pet):void{
			if(PetDataManager.currentPetInfo && PetDataManager.currentPetInfo.pet_id == pet.pet_id){
				update();
			}
		}
		
		public function update():void {
			if(stage == null)return;
			for (var i:int=0; i < 12; i++) {
				skillItems[i].data=null;
				skillItems[i].buttonMode=false;
				skillItems[i].closeSkill(true);
				skillItems[i].removeEventListener(MouseEvent.MOUSE_DOWN, onDragSkill);
				if (selectedBorder && skillItems[i].contains(selectedBorder) == true) {
					selectedBorder.parent.removeChild(selectedBorder);
				}
			}
			if(PetDataManager.currentPetInfo){
				for (i=0; i < PetDataManager.currentPetInfo.max_skill_grid; i++) {
					skillItems[i].closeSkill(false);
				}
				if(i <= 11){
					skillItems[i].addOpenText();
				}
				var petSkills:Array=PetDataManager.currentPetInfo.skills;
				for (i=0; i < petSkills.length; i++) {
					var ps:p_pet_skill=petSkills[i];
					var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
					var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
					skillItems[i].data=petSkill;
					if (petSkill.skill_type < 10 || petSkill.skill_type > 100) { //群攻技能或者神技并且是出战宠物的技能，才能拖
						skillItems[i].addEventListener(MouseEvent.MOUSE_DOWN, onDragSkill);
					}
				}
			}
			updateSkillBookList();
			updatesuccessRate();
		}

		public function updateInfo(vo:p_pet):void {
			
		}
		
		public function updateSkillBookList():void {
			if(stage == null)return;
			var goods:Array=PackManager.getInstance().getItemsByPackId(1);

			var len:int=goods.length;
			var books:Array=[];
			for (var i:int=0; i < len; i++) {
				var item:BaseItemVO=goods[i] as BaseItemVO;
				if (item != null && item.typeId >= 10305101 && item.typeId <= 10305330) {
					books.push(item);
				}
			}
			books.sortOn("typeId");
			var oldtype:int=0;
			var oldItem:BaseItemVO;
			var arr3:Array=new Array();
			for (i=0; i < books.length; i++) {
				item=books[i] as BaseItemVO;
				if (item.typeId == oldtype) {
					oldItem.num+=item.num;
				} else {
					oldItem=ItemLocator.getInstance().getObject(item.typeId);
					oldItem.num=item.num;
					arr3.push(oldItem);
				}
			}
			skillBookDataGrid.dataProvider=arr3;
			if (arr3.length <= 0) {
				buyBookNoticeTxt.visible=true;
			} else {
				buyBookNoticeTxt.visible=false;
			}
		}

		private function updatesuccessRate():void {
			if (currentBookItem == null) {
				successRate.text="";
				return;
			}
			var type_id:int=currentBookItem.typeId;
			//61131401"
			var skill:SkillVO=SkillDataManager.getSkill(61131401);
			if (skill == null) {
				successRate.text="";
				return;
			}
			if (checkSameSkill(skill.sid) != "") { //要顶替技能就100%
				successRate.text="100%";
				return;
			}
			var skill_type:int=getSkillType(skill.sid);
			if (skill_type < 10) { //skill_type < 10就是群攻技能
				successRate.text="100%";
				return;
			}
			var learnedSkillNum:int=PetDataManager.currentPetInfo.skills.length;
			for (var i:int=0; i < 12; i++) {
				if (skillItems[i].data == null)
					break;
				var skillTmp:PetSkillVO=skillItems[i].data as PetSkillVO;
				if (skillTmp.skill_type < 10) { //在已学技能中排除，群攻的技能
					learnedSkillNum--;
				}
			}
			if (learnedSkillNum >= 0 && learnedSkillNum <= succRate.length) {
				successRate.text=succRate[learnedSkillNum] + "%";
			}
		}

		//检测是否顶替已有技能
		private function checkSameSkill(skill_id:int):String {
			var sidStr:String=skill_id.toString();
			var temStr:String;
			for (var i:int=0; i < 12; i++) {
				var skillTmp:PetSkillVO=skillItems[i].data as PetSkillVO;
				if (skillItems[i].data == null) {
					break;
				}
				temStr=skillTmp.skill.sid.toString();
				if (sidStr.length == temStr.length) {
					if (sidStr.substr(0, 5) == temStr.substr(0, 5) && sidStr.substr(6, 2) == temStr.substr(6, 2)) {
						return skillTmp.skill.name;
					}
				}
				//特殊判断助力技能，因为只有这个不符合规则
				if (skill_id == 62123101 || skill_id == 62111201 || skill_id == 62111301 || skill_id == 62111401) {
					if (skillTmp.skill.sid == 62123101 || skillTmp.skill.sid == 62111201 || skillTmp.skill.sid == 62111301 || skillTmp.skill.sid == 62111401) {
						return skillTmp.skill.name;
					}
				}
				//特殊处理痛击和猛击
				if (skill_id == 61131401 || skill_id == 61131101 || skill_id == 61131201 || skill_id == 61131301 || skill_id == 61132401 || skill_id == 61132101 || skill_id == 61132201 || skill_id == 61132301) {
					if (skillTmp.skill.sid == 61131401 || skillTmp.skill.sid == 61131101 || skillTmp.skill.sid == 61131201 || skillTmp.skill.sid == 61131301 || skillTmp.skill.sid == 61132401 || skillTmp.skill.sid == 61132101 || skillTmp.skill.sid == 61132201 || skillTmp.skill.sid == 61132301) {
						return skillTmp.skill.name;
					}
				}
				//特殊处理大江东去和气吞山河
				if (skill_id == 61331401 || skill_id == 61331101 || skill_id == 61331201 || skill_id == 61331301 || skill_id == 61332401 || skill_id == 61332101 || skill_id == 61332201 || skill_id == 61332301) {
					if (skillTmp.skill.sid == 61331401 || skillTmp.skill.sid == 61331101 || skillTmp.skill.sid == 61331201 || skillTmp.skill.sid == 61331301 || skillTmp.skill.sid == 61332401 || skillTmp.skill.sid == 61332101 || skillTmp.skill.sid == 61332201 || skillTmp.skill.sid == 61332301) {
						return skillTmp.skill.name;
					}
				}
			}
			return "";
		}
		
		private function checkSameTypeSkill(skill_id:int):String {
			var type:int=getSkillType(skill_id);
			for (var i:int=0; i < 16; i++) {
				if (skillItems[i].data == null)
					break;
				var skillTmp:PetSkillVO=skillItems[i].data as PetSkillVO;
				if (skillTmp.skill_type == type)
					return skillTmp.skill.name;
			}
			return "";
		}
		
		private function getSkillType(skill_id:int):int {
			var len:int=skillType.length;
			for (var i:int=0; i < len; i++) {
				if (skillType[i][0] == skill_id)
					return skillType[i][1];
			}
			return 0;
		}
	}
}