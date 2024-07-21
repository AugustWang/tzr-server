package com.net.event
{
	import flash.events.Event;
	/**
	 * 连接事件处理 
	 * @author Administrator
	 * 
	 */	
	public class ConnectionEvent extends Event
	{
		/**
		 * 连接失败 
		 */		
		public static const FAILURE:String = "socket_failure";
		/**
		 * 连接成功 
		 */		
		public static const SUCCESS:String = "socket_success";
		/**
		 * 连接断开 
		 */		
		public static const CLOSE:String = "socket_close";
		/**
		 * 安全沙箱
		 */
		public static const SECURITY_ERROR:String = "socket_security_error";
		/**
		 * IO错误 
		 */		
		public static const IO_ERROR:String = "socket_io_error";
		public var data:Object;
		public function ConnectionEvent(type:String)
		{
			super(type);
		}
		
		override public function clone():Event{
			var evt:ConnectionEvent = new ConnectionEvent(type);
			evt.data = data;
			return evt;
		}
	}
}