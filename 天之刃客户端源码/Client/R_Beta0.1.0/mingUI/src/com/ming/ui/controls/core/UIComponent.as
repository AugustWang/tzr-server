package com.ming.ui.controls.core
{
	import com.ming.core.IDataRenderer;
	import com.ming.core.IDisposable;
	import com.ming.events.ResizeEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	
	[Event(name="resize", type="com.ming.events.ResizeEvent")]
	
	/**
	 * 所有组件的基类，提供对组件的大小、皮肤、绘制、等操作.
	 */
	public class UIComponent extends Sprite implements IDataRenderer,IDisposable
	{
		private var _bgSkin:Skin; //背景皮肤
		private var _height:Number=0; //高度 
		private var _width:Number=0; //宽度 
		private var _bgAlpha:Number=0; //背景透明度
		private var _bgColor:uint=0xffffff; //背景颜色 
		
		private var _isUpdate:Boolean=false; 
		private var _bgAlphaChanged:Boolean=false; //背景透明度是否发生改变
		private var _bgColorChanged:Boolean=false; //背景颜色 是否发生改变
		private var _bgSkinChanged:Boolean=false; //背景皮肤是否改变  
		private var _sizeChanged:Boolean=true; //宽度高度是否已经改变
		protected var listeners:Array; //事件列表
		
		private var _data:Object;

		public function UIComponent()
		{
			listeners = [];
			invalidateDisplayList();
		}
		/**
		 * 设置和获取皮肤类
		 */
		public function get bgSkin():Skin
		{
			return _bgSkin;
		}
		public function set bgSkin(skin:Skin):void
		{
			if (skin == bgSkin)
				return ;
			if (_bgSkin != null && contains(_bgSkin))
			{
				removeChild(_bgSkin);
			}
			_bgSkinChanged=true;
			_bgSkin=skin;
			invalidateDisplayList();
		}
		/**
		 * 覆盖父类设置和获取宽度的方法
		 */
		override public function get width():Number
		{
			return _width;
		}
		override public function set width(value:Number):void
		{
			if(_width == value)
				return;
			_width=value;
			_sizeChanged=true;
			invalidateDisplayList();
		}
		/**
		 * 覆盖父类设置和获取高度的方法
		 */
		override public function get height():Number
		{
			return _height;
		}
		override public function set height(value:Number):void
		{
			if(_height == value)
				return;
			_height=value;
			_sizeChanged=true;
			invalidateDisplayList();
		}
		/**
		 * 设置获取背景透明度
		 */
		public function get bgAlpha():Number
		{
			return _bgAlpha;
		}
		public function set bgAlpha(value:Number):void
		{
			_bgAlpha=value;
			_bgAlphaChanged=true;
			invalidateDisplayList();
		}
		/**
		 * 设置和获取背景颜色的方法
		 */
		public function get bgColor():uint
		{
			return _bgColor;
		}
		public function set bgColor(value:uint):void
		{
			_bgColor=value;
			_bgColorChanged=true;
			invalidateDisplayList();
		}
		/**
		 * 调用需要界面实效的方法，在下一渲染期进行重新绘制
		 */
		public function invalidateDisplayList():void
		{
			_isUpdate=true;
			addEventListener(Event.ENTER_FRAME, onRender);
		}
		/**
		 * 处理帧频事件
		 */
		private function onRender(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME,onRender);
			update();
		}

		private function update():void
		{
			if (_isUpdate == true)
				updateDisplayList(width, height);
		}
		/**
		 * 修改宽高，而不抛出大小改变的事件
		 */ 
		public function setSize(w:Number,h:Number):void{
			this._width = w;
			this._height = h;
		}
		
		public function get data():Object{
			return this._data
		}
		public function set data(value:Object):void{
			this._data = value;
		}
		
		private var _toolTip:Object;
		private var toolTipClass:Class;
		private var tipname:String;
		private var lazyTime:int;
		private var _showToolTip:Boolean;
		
		public function set showToolTip(bool:Boolean):void
		{
			this._showToolTip = bool;
		}
		public function get showToolTip():Boolean
		{
			return this._showToolTip;
		}
		
		public function setToolTip(toolTip:Object,lazyTime:int=500,toolTipClass:Class=null):void{
			this._toolTip = toolTip;
			this.toolTipClass = toolTipClass;
			this.lazyTime = lazyTime;
			this._showToolTip = true;
			if(toolTipClass){
				tipname = getQualifiedClassName(toolTipClass);
				ToolTipManager.registerToolTip(tipname,toolTipClass);
			}else{
				tipname="defaultTip";
			}
			addEventListener(MouseEvent.ROLL_OVER,onToolTipShow);
			addEventListener(MouseEvent.ROLL_OUT, onToolTipHide);
		}
		
		public function setToolTipClass(toolTipClass:Class, lazyTime:int = 500):void
		{
			if(toolTipClass != null)
			{
				this.toolTipClass = toolTipClass;
				this._showToolTip = true;
				this.lazyTime = lazyTime;
				
				tipname = getQualifiedClassName(toolTipClass);
				ToolTipManager.registerToolTip(tipname,toolTipClass);
			}
			
			addEventListener(MouseEvent.ROLL_OVER,onToolTipShow);
			addEventListener(MouseEvent.ROLL_OUT, onToolTipHide);
		}
		
		protected function onToolTipShow(event:MouseEvent):void{
			if(_showToolTip)
				ToolTipManager.getInstance().show(_toolTip,lazyTime,0,0,tipname);
		}
		
		protected function onToolTipHide(evnt:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		/**
		 * 销毁对象
		 */ 
		public function dispose():void{
			while(listeners.length > 0){
				removeEventListener(listeners[0].type,listeners[0].listener);
			}
			if(bgSkin){
				_bgSkin.owner = null;
				bgSkin.dispose();
			}
			removeSelf();
		}
		
		protected function removeSelf():void{
			if(parent){
				parent.removeChild(this);
			}
		}
		
		/**
		 * 重新绘制界面的方法
		 */
		protected function updateDisplayList(w:Number, h:Number):void
		{
			_isUpdate=false;
			if (_bgAlphaChanged || _bgColorChanged)
			{
				if (bgAlpha == 0)
				{
					graphics.clear();
				}
				else
				{
					graphics.clear();
					if(w !=0 && h != 0){
						graphics.beginFill(bgColor, bgAlpha);
						graphics.drawRect(0, 0, w, h);
						graphics.endFill();
					}
				}
			}
			if (_sizeChanged)
			{
				if (_bgSkin != null)
				{
					graphics.clear();
					width == 0 ? width = _bgSkin.realWidth : "";
					height == 0 ? height = _bgSkin.realHeight : "";	
					_bgSkin.setSize(width,height);
				}
				else
				{
					graphics.clear();
					if(w !=0 && h != 0){
						graphics.beginFill(bgColor, bgAlpha);
						graphics.drawRect(0, 0, w, h);
						graphics.endFill();
					}
				}
				var evt:ResizeEvent=new ResizeEvent(ResizeEvent.RESIZE);
				dispatchEvent(evt);				
			}
			if (_bgSkinChanged && _bgSkin != null)
			{
				width == 0 ? width = _bgSkin.realWidth : "";
				height == 0 ? height = _bgSkin.realHeight : "";
				_bgSkin.owner = this;
				super.addChildAt(_bgSkin, 0);
				_bgSkin.setSize(width,height);
				_bgSkin.doubleClickEnabled = doubleClickEnabled;
			}
			_bgSkinChanged=false;
			_bgAlphaChanged=false;
			_bgColorChanged=false;
			_sizeChanged=false;
		}
		
		public function validateNow():void{
			if(_isUpdate){
				removeEventListener(Event.ENTER_FRAME,onRender);
				update();
			}
		}
		
		override public function set doubleClickEnabled(enabled:Boolean):void{
			super.doubleClickEnabled = enabled;
			if(_bgSkin){
				_bgSkin.doubleClickEnabled = enabled;
			}
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false) : void{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
			listeners.push({type:type,listener:listener});
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false) : void{
			super.removeEventListener(type,listener,useCapture);
			var delEvent:Object;
			for each(var event:Object in listeners){
				if(event.type == type && event.listener == listener){
					delEvent = event;
					break;
				}
			}
			if(delEvent){
				listeners.splice(listeners.indexOf(delEvent),1);
			}
		}
	}
}