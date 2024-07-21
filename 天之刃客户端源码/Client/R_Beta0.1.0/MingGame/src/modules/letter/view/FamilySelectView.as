package modules.letter.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import modules.letter.LetterModule;
	
	public class FamilySelectView extends BasePanel
	{
		public static var range:int = 0;//0 全部，1在线，-1离线
		public function FamilySelectView()
		{
			super("FamilySelectView");
			initView();
		}
		
		private function initView():void{
			this.width = 380;
			this.height = 150;
			this.title = "群发信件";
			addContentBG(5);
			//背景
			
			var allTxt:TextField  = ComponentUtil.createTextField("所有帮众",108,40,null,60,30,this);
			allTxt.mouseEnabled = true;
			allTxt.addEventListener(TextEvent.LINK,onLinkHandler);
			allTxt.htmlText = "<font color='#00ff00'><u><a href='event:allTxt'>所有帮众</a></u></font>";
			var onlineTxt:TextField = ComponentUtil.createTextField("在线帮众",allTxt.x + allTxt.width,allTxt.y,null,60,30,this);
			onlineTxt.mouseEnabled = true;
			onlineTxt.addEventListener(TextEvent.LINK,onLinkHandler);
			onlineTxt.htmlText = "<font color='#00ff00'><u><a href='event:onlineTxt'>在线帮众</a></u></font>";
			var notOnlineTxt:TextField = ComponentUtil.createTextField("离线帮众",onlineTxt.x + onlineTxt.width,allTxt.y,null,60,30,this);
			notOnlineTxt.mouseEnabled = true;
			notOnlineTxt.addEventListener(TextEvent.LINK,onLinkHandler);
			notOnlineTxt.htmlText = "<font color='#00ff00'><u><a href='event:notOnlineTxt'>离线帮众</a></u></font>";
			
			var costTxt:TextField = ComponentUtil.createTextField("群发信件费用：10 两",20,notOnlineTxt.y + notOnlineTxt.height + 10,null,120,30,this);
			costTxt.htmlText = "<font color='#AFE1EC'>群发信件费用：<font color='#00ff00'>10 两</font></font>"
		}
		
		private function onLinkHandler(evt:TextEvent):void{
			var str:String = evt.text;
			var familyName:String = GlobalObjectManager.getInstance().user.base.family_name;
			if(str == "allTxt"){
				range = 0;
				LetterModule.getInstance().writeLetter(familyName+"的所有帮众","",true);
			}else if(str == "onlineTxt"){
				range = 1;
				LetterModule.getInstance().writeLetter(familyName+"的在线帮众","",true);
			}else if(str == "notOnlineTxt"){
				range = -1;
				LetterModule.getInstance().writeLetter(familyName+"的离线帮众","",true);
			}
			WindowManager.getInstance().removeWindow(this);
		}
	}
}