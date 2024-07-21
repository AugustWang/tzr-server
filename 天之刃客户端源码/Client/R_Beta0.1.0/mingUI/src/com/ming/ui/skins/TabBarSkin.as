package com.ming.ui.skins
{
	import com.ming.ui.controls.Button;
	
	import flash.text.TextFormat;

	public class TabBarSkin
	{
		public var firstBtnFunc:Function;
		public var tabBtnFunc:Function;
		public var lastBtnFunc:Function;
		public var soundFunc:Function;
		
		public function firstButtonSkin(btn:Button):void{
			if(firstBtnFunc != null){
				btn.bgSkin = firstBtnFunc();
			}else{
				tabButtonSkin(btn);
			}
		}
		
		public function tabButtonSkin(btn:Button):void{
			if(tabBtnFunc != null ){
				btn.bgSkin = tabBtnFunc();
			}
		}
		
		public function lastButtonSkin(btn:Button):void{
			if(lastBtnFunc != null){
				btn.bgSkin = lastBtnFunc();
			}else{
				tabButtonSkin(btn);
			}
		}
	}
}