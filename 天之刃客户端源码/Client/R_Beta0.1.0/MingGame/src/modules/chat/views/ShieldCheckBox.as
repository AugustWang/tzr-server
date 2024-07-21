package modules.chat.views
{
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.CheckBoxSkin;
	import com.ming.ui.skins.Skin;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ShieldCheckBox extends UIComponent
	{
		private var defaultWidth:int = 52;
		private var  defaultHeight:int = 20;
		
		private var icon:UIComponent;
		private var _text:TextField;
		
		private var tem:Number = 2;
		private var iconWidth:Number = 18;
		private var iconHeight:Number = 18;
		
		private  var iconSkin:CheckBoxSkin;
		
		private var sizeChange:Boolean = false;
		
		private var _selected:Boolean;
		
		public function ShieldCheckBox()
		{
			super();
			this.width = defaultWidth;
			this.height = defaultHeight;
			this.buttonMode = true;
			this.useHandCursor = true;
			icon = new UIComponent();
			iconSkin = Style.getShieldCheckBox();
			
			if(iconSkin){
				var unSelectedSkin:Skin = iconSkin.unSelectedSkin;
				if(unSelectedSkin){
					icon.bgSkin = unSelectedSkin;
				}
			}
			sizeChange = true;
			invalidateDisplayList();
			addChild(icon);
			this.addEventListener(MouseEvent.CLICK,click);
		}
		
		private function click(evt:MouseEvent):void
		{
			selected = !selected;
			
			if(selected)
				icon.bgSkin = iconSkin.selectedSkin;
			else
				icon.bgSkin = iconSkin.unSelectedSkin;
			
			ShieldChatChannel.clickThis = true;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(bool:Boolean):void
		{
			if(bool == _selected)
				return;
			
			_selected = bool;
			if(_selected)
				icon.bgSkin = iconSkin.selectedSkin;
			else
				icon.bgSkin = iconSkin.unSelectedSkin;
			icon.validateNow();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * 不分发事件的设置选中 
		 */		
		public function setSelected(bool:Boolean):void{
			if(bool == _selected)
				return;
			_selected = bool;
			if(_selected)
				icon.bgSkin = iconSkin.selectedSkin;
			else
				icon.bgSkin = iconSkin.unSelectedSkin;
			icon.validateNow();
		}
		
		public function set text(label:String):void
		{
			
			if(_text == null)
				createTextField();
			if(_text.text == label)
				return;
			
			_text.text = label;
			sizeChange = true;
			invalidateDisplayList();
		}
		
		public function get text():String
		{
			if(_text == null)
				return "";
			return _text.text;
		}
		public function set htmlText(label:String):void
		{
			if(_text == null)
				createTextField();
			
			if(_text.htmlText == label)
				return;
			_text.htmlText = label;
			sizeChange = true;
			invalidateDisplayList();
		}
		public function get htmlText():String
		{
			if(_text == null)
				return "";
			return _text.htmlText;
		}
		
		private var _tf:TextFormat;
		public function set textFormat(format:TextFormat):void
		{
			if(_text != null){
				_text.defaultTextFormat = format;
				_text.setTextFormat(format);
			}
			else
				_tf = format;
		}
		
		private function createTextField() : void
		{
			_text = new TextField();
			_text.mouseEnabled = false;
//			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.width = 30;
			_text.height = 18;
			_text.selectable = false;
			var tf:TextFormat = Style.textFormat;
			_text.defaultTextFormat = _tf == null ? tf : _tf;
			addChild(_text);
			sizeChange = true;
			invalidateDisplayList();
		}
		
		
		override public function set width(w:Number):void
		{
			if(super.width == w)
				return;
			sizeChange = true;
			super.width = w;
		}
		override public function set height(h:Number):void
		{
			if(super.height == h)
				return;
			
			sizeChange = true;
			super.height = h;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w,h);
			
//			checkEnable();
			checkSize();
		}
		
		private function checkSize():void
		{
			if(sizeChange)
			{
				icon.height = iconWidth;
				icon.width = iconHeight;
				
				if(_text == null)
				{
					icon.x = (this.width - icon.width) / 2;
					icon.y = (this.height - icon.height) / 2;
				}
				else
				{
					_text.x = tem;
					_text.y = (this.height - _text.textHeight -5) / 2;//(this.height - _text.textHeight - 5) / 2;
					
//					var left:Number = _iconLeft == 0 ? defaultIconLeft : _iconLeft;
					icon.x = _text.x + _text.textWidth + 3;
					icon.y = (this.height - icon.height) / 2;
					
//					this.width = icon.width + _text.textWidth + tem;
				}
			}
			
			sizeChange = false;
		}
	}
}