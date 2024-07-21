package modules.family.views
{
	import com.ming.ui.controls.TabNavigation;
	
	import flash.display.Sprite;
	import proto.line.m_family_activestate_toc;
	import proto.common.p_family_task;
	import com.ming.events.TabNavigationEvent;
	
	public class NoFamilyView extends Sprite
	{
		private var joinFamilyView:JoinFamilyView;
		private var familyIntroView:FamilyIntroView;
		private var aboutFamily:AboutFamily;
		public var tab:TabNavigation;
		
		public function NoFamilyView()
		{
			super();
			joinFamilyView = new JoinFamilyView;
			familyIntroView = new FamilyIntroView;
			aboutFamily = new AboutFamily();
			joinFamilyView.y = familyIntroView.y = aboutFamily.y = 3;
			
			tab = new TabNavigation();
			tab.tabContainerSkin = Style.getPanelContentBg();
			tab.width = 465;
			tab.height = 345;
			tab.addItem("门派信息", familyIntroView, 70, 25);
			tab.addItem("门派列表", joinFamilyView, 70, 25);
			tab.addItem("关于门派", aboutFamily, 70, 25);
			tab.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onTabChanged);
			this.addChild(tab);
		}
		
		public function selectedIndex(value:int):void{
			tab.selectedIndex = value;	
		}
		
		public function requestJoinFamily(family_id:int):void
		{
			joinFamilyView.requestJoinFamily(family_id);
		}
		
		public function setFamilyPanel(familys:Array,requesteds:Array,totalCount:int):void{
			joinFamilyView.setRequests(requesteds);
			joinFamilyView.setFamilyList(familys,totalCount);			
		}
		
		private function onTabChanged(event:*):void{
			if(tab.selectedIndex == 2)
			{
				getFamilyTask();				
			}
		}
		
		public function getFamilyTask():void
		{
			var bossnull:p_family_task = new p_family_task();
			var ybcstate:p_family_task = new p_family_task();
			bossnull.id = 10002;
			bossnull.status = 3;
			ybcstate.id = 10001;
			ybcstate.status = 3;
			var tempObj:m_family_activestate_toc = new m_family_activestate_toc();
			tempObj.succ = true;
			tempObj.familytasklist = new Array();
			tempObj.familytasklist[0] = bossnull;
			tempObj.familytasklist[1] = ybcstate;
			setFamilyTask(tempObj);						
		}
		
		public function setFamilyList(list:Array,totalPageCount:int):void{
			joinFamilyView.setFamilyList(list, totalPageCount);
		}
		
		public function setFamilyTask(data:Object):void
		{
			aboutFamily.setFamilyActivity(data);		
		}		
	}
}