package com.managers
{
	import com.globals.GameParameters;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import modules.system.SystemModule;

	/**
	 * 事件分发器 
	 */	
	public class Dispatch
	{
		public var observers:Dictionary;
		private var mapping:Dictionary;
		public function Dispatch()
		{
			super();
			observers = new Dictionary();
			mapping = new Dictionary;
		}
		
		private static var instance:Dispatch;
		private static function getInstance():Dispatch{
			if(instance == null){
				instance = new Dispatch();
			}
			return instance;
		}
		
		private function add(type:String,call:Function, module:String=null, method:String=null):void{
			var funcs:Array = observers[type];
			mapping[call] = {'module':module, 'method':method};
			if(funcs == null){
				funcs = [];
				observers[type] = funcs;
			}else{
				if(funcs.indexOf(call) != -1){
					return;
				}
			}
			funcs.push(call);
		}
		
		private function remove(type:String,call:Function):void{
			var funcs:Array = observers[type];
			if(funcs){
				var index:int = funcs.indexOf(call);
				if(index != -1){
					funcs.splice(index,1);
				}
			}
		}
		
		private function execute(type:String,param:Object):void{
			var funcs:Array = observers[type];
			for each(var call:Function in funcs){
				if (GameParameters.getInstance().isDebug()) {
					if(param == null){
						call.apply(null,null);
					}else{
						call.apply(null,[param]);
					}
				} else {
					try {
						if(param == null){
							call.apply(null,null);
						}else{
							call.apply(null,[param]);
						}
					} catch (e:Error) {
						var obj:Object = mapping[call];
						if (obj != null) {
							SystemModule.getInstance().postError(e, type, obj.module, obj.method);	
						} else {
							SystemModule.getInstance().postError(e, type);
						}
					}
				}
			}
		}
		
		public static function dispatch(type:String,param:Object=null):void{
			getInstance().execute(type,param);
		}
		
		public static function register(type:String,call:Function, module:String=null, method:String=null):void{
			getInstance().add(type,call,module,method);
		}
		
		public static function remove(type:String,call:Function):void{
			getInstance().remove(type,call);
		}
	}
}