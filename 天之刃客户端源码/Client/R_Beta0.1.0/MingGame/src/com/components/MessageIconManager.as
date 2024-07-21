package com.components {
	import com.common.GlobalObjectManager;
	import com.components.alert.Prompt;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Image;
	
	import flash.events.MouseEvent;
	
	import modules.Activity.ActivityModule;
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.educate.EducateModule;
	import modules.family.views.FamilyYBCTimer;
	import modules.friend.views.AcceptFriendLuckPanel;
	import modules.help.HelpManager;
	import modules.help.IntroduceConstant;
	import modules.navigation.NavigationModule;
	import modules.personalybc.view.PersonybcFactionTipsView;
	import modules.playerGuide.GuideConstant;
	import modules.scene.SceneDataManager;
	import modules.spy.SpyModule;
	import modules.spy.views.spyFactionTipsView;
	import modules.stat.StatConstant;
	import modules.trading.TradingModule;
	
	import proto.common.p_role;

	public class MessageIconManager extends BaseModule {
		private var level:int;
		private var queueIcons:Vector.<MessageIcon>=new Vector.<MessageIcon>;
		private var specialIcons:Vector.<MessageIcon>=new Vector.<MessageIcon>;
		private static const MAX_SHOW_NUM:int=2;

		private static var _instance:MessageIconManager;

		public static function getInstance():MessageIconManager {
			if (_instance == null)
				_instance=new MessageIconManager();
			return _instance;
		}

		public function MessageIconManager() {
			super();
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
			addMessageListener(GuideConstant.LEVEL_UP, onLevelUp);

			addMessageListener(ModuleCommand.CHANGE_FAMILY, showFamilyIcon);

		}

		private function onEnterGame():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			checkIconState();
		}

		private function onLevelUp():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			checkIconState();
		}

		private function checkIconState():void {
			showShouChongIcon();
			showFamilyIcon();
			showPoyanghuIcon();
			showEquipRefineIcon();
			showMoneyIcon();
			showAccumulateIcon();
			showPetTrainingIcon();
			showTakePetMapIcon();
			showNeedfireIcon();
			showSafetyMapIcon();
			update();
		}

		private function addToSprecial(icon:MessageIcon):void {
			if (specialIcons.indexOf(icon) == -1) {
				specialIcons.push(icon);
				update();
			}
		}

		private function addToQueue(icon:MessageIcon):void {
			if (queueIcons.indexOf(icon) == -1) {
				queueIcons.push(icon);
				update();
			}
		}

		private function removeFromSpecialIcons(icon:MessageIcon):void {
			var index:int=specialIcons.indexOf(icon);
			if (index != -1) {
				specialIcons.splice(index, 1);
				update();
			}
		}

		private function removeFromQueueIcons(icon:MessageIcon):void {
			var index:int=queueIcons.indexOf(icon);
			if (index != -1) {
				queueIcons.splice(index, 1);
				update();
			}
		}

		private function queueSort(iconA:MessageIcon, iconB:MessageIcon):int {
			if (!iconA.hasClick && iconB.hasClick) {
				return -1;
			} else if (iconA.hasClick && !iconB.hasClick) {
				return 1;
			} else if (iconA.createTime > iconB.createTime) {
				return 1;
			} else if (iconA.createTime < iconB.createTime) {
				return -1;
			}
			return 0;
		}

		private function filtreQueue():Vector.<MessageIcon> {
			var result:Vector.<MessageIcon>=queueIcons.sort(queueSort);
			return result.slice(0, MAX_SHOW_NUM);
		}

		private function iconSort(iconA:MessageIcon, iconB:MessageIcon):int {
			if (iconA.createTime > iconB.createTime) {
				return -1;
			} else if (iconA.createTime < iconB.createTime) {
				return 1;
			}
			return 0;
		}

		private function update():void {
			var icons:Vector.<MessageIcon>=new Vector.<MessageIcon>;
			var queueSortResult:Vector.<MessageIcon>=filtreQueue();
			icons=specialIcons.concat(queueSortResult);
			var result:Vector.<MessageIcon>=new Vector.<MessageIcon>;
			result=icons.sort(iconSort);
			LayerManager.uiLayer.removeAllIcon();
			var l:int=result.length;
			for (var i:int=0; i < l; i++) {
				LayerManager.uiLayer.addIcon(result[i]);
			}
		}

		private function onIconClick():void {
			update();
		}

		/**
		 *众志成城 门派
		 * familyItem=new MessageIcon("familyIcon");
		   familyItem.getModuleId = StatConstant.VALUE_FAMILY;
		   familyItem.callBack=onItemClick;
		   familyItem.tip="赶快去加入门派吧!";
		 */
		private var familyIcon:MessageIcon;

		public function showFamilyIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			var familyId:int=GlobalObjectManager.getInstance().user.base.family_id;
			if (level >= 25 && familyId == 0) {
				if (!familyIcon) {
					familyIcon=new MessageIcon("familyIcon");
					familyIcon.getModuleId=StatConstant.VALUE_FAMILY;
					familyIcon.tip="赶快去加入门派吧!";
					familyIcon.callBack=onFamilyClick;
					familyIcon.startFlick();
					familyIcon.show();
					addToQueue(familyIcon);
				}
			} else {
				if (familyIcon != null) {
					familyIcon.stopFlick();
					familyIcon.hide();
					removeFromQueueIcons(familyIcon);
					familyIcon=null;
				}
			}
			function onFamilyClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.FAMILY);
			}
		}

		/**
		 *拜师收徒
		 */
		private var teacherIcon:MessageIcon;

		public function showTeacherIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			var hasTeacher:Boolean=EducateModule.getInstance().educateInfo.teacher != 0;
			var hasStudent:Boolean=EducateModule.getInstance().educateInfo.student_num > 0;
			if (level >= 15 && level < 31 && !hasTeacher && !hasStudent) {
				if (teacherIcon == null) {
					teacherIcon=new MessageIcon("teacherIcon");
					teacherIcon.getModuleId=StatConstant.VALUE_BAI_SHI;
					teacherIcon.tip="拜师收徒";
					teacherIcon.callBack=onTeacherClick;
					teacherIcon.show();
					addToQueue(teacherIcon);
				}
			} else {
				if (teacherIcon != null) {
					teacherIcon.hide();
					removeFromQueueIcons(teacherIcon);
					teacherIcon=null;
				}
			}
			function onTeacherClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.EDUCATE);
			}
		}


		/**
		 *训练有方
		 */
		private var petTrainingIcon:MessageIcon;
		private var PT_HasClick:Boolean=false;

		public function showPetTrainingIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 25 && level < 29 && !PT_HasClick) {
				if (!petTrainingIcon) {
					petTrainingIcon=new MessageIcon("xunlianyoufangIcon");
					petTrainingIcon.getModuleId=StatConstant.VALUE_XUN_LIAN_YOU_FANG;
					petTrainingIcon.tip="训练有方";
					petTrainingIcon.callBack=onPetTrainingClick;
					petTrainingIcon.show();
					addToQueue(petTrainingIcon);
				}
			} else {
				if (petTrainingIcon != null) {
					petTrainingIcon.hide();
					removeFromQueueIcons(petTrainingIcon);
					petTrainingIcon=null;
				}
			}
			function onPetTrainingClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.XUN_LIAN_YOU_FANG);
				PT_HasClick=true;
				petTrainingIcon.hide();
				removeFromQueueIcons(petTrainingIcon);
				petTrainingIcon=null;
			}
		}

		/**
		 * 鄱阳湖大战
		 */
		private var poyanghuIcon:MessageIcon;
		private var PYH_HasClick:Boolean=false;

		private function showPoyanghuIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 28 && level < 36 && !PYH_HasClick) {
				if (!poyanghuIcon) {
					poyanghuIcon=new MessageIcon("poyanghu");
					poyanghuIcon.getModuleId=StatConstant.VALUE_PO_YANG_HU;
					poyanghuIcon.tip="副本：鄱阳湖大战";
					poyanghuIcon.callBack=onPoyanghuClick;
					poyanghuIcon.startFlick();
					poyanghuIcon.show();
					addToQueue(poyanghuIcon);
				}
			} else {
				if (poyanghuIcon != null) {
					poyanghuIcon.hide();
					removeFromQueueIcons(poyanghuIcon);
					poyanghuIcon=null;
				}
			}
			function onPoyanghuClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.POYANGHU_HELP);
				PYH_HasClick=true;
				poyanghuIcon.hide();
				removeFromQueueIcons(poyanghuIcon);
				poyanghuIcon=null;
			}
		}

		/**
		 *神农架
		 */
		private var takePetMapIcon:MessageIcon;
		private var TPM_HasClick:Boolean=false;

		public function showTakePetMapIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 30 && level < 35 && !TPM_HasClick) {
				if (!takePetMapIcon) {
					takePetMapIcon=new MessageIcon("shennongjiaIcon");
					takePetMapIcon.getModuleId=StatConstant.VALUE_SHEN_NONG_JIA;
					takePetMapIcon.tip="神农架";
					takePetMapIcon.callBack=onTakePetMapClick;
					takePetMapIcon.show();
					addToQueue(takePetMapIcon);
				}
			} else {
				if (takePetMapIcon != null) {
					takePetMapIcon.hide();
					removeFromQueueIcons(takePetMapIcon);
					takePetMapIcon=null;
				}
			}
			function onTakePetMapClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.SHENNONGJIA);
				TPM_HasClick=true;
				takePetMapIcon.hide();
				removeFromQueueIcons(takePetMapIcon);
				takePetMapIcon=null;
			}
		}

		/**
		 *神兵利器
		 * @return
		 *
		 */
		private var equipRefineIcon:MessageIcon;

		private function showEquipRefineIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 28 && level < 35) {
				if (!equipRefineIcon) {
					equipRefineIcon=new MessageIcon("shenbingliqiIcon");
					equipRefineIcon.getModuleId=StatConstant.VALUE_SHEN_BIN_LI_QI;
					equipRefineIcon.tip="装备打造和精炼";
					equipRefineIcon.callBack=onEquipRefineClick;
					equipRefineIcon.show();
					addToQueue(equipRefineIcon);
				}
			} else {
				if (equipRefineIcon != null) {
					equipRefineIcon.hide();
					removeFromQueueIcons(equipRefineIcon);
					equipRefineIcon=null;
				}
			}
			function onEquipRefineClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.SHENBINGLIQI);
				onIconClick();
			}
		}


		/**
		 *篝火needfire
		 */
		private var needfireIcon:MessageIcon;
		private var NF_HasClick:Boolean=false;

		public function showNeedfireIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 23 && level < 31 && !NF_HasClick) {
				if (!needfireIcon) {
					needfireIcon=new MessageIcon("gouhuoIcon");
					needfireIcon.getModuleId=StatConstant.VALUE_GOU_HUO;
					needfireIcon.tip="篝火";
					needfireIcon.callBack=onNeedfireClick;
					needfireIcon.show();
					addToQueue(needfireIcon);
				}
			} else {
				if (needfireIcon != null) {
					needfireIcon.hide();
					removeFromQueueIcons(needfireIcon);
					needfireIcon=null;
				}
			}
			function onNeedfireClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.GOUHUO);
				NF_HasClick=true;
				needfireIcon.hide();
				removeFromQueueIcons(needfireIcon);
				needfireIcon=null;
			}
		}

		/**
		 * 高枕无忧
		 */
		private var safetyMapIcon:MessageIcon;
		private var SM_HasClick:Boolean=false;

		public function showSafetyMapIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 30 && level < 36 && !SM_HasClick) {
				if (!safetyMapIcon) {
					safetyMapIcon=new MessageIcon("gaozhenwuyouIcon");
					safetyMapIcon.getModuleId=StatConstant.VALUE_GAO_ZHEN_WU_YOU;
					safetyMapIcon.tip="高枕无忧";
					safetyMapIcon.callBack=onSafetyMapClick;
					safetyMapIcon.show();
					addToQueue(safetyMapIcon);
				}
			} else {
				if (safetyMapIcon != null) {
					safetyMapIcon.hide();
					removeFromQueueIcons(safetyMapIcon);
					safetyMapIcon=null;
				}
			}
			function onSafetyMapClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.GAOZHENWUYOU);
				SM_HasClick=true;
				safetyMapIcon.hide();
				removeFromQueueIcons(safetyMapIcon);
				safetyMapIcon=null;
			}
		}

		/**
		 *财源广进
		 */
		private var moneyIcon:MessageIcon;

		public function showMoneyIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 29 && level < 35) {
				if (!moneyIcon) {
					moneyIcon=new MessageIcon("caiyuanguangjinIcon");
					moneyIcon.getModuleId=StatConstant.VALUE_CAI_YUAN_GUANG_JIN;
					moneyIcon.tip="财源广进";
					moneyIcon.callBack=onMoneyClick;
					moneyIcon.show();
					addToQueue(moneyIcon);
				}
			} else {
				if (moneyIcon != null) {
					moneyIcon.hide();
					removeFromQueueIcons(moneyIcon);
					moneyIcon=null;
				}
			}
			function onMoneyClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.CAIYOUGUANGJIN);
			}
		}

		/**
		 *突飞猛进
		 */
		private var accumulateIcon:MessageIcon;
		private var AL_HasClick:Boolean=false;

		public function showAccumulateIcon():void {
			level=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 30 && level < 35 && !AL_HasClick) {
				if (!accumulateIcon) {
					accumulateIcon=new MessageIcon("tufeimengjinIcon");
					accumulateIcon.getModuleId=StatConstant.VALUE_TU_FEI_MENG_JIN;
					accumulateIcon.tip="突飞猛进";
					accumulateIcon.callBack=onAccumulateClick;
					accumulateIcon.show();
					addToQueue(accumulateIcon);
				}
			} else {
				if (accumulateIcon != null) {
					accumulateIcon.hide();
					removeFromQueueIcons(accumulateIcon);
					accumulateIcon=null;
				}
			}
			function onAccumulateClick():void {
				HelpManager.getInstance().openIntroduce(IntroduceConstant.TUFEIMENGJIN);
				AL_HasClick=true;
				accumulateIcon.hide();
				removeFromQueueIcons(accumulateIcon);
				accumulateIcon=null;
			}
		}

		/**
		 * 显示好友祝福图标
		 */
		private var friendLuckInfos:Array;
		private var friendLuckIcon:MessageIcon;

		public function showFriendLuckIcon(info:Object):void {
			if (!friendLuckIcon) {
				friendLuckIcon=new MessageIcon("friendLuck");
				friendLuckIcon.getModuleId=StatConstant.VALUE_HAO_YOU_ZHU_FU;
				friendLuckIcon.callBack=clickGoodLuckHandler;
				friendLuckIcon.tip="好友祝福";
			}
			if (!friendLuckInfos) {
				friendLuckInfos=[];
			}
			friendLuckInfos.push(info);
			friendLuckIcon.show();
			friendLuckIcon.startFlick();
			addToSprecial(friendLuckIcon);
			function clickGoodLuckHandler():void {
				var obj:Object=friendLuckInfos.shift();
				if (obj) {
					var s:AcceptFriendLuckPanel=new AcceptFriendLuckPanel();
					s.setLuck(obj.from_friend, obj.congratulation);
					WindowManager.getInstance().popUpWindow(s);
					WindowManager.getInstance().centerWindow(s);
					removeFriendLuckIcon();
				}
			}
		}

		public function removeFriendLuckIcon():void {
			if (!friendLuckInfos || (friendLuckInfos && friendLuckInfos.length == 0)) {
				if (friendLuckIcon) {
					friendLuckIcon.stopFlick();
					friendLuckIcon.hide();
					removeFromSpecialIcons(friendLuckIcon);
				}
				friendLuckIcon=null;
				friendLuckInfos=null;
			}
		}

		/**
		 * 显示可以祝福好友的功能图标
		 */
		private var goodLuckInfos:Array;
		private var goodLuckIcon:MessageIcon

		public function showGoodLuckIcon(info:Object):void {
			if (!goodLuckIcon) {
				goodLuckIcon=new MessageIcon("zhufu");
				goodLuckIcon.getModuleId=StatConstant.VALUE_ZHU_FU;
				goodLuckIcon.callBack=sendGoodLuckHandler;
				goodLuckIcon.tip="送去祝福";
			}
			if (!goodLuckInfos) {
				goodLuckInfos=[];
			}
			goodLuckInfos.push(info);
			goodLuckIcon.show();
			goodLuckIcon.startFlick();
			addToSprecial(goodLuckIcon);
			function sendGoodLuckHandler():void {
				var obj:Object=goodLuckInfos.shift();
				if (obj) {
					obj.handler(obj.friendName, obj.friendId, obj.level);
					removeGoodLuckIcon();
				}
			}
		}

		public function removeGoodLuckIcon():void {
			if (!goodLuckInfos || (goodLuckInfos && goodLuckInfos.length == 0)) {
				if (goodLuckIcon) {
					goodLuckIcon.stopFlick();
					goodLuckIcon.hide();
					removeFromSpecialIcons(goodLuckIcon);
				}
				goodLuckIcon=null;
				goodLuckInfos=null;
			}
		}

		/**
		 * 显示技能升级按钮
		 */
		private var skillIcon:MessageIcon;

		public function showLevelSkillIcon(skillCall:Function):void {
			if (!skillIcon) {
				skillIcon=new MessageIcon("skillIcon");
				skillIcon.getModuleId=StatConstant.VALUE_JI_NENG_SHENG_JI;
				skillIcon.tip="有可升级的技能";
				skillIcon.callBack=skillCall;
			}
			skillIcon.show();
			skillIcon.startFlick();
			addToSprecial(skillIcon);
		}

		/**
		 *  显示升级按钮 (特殊处理不显示图标 在人物头像处闪)
		 */
		private var hasClose:Boolean=false;
		private var callFunc:Function;

		public function showLevelUpIcon(call:Function):void {
			var user:p_role=GlobalObjectManager.getInstance().user;
			if (user.base.status == 1)
				return;
			if (user.attr.exp >= user.attr.next_level_exp && user.attr.level >= 20) {
				if (user.attr.level < 100) {
					NavigationModule.getInstance().startRoleFlick();
				}
			} else {
				NavigationModule.getInstance().stopRoleFlick();
			}
		}

		/**
		 * 移除技能升级按钮
		 */
		public function removeLevelSkillIcon():void {
			if (skillIcon) {
				skillIcon.stopFlick();
				skillIcon.hide();
				removeFromSpecialIcons(skillIcon);
			}
			skillIcon=null;
		}
		
		/**
		 *首充
		 */
		private var shouChongIcon:MessageIcon;
		private function showShouChongIcon():void {
			if (level == 21) {
				if (!shouChongIcon) {
					shouChongIcon=new MessageIcon("shouchong");
					shouChongIcon.tip="首次充值送价值1888元大礼包";
					shouChongIcon.callBack=onShouChongClick;
					shouChongIcon.show();
					addToSprecial(shouChongIcon);
				}
			} else {
				if (shouChongIcon != null) {
					shouChongIcon.stopFlick();
					shouChongIcon.hide();
					removeFromSpecialIcons(shouChongIcon);
				}
			}
			function onShouChongClick():void {
				ActivityModule.getInstance().openShouchongWin();
				if (shouChongIcon) {
					shouChongIcon.stopFlick();
					shouChongIcon.hide();
					removeFromSpecialIcons(shouChongIcon);
				}
			}
		}
		
		/**
		 *经验满
		 */
		private var expFullIcon:MessageIcon;
		
		public function showExpFullIcon(msg:String=""):void {
			if (!expFullIcon) {
				expFullIcon=new MessageIcon("tanhao");
				expFullIcon.getModuleId=StatConstant.VALUE_JI_LEI_JING_YAN;
				expFullIcon.setFilters();
				expFullIcon.tip=msg;
				expFullIcon.callBack=onExpFullClick;
			}
			expFullIcon.show();
			addToSprecial(expFullIcon);
			function onExpFullClick():void {
				promptKey=Prompt.show("您当前储存的经验已达上限，升级后可继续获得经验。", "温馨提示：", yesHandler, null, "确定", "", null, false);
				function yesHandler():void {
					promptKey="";
				}
				
				if (expFullIcon) {
					expFullIcon.hide();
					removeFromSpecialIcons(expFullIcon);
					expFullIcon=null;
				}
			}
		}
		
		private var promptKey:String;
		
		public function hideExpFull():void {
			if (expFullIcon) {
				expFullIcon.hide();
				removeFromSpecialIcons(expFullIcon);
				expFullIcon=null;
			}
			if (promptKey) {
				Prompt.removePromptItem(promptKey);
				promptKey="";
			}
		}
		
		/**
		 * 显示个人拉镖
		 */
		private var personBiao:MessageIcon;
		public function showPersonBiao(clickHandler:Function):void
		{
			if (personBiao == null)
			{
				personBiao=new MessageIcon("biao");
				personBiao.getModuleId = StatConstant.VALUE_GE_REN_LA_BIAO;
				personBiao.setFilters();
				personBiao.callBack=clickHandler;
				personBiao.tip="个人拉镖详情";
			}
			personBiao.show();
			addToSprecial(personBiao);
		}
		
		public function removePersonBiao():void
		{
			if (personBiao)
			{
				personBiao.hide();
				removeFromSpecialIcons(personBiao);
			}
		}
		
		/**
		 * 显示门派拉镖
		 */
		private var familyBiao:MessageIcon;
		
		public function showFamilyBiao(clickHandler:Function):void
		{
			if (familyBiao == null)
			{
				familyBiao=new MessageIcon("biao");
				familyBiao.getModuleId = StatConstant.VALUE_ZONG_ZU_LA_BIAO;
				familyBiao.setFilters();
				familyBiao.callBack=clickHandler;
				familyBiao.tip="门派拉镖详情";
			}
			familyBiao.show();
			addToSprecial(familyBiao);
		}
		
		public function removeFamilyBiao():void
		{
			if (familyBiao)
			{
				familyBiao.hide();
				removeFromSpecialIcons(familyBiao);
			}
			removeFamilyYBCTime();
		}
		
		/**
		 *  显示商贸状态
		 * @param clickHandler
		 *
		 */
		private var shangMao:MessageIcon;
		
		public function showShangmao(clickHandler:Function=null):void
		{
			if (shangMao == null)
			{
				shangMao=new MessageIcon("shangIcon");
				shangMao.getModuleId = StatConstant.VALUE_SHANG_MAO;
				shangMao.setFilters();
				shangMao.callBack=clickHandler;
				
			}
			shangMao.tip="商贸状态，当前为第" + TradingModule.getInstance().times+
				"次领取商票。\n丢弃商票可取消商贸。\n<font color='#00ff00'>点击查看详情。</font>";
			shangMao.show();
			addToSprecial(shangMao);
		}
		
		public function removeShangMao():void
		{
			if (shangMao)
			{
				shangMao.hide();
				removeFromSpecialIcons(shangMao);
			}
		}

		/**
		 * 师徒副本队长图标显示
		 */
		private var teamLeaderIcon:MessageIcon;

		/**
		 * 显示师徒副本队长图标
		 */
		public function showTeamLeaderIcon(callBack:Function):void {
			if (SceneDataManager.mapData.map_id == 10600) {
				if (!teamLeaderIcon) {
					teamLeaderIcon=new MessageIcon("teamLeader");
					teamLeaderIcon.getModuleId=StatConstant.VALUE_SHI_TU_FU_BEN_DUI_ZHANG;
					teamLeaderIcon.setFilters();
					teamLeaderIcon.callBack=callBack;
					teamLeaderIcon.tip="队长指挥队员，完成师徒副本";
				}
				teamLeaderIcon.show();
				teamLeaderIcon.startFlick();
			}
		}

		/**
		 * 开始闪烁师徒队长图标
		 */
		public function startFlickTeamLeaderIcon():void {
			if (teamLeaderIcon) {
				teamLeaderIcon.startFlick();
			}
		}

		/**
		 * 停止闪烁师徒队长图标
		 */
		public function stopFlickTeamLeaderIcon():void {
			if (teamLeaderIcon) {
				teamLeaderIcon.stopFlick();
			}
		}

		/**
		 * 删除闪烁师徒队长图标
		 */
		public function removeTeamLeaderIcon():void {
			if (teamLeaderIcon) {
				teamLeaderIcon.hide();
				teamLeaderIcon=null;
			}
		}

		/**
		 * 显示门派拉镖时间
		 */
		private var familyYBCTime:FamilyYBCTimer

		public function showFamilyYBCTime(hasGoTime:int=0):void {
			if (familyYBCTime == null) {
				familyYBCTime=new FamilyYBCTimer();
			}
			familyYBCTime.start(hasGoTime);
			BroadcastModule.getInstance().countdownView.addChilren(familyYBCTime);
		}

		public function removeFamilyYBCTime():void {
			if (familyYBCTime && familyYBCTime.parent) {
				familyYBCTime.stop();
				BroadcastModule.getInstance().countdownView.removeChildren(familyYBCTime);
			}
			familyYBCTime=null
		}
		
		/**
		 * 显示国探图标
		 */
		
		private var spyFactionIcon:Image;
		
		public function showSpyFactionIcon():void
		{
			if (!SpyModule.getInstance().spyFactionVo)
				return;
			
			if (spyFactionIcon == null) {
				spyFactionIcon = new Image();
				spyFactionIcon.source = GameConfig.ROOT_URL + 'com/assets/tongzhi.png';
				spyFactionIcon.addEventListener(MouseEvent.CLICK, onSpyFactionIconHandler);
				spyFactionIcon.width = 70;
				spyFactionIcon.height = 70;
				spyFactionIcon.x = (GlobalObjectManager.GAME_WIDTH - spyFactionIcon.width) / 2;
				spyFactionIcon.y = (GlobalObjectManager.GAME_HEIGHT - spyFactionIcon.height) / 2;
				spyFactionIcon.buttonMode = true;
			}
			
			LayerManager.uiLayer.addChild(spyFactionIcon);
		}
		
		public function removeSpyFactionIcon():void
		{
			if (spyFactionIcon) {
				spyFactionIcon.parent.removeChild(spyFactionIcon);
				spyFactionIcon.removeEventListener(MouseEvent.CLICK, onSpyFactionIconHandler);
				spyFactionIcon = null;
			}
		}
		
		private var spyFactionTipsPannel:spyFactionTipsView;
		
		private function onSpyFactionIconHandler(event:MouseEvent):void
		{
			if (spyFactionTipsPannel == null) {
				spyFactionTipsPannel = new spyFactionTipsView("国探通知");
			}
			
			WindowManager.getInstance().popUpWindow(spyFactionTipsPannel);
			removeSpyFactionIcon();
		}
		
		
		/**
		 * 显示国运图标
		 *
		 */
		private var factionYbcIcon:Image;
		
		public function showFactionYbcIcon():void
		{
			if (GlobalObjectManager.getInstance().user.attr.level <= 10)
			{
				return ;
			}
			if (factionYbcIcon == null)
			{
				factionYbcIcon=new Image();
				factionYbcIcon.source=GameConfig.ROOT_URL + 'com/assets/tongzhi.png';
				factionYbcIcon.addEventListener(MouseEvent.CLICK, onfactionYbcIconHandler);
				factionYbcIcon.width=70;
				factionYbcIcon.height=70;
				factionYbcIcon.x=(GlobalObjectManager.GAME_WIDTH - factionYbcIcon.width) / 2;
				factionYbcIcon.y=(GlobalObjectManager.GAME_HEIGHT - factionYbcIcon.height) / 2;
				factionYbcIcon.buttonMode=true;
			}
			LayerManager.uiLayer.addChild(factionYbcIcon);
		}
		
		private var factionYbcTipsPannel:PersonybcFactionTipsView;
		
		private function onfactionYbcIconHandler(event:MouseEvent):void
		{
			if (factionYbcTipsPannel == null)
			{
				factionYbcTipsPannel=new PersonybcFactionTipsView("国运通知");
			}
			WindowManager.getInstance().popUpWindow(factionYbcTipsPannel);
			removeFactionYbcIcon();
		}
		
		/**
		 * 移除国运图标
		 *
		 */
		public function removeFactionYbcIcon():void
		{
			if (factionYbcIcon)
			{
				factionYbcIcon.parent.removeChild(factionYbcIcon);
				factionYbcIcon.removeEventListener(MouseEvent.CLICK, onfactionYbcIconHandler);
				factionYbcIcon=null;
			}
		}
	}
}