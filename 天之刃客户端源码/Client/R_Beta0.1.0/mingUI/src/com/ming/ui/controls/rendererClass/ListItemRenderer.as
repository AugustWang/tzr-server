package com.ming.ui.controls.rendererClass
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class ListItemRenderer extends UIComponent
	{
		private var text:TextField;
		public var labelField:String;
		public function ListItemRenderer():void{
			mouseChildren = false;
			useHandCursor = true;
			text = new TextField();
			text.height = 25;
			text.selectable = false;
			var tf:TextFormat = StyleManager.textFormat;
			if(tf){
				text.defaultTextFormat = tf;
			}
			var skin:Skin = StyleManager.listItemSkin;
			if(skin){
				bgSkin = skin;
			}
			addChild(text);
			addEventListener(Event.ADDED,onAdded);
		}
		
		private function onAdded(event:Event):void{
			width = parent.width;
			height = 25;
		}
		
		public override function set data(value:Object):void{
			super.data = value;
			if(labelField == null){
				text.htmlText = data.toString();
			}else{
				if( data[labelField])text.htmlText = data[labelField];
			}
			text.width = text.textWidth + 5;
		}
	}
}