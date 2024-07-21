package modules.educate.views
{
	import com.components.DataGrid;
	import com.components.LoadingSprite;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.educate.EducateConstant;
	import modules.educate.EducateModule;
	import modules.educate.items.TeacherItem;
	
	import proto.line.p_educate_role_info;
	
	public class TeacherList extends LoadingSprite implements ILoadData
	{
		
		private var list:DataGrid;
		private var teacherName:TextField;
		private var curTeacherValue:TextField;
		private var tolStudents:TextField;
		public function TeacherList()
		{
			var infoBg:UIComponent = ComponentUtil.createUIComponent(3,3,457,280);
			Style.setBorderSkin(infoBg);
			infoBg.y = 3;
			infoBg.x = 3;
			infoBg.mouseEnabled = false;
			addChild(infoBg);
			
			var txt1:TextField = ComponentUtil.createTextField("",4,4,null,NaN,NaN,infoBg);
			txt1.htmlText = HtmlUtil.bold(HtmlUtil.font("师门信息","#ffff00"));
			
			ComponentUtil.createTextField("导师称号：",4,25,null,NaN,NaN,infoBg);
			teacherName = ComponentUtil.createTextField("",60,25,null,NaN,NaN,infoBg);
			ComponentUtil.createTextField("导师师德值：",160,25,null,NaN,NaN,infoBg);
			curTeacherValue = ComponentUtil.createTextField("",230,25,null,NaN,NaN,infoBg);
			ComponentUtil.createTextField("导师徒弟数量：",320,25,null,NaN,NaN,infoBg);
			tolStudents = ComponentUtil.createTextField("",410,25,null,NaN,NaN,infoBg);
			
			list = new DataGrid();
			list.itemRenderer = TeacherItem;
			list.y = 53;
			list.x = 2;
			list.width = 453;
			list.height = 222;
			list.addColumn("玩家名",120);
			list.addColumn("关系",55);
			list.addColumn("等级",55);
			list.addColumn("称号",113);
			list.addColumn("徒弟数量",110);
			list.itemHeight = 25;
			list.pageCount = 9;
			list.verticalScrollPolicy = ScrollPolicy.ON;
			infoBg.addChild(list);
						
			var leaveButton:Button = ComponentUtil.createButton("离开师门",10,280,74,25,infoBg);
			leaveButton.addEventListener(MouseEvent.CLICK,leaveHandler);
		}
		
		private function leaveHandler(event:MouseEvent):void{
			EducateModule.getInstance().dropOutS();
		}
		
		public function load():void{
			addDataLoading();
			EducateModule.getInstance().getTeacherInfo();
		}
		
		private var teacher:p_educate_role_info;
		public function setTeacherInfo(brothers:Array):void{
			removeDataLoading();
			this.teacher = getTeacher(brothers);
			if(teacher){
				teacherName.text = EducateConstant.TITLE_NAMES[teacher.title];;
				var totalValues:int = EducateConstant.TOL_VALUES[teacher.title];
				var studentCount:int = EducateConstant.STUDENT_COUNTS[teacher.title];
				tolStudents.text = teacher.student_num+"/"+studentCount;
				curTeacherValue.text = teacher.moral_values.toString()+"/"+totalValues;
				if(brothers){
					brothers.sort(sortHandler);
					list.dataProvider = brothers;
					list.validateNow();
				}
			}
		}
		
		private function getTeacher(datas:Array):p_educate_role_info{
			var teacherId:int = EducateModule.getInstance().teacherId;
			for each(var teacher:p_educate_role_info in datas){
				if(teacher.roleid == teacherId){
					return teacher;
				}
			}
			return null;
		}
		
		/**
		 * 根据上下线进行排序
		 */	
		private function sortHandler(obj1:p_educate_role_info,obj2:p_educate_role_info):int{
			var online1:int = obj1.online ? 1 : 0;
			var online2:int = obj2.online ? 1 : 0;
			if(online1 > online2){
				return -1;
			}else if(online1 < online2){
				return 1;
			}else{
				return 0;
			}
		}
	}
}