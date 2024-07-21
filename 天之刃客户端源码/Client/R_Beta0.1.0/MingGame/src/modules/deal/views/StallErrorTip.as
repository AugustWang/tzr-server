package modules.deal.views
{
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setTimeout;
	
	public class StallErrorTip extends UIComponent
	{
		private var txt:TextField;
		private var timeoutId:int;
		public function StallErrorTip()
		{
			super();txt=new TextField;
			txt.x=7;
			txt.y=7;
			txt.width=138;
			txt.height=50;
			txt.textColor=0xffffff;
			txt.multiline=true;
			txt.wordWrap=true;
			addChild(txt);
			this.width=160;
			this.height=65;
			Style.setRectBorder(this);
		}
		
		public function turnon(msg:String):void
		{
			this.visible=true;
			txt.htmlText=msg;
			clearInterval(timeoutId);
			timeoutId=setTimeout(hide, 2000);
		}
		
		private function hide():void
		{
			this.visible=false;
		}
	}
}