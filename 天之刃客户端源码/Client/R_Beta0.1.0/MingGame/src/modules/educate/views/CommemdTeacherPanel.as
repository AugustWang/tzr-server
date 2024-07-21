package modules.educate.views
{
	import com.components.BasePanel;
	
	public class CommemdTeacherPanel extends BasePanel
	{
		private var view:CommendTeacher;
		public function CommemdTeacherPanel(key:String=null)
		{
			super("");
			width = 450;
			height = 350;
			this.title = "推荐导师";
			view = new CommendTeacher();
			view.x = 5;
			addChild(view);
		}
		
		public function setTeachers(teachers:Array):void{
			view.setTeachers(teachers);
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