package modules.pet.view {

	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.PetSkillVO;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;

	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_pet_skill;
	import proto.common.p_skin;
	import proto.line.m_pet_add_skill_grid_tos;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_forget_skill_tos;
	import proto.line.m_pet_learn_skill_toc;
	import proto.line.m_pet_learn_skill_tos;

	public class PetLearnSkillView extends UIComponent {
		///蛋疼的后台不发开技能需要多少钱过来,开技能栏钱的顺序：0, 1, 2, 3, 4, 5,  6,   7,   8,    9,   10,  11,    12
		private static const openSkillMoney:Array=[0, 0, 0, 0, 0, 5, 9, 14, 20, 29, 39, 49, 59];
		private static const succRate:Array=[100, 50, 40, 30, 28, 26, 25, 23, 22, 20, 20];

		private var skills:Array=[];
		private var learnSuccRate:TextField;
		private var skillBook:UIComponent;
		private var learnedLevelSkill:PetSkillLearnItem;
		private var learnedNextLevelSkill:PetSkillLearnItem;
		public var pvo:p_pet;
		private var skin:p_skin;
		private var skillList:List;
		private var buyBookNoticeTxt:TextField;
		private static var skillType:Array=[[62123101, 12], [62111201, 12], [62111301, 12], [62123102, 12], [62123202, 12], [62123302, 12], [62123103, 12], [62123203, 12], [62123303, 12], [62123104, 12], [62123204, 12], [62123304, 12], [62123105, 12], [62123205, 12], [62123305, 12], [62111401, 12], [62123402, 12], [62123403, 12], [62123404, 12], [62123405, 12], [62113101, 13], [62113201, 13], [62113301, 13], [62113102, 13], [62113202, 13], [62113302, 13], [62113103, 13], [62113203, 13], [62113303, 13], [62113104, 13], [62113204, 13], [62113304, 13], [62113105, 13], [62113205, 13], [62113305, 13], [62113401, 13], [62113402, 13], [62113403, 13], [62113404, 13], [62113405, 13], [61131101, 11], [61131201, 11], [61131301, 11], [61132101, 11], [61132201, 11], [61132301, 11], [61131401, 11], [61132401, 11], [61331101, 1], [61331201, 1], [61331301, 1], [61332101, 1], [61332201, 1], [61332301, 1], [61331401, 1], [61332401, 1], [63236101, 2], [63236201, 2], [63236301, 2]];
		private var theSelected:PetSkillLearnItem;
		private var selectBg:Bitmap;

		public var headerContent:HeaderContent;

		public function PetLearnSkillView() {
			width=525;
			height=400;
			init();
		}

		private function init():void {
			this.y=3;
			var tf:TextFormat=new TextFormat(null, null, 0xffffff);
			tf.leading=4;
			var tfy:TextFormat=new TextFormat(null, null, 0xffff00);
			var tfr:TextFormat=new TextFormat(null, null, 0xff0000);
			var tfg:TextFormat=new TextFormat(null, null, 0x00ff00);

			headerContent=new HeaderContent();
			headerContent.showPetSkillLink(true);
			headerContent.y=2;
			addChild(headerContent);

			var part3:Sprite=new Sprite();
			part3.x=2;
			part3.y=168;
			var btf:TextFormat=new TextFormat(null, null, 0xcccccc, null);
			var petSkillPart:Sprite=new Sprite();
			petSkillPart.x=4;
			petSkillPart.y=2;
			var img2:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "name_petSkill");
			img2.y=7;
			img2.x=5;
			petSkillPart.addChild(img2);
			part3.addChild(petSkillPart);
			for (var i:int=0; i < 16; i++) {
				var psi:PetSkillLearnItem=new PetSkillLearnItem;
				psi.cover(true);
				psi.addEventListener(MouseEvent.CLICK, onClickSkill);
				psi.x=45 + (i % 8) * 39;
				psi.y=5 + int(i / 8) * 40;
				skills.push(psi);
				part3.addChild(psi);
			}
			selectBg=Style.getBitmap(GameConfig.T1_VIEWUI, "skillBorder");
			var part4:Sprite=new Sprite();
			part4.x=2;
			part4.y=258;
			var btnBg:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "btn_bg");
			btnBg.x=285;
			btnBg.y=45;
			part4.addChild(btnBg);
			var confirmBtn:Button=ComponentUtil.createButton("", 297, 67, 74, 74, part4);
			confirmBtn.addEventListener(MouseEvent.CLICK, onClickLearn);
			confirmBtn.bgSkin=Style.getButtonSkin("name_study", "", "", null, GameConfig.T1_VIEWUI);
			ComponentUtil.createTextField("费用：5两", 8, 68, tf, 94, 24, part4);
			ComponentUtil.createTextField("学习成功率：", 8, 46, tfg, 70, 60, part4);
			learnSuccRate=ComponentUtil.createTextField("100%", 76, 46, tfg, 50, 60, part4);
			ComponentUtil.createTextField("注意：先学初级技能，再学更高级技能将100%成功", 8, 104, tf, 300, 60, part4);
			ComponentUtil.createTextField("温馨提示：优先学习高价值技能，成功率更有保障！", 8, 124, tfg, 300, 60, part4);

			ComponentUtil.createTextField("从右侧选择宠物和技能书后点击“学习”", 8, 0, tf, 206, 24, part4);
			var washSkillTxt:TextField=ComponentUtil.createTextField("遗忘选中技能", 214, 0, null, 120, 20, part4);
			var washSkillAllTxt:TextField=ComponentUtil.createTextField("遗忘所有技能", 296, 0, null, 120, 20, part4);
			washSkillTxt.mouseEnabled=washSkillAllTxt.mouseEnabled=true;
			washSkillTxt.htmlText="<a href=\"event:forget_skill\"><font color='#00FF00'><u>遗忘选中技能</u></font>";
			washSkillAllTxt.htmlText="<a href=\"event:forget_all_skill\"><font color='#00FF00'><u>遗忘所有技能</u></font>";
			washSkillTxt.addEventListener(TextEvent.LINK, washSkill);
			washSkillAllTxt.addEventListener(TextEvent.LINK, washAllSkill);

			skillBook=ComponentUtil.createUIComponent(381, 176, 158, 230);
			Style.setBorderSkin(skillBook);

			ComponentUtil.createTextField("技能书", 6, 4, tfy, 120, 20, skillBook);

			buyBookNoticeTxt=ComponentUtil.createTextField("", 6, 23, tf, 146, 100, skillBook);
			buyBookNoticeTxt.htmlText="你的背包中没有宠物技能\n书,可到<a href=\"event:goto_pet_npc\"><font color='#00FF00'><u>宠物驯养师</u></font></a>或<a href=\"event:goto_pet_shop\"><font color='#00FF00'><u>宠物\n商城</u></font></a>购买";
			buyBookNoticeTxt.addEventListener(TextEvent.LINK, gotoPetNpc);
			buyBookNoticeTxt.mouseEnabled=true;
			skillList=new List();
			skillList.itemSkinLeft=40;
			skillList.itemSkinRight=10;
			skillList.x=6;
			skillList.y=23;
			skillList.bgSkin=null;
			skillList.width=150;
			skillList.height=204;
			skillList.itemHeight=36;
			skillList.itemRenderer=GoodsListRender;
			skillList.addEventListener(ItemEvent.ITEM_CLICK, onSkillItemClick);
			skillBook.addChild(skillList);

			this.addChild(part3);
			this.addChild(part4);
			this.addChild(skillBook);
			//默认30级的特殊技能
//			changeLevelBtn(btn30);
		}

		private function doToolTip(txt:TextField):void {
			txt.mouseEnabled=true;
			txt.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			txt.addEventListener(MouseEvent.ROLL_OUT, hideToolTip);
		}

		private function onRollOver(e:MouseEvent):void {
			var str:String="";
			switch ((e.currentTarget as TextField).name) {
				case "takeLevel":
					str="";
					break;
				case "attackType":
					str="影响宠物对敌人的伤害类型";
					break;
				case "color":
					str="宠物颜色，由宠物资质和悟性影响";
					break;
			}
			if (str != "") {
				ToolTipManager.getInstance().show(str);
			}
		}

		private function hideToolTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function updateList(pets:Array, count:int):void {
			headerContent.updateList(pets, count);
		}

		public function updateInfo(vo:p_pet):void {
			headerContent.updateInfo(vo);
			var p:p_pet_id_name=headerContent.getSelectedItem();
			if (p == null)
				return;
			if (vo.pet_id == p.pet_id) {
				pvo=vo;

				for (var i:int=0; i < 16; i++) {
					skills[i].data=null;
					skills[i].buttonMode=false;
					skills[i].cover(true);
					if (skills[i].contains(selectBg) == true) {
						selectBg.parent.removeChild(selectBg);
					}
				}
				for (i=0; i < vo.max_skill_grid; i++) {
					skills[i].cover(false);
				}
				for (i=0; i < vo.skills.length; i++) {
					var ps:p_pet_skill=vo.skills[i];
					var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
					var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
					skills[i].data=petSkill;
					skills[i].buttonMode=true;
				}
				updateSkillBookList();
				updateLearnSuccRate();
			}
		}

		//制造颜色
		private function coloring2(s1:String, s2:String):String {
			var str:String=HtmlUtil.font2(s1, 0xAFE0EE) + HtmlUtil.font2(s2, 0xECE8BB);
			return str;
		}

		//制造颜色
		private function coloring(s1:String, s2:int, color2:uint=0xECE8BB):String {
			var str:String=HtmlUtil.font2(s1, 0xAFE0EE) + HtmlUtil.font2(s2 + "", color2);
			return str;
		}

		private function onSkillItemClick(e:ItemEvent):void {
			updateLearnSuccRate();
		}


		private function onClickLearn(e:MouseEvent):void {
			if (headerContent.selectedItem == null) {
				Tips.getInstance().addTipsMsg("请先选择要学习技能的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == headerContent.selectedItem.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "提悟", exeCallBack, null, "召回宠物");
				return;
			}
			if (skillList.selectedItem == null) {
				Tips.getInstance().addTipsMsg("请先选择要学习的技能");
				return;
			}

			//			vo.pet_id=headerContent.selectedItem.pet_id;
			var type_id:int=BaseItemVO(skillList.selectedItem).typeId;

			var skill:SkillVO=SkillDataManager.getSkill(SkillDataManager.skillBooks[type_id]);
			if (skill == null) {
				Tips.getInstance().addTipsMsg("框中的物品必须为宠物技能书");
				return;
			}
			var oldSameSkill:String=checkSameSkill(skill.sid);
			if (oldSameSkill != "") {
				var param:Array=[headerContent.selectedItem.pet_id, skill.sid];
				var str:String="学习该技能将替换已有的<font color=\"#00FF00\">【" + oldSameSkill + "】</font>技能";
				Alert.show(str, "提示", toLearnSkill, null, "确定", "取消", param, true, false, null);
				return;
			} else if (pvo.skills.length >= pvo.max_skill_grid) {
				Tips.getInstance().addTipsMsg("宠物可学技能栏已满，请在技能界面扩展技能栏");
				return;
			}
			toLearnSkill(headerContent.selectedItem.pet_id, skill.sid);
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

		//检测是否顶替已有技能
		private function checkSameSkill(skill_id:int):String {
			var sidStr:String=skill_id.toString();
			var temStr:String;
			for (var i:int=0; i < 16; i++) {
				var skillTmp:PetSkillVO=skills[i].data as PetSkillVO;
				if (skills[i].data == null) {
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
				if (skills[i].data == null)
					break;
				var skillTmp:PetSkillVO=skills[i].data as PetSkillVO;
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

		private function toLearnSkill(pet_id:int, skill_id:int):void {
			var vo:m_pet_learn_skill_tos=new m_pet_learn_skill_tos;
			vo.pet_id=pet_id;
			vo.skill_id=skill_id;
			PetModule.getInstance().send(vo);
		}

		public function onLearnSkill(vo:m_pet_learn_skill_toc):void {
			for (var i:int=0; i < 16; i++) {
				skills[i].data=null;
			}

			for (i=0; i < vo.skills.length; i++) {
				var ps:p_pet_skill=vo.skills[i];
				var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
				SkillDataManager.getSkill(ps.skill_id).level=1;
				var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
				skills[i].data=petSkill;
			}
			if (pvo) {
				pvo.skills=vo.skills;
			}
			updateSkillBookList();
		}

		public function updateSkillBookList():void {
			var arrp1:Array=PackManager.getInstance().getItemsByPackId(1);
			var arrp2:Array=PackManager.getInstance().getItemsByPackId(2);
			var arrp3:Array=PackManager.getInstance().getItemsByPackId(3);
			var arr:Array=[];

			//从三个包裹获取数据
			if (arrp2 == null && arrp3 == null) {
				arr=arrp1;
			} else if (arrp2 != null && arrp3 == null) {
				arr=arrp1.concat(arrp2);
			} else if (arrp2 != null && arrp3 != null) {
				arr=arrp1.concat(arrp2.concat(arrp3));
			} else if (arrp2 == null && arrp3 != null) {
				arr=arrp1.concat(arrp3);
			}

			var len:int=arr.length;

			var arr2:Array=new Array();
			for (var i:int=0; i < len; i++) {
				var item:BaseItemVO=arr[i] as BaseItemVO;
				if (item != null && item.typeId >= 10305101 && item.typeId <= 10305330) {
					arr2.push(item);
				}
			}
			arr2.sortOn("typeId");
			var oldtype:int=0;
			var oldItem:BaseItemVO;
			var arr3:Array=new Array();
			for (i=0; i < arr2.length; i++) {
				item=arr2[i] as BaseItemVO;
				if (item.typeId == oldtype) {
					oldItem.num+=item.num;
				} else {
					oldItem=ItemLocator.getInstance().getObject(item.typeId);
					oldItem.num=item.num;
					arr3.push(oldItem);
				}
			}
			skillList.dataProvider=arr3;
			if (arr3.length <= 0) {
				buyBookNoticeTxt.visible=true;
				skillList.visible=false;
			} else {
				buyBookNoticeTxt.visible=false;
				skillList.visible=true;
			}
		}

		private function updateLearnSuccRate():void {
			if (skillList.selectedItem == null) {
				learnSuccRate.text="";
				return;
			}
			var type_id:int=BaseItemVO(skillList.selectedItem).typeId;
			var skill:SkillVO=SkillDataManager.getSkill(SkillDataManager.skillBooks[type_id]);
			if (skill == null) {
				learnSuccRate.text="";
				return;
			}
			if (checkSameSkill(skill.sid) != "") { //要顶替技能就100%
				learnSuccRate.text="100%";
				return;
			}
			var skill_type:int=getSkillType(skill.sid);
			if (skill_type < 10) { //skill_type < 10就是群攻技能
				learnSuccRate.text="100%";
				return;
			}
			var learnedSkillNum:int=pvo.skills.length;
			for (var i:int=0; i < 12; i++) {
				if (skills[i].data == null)
					break;
				var skillTmp:PetSkillVO=skills[i].data as PetSkillVO;
				if (skillTmp.skill_type < 10) { //在已学技能中排除，群攻的技能
					learnedSkillNum--;
				}
			}
			if (learnedSkillNum >= 0 && learnedSkillNum <= succRate.length) {
				learnSuccRate.text=succRate[learnedSkillNum] + "%";
			}
		}

		private function gotoPetNpc(e:TextEvent):void {
			if (e.text == "goto_pet_shop") {
				Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP);
			}
			if (e.text == "goto_pet_npc") {
				ChatModule.getInstance().chat.gotoPetNpc();
			}
		}

		public function stopAvatar():void {
			headerContent.stopAvatar();
		}

		public function startAvatar():void {
			headerContent.startAvatar();
		}

		private function onClickSkill(e:MouseEvent):void {
			var tar:PetSkillLearnItem=e.target as PetSkillLearnItem;
			if (theSelected != tar && tar.data != null) {
				theSelected=tar;
				if (selectBg.parent != null) {
					selectBg.parent.removeChild(selectBg);
				}
				selectBg.x=-4;
				selectBg.y=-4;
				theSelected.addChild(selectBg);
			}
		}

		private function openSkill(e:TextEvent):void {
			if (headerContent.selectedItem == null) {
				Tips.getInstance().addTipsMsg("请先选择要扩展技能栏的宠物");
				return;
			}
			if (this.pvo) {
				if (this.pvo.max_skill_grid < openSkillMoney.length - 1 && this.pvo.max_skill_grid > 0) {
					Alert.show("扩展技能栏需要" + openSkillMoney[this.pvo.max_skill_grid + 1] + "元宝，确定扩展吗？", "消费提示", yesOpenSkill);
				} else {
					Tips.getInstance().addTipsMsg("技能栏已经达到最大数");
				}
			} else {
				Tips.getInstance().addTipsMsg("请先选择要扩展技能栏的宠物");
			}
		}

		private function yesOpenSkill():void {
			var vo:m_pet_add_skill_grid_tos=new m_pet_add_skill_grid_tos;
			vo.pet_id=headerContent.selectedItem.pet_id;
			Connection.getInstance().sendMessage(vo);
		}

		private function washSkill(e:TextEvent):void {
			if (headerContent.selectedItem == null) {
				Tips.getInstance().addTipsMsg("请先选择要遗忘技能的宠物");
				return;
			}
			if (theSelected) { //有没有选中的技能
				if (theSelected.data) {
					Alert.show("确定要花费1锭20两银子遗忘技能【" + theSelected.data.skill.name + "】吗?", "遗忘技能", forgetSkill, null, "确定", "取消", [headerContent.selectedItem.pet_id, theSelected.data.skill.sid]);
				}
			} else {
				Tips.getInstance().addTipsMsg("请先选择要遗忘的技能");
			}
		}

		private function forgetSkill(pet_id:int, skill_id:int):void {
			var vo:m_pet_forget_skill_tos=new m_pet_forget_skill_tos;
			vo.pet_id=pet_id;
			vo.skill_id=skill_id;
			Connection.getInstance().sendMessage(vo);
		}

		private function washAllSkill(e:TextEvent):void {
			if (headerContent.selectedItem == null) {
				Tips.getInstance().addTipsMsg("请先选择要遗忘技能的宠物");
				return;
			}
			Alert.show("确定要花费3锭银子遗忘所有技能吗?", "遗忘技能", forgetSkill, null, "确定", "取消", [headerContent.selectedItem.pet_id, 0]);
		}
	}
}