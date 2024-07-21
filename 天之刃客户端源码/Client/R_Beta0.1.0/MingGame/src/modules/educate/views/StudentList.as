package modules.educate.views
{
	import com.common.FilterCommon;
	import com.components.DataGrid;
	import com.components.LoadingSprite;
	import com.components.alert.Alert;
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
	import modules.educate.items.StudentItem;
	import modules.family.FamilyModule;
	
	import proto.line.p_educate_role_info;
	
	public class StudentList extends LoadingSprite implements ILoadData
	{
		private var list:DataGrid;
		private var removeButton:Button;
		private var teamButton:Button;
		
		private var teacherName:TextField;
		private var curTeacherValue:TextField;
		private var tolStudents:TextField;
		public function StudentList()
		{
			var infoBg:UIComponent = ComponentUtil.createUIComponent(3,3,457,280);
			Style.setBorderSkin(infoBg);
			infoBg.y = 3;
			infoBg.x = 3;
			infoBg.mouseEnabled = false;
			addChild(infoBg);
			
			var txt1:TextField = ComponentUtil.createTextField("",4,4,null,NaN,NaN,infoBg);
			txt1.htmlText = HtmlUtil.bold(HtmlUtil.font("个人信息","#ffff00"));
			
			ComponentUtil.createTextField("当前称号：",4,25,null,NaN,NaN,infoBg);
			teacherName = ComponentUtil.createTextField("",60,25,null,NaN,NaN,infoBg);
			ComponentUtil.createTextField("当前师德值：",160,25,null,NaN,NaN,infoBg);
			curTeacherValue = ComponentUtil.createTextField("",230,25,null,NaN,NaN,infoBg);
			ComponentUtil.createTextField("当前徒弟数量：",320,25,null,NaN,NaN,infoBg);
			tolStudents = ComponentUtil.createTextField("",410,25,null,NaN,NaN,infoBg);
				
			list = new DataGrid();
			list.itemRenderer = StudentItem;
			list.y = 53;
			list.x = 2;
			list.width = 453;
			list.height = 222;
			list.addColumn("高徒",130);
			list.addColumn("等级",48);
			list.addColumn("称号",100);
			list.addColumn("贡献经验",78);
			list.addColumn("徒孙数量",92);
			list.itemHeight = 25;
			list.pageCount = 8;
			list.verticalScrollPolicy = ScrollPolicy.ON;
			infoBg.addChild(list);

			teamButton = ComponentUtil.createButton("邀请组队",14,280,74,25,infoBg);
			teamButton.addEventListener(MouseEvent.CLICK,teamHandler);
			
			removeButton = ComponentUtil.createButton("开除徒弟",100,280,74,25,infoBg);
			removeButton.addEventListener(MouseEvent.CLICK,removeHandler);
			
			var txt:TextField = ComponentUtil.createTextField("60级徒弟将自动出师，可以再招新徒弟。",195,283,null,230,25,infoBg);
			txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			txt.textColor = 0xffff00;
		}
		
		public function load():void{
			addDataLoading();
			EducateModule.getInstance().getStudentInfo();
		}
		
		private function teamHandler(event:MouseEvent):void{
			var item:Object = list.list.selectedItem;
			if(item){
				var role:p_educate_role_info = item as p_educate_role_info;
				FamilyModule.getInstance().inviteTeam(role.roleid);//邀请组队
			}
		}
		
		private function removeHandler(event:MouseEvent):void{
			var item:Object = list.list.selectedItem;
			if(item){
				var role:p_educate_role_info = item as p_educate_role_info;
				if(role.level >= 60){
					Alert.show(HtmlUtil.font(role.name,"#ffff00")+"已经成功出师，你们已经感情深厚，不能解除师徒关系。","温馨提示",null,null,"确定","",null,false);
					return;
				}
				EducateModule.getInstance().dismissS(role.roleid);
			}
		}
		
		public function setStudentInfo(studentInfo:Array):void{
			removeDataLoading();
			studentInfo.sort(sortHandler);
			list.dataProvider = studentInfo;
			list.validateNow();
			var info:p_educate_role_info = EducateModule.getInstance().educateInfo;
			if(info){
				teacherName.text = EducateConstant.TITLE_NAMES[info.title];
				var totalValues:int = EducateConstant.TOL_VALUES[info.title];
				var studentCount:int = EducateConstant.STUDENT_COUNTS[info.title];
				tolStudents.text = info.student_num+"/"+studentCount;
				curTeacherValue.text = info.moral_values.toString()+"/"+totalValues;
			}
		}
		
		public function removeStudent(roleId:int):void{
			var array:Array = list.list.dataProvider;
			if(!array)return;
			for(var i:int=0;i<array.length;i++){
				var p:p_educate_role_info = array[i];
				if(p.roleid == roleId){
					array.splice(i,1);
					break;
				}
			}
			list.dataProvider = array;
			list.validateNow();
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