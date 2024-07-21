package modules.educate.items
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.utils.ComponentUtil;
	import modules.educate.EducateConstant;
	import modules.educate.EducateModule;
	import modules.educate.views.EducateHandlerTip;
	import modules.family.FamilyModule;
	
	import proto.line.p_educate_role_info;

	public class TeacherItem extends Sprite implements IDataRenderer
	{
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var roleName:TextField;
		private var relation:TextField;
		private var levelText:TextField;
		private var titleName:TextField;
		private var studentCount:TextField;
//		private var action:TextField;
		public function TeacherItem()
		{
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #ffffff;}");
			roleName = ComponentUtil.createTextField("",0,2,tf,120,25,this);
			relation = ComponentUtil.createTextField("",0,2,tf,55,25,this);
			levelText = ComponentUtil.createTextField("",0,2,tf,55,25,this);
			titleName = ComponentUtil.createTextField("",0,2,tf,113,25,this);
			studentCount = ComponentUtil.createTextField("",0,2,tf,110,25,this);
//			action = ComponentUtil.createTextField("",100,2,tf,115,25,this);
			roleName.mouseEnabled = true;
			roleName.styleSheet = css;
//			action.htmlText = "<a href='event:1'>[组队]</a>";
//			action.addEventListener(TextEvent.LINK,onTextLink);
			roleName.addEventListener(TextEvent.LINK,onNameLink);
			LayoutUtil.layoutHorizontal(this);
		}
		
		private var _data:Object;
		public function set data(value:Object):void{
			this._data = value;
			if(_data){
				wrapperContent();
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		private function wrapperContent():void{
			var vo:p_educate_role_info = data as p_educate_role_info;
			if(vo){
				roleName.text = "<a href='event:showInfo'>"+vo.name+"</a>";
				relation.htmlText = EducateConstant.RELATIVES[vo.relation];
				levelText.text = vo.level.toString();
				titleName.text = EducateConstant.TITLE_NAMES[vo.title];
				studentCount.text = vo.student_num.toString();
				setOnline(vo.online);
			}
		}	
		
		private function setOnline(online:Boolean):void{
			if(online){
				filters = [];
			}else{
				filters = [new ColorMatrixFilter([1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0])];
			}
		}
		
		private function onNameLink(event:TextEvent):void{
			EducateHandlerTip.getInstance().show(data as p_educate_role_info,EducateHandlerTip.ITEM_VIEW);
		}
		
		private function onTextLink(event:TextEvent):void{
			var text:String = event.text;
			if(text == "1"){
				var vo:p_educate_role_info = data as p_educate_role_info;
				FamilyModule.getInstance().inviteTeam(vo.roleid);//邀请组队
			}
		}
		
	}
}