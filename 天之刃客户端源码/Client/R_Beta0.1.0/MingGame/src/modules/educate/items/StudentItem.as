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
	import com.utils.HtmlUtil;
	import modules.educate.EducateConstant;
	import modules.educate.views.EducateHandlerTip;
	
	import proto.line.p_educate_role_info;
	
	public class StudentItem extends Sprite implements IDataRenderer
	{
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var studentName:TextField;
		private var level:TextField;
		private var title:TextField;
		private var exp:TextField;
		private var children:TextField;
		public function StudentItem()
		{			
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #ffffff;}");
			studentName = ComponentUtil.createTextField("",0,2,tf,130,25,this);
			level = ComponentUtil.createTextField("",100,2,tf,48,25,this);
			title = ComponentUtil.createTextField("",200,2,tf,100,25,this);
			exp = ComponentUtil.createTextField("",100,2,tf,78,25,this);
			children = ComponentUtil.createTextField("",200,2,tf,94,25,this);
			studentName.mouseEnabled = true;
			studentName.styleSheet = css;
			studentName.addEventListener(TextEvent.LINK,onNameLink);
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
			var info:p_educate_role_info = data as p_educate_role_info;
			if(info){
				setNameText(info);
				level.text = info.level.toString();
				title.text = EducateConstant.TITLE_NAMES[info.title];
				exp.text = info.exp_devote1.toString();
				children.text = info.student_num.toString();
				setOnline(info.online);
			}
		}	
		
		private function setNameText(info:p_educate_role_info):void{
			var endFix:String;
			var normalColor:String = info.online ? "#00ff00" : "#ffffff";
			if(info.level >= 60){
				endFix = HtmlUtil.font("已出师",normalColor);
			}else{
				var fixColor:String = info.online ? EducateConstant.RELATIVES_COLORS[info.title] : "#ffffff";
				endFix = HtmlUtil.font(EducateConstant.RELATIVES[info.relation],fixColor);
			}
			studentName.text = "<a href='event:showInfo'>"+info.name+"("+endFix+")</a>";
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
	}
}