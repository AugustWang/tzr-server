package com.ming.ui.containers
{
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.DisplayObject;
	
	public class VBox extends Container
	{
		private var _vPadding:int = 0; //水平间距
		private var _vPaddingChanged:Boolean = false;
		public var topBottom:Number = 0;
		public var leftRight:Number = 0;
		public function VBox()
		{
			super()
		}
		
		public function set vPadding(value:int):void{
			if(_vPadding != value){
				this._vPadding = value;
				_vPaddingChanged = true;
				invalidateDisplayList();
			}
		}
		public function get vPadding():int{
			return this._vPadding
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			if(_contentChanaged || _vPaddingChanged){
				_vPaddingChanged = false;
				layoutChildren();
			}
			super.updateDisplayList(w,h);
		}	
				
		private function layoutChildren():void{
			LayoutUtil.layoutVectical(contentPane,vPadding,topBottom);
			for(var i:int=0;i<contentPane.numChildren;i++){
				var child:DisplayObject = contentPane.getChildAt(i);
				child.x = leftRight;
			}
		}	
		
		/**
		 * 获取内容的自适应宽高
		 */ 
		override protected function getContentSize():Array{
			var size:int = numChildren;
			var w:Number = 0,h:Number = 0;
			for(var i:int = 0 ; i < size ; i++){
				var child:DisplayObject = getChildAt(i);
				w = Math.max(w,child.x + child.width);
				h = Math.max(h,child.y + child.height);
			}
			return [w+leftRight,h+topBottom];			
		}
	}
}