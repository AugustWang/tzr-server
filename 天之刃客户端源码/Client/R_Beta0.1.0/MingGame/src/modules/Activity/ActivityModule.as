package modules.Activity {
	import com.Message;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	
	import modules.Activity.activityManager.ActAwardLocator;
	import modules.Activity.activityManager.ActivityFollowManager;
	import modules.Activity.activityManager.BossGroupManager;
	import modules.Activity.view.ActivityFollowView;
	import modules.Activity.view.ActivityWindow;
	import modules.Activity.view.BossGroupPanel;
	import modules.Activity.view.ClearContinueLoginView;
	import modules.Activity.view.EquipListView;
	import modules.Activity.vo.AwardVo;
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.conlogin.views.ClearConloginView;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;
	
	import proto.common.p_goods;
	import proto.line.m_accumulate_exp_fetch_toc;
	import proto.line.m_accumulate_exp_get_toc;
	import proto.line.m_accumulate_exp_get_tos;
	import proto.line.m_accumulate_exp_refresh_toc;
	import proto.line.m_accumulate_exp_refresh_tos;
	import proto.line.m_accumulate_exp_view_toc;
	import proto.line.m_accumulate_exp_view_tos;
	import proto.line.m_activity_benefit_buy_toc;
	import proto.line.m_activity_benefit_buy_tos;
	import proto.line.m_activity_benefit_list_toc;
	import proto.line.m_activity_benefit_list_tos;
	import proto.line.m_activity_benefit_reward_toc;
	import proto.line.m_activity_benefit_reward_tos;
	import proto.line.m_activity_boss_group_toc;
	import proto.line.m_activity_boss_group_tos;
	import proto.line.m_activity_getgift_toc;
	import proto.line.m_activity_getgift_tos;
	import proto.line.m_activity_pay_gift_info_toc;
	import proto.line.m_activity_pay_gift_info_tos;
	import proto.line.m_activity_today_tos;
	import proto.line.m_conlogin_fetch_toc;
	import proto.line.m_conlogin_fetch_tos;
	import proto.line.m_conlogin_info_toc;
	import proto.line.m_conlogin_info_tos;
	import proto.line.m_conlogin_notshow_toc;
	import proto.line.m_special_activity_able_get_toc;
	import proto.line.m_special_activity_detail_toc;
	import proto.line.m_special_activity_detail_tos;
	import proto.line.m_special_activity_get_prize_toc;
	import proto.line.m_special_activity_get_prize_tos;
	import proto.line.m_special_activity_list_toc;
	import proto.line.m_special_activity_list_tos;
	import proto.line.m_special_activity_stat_toc;
	import proto.line.m_special_activity_stat_tos;
	
	public class ActivityModule extends BaseModule {
		public function ActivityModule() {
			
			_baseAwardList=ActAwardLocator.getInstance().getBaseAwardList();
			_extraAwardList=ActAwardLocator.getInstance().getExtraAwardList();
		}
		public var isOpen:Boolean=false;
		private static var _instance:ActivityModule;
		private var bossGroupPanel:BossGroupPanel;
		private var activityWin:ActivityWindow;
		private var activityFollowView:ActivityFollowView;
		public var finishTimes:int=0;
		public var benefitList:m_activity_benefit_list_toc;
		
		private var _baseAwardList:Array;
		private var _extraAwardList:Array;
		private var equipListView:EquipListView;
		
		public function get baseAwardList():Array {
			return _baseAwardList;
		}
		
		public function get extraAwardList():Array {
			return _extraAwardList;
		}
		
		public static function getInstance():ActivityModule {
			if (!_instance) {
				_instance=new ActivityModule();
			}
			return _instance;
		}
		
		override protected function initListeners():void {
			//服务端消息
			this.addSocketListener(SocketCommand.ACTIVITY_TODAY, tocActivityToday);
			this.addSocketListener(SocketCommand.ACTIVITY_BENEFIT_LIST, tocBenefitList);
			this.addSocketListener(SocketCommand.ACTIVITY_BENEFIT_REWARD, tocBenefitReward);
			this.addSocketListener(SocketCommand.ACTIVITY_BENEFIT_BUY, tocBenefitBuy);
			this.addSocketListener(SocketCommand.ACTIVITY_GETGIFT, tocGetGift);
			this.addSocketListener(SocketCommand.ACTIVITY_PAY_GIFT_INFO, toPayGiftInfo);
			
			this.addSocketListener(SocketCommand.CONLOGIN_FETCH, doFetchBack);
			//点击获取按钮，获取经验
			this.addSocketListener(SocketCommand.ACCUMULATE_EXP_GET, onUpdateExp);
			//打开面板时，获取总经验等等数据
			this.addSocketListener(SocketCommand.ACCUMULATE_EXP_VIEW, onGetExp);
			
			this.addSocketListener(SocketCommand.ACCUMULATE_EXP_REFRESH, doRefExp);
			
			//连续登录数据返回
			this.addSocketListener(SocketCommand.CONLOGIN_INFO, doInfoBack);
			//请求不在显示
			this.addSocketListener(SocketCommand.CONLOGIN_NOTSHOW, doNotShowBack);
			
			//打开高明
			this.addMessageListener(NPCActionType.NA_95, onOpenAcc);
			//this.addMessageListener(ModuleCommand.OPEN_BOSSGROUP_PANEL,openBossGroupPanel);
			this.addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);	
			this.addSocketListener(ModuleCommand.STAGE_RESIZE,resizeHandler);
			//特殊活动
			this.addSocketListener(SocketCommand.SPECIAL_ACTIVITY_ABLE_GET,tocSpclActAbleGet);
			this.addSocketListener(SocketCommand.SPECIAL_ACTIVITY_GET_PRIZE,tocSpclActGetPrize);
			this.addSocketListener(SocketCommand.SPECIAL_ACTIVITY_LIST,tocSpclActList);
			this.addSocketListener(SocketCommand.SPECIAL_ACTIVITY_DETAIL,tocSpclActDetail);
			this.addSocketListener(SocketCommand.SPECIAL_ACTIVITY_STAT,tocSpclActStat);
			this.addSocketListener(SocketCommand.ACTIVITY_BOSS_GROUP,tocBossGroup);
		}
		/**
		 * 打开boss群面板 
		 * 
		 */		
		public function openBossGroupPanel():void{
//			if(BossGroupManager.getInstance().inited == false){
//				BossGroupManager.getInstance().addEventListener(BossGroupManager.INIT_COMPLETE,bossGroupInitComplete);
//				BossGroupManager.getInstance().startInit();
//				return;
//			}
//			if(bossGroupPanel == null){
//				bossGroupPanel = new BossGroupPanel();
//				requestBossGroups();
//			}
//			//bossGroupPanel.centerOpen();
		}
		/**
		 * boss群初始化完毕 
		 * 
		 */		
		private function bossGroupInitComplete(event:ParamEvent):void{
			BossGroupManager.getInstance().removeEventListener(BossGroupManager.INIT_COMPLETE,bossGroupInitComplete);
			openBossGroupPanel();
		}
		/**
		 * 
		 * @param vo
		 * 打开累积经验面板 
		 */		
		private function onOpenAcc(vo:NpcLinkVO):void{
			if(WindowManager.getInstance().isPopUp(activityWin) != true){
				WindowManager.getInstance().popUpWindow(activityWin, WindowManager.UNREMOVE);
				WindowManager.getInstance().centerWindow(activityWin);
				activityWin.openAccView();
			}
		}
		
		//请求今天不再显示本界面
		public function sendNotShowRequest(vo:Message):void
		{
			this.sendSocketMessage(vo);
			ActivityModule.getInstance().removeActivityWindow();
		}
		
		/**
		 * 处理点击 当天不显示 的返回值
		 */
		private function doNotShowBack(vo:m_conlogin_notshow_toc):void{
			if (vo.succ) {
				BroadcastSelf.logger("你已设置今天不再自动显示连续登陆窗口");
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		public function removeActivityWindow():void{
			if(activityWin != null){
				WindowManager.getInstance().removeWindow(activityWin);
			}
		}
		
		public function popClearConloginView():void
		{
			var notice:ClearContinueLoginView = new ClearContinueLoginView();
			WindowManager.getInstance().popUpWindow(notice);
		}
		
		public function showBagEquipList(activityKey:int):void
		{
			if (!equipListView) {
				equipListView=new EquipListView();
			}
			equipListView.updateTileListData(activityKey);
			WindowManager.getInstance().popUpWindow(equipListView, WindowManager.UNREMOVE);
		}
		
		//进入游戏
		private function onEnterGame():void {
			//当玩家到20级时才去请求
			if(GlobalObjectManager.getInstance().user.attr.level >= 20){
				openActivityWin(5);
			}
			if(activityFollowView == null){
				activityFollowView = new ActivityFollowView();
				ActivityFollowManager.getInstance().initActivity();
			}
			resizeHandler();
			LayerManager.uiLayer.addChild(activityFollowView);
		}
		
		private function resizeHandler(param:Object=null):void{
			activityFollowView.x = GlobalObjectManager.GAME_WIDTH - 400;
			activityFollowView.y = 20;
		}
		
		//m_accumulate_exp_refresh_tos
		public function sendUpdateExp(vo:m_accumulate_exp_refresh_tos):void {
			this.sendSocketMessage(vo);
		}
		
		public function sendGetExp(vo:m_accumulate_exp_get_tos):void {
			this.sendSocketMessage(vo);
		}
		
		private function tocGetGift(vo:m_activity_getgift_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("领取成功，请打开背包查看");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private function onGetExp(vo:m_accumulate_exp_view_toc):void {
			if (!activityWin) {
				activityWin=new ActivityWindow;
			}
			if (vo.succ) {
				if(activityWin.tabNavigation.selectedIndex != 5){
					activityWin.tabNavigation.selectedIndex = 5;
				}
				
				if (activityWin.hortationView) {
					activityWin.hortationView.data=vo;
				}
			} else {
				if (activityWin && activityWin.hortationView) {
					activityWin.hortationView.data=vo;
				}
			}
		}
		
		/**
		 * <font color="#FFFFFF">白色</font>
		 * 处理领取或者购买奖励的返回值
		 */
		private function doFetchBack(vo:m_conlogin_fetch_toc):void{
			if (vo.succ) {
				this.activityWin.hortationView.continueLoginView.updateReward(vo);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		public function send(vo:m_conlogin_fetch_tos):void
		{
			this.sendSocketMessage(vo);
		}
		
		private function onUpdateExp(vo:m_accumulate_exp_get_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("获取成功");
				BroadcastSelf.getInstance().appendMsg("获取成功");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		private function doRefExp(vo:m_accumulate_exp_refresh_toc):void {
			//			Tips.getInstance().addTipsMsg(vo.reason);
			BroadcastSelf.getInstance().appendMsg(vo.reason);
		}
		
		private function toPayGiftInfo(vo:m_activity_pay_gift_info_toc):void {
			if (activityWin != null) {
				if(vo.succ != false){
					activityWin.updateDynamicGift(vo);
				}else{
					Tips.getInstance().addTipsMsg(vo.reason);
					BroadcastSelf.getInstance().appendMsg(vo.reason);
				}
			}
		}
		
		// 请求领取礼包，1为首充大礼包，2为单个武器礼包
		public function requestGetFirstPayGift(type:int):void {
			var vo:m_activity_getgift_tos=new m_activity_getgift_tos;
			vo.type=type;
			sendSocketMessage(vo);
		}
		
		private var cnt:int=0;
		
		public function openShouchongWin():void {
			if (!activityWin) {
				activityWin=new ActivityWindow;
			}
			WindowManager.getInstance().popUpWindow(activityWin, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(activityWin);
			activityWin.tabNavigation.selectedIndex=5;
		}
		
		//打开领取福利
		public function openActivityBenefit():void {
			this.openActivityWin( 0 );
		}
		
		//打开活动面板
		public function openActivityWin(idx:int=0):void {
			if (!activityWin) {
				activityWin=new ActivityWindow();
			}
			
			activityWin.tabNavigation.selectedIndex = idx;
			if (idx == 0) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.BENEFIT;
			} else if (idx == 1) { //从聊天界面打开领取福利。 
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.EVERYDAY;
			} else if(idx == 2) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.UPDATELVL;
			} else if(idx == 3) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.ADDMONEY;
			} else if(idx == 4) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.GIFT;
			} else if(idx == 5) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.HORTATION;
			} else if(idx == 6) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.NOTICE;
			} else if(idx == 7) {
				activityWin.getIndex=ActivityWindow.NAVIGATION_NAME.SPECIALACTIVITY;
			}
			
			switch (activityWin.getIndex) {
				case ActivityWindow.NAVIGATION_NAME.EVERYDAY:
					//					if (cnt != 0) {
					//						requestEverydayData(1);
					//					}
					requestEverydayData(1);
					break;
				case ActivityWindow.NAVIGATION_NAME.GIFT:
					
					break;
				case ActivityWindow.NAVIGATION_NAME.UPDATELVL:
					requestEverydayData(2);
					break;
				case ActivityWindow.NAVIGATION_NAME.ADDMONEY:
					//requestEverydayData(3);
					openBossGroupPanel();
					break;
				case ActivityWindow.NAVIGATION_NAME.PERCIOUS:
					requestEverydayData(4);
					break;
				case ActivityWindow.NAVIGATION_NAME.BENEFIT:
					//					if (cnt != 0) {
					//						requestBenefitList();
					//					}
					requestBenefitList();
					break;
				case ActivityWindow.NAVIGATION_NAME.HORTATION:
					//因为连续登录已经在游戏进入时就向后台获取等到了，所以这里是获取累积经验的
					requestAccumulateAndContinueLogin();
					break;
				case ActivityWindow.NAVIGATION_NAME.SPECIALACTIVITY:
					requestSpecialActivityList();
					break;
			}
			//			cnt++;
			
			if(WindowManager.getInstance().isPopUp(activityWin) != true){
				WindowManager.getInstance().popUpWindow(activityWin, WindowManager.UNREMOVE);
				WindowManager.getInstance().centerWindow(activityWin);
			}
		}
		
		public function requestBossGroups():void{
			var vo:m_activity_boss_group_tos = new m_activity_boss_group_tos();
			vo.op_type = 1;
			sendSocketMessage(vo);
		}
		
		public function requestBossGroupDetail(bossId:int):void{
			var vo:m_activity_boss_group_tos = new m_activity_boss_group_tos();
			vo.op_type = 2;
			vo.boss_id = bossId;
			sendSocketMessage(vo);
		}
		
		public function requestBossGroupTransfer(bossId:int):void{
			var carryVO:BaseItemVO = PackManager.getInstance().getGoodsByEffectType([ItemConstant.EFFECT_TRANSFORM_MAP]);
			if(carryVO){
				var vo:m_activity_boss_group_tos = new m_activity_boss_group_tos();
				vo.op_type = 3;
				vo.boss_id = bossId;
				sendSocketMessage(vo);
			}else{
				Tips.getInstance().addTipsMsg("背包里没有传送卷，传送卷可在商店购买");
			}
		}
		
		public function requestSpecialActivityList():void{
			//var vo:m_accumulate_exp_view_tos=new m_accumulate_exp_view_tos();			
			var vo:m_special_activity_list_tos = new m_special_activity_list_tos();
			this.sendSocketMessage(vo);
			
		}
		
		public function requestAccumulateAndContinueLogin():void{
			var vo:m_accumulate_exp_view_tos=new m_accumulate_exp_view_tos();
			this.sendSocketMessage(vo);
			
			requestHortation();
		}
		
		public function requestBenefitList():void {
			var vo:m_activity_benefit_list_tos=new m_activity_benefit_list_tos();
			this.sendSocketMessage(vo);
		}
		
		
		public function requestAward():void {
			var vo:m_activity_benefit_reward_tos=new m_activity_benefit_reward_tos();
			this.sendSocketMessage(vo);
		}
		
		public function requestBuyAllBenefit():void {
			requestBuyBenefit(0);
		}
		
		public function requestBuyBenefit(taskID:int):void {
			var vo:m_activity_benefit_buy_tos=new m_activity_benefit_buy_tos();
			vo.act_task_id=taskID;
			this.sendSocketMessage(vo);
		}
		
		//%% type::integer() 活动类型：1=普通活动，2=升级,3=赚钱,4=宝藏
		public function requestEverydayData(type:int):void {
			var vo:m_activity_today_tos=new m_activity_today_tos();
			vo.type=type;
			this.sendSocketMessage(vo);
		}
		
		//获取动态礼包的信息
		public function requestDynamicGift():void {
			var vo:m_activity_pay_gift_info_tos=new m_activity_pay_gift_info_tos();
			this.sendSocketMessage(vo);
		}
		
		//获取连续登录的信息
		public function requestHortation():void {
			var vo:m_conlogin_info_tos=new m_conlogin_info_tos;
			vo.auto=false;
			this.sendSocketMessage(vo);
		}
		
		public function requestGetSpclActReward(key:int,id:int):void{
			var vo:m_special_activity_get_prize_tos=new m_special_activity_get_prize_tos;
			vo.activity_key=key;
			vo.condition_id=id;
			this.sendSocketMessage(vo);
		}
		public function requestGetSpclActDetail(key:int):void{
			var vo:m_special_activity_detail_tos = new m_special_activity_detail_tos;
			vo.activity_key=key;
			this.sendSocketMessage(vo);
		}
		
		public function reqestEquipActivityData(ActivityKey:int,equipOid:int):void{
			var vo:m_special_activity_stat_tos = new m_special_activity_stat_tos();
			vo.activity_key = ActivityKey;
			vo.goods_id = equipOid;
			this.sendSocketMessage(vo);
		}
		private function tocBenefitList(vo:m_activity_benefit_list_toc):void {
			if (vo.succ) {
				this.benefitList=vo;
				activityWin.benefitListResult(vo);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		
		private function tocBenefitReward(vo:m_activity_benefit_reward_toc):void {
			if (vo.succ) {
				if (benefitList) {
					this.benefitList.is_rewarded=true;
					
					activityWin.benefitListResult(this.benefitList);
				} else {
					Tips.getInstance().addTipsMsg("无法取得日常福利的数据");
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
			
		}
		
		private function tocBenefitBuy(vo:m_activity_benefit_buy_toc):void {
			
			if (vo.succ) {
				if (benefitList) {
					if (vo.act_task_id > 0) {
						handleBuyOneBenefit(vo.act_task_id);
					} else {
						handleBuyAllBenefit();
					}
					
					activityWin.benefitListResult(this.benefitList);
					
				} else {
					Tips.getInstance().addTipsMsg("无法取得日常福利的数据");
				}
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		private function handleBuyOneBenefit(actTaskID:int):void {
			var isNewTaskComplete:Boolean=true;
			for each (var i:int in benefitList.act_task_list) {
				if (i == actTaskID) {
					isNewTaskComplete=false;
					break;
				}
			}
			if (isNewTaskComplete) {
				//重新计算基础奖励、额外奖励
				benefitList.act_task_list.push(actTaskID);
				var count:int=benefitList.act_task_list.length;
				benefitList.base_exp+=getBaseAwardExp(actTaskID);
				benefitList.extra_exp=getExtraAwardExp(count);
			}
		}
		
		private function handleBuyAllBenefit():void {
			benefitList.act_task_list=[];
			benefitList.base_exp=0;
			for each (var award:AwardVo in _baseAwardList) {
				benefitList.act_task_list.push(award.id);
				benefitList.base_exp+=getBaseAwardExp(award.id);
			}
			var count:int=benefitList.act_task_list.length;
			benefitList.extra_exp=getExtraAwardExp(count);
		}
		
		private function getBaseAwardExp(taskID:int):int {
			for each (var v:AwardVo in _baseAwardList) {
				if (v.id == taskID) {
					return getExp(v.expAdd, v.expMult);
				}
			}
			return 0;
		}
		
		private function getExtraAwardExp(countLevel:int):int {
			for each (var v:AwardVo in _extraAwardList) {
				if (v.id == countLevel) {
					return getExp(v.expAdd, v.expMult);
				}
			}
			return 0;
		}
		
		public static function getExp(add:int, mult:int):int {
			var exp:int=0;
			var lv:int=GlobalObjectManager.getInstance().user.attr.level;
			exp=add + lv * mult;
			return exp;
		}
		
		//每日活动数据返回
		private function tocActivityToday(data:Object):void {
			if (activityWin) {
				activityWin.setActivityEveryday(data);
			}
		}
		
		/**
		 * 处理获取连续登录信息的返回值
		 */
		private function doInfoBack(vo:m_conlogin_info_toc):void {
			if (activityWin == null) {
				activityWin=new ActivityWindow();
			}
			//			if(WindowManager.getInstance().isPopUp(activityWin) != true){
			//				WindowManager.getInstance().popUpWindow(activityWin, WindowManager.UNREMOVE);
			//				WindowManager.getInstance().centerWindow(activityWin);
			//			}
			activityWin.hortationView.data=vo;
		}
		
		
		//NPC寻路前往
		public function goto( npcId:int ):void //map_id:int,x:int,y:int
		{
			PathUtil.findNpcAndOpen( npcId.toString());
		}
		
		//使用传送卷
		public function sendtoNpc( npcId:int ):void {
			var onConfirmSentToClick:Function=function():void {
				PathUtil.carryNPC( npcId.toString());
			}
			var alertMsg:String='确定使用一个<font color="#cde643">【传送卷】</font>传送到达任务地点？\n<font color="#cde643">【传送卷】</font>剩余数量：' +
				PackManager.getInstance().getGoodsNumByTypeId( 10100001 ) + "。";
			Alert.show( alertMsg, "提示", onConfirmSentToClick, null, "确定", "取消" );
			
		}
		
		
		//玩家可以获取特殊活动奖励提示
		public function tocSpclActAbleGet(vo:m_special_activity_able_get_toc):void{
			
		}
		//特殊活动列表
		public function tocSpclActList(vo:m_special_activity_list_toc):void{
			if (activityWin) {
				activityWin.specialActivityList(vo);
			}
		}
		//获取奖励 
		public function tocSpclActGetPrize(vo:m_special_activity_get_prize_toc):void{
			if(activityWin){
				if(!vo.succ){
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			}
		}
		//活动详情
		public function tocSpclActDetail(vo:m_special_activity_detail_toc):void{
			if(activityWin){
				activityWin.specialActivityDetail(vo);
			}
		}
		// 参与活动结果 
		public function tocSpclActStat(vo:m_special_activity_stat_toc):void{
			if(activityWin){
				if(!vo.succ){
					Tips.getInstance().addTipsMsg(vo.reason);
				}
			}
		}
		//boss群消息返回
		public function tocBossGroup(vo:m_activity_boss_group_toc):void{
			if(vo.succ){
				if(vo.op_type == 1){
					BossGroupManager.getInstance().setdGroupList(vo.boss_group_list);
				}else if(vo.op_type == 2){
					BossGroupManager.getInstance().updateGroupBossVO(vo.boss_id,vo.map_id,vo.tx,vo.ty);
				}else if(vo.op_type == 3){
					
				}
			}
		}
		
	}
}
