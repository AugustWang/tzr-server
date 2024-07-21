package modules.deal.views.stallViews
{
	import com.ming.events.PaginationEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class PageBar extends UIComponent
	{
		private var _preTxt:TextField;
		private var _nextTxt:TextField;
		
		private var _numTxt:TextField;
		
		private var _totalTxt:TextField;
		
		private var _tf:TextFormat; 
		
		////////////////////////
		private var _totalPage:int;
		private var _currentPage:int;
		private var _pageArr:Array = []; // [<a href='event:page,1'><font color='#ff0000'>1<font></a>,2,3,];
		private var _selected:int;
		private var _numspace:Number = 18;
		
		private var begingPage:int = 1;
		
		public function PageBar()
		{
			super();
			this.width = 532;
			this.height = 37;
			
			init();
		}
		
		private function init():void
		{
			_tf = new TextFormat("Tahoma",14,0xffffff,null,null,null,null,null,"center");
			_preTxt = new TextField();
			_preTxt.x = 0;
			_preTxt.y = 0;
			_preTxt.width =65;
			_preTxt.height = 22;
			_preTxt.defaultTextFormat = _tf;
			addChild(_preTxt);
//			_preTxt = ComponentUtil.createTextField("",0,0,_tf,65,22,this);
			
			_preTxt.htmlText = "<font><a href='event:prePage'>上一页</a></font>";
			_preTxt.selectable = false;
			
//			_preTxt.addEventListener(TextEvent.LINK, onPrePage);
			
			
			_numTxt = new TextField();
			_numTxt.x = 70;
			_numTxt.y = 0;
			_numTxt.width = 62;
			_numTxt.height = 22;
			_numTxt.defaultTextFormat = _tf;
			addChild(_numTxt);
//			_numTxt = ComponentUtil.createTextField("",70,0,_tf,62,22,this);
			
			
			_nextTxt = new TextField();
			_nextTxt.x = 200;
			_nextTxt.y = 0;
			_nextTxt.width = 65;
			_nextTxt.height = 22;
			_nextTxt.defaultTextFormat = _tf;
			addChild(_nextTxt);
			
//			_nextTxt = ComponentUtil.createTextField("",200,0,_tf,65,22,this);
			
			_nextTxt.htmlText = "<font><a href='event:nextPage'>下一页</a></font>";
			_nextTxt.selectable = false;
			_nextTxt.addEventListener(TextEvent.LINK, onNextPage);
			
			
			_totalTxt = ComponentUtil.createTextField("共9页",266,0,_tf,65,22,this);
			
			
			var  css:StyleSheet = new StyleSheet();
			
			css.parseCSS("a {color: #ffffff;}a:hover { color: #ff0000;} ");//a:active {color: #ffff00;}
			_numTxt.styleSheet = css;
			_numTxt.addEventListener(TextEvent.LINK, onNumPage);
			
			
			_currentPage = 1;
		}
		
		private function onPrePage(evt:TextEvent):void
		{
			if(_currentPage == 1 )
			{
				return;
				
			}
			else{
				_pageArr[_currentPage-1] = "<a href='event:page," +
					String(_currentPage) + "'><font size='14'>[" +
					String(_currentPage) +
					"]</font></a>";
				
				_currentPage--;
				if(_currentPage == 1)
				{
					if(_preTxt.hasEventListener(TextEvent.LINK))
					{
						_preTxt.removeEventListener(TextEvent.LINK, onPrePage);
					}
				}
			}
			
			if(_currentPage< totalPage)
			{
				if(!_nextTxt.hasEventListener(TextEvent.LINK))
				{
					_nextTxt.addEventListener(TextEvent.LINK, onNextPage);
				}
				
			}
			_pageArr[_currentPage-1] = "<a href='event:page," +
				String(_currentPage) +
				"'><font color='#ff0000' size='14'>[" +
				String(_currentPage) +
				"]</font></a>";
			
			showNumText();
			
			var pageEvent:PaginationEvent = new PaginationEvent(PaginationEvent.PAGINATION,false,true);
			pageEvent.pageNum = _currentPage;
			
			dispatchEvent(pageEvent);
			//  trace("....PaginationEvent....");
			
		}
		private function onNextPage(evt:TextEvent):void
		{
			if(_currentPage == totalPage )
			{
				return;
				
			}
			else{
				_pageArr[_currentPage-1] = "<a href='event:page," +
					String(_currentPage) + "'><font size='14'>[" +
					String(_currentPage) +
					"]</font></a>";
				
				_currentPage++;
				if(_currentPage == totalPage)
				{
					if(_nextTxt.hasEventListener(TextEvent.LINK))
					{
						_nextTxt.removeEventListener(TextEvent.LINK, onNextPage);
					}
				}
			}
			
			if(_currentPage> 1)
			{
				if(!_preTxt.hasEventListener(TextEvent.LINK))
				{
					_preTxt.addEventListener(TextEvent.LINK, onPrePage);
				}
				
			}
			
			_pageArr[_currentPage-1] = "<a href='event:page," +
				String(_currentPage) +
				"'><font color='#ff0000' size='14'>[" +
				String(_currentPage) +
				"]</font></a>";
			
			showNumText();
			
			var pageEvent:PaginationEvent = new PaginationEvent(PaginationEvent.PAGINATION,false,true);
			pageEvent.pageNum = _currentPage;
			
			dispatchEvent(pageEvent);
			//  trace("....PaginationEvent....");
		}
		private function onNumPage(evt:TextEvent):void
		{
			var arr:Array = evt.text.split(",");
			var page:int = int(arr[1]);
			
			if(_currentPage == page)
			{
				return;
			}
			_pageArr[_currentPage-1] = "<a href='event:page," +
				String(_currentPage) + "'><font size='14'>[" +
				String(_currentPage) +
				"]</font></a>";
			
				_currentPage = page;
			
			
			if(_currentPage == totalPage)
			{
				if(_nextTxt.hasEventListener(TextEvent.LINK))
				{
					_nextTxt.removeEventListener(TextEvent.LINK, onNextPage);
				}
			}
			
			if(_currentPage> 1)
			{
				if(!_preTxt.hasEventListener(TextEvent.LINK))
				{
					_preTxt.addEventListener(TextEvent.LINK, onPrePage);
				}
				
			}
			
			////////////
			
			if(_currentPage == 1)
			{
				if(_preTxt.hasEventListener(TextEvent.LINK))
				{
					_preTxt.removeEventListener(TextEvent.LINK, onPrePage);
				}
			}
			
			if(_currentPage< totalPage)
			{
				if(!_nextTxt.hasEventListener(TextEvent.LINK))
				{
					_nextTxt.addEventListener(TextEvent.LINK, onNextPage);
				}
				
			}
			
			_pageArr[_currentPage-1] = "<a href='event:page," +
				String(_currentPage) +
				"'><font color='#ff0000' size='14'>[" +
				String(_currentPage) +
				"]</font></a>";
		
			
			showNumText();
		}
		
		
		private function setBegingPage(value:int):void
		{
			begingPage = value;
		}
		
		
		public function set totalPage(value:int):void
		{
			if(value<1)
			{
				
				return;
			}
			_totalPage = value;
			_totalTxt.text = "共" +String(value) +"页";
			setNumTxt();
		}
		
		public function get totalPage():int
		{
			return _totalPage;
		}
		
		
//		public function set currentPage(value:int):void
//		{
//			_currentPage = value;
//		}
		
		public function get currentPage():int
		{
			return _currentPage;
		}
		
		/*public function set selected(value:int):void
		{
			_selected = value;
			
		}
		public function get selected():int
		{
			return _selected;
		}*/
		
		
		private function setNumTxt():void
		{
			if(totalPage >= 10)
			{
				_preTxt.x = 77;
				_numTxt.x = 77 + _preTxt.width + _numspace;
				
				_nextTxt.x = _numTxt.x + _numspace * 11;
				_totalTxt.x = _nextTxt.x + _nextTxt.width + _numspace;
				
				
			}else{
				
				_preTxt.x = (this.width - 3 * _numspace -  totalPage * _numspace) * 0.5 ;
				_numTxt.x = 77 + _preTxt.width + _numspace * totalPage/2;
				
				_nextTxt.x = _numTxt.x + _numspace * totalPage;
				_totalTxt.x = _nextTxt.x + _nextTxt.width + _numspace;
			}
			
			setPageData();
		}
		
		private function setPageData():void
		{
			_pageArr[0]= "<a href='event:page,1'><font color='#ff0000' size='14'>[1]</font></a>";
			
			for(var i:int= 1;i< totalPage; i++)
			{
				_pageArr[i] = "<a href='event:page," +
					String(i+1) + "'><font size='14'>[" +
					String(i+1) +
						"]</font></a>";
				
			}
			
			showNumText();
		}
		
		private function showNumText():void
		{
			_numTxt.htmlText = "";
			var i:int;
			if(totalPage >10)
			{
				for( i = begingPage-1 ; i<10; i++)
				{
					_numTxt.htmlText += _pageArr[i];
				}
			}
			else {
				for(i = begingPage-1 ; i<totalPage; i++)
				{
					_numTxt.htmlText += _pageArr[i];
				}
				
			}
			
			_numTxt.width = _numTxt.textWidth + 12;
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
		}
		
		
	}
}