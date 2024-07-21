package modules.educate.views
{
	import com.components.BasePanel;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class EducateCommendView extends BasePanel
	{
		private var tab:TabNavigation;
		private var teacherCommendView:CommendTeacher;
		private var studentCommendView:CommendStudent;
		
		public function EducateCommendView(key:String=null)
		{
			this.title = "师徒推荐";
			this.width = 479;
			this.height = 388;
			addContentBG(33,8,24);
			
			teacherCommendView = new CommendTeacher();
			studentCommendView = new CommendStudent();
			teacherCommendView.y = studentCommendView.y = 2;
			
			tab = new TabNavigation;
			tab.tabContainerSkin=null;
			this.addChild(tab);
			tab.x = 9;
			tab.addItem("推荐名师", teacherCommendView,60,25);
			tab.addItem("推荐徒弟", studentCommendView,60,25);
			tab.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onTabClick);
		}
		
		private function onTabClick(e:TabNavigationEvent):void
		{
			if (tab.selectedIndex == 0) {
				teacherCommendView.load();
			} else {
				studentCommendView.load();
			}
		}
		
		public function setTab(type:int):void
		{
			// 收徒
			if (type == 1) {
				this.tab.selectedIndex = 1;
			} else {
				this.tab.selectedIndex = 0;
			}
		}
		
		
		public function load():void{
			// 0为师傅 1 为徒弟
			if (tab.selectedIndex == 0) {
				teacherCommendView.load();
			} else {
				studentCommendView.load();
			}
		}
		
		public function setTeachers(teachers:Array):void{
			teacherCommendView.setTeachers(teachers);
		}
		
		public function setStudents(students:Array):void{
			studentCommendView.setStudents(students);
		}
		
		public function refCommendView():void{
			if(teacherCommendView){teacherCommendView.refresh();}
			if(studentCommendView){studentCommendView.refresh();}
		}
	}
}