package modules.pet.view {
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.net.connection.Connection;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetSkillVO;
	import modules.pet.config.PetConfig;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_pet_skill;
	import proto.common.p_skin;
	import proto.line.m_pet_info_tos;
	import proto.line.m_pet_trick_learn_tos;
	import proto.line.m_pet_trick_upgrade_tos;

	public class PetTrickSkillView extends UIComponent {
		private var skillIntroView:PetTrickDictView;
		private var shenJiDanID:int=12300140; //一级神技丹ID
		private var pvo:p_pet;
		private var skin:p_skin;
		private var curLevel:int=101;
		private var avatar:Avatar;
		private var list:List;
		private var goodsList:List;
		private var nav:TabNavigation;
		private var learnedLevelSkill:PetSkillLearnItem;
		private var btn30:Button;
		private var btn50:Button;
		private var btn75:Button;
		private var btn100:Button;
		private var relearnBtn:Button;
		private var curSkillTxt:TextField;
		private var trickSkills:Array=[];


		private var commitType:int;
		private var itemNum:int;
		private var timer:Timer;
		private var timeLeft:int=0;
		private var alertStr:String;
		private var petLevel:int=0;
		private var petExp:int=0;
		private var petNextExp:int=0;


		public function PetTrickSkillView() {
			this.width=470;
			this.height=275;
			init();
		}

		private function init():void {
			this.y=3;
			var part1:Sprite=Style.getBlackSprite(278, 164, 0, 0.2);
			part1.x=2
			part1.y=2;
			
			var avatarBg:Image = new Image();
			avatarBg.x = 278;
			avatarBg.y = 164;
			avatarBg.width = 213;
			avatarBg.height = 153;
			avatarBg.mouseChildren = avatarBg.mouseEnabled = false;
			avatarBg.source = GameConfig.getBackImage("petAvatarBg");
			part1.addChild(avatarBg);
			
			avatar=new Avatar;
			avatar.x=140;
			avatar.y=136;
			part1.addChild(avatar);

			var part2:Sprite=Style.getBlackSprite(92, 164, 0, 0.2);
			part2.x=282;
			part2.y=2;
			var listBar:Skin=Style.getSkin("titleBar", GameConfig.T1_VIEWUI);
			listBar.setSize(92, 22);
			part2.addChild(listBar);
			ComponentUtil.createTextField("提示", 30, 0, null, 94, 22, part2);
			var tip:TextField=ComponentUtil.createTextField("", 1, 22, null, 94, 140, part2);
			tip.multiline=true;
			tip.wordWrap=true;
			tip.text="宠物到达一定等级后，可领悟神技。升级神技需要花费对应等级的神技丹。";
			var part3:Sprite=Style.getBlackSprite(372, 237, 0, 0.2);
			part3.y=167;
			part3.x=2;

			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y=141;
			line.width=372;
			part3.addChild(line);
			var titleBar:Skin=Style.getSkin("titleBar", GameConfig.T1_VIEWUI);
			titleBar.setSize(372, 22);
			part3.addChild(titleBar);
			var tfTitle:TextFormat=new TextFormat(null, null, 0xAFE1EC, null, null, null, null, null, "center");
			ComponentUtil.createTextField("神技", 0, 0, tfTitle, 372, 22, part3);
			btn30=ComponentUtil.createButton("30级", 2, 24, 90, 22, part3);
			btn50=ComponentUtil.createButton("50级", 94, 24, 90, 22, part3);
			btn75=ComponentUtil.createButton("75级", 186, 24, 90, 22, part3);
			btn100=ComponentUtil.createButton("100级", 278, 24, 90, 22, part3);
			btn30.enabled=false;
			btn30.addEventListener(MouseEvent.CLICK, onSelectedLevel);
			btn50.addEventListener(MouseEvent.CLICK, onSelectedLevel);
			btn75.addEventListener(MouseEvent.CLICK, onSelectedLevel);
			btn100.addEventListener(MouseEvent.CLICK, onSelectedLevel);
			ComponentUtil.createTextField("已领悟的神技", 0, 66, tfTitle, 140, 22, part3);
			curSkillTxt=ComponentUtil.createTextField("当前等级可领悟的神技", 136, 66, tfTitle, 230, 22, part3);
			learnedLevelSkill=new PetSkillLearnItem;
			learnedLevelSkill.x=56;
			learnedLevelSkill.y=88;
			part3.addChild(learnedLevelSkill);
			for (var i:int=0; i < 3; i++) {
				var s:PetSkillLearnItem=new PetSkillLearnItem;
				s.addEventListener(MouseEvent.ROLL_OVER, onOverSkill);
				s.addEventListener(MouseEvent.ROLL_OUT, hideTip);
				s.x=194 + i * 41;
				s.y=88;
				part3.addChild(s);
				trickSkills.push(s);
			}
			var showAllBtn:Button=ComponentUtil.createButton("显示所有神技", 146, 200, 80, 22, part3);
			showAllBtn.addEventListener(MouseEvent.CLICK, onClickShowAll);
			relearnBtn=ComponentUtil.createButton("领悟技能", 85, 170, 80, 22, part3);
			relearnBtn.addEventListener(MouseEvent.ROLL_OVER, showRelearnTip);
			relearnBtn.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			relearnBtn.addEventListener(MouseEvent.CLICK, relearnSkill);
			var levelUpBtn:Button=ComponentUtil.createButton("升级神技", 214, 170, 80, 22, part3);
			levelUpBtn.addEventListener(MouseEvent.ROLL_OVER, showRelearnTip);
			levelUpBtn.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			levelUpBtn.addEventListener(MouseEvent.CLICK, onClickLevelUp);
			var petPart:Sprite=Style.getBlackSprite(146, 208, 0, 0);
			list=new List;
			list.x=list.y=6;
			list.bgSkin=null;
			list.width=140;
			list.height=186;
			list.itemHeight=36;
			list.itemRenderer=PetListRender;
			list.addEventListener(ItemEvent.ITEM_CLICK, onPetItemClick);
			petPart.addChild(list);
			var toolpart:Sprite=Style.getBlackSprite(146, 168, 0, 0);
			toolpart.x=375;
			toolpart.y=222;
			var bar:Skin=Style.getSkin("titleBar", GameConfig.T1_VIEWUI);
			bar.setSize(153, 22);
			toolpart.addChild(bar);
			goodsList=new List;
			goodsList.bgSkin=null;
			goodsList.x=goodsList.y=3;
			goodsList.width=150;
			goodsList.height=144;
			goodsList.itemHeight=36;
			goodsList.y=23;
			goodsList.itemRenderer=GoodsListRender;
			toolpart.addChild(goodsList);
			ComponentUtil.createTextField("升级所需道具：", 2, 2, null, 160, 22, toolpart);
			nav=new TabNavigation();
			nav.addItem("宠物", petPart, 60, 25);
			nav.y=1;
			nav.x=375;
			nav.width=152;
			nav.height=224;
			this.addChild(part1);
			this.addChild(part2);
			this.addChild(part3);
			this.addChild(nav);
			this.addChild(toolpart);
		}

		private function onClickShowAll(e:MouseEvent):void {
			if (skillIntroView == null) {
				skillIntroView=new PetTrickDictView;
			}
			WindowManager.getInstance().popUpWindow(skillIntroView);
			WindowManager.getInstance().centerWindow(skillIntroView);
		}

		private function onOverSkill(e:MouseEvent):void {

		}

		private function onClickLevelUp(e:MouseEvent):void {
			if (pvo == null) {
				Tips.getInstance().addTipsMsg("请选择要升级技能的宠物");
				return;
			}
			if (learnedLevelSkill.data) {
				var vo:m_pet_trick_upgrade_tos=new m_pet_trick_upgrade_tos;
				vo.pet_id=pvo.pet_id;
				vo.skill_id=learnedLevelSkill.data.skill.sid;
				Connection.getInstance().sendMessage(vo);
			}
		}

		private function showRelearnTip(e:MouseEvent):void {
			ToolTipManager.getInstance().show("本阶段可领悟技能中随机领悟其中一个，花费1锭银子", 100);
		}

		private function hideTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function onSelectedLevel(e:MouseEvent):void {
			changeLevelBtn(e.currentTarget as Button);
		}

		//重新领悟技能
		private function relearnSkill(e:MouseEvent):void {
			if (pvo == null) {
				Tips.getInstance().addTipsMsg("请先选择要重新领悟的宠物");
				return;
			}
			var vo:m_pet_trick_learn_tos=new m_pet_trick_learn_tos;
			vo.pet_id=pvo.pet_id;
			vo.type=curLevel;
			Connection.getInstance().sendMessage(vo);
		}

		private function onPetItemClick(e:ItemEvent):void {
			var p:p_pet_id_name=e.selectItem as p_pet_id_name;
			var dic:Dictionary=PetDataManager.petInfos;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=p.pet_id;
			Connection.getInstance().sendMessage(vo);
		}

		private function changeLevelBtn(btn:Button):void {
			btn30.enabled=true;
			btn50.enabled=true;
			btn75.enabled=true;
			btn100.enabled=true;
			var level:int=30;
			switch (btn) {
				case btn30:
					curLevel=101;
					level=30;
					curSkillTxt.text="宠物30级可领悟的神技";
					break;
				case btn50:
					curLevel=102;
					level=50;
					curSkillTxt.text="宠物50级可领悟的神技";
					break;
				case btn75:
					curLevel=103;
					level=75;
					curSkillTxt.text="宠物75级可领悟的神技";
					break;
				case btn100:
					curLevel=104;
					level=100;
					curSkillTxt.text="宠物100级可领悟的神技";
					break;
			}
			btn.enabled=false;
			var skills:Array=PetConfig.getTrickSkillByLevel(level);
			if (skills) {
				for (var i:int=0; i < trickSkills.length; i++) {
					var s:SkillVO=SkillDataManager.getSkill(int(skills[i].id));
					s.level=1;
					if (s) {
						var petSkill:PetSkillVO=new PetSkillVO(s, 101);
						trickSkills[i].data=petSkill;
					}
				}
			}
		}

		public function updateList(pets:Array):void {
			list.dataProvider=pets;

		}

		public function updateInfo(vo:p_pet):void {
			if (list.dataProvider == null || list.dataProvider.length <= 0)
				return;
			var p:p_pet_id_name=list.dataProvider[list.selectedIndex] as p_pet_id_name;
			if (p == null) {
				p=list.dataProvider[0];
			}
			if (vo.pet_id == p.pet_id) {
				skin=new p_skin;
				skin.skinid=PetConfig.getPetSkin(vo.type_id);
				if (avatar.skinData == null) {
					avatar.initSkin(skin);
				} else {
					avatar._bodyLayer.y=0;
					avatar.updataSkin(skin);
				}
				var skinid:int=PetConfig.getPetSkin(vo.type_id);
				avatar.play(AvatarConstant.ACTION_STAND, 6, PetDataManager.getStandSpeed(skinid));
				avatar.visible=true;
				if (skinid == 10086 || skinid == 10089 || skinid == 10090 || skinid == 10092 || skinid == 10108) {
					skinid == 10108 ? avatar._bodyLayer.y=66 : avatar._bodyLayer.y=40;
				}
				var hasTrickSkill:Boolean;
				for (var i:int=0; i < vo.skills.length; i++) {
					var ps:p_pet_skill=vo.skills[i];
					if (ps.skill_type == curLevel) {
						var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
						var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type);
						learnedLevelSkill.data=petSkill;
						if (relearnBtn.label != "重新领悟") {
							relearnBtn.label="重新领悟";
						}
						var danID:int=shenJiDanID + (ps.skill_level - 1);
						var danVO:BaseItemVO=ItemLocator.getInstance().getObject(danID);
						if (danVO) {
							danVO.num=PackManager.getInstance().getGoodsNumByTypeId(danID);
							goodsList.dataProvider=[danVO];
						}
						hasTrickSkill=true;
					}
				}
				if (hasTrickSkill == false) {
					learnedLevelSkill.data=null;
					relearnBtn.label="领悟技能";
				}
				pvo=vo;
				checkLearnedSkill(vo.level);
			}
		}

		private function checkLearnedSkill(level:int):void {
			var skillType:int;
			if (level < 50) {
				skillType=101;
				changeLevelBtn(btn30);
			} else if (level >= 50 && level < 75) {
				skillType=102;
				changeLevelBtn(btn50);
			} else if (level >= 75 && level < 100) {
				skillType=103;
				changeLevelBtn(btn75);
			} else {
				skillType=104;
				changeLevelBtn(btn100);
			}
			for (var i:int=0; i < pvo.skills.length; i++) {
				var data:p_pet_skill=pvo.skills[i];
				if (data.skill_type == skillType) {
					var skill:SkillVO=SkillDataManager.getSkill(data.skill_id);
					if (skill) {
						var psk:PetSkillVO=new PetSkillVO(skill, data.skill_type);
						learnedLevelSkill.data=psk;
						break;
					}
				}
			}

		}
	}
}