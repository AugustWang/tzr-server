package modules
{
	import com.Message;
	import com.managers.Dispatch;
	import com.net.connection.Connection;
	
	public class BaseModule
	{
		protected var connect:Connection;
		
		public function BaseModule()
		{
			connect = Connection.getInstance();
			initListeners();
		}
		/**
		 * 初始化socket监听器和初始化逻辑间的消息侦听 
		 */		
		protected function initListeners():void{
			
		}
		/**
		 * 监听来自socket的消息 
		 * @param type
		 * @param handler
		 */		
		protected function addSocketListener(type:String,handler:Function):void{
			connect.addSocketListener(type,handler);
		}
		/**
		 * 删除来自socket的消息侦听器
		 * @param type
		 * @param handler
		 */		
		protected function removeSocketListener(type:String,handler:Function):void{
			connect.removeSocketListener(type,handler);
		}
		/**
		 * 向socket发送消息 
		 */		
		protected function sendSocketMessage(vo:Message):void{
			connect.sendMessage(vo);
		}
		/**
		 * 向外部分发消息 
		 * @param type
		 * @param params
		 * 
		 */		
		protected function dispatch(type:String,params:*=null):void{
			Dispatch.dispatch(type,params);
		}
		/**
		 * 侦听来模块逻辑间的消息 
		 * @param type
		 * @param handler
		 * 
		 */		
		protected function addMessageListener(type:String,handler:Function):void{
			Dispatch.register(type,handler);
		}
		/**
		 * 删除来模块逻辑间的消息 
		 * @param type
		 * @param handler
		 */	
		protected function removeMessageListener(type:String,handler:Function):void{
			Dispatch.remove(type,handler);
		}
		/**
		 * 卸载模块 
		 */		
		public function dispose():void{
			
		}
	}
}