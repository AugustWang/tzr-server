package com.ming.ui.skins
{
	import com.ming.ui.controls.Button;

	public class AccordionSkin
	{
		public var branchFunc:Function;
		public var leafFunc:Function;
		public function AccordionSkin()
		{
		}
		
		public function branchSkin(btn:Button):void{
			if(branchFunc != null ){
				btn.bgSkin = branchFunc();
			}
		}
		
		public function leafSkin(btn:Button):void{
			if(leafFunc != null){
				btn.bgSkin = leafFunc();
			}
		}
	}
}