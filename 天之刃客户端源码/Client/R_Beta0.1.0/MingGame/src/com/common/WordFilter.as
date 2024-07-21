package com.common
{
	import com.common.GlobalObjectManager;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class WordFilter
	{
		private static var charctors:Dictionary;
		private static var inited:Boolean = false;
		public function WordFilter()
		{
			
		}
		
		/**
		 * 为了不用加载所以写死(上面有加载的方法) 
		 */		
		private static function init():void{
			charctors = new Dictionary();
			register("元.*?宝",0.5);
			register("出.*?售",0.5);
			register("销.*?售",1.0);
			register("经.*?销",1.0);
			register("诚.*?信",0.8);
			register("商.*?人",0.5);
			register("代.*?理",0.8);
			register("信.*?誉",0.5);
			register("购.*?买",0.5);
			
			register("咨.*?询",0.5);
			register("联.*?系",0.5);
			register("货.*?到",0.8);
			register("付.*?款",0.8);
			register("热.*?线",0.5);
			
			register("特.*?价",0.5);
			register("认.*?准",0.5);
			register("售.*?货",0.5);
			register("详.*?情",0.5);
			register("Y.*?B",0.5);
			register("Q.*?Q",0.5);
			register("安全交易",0.5);
			
			register("安全交易",0.5);
			register("交易安全",0.5);
			register("=.*?100.*?RMB",0.8);
			register("=.*?100.*?元",0.8);
			register("=.*?200.*?RMB",0.8);
			register("=.*?200.*?元",0.8);
			register("Q",0.5);
			register("=.*?00",0.5);
			register("优.*?惠",0.5);
			inited = true;
		}
		
		private static function register(regString:String,value:Number):void{
			charctors[new RegExp(regString,"gi")] = value;
		}
		
		public static function isValid(msg:String):Boolean{
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			if(level <= 20){
				if(inited == false){
					init();
				}
				var totalValue:Number = 0;
				for(var reg:Object in charctors){
					var regExp:RegExp = reg as RegExp;
					regExp.lastIndex = 0;
					if(regExp.test(msg)){
						totalValue += Number(charctors[reg]);
					}
					if(totalValue >= 1){
						return false;
					}
				}
				return true;
			}
			return true;
		}
	}
}