package com.ming.ui.controls
{
	import com.ming.ui.skins.CheckBoxSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class RadioButton extends CheckBox
	{
		public static var SELECTED:String = "selectedevent";
		
		public function RadioButton(label:String)
		{
			super();
			
			init();
			this.iconWidth = 12;
			this.iconHeight = 12;
			this.text = label;
		}
		
		private function init():void
		{
			this.height = 17;
			var radioButtonSkin:CheckBoxSkin = StyleManager.radioButtonSkin;
			if(radioButtonSkin){
				iconSkin = radioButtonSkin;
				var unSelectedSkin:Skin = iconSkin.unSelectedSkin;
				if(unSelectedSkin){
					icon.bgSkin = unSelectedSkin;
				}
			}
		}
		
		override protected function click(evt:MouseEvent):void
		{
			if(selected == true)
				return;
			selected = true;
			
			this.dispatchEvent(new Event(SELECTED));
		}
	}
}