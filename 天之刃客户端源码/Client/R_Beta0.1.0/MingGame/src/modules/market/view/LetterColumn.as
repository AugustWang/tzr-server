package modules.market.view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import modules.market.MarketModule;
	
	public class LetterColumn extends Sprite
	{
		private var tf:TextFormat;
		private var firstPageTxt:TextField;//首页
		private var lastPageTxt:TextField;//末页
		private var preTxt:TextField;//上一页
		private var nextTxt:TextField;//下一页
		private var totalTxt:TextField;//总页数
		private static var ALLOW_MAX_PAGE:int = 5;//允许显示最大的页数
		public function LetterColumn(){
			tf = new TextFormat();
			tf.align = TextFormatAlign.CENTER;
			tf.underline = true;
			init();
		}
		
		private function init():void{
			firstPageTxt = createTxt(30,25,"<font color='#ffcc00' size='12'><a href='event:firstPage'>首页</a></font>","firstPageTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			firstPageTxt.mouseEnabled = true;
			
			preTxt = createTxt(42,25,"<font color='#ffcc00' size='12'><a href='event:pre'>上一页</a></font>","preTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			preTxt.mouseEnabled = true;
			
			//下一页
			nextTxt = createTxt(42,25,"<font color='#ffcc00' size='12'><a href='event:next'>下一页</a></font>","nextTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			nextTxt.mouseEnabled = true;
			
			lastPageTxt = createTxt(30,25,"<font color='#ffcc00' size='12'><a href='event:lastPage'>末页</a></font>","lastPageTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			lastPageTxt.mouseEnabled = true;
			
			//显示总页数
			totalTxt = new TextField();
			totalTxt.mouseEnabled = false;
			this.addChild(totalTxt);
		}
		
		private function onRollOverHandler(evt:MouseEvent):void{
			switch(evt.currentTarget.name.toString()){
				case "firstPageTxt":
					firstPageTxt.textColor = 0x00ff00;
					break;
				case "preTxt":
					preTxt.textColor = 0x00ff00;
					break;
				case "nextTxt":
					nextTxt.textColor = 0x00ff00;
					break;
				case "lastPageTxt":
					lastPageTxt.textColor = 0x00ff00;
					break;
			}
		}
		
		private function onRollOutHandler(evt:MouseEvent):void{
			switch(evt.currentTarget.name.toString()){
				case "firstPageTxt":
					firstPageTxt.textColor = 0xffcc00;
					break;
				case "preTxt":
					preTxt.textColor = 0xffcc00;
					break;
				case "nextTxt":
					nextTxt.textColor = 0xffcc00;
					break;
				case "lastPageTxt":
					lastPageTxt.textColor = 0xffcc00;
					break;
			}
		}
		
		/**
		 *创建业面的文本 
		 * @param $width
		 * @param $height
		 * @return 
		 * 
		 */		
		private function createTxt($width:int,$height:int,str:String,$name:String,func_link:Function,func_over:Function,func_out:Function):TextField{
			var txt:TextField = new TextField();
			this.addChild(txt);
			txt.selectable = false;
			txt.width = $width;
			txt.height = $height;
			txt.htmlText = str;
			txt.setTextFormat(tf);
			txt.name = $name;
			txt.addEventListener(TextEvent.LINK,func_link,false,0,true);
			txt.addEventListener(MouseEvent.ROLL_OVER,func_over,false,0,true);
			txt.addEventListener(MouseEvent.ROLL_OUT,func_out,false,0,true);
			
			//						txt.background = true;
			//						txt.backgroundColor = 0xff0000;
			return txt;
		}
		/**
		 * 
		 * @param page_arr:总的记录数
		 * @param posX
		 * @param posY
		 * @param row_num:每页显示几条记录
		 * 
		 */	
		public var currentPageNumber:int = -1;//当前的页数
		public var totalPage:int;//页数
		//计算内容需要分的页数
		public function createPageNum(currentPage:int,posX:int,posY:int,row_num:int,allPage:int):void{
			this.visible = true;
//			currentIndex = currentPage-1;
			firstPageTxt.mouseEnabled = true;
			lastPageTxt.mouseEnabled = true;
			preTxt.mouseEnabled = true;
			nextTxt.mouseEnabled = true;
			
			totalPage = allPage;
			
			if(allPage == 0){
				this.visible = false;
			}
			totalTxt.htmlText = "<font color='#ffcc00' size='12'>共 "+"<font color='#ffffff'>"+allPage+"</font> 页</font>";
			createUI(currentPage-1,allPage,posX,posY,row_num);
		}
		
		//创建页数的UI
		private var arr_diplayObject:Array = [];
		private function createUI(currentPage:int,allPage:int,xx:int,yy:int,rowNum:int):void{
			if(currentPage == 0){
				firstPageTxt.mouseEnabled = false;
				preTxt.mouseEnabled = false;	
			}
			firstPageTxt.x = xx;
			firstPageTxt.y = yy;
			preTxt.x = firstPageTxt.x + firstPageTxt.textWidth + 2;
			preTxt.y = yy;
			
			//删除对象
			if(arr_diplayObject && arr_diplayObject.length != 0){
				for each(var a:TextField in arr_diplayObject){
					if(this.contains(a)){
						if(a.hasEventListener(TextEvent.LINK) == true){
							a.removeEventListener(TextEvent.LINK,onLinkHandler,false);
						}
						this.removeChild(a);
					}
				}
			}
			arr_diplayObject.length = 0;
			
			if(allPage != 0){
				
				var column:Array = sort(currentPage,allPage);
				
				for(var i:int = 0;i<column.length;i++){
					var txt:TextField = new TextField();
					txt.selectable = false;
					this.addChild(txt);
					//arr_diplayObject内的数据不删除，
//					if(arr_diplayObject.length < column[i]+1)
//					{
//						arr_diplayObject.push(txt);
//					}
					arr_diplayObject.push(txt);
					txt.width = 23;
					txt.height = 20;
					if(currentPage % 10 == i){
						txt.htmlText = "<font color='#ffffff' size='12'><a href='event:"+(column[i]+1)+"'>"+(column[i]+1)+"</a></font>";
//						currentIndex = i;
						txt.x = firstPageTxt.x + firstPageTxt.textWidth + preTxt.textWidth + 2 + i*txt.width;
					}else{
						txt.htmlText = "<font color='#ffcc00' size='12'><a href='event:"+(column[i]+1)+"'>["+(column[i]+1)+"]</a></font>";
						txt.x = firstPageTxt.x + firstPageTxt.textWidth + preTxt.textWidth + 2 + i*txt.width;
						txt.addEventListener(TextEvent.LINK,onLinkHandler,false,0,true);
					}
					txt.y = yy;
					txt.setTextFormat(tf);
				}
				currentPageNumber = currentPage;
				
				//下一页
				if(currentIndex == allPage - 1 || allPage == 1){
					lastPageTxt.mouseEnabled = false;
					nextTxt.mouseEnabled = false;
				}
				nextTxt.x = arr_diplayObject[arr_diplayObject.length - 1].x + arr_diplayObject[arr_diplayObject.length - 1].width + 2;
				nextTxt.y = yy;
				
				lastPageTxt.x = nextTxt.textWidth + nextTxt.x + 2;
				lastPageTxt.y = yy;
				
				totalTxt.x = lastPageTxt.textWidth + lastPageTxt.x + 2;
				totalTxt.y = yy;
			}
		}
		
		private function sort(current:int,allPage:int):Array
		{
			if(allPage != 0)
			{
				if(current % 10 == 0)
				{
					var a:Array = new Array();	
					if(allPage-current < 10)
					{
						for(var i:int=0; i< allPage-current; i++)
						{
							a.push(current+i);
						}
					}
					else
					{
						for(var j:int=0; j< 10; j++)
						{
							a.push(current+j);
						}
					}
					return a;
				}
				else
				{
					var time:int = Math.floor( current / 10);
					var b:Array = sort(10*time,allPage);
					return b;
				}
			}
			return null;
		}
		
		/**
		 * 用来处理点击后的文本
		 * @param index
		 * @param str：old当前页,new刚点的页
		 * 
		 */		
		public function dealTxt(index:int,str:String = "old"):void{
			var str:String;
			if(str == "old"){
				str = "<font color='#ffcc00' size='12'><a href='event:"+(index+1)+"'>["+(index+1)+"]</a></font>";
			}else{
				str = "<font color='#ffffff' size='12'><a href='event:"+(index+1)+"'>"+(index+1)+"</a></font>";
			}
			
			if(index > arr_diplayObject.length)
			{
				index = arr_diplayObject.length - 1;
			}
			TextField(arr_diplayObject[index % 10]).htmlText = str;
			TextField(arr_diplayObject[index % 10]).setTextFormat(tf);
		}
		
		public var currentIndex:int = 0;
		private function onLinkHandler(evt:TextEvent):void{
			dealTxt(currentIndex);
			if(evt.text == "firstPage"){
				currentIndex = 0;
			}else if(evt.text == "lastPage"){
				currentIndex = totalPage -1;
			}else if(evt.text == "pre"){
				if(currentIndex > 0)
				{
					currentIndex--;
				}
			}else if(evt.text == "next"){
				if( currentIndex < totalPage -1)
				{
					currentIndex++;
				}
			}else{
				currentIndex = int(evt.text) - 1;
			}
			
			this.dispatchEvent(new Event("DATA_CHAGE"));
			
			dealLinkState(currentIndex);
		}
		
		public function dealLinkState(currentIndex:int):void{
			dealTxt(currentIndex,"new");
			currentPageNumber = currentIndex + 1;
			if(currentIndex == arr_diplayObject.length -1){
				lastPageTxt.mouseEnabled = false;
				nextTxt.mouseEnabled = false;
				preTxt.mouseEnabled = true;
				firstPageTxt.mouseEnabled = true;
			}else if(currentIndex == 0){
				firstPageTxt.mouseEnabled = false;
				preTxt.mouseEnabled = false;
				nextTxt.mouseEnabled = true;
				lastPageTxt.mouseEnabled = true;
			}else{
				firstPageTxt.mouseEnabled = true;
				lastPageTxt.mouseEnabled = true;
				preTxt.mouseEnabled = true;
				nextTxt.mouseEnabled = true;
			}
		}
	}
}