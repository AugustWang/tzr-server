package modules.family.views
{
	import flash.display.Sprite;
	
	import proto.line.*;
	
	public class AboutFamily extends Sprite
	{
		private var InfoPanel:FamilyAlertPanel;
		
		
		public function AboutFamily()
		{
			super();
			init();
		}
		
		private function init():void
		{
			
			InfoPanel = new FamilyAlertPanel();
			InfoPanel.x = 3;
			InfoPanel.y = 2;
			addChild(InfoPanel);	

		}
		
		public function setFamilyActivity(data:Object):void {
			var everydayVo:m_family_activestate_toc =data as m_family_activestate_toc;
			if (everydayVo == null)
				return;
			if (everydayVo.succ) {
				var arr:Array=[];
				var temArr:Array=everydayVo.familytasklist;
				if (temArr.length != 0) {
					arr=temArr;
					InfoPanel.setFamilyData(arr);
				}
			}
		}
	}
}