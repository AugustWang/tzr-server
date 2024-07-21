package modules.educate.views
{
	import com.common.GlobalObjectManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.educate.EducateModule;
	
	import proto.common.p_role;
	import proto.line.p_educate_role_info;
	
	public class EducateView extends Sprite
	{
		public static const C_TEACHER:String = "找师傅";
		public static const C_STUDENT:String = "找徒弟";
		public static const MY_TEACHER:String = "我的师门";
		public static const MY_STUDENT:String = "我的徒弟";
		
		public static const CTEACHER_CSTUDENT:int = 0;
		public static const MYTEACHER_MYSTUDENT:int = 1;
		public static const VIEW_3:int = 2;
		
		private var tabBar:TabBar;
		private var veiwMap:Dictionary;
		private var currentView:Sprite;
		private var educateInfo:p_educate_role_info;
		
		private var commemdTeacherView:CommendTeacher;
		private var commendStudentView:CommendStudent;
		private var teacherListView:TeacherList;
		private var studentListView:StudentList;
		
		private var tabButtons:Array;
		private var border:UIComponent;
		private var container:UIComponent;
		public function EducateView()
		{
			super();
			tabButtons = [];
			veiwMap = new Dictionary();
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			container = ComponentUtil.createUIComponent(0,0,461,319);
			container.bgSkin = Style.getPanelContentBg();
			container.y = 24;
			container.mouseEnabled = false;
		}
		
		private function createTabBar(tabs:Array):void{
			if(tabs.length == 0){
				if(container.parent){
					container.parent.removeChild(this);
				}
				return;	
			}else if(container.parent == null){
				addChild(container);
			}
			if(currentView && tabButtons && tabButtons.toString() == tabs.toString()){
				ILoadData(currentView).load();//重新加载数据，以保证数据位最新数据
				return;
			}
			if(tabBar == null){
				tabBar = new TabBar();
				tabBar.x = 10;
			}
			tabBar.removeItems();
			tabButtons = tabs;
			for each(var title:String in tabButtons){
				tabBar.addItem(title,80,25);	
			}
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onSelectChanged);
			tabBar.selectIndex = 0;
			addChild(tabBar);
			tabBar.validateNow();
		}
		
		private function addTextField():void{
			if(border == null){
				border = ComponentUtil.createUIComponent(0,0,439,338);
				Style.setBorderSkin(border);
				var border1:UIComponent = ComponentUtil.createUIComponent(20,140,400,40);
				Style.setRectBorder(border1);
				border.addChild(border1);
				var tf:TextFormat = Style.textFormat;
				tf.color = 0xffff00;
				tf.align = "center";
				tf.size = 12;
				var text:TextField = ComponentUtil.createTextField("",0,10,tf,400,25,border1);
				text.text = "你等级还不够10级，无法拜师，赶紧做任务升级吧！";
			}
			addChild(border);
		}
		
		private function removeTextField():void{
			if(border && border.parent){
				removeChild(border);
			}
		}
		
		private function onAddedToStage(event:Event):void{
			var user:p_role = GlobalObjectManager.getInstance().user;
			if(user.attr.level >= 10){
				EducateModule.getInstance().getEducateInfo();	
			}else{
				addTextField();	
			}
		}
		
		public function setEducateInfo(info:p_educate_role_info):void{
			this.educateInfo = info;
			changeState();
		}
		
		public function changeState():void{
			removeTextField();
			if(educateInfo == null)return;
			var tabs:Array = [];
			getMyTeacherView(tabs);
			getMyStudentView(tabs);
			getCommendTeacherView(tabs);
			getCommendStudentView(tabs);
			createTabBar(tabs);
			if(showDismissView){
				openDismissView();
			}else{
				if(educateInfo.student_num == 0){
					var index:int = tabButtons.indexOf(C_STUDENT);
					if(index != -1){
						tabBar.selectIndex = index;
					}
				}
			}
		}
		
		private function onSelectChanged(event:TabNavigationEvent):void{
			changeView(event.index);
		}
		
		public function changeView(index:int):void{
			var name:String = tabButtons[index];
			var view:Sprite = veiwMap[name];
			if(view == null){
				view = createView(name);
				veiwMap[name] = view;
			}
			if(view == currentView)return;
			if(currentView && currentView.parent){
				container.removeChild(currentView);
			}
			view.y = 3;
			container.addChild(view);
			ILoadData(view).load();//重新加载数据，以保证数据位最新数据
			currentView = view;
		}
		
		private function createView(name:String):Sprite{
			var view:Sprite = null;
			if(name == C_TEACHER){
				view = commemdTeacherView = new CommendTeacher();
			}else if(name == C_STUDENT){
				view = commendStudentView = new CommendStudent();
			}else if(name == MY_TEACHER){
				view = teacherListView = new TeacherList();
			}else if(name == MY_STUDENT){
				view = studentListView = new StudentList();
			}
			return view;
		}
		
		private var showDismissView:Boolean;
		public function openDismissView():void{
			var index:int = tabButtons.indexOf(MY_STUDENT);
			if(index != -1){
				showDismissView = false;
				tabBar.selectIndex = index;
			}else{
				showDismissView = true;
			}	
		}
		/**
		 * 根据角色当前条件是否可以获取推荐徒弟列表 界面
		 */		
		private function getCommendStudentView(tabs:Array):void{
			tabs.push(C_STUDENT);
		}
		/**
		 * 根据角色当前条件是否可以获取推荐师傅  界面
		 */	
		private function getCommendTeacherView(tabs:Array):void{
			tabs.push(C_TEACHER);
		}
		/**
		 * 根据角色当前条件是否可以获取我的师门  界面
		 */	
		private function getMyTeacherView(tabs:Array):void{
			if(educateInfo.teacher != 0){
				tabs.push(MY_TEACHER);
			}
		}
		/**
		 * 根据角色当前条件是否可以获取我的徒弟  界面
		 */	
		private function getMyStudentView(tabs:Array):void{
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			if(level >= 25 && educateInfo.title != 0){
				tabs.push(MY_STUDENT);
			}
		}
		public function setTeachers(teachers:Array):void{
			if(commemdTeacherView){
				commemdTeacherView.setTeachers(teachers);
			}
		}
		
		public function setStudents(students:Array):void{
			if(commendStudentView){
				commendStudentView.setStudents(students);
			}
		}
		
		public function removeStudent(roleId:int):void{
			if(studentListView){
				studentListView.removeStudent(roleId);
			}
		}
		
		public function setStudentInfo(students:Array):void{
			if(studentListView){
				studentListView.setStudentInfo(students);
			}
		}
		
		public function setTeacherInfo(brothers:Array):void{
			if(teacherListView){
				teacherListView.setTeacherInfo(brothers);
			}
		}
		
		public function refCommendView():void{
			if(commemdTeacherView){commemdTeacherView.refresh();}
			if(commendStudentView){commendStudentView.refresh();}
		}
	}
}