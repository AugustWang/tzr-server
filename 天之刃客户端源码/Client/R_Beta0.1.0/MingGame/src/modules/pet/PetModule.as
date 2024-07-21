package modules.pet {
	import com.Message;
	import com.globals.GameConfig;
	import com.loaders.ViewLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import flash.filters.ColorMatrixFilter;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.npc.NPCActionType;
	import modules.pet.newView.PetPanel;

	public class PetModule extends BaseModule {
		private static var _instance:PetModule;
		private var inited:Boolean;
		public var mediator:PetMediator;
		public static var filter:ColorMatrixFilter=new ColorMatrixFilter([1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]);

		public function PetModule() {
			mediator=new PetMediator;
			super();
			if (_instance != null) {
				throw new Error("PetModule只能存在一个实例。");
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, mediator.showState);
			addMessageListener(ModuleCommand.OPEN_OR_CLOSE_PET_MAIN, mediator.openPanel);
			addMessageListener(ModuleCommand.PET_LIST_CHANGED, mediator.showHideState); //显示宠物状态面板
			addMessageListener(ModuleCommand.BATTLE_PET_CHANGE, mediator.resetBattlePet); //显示宠物状态面板
			addMessageListener(ModuleCommand.OPEN_PET_SKILL, mediator.showSkillPanel); //打开宠物技能面板
			addMessageListener(ModuleCommand.OPEN_PET_LIFE, mediator.showLifePanel); //延寿
			addMessageListener(ModuleCommand.OPEN_PET_FEED, mediator.showPetFeed);
			addMessageListener(NPCActionType.NA_5, mediator.showLifePanel); //延寿
			addMessageListener(ModuleCommand.OPEN_PET_SAVVY, mediator.showSavvyView); //提悟
			addMessageListener(ModuleCommand.ROLE_LEVEL_UP, mediator.hookLevelUpToNoticeGrow);
			addMessageListener(ModuleCommand.GET_PET_GROW_INFO, mediator.toPetGrowInfo);
			addMessageListener(ModuleCommand.MISSION_NEW_PLAYER_PET_TASK, mediator.toActionPetForNewPlayer);
			addMessageListener(ModuleCommand.STAGE_RESIZE, mediator.onStageRezise);
			addMessageListener(ModuleCommand.OPEN_PET_APTITUDE, mediator.showPetAptitude); //洗灵
			addSocketListener(SocketCommand.PET_ATTR_CHANGE, mediator.onAttrChange);
			addSocketListener(SocketCommand.PET_SUMMON, mediator.onSummon);
			addSocketListener(SocketCommand.PET_CALL_BACK, mediator.onTakeBack);
			addSocketListener(SocketCommand.PET_THROW, mediator.onThrow);
			addSocketListener(SocketCommand.PET_LEARN_SKILL, mediator.onLearnSkill);
			addSocketListener(SocketCommand.PET_LEVEL_UP, mediator.onLevelUp);
			addSocketListener(SocketCommand.PET_INFO, mediator.onPetInfo);
			addSocketListener(SocketCommand.PET_BAG_INFO, mediator.onPetBag);
			addSocketListener(SocketCommand.PET_ATTR_ASSIGN, mediator.onChangeProperty);
			addSocketListener(SocketCommand.PET_ADD_LIFE, mediator.onAddLife);
			addSocketListener(SocketCommand.PET_CHANGE_NAME, mediator.onChangeName);
			addSocketListener(SocketCommand.PET_ADD_UNDERSTANDING, mediator.onAddSavvy);
			addSocketListener(SocketCommand.PET_FEED_BEGIN, mediator.onFeedBegin);
			addSocketListener(SocketCommand.PET_FEED_COMMIT, mediator.onFeedCommit);
			addSocketListener(SocketCommand.PET_FEED_GIVE_UP, mediator.onFeedGiveUp);
			addSocketListener(SocketCommand.PET_FEED_INFO, mediator.onFeedInfo);
			addSocketListener(SocketCommand.PET_FEED_OVER, mediator.onFeedOver);
			addSocketListener(SocketCommand.PET_FEED_STAR_UP, mediator.onFeedStarUp);
			addSocketListener(SocketCommand.PET_REFRESH_APTITUDE, mediator.onRefreshApt);

			addSocketListener(SocketCommand.PET_GROW_BEGIN, mediator.onGrowBegin);
			addSocketListener(SocketCommand.PET_GROW_COMMIT, mediator.onGrowCommit);
			addSocketListener(SocketCommand.PET_GROW_GIVE_UP, mediator.onGrowGiveUp);
			addSocketListener(SocketCommand.PET_GROW_OVER, mediator.onGrowOver);
			addSocketListener(SocketCommand.PET_GROW_INFO, mediator.onPetGrowInfo);
			addSocketListener(SocketCommand.PET_CHANGE_POS, mediator.onPetChangeIndex);
			addSocketListener(SocketCommand.PET_FORGET_SKILL, mediator.onForgetSkill);
			addSocketListener(SocketCommand.PET_ADD_SKILL_GRID, mediator.onAddSkillGrid);
			addSocketListener(SocketCommand.PET_REFINING, mediator.onRefining);
			addSocketListener(SocketCommand.PET_REFINING_EXP, mediator.onRefiningEXP);
			addSocketListener(SocketCommand.PET_EGG_ADOPT, mediator.onEggAdopt);
			addSocketListener(SocketCommand.PET_EGG_REFRESH, mediator.onEggRefresh);
			addSocketListener(SocketCommand.PET_EGG_USE, mediator.onEggUse);
			addSocketListener(SocketCommand.PET_TRICK_LEARN, mediator.onTrickLearn);
			addSocketListener(SocketCommand.PET_TRICK_UPGRADE, mediator.onTrickUpgrade);
			addSocketListener(SocketCommand.PET_ADD_BAG, mediator.onAddPetBag);
			
			addSocketListener(SocketCommand.PET_TRAINING_REQUEST, mediator.onTrainingRequest);
		}


		public function send(vo:Message):void {
			sendSocketMessage(vo);
		}

		public static function getInstance():PetModule {
			if (_instance == null) {
				_instance=new PetModule;
			}
			return _instance;
		}
	}
}