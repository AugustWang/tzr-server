package com.ming.ui.controls
{
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	public class TextArea extends Text
	{
		protected var _scrollbar:ScrollBar;
		public function TextArea()
		{

		}
		
		override protected function init() : void{
			super.init();
			var textAreaSkin:Skin = StyleManager.textAreaSkin;
			if(textAreaSkin){
				bgSkin = textAreaSkin;
			}
		}
		
		private function createScrollBar():void{
			if(_scrollbar == null){
				_scrollbar = new ScrollBar();
				_scrollbar.pageScrollSize = 1;
				_scrollbar.height = height;
				_scrollbar.x = width - _scrollbar.width;
				_scrollbar.direction = ScrollDirection.VERTICAL;
				_scrollbar.addEventListener(ScrollEvent.SCROLL, onScroll);
				textField.width = width - _scrollbar.width - 2*borderThickness;
				textField.addEventListener(Event.SCROLL,onTextScroll);
				addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				addChild(_scrollbar);
			}
		}
		
		private function removeScrollBar():void{
			if(_scrollbar){
				_scrollbar.dispose();
				_scrollbar = null;
				removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				textField.removeEventListener(Event.SCROLL,onTextScroll);
				textField.width = width - 2*borderThickness;
			}
		}
		
		protected function updateScrollbar():void{
			if(textField.maxScrollV > 1){
				createScrollBar();
				var visibleLines:int = textField.numLines - textField.maxScrollV + 1;
				_scrollbar.pageSize = visibleLines;
				_scrollbar.maxScrollPosition = textField.maxScrollV+1;
			}else{
				removeScrollBar();
			}
		}
		
		override protected function resizeTextField():void{
			super.resizeTextField();
			if(_scrollbar){
				textField.width = width - _scrollbar.width - 2*borderThickness;
			}else{
				textField.width = width -  2*borderThickness;
			}
		}
		
		protected function onScroll(event:ScrollEvent):void{
			if(textField.scrollV != event.position){
				textField.scrollV = event.position;
			}
		}
		
		protected override function onChange(event:Event):void{
			super.onChange(event);
			updateScrollbar();
			if(_scrollbar){
				_scrollbar.scrollPosition = 0;
			}
		}
		
		protected override function onTextInput(event:TextEvent):void{
			super.onTextInput(event);
			updateScrollbar();
			if(_scrollbar){
				_scrollbar.scrollPosition = _scrollbar.maxScrollPosition;
			}
		}
		
		protected function onTextScroll(event:Event):void{
			if(_scrollbar.scrollPosition != textField.scrollV){
				var position:int = textField.scrollV;
				if(position == 1){
					position=0;	
				}else if(position == textField.maxScrollV){
					position = _scrollbar.maxScrollPosition;
				}
				_scrollbar.setScrollPosition(position);
			}
		}
		
		protected function onMouseWheel(event:MouseEvent):void{
			_scrollbar.scrollPosition -= event.delta;
		}
		
		public function setMaxScroll():void{
			if(_scrollbar){
				_scrollbar.scrollPosition = _scrollbar.maxScrollPosition;
			}
		}
		
		override public function dispose():void{
			super.dispose();
			removeScrollBar();
		}
	}
}