package modules.vip
{
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.loaders.ViewLoader;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.DateFormatUtil;
	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.smallMap.SmallMapModule;
	import modules.system.SystemConfig;
	import modules.vip.views.ExamineHorView;
	import modules.vip.views.VipListView;
	import modules.vip.views.VipPanel;
	import modules.vip.views.VipStateView;
	
	import proto.common.p_role_vip;
	import proto.line.m_vip_active_toc;
	import proto.line.m_vip_active_tos;
	import proto.line.m_vip_info_toc;
	import proto.line.m_vip_list_toc;
	import proto.line.m_vip_list_tos;
	import proto.line.m_vip_multi_exp_toc;
	import proto.line.m_vip_multi_exp_tos;
	import proto.line.m_vip_remote_depot_toc;
	import proto.line.m_vip_remote_depot_tos;
	import proto.line.m_vip_stop_notify_toc;
	import proto.line.m_vip_stop_notify_tos;
	
	public class VipModule extends BaseModule
	{
		public static var vipInfo:p_role_vip;
		
		private static var _instance:VipModule;
		
		public var _vipDataManager:VipDataManager;
		
		private var _vipPanel:VipPanel;
		private var _vipStateView:VipStateView;
		private var _vipListView:VipListView;
		private var _examineHorView:ExamineHorView;
		private var _isInit:Boolean = true;
		private var _index:int;
		
		public function VipModule()
		{
		}
		
		public static function getInstance():VipModule
		{
			if (!_instance) {
				_instance = new VipModule();
			}
			
			return _instance;
		}
		
		override protected function initListeners():void
		{
			// 模块消息
			addMessageListener(ModuleCommand.VIP_PANEL, onOpenVipPannel);
			addMessageListener(ModuleCommand.VIP_REMOTE_DEPOT, remoteDepotTos);
			
			// 服务器消息
			addSocketListener(SocketCommand.VIP_INFO, vipInfoToc);
			addSocketListener(SocketCommand.VIP_ACTIVE, vipActiveToc);
			addSocketListener(SocketCommand.VIP_MULTI_EXP, getMultiExpToc);
			addSocketListener(SocketCommand.VIP_STOP_NOTIFY, stopNotifyToc);
			addSocketListener(SocketCommand.VIP_LIST, vipListReturn);
			addSocketListener(SocketCommand.VIP_REMOTE_DEPOT, remoteDepotToc);
		}
		
		public function openExamineView():void
		{
			if (!_examineHorView)
				_examineHorView = new ExamineHorView;
			
			_examineHorView.centerOpen();
		}
		
		/**
		 * 获取目前开通了几个远程仓库
		 */
		
		public function getRemoteDepotNum():int
		{
			if (!vipInfo || vipInfo.is_expire)
				return 0;
			
			return vipInfo.remote_depot_num;
		}
		
		/**
		 * 开通VIP远程仓库
		 */
		
		private function remoteDepotTos():void
		{
			if (!vipInfo) {
				Alert.show("你还不是VIP，不能开通远程仓库    <a href='event:openVipPanel'><font color='#00ff00'><u>成为VIP</u></font></a>", "提示", null, null, "确定", "", null, false, false, null, alertLink);
				return;
			}
			if (vipInfo.is_expire) {
				Alert.show("你的VIP已过期，不能开通远程仓库    <a href='event:openVipPanel'><font color='#00ff00'><u>续期</u></font></a>", "提示", null, null, "确定", "", null, false, false, null, alertLink);
				return;
			}
			var minLevel:int = VipDataManager.getInstance().getRemoteDepotMinLevel();
			if (vipInfo.vip_level < minLevel) {
				Alert.show("你的VIP等级不足，不能开通远程仓库    <a href='event:openVipPanel'><font color='#00ff00'><u>成为VIP" + minLevel + "</u></font></a>", "提示", null, null, "确定", "", null, false, false, null, alertLink);
				return;
			}
			var str:String = "";
			var gold:int = GlobalObjectManager.getInstance().user.attr.gold;
			var goldBind:int = GlobalObjectManager.getInstance().user.attr.gold_bind;
			var goldNeed:int = VipDataManager.getInstance().getRemoteDepotFee(vipInfo.remote_depot_num);
			if (gold + goldBind < goldNeed) {
				str = "开通第" + (vipInfo.remote_depot_num+1) + "个远程仓库需要" + goldNeed + "元宝，你当前元宝不足    <a href='event:openPay'><font color='#00ff00'><u>充值</u></font></a>";
				Alert.show(str, "提示", null, null, "确定", "", null, false, false, null, alertLink);
				return;
			}
			
			str = "确定花费" + goldNeed + "元宝，开通第" + (vipInfo.remote_depot_num+1) + "个远程仓库？"
			Alert.show(str, "提示", yesHandler);
			
			function yesHandler():void
			{
				sendSocketMessage(new m_vip_remote_depot_tos());
			}
			
			function alertLink(evt:TextEvent):void
			{
				if (evt.text == "openPay") {
					SmallMapModule.getInstance().openPayHandler();
					return;
				}
			}
		}
		
		/**
		 * 开通远程仓库返回
		 */
		
		private function remoteDepotToc(vo:m_vip_remote_depot_toc):void
		{
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		/**
		 * VIP列表返回
		 */
		
		private function vipListReturn(vo:m_vip_list_toc):void
		{			
			if (!vo.succ) {
				Tips.getInstance().addTipsMsg(vo.reason);
				return;
			}
			if (_vipPanel) {
				_vipPanel.vipListReturn(vo.vip_list);
			}
		}
		
		/**
		 * 请求VIP列表
		 */
		
		private var _lastTimeRequest:int;
		private static const _requestInterval:int = 300000;
		
		public function RequestVipList():void
		{	
			var now:int = getTimer();
			if (now - _lastTimeRequest > _requestInterval || _lastTimeRequest == 0) {
				_lastTimeRequest = now;		
				sendSocketMessage(new m_vip_list_tos);
			}
		}
		
		/**
		 * 点击我的VIP按钮
		 */
		
		public function myVipClickHandler():void
		{
			if (_vipListView && _vipListView.parent)
				_vipListView.parent.removeChild(_vipListView);
		}
		
		/**
		 * 成为VIP几
		 */
		
		public function upVipLevel(toLevel:int):void
		{
			var cardType:int = VipDataManager.getInstance().getUpLevelCardType(toLevel);
			if (cardType == -1) {
				Tips.getInstance().addTipsMsg("暂时还不支持直接升到该升级");
				return;
			}
			vipActiveTos(cardType);
		}
		
		/**
		 * 领取多倍经验_tos
		 */
		
		public function getMultiExpTos():void
		{
			sendSocketMessage(new m_vip_multi_exp_tos);
		}
		
		/**
		 * 领取多倍经验_toc
		 */
		
		private function getMultiExpToc(vo:m_vip_multi_exp_toc):void
		{
			if (vo.succ) {
				vipInfo.multi_exp_times --;
				
				BroadcastSelf.logger("多倍经验领取成功");
				return;
			}
			
			BroadcastSelf.logger(vo.reason);
		}
		
		/**
		 * 停止提示_toc
		 */
		private function stopNotifyToc(vo:m_vip_stop_notify_toc):void
		{
			if (!vo.succ) {
				BroadcastSelf.logger(vo.reason);
				return;
			}
			
			if (vo.notify_type == 1) {
				vipInfo.is_transfer_notice_free = false;
			} else {
				vipInfo.is_transfer_notice = false;
			}
		}
		
		/**
		 * 停止提示
		 */
		
		public function stopNoticTos(type:int):void
		{
			// _type: 1、跳转
			var notifyType:int;
			if (type == 1 && getMissionTransferTimes() > 0) {
				notifyType = 1;
			} else {
				notifyType = 2;
			}
			
			var vo:m_vip_stop_notify_tos = new m_vip_stop_notify_tos;
			vo.notify_type = notifyType;
			sendSocketMessage(vo);
		}
		
		/**
		 * 服务端返回角色VIP信息
		 */
		 
		private function vipInfoToc(vo:m_vip_info_toc):void
		{
			if (vo.succ) {			
				if (vipInfo && !vipInfo.is_expire && vo.vip_info.is_expire) {
					Alert.show("你的VIP已过期，是否马上续期？", "提示", yesHandler, null, "续期", "忽略");
					
					function yesHandler():void
					{
						onOpenVipPannel(4);
					}
				}
				vipInfo = vo.vip_info;
				
				if (vipInfo) {			
					if (_vipStateView) {
						_vipStateView.setData(vipInfo.vip_level);
					}
					if (_vipPanel) {
						_vipPanel.reset();
					}
				}
				showRoleVIPState();
				if (_isInit) {
					dispatch(ModuleCommand.EQUIP_CHECK_ENDURANCE);
					_isInit = false;
				}
			}
		}
		
		private function showRoleVIPState():void
		{
			if (!_vipStateView) {
				_vipStateView = new VipStateView();
				LayerManager.uiLayer.addChild(_vipStateView);
			}
			_vipStateView.setData(getRoleVipLevel());
		}
		
		/**
		 * 打开VIP面板
		 */
		
		public function onOpenVipPannel(index:int=0):void
		{
			_index = index;
			// 如果弹出来了就不再弹了
			if (!_vipDataManager) {
				_vipDataManager = new VipDataManager;
			}
			if(!ViewLoader.hasLoaded(GameConfig.VIP_UI)){
				ViewLoader.load(GameConfig.VIP_UI,onOpenVipPannel,[index]);
				return;
			}else{
				sourceLoadComplete();
			}
		}
		
		private function sourceLoadComplete():void
		{
			if (!_vipPanel) {
				_vipPanel = new VipPanel;
			}
			WindowManager.getInstance().popUpWindow(_vipPanel);
			WindowManager.getInstance().centerWindow(_vipPanel);
			if (_index > 0) {
				_vipPanel.setIndex(_index-1);
			}
		}
		
		/**
		 * 开通VIP
		 */
		
		public function vipActiveTos(vipType:int):void 
		{
			var totalTime:int;
			if (!vipInfo || vipInfo.role_id == 0) {
				totalTime = 0; 
			} else {
				totalTime = vipInfo.total_time;
			}
			
			var gold:int = GlobalObjectManager.getInstance().user.attr.gold;
			var cardInfo:Object = Object(VipDataManager.getInstance().vipCard[vipType-1]);
			var newVipLevel:int = getVipLevel(totalTime + cardInfo.timeAdd);
			var endTime:String = "";
			if (getRoleVipLevel() > 0) {
				endTime = DateFormatUtil.secToDateCn(vipInfo.end_time + cardInfo.lastTime);
			} else {
				endTime = DateFormatUtil.secToDateCn(SystemConfig.serverTime + cardInfo.lastTime);
			}
			var vipColor:String = "CEE742";
			
			var activeType:String = "续期";
			if (!vipInfo || vipInfo.role_id == 0) {
				activeType = "开通";
			}
			
			if (PackManager.getInstance().getGoodsNumByTypeId(cardInfo.typeid) > 0) {
				var vo:BaseItemVO = ItemLocator.getInstance().getObject(cardInfo.typeid);
				
				Alert.show("      确定使用你背包里的道具<font color='" + GameColors.HTML_COLORS[vo.color] + "'>【" + cardInfo.name + "】</font>" + activeType + "吗？" + activeType + "后VIP等级<font color='#" + vipColor + "'>VIP" + newVipLevel + "</font>；" + 
					"有效期至<font color='#CDE643'>" + endTime + "</font>", "提示",
					sureActiveVip, null);
			} else if (gold >= cardInfo.gold) {
				Alert.show("      确定花费<font color='#CDE643'>" + cardInfo.gold + "</font>元宝" + activeType + "VIP时长吗？" + activeType + "后VIP等级<font color='#" + vipColor + "'>VIP" + newVipLevel + "</font>；" + 
					"有效期至<font color='#CDE643'>" + endTime + "</font>", "提示",
					sureActiveVip, null);
			} else {
				Alert.show("你的背包不绑定元宝不足" + cardInfo.gold + "，<font color='#39E352'><a href='event:chongZhi'><u>立即充值</u></a></font></font>", "提示",
						   null, null, "确定", "", null, false, true, null, linkFun);
			}
			
			function sureActiveVip():void
			{
				var vo:m_vip_active_tos = new m_vip_active_tos;
				vo.vip_type = vipType;
				
				sendSocketMessage(vo);				
			}
		} 
		
		private function linkFun(e:Event):void
		{
			SmallMapModule.getInstance().openPayHandler();
		}
		
		/**
		 * 开通VIP返回
		 */
		
		private function vipActiveToc(vo:m_vip_active_toc):void
		{
			if (vo.succ) {
				vipInfo = vo.vip_info;
				
				var msg:String = "";
				if (vo.gold != 0) {
					msg += "花费" + vo.gold + "元宝，成功开通VIP，身份持续到" + DateFormatUtil.secToDateCn(vipInfo.end_time);
				} else {
					msg += "消耗【" + ItemLocator.getInstance().getObject(vo.item).name + "】×1，成功开通VIP，身份持续到" + DateFormatUtil.secToDateCn(vipInfo.end_time);
				}
				BroadcastSelf.logger(msg);
						
				if (_vipStateView) {
					_vipStateView.setData(vipInfo.vip_level);
				}
				if (_vipPanel) {
					_vipPanel.reset();
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		/**
		 * 是否VIP
		 */
		
		public function isVip():Boolean{
			if (!vipInfo  || vipInfo.role_id == 0) {
				return false;
			}
			
			return (!vipInfo.is_expire);
		}
		
		/**
		 * VIP是否过期
		 */
		
		public function isVipExpire():Boolean
		{
			if (!vipInfo || vipInfo.role_id == 0)
				return false;
			
			return vipInfo.is_expire;
		}
		
		
		/**
		 * 任务免费传送剩余次数
		 */
		
		public function getMissionTransferTimes():int{
			if (!vipInfo || vipInfo.role_id == 0)
				return 0;
			
			if (vipInfo.is_expire)
				return 0;
			
			return vipInfo.mission_transfer_times;
		}
		
		/**
		 * 任务免费传送总次数
		 */
		
		public function getMissionTransTotalTimes():int
		{
			if (!vipInfo || vipInfo.role_id == 0)
				return 0;
			
			if (vipInfo.is_expire)
				return 0;
			
			return getTransferTimesByVipLevel(vipInfo.vip_level);
		}
		
		/**
		 * 快速任务免费传送是否提示
		 */
		
		public function isMissionTransNoticeFree():Boolean
		{
			return vipInfo.is_transfer_notice_free;
		}
		
		/**
		 * 快速任务传送卷传送是否提示
		 */
		
		public function isMissionTransNotic():Boolean
		{
			return vipInfo.is_transfer_notice;
		}
		
		/**
		 * 根据等级获取传送总次数
		 */
		
		private function getTransferTimesByVipLevel(vipLevel:int):int
		{
			return Object(VipDataManager.getInstance().vipLevel[vipLevel-1]).transfer;
		}
		
		/**
		 * 根据时长获取VIP等级
		 */
		
		public function getVipLevel(time:int):int
		{
			for (var i:int = VipDataManager.getInstance().vipLevel.length; i > 0; i --) {
				if (time >= Object(VipDataManager.getInstance().vipLevel[i-1]).point)
					return i;
			}
			
			return 1;
		}
		
		/**
		 * 获取VIP信息
		 */
		
		public function getVipInfo():p_role_vip{
			return vipInfo;
		}
		
		/**
		 * 免费刷离线经验次数
		 */
		
		public function getAccuExpTimes():int
		{
			if (!vipInfo || vipInfo.role_id == 0) {
				return 0;
			}
			
			if (vipInfo.is_expire) {
				return 0;
			}
			
			return vipInfo.accumulate_exp_times;
		}
		
		/**
		 * 获取VIP等级，过期后VIP等级0
		 */
		
		public function getRoleVipLevel():int
		{
			if (!vipInfo || vipInfo.role_id == 0)
				return 0;
			
			if (vipInfo.is_expire)
				return 0;
			
			return vipInfo.vip_level;
		}
		
		/**
		 * 根据VIP等级获取商店折扣
		 */
		
		public function getShopDiscount(level:int):int
		{
			if (level == 0) {
				return 100;
			}
			
			return Object(VipDataManager.getInstance().vipLevel[level-1]).discount;
		}
		
		/**
		 * 宠物训练是否免费
		 */
		
		public function isPetFeedFree():Boolean
		{
			if (!vipInfo || vipInfo.role_id == 0 || vipInfo.is_expire || vipInfo.vip_level < 2 || vipInfo.pet_training_times <= 0)
				return false;
			
			return true;
		}
		
		/**
		 * 宠物训练提示
		 */
		
		public function getPetFeedDesc():String
		{
			if (!vipInfo || vipInfo.role_id == 0 || vipInfo.is_expire || vipInfo.vip_level < 2)
				return "<font color='#FFFF00'>5</font>元宝<font color='#FF0000'>（VIP2每天免费立即完成两次）</font>";
			
			if (vipInfo.pet_training_times > 0)
				return "<font color='#FF3C39'>VIP" + vipInfo.vip_level + "</font>免费";
			
			return "<font color='#FFFF00'>5</font>元宝";
		}
	}
}