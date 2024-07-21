package com.scene.sceneData
{

	public class HandlerAction
	{
		private var _handler:Function;
		private var _params:Array;

		public function HandlerAction(handler:Function, params:Array=null)
		{
			this._handler=handler;
			this._params=params;
		}

		public function execute():void
		{
			if (_handler != null)
			{
				_handler.apply(null, _params);
				unload();
			}
		}

		public function unload():void
		{
			_handler=null;
			_params=null;
		}
	}
}