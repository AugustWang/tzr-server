package modules.bigExpresion {
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.loaders.ViewLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUtils.SceneUnitType;
	
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.bigExpresion.view.BigExpresionView;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.scene.SceneModule;
	import modules.scene.cases.ChatCase;
	
	import proto.line.m_bubble_msg_toc;
	import proto.line.m_bubble_send_toc;
	import proto.line.m_bubble_send_tos;

	public class BigExpresionModule extends BaseModule {
		public static var tip_arr:Array;
		
		private static var _instance:BigExpresionModule;
		
		private var currentTime:int = 0;
		private var _isSelected:Boolean;
		private var _playerName:String;

		public function BigExpresionModule() {
			tip_arr = BigExpresionDataManager.getInstance().arr;
		}

		public static function getInstance():BigExpresionModule {
			if (!_instance) {
				_instance=new BigExpresionModule()
			}
			return _instance;
		}

		override protected function initListeners():void {
			//服务端消息
			this.addSocketListener(SocketCommand.BUBBLE_SEND, backFromService_SEND);
			this.addSocketListener(SocketCommand.BUBBLE_MSG, doBubbleBubbleMsg);
		}

		private function doBubbleBubbleMsg(vo:m_bubble_msg_toc):void {
			if (vo.action_type == 0) {
				ChatCase.getInstance().say(vo);
			} else {
				backFromService_MSG(vo)
			}
		}

		/**
		 *打开大表情界面
		 */
		private var bigExpresionView:BigExpresionView;
		public function openBigExpresionView():void {
			if(!ViewLoader.hasLoaded(GameConfig.BIG_EXPRESION_UI)){
				ViewLoader.load(GameConfig.BIG_EXPRESION_UI,open);
			}else{
				open();
			}
		}

		private function open():void {
			if (!bigExpresionView) {
				bigExpresionView=new BigExpresionView();
			}
			WindowManager.getInstance().popUpWindow(bigExpresionView, WindowManager.REMOVE);
			WindowManager.getInstance().centerWindow(bigExpresionView);
			bigExpresionView.x = 200;
		}		
		/**
		 * 请求发送表情
		 */
		
		public function requestSendExpression(msg:String):void
		{
			if(getTimer() - currentTime > 3000){
				currentTime = getTimer();
				var hero:MyRole = SceneModule.getInstance().view.hero;
				var selectRoleVo:SeletedRoleVo = RoleStateDateManager.seletedUnit;
				if(selectRoleVo && selectRoleVo.unit_type == SceneUnitType.ROLE_TYPE){//符近玩家,保证不是NPC或怪物
					var playerId:int = selectRoleVo.id;
					_isSelected = true;
					_playerName = selectRoleVo.name;
					requestSendExpresion(msg, playerId);
				}else{
					if(hero != null){
						requestSendExpresion(msg, int(hero.id));
					}
				}
			}else{
				BroadcastSelf.logger("太快了，坐下来喝杯咖啡，休息下~");
			}
		}

		/**
		 *请求发送表情
		 *
		 */
		public function requestSendExpresion(msg:String, roleId:int):void {
			var vo:m_bubble_send_tos = new m_bubble_send_tos();
			vo.action_type=1; //0是普通聊天，1是表情
			vo.msg=msg;
			vo.to_role_id=roleId;
			this.sendSocketMessage(vo);
		}

		//发送普通场景聊天
		public function requestSendString(msg:String):void {
			var vo:m_bubble_send_tos = new m_bubble_send_tos();
			vo.action_type=0; //0是普通聊天，1是表情
			vo.msg=msg;
			vo.to_role_id=0;
			this.sendSocketMessage(vo);
		}

		/**
		 *服务器信息返回 SEND
		 *
		 */
		public function backFromService_SEND(data:Object):void {
			dealDataFromService(data, SocketCommand.BUBBLE_SEND);
		}
		/**
		 *
		 * 服务器信息返回  MSG
		 *
		 */
		public function backFromService_MSG(data:Object):void {
			dealDataFromService(data, SocketCommand.BUBBLE_MSG);
		}		
		/**
		 *集中处理从服务端返回的数据 
		 * @param data
		 * @param str
		 * 
		 */		
		public function dealDataFromService(data:Object,str:String):void{
			var hero:MyRole = SceneModule.getInstance().view.hero;
			switch(str){
				case SocketCommand.BUBBLE_SEND:
					var sendVo:m_bubble_send_toc = data as m_bubble_send_toc;
					if(sendVo == null)return;
					if(sendVo.succ){
						//成功时，暂时没有其他的操作
					}else{
						Tips.getInstance().addTipsMsg(sendVo.reason);
					}
					break;
				case SocketCommand.BUBBLE_MSG:
					var msgVo:m_bubble_msg_toc = data as m_bubble_msg_toc;
					if(msgVo == null)return;
					if(hero != null){
						var _actor:Role = SceneUnitManager.getUnit(msgVo.actor_id) as Role;
						var _toRole:Role = SceneUnitManager.getUnit(msgVo.to_role_id) as Role;
						if(_actor&&_actor.pvo!=null){
							_actor.expresion(int(msgVo.msg));
							if(msgVo.to_role_id == hero.pvo.role_id){
								BroadcastSelf.logger("<font color='#ffff00'>【"+_actor.pvo.role_name+"】"+tip_arr[int(msgVo.msg)].receive+"</font>");
							}
						}else if(msgVo.actor_id == hero.pvo.role_id){
							hero.expresion(int(msgVo.msg));
							if(_isSelected){
								_isSelected = false;
								BroadcastSelf.logger("<font color='#ffff00'>你对【"+_playerName+"】"+ tip_arr[int(msgVo.msg)].send+"</font>");
							}else{
								BroadcastSelf.logger("<font color='#ffff00'>"+tip_arr[int(msgVo.msg)].self+"</font>");
							}
						}
					}
					break;
			}
		}
	}
}