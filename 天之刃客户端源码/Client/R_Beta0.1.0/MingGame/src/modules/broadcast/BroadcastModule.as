package modules.broadcast {
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	import com.scene.WorldManager;
	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.BroadcastView;
	import modules.broadcast.views.CountdownView;
	import modules.broadcast.views.EnduranceCheckWindow;
	import modules.broadcast.views.PopupLabaWindow;
	import modules.broadcast.views.PopupWindow;
	import modules.broadcast.views.SpeakerView;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.chat.ChatType;
	
	import proto.common.p_chat_role;
	import proto.line.m_broadcast_countdown_toc;
	import proto.line.m_broadcast_general_toc;
	import proto.line.m_broadcast_laba_toc;
	import proto.line.m_map_role_killed_toc;
	import proto.line.m_ybc_notify_pos_toc;

	public class BroadcastModule extends BaseModule {
		private static var instance:BroadcastModule;

		private var broadcastView:BroadcastView;
		private var selfbroadcast:BroadcastSelf;
		private var items:Array=[];
		private var roleDatas:Array=[];
		public var countdownView:CountdownView

		public function BroadcastModule() {
		}

		public static function getInstance():BroadcastModule {
			if (!instance) {
				instance=new BroadcastModule();
			}

			return instance;
		}

		private function initBroadcast():void {
			if (countdownView == null) {
				countdownView=new CountdownView();
					//LayerManager.uiLayer.addChild(countdownView);这句会导致错误
			}

			LayerManager.main.addChild(Tips.getInstance());
			LayerManager.uiLayer.addChild(BroadcastView.getInstance());
			LayerManager.uiLayer.addChildAt(BroadcastSelf.getInstance(), 0);
			LayerManager.uiLayer.addChild(SpeakerView.getInstance());
			LayerManager.uiLayer.addChild(countdownView);
			SpeakerView.getInstance().visibled=false;
		}


		override protected function initListeners():void {

			addMessageListener(ModuleCommand.ENTER_GAME, initBroadcast); //START_LOGIN
			addMessageListener(ModuleCommand.BROADCAST, handlerMsgBroadcast);
			addMessageListener(ModuleCommand.BROADCAST_SELF, handlerMsgSelf);
			addMessageListener(ModuleCommand.TIPS, handlerTips);

			addMessageListener(ModuleCommand.MAP_BROTHER_KILLED, killedBrother);
			addMessageListener(ModuleCommand.YBC_NOTIFY_POS, showYbcPos);
			addMessageListener(ModuleCommand.BROADCAST_SHOW, BroadcastView.getInstance().addBroadcastMsg);

//			addSocketListener(SocketCommand.BROADCAST_SEND, sysInfoHandler);
			addSocketListener(SocketCommand.BROADCAST_GENERAL, dealGeneralMsg);
			addSocketListener(SocketCommand.BROADCAST_COUNTDOWN, dealCountDownMsg);
			addSocketListener(SocketCommand.BROADCAST_LABA, labaMsg);
		}

		private function dealGeneralMsg(vo:m_broadcast_general_toc):void {
			var typeList:Array=new Array;
			typeList=typeList.concat(vo.type);

			for (var i:int=0; i < typeList.length; i++) {
				var type:int=typeList[i];

				switch (type) {
					case BroadCastConstant.SYSTEM_MSG:
						dealSystemMsg(vo);
						break;
					case BroadCastConstant.SPEAKER_MSG:
						dealSpeakerMsg(vo);
						break;
					case BroadCastConstant.CENTRAL_BROADCASTING_MSG:
						dealCentralBroadCastMsg(vo);
						break;
					case BroadCastConstant.CHAT_CHANNEL_MSG:
						dealChatChannelMsg(vo);
						break;
					case BroadCastConstant.POPUP_WINDOW_MSG:
						dealPopupWindowMsg(vo);
						break
				}
			}
		}

		//倒计时消息      todo (只用于时间同步 ？)
		private function dealCountDownMsg(vo:m_broadcast_countdown_toc):void {
			switch (vo.sub_type) {
				case BroadCastConstant.DUPLICATE_TIME_MSG: //副本时间消息
					duplicateTime(vo);
					break;
				case BroadCastConstant.TASK_TIME_MSG: //任务时间消息
					taskTime(vo);
					break;
				default:
					break;
			}
		}

		private function labaMsg(vo:m_broadcast_laba_toc):void {
			if (!vo.return_self) {
				var msg:String="";
				var countryStr:String=BroadCastConstant.getCountryStr(vo.faction_id);
				var sex:String='';
				vo.sex == 1 ? sex="<font color='#00ccff'><b>♂</b></font>" : sex="<font color='#ff37e0'><b>♀</b></font>";
				var nameHtml:String;
				if (vo.role_id != GlobalObjectManager.getInstance().user.base.role_id) {
					nameHtml=countryStr + sex + "<font color ='#ffff00'>[" + "<a href = 'event:somebody'>" + vo.role_name + "</a>" + "] </font>";
				} else {

					nameHtml=countryStr + sex + "<font color ='#ffff00'>[" + vo.role_name + "] </font>";
				}
				msg=nameHtml + "<font color = '#ffde00'>" + vo.content + "</font>";

				var role:p_chat_role=new p_chat_role();
				role.head=vo.sex;
				role.roleid=vo.role_id;
				role.rolename=vo.role_name;
				role.sex=vo.sex;
				role.factionid=vo.faction_id;
				SpeakerView.getInstance().appMsgRole(role);
				SpeakerView.getInstance().appendMsg(msg);

			}
		}

		public function recordLabaMsg(str:String, role:Object):void {
			items.push(str);
			roleDatas.push(role);
			if (items.length > 10) {
				items.shift();
				roleDatas.shift();
			}
			if (_labaWindow) {
				_labaWindow.appendTxt(str, role);
			}
		}

		public function showLabaView():void {
			SpeakerView.getInstance().visible=true;
		}

		public function hideLabaView():void {
			SpeakerView.getInstance().visible=false;
		}

		public function changeLabapos(pos:int=1):void // 0 min  1 normor   2 bigger  3 max
		{
			var speaker:SpeakerView=SpeakerView.getInstance();
			switch (pos) {
				case 0:
					speaker.y=GlobalObjectManager.GAME_HEIGHT - 195; //230;//455;
					break;
				case 1:
					speaker.y=GlobalObjectManager.GAME_HEIGHT - 310 //345;//340;
					break;
				case 2:
					speaker.y=GlobalObjectManager.GAME_HEIGHT - 378; //413;//272;
					break;
				case 3:
					speaker.y=GlobalObjectManager.GAME_HEIGHT - 446; //481;//204;
					break;
				default:
					break;
			}
		}


		//系统消息
		private function dealSystemMsg(vo:m_broadcast_general_toc):void {
			BroadcastSelf.logger(vo.content);
		}

		//传音消息
		private function dealSpeakerMsg(vo:m_broadcast_general_toc):void {
			SpeakerView.getInstance().appendMsg(vo.content);
		}

		//中央广播消息
		private function dealCentralBroadCastMsg(vo:m_broadcast_general_toc):void {
			var tmptxt:TextField=new TextField();
			tmptxt.htmlText=vo.content;
			var msg:String=tmptxt.text.split("\\n").join("\n");
			//trace("....通过textfield转换....."+msg);
			BroadcastView.getInstance().addBroadcastMsg(msg);

			msg=null;
			tmptxt=null;
		}

		//聊天频道消息
		private function dealChatChannelMsg(vo:m_broadcast_general_toc):void {
			var msg:String=vo.content.split("<br>").join("");
			msg=msg.split("\\n").join("");
			msg="【系】<font color='#ffffff'>" + msg + "</font>";
			switch (vo.sub_type) {
				case BroadCastConstant.WORLD_MSG:
					sendChatMsg(msg, null, ChatType.WORLD_CHANNEL);
					break;
				case BroadCastConstant.FACTION_MSG:
					sendChatMsg(msg, null, ChatType.COUNTRY_CHANNEL);
					break;
				case BroadCastConstant.FAMILY_MSG:
					sendChatMsg(msg, null, ChatType.FAMILY_CHANNEL);
					break;
				case BroadCastConstant.TEAM_MSG:
					sendChatMsg(msg, null, ChatType.TEAM_CHANNEL);
					break;
				case BroadCastConstant.PERSON_MSG:
					sendChatMsg(msg, null, ChatType.PRIVATE_CHANNEL);
					break;
			}
		}


		private var enduranceCheckWindow:EnduranceCheckWindow;

		//add by handing @2011.4.21 14:52 显示提示耐久度为0的window
		public function openEnduranceWindow():void {
			if (enduranceCheckWindow == null) {
				enduranceCheckWindow=new EnduranceCheckWindow();
				enduranceCheckWindow.x=LayerManager.stage.stageWidth - enduranceCheckWindow.width - 44;
				enduranceCheckWindow.y=LayerManager.stage.stageHeight - enduranceCheckWindow.height - 20;
			}
			LayerManager.uiLayer.addChild(enduranceCheckWindow);
		}

		//弹窗消息
		private function dealPopupWindowMsg(vo:m_broadcast_general_toc):void {
			if (!vo || !vo.content)
				return;
			popup(vo.content);
		}

		private var msgQueue:Array;

		public function popup(msg:String, linkStr:String="", fun:Function=null, obj:Object=null, sec:int=10):void {
			//暂时屏蔽弹出
//			if (popupWindow == null) {
//				popupWindow=new PopupWindow();
//				popupWindow.addEventListener(CloseEvent.CLOSE, onPopupWindowClosed);
//				msgQueue=[];
//			}
//			if (popupWindow.parent == null) {
//				popupWindow.setContent(msg, linkStr, fun, obj);
//				popupWindow.popup(sec);
//			} else {
//				popupWindow.setContent(msg, linkStr, fun, obj);
//			}
		}


		private function onPopupWindowClosed(event:CloseEvent):void {
			if (msgQueue && msgQueue.length > 0) {
				var obj:Object=msgQueue.shift();
				popup(obj.msg, obj.linkStr, obj.fun, obj.obj, obj.sec);
			}
		}

		public function popupWindowMsg(str:String, sec:int=5):void {
			if (!str) {
				return;
			}
			popup(str, "", null, null, sec);
		}

		/**
		 * 好友祝福
		 *
		 */
		public function popupMsg(str:String, linkString:String="", callBackFun:Function=null, object:Object=null):void {
			popup(str, linkString, callBackFun, object);
		}

		//副本消息  (同步？)
		private function duplicateTime(vo:m_broadcast_countdown_toc):void {

		}

		//任务消息 (同步？)
		private function taskTime(vo:m_broadcast_countdown_toc):void {
		}

		private function handlerMsgBroadcast(message:String):void {
			var tmptxt:TextField=new TextField();
			tmptxt.htmlText=message;
			var msg:String=tmptxt.text;
			BroadcastView.getInstance().addBroadcastMsg(msg);
			msg=null;
			tmptxt=null;
		}

		private function handlerMsgSelf(message:String):void {
			BroadcastSelf.logger(message);
		}

		private function handlerTips(msg:String):void {
			Tips.getInstance().addTipsMsg(msg);
		}

		private function showYbcPos(vo:m_ybc_notify_pos_toc):void {
			var map_name:String=WorldManager.getMapName(vo.map_id);
			var str:String="<font color='#FFFF00'>你的镖车当前位置在 <a href='event:goto#" + vo.map_id + "," + vo.tx + "," + vo.ty + "'><u>" + map_name + "(" + vo.tx + "," + vo.ty + ")</u></a></font>";
			BroadcastSelf.logger(str);
		}

		private function killedBrother(vo:m_map_role_killed_toc):void {
			if (vo.role_name == GlobalObjectManager.getInstance().user.base.role_name)
				return;
			var map_name:String=WorldManager.getMapName(vo.map_id);

			var str:String="有外敌在<a href='event:ATTACK#" + vo.map_id + "," + vo.tx + "," + vo.ty + "'><u><font color='#00ff00'>" + map_name + "</font></u></a>" + "袭击我国国民<font color='#ffff00'>[" + vo.role_name + "]</font>，请速<a href='event:ATTACK#" + vo.map_id + "," + vo.tx + "," + vo.ty + "'><u><font color='#00ff00'>前往支援</font></u></a>！";

			//有外敌在新手村袭击我国国民[yyy]，请速支援！
			//<a href='event:ATTACK#'><u></u></a>
			BroadcastSelf.logger(str);
		}

		private function test():void {
			var str:String="有外敌在<a href='event:ATTACK#2,5,5'>" + "<u>" + "XX图" + "</u></a>" + "袭击我国国民<font color='#ffff00'>[" + "roleName" + "]</font>,请速<a href='event:ATTACK#2,5,5'>" + "<u>前往支援</u></a>！";

			//有外敌在新手村袭击我国国民[yyy]，请速支援！
			//<a href='event:ATTACK#'><u></u></a>
			BroadcastSelf.logger(str);
		}

		private var _labaWindow:PopupLabaWindow;

		public function popupLabaRecord():void {
			if (!_labaWindow) {
				_labaWindow=new PopupLabaWindow();
				_labaWindow.centerOpen();
				_labaWindow.addEventListener(CloseEvent.CLOSE, onLabaClose);

				_labaWindow.setDatas(items, roleDatas);

			} else {

				onLabaClose();
			}
		}

		private function onLabaClose(e:CloseEvent=null):void {
			if (_labaWindow) {
				_labaWindow.removeEventListener(CloseEvent.CLOSE, onLabaClose);
				_labaWindow.dispose();
				WindowManager.getInstance().removeWindow(_labaWindow);
				_labaWindow=null;
			}
		}


		private var _popupWindow:PopupWindow;

		public function set popupWindow(value:PopupWindow):void {
			_popupWindow=value
		}

		public function get popupWindow():PopupWindow {
			return _popupWindow
		}

		public function sendToScene(arr:Array):void {
			if (!arr) {
				return;
			}

			this.dispatch(ModuleCommand.GOTO_BROTHER_KILLED, arr);
		}

		private function sendChatMsg(msg:String, role:*=null, channel:String=null):void {
			ChatModule.getInstance().sendChatMsg(msg, role, channel);
		}

		public function addToCountDown(obj:DisplayObject):void {
			if (countdownView == null) {
				countdownView=new CountdownView();
			}
			countdownView.addChilren(obj);
		}
	}
}