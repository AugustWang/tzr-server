package com.ming.managers
{
	import com.ming.ui.controls.IToolTip;
	import com.ming.ui.controls.ToolTip;
	import com.ming.ui.controls.core.BaseToolTip;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	/**
	 * 文本提示管理器,通过注册提示类(必须继承或者实现IToolTip接口)来使用 
	 * @author Administrator
	 * 
	 */
	public class ToolTipManager
	{
		public static var tipLib:Object = {defaultTip:ToolTip};
		
		private var data:Object;
		private var tipType:String = "";
		private var tipInstance:Object;
		private var tip:BaseToolTip;
		private var tipContainer:DisplayObjectContainer;
		private var targetX:Number;
		private var targetY:Number;
		private var timeOut:uint;
		public function ToolTipManager()
		{
			if(_instance){
				throw new Error("ToolTipManager只能被实例化一次");
			}
		}
		
		private static var _instance:ToolTipManager;
		public static function getInstance():ToolTipManager{
			if(_instance == null){
				_instance = new ToolTipManager();
			}
			return _instance;
		}
		/**
		 * 注册提示的父容器 
		 * @param c
		 * 
		 */		
		public function registerContainer(c:DisplayObjectContainer):void
		{
			if(tipContainer){
				tipContainer.removeEventListener(MouseEvent.MOUSE_MOVE, stageMove);
			}
			tipContainer = c;
			tipContainer.addEventListener(MouseEvent.MOUSE_MOVE, stageMove, false, 0, true);
		}
		
		public function getContainer():DisplayObjectContainer{
			return tipContainer;
		}
		
		/**
		 * 通过名称获取提示类的Class 
		 * @param name
		 * @return 
		 * 
		 */		
		public static function getToolTipClass(name:String) : Class
		{
			return tipLib[name]
		}
		/**
		 * 注册提示类 
		 * @param name
		 * @param toolTipClass
		 * 
		 */		
		public static function registerToolTip(name:String, toolTipClass:Class) : void
		{
			tipLib[name] = toolTipClass;
		}
		/**
		 * 显示提示消息 
		 * @param data 数据
		 * @param lazy_Time 延迟时间
		 * @param targetX 目标X（一般用于固定显示提示文本使用）
		 * @param targetY 目标Y
		 * @param type 类型，要显示那个提示文本
		 * 
		 */		
		public function show(data:Object,lazy_Time:int = 500,targetX:Number=0,targetY:Number=0,type:String = "defaultTip") : void
		{
			if (tip && type == tipType)
			{
				this.data = data;
				tip.targetX = this.targetX = targetX;
				tip.targetY  = this.targetY = targetY;
				tip.mX = tipContainer.mouseX;
				tip.mY = tipContainer.mouseY;
				tip.data = data;
				tipContainer.addChild(tip);
				return;
			}else if(tip){
				tipContainer.removeChild(tip);
				tip.clear();
				tip = null;
			}
			this.targetX = targetX;
			this.targetY = targetY;
			this.tipType = type;
			this.data = data;
			clearTimeout(timeOut);
			timeOut = setTimeout(timerHandler,lazy_Time);	
		}
		/**
		 * 隐藏当前提示 
		 * 
		 */		
		public function hide() : void
		{
			clearTimeout(timeOut);
			if (tip != null)
			{
				tipContainer.removeChild(tip);
				tip.clear();
				tip = null;
			}
			if (tipType != "")
			{
				tipType = "";
			}
		}
		/**
		 * 延迟处理函数 b
		 * @param event
		 * 
		 */		
		private function timerHandler() : void
		{
			if (tipType != "")
			{
				tip = getTip(tipType);
				if (tip != null)
				{	
					tip.data = data;
					tipContainer.addChild(tip);
					tip.targetX = this.targetX;
					tip.targetY = this.targetY;
					tip.mX = tipContainer.mouseX;
					tip.mY = tipContainer.mouseY;
				}
			}
		}
		
		private function stageMove(event:MouseEvent) : void
		{
			if (tip != null)
			{
				tip.mX = event.stageX;
				tip.mY = event.stageY;
				event.updateAfterEvent();
			}
		}
		
		public function getTip(name:String) : BaseToolTip
		{
			try{
				var tip:BaseToolTip;
				if (tipInstance == null || !tipInstance.hasOwnProperty(name))
				{
					tip = new (getToolTipClass(name))() as BaseToolTip;
					if (tipInstance == null)
					{
						tipInstance = new Object();
					}
					tipInstance[name] = tip;
				}
				else
				{
					tip = tipInstance[name];
				}
				return tip;
			}catch(e:Error){
				trace(e.message)
			}
			return null
		}	
	}
}