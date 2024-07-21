package modules.pet {
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.connection.Connection;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.navigation.NavigationModule;
	import modules.npc.vo.NpcLinkVO;
	import modules.pet.config.PetConfig;
	import modules.pet.newView.PetAptitudeView;
	import modules.pet.newView.PetInfoView;
	import modules.pet.newView.PetPanel;
	import modules.pet.newView.PetSavvyView;
	import modules.pet.newView.PetSkillView;
	import modules.pet.view.PetFeedView;
	import modules.pet.view.PetHatchPanel;
	import modules.pet.view.PetLearnSkillView;
	import modules.pet.view.PetLifeView;
	import modules.pet.view.PetPanelOther;
	import modules.pet.view.PetSkillsBar;
	import modules.pet.view.PetStateView;
	import modules.pet.view.PetTrickSkillView;
	import modules.rank.view.PetListView;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	import modules.skillTree.views.items.SkillPetGrowView;
	
	import proto.common.p_grow_info;
	import proto.common.p_map_pet;
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_role_pet_bag;
	import proto.line.m_pet_add_bag_toc;
	import proto.line.m_pet_add_life_toc;
	import proto.line.m_pet_add_skill_grid_toc;
	import proto.line.m_pet_add_understanding_toc;
	import proto.line.m_pet_attr_assign_toc;
	import proto.line.m_pet_attr_assign_tos;
	import proto.line.m_pet_attr_change_toc;
	import proto.line.m_pet_bag_info_toc;
	import proto.line.m_pet_bag_info_tos;
	import proto.line.m_pet_call_back_toc;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_change_name_toc;
	import proto.line.m_pet_change_pos_toc;
	import proto.line.m_pet_egg_adopt_toc;
	import proto.line.m_pet_egg_refresh_toc;
	import proto.line.m_pet_egg_use_toc;
	import proto.line.m_pet_feed_begin_toc;
	import proto.line.m_pet_feed_commit_toc;
	import proto.line.m_pet_feed_give_up_toc;
	import proto.line.m_pet_feed_info_toc;
	import proto.line.m_pet_feed_over_toc;
	import proto.line.m_pet_feed_star_up_toc;
	import proto.line.m_pet_forget_skill_toc;
	import proto.line.m_pet_grow_begin_toc;
	import proto.line.m_pet_grow_begin_tos;
	import proto.line.m_pet_grow_commit_toc;
	import proto.line.m_pet_grow_commit_tos;
	import proto.line.m_pet_grow_give_up_toc;
	import proto.line.m_pet_grow_give_up_tos;
	import proto.line.m_pet_grow_info_toc;
	import proto.line.m_pet_grow_info_tos;
	import proto.line.m_pet_grow_over_toc;
	import proto.line.m_pet_info_toc;
	import proto.line.m_pet_info_tos;
	import proto.line.m_pet_learn_skill_toc;
	import proto.line.m_pet_level_up_toc;
	import proto.line.m_pet_refining_exp_toc;
	import proto.line.m_pet_refining_toc;
	import proto.line.m_pet_refining_tos;
	import proto.line.m_pet_refresh_aptitude_toc;
	import proto.line.m_pet_summon_toc;
	import proto.line.m_pet_summon_tos;
	import proto.line.m_pet_throw_toc;
	import proto.line.m_pet_throw_tos;
	import proto.line.m_pet_training_request_toc;
	import proto.line.m_pet_training_request_tos;
	import proto.line.m_pet_trick_learn_toc;
	import proto.line.m_pet_trick_upgrade_toc;

	public class PetMediator {
		private var stateView:PetStateView;
		private var view:PetInfoView;
		private var otherView:PetPanelOther;
		private var skillView:PetSkillView;
		private var savvyView:PetSavvyView;
		private var aptitudeView:PetAptitudeView;
		private var feedView:PetFeedView;
		private var trickView:PetTrickSkillView;
		private var lifeView:PetLifeView;
		private var hatchPanel:PetHatchPanel;
		private var skillBar:PetSkillsBar;

		public function PetMediator() {

		}

		//宠物头像界面
		private function initStateView():void {
			if (stateView == null) {
				stateView=new PetStateView;
				stateView.addEventListener(PetInfoView.SUMMON_EVENT, toSummon);
				stateView.addEventListener(PetInfoView.CALL_BACK_EVENT, toTakeBack);
				stateView.x=220;
			}
		}

		//初始化别人宠物面板
		private function initOtherDetailPanel():void {
			if (otherView == null) {
				otherView=new PetPanelOther;
			}
		}

		//宠物面板
		private var petPanel:PetPanel;
		public function initView(tabIndex:int=-1):void{
			if(petPanel == null){
				petPanel=new PetPanel();
				petPanel.addEventListener(WindowEvent.OPEN, onOpenPanel);
				view=petPanel.petInfoView;
				view.addEventListener(WindowEvent.OPEN, onOpenInfo);
				view.addEventListener(PetInfoView.CALL_BACK_EVENT, toTakeBack);
				view.addEventListener(PetInfoView.SUMMON_EVENT, toSummon);
				view.addEventListener(PetInfoView.THROW_EVENT, toThrow);
				view.addEventListener(PetInfoView.PROPERTY_EVENT, toChangeProperty);
				view.addEventListener(PetInfoView.PET_STORE_EVENT, toPetStore);
				skillView=petPanel.skillView;
				savvyView=petPanel.savvyView;
				aptitudeView=petPanel.petAptitudeView;
//				feedView=petPanel.feedView;
//				feedView.addEventListener(PetInfoView.PET_STORE_EVENT, toPetStore);
//				trickView=petPanel.trickView;
			}
			if(tabIndex != -1){
				petPanel.selectIndex = tabIndex;
			}
		}
		
		private function initLifeView():void {
			if (lifeView == null) {
				lifeView=new PetLifeView();
			}
		}

		private function initHatchView():void {
			if (hatchPanel == null) {
				hatchPanel=new PetHatchPanel;
			}
		}

		//外部调用打开面板
		public function onOpenPanel(e:WindowEvent):void {
			if (petPanel == null) {
				initView();
				updatePetList(PetDataManager.petBag);
			}
//			fillData(); //填数据
		}

		public function onOpenOtherPanel():void {
			initOtherDetailPanel();
		}

		//显示宠物头像面板
		public function showState():void {
			initStateView();
			LayerManager.uiLayer.addChild(stateView);
		}

		//更新面板上的宠物列表
		private function updatePetList(info:p_role_pet_bag):void {
			if (info.pets != null) {
				info.pets.sortOn("index");
				PetDataManager.petBag=info;
				PetListView.getInstance().updateList(info.pets);
				if (petPanel) {
//					view.updateList(info.pets, info.content);
//					skillView.updateList(info.pets,info.content);
//					savvyView.updateList(info.pets,info.content);
//					aptitudeView.updateList(info.pets,info.content);
//					feedView.updateList(info.pets,info.content);
//					trickView.updateList(info.pets);
					
					if (lifeView) {
						lifeView.updateList(info.pets);
					}
				}
			}
		}

		//来了一个p_pet，更新所有面板的信息
		private function updatePetInfo(pet_info:p_pet):void {
			if (!pet_info) {
				return;
			}

			if (pet_info.role_id == GlobalObjectManager.getInstance().user.base.role_id) {
				PetDataManager.updatePetInfo(pet_info);
				stateView.updateInfo(pet_info);
				if (petPanel) {
//					view.update(pet_info);
//					skillView.update();
//					savvyView.makeUseFu(pet_info);
//					aptitudeView.makeUseDrug(pet_info);
//					skillView.updateInfo(pet_info);
//					feedView.updatePetLevelAndExp(pet_info);
//					trickView.updateInfo(pet_info);
					if (lifeView) {
						lifeView.updateCurrentLife(pet_info);
					}
				}
				if (PetDataManager.thePet != null && PetDataManager.thePet.pet_id == pet_info.pet_id) { //更新出战宠物的buff
					stateView.updateBuff(pet_info.buffs);
				}
			} else {
				initOtherDetailPanel();
				otherView.update(pet_info);
				WindowManager.getInstance().popUpWindow(otherView);
				WindowManager.getInstance().centerWindow(otherView);
			}
		}

		//后台一开始告诉我有多少宠物
		public function onPetBag(vo:m_pet_bag_info_toc):void {
			if (vo.info != null) {
				if (vo.info && vo.info.pets) {
					vo.info.pets.sortOn("index");
				}
				updatePetList(vo.info);
			}
		}

		private function onOpenInfo(e:WindowEvent=null):void {
			if (PetDataManager.petList.length > 0) {
				var idname:p_pet_id_name=PetDataManager.petList[0];
				toPetInfo(idname.pet_id);
			}
		}


		public function showPanel(lable:String=PetConstant.PET_LABEL_INFO):void {
			initView();
			//petPanel.seleteIndex(lable);
			if (WindowManager.getInstance().isPopUp(petPanel) == false) {
				WindowManager.getInstance().popUpWindow(petPanel);
				WindowManager.getInstance().centerWindow(petPanel);
			}
			updatePetList(PetDataManager.petBag);
		}

		public function openPanel(tabIndex:int=-1,removeModel:String=WindowManager.REMOVE):void {
			initView(tabIndex);
			WindowManager.getInstance().popUpWindow(petPanel,removeModel);
			WindowManager.getInstance().centerWindow(petPanel);
			if (WindowManager.getInstance().isPopUp(petPanel)) {
//				fillData();
				//petPanel.seleteIndex(PetConstant.PET_LABEL_INFO);
				var vo:m_pet_bag_info_tos=new m_pet_bag_info_tos;
				PetModule.getInstance().send(vo);
			}

		}

		public function getPanel():PetPanel {
			return petPanel;
		}

		public function showLifePanel(link:NpcLinkVO=null):void {
			initLifeView();
			WindowManager.getInstance().popUpWindow(lifeView);
			WindowManager.getInstance().centerWindow(lifeView);
		}

		public function showSkillPanel(link:NpcLinkVO=null):void {
			showPanel(PetConstant.PET_LABEL_LEARN_SKILL);
		}

		public function showSavvyView(link:NpcLinkVO=null):void {
			showPanel(PetConstant.PET_LABEL_ADD_UNDERSTANDING);
		}

		public function showPetAptitude():void {
			showPanel(PetConstant.PET_LABEL_REFRESH_APTITUDE);
		}

		public function showPetFeed(link:NpcLinkVO=null):void {
			showPanel(PetConstant.PET_LABEL_FEED);
		}

		public function showPetAttr():void {
			showPanel(PetConstant.PET_LABEL_PET_ATTR);
		}

		public function showHideState():void {
			var isShow:Boolean=PetDataManager.petList.length > 0;
			initStateView();
			if (stateView && stateView.visible != isShow) {
				stateView.visible=isShow;
			}
			if (isShow == true && PetDataManager.isBattle == false) {
				stateView.resetBattlePet();
			}
		}

		public function resetBattlePet(vo:p_map_pet=null):void {
			stateView.resetBattlePet(vo);
			initView();
			view.resetSummonBtn(vo == null);
			if (vo == null && PetDataManager.thePet == null && PetDataManager.isBattle == false) {
				var items:Array=NavigationModule.getInstance().getItems();
				for (var i:int=0; i < items.length; i++) { //清空技能栏里面的宠物群攻技能
					if (items[i].type == 1) { //type==1表示那个栏里面放的是技能
						var sk:SkillVO=SkillDataManager.getSkill(items[i].id);
						if (sk.category == PetDataManager.petTroopIn || sk.category == PetDataManager.petTroopOut) {
							NavigationModule.getInstance().clearItemAt(i);
						}
					}
				}
			}
			if (vo == null && PetDataManager.thePet == null) {
				if (skillBar && skillBar.parent) {
					skillBar.parent.removeChild(skillBar);
				}
			}
		}

		//召唤宠物
		private function toSummon(e:ParamEvent):void {
			var vo:m_pet_summon_tos=new m_pet_summon_tos;
			vo.pet_id=int(e.data);
			Connection.getInstance().sendMessage(vo);
		}

		public function onSummon(vo:m_pet_summon_toc):void {
			if (vo.succ == true) {
				PetDataManager.thePet=vo.pet_info; //记录这只的p_pet
				stateView.updateInfo(vo.pet_info);
				PetDataManager.theAttackType=vo.pet_info.attack_type;
				var hotSkills:Array=PetDataManager.makeOwnSkills(vo.pet_info.skills);
//				showSkillsBar(hotSkills);
				Tips.getInstance().addTipsMsg("成功召唤宠物！");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function showSkillsBar(skills:Array):void {
			if (skills.length > 0) {
				if (skillBar == null) {
					skillBar=new PetSkillsBar;
				}
				var pos:Point=NavigationModule.getInstance().getNacBarPos();
				skillBar.x=pos.x + 690;
				skillBar.y=pos.y - 5;
				LayerManager.uiLayer.addChild(skillBar);
				skillBar.dataProvider=skills;
			}
		}

		//收回宠物
		private function toTakeBack(e:ParamEvent):void {
			var vo:m_pet_call_back_tos=new m_pet_call_back_tos;
			vo.pet_id=PetDataManager.thePet.pet_id;
			Connection.getInstance().sendMessage(vo);
		}

		public function onTakeBack(vo:m_pet_call_back_toc):void {
			if (vo.succ == true) {
				PetDataManager.thePet=null;
				initView();
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function toThrow(e:ParamEvent):void {
			var vo:p_pet=e.data as p_pet;
			var color:uint=GameColors.getColorByIndex(vo.color);
			Alert.show("你确定要放生" + HtmlUtil.font2("【" + vo.pet_name + "】", color) + "吗？", "警告", yesThrow, null, "放生", "取消", [vo.pet_id], true);
		}

		private function yesThrow(pet_id:int):void {
			var vo:m_pet_throw_tos=new m_pet_throw_tos;
			vo.pet_id=pet_id;
			Connection.getInstance().sendMessage(vo);
		}

		public function onThrow(vo:m_pet_throw_toc):void {
			if (vo.succ == true) {
				if (vo.bag_info) {
					updatePetList(vo.bag_info);
				}
				if (vo.bag_info.pets.length == 0) {
					view.doEmpty();
				}
				Tips.getInstance().addTipsMsg("宠物成功放生");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private function toPetStore(e:Event):void {
			Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP);
		}

		//获取宠物详细信息
		public function toPetInfo(pet_id:int):void {
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=pet_id;
			vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
			Connection.getInstance().sendMessage(vo);
		}

		public function onPetInfo(vo:m_pet_info_toc):void {
			if (vo.succ == true) {
				PetDataManager.currentPetInfo = vo.pet_info;
				updatePetInfo(vo.pet_info);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}


		private function toChangeProperty(e:ParamEvent):void {
			PetModule.getInstance().send(e.data as m_pet_attr_assign_tos);
		}

		public function onChangeProperty(vo:m_pet_attr_assign_toc):void {
			if (vo.succ == true) {
				PetDataManager.updatePetInfo(vo.pet_info);
				stateView.updateInfo(vo.pet_info);
				Tips.getInstance().addTipsMsg("属性点分配成功");
			} else {
				view.clearProperty();
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//升级
		public function onLevelUp(vo:m_pet_level_up_toc):void {
			///////更新界面
			stateView.updateInfo(vo.pet_info);
			PetDataManager.updatePetInfo(vo.pet_info);
			if (petPanel) {
//				savvyView.makeUseFu(vo.pet_info);
//				aptitudeView.makeUseDrug(vo.pet_info);
//				skillView.updateInfo(vo.pet_info);
			}
			var pet_id:int=PetDataManager.thePet.pet_id;
			var pet:MutualAvatar=MutualAvatar(SceneUnitManager.getUnit(pet_id, SceneUnitType.PET_TYPE));
			if (pet != null) {
				var eImage:Effect=Effect.getEffect();
				eImage.show(GameConfig.OTHER_PATH + 'shengji_guang.swf', 0, 0, pet, 5);
				var eText:Effect=Effect.getEffect();
				eText.show(GameConfig.OTHER_PATH + 'shengji_wenzi.swf', 0, -150, pet, 5, 25);
			}
		}

		public function onLearnSkill(vo:m_pet_learn_skill_toc):void {
			if (vo.succ == true) {
				if (vo.succ2 == true) {
					PetDataManager.updatePetSkills(vo.pet_id,vo.skills);
					Tips.getInstance().addTipsMsg("恭喜！您的宠物又学会了新的技能！");
				} else {
					Tips.getInstance().addTipsMsg("技能学习失败了，不要气馁，再试一次吧！");
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			skillView.updateSkillBookList();
		}

		public function onAddLife(vo:m_pet_add_life_toc):void {
			initLifeView();
			if (vo.succ == true) {
				lifeView.updateLife(vo);
				view.updateLife(vo.pet_id, vo.life);
				Tips.getInstance().addTipsMsg("恭喜！您的宠物寿命延长了！");

			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			lifeView.updateUseItemItemNum();
		}

		public function onChangeName(vo:m_pet_change_name_toc):void {
			if (vo.succ == true) {
				Tips.getInstance().addTipsMsg("恭喜！您的宠物改名了！");
				view.updateName(vo);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		public function onAddSavvy(vo:m_pet_add_understanding_toc):void {
			if (vo.succ == true) {
				if (vo.succ2 == true) {
					Tips.getInstance().addTipsMsg("恭喜！您的宠物提悟成功了！");
				} else {
					Tips.getInstance().addTipsMsg("提悟失败了，不要气馁，再试一次吧！");
				}
				stateView.updateInfo(vo.pet_info);
				PetDataManager.updatePetInfo(vo.pet_info);
//				savvyView.makeUseFu(vo.pet_info);
//				aptitudeView.makeUseDrug(vo.pet_info);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			savvyView.updateUseItemNum();
		}

		public function onRefreshApt(vo:m_pet_refresh_aptitude_toc):void {
			if (vo.succ == true) {
				Tips.getInstance().addTipsMsg("恭喜！您的宠物洗灵成功了！");
				updatePetInfo(vo.pet_info);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			aptitudeView.updateUseItemNum();
		}

		//更新某个属性
		public function onAttrChange(vo:m_pet_attr_change_toc):void {
			if (PetDataManager.thePet != null && vo.pet_id == PetDataManager.thePet.pet_id) {
				switch (vo.change_type) {
					case 10: //寿命
						break;
					case 11: //经验
						stateView.updateExp(vo.value);
						break;
					case 12: //出战宠物的当前血
						stateView.updateBlood(vo.value);
						break;
					case 13: //出战宠物的总血量
						stateView.updateBloodMax(vo.value);
						break;
				}
			}
		}


		public function onFeedBegin(vo:m_pet_feed_begin_toc):void {
			if (vo.succ == true) {
				feedView.updateFeed(vo.info);
				feedView.updateUseItemNum();
			} else
				Tips.getInstance().addTipsMsg(vo.reason);
		}

		public function onFeedCommit(vo:m_pet_feed_commit_toc):void {
			if (vo.succ == true) {
				feedView.updateFeed(vo.info);
				feedView.updatePetLevelAndExp(vo.pet_info);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		public function onFeedGiveUp(vo:m_pet_feed_give_up_toc):void {
			if (vo.succ == true) {
				BroadcastSelf.getInstance().appendMsg("已放弃本次宠物训练");
				feedView.updateFeed(vo.info);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}


		public function onFeedInfo(vo:m_pet_feed_info_toc):void {
//			if (vo.succ == true) {
//				initView();
//				feedView.updateFeed(vo.info);
//
//			} else {
//				Tips.getInstance().addTipsMsg(vo.reason);
//			}
		}


		public function onFeedOver(vo:m_pet_feed_over_toc):void {
			feedView.feedOver(vo.pet_id);
		}


		public function onFeedStarUp(vo:m_pet_feed_star_up_toc):void {
			if (vo.succ == true) {
				if (vo.succ2 == true)
					Tips.getInstance().addTipsMsg("星级成功提升为" + vo.info.star_level + "星");
				else
					Tips.getInstance().addTipsMsg("星级提升失败");
				feedView.updateFeed(vo.info);
			} else
				Tips.getInstance().addTipsMsg(vo.reason);
		}

		//获取玩家训宠信息
		public function toPetGrowInfo():void {
			var vo:m_pet_grow_info_tos=new m_pet_grow_info_tos;
			Connection.getInstance().sendMessage(vo);
		}

		//获取玩家训宠信息
		public function onPetGrowInfo(vo:m_pet_grow_info_toc):void {
			if (vo.succ == true) {
				Dispatch.dispatch(ModuleCommand.UPDATE_PET_GROW, {"grow_info": vo.grow_info, "info_configs": vo.info_configs});
			} else
				Tips.getInstance().addTipsMsg(vo.reason);
		}

		public function onPetChangeIndex(vo:m_pet_change_pos_toc):void {
			PetInfoView.upDownAbled=true;
			if (vo.succ == true) {
				if (vo.info) {
					updatePetList(vo.info);
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//遗忘技能
		public function onForgetSkill(vo:m_pet_forget_skill_toc):void {
			if (vo.succ == true) {
				updatePetInfo(vo.pet_info);
				Tips.getInstance().addTipsMsg("操作成功");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//开技能栏
		public function onAddSkillGrid(vo:m_pet_add_skill_grid_toc):void {
			if (vo.succ == true) {
				updatePetInfo(vo.pet_info);
				Tips.getInstance().addTipsMsg("操作成功");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//宠物退役
		public function onRefiningEXP(vo:m_pet_refining_exp_toc):void {
			PetInfoView.retireAbled=true;
			if (vo.succ == true) {
				var ownMoney:int=GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind;
				if (ownMoney < vo.silver) {
					Dispatch.dispatch(ModuleCommand.TIPS, "你的银子不足，完成拉镖或商贸可获得银子。");
					return;
				}
				var money:String=MoneyTransformUtil.silverToOtherString(vo.silver);
				Alert.show("使【" + vo.pet_name + "】退役需要花费" + HtmlUtil.font(money, "#ff0000") + "，退役后宠物消失，将获得一个" + HtmlUtil.font(vo.exp + "点", "#ff0000") + "的【宠物经验葫芦】", "宠物退役", toRefining, null, "确定", "取消", [vo.pet_id], true);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//宠物退役
		private function toRefining(pet_id:int):void {
			var vo:m_pet_refining_tos=new m_pet_refining_tos;
			vo.pet_id=pet_id;
			Connection.getInstance().sendMessage(vo);
		}

		//宠物退役
		public function onRefining(vo:m_pet_refining_toc):void {
			if (vo.succ == true) {
				updatePetList(vo.info);
				Tips.getInstance().addTipsMsg("宠物退役成功，你获得了一个【宠物经验葫芦】！");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		public function toPetGrowBegin(type:int):void {
			var vo:m_pet_grow_begin_tos=new m_pet_grow_begin_tos;
			vo.grow_type=type;
			Connection.getInstance().sendMessage(vo);
		}

		public function onGrowBegin(vo:m_pet_grow_begin_toc):void {
			if (vo.succ == true) {
				BroadcastSelf.getInstance().appendMsg("<font color='#ffff00'>成功开始了驯宠能力训练。</font>");
				Dispatch.dispatch(ModuleCommand.UPDATE_PET_GROW, {"grow_info": vo.grow_info, "info_configs": vo.info_configs});
			} else
				Tips.getInstance().addTipsMsg(vo.reason);
		}

		public function toPetGrowCommit():void {
			var vo:m_pet_grow_commit_tos=new m_pet_grow_commit_tos;
			Connection.getInstance().sendMessage(vo);
		}

		public function onGrowCommit(vo:m_pet_grow_commit_toc):void {
			if (vo.succ == true) {
				var str:String="<font color='#ffff00'>花费" + vo.use_gold + "元宝，快速提升了驯宠能力！</font>";
				BroadcastSelf.getInstance().appendMsg(str);
				Dispatch.dispatch(ModuleCommand.UPDATE_PET_GROW, {"grow_info": vo.grow_info, "info_configs": vo.info_configs});
			} else
				Tips.getInstance().addTipsMsg(vo.reason);
		}

		public function toPetGrowGiveUp():void {
			var vo:m_pet_grow_give_up_tos=new m_pet_grow_give_up_tos;
			Connection.getInstance().sendMessage(vo);
		}


		public function onGrowGiveUp(vo:m_pet_grow_give_up_toc):void {
			if (vo.succ == true) {
				Dispatch.dispatch(ModuleCommand.UPDATE_PET_GROW, {"grow_info": vo.grow_info, "info_configs": vo.info_configs});
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		public function onGrowOver(vo:m_pet_grow_over_toc):void {
			var growNameArr:Array=getGrowName(vo.grow_type);
			var addValue:int=0;
			var lv:int=0;
			for (var i:int=0; i < 5; i++) {
				var info:p_grow_info=vo.info_configs[i] as p_grow_info;
				if (info.type == vo.grow_type) {
					addValue=info.add_value;
					lv=info.level - 1;
					break;
				}
			}

			var msg:String="<b>成功提升：</b>" + growNameArr[1] + "到" + lv + "级<br>";
			msg+="<b>    下一级效果：</b>" + growNameArr[0] + "+" + addValue;
			BroadcastModule.getInstance().popup(msg, "查看驯宠能力", openPetGrowPanel, null, 0);

			//BroadcastModule.getInstance().popup("您的驯宠能力已成功提升！", "查看驯宠能力", openPetGrowPanel, null, 0);
			Dispatch.dispatch(ModuleCommand.UPDATE_PET_GROW, vo);
		}

		//--训宠技能OK，获取对应的名称。
		private function getLifeAdd(level:int):int {
			var a1:int=0;
			for (var i:int=1; i <= level; i++) {
				a1+=(i - 1);
			}
			return a1;
		}

		private function getGrowName(type:int):Array {
			switch (type) {
				case 1:
					return ["宠物外攻", "力敌千钧"];
				case 2:
					return ["宠物内攻", "以柔克刚"];
				case 3:
					return ["宠物外防", "刀枪不入"];
				case 4:
					return ["宠物内防", "气运丹田"];
				case 5:
					return ["宠物生命", "神功护体"];
			}
			return null;
		}

		private function openPetGrowPanel():void {
			Dispatch.dispatch(ModuleCommand.ONEP_SKILL_TREE, SkillConstant.CATEGORY_LABEL_PETGROW);
		}

		public function hookLevelUpToNoticeGrow():void {
			if (GlobalObjectManager.getInstance().user.attr.level >= 25 && GlobalObjectManager.getInstance().user.attr.level % 3 == 1) {
				if (SkillPetGrowView.state == 0 || SkillPetGrowView.state == 1) {
					BroadcastModule.getInstance().popup("您有新的驯宠能力可提升啦！", "查看驯宠能力", openPetGrowPanel, null, 0);
				}
			}
		}

		public function updatePetViewItemNum(typeId:int):void {
			initView();
			if (typeId == 12300134) {
				feedView.updateUseItemNum();
			} else if (typeId >= 12300118 && typeId <= 12300120) {
				aptitudeView.updateUseItemNum();
			} else if (typeId >= 12300121 && typeId <= 12300123) {
				savvyView.updateUseItemNum();
			} else {
				skillView.updateSkillBookList();
			}
		}

		////////宠物蛋
		public function onEggAdopt(vo:m_pet_egg_adopt_toc):void { //领养
			initHatchView();
			if (vo.succ) {
				hatchPanel.onAdopt();
				var petName:String=PetConfig.getPetMsg(vo.type_id);
				if (petName) {
					Tips.getInstance().addTipsMsg("恭喜你成功领养【" + petName + "】");
				}
			} else {
				Dispatch.dispatch(ModuleCommand.TIPS, vo.reason);
			}
		}

		public function onEggRefresh(vo:m_pet_egg_refresh_toc):void { //用钱刷新
			initHatchView();
			if (vo.succ) {
				hatchPanel.onRefresh(vo);
			} else {
				Dispatch.dispatch(ModuleCommand.TIPS, vo.reason);
			}
		}

		public function onEggUse(vo:m_pet_egg_use_toc):void { //使用
			initHatchView();
			if (vo.succ == true) {
				if (WindowManager.getInstance().isPopUp(hatchPanel) == false) {
					WindowManager.getInstance().popUpWindow(hatchPanel);
					WindowManager.getInstance().centerWindow(hatchPanel);
				}
				hatchPanel.onUseEgg(vo);
			} else {
				Dispatch.dispatch(ModuleCommand.TIPS, vo.reason);
			}
		}

		//重新领悟
		public function onTrickLearn(vo:m_pet_trick_learn_toc):void {
			if (vo.succ == true) {
				updatePetInfo(vo.pet_info);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//特殊技能升级
		public function onTrickUpgrade(vo:m_pet_trick_upgrade_toc):void {
			if (vo.succ == true) {
				updatePetInfo(vo.pet_info);
				if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == vo.pet_info.pet_id) {
					var hotSkills:Array=PetDataManager.makeOwnSkills(vo.pet_info.skills); //学了技能要更新技能
					showSkillsBar(hotSkills);
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		//扩展宠物包
		public function onAddPetBag(vo:m_pet_add_bag_toc):void {
			if (vo.succ == true) {
				if (vo.info && vo.info.pets) {
					vo.info.pets.sortOn("index");
				}
				updatePetList(vo.info);
				Tips.getInstance().addTipsMsg("宠物栏已扩展到" + vo.info.content + "格");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		public function toActionPetForNewPlayer():void {
			var vo:m_pet_summon_tos=new m_pet_summon_tos;
			if (PetDataManager.petList.length > 0) {
				vo.pet_id=PetDataManager.petList[0].pet_id;
			}
			Connection.getInstance().sendMessage(vo);
		}

		public function onStageRezise(value:Object):void {
			if (skillBar) {
				var pos:Point=NavigationModule.getInstance().getNacBarPos();
				skillBar.x=pos.x + 690;
				skillBar.y=pos.y - 5;
			}
		}
		
		public function onTrainingRequest(vo:m_pet_training_request_toc):void{
			if(vo.succ){
				switch(vo.op_type){
					case 1:
						PetDataManager.petTrainingInfo = vo.pet_training_list;
						PetDataManager.trainingRoom = vo.cur_room;
						petPanel.petTrainingView.setCurRoom();
						break;
					case 2:
						PetDataManager.trainingRoom = vo.cur_room;
						petPanel.petTrainingView.setCurRoom();
						break;
					case 3:
						PetDataManager.petTrainingInfo = vo.pet_training_list;
						break;
					case 4:
						PetDataManager.petTrainingInfo = vo.pet_training_list;
						Tips.getInstance().addTipsMsg("本次宠物训练已结束,获取经验"+vo.pet_training_info.total_get_exp);
						break;
					case 7:
						PetDataManager.petTrainingInfoDic[vo.pet_training_info.pet_id] = vo.pet_training_info;
						petPanel.petTrainingView.setCurrentPetData();
						Tips.getInstance().addTipsMsg("更改训练模式成功");
						break;
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		public function getTrainingInfo():void{
			var vo:m_pet_training_request_tos = new m_pet_training_request_tos();
			vo.op_type = 1;
			Connection.getInstance().sendMessage(vo);
		}
	}
}
