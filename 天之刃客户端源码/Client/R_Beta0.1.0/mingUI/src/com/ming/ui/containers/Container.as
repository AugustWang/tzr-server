package com.ming.ui.containers
{
	import com.ming.events.ResizeEvent;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * (带 mask)容器基类, 不带滚动条 ，自适应大小  
	 */
	public class Container extends UIComponent
	{
		public var rawChildren:Sprite; //提供对容器边框，内容进行绘制
		public var contentPane:Sprite; //内容面板
		
		private var _mask:Shape;  //内容mask
		private var _maskRawChildren:Shape; //rawChildren的mask
		
		protected var _contentChanaged:Boolean = false;
		
		private var _explicitWidth:Number = NaN; //精确宽度 ,用来确定外部是否设置了宽度，如果没有将进行自适应
		protected var _explicitWSet:Boolean = false;
		private var _explicitHeight:Number = NaN; //精确高度
		protected var _explicitHSet:Boolean = false;
		
		public function Container()
		{
			init();
		}

		private function init():void{
			_mask = new Shape();
			_mask.x = 0;
			_mask.y = 0;
			super.addChild(_mask);
			
			_maskRawChildren = new Shape;
			super.addChild(_maskRawChildren);
			
			rawChildren = new Sprite();	
			rawChildren.mask = _maskRawChildren;
			super.addChild(rawChildren);
			
			contentPane = new Sprite();
			contentPane.x = 0;
			contentPane.y = 0;
			contentPane.mask = _mask;
			super.addChild(contentPane);
			
			addEventListener(ResizeEvent.RESIZE,onReisze);
		}
		
		override public function set width(value:Number):void{
			if(_explicitWidth != value){
				_explicitWidth = value;
				_explicitWSet = true;
				super.width = _explicitWidth;
			}
		} 
		
		override public function set height(value:Number):void{
			if(_explicitHeight != value){
				_explicitHeight = value;
				_explicitHSet = true;
				super.height = _explicitHeight;
			}
		} 		
		/**
		 * 删除所有子对象
		 */
		public function removeAllChildren():void
		{
			while (numChildren > 0)
			{
				removeChildAt(0);
			}		
		}
		/**
		 * 子对象数量 
		 */
		override public function get numChildren():int
		{
			return contentPane.numChildren;
		}
		/**
		 * 增加对象 
		 */
		public override function addChild(child:DisplayObject) : DisplayObject
		{
			contentPane.addChild(child);
			_contentChanaged = true;
			invalidateDisplayList();
			return child;
		} 
		/**
		 * 增加对象在某个索引处 
		 */
		public override function addChildAt(child:DisplayObject, index:int) : DisplayObject
		{
			contentPane.addChildAt(child,index);
			return child;
		}
		/**
		 * 删除对象
		 */
		public override function removeChild(child:DisplayObject) : DisplayObject
		{
			if(child.parent == contentPane){
				contentPane.removeChild(child);
				_contentChanaged = true;
				invalidateDisplayList();
			}else{
				removeSuperChild(child);
			}
			return child;
		}
		/**
		 * 删除索引处的对象 
		 */
		public override function removeChildAt(index:int) : DisplayObject
		{
			var v:DisplayObject = contentPane.removeChildAt(index);
			_contentChanaged = true;
			invalidateDisplayList();			
			return v;
		}
		/**
		 * 获得索引处的对象
		 */
		public override function getChildAt(index:int):DisplayObject
		{
			return contentPane.getChildAt(index);
		}
		/**
		 * 根据对象名获得对象
		 */
		public override function getChildByName(name:String):DisplayObject
		{
			return contentPane.getChildByName(name);
		}
		/**
		 * 获得对象的索引
		 * 
		 */
		public override function getChildIndex(child:DisplayObject):int
		{
			if(child.parent == this){
				return super.getChildIndex(child);
			}
			return contentPane.getChildIndex(child);
		}
		/**
		 * 添加到对象本身和contentPane的级别一样
		 */ 
		public function addChildToSuper(child:DisplayObject):void{
			super.addChild(child);
		}
		public function removeSuperChild(child:DisplayObject):void{
			super.removeChild(child);
		}
		/**
		 * 覆盖鼠标禁用，同时禁用contentPanel的
		 */ 
		override public function set mouseEnabled(enabled:Boolean) : void{
			this.contentPane.mouseEnabled = enabled;
			super.mouseEnabled = enabled;
		}
		
		/**
		 * 获取容器所有子对象
		 */ 
		public function getAllChildren():Array{
			var children:Array = [];
			for(var i:int=0;i<numChildren;i++){
				children.push(contentPane.getChildAt(i));
			}
			return children;
		}
		
		protected function onReisze(event:ResizeEvent):void{
			_mask.graphics.clear();
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRect(0, 0, width, height);	
			
			_maskRawChildren.graphics.clear();
			_maskRawChildren.graphics.beginFill(0);
			_maskRawChildren.graphics.drawRect(0, 0, width, height);	
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void{
			if(_contentChanaged){
				_contentChanaged = false;
				if(!_explicitHSet || !_explicitWSet){
					var contentSize:Array = getContentSize();
					if(!_explicitWSet){
						super.width = contentSize[0];
					}
					if(!_explicitHSet){
						super.height = contentSize[1];
					}
				}
			}
			super.updateDisplayList(width,height);
		}
		
		/**
		 * 获取内容的自适应宽高
		 */ 
		protected function getContentSize():Array{
			var size:int = numChildren;
			var w:Number = 0,h:Number = 0;
			for(var i:int = 0 ; i < size ; i++){
				var child:DisplayObject = getChildAt(i);
				w = Math.max(w,child.x + child.width);
				h = Math.max(h,child.y + child.height);
			}
			return [w,h];			
		}
		/**
		 * 手动更新自适应大小
		 */ 
		public function updateSize():void{
			_contentChanaged = true;
			invalidateDisplayList();
		}
	}
}