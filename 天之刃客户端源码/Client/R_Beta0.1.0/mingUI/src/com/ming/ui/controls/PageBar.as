package com.ming.ui.controls
{
	import com.ming.events.PageEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextField;

	/**
	 * 分页组件
	 */ 
	public class PageBar extends Sprite
	{
		public var size:int = 5;
		private var currentPage:int = 1;
		private var _totalPageCount:int;
		public function PageBar()
		{
			init();
		}
		
		private var preText:TextField;
		private var endText:TextField;
		private var text:TextField;
		private function init():void{
			var filters:Array = [new GlowFilter(0x000000,1,4,4)];
			preText = new TextField();
			preText.filters = filters;
			preText.selectable = false;
			preText.textColor = 0xa0ecef;
			preText.addEventListener(TextEvent.LINK,onTextLink);
			addChild(preText);
			
			text = new TextField();
			text.filters = filters;
			text.selectable = false;
			text.textColor = 0xa0ecef;
			text.addEventListener(TextEvent.LINK,onTextLink);
			addChild(text);
			
			css = "a {color: #a0ecef;} a:hover {color: #ffcc00;}";
			
			endText = new TextField();
			endText.filters = filters;
			endText.selectable = false;
			endText.textColor = 0xa0ecef;
			endText.addEventListener(TextEvent.LINK,onTextLink);
			addChild(endText);
			height = 25;
			
		}
		
		public function set totalPageCount(value:int):void{
			if(_totalPageCount != value){
				_totalPageCount = value;
				wrapperText();
			}
		}
		
		public function get totalPageCount():int{
			return _totalPageCount;
		}
		
		private var _h:Number = 25;
		override public function set height(value:Number):void{
			_h = value;
			updateSize();
		}
		
		private var _css:String;
		public function set css(value:String):void{
			this._css = value;
			var style:StyleSheet = new StyleSheet();
			style.parseCSS(css);
			text.styleSheet = style;
		}
		
		public function get css():String{
			return _css;
		}
		
		private function updateSize():void{
			preText.height = endText.height = text.height = _h;
		}
		
		private function updatePosition():void{
			text.x = preText.width;
			endText.x = text.x + text.width;
		}
		
		private function wrapperText():void{
			var str:String;
			if(currentPage > 1){
				str = "<a href='event:1'>首页</a> <a href='event:"+(currentPage-1)+"'>上一页</a>";
			}else{
				str = "首页 上一页";
			}
			preText.htmlText = str;
			preText.width = preText.textWidth + 10;
			str = "";
			var addMax:int = size/2;
			var min:int = Math.max(1,currentPage - addMax);
			var max:int = (min+size-1);
			if(totalPageCount < max){
				max = totalPageCount;
				min = Math.max(1,max - size + 1);
			}
			for(var i:int=min;i<=max;i++){
				if(i == currentPage){
					str += " <font color='#ffcc00'>[ "+i+" ]</font> ";
				}else{
					str += " <a href='event:"+i+"'>[ "+i+" ]</a> ";
				}
			}
			text.htmlText = str;
			text.width = text.textWidth + 10;
			if(currentPage < totalPageCount){
				str = "<a href='event:"+(currentPage+1)+"'>下一页</a> <a href='event:"+totalPageCount+"'>末页</a> 共"+totalPageCount+"页";
			}else{
				str = "下一页 末页 共"+totalPageCount+"页";
			}
			endText.htmlText = str;
			endText.width = endText.textWidth + 10;
			updatePosition();
		}
		
		private function onTextLink(event:TextEvent):void{
			var page:int = int(event.text);
			if(page <=0 || page>totalPageCount)return;
			var evt:PageEvent = new PageEvent(PageEvent.CHANGED);
			evt.pageNumber = page;
			dispatchEvent(evt);
			currentPage = page;
			wrapperText();
		}
	}
}