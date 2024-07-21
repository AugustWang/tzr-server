package com.ming.ui.containers
{
	import com.ming.ui.layout.LayoutUtil;
	
	public class HBox extends Container
	{
		private var _hPadding:int = 0; //水平间距
		private var _hPaddingChanged:Boolean = false;
		public function HBox()
		{
			super();
		}
		
		public function set hPadding(value:int):void{
			if(_hPadding != value){
				this._hPadding = value;
				_hPaddingChanged = true;
				invalidateDisplayList();
			}
		}
		public function get hPadding():int{
			return this._hPadding
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			if(_contentChanaged || _hPaddingChanged){
				_hPaddingChanged = false;
				layoutChildren();
			}
			super.updateDisplayList(w,h);
		}	
		
		private function layoutChildren():void{
			LayoutUtil.layoutHorizontal(contentPane,hPadding);		
		}	
	}
}