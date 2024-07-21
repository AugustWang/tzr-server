package modules.mission.views
{
	import com.ming.ui.containers.Canvas;
	
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import modules.Activity.ActivityModule;
	
	public class CanLinkMissionCanvas extends Canvas
	{
		public function CanLinkMissionCanvas()
		{
			super();
			initUI();
		}
		
		private function initUI():void{
			var exp:TextField = new TextField();
			exp.x = 5;
			exp.y = 5;
			exp.width = 200;
			exp.height=20;
			exp.htmlText="<u><font color='#39ff0b'><a href='event:exp'>经验</a></font></u>";
			exp.addEventListener(TextEvent.LINK, onLinkHandle);
			this.addChild(exp);
			
			var silver:TextField = new TextField();
			silver.x = exp.x;
			silver.y = exp.y + exp.height + 2;
			silver.width = 200;
			silver.height = 20;
			silver.htmlText="<u><font color='#39ff0b'><a href='event:silver'>银子</a></font></u>";
			silver.addEventListener(TextEvent.LINK, onLinkHandle);
			this.addChild(silver);
			
			var equip:TextField = new TextField();
			equip.x = exp.x;
			equip.y = silver.y + silver.height + 2;
			equip.width = 200;
			equip.height = 20;
			equip.htmlText="<u><font color='#39ff0b'><a href='event:equip'>装备道具</a></font></u>";
			equip.addEventListener(TextEvent.LINK, onLinkHandle);
			this.addChild(equip);
			
			var benefit:TextField = new TextField();
			benefit.x = exp.x;
			benefit.y = equip.y + equip.height + 2;
			benefit.width = 200;
			benefit.height = 20;
			benefit.htmlText="<u><font color='#39ff0b'><a href='event:benefit'>日常福利</a></font></u>";
			benefit.addEventListener(TextEvent.LINK, onLinkHandle);
			this.addChild(benefit);
		}
		
		protected function onLinkHandle(event:TextEvent):void
		{
			// TODO Auto-generated method stub
			switch(event.text){
				case "exp":
					ActivityModule.getInstance().openActivityWin(2);
					break;
				case "silver":
					ActivityModule.getInstance().openActivityWin(3);
					break;	
				case "equip":
					ActivityModule.getInstance().openActivityWin(4);
					break;
				case "benefit":
					ActivityModule.getInstance().openActivityWin(0);
					break;
			}
		}
	}
}