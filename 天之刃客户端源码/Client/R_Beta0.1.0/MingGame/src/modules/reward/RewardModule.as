package modules.reward {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.gs.Quadratic;
	import com.gs.TweenMax;
	import com.loaders.SourceLoader;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.net.SocketCommand;
	import com.scene.sceneUnit.baseUnit.things.effect.Effect;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mission.MissionFBModule;
	import modules.reward.view.RewardWindow;
	import modules.reward.view.TimeGiftView;
	
	import proto.line.m_level_gift_accept_toc;
	import proto.line.m_level_gift_accept_tos;
	import proto.line.m_level_gift_list_toc;
	import proto.line.m_time_gift_accept_toc;
	import proto.line.m_time_gift_accept_tos;
	import proto.line.m_time_gift_list_toc;

	public class RewardModule extends BaseModule {
		private static var _instance:RewardModule;

		public function RewardModule() 
		{
		}

		public static function getInstance():RewardModule {
			if (!_instance) {
				_instance=new RewardModule();
			}
			return _instance;
		}

		override protected function initListeners():void {
			//服务端消息
			/*** 暂时屏蔽礼包功能
			this.addSocketListener(SocketCommand.LEVEL_GIFT_LIST, rewardDataBack);
			this.addSocketListener(SocketCommand.LEVEL_GIFT_ACCEPT, getRewardDataBack);
			this.addSocketListener(SocketCommand.TIME_GIFT_LIST, timeGiftDataBack);
			this.addSocketListener(SocketCommand.TIME_GIFT_ACCEPT, getTimeGiftDataBack); 
			this.addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
			addMessageListener( ModuleCommand.CHANGE_MAP, onChangeMap );
			 ****/
		}

		private function onChangeMap( mapId:int ):void {
			var isSingleFbMapId:Boolean=MissionFBModule.getInstance().isMapMisssionFB(mapId);
			if( gift_sprite ){
				if( isSingleFbMapId ){
					if( gift_sprite.visible )
						gift_sprite.visible = false;
				}else{
					gift_sprite.visible = true;
				}
			}
		}
		
		private function onStageResize(obj:Object):void {
			if (gift_sprite)
			{
					updateGiftSprite();
			}
		}
		/**
		 *点击礼包图标打开礼包界面
		 */
		private var rewardWin:RewardWindow;
		private var source:SourceLoader;

		public function loaderSource():void {
			if (!rewardWin) {
				source=new SourceLoader();
				var reward_url:String=GameConfig.ROOT_URL + "com/assets/gift/gift.swf";
				var msg:String="加载等级礼包模块、、、";
				source.loadSource(reward_url, msg, openRewardWindow);
			} else {
				openRewardWindow();
			}
		}

		/**
		 *打开领取的界面
		 *
		 */
		private function openRewardWindow():void {
			if (!rewardWin) {
				rewardWin=new RewardWindow();
				rewardWin.init(source);
				source=null;
			}
			if (time == 0 && isClickTimeGiftOpen) {
				rewardWin.getRewardBtn.label="领取奖励";
			} else if (isClickTimeGiftOpen == false && (GlobalObjectManager.getInstance().user.attr.level >= giftLv)) {
				rewardWin.getRewardBtn.label="领取奖励";
			} else {
				rewardWin.getRewardBtn.label="稍后再来";
			}
			if (arr.length != 0) {
				rewardWin.handlerFromService(arr[0], arr[1]);
				WindowManager.getInstance().popUpWindow(rewardWin, WindowManager.UNREMOVE);
				WindowManager.getInstance().centerWindow(rewardWin);
			}
		}
		/**
		 *时间礼包数据返回
		 * @param data
		 *
		 */
		private var time:int;
		public var timeGiftView:TimeGiftView;

		private function timeGiftDataBack(data:Object):void {
			var timeGiftVo:m_time_gift_list_toc=data as m_time_gift_list_toc;
			if (timeGiftVo == null)
				return;
			time=timeGiftVo.gift.time;
			arr[0]=timeGiftVo.gift;
			arr[1]=SocketCommand.TIME_GIFT_LIST;

			if (!timeGiftView) {
				timeGiftView=new TimeGiftView();
				LayerManager.uiLayer.addChild(timeGiftView);
				timeGiftView.init();
				//中间对齐
				timeGiftView.x=(1000 - timeGiftView.width) / 2 - 37 + 100;
				timeGiftView.y=GlobalObjectManager.GAME_HEIGHT - timeGiftView.height - 50;
			} else {
				if (!timeGiftView.parent) {
					LayerManager.uiLayer.addChild(timeGiftView);
				}
			}

			timeGiftView.glow(time);
			if (time == 0) { //如果时间为0
				timeGiftView.timeTxt.htmlText="<font size = '16' color='#ffcc00'><b>00:00:00</b></font>";
			} else { //如果时间不为0
				var countTime:Timer=new Timer(1000);
				countTime.addEventListener(TimerEvent.TIMER, onTimerHandler);
				countTime.start();
			}
			updateGiftSprite();
		}

		private function onTimerHandler(evt:TimerEvent):void {
			var countTime:Timer=evt.currentTarget as Timer;
			time--;
			timeGiftView.glow(time);
			if (time == 0) {
				countTime.removeEventListener(TimerEvent.TIMER, onTimerHandler);
				countTime.stop();
				timeGiftView.timeTxt.htmlText="<font size = '16' color='#ffcc00'><b>00:00:00</b></font>";
				if (rewardWin) {
					rewardWin.getRewardBtn.label="领取奖励";
				}
			} else {
				timeGiftView.timeTxt.htmlText="<font size = '16' color='#ffcc00'><b><font color='#00ff00'>" + countDonwTime(time) + "</font></b></font>";
			}
			updateGiftSprite();

		}

		//倒计时的处理
		private var h:int;
		private var m:int;
		private var s:int;
		private var h_str:String;
		private var m_str:String;
		private var s_str:String;

		private function countDonwTime(time:int):String {
			h=time / 3600;
			m=(time % 3600) / 60;
			s=(time % 3600) % 60;
			if (h < 10) {
				h_str="0" + h;
			} else {
				h_str=h.toString();
			}
			if (m < 10) {
				m_str="0" + m;
			} else {
				m_str=m.toString();
			}
			if (s < 10) {
				s_str="0" + s;
			} else {
				s_str=s.toString();
			}
			return h_str + ":" + m_str + ":" + s_str;
		}

		/**
		 *请求领取时间礼包
		 */
		public function reqeustGetTimeGift(rewardId:int):void {
			var vo:m_time_gift_accept_tos=new m_time_gift_accept_tos();
			vo.id=rewardId;
			this.sendSocketMessage(vo);
			updateGiftSprite();
		}

		/**
		 *领取时间礼包数据返回
		 */
		private function getTimeGiftDataBack(data:m_time_gift_accept_toc):void {
			if (rewardWin) {
				rewardWin.handlerFromService(data as Object, SocketCommand.TIME_GIFT_ACCEPT);
				if (data.succ) {
					timeGiftView.removeSomeDisplayObject();
					if (timeGiftView.parent) {
						timeGiftView.parent.removeChild(timeGiftView);
					}
					//烟花
					var effect:Effect=new Effect();
					effect.show(GameConfig.OTHER_PATH + 'libaolingqu.swf', rewardWin.x + 230, rewardWin.y + 180, LayerManager.uiLayer, 8);

					arr.length=0;
				}
			}
			updateGiftSprite();
		}

		/**
		 *  等级礼包列表数据返回
		 */
		private var arr:Array=[];
		public var gift_glow_mc:MovieClip;
		private var gift_sprite:Sprite;
		private var clazz:Class;
		private var isHasNextLvGift:int=-1; //1代表有下一级礼包，0代表没有
		private var giftLv:int;

		private function rewardDataBack(data:Object):void {
			var vo:m_level_gift_list_toc=data as m_level_gift_list_toc;
			if (vo == null)
				return;
			//等级礼包按钮
			RewardModule.getInstance().createGiftBtn();
			isHasNextLvGift=vo.gift.next_level;
			giftLv=vo.gift.id;
			if (vo.gift.goods_list.length != 0) {
				arr[0]=vo.gift;
				arr[1]=SocketCommand.LEVEL_GIFT_LIST;
				if (gift_glow_mc && gift_sprite.contains(gift_glow_mc)) {
					gift_sprite.removeChild(gift_glow_mc);
				}
				if (GlobalObjectManager.getInstance().user.attr.level >= giftLv) { //至少到达等级的时候才会闪
					clazz=Style.getClass(GameConfig.ROOT_URL + "com/assets/viewUI/viewUI.swf", "flickMC");
					gift_glow_mc=new clazz();
					gift_sprite.addChildAt(gift_glow_mc, 0);
					gift_glow_mc.x=-18;
					gift_glow_mc.y=-18;
					gift_sprite.mouseEnabled=false;
					gift_glow_mc.mouseChildren=false;
					gift_glow_mc.mouseEnabled=false;
				}
			}
			updateGiftSprite();
		}

		/**
		 *
		 * @param 移除等级礼包图标
		 *
		 */
		public function cleanGiftIcon():void {
			if (gift_sprite && LayerManager.uiLayer.contains(gift_sprite)) 
			{
				LayerManager.uiLayer.removeChild(gift_sprite);
			}
		}

		/**
		 *请求领取等级礼包
		 */
		public function reqeustGetReward(rewardId:int):void {
			var vo:m_level_gift_accept_tos=new m_level_gift_accept_tos();
			vo.id=rewardId;
			this.sendSocketMessage(vo);
			
			updateGiftSprite();
		}

		/**
		 *领取等级礼包数据返回
		 */
		private function getRewardDataBack(data:m_level_gift_accept_toc):void {
			if (rewardWin) {
				rewardWin.handlerFromService(data as Object, SocketCommand.LEVEL_GIFT_ACCEPT);
				if (data.succ) {
					//烟花
					var effect:Effect=new Effect();
					effect.show(GameConfig.OTHER_PATH + 'libaolingqu.swf', rewardWin.x + 230, rewardWin.y + 180, LayerManager.uiLayer, 8);
					arr.length=0;
				}
			}
			updateGiftSprite();
		}

		/**
		 *创建等级礼包按钮
		 */
		public var btn:Sprite;

		public function createGiftBtn():void {
			if (!btn) {
				btn=Style.getViewBg("time_libao");
				btn.buttonMode=true;
				btn.useHandCursor=true;
			}
			if (!gift_sprite) {
				gift_sprite=new Sprite();
				gift_sprite.x=GlobalObjectManager.GAME_WIDTH-206;
				gift_sprite.y=100;
				
				
				if ( GlobalObjectManager.getInstance().user.attr.level< giftLv)
				{ 
					gift_sprite.x=GlobalObjectManager.GAME_WIDTH - 206;
					gift_sprite.y=100;
				}
				else
				{
					gift_sprite.x=(GlobalObjectManager.GAME_WIDTH>>1)+50;
					gift_sprite.y=GlobalObjectManager.GAME_HEIGHT>>1;
				}
				
				
				gift_sprite.addChild(btn);
				LayerManager.uiLayer.addChild(gift_sprite);
				btn.addEventListener(MouseEvent.CLICK, onMouseClickHandler, false, 0, true);
				btn.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler, false, 0, true);
				btn.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler, false, 0, true);
			}
		}

		private function onMouseRollOverHandler(evt:MouseEvent):void {
			if (GlobalObjectManager.getInstance().user.attr.level >= giftLv) {
				ToolTipManager.getInstance().show("当前有礼包领取啦！", 50);
			} else {
				ToolTipManager.getInstance().show("加油升到" + giftLv + "级就可以领取礼包啦！", 50);
			}
		}

		private function onMouseRollOutHandler(evt:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public var isClickTimeGiftOpen:Boolean;

		private function onMouseClickHandler(evt:MouseEvent):void {
			if (arr.length != 0) {
				isClickTimeGiftOpen=false;
				loaderSource();
				if (gift_glow_mc && gift_sprite.contains(gift_glow_mc)) {
					gift_sprite.removeChild(gift_glow_mc);
				}
			} else {
				Tips.getInstance().addTipsMsg("加油升到" + giftLv + "级就可以领取礼包啦！");
			}
		}
		
		private var inCenter:Boolean=false;
		private function updateGiftSprite():void
		{
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if ( level< giftLv)
			{ 
				gift_sprite.x=GlobalObjectManager.GAME_WIDTH - 206;
				gift_sprite.y=100;
				inCenter=false;
				return;
			}
			else if(level>=giftLv && inCenter==false)
			{	
				//飞的过程
				inCenter=true;
				TweenMax.to(gift_sprite,2,{x:(GlobalObjectManager.GAME_WIDTH>>1)+50,y:GlobalObjectManager.GAME_HEIGHT>>1});
				 return;
			}
			else
			{
				gift_sprite.x=(GlobalObjectManager.GAME_WIDTH>>1)+50;
				gift_sprite.y=GlobalObjectManager.GAME_HEIGHT>>1;
			}

		}
	}
}