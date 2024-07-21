package modules.letter.view
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class LetterPage extends Sprite
	{
		private var tf:TextFormat;
		private var firstPageTxt:TextField;//首页
		private var lastPageTxt:TextField;//末页
		private var preTxt:TextField;//上一页
		private var nextTxt:TextField;//下一页
		private var totalTxt:TextField;//总页数
		public static var content_arr:Array = [];
		private static var ALLOW_MAX_PAGE:int = 3;//允许显示最大的页数
		public function LetterPage(){
			tf = new TextFormat();
			tf.align = TextFormatAlign.CENTER;
			tf.underline = true;
			init();
		}
		
		private function init():void{
			firstPageTxt = createTxt(30,25,"<font color='#ffffff' size='12'><a href='event:firstPage'>首页</a></font>","firstPageTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			firstPageTxt.mouseEnabled = true;
			
			preTxt = createTxt(42,25,"<font color='#ffffff' size='12'><a href='event:pre'>上一页</a></font>","preTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			preTxt.mouseEnabled = true;
			
			//下一页
			nextTxt = createTxt(42,25,"<font color='#ffffff' size='12'><a href='event:next'>下一页</a></font>","nextTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
			nextTxt.mouseEnabled = true;
			
			lastPageTxt = createTxt(30,25,"<font color='#ffffff' size='12'><a href='event:lastPage'>末页</a></font>","lastPageTxt",onLinkHandler,onRollOverHandler,onRollOutHandler);
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
		public static var dic:Dictionary = new Dictionary();//装载已经分页好的内容
		public static var currentPageNumber:int = -1;//当前的页数
		public static var totalPage:int;//页数
		private var arr_container:Array = [];//装载分页的textfield，方面清除
		//计算内容需要分的页数
		public function createPageNum(page_arr:Array,posX:int,posY:int,row_num:int = 5):void{
			this.visible = true;
			currentIndex = 0;
			firstPageTxt.mouseEnabled = true;
			lastPageTxt.mouseEnabled = true;
			preTxt.mouseEnabled = true;
			nextTxt.mouseEnabled = true;
			if(arr_container.length != 0){
				for(var a:int=0;a<arr_container.length;a++){
					if(this.contains(arr_container[a])){
						this.removeChild(arr_container[a]);
					}
				}
				arr_container.length = 0;
			}
			if(page_arr.length != 0){
				if(page_arr.length%row_num == 0){
					totalPage = page_arr.length/row_num;
				}else{
					totalPage = (page_arr.length/row_num) + 1;
				}
			}else{
				this.visible = false;
			}
			totalTxt.htmlText = "<font color='#ffffff' size='12'>共 "+"<font color='#00ff00'>"+totalPage+"</font> 页</font>";
			createUI(page_arr,totalPage,posX,posY,row_num);
		}
		
		//创建页数的UI
		private var arr_diplayObject:Array = [];
		private function createUI(page_arr:Array,page:int,xx:int,yy:int,rowNum:int):void{
			if(currentIndex == 0){
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
						this.removeChild(a);
					}
				}
			}
			arr_diplayObject.length = 0;
			if(page != 0){
				for(var i:int = 0;i<page;i++){
					dic[i+1] = page_arr.splice(0,rowNum);
					var txt:TextField = new TextField();
					txt.selectable = false;
					this.addChild(txt);
					arr_diplayObject.push(txt);
					arr_container[i] = txt;
					txt.width = 23;
					txt.height = 20;
					if(i == 0){
						txt.htmlText = "<font color='#00ff00' size='12'><a href='event:"+(i+1)+"'>"+(i+1)+"</a></font>";
						currentIndex = i;
						txt.x = firstPageTxt.x + firstPageTxt.textWidth + preTxt.textWidth + 4;
					}else{
						txt.htmlText = "<font color='#ffcc00' size='12'><a href='event:"+(i+1)+"'>["+(i+1)+"]</a></font>";
						txt.x = firstPageTxt.x + firstPageTxt.textWidth + preTxt.textWidth + 2 + i*txt.width;
					}
					txt.y = yy;
					txt.setTextFormat(tf);
					txt.addEventListener(TextEvent.LINK,onLinkHandler,false,0,true);
				}
				content_arr = dic[1];
				currentPageNumber = 1;
				
				//下一页
				if(currentIndex == page - 1){
					lastPageTxt.mouseEnabled = false;
					nextTxt.mouseEnabled = false;
				}
				nextTxt.x = arr_container[page - 1].x + arr_container[page - 1].width + 2;
				nextTxt.y = yy;
				
				lastPageTxt.x = nextTxt.textWidth + nextTxt.x + 2;
				lastPageTxt.y = yy;
				
				totalTxt.x = lastPageTxt.textWidth + lastPageTxt.x + 2;
				totalTxt.y = yy;
			}else{
				content_arr.length = 0;
			}
			
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
			TextField(arr_container[index]).htmlText = str;
			TextField(arr_container[index]).setTextFormat(tf);
		}
		
		public static var currentIndex:int = 0;
		private function onLinkHandler(evt:TextEvent):void{
			dealTxt(currentIndex);
			if(evt.text == "firstPage"){
				currentIndex = 0;
			}else if(evt.text == "lastPage"){
				currentIndex = arr_container.length -1;
			}else if(evt.text == "pre"){
				if(currentIndex > 0)
				{
					currentIndex--;
				}
			}else if(evt.text == "next"){
				if( currentIndex < arr_container.length -1)
				{
					currentIndex++;
				}
			}else{
				currentIndex = int(evt.text) - 1;
			}
			dealLinkState(currentIndex);
		}
		
		public function dealLinkState(currentIndex:int):void{
			dealTxt(currentIndex,"new");
			content_arr = dic[currentIndex+1];
			currentPageNumber = currentIndex + 1;
			this.dispatchEvent(new Event("DATA_CHAGE"));
			if(currentIndex == arr_container.length -1){
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