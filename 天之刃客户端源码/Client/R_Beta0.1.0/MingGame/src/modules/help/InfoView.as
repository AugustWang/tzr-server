package modules.help
{
	import com.ming.ui.containers.VScrollCanvas;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	public class InfoView extends VScrollCanvas
	{
		//问题
		private var question:TextField;
		//回答
		private var answer:TextField;
		
		public function InfoView(){
			initUI();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			question = new TextField();
			question.x = 10;
			question.y = 10;
			question.width = 300;
			question.htmlText = "<font color='#FFFF00'>问题：这个游戏好玩吗？</font>";
			addChild(question);
			
			answer = new TextField();
			answer.x = 10;
			answer.y = 30;
			answer.width = 300;
			answer.height = 270;
			answer.wordWrap = true;
			answer.htmlText = "<font color='#FFFFFF'>答案：不错，强烈推荐。玩《天之刃》，提高您的素养，彰显您的品位。调查显示，目前上班族中不知道《天之刃》的人，普遍遭受鄙视。</font>";
			addChild(answer);
			
			this.width = 320;
			this.height = 318;
		}
		
		//为了实现代码公用的，而写了下面这两个set方法
		public function set dataXML(xml:XML):void{
			question.htmlText = "<font color='#FFFF00'>问题："+xml.@question+"</font>";
			answer.htmlText = "<font color='#FFFFFF'>答案："+xml.@answer+"</font>";
		}
		
		public function set otherData(data:Object):void{
			question.htmlText = "<font color='#FFFFFF'>问题："+data.question+"</font>";
			answer.htmlText = "<font color='#FFFFFF'>答案："+data.answer+"</font>";
		}
	}
}