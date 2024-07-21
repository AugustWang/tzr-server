package com.ming.ui.controls.core
{
	import com.ming.ui.controls.IToolTip;
	/**
	 * 提示信息基类
	 */ 
	public class BaseToolTip extends UIComponent implements IToolTip
	{
		private var _mX:Number;
		private var _mY:Number;
		
		private var _targetX:Number;
		private var _targetY:Number;
		
		public function BaseToolTip()
		{
			this.mouseChildren=this.mouseEnabled=false;
		}
		
		public function set mX(value:Number):void
		{
			this._mX = value;
		}
		
		public function get mX():Number
		{
			return _mX;
		}
		
		public function set mY(value:Number):void
		{
			this._mY  = value;
		}
		
		public function get mY():Number
		{
			return _mY;
		}
		
		public function set targetX(value:Number):void
		{
			this._targetX = value;
		}
		
		public function get targetX():Number
		{
			return _targetX;
		}
		
		public function set targetY(value:Number):void
		{
			this._targetY = value;
		}
		
		public function get targetY():Number
		{
			return this._targetY;
		}
		
		public function clear():void{
			
		}
		
		public function ajustPosition(itemWidth:Number,itemHeight:Number):void{
			if(x + width > stage.stageWidth){
				x = x - itemWidth - width;
				x = Math.max(0,x);
			}
			if(y + height > stage.stageHeight){
				y = y - (height - itemHeight);
				y = Math.max(0,y);
			}
		}
	}
}