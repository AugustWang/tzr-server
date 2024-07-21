package com.ming.ui.skins
{
	import com.ming.ui.controls.core.UIComponent;
	
	public class SelectItemSkin extends UIComponent
	{
		public function SelectItemSkin()
		{
			super();
			bgAlpha = 0;
			mouseEnabled = mouseChildren = false;			
		}
		
		override public function set bgSkin(skin:Skin):void{
			super.bgSkin = skin;
			validateNow();
		}
	}
}