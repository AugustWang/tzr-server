package com.ming.utils
{

	/**
	 * 带参函数执行器 
	 */
	public class Handler
	{
		public var caller:*;
		public var handler:Function;
		public var params:Array;
		
		private var _toFunction:Function;
		/**
		 * 函数执行器
		 */
		public function Handler(handler:*=null,params:Array=null,caller:*=null)
		{
			this.handler = handler;
			this.params = params;
			this.caller = caller;
		}
		
		/**
		 * 调用
		 */
		public function call(...params) : void
		{
			if (handler != null)
			{
				if (params && params.length > 0)
					handler.apply(this.caller,params);
				else
					handler.apply(this.caller,this.params);
			}
		}
	}
}