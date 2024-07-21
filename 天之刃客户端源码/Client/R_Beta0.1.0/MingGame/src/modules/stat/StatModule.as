package modules.stat
{
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	
	import proto.line.m_stat_button_tos;
	import proto.line.m_stat_config_toc;
	
	public class StatModule extends BaseModule
	{
		private var statOpen:Boolean = false;
		private static var _instance:StatModule;
		public function StatModule(){
		}
		
		public static function getInstance():StatModule{
			if(_instance == null)
				_instance = new StatModule();
			return _instance;
		}
		
		override protected function initListeners():void{
			//服务端消息
			this.addSocketListener(SocketCommand.STAT_CONFIG,statConfig);
		} 
		
		/*********************************界面视图逻辑********************************************/
		/**
		 * 添加键盘处理行为 
		 */		
		public function addKeyHandler(key:int):void{
			if(statOpen){
				statButton(key,StatConstant.TYPE_KEY);
			}
		}
		/**
		 * 添加按钮处理行为 
		 */		
		public function addButtonHandler(key:int):void{
			if(statOpen){
				statButton(key,StatConstant.TYPE_BUTTON);
			}
		}
		
		/*********************************消息发送逻辑********************************************/
		/**
		 * 统计玩家点击按钮行为
		 */		
		private function statButton(key:int,type:int):void{
			var vo:m_stat_button_tos = new m_stat_button_tos();
			vo.btn_key = key;
			vo.use_type = type;
			sendSocketMessage(vo);
		}
		
		/*********************************消息接受并处理逻辑********************************************/
		/**
		 * 是否关闭按钮点击统计（返回）
		 */		
		private function statConfig(data:Object):void{
			var vo:m_stat_config_toc = data as m_stat_config_toc;
			statOpen = vo.is_open;
		}
	}
}