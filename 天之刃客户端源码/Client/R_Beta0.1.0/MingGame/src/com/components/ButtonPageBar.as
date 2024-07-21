package com.components
{
	import com.ming.events.PageEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ButtonPageBar extends Sprite
	{
		private var preButton:Button;
		private var pageText:TextInput;
		private var nextButton:Button;
		private var gotoButton:Button;
		private var pageInput:TextInput;
		private var endText:TextField;
		
		private var tf:TextFormat;
		public function ButtonPageBar()
		{
			super();
			initUI();
		}
		
		private function initUI():void{
			tf = Style.themeTextFormat;
			tf.align = "center";
			preButton = ComponentUtil.createButton("上一页",0,0,65,25,this);
			pageText = new TextInput();
			pageText.mouseEnabled = pageText.mouseChildren = false;
			pageText.textField.defaultTextFormat = tf;
			pageText.textField.textColor = 0xffffff;
			pageText.text = "1 / 1";
			pageText.width = 50;
			pageText.height = 25;
			pageText.x = preButton.x + preButton.width+5;
			pageText.y = preButton.height - pageText.height >> 1;
			addChild(pageText);
			nextButton = ComponentUtil.createButton("下一页",pageText.x+pageText.width+5,0,65,25,this);
			gotoButton = ComponentUtil.createButton("跳转至",nextButton.x+nextButton.width+10,0,65,25,this);
			pageInput = ComponentUtil.createTextInput(gotoButton.x+gotoButton.width+5,pageText.y,45,25,this);
			pageInput.restrict = "[0-9]";
			pageInput.maxChars = 3;
			endText = ComponentUtil.createTextField("页",pageInput.x+pageInput.width+3,pageText.y,tf,18,18,this);
			
			preButton.addEventListener(MouseEvent.CLICK,prePageHandler);
			nextButton.addEventListener(MouseEvent.CLICK,nextPageHandler);
			gotoButton.addEventListener(MouseEvent.CLICK,gotoPageHandler);
		}
		
		public function set hideGotoBar(value:Boolean):void{
			if(value){
				gotoButton.visible = false;
				pageInput.visible = false;
				endText.visible = false;
			}else{
				gotoButton.visible = true;
				pageInput.visible = true;
				endText.visible = true;
			}
		}
		
		private var _currentPage:int=1;
		public function set currentPage(value:int):void{
			if(value >=0 && value <= totalPageCount){
				_currentPage = value;
				dispatchPageEvent();
			}
		}
		
		public function get currentPage():int
		{
			return _currentPage;
		}
		
		private var _totalPageCount:int=1;
		public function set totalPageCount(value:int):void{
			_totalPageCount = value;	
			_totalPageCount = Math.max(1,_totalPageCount);
			_currentPage = Math.min(_totalPageCount,_currentPage);
			changePageText();
		}
		
		public function get totalPageCount():int{
			return _totalPageCount;
		}
		
		private function prePageHandler(event:MouseEvent):void{
			_currentPage--;
			if(_currentPage < 1){
				_currentPage = totalPageCount;
			}
			dispatchPageEvent();
		}
		
		private function nextPageHandler(event:MouseEvent):void{
			_currentPage++;
			if(_currentPage > totalPageCount){
				_currentPage = 1;
			}
			dispatchPageEvent();
		}
		
		private function gotoPageHandler(event:MouseEvent):void{
			var page:int = int(pageInput.text);
			page = Math.min(totalPageCount,page);
			page = Math.max(1,page);
			_currentPage = page;
			dispatchPageEvent();
		}
		
		private function changePageText():void{
			pageText.text = _currentPage+" / "+totalPageCount;
			pageInput.text = _currentPage.toString();
		}
		
		private function dispatchPageEvent():void{
			if(_currentPage <=0 || _currentPage>totalPageCount)return;
			var evt:PageEvent = new PageEvent(PageEvent.CHANGED);
			evt.pageNumber = _currentPage;
			dispatchEvent(evt);
			changePageText();
		}
	}
}