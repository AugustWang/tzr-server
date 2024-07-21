package modules.skillTree {
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.components.alert.Alert;
	import com.components.cooling.CoolingManager;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	import com.scene.sceneManager.LoopManager;
	
	import flash.events.DataEvent;
	import flash.geom.Point;
	import flash.media.Video;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.navigation.NavigationModule;
	import modules.playerGuide.GuideConstant;
	import modules.playerGuide.PlayerGuideModule;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.SkillMethods;
	import modules.skill.SkillModule;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;
	import modules.skillTree.views.SkillPanel;
	import modules.skillTree.views.items.SkillItem;
	import modules.system.SystemConfig;
	
	import proto.line.m_pet_grow_over_toc;
	import proto.line.m_skill_getskills_toc;
	import proto.line.m_skill_getskills_tos;
	import proto.line.m_skill_learn_toc;
	import proto.line.m_skill_learn_tos;
	import proto.line.m_skill_personal_forget_toc;
	import proto.line.m_skill_personal_forget_tos;
	import proto.line.m_skill_reset_toc;
	import proto.line.m_skill_use_time_toc;
	import proto.line.p_skill_time;

	/**
	 * 技能树，学习，遗忘，显示 技能
	 */
	public class SkillTreeModule extends BaseModule {
		public var skillPanel:SkillPanel;

		public function SkillTreeModule() {
			super();
		}

		private static var instance:SkillTreeModule;

		public static function getInstance():SkillTreeModule {
			if (instance == null) {
				instance=new SkillTreeModule();
			}
			return instance;
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.SKILL_GETSKILLS, onSkillGetSkills);
			addSocketListener(SocketCommand.SKILL_LEARN, onSkillLearn);
			addSocketListener(SocketCommand.SKILL_RESET, onSkillReset);
			addSocketListener(SocketCommand.SKILL_PERSONAL_FORGET, onSkillPersonalForget);
			addSocketListener(SocketCommand.SKILL_USE_TIME, onSkillUseTime);
			addMessageListener(ModuleCommand.ONEP_SKILL_TREE, openSkillTree);
			addMessageListener(ModuleCommand.ROLE_REMAIN_POINT_CHANGE, showRemainSkillPointIcon);
			addMessageListener(ModuleCommand.SKILL_LEARN_FROM_BOOK, onSkillLearnFromBook);
			addMessageListener(ModuleCommand.UPDATE_PET_GROW, updatePetGrow);
			addMessageListener(ModuleCommand.OPEN_TRAIN_PET,onOpenTrainPet);
			addMessageListener(ModuleCommand.OPEN_CAREER_SKILL_PANEL,onOpenCareerSkillPanel);
			addMessageListener(ModuleCommand.EXP_CHAGNGE,onMoneyExpChanged);
			addMessageListener(ModuleCommand.PACKAGE_MONEY_CHANGE,onMoneyExpChanged);
		}
	
		private function onMoneyExpChanged():void{
			if(skillPanel){
				skillPanel.updateMoneyExp();
			}
		}
		
		private function onOpenCareerSkillPanel():void{
			var category:int = GlobalObjectManager.getInstance().user.attr.category;
			var label:String = "";
			switch(category){
				case 1:label = SkillConstant.CATEGORY_LABEL_WARRIOR;break;
				case 2:label = SkillConstant.CATEGORY_LABEL_ARCHER;break;
				case 3:label = SkillConstant.CATEGORY_LABEL_RANGER;break;
				case 4:label = SkillConstant.CATEGORY_LABEL_PRIEST;break;
				default:break;
			}
			if(label != ""){
				openSkillTree(label);
			}
		}
		
		private function onOpenTrainPet():void{
			openSkillTree(SkillConstant.CATEGORY_LABEL_PETGROW);	
		}
		
		public function updatePetGrow(obj:Object):void {
			if (skillPanel) {
				skillPanel.updatePetGrowInfo(obj['grow_info'], obj['info_configs']);
			}
		}

		/**
		 *技能等级返回
		 */
		private function onSkillGetSkills(vo:m_skill_getskills_toc):void {
			resetLevel();
			var levels:Array=vo.skills;
			for (var j:int=0; j < levels.length; j++) {
				SkillDataManager.getSkill(levels[j].skill_id).level=levels[j].cur_level;
			}
			setCustomSkillLevel();
			SkillDataManager.updataCategoryPoint();
			updata();
			showRemainSkillPointIcon();
		}

		/**
		 *技能学习返回
		 */
		private function onSkillLearn(vo:m_skill_learn_toc):void {
			if (vo.succ) {
				var skillVO:SkillVO=SkillDataManager.getSkill(vo.skill.skill_id);
				var tipsTxt:String = '你学会了' + skillVO.name + '（' + vo.skill.cur_level + '级）';
				Tips.getInstance().addTipsMsg(tipsTxt);
				SkillDataManager.getSkill(skillVO.sid).level=vo.skill.cur_level;
				SkillDataManager.updataCategoryPoint();
				updata();
				//去掉新手提示
				if (PlayerGuideModule.getInstance().currentType == PlayerGuideModule.SKILL_WIDNOW) {
					this.dispatch(GuideConstant.REMOVE_TASK_GUIDE);
				}
				showRemainSkillPointIcon();
				if (SkillPanel.items[skillVO.sid] && SkillPanel.items[skillVO.sid] is SkillItem) {
					SkillPanel.items[skillVO.sid].showUpLevel(); //播放升级动画
				}
				//学习第一个技能则重置一下技能面板
				if (SkillDataManager.warriorPoint + SkillDataManager.archerPoint + SkillDataManager.rangerPoint + SkillDataManager.priestPoint == 1 && GlobalObjectManager.getInstance().user.attr.level < 30) {
					if (skillPanel)
						skillPanel.createNav();
				}
				if (skillVO.attack_type != SkillConstant.ATTACK_TYPE_PASSIVITY) {
					if (skillVO.level == 1) { //学习的是自动技能则更新一下自动技能
						SystemConfig.skills=SkillModule.getInstance().getRecommend();
						SystemConfig.save();
					}
					//加到快捷栏中
					var items:Array=NavigationModule.getInstance().getItems();
					for (var i:int=0; i < items.length; i++) {
						if (items[i].type == 1) {
							if (items[i].id == skillVO.sid) {
								return;
							}
						}
					}
					//把新学习的第一个技能设置成自动施放
					for (var j:int=9; j < items.length; j++) {
						if (items[j].type == 0) {
							NavigationModule.getInstance().addItemAt(skillVO, j);
							if (skillVO.sid == 11101001 && skillVO.level == 1) {
								SkillModule.getInstance().autoSkill=skillVO;
							}
							if (skillVO.sid == 21101001 && skillVO.level == 1) {
								SkillModule.getInstance().autoSkill=skillVO;
							}
							if (skillVO.sid == 31101001 && skillVO.level == 1) {
								SkillModule.getInstance().autoSkill=skillVO;
							}
							if (skillVO.sid == 41101001 && skillVO.level == 1) {
								SkillModule.getInstance().autoSkill=skillVO;
							}
							return;
						}
					}
				}
			} else {
				SkillMethods.showError(vo.reason);
			}
		}

		/**
		 *技能重置返回
		 */
		private function onSkillReset(vo:m_skill_reset_toc):void {
			if (vo.succ) {
				SkillDataManager.autoSkill=null;
				SkillDataManager.currentSkill=null;
				dispatch(ModuleCommand.RESET_SKILL);
				GlobalObjectManager.getInstance().user.attr.remain_skill_points=vo.skill_points;
				resetLevel();
				setCustomSkillLevel();
				SkillDataManager.updataCategoryPoint();
				updata();
				showRemainSkillPointIcon();
				Tips.getInstance().addTipsMsg("技能点重置成功");
				BroadcastSelf.getInstance().appendMsg("技能点重置成功");
				if (GlobalObjectManager.getInstance().user.attr.level < 30) {
					if (skillPanel)
						skillPanel.createNav();
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}

		}

		/**
		 *技能遗忘返回
		 */
		private function onSkillPersonalForget(vo:m_skill_personal_forget_toc):void {
			if (vo.succ) {
				SkillDataManager.getSkill(vo.skill_id).level=0;
				dispatch(ModuleCommand.REMOVE_SKILL_ITEM);
				Tips.getInstance().addTipsMsg("遗忘成功");
				BroadcastSelf.logger("遗忘成功");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 *技能冷却返回
		 */
		private function onSkillUseTime(vo:m_skill_use_time_toc):void {
			var serverTime:int=vo.server_time;
			var l:int=vo.skill_time.length;
			for (var i:int=0; i < l; i++) {
				var skillTime:p_skill_time=vo.skill_time[i] as p_skill_time;
				var skillVO:SkillVO=SkillDataManager.getSkill(skillTime.skill_id);
				var skillItem:SkillLevelVO=skillVO.levels[skillVO.level - 1] as SkillLevelVO;
				var hasTime:Number=(serverTime - skillTime.last_use_time) * 1000;
				if (skillItem != null) {
					if (hasTime <= skillItem.cooldown) {
						CoolingManager.getInstance().startCooling(skillVO.typeId, skillItem.cooldown, hasTime);
					}
				}
			}
		}

		//请求技能等级列表 	
		public function getSkills():void {
			var vo:m_skill_getskills_tos=new m_skill_getskills_tos();
			sendSocketMessage(vo);
		}

		//学习技能
		public function skillLearn(id:int):void {
			var vo:m_skill_learn_tos=new m_skill_learn_tos();
			vo.skill_id=id;
			sendSocketMessage(vo);
		}

		//遗忘单个技能
		public function skillPersonalForget(id:int):void {
			var vo:m_skill_personal_forget_tos=new m_skill_personal_forget_tos();
			vo.skill_id=id;
			sendSocketMessage(vo);
		}

		//设置自定义的技能等级
		private function setCustomSkillLevel():void {
			SkillDataManager.getSkill(1).level=1;
			SkillDataManager.getSkill(2).level=1;
			SkillDataManager.getSkill(3).level=1;
			SkillDataManager.getSkill(4).level=1;
			SkillDataManager.getSkill(5).level=1;
			SkillDataManager.getSkill(6).level=1;
			SkillDataManager.getSkill(7).level=1;
			SkillDataManager.getSkill(9999991).level=1;
			SkillDataManager.getSkill(9999992).level=1;
		}

		//清空技能等级
		private function resetLevel():void {
			var skills:Array=SkillDataManager.getSkills();
			var l:int=skills.length;
			for (var i:int=0; i < l; i++) { //清空技能等级
				if (skills[i].category == SkillConstant.CATEGORY_PET1 || skills[i].category == SkillConstant.CATEGORY_PET2) {
					continue;
				}
				skills[i].level=0;
			}
		}

		private function onSkillLearnFromBook(id:int):void {
			var skill:SkillVO=SkillDataManager.getSkill(SkillDataManager.skillBooks[id]);
			if(skill == null){
				Tips.getInstance().addTipsMsg("找不到对应的学习技能");
				return;
			}	
			if(skill.category != GlobalObjectManager.getInstance().user.attr.category){
				Tips.getInstance().addTipsMsg("不能学习其他职业的技能");
				return;
			}
			if (SkillDataManager.warriorPoint == 0 && SkillDataManager.archerPoint == 0 && SkillDataManager.rangerPoint == 0 && SkillDataManager.priestPoint == 0 && GlobalObjectManager.getInstance().user.attr.level >= 10) {
				selectItemFromBook(skill);
			} else {
				var myCategory:int=GlobalObjectManager.getInstance().user.attr.category;
				var myLevel:int=GlobalObjectManager.getInstance().user.attr.level;
				if (myLevel >= 30) {
					selectItemFromBook(skill);
				} else {
					if (skill.category == myCategory) {
						selectItemFromBook(skill);
					} else {
						selectItemFromBookError(skill);
					}
				}
			}
		}

		private function selectItemFromBookError(skill:SkillVO):void {
			Alert.show("此书只有" + SkillConstant.categorys[skill.category] + "职业玩家可以使用,(使用洗髓丹可以改变职业)");
		}

		private function selectItemFromBook(skill:SkillVO):void {
			callBack = selectSkill;
			openSkillTree(SkillConstant.categorys[skill.category]);
			function selectSkill():void{
				skillPanel.setSelectSkill(skill.sid);	
			}
		}
		
		private var callBack:Function;
		public function openSkillTree(tarLabel:String="", point:Point=null):void {
			if(!ViewLoader.hasLoaded(GameConfig.SKILL_UI)){
				ViewLoader.load(GameConfig.SKILL_UI,openSkillTree,[tarLabel,point]);
				return;
			}	
			if (!skillPanel) {
				skillPanel=new SkillPanel();
				skillPanel.addEventListener(SkillConstant.EVENT_SKILL_UPGRADE, skillUpgrade);
				skillPanel.addEventListener(CloseEvent.CLOSE, onPanelClose);
			}
			this.dispatch(GuideConstant.OPEN_SKILL_PANEL);
			skillPanel.seleteIndex(tarLabel);
			WindowManager.getInstance().popUpWindow(skillPanel);
			WindowManager.getInstance().centerWindow(skillPanel);
			if (point) {
				skillPanel.x=point.x;
				skillPanel.y=point.y;
			}
			skillPanel.updata();
			hideRemainSkillPointIcon();
			if(callBack != null){
				callBack();
				callBack = null;
			}
		}

		private function onPanelClose(event:CloseEvent):void {
			showRemainSkillPointIcon();
		}

		private function skillUpgrade(e:DataEvent):void {
			skillLearn(int(e.data));
		}

		//加上技能升级提示
		public function showRemainSkillPointIcon():void {
			if (GlobalObjectManager.getInstance().user.attr.remain_skill_points >= 3 && GlobalObjectManager.getInstance().user.attr.level >= 20) {
				if (!skillPanel || !skillPanel.parent) {
					MessageIconManager.getInstance().showLevelSkillIcon(openSkillTree);
				}
			}
		}

		//移去技能升级提示
		public function hideRemainSkillPointIcon():void {
			MessageIconManager.getInstance().removeLevelSkillIcon();
		}

		public function updata():void {
			if (skillPanel && skillPanel.parent)
				skillPanel.updata();
		}
		
		public function updateFromShop():void{
			LoopManager.setTimeout(updata,500);
		}
	}
}