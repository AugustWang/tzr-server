package modules.educate.views
{
	import com.components.BasePanel;
	
	public class CommemdStudentPanel extends BasePanel
	{
		private var view:CommendStudent;
		public function CommemdStudentPanel(key:String=null)
		{
			super("");
			width = 450;
			height = 350;
			this.title = "推荐徒弟";
			view = new CommendStudent();
			view.x = 5;
			addChild(view);
		}
		
		public function setStudents(students:Array):void{
			view.setStudents(students);
		}
		
		public function load():void{
			view.load();	
		}
		
		public var closeFunc:Function;
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			if(closeFunc != null){
				closeFunc.apply(null);
			}
		}
	}
}