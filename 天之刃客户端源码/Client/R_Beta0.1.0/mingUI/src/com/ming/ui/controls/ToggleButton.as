package com.ming.ui.controls
{
    import com.ming.ui.controls.Button;
    import com.ming.ui.skins.ButtonSkin;
    import com.ming.ui.skins.Skin;
    import com.ming.ui.style.StyleManager;
    
    import flash.events.MouseEvent;

    public class ToggleButton extends Button
    {
		private var _selected:Boolean = false;
		private var _toggle:Boolean = false;
		
        public function ToggleButton()
        {
			var selectSkin:Skin = StyleManager.selectedSkin;
			if(selectSkin){
				bgSkin = selectSkin;
			}
        }
		
		public function set toggle(value:Boolean):void{
			if(_toggle != value){
				this._toggle = value;
				if(_toggle){
					addEventListener(MouseEvent.CLICK,onToggleHandler);
				}else{
					removeEventListener(MouseEvent.CLICK,onToggleHandler);
				}
			}
		}
		
		public function get toggle():Boolean{
			return this._toggle;
		}
		
        public function set selected(value:Boolean) : void{
            _selected = value;
			updateStateSkin();
		}
		public function get selected() : Boolean
		{
			return _selected;
		}        

		private function onToggleHandler(event:MouseEvent):void{
			selected = !selected;
		}
		
		private function updateStateSkin():void{
			var skin:ButtonSkin = bgSkin as ButtonSkin;
			if(skin){
				skin.selected = selected
			}
		}
    }
}
