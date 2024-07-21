package modules.heroFB
{
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.components.MessageIcon;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.tile.Pt;
	import com.utils.PathUtil;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.heroFB.newViews.NewHeroFBView;
	import modules.heroFB.newViews.items.HeroFBRecordView;
	import modules.heroFB.views.HeroFBStateView;
	import modules.heroFB.views.HeroFBView;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.playerGuide.TipsView;
	import modules.reward.RewardModule;
	import modules.scene.SceneDataManager;
	import modules.scene.SceneModule;
	
	import org.osmf.net.StreamingURLResource;
	
	import proto.common.p_role_hero_fb_info;
	import proto.line.m_hero_fb_buy_toc;
	import proto.line.m_hero_fb_buy_tos;
	import proto.line.m_hero_fb_enter_toc;
	import proto.line.m_hero_fb_enter_tos;
	import proto.line.m_hero_fb_panel_toc;
	import proto.line.m_hero_fb_panel_tos;
	import proto.line.m_hero_fb_quit_toc;
	import proto.line.m_hero_fb_quit_tos;
	import proto.line.m_hero_fb_report_toc;
	import proto.line.m_hero_fb_report_tos;
	import proto.line.m_hero_fb_reward_toc;
	import proto.line.m_hero_fb_reward_tos;
	import proto.line.m_hero_fb_state_toc;
	
	public class HeroFBModule extends BaseModule
	{
		public static var isOpenHeroFBPanel:Boolean;
		
		private static var _instance:HeroFBModule;
		
		private var _source:SourceLoader;
		private var _heroView:NewHeroFBView;
		private var _heroFBInfo:p_role_hero_fb_info;
		private var _stateView:HeroFBStateView;
		private var _isInHeroFb:Boolean = false;
		private var _recordView:HeroFBRecordView;
		private var _icon:MessageIcon;
		private var _currentBarrier:int;
		private var _heroFbState:m_hero_fb_state_toc;
		private var _toEnterBarrier:int = 0;
		
		public function HeroFBModule()
		{
			super();
		}
		
		public static function getInstance():HeroFBModule
		{
			if (!_instance)
				_instance = new HeroFBModule;
			
			return _instance;
		}
		
		override protected function initListeners():void
		{
			addMessageListener(NPCActionType.NA_87, openHeroFBPanel);
			addMessageListener(ModuleCommand.CHANGE_MAP, onChangeMap);
			addMessageListener(ModuleCommand.HERO_FB_ROLE_DEAD, onRoleDead);
			addMessageListener(ModuleCommand.STAGE_RESIZE, stageResizeHandler);
			
			addSocketListener(SocketCommand.HERO_FB_PANEL, acceptHeroFBInfo);
			addSocketListener(SocketCommand.HERO_FB_STATE, heroFBStateHandler);
			addSocketListener(SocketCommand.HERO_FB_QUIT, heroFBQuitReturn);
			addSocketListener(SocketCommand.HERO_FB_REPORT, onReportInfoReturn);
			addSocketListener(SocketCommand.HERO_FB_REWARD, getRewardReturn);
			addSocketListener(SocketCommand.HERO_FB_BUY, heroFBBuyReturn);
		}
		
		private function heroFBBuyReturn(vo:m_hero_fb_buy_toc):void
		{
			if (!vo.succ) {
				BroadcastSelf.logger(vo.reason);
				return;
			}
			
			_heroFBInfo.buy_count = vo.buy_count;
			_heroFBInfo.max_enter_times = vo.max_enter_times;
			BroadcastSelf.logger(("购买成功，当前最大挑战次数为" + vo.max_enter_times));
			if (_heroView) {
				_heroView.setEnterTime(_heroFBInfo.today_count, vo.max_enter_times);	
			}
			if (_toEnterBarrier != 0) {
				heroFBEnter(_toEnterBarrier);
			}
		}
		
		/**
		 * @doc 挑战下一关
		 */
		
		public function enterNextBarrier():void
		{
			var nextBarrierId:int = HeroFBDataManager.getInstance().getNextBarrierID(_currentBarrier);
			if (nextBarrierId == 0) {
				Alert.show("当前已经是最后一个关卡，无法挑战下一关", "提示");
			} else {
				heroFBEnter(nextBarrierId);
			}
		}
		
		/**
		 * @doc 重复挑战当前关卡
		 */
		
		public function repeatBarrier():void
		{
			heroFBEnter(_currentBarrier);
		}
		
		/**
		 * 购买次数
		 */
		
		public function requestBuyEnterTime(isGoldNotice:Boolean=true):void
		{
			var maxBuyTimes:int = HeroFBDataManager.getInstance().getMaxBuyTimes();
			if (_heroFBInfo.buy_count >= maxBuyTimes) {
				Alert.show(("你已经达到每天的" + maxBuyTimes + "次购买次数上限，无法再购买挑战次数"), "提示");
				return;
			}
			if (isGoldNotice) {
				var goldNeed:int = HeroFBDataManager.getInstance().getBuyGold(_heroFBInfo.buy_count);
				var str:String = "你确定要花<font color='#FF0000'>" + goldNeed + "元宝</font>购买1次挑战机会吗？";
				Alert.show(str, "提示", yesHandler);
			} else {
				yesHandler();
			}
			
			function yesHandler():void
			{
				var vo:m_hero_fb_buy_tos = new m_hero_fb_buy_tos;
				sendSocketMessage(vo);
			}
		}
		
		/**
		 * 打完所有怪物，弹出叹号
		 */
		
		public function clearMonsterHandler():void
		{
			_icon = new MessageIcon("lixianjingyan");
			_icon.callBack = iconClickHandler;
			_icon.x = (GlobalObjectManager.GAME_WIDTH - _icon.width) / 2;
			_icon.y = (GlobalObjectManager.GAME_HEIGHT - _icon.height) / 2;
			LayerManager.uiLayer.addChild(_icon);
			_icon.startFlick();
		}
		
		private function iconClickHandler():void
		{
			// 移除叹号
			if (_icon && _icon.parent)
				_icon.parent.removeChild(_icon);
			
			var barrier:int = HeroFBModule.getInstance().getCurrentBarrier();
			var boss:MonsterType = HeroFBDataManager.getInstance().getBossVoByBarrierId(barrier);
			var str:String = "英雄果然实力不凡，成功击败【" + boss.monstername + "】。请点击“返回入口”，继续你的英雄之旅！";
			Alert.show(str, "提示", yesHandler, null, "返回入口", "取消");
			
			function yesHandler():void
			{
				heroFBQuit(0);
			}
		}
		
		/**
		 * 获取当前关卡
		 */
		
		public function getCurrentBarrier():int
		{	
			return _currentBarrier;
		}
		
		/**
		 * 屏幕自适应
		 */
		
		private function stageResizeHandler(value:Object):void
		{
			if (_stateView)
				_stateView.onStageResize();
			
			if (_heroView)
				_heroView.stageResizeHandler();
		}
		
		/**
		 * 领取奖励
		 */
		
		public function getRewardRequest(chapterId:int):void
		{
			var vo:m_hero_fb_reward_tos = new m_hero_fb_reward_tos;
			vo.reward_id = chapterId;
			sendSocketMessage(vo);
		}
		
		/**
		 * 领取奖励返回
		 */
		
		private function getRewardReturn(vo:m_hero_fb_reward_toc):void
		{
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				return;
			}
			var chapId:int = _heroView.currentChapter;
			var chapInfo:XML = HeroFBDataManager.getInstance().getChapterInfo(chapId);
			var rewardVo:BaseItemVO = ItemLocator.getInstance().getObject(chapInfo.@rewardTypeId);
			if (rewardVo) {
				var str:String = "成功领取奖励，获得<font color='" + ItemConstant.COLOR_VALUES[int(chapInfo.@rewardColor)] + "'>" + rewardVo.name + "</font>";
				Tips.getInstance().addTipsMsg(str);
				BroadcastSelf.logger(str);
			}
			_heroView.hideeRewardBtn();
		}
		
		/**
		 * 接受战报数据
		 */
		
		public function onReportInfoReturn(vo:m_hero_fb_report_toc):void
		{
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				return;
			}
			
			if (!_recordView){
				_recordView = new HeroFBRecordView;
			}
			_recordView.setData(vo);
			WindowManager.getInstance().popUpWindow(_recordView);
			WindowManager.getInstance().centerWindow(_recordView);
		}
		
		/**
		 * 请求战报数据
		 */
		
		public function requestReportInfo(barrierId:int):void
		{
			var vo:m_hero_fb_report_tos = new m_hero_fb_report_tos
			vo.barrier_id = barrierId;
			sendSocketMessage(vo);
		}
		
		/**
		 * 角色在副本中死亡
		 */
		
		private function onRoleDead():void
		{
			Alert.show("挑战失败，你需要更加强大的实力，通过<font color='#00ff00'>铁匠铺</font>可以打造更强大的装备", "挑战失败", heroFBQuit, null, "返回入口", "", null, false);
		}
		
		/**
		 * 退出副本返回
		 */
		
		private function heroFBQuitReturn(vo:m_hero_fb_quit_toc):void
		{
			if (!vo.succ)
				Tips.getInstance().addTipsMsg(vo.reason);
		}
		
		/**
		 * 退出英雄副本
		 */
		
		public function heroFBQuit(quitType:int=1):void
		{
			var vo:m_hero_fb_quit_tos = new m_hero_fb_quit_tos;
			vo.quit_type = quitType;
			sendSocketMessage(vo);
		}
		
		/**
		 * 挑战状态
		 */
		
		private function heroFBStateHandler(vo:m_hero_fb_state_toc):void
		{
			_heroFbState = vo;
			if (_stateView)
				_stateView.setData(vo);
		}
		
		/**
		 * 进入地图hook
		 */
		
		private function onChangeMap(mapId:int):void
		{
			_toEnterBarrier = 0;
			// 关闭英雄副本界面
			closeHeroFBPanel();
			// 去掉叹号
			if (_icon && _icon.parent)
				_icon.parent.removeChild(_icon);
			// 如果是英雄副本，要弹出副本进度界面
			if (isMapHeroFB(mapId)) {
				if (!_heroFBInfo)
					requestHeroFBInfo();
				else
					popStateView(mapId);
				
				_isInHeroFb = true;
			} else {
				if (_stateView && _stateView.parent) {
					LoopManager.removeFromTimer(_stateView);
					_stateView.parent.removeChild(_stateView);
				}
				// 从副本中退出要弹出选择副本界面
				var factionId:int = GlobalObjectManager.getInstance().user.base.faction_id;
				var currentMapId:int = SceneDataManager.mapData.map_id;
				var hero:MyRole = GameScene.getInstance().hero;
				var npcPt:Pt = new Pt(126, 0, 45);
				if (_isInHeroFb && (mapId == 10000 + factionId * 1000 + 100) && ScenePtMath.checkDistance(hero.index, npcPt) < 5) {
					openHeroFBPanel();
				}
				_isInHeroFb = false;
			}
		}
		
		/**
		 * 弹出副本状态界面
		 */
		
		private function popStateView(mapId:int):void
		{		
			if (!_stateView) {
				_stateView = new HeroFBStateView;
			}
			_currentBarrier = HeroFBDataManager.getInstance().getBarrierIdByMapId(mapId);
			_stateView.initData(_heroFBInfo, _currentBarrier);
			LayerManager.uiLayer.addChild(_stateView);
			if (_heroFbState) {
				_stateView.setData(_heroFbState);
			}
			_heroFbState = null;
		}
		
		/**
		 * 打开英雄副本面板
		 */
		
		private function openHeroFBPanel(vo:NpcLinkVO=null):void
		{
			if (!_source) {
				_source = new SourceLoader;
				
				var url:String = GameConfig.ROOT_URL + "com/assets/hero_fb/hero_fb.swf";
				_source.loadSource(url, "正在加载个人副本界面", sourceLoadComplete);
			} else {
				sourceLoadComplete()
			}
		}
		
		/**
		 * 英雄副本界面加载成功
		 */
		
		private function sourceLoadComplete():void
		{
			if (!_heroView)
				_heroView = new NewHeroFBView(_source);
			
			LayerManager.sceneLayer.addChild(_heroView);
			
			if (!_heroFBInfo)
				requestHeroFBInfo();
			else
				_heroView.setData(_heroFBInfo);
			
			onOpenHeroFBPanel();
		}
		
		/**
		 * 请求英雄副本信息
		 */
		
		private function requestHeroFBInfo():void
		{
			sendSocketMessage(new m_hero_fb_panel_tos);
		}
		
		/**
		 * 英雄副本信息返回
		 */
		
		private function acceptHeroFBInfo(vo:m_hero_fb_panel_toc):void
		{
			_heroFBInfo = vo.hero_fb;
			
			if (_heroView)
				_heroView.setData(_heroFBInfo);
			// 如果是在英雄副本中，则弹出状态界面
			var mapId:int = SceneDataManager.mapData.map_id;
			if (isMapHeroFB(mapId)) {
				popStateView(mapId);
			}
		}
		
		/**
		 * 挑战某关副本
		 */
		
		public function heroFBEnter(barrierId:int):void
		{			
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			var minLevel:int =HeroFBDataManager.getInstance().getEnterMinLevel();
			if (level < minLevel) {
				Tips.getInstance().addTipsMsg("必须要等级达到"+minLevel+"级才可以开启大明英雄副本");
				return;
			}
			
			if (_heroFBInfo.today_count >= _heroFBInfo.max_enter_times) {
				_toEnterBarrier = barrierId;
				var goldNeed:int = HeroFBDataManager.getInstance().getBuyGold(_heroFBInfo.buy_count);
				Alert.show("你今天的副本挑战次数已达上限，需要花费" + goldNeed + "元宝购买1次挑战次数吗？", "提示", yesHandler, null, "购买");
				return;
			}
			
			function yesHandler():void
			{
				requestBuyEnterTime(false);
			}
			
			var monster:MonsterType;
			if (barrierId > _heroFBInfo.progress) {
				monster = HeroFBDataManager.getInstance().getBossVoByBarrierId(_heroFBInfo.progress);
				Tips.getInstance().addTipsMsg("请先击败【" + monster.monstername + "】，再挑战后面的关卡。");
				return;
			}
			
			var vo:m_hero_fb_enter_tos = new m_hero_fb_enter_tos;
			vo.barrier_id = barrierId;
			sendSocketMessage(vo);
		}
		
		/**
		 * 挑战某关副本返回
		 */
		
		private function heroFBEnterReturn(vo:m_hero_fb_enter_toc):void
		{
			_toEnterBarrier = 0;
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				return;
			}
		}
		
		/**
		 * 请求某关战报
		 */
		
		public function heroFBReport(barrierId:int):void
		{
			
		}
		
		/**
		 * 打开个人副本界面
		 */
		
		private function onOpenHeroFBPanel():void
		{
			isOpenHeroFBPanel = true;
			
			// 隐藏小图标
			LayerManager.uiLayer.hide();
			// 隐藏任务追踪
			this.dispatch(ModuleCommand.MISSION_HIDE_FOLLOW_VIEW);
			// 隐藏选中的NPC
			this.dispatch(ModuleCommand.SHOW_SELECTED_ONE, {'visible':false});
			// 隐藏等级礼包
			if (RewardModule.getInstance().btn) {
				RewardModule.getInstance().btn.visible = false;
			}
			if (RewardModule.getInstance().gift_glow_mc) {
				RewardModule.getInstance().gift_glow_mc.visible = false;
			}
//			this.dispatch(ModuleCommand.GIFT_HIDE_PANEL);
			
			
//			SceneTopTimeIconManager.getInstance().hide();
			BroadcastModule.getInstance().countdownView.hide();
		}
		
		/**
		 * 关闭副本界面
		 */
		
		public function closeHeroFBPanel():void
		{
			isOpenHeroFBPanel = false;
			
			if (_heroView) {
				if (_heroView.parent) _heroView.parent.removeChild(_heroView); 
			}
			
			// 显示小图标
			LayerManager.uiLayer.show();
			// 显示傻笑追踪
			this.dispatch(ModuleCommand.MISSION_SHOW_FOLLOW_VIEW);
			// 显示等级礼包
			if (RewardModule.getInstance().btn) {
				RewardModule.getInstance().btn.visible = true;
			}
			if (RewardModule.getInstance().gift_glow_mc) {
				RewardModule.getInstance().gift_glow_mc.visible = true;
			}
//			this.dispatch(ModuleCommand.GIFT_SHOW_PANEL);
//			SceneTopTimeIconManager.getInstance().show();
			BroadcastModule.getInstance().countdownView.show();
		}
		
		/**
		 * 某地图是否是英雄副本
		 */
		
		public function isMapHeroFB(mapId:int):Boolean
		{
			var ary:Array = HeroFBDataManager.getInstance().getHeroFBMapIdList();
			if (ary.indexOf(mapId) >= 0)
				return true;
			
			return false;
		}
		
		/**
		 * ms -> min'sec'..
		 */
		
		public function formatTime(time:int):String
		{
			if (time == 0) {
				return "";
			}
			
			return (int(time/60000) + "'" + int(time%60000/1000) + "''" + int(time%60000%1000/10));
		}
	}
}