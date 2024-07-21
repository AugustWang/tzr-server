package modules.family.views.items
{
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyModule;
	import modules.family.views.JoinFamilyToolTip;
	
	import proto.line.p_family_summary;
	
	public class FamilyInfoItem extends Sprite implements IDataRenderer
	{
		public static const JOINED_FAMILY:String = "joinedFamily";
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var creator:TextField;
		private var familyName:TextField;
		private var familyGlory:TextField;
		private var memberCount:TextField;
		public function FamilyInfoItem()
		{
			super();
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #AFE1EC;}");
			creator = ComponentUtil.createTextField("",0,2,tf,110,25,this);
			creator.styleSheet = css;
			creator.mouseEnabled = true;
			familyName = ComponentUtil.createTextField("",110,2,tf,120,25,this);
			familyName.styleSheet = css;
			familyName.mouseEnabled = true;
			familyGlory = ComponentUtil.createTextField("",230,2,tf,110,25,this);
			memberCount = ComponentUtil.createTextField("",340,2,tf,102,25,this);
			familyName.addEventListener(TextEvent.LINK,onNameLink);
			creator.addEventListener(TextEvent.LINK,onTextLink);
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
			var info:p_family_summary = data as p_family_summary;
			if(info){
				creator.htmlText = "<a href='event:showInfo'><u>"+info.owner_role_name+"</u></a>";
				familyName.text = "("+info.level+"级)"+"<a href='event:showInfo'><u>"+info.name+"</u></a>";
				familyGlory.text = info.active_points.toString();
				var totalCount:int = FamilyConstants.counts[info.level];
				if(totalCount == info.cur_members){
					memberCount.htmlText = HtmlUtil.font(info.cur_members+"/"+totalCount,"#ff0000");
				}else{
					memberCount.htmlText = HtmlUtil.font(info.cur_members.toString(),"#00ff00")+"/"+totalCount;
				}
			}
		}
		
	
		private function onTextLink(event:TextEvent):void{
			var text:String = event.text;
			var info:p_family_summary = data as p_family_summary;
			if(text == "showInfo"){
				JoinFamilyToolTip.getInstance().show(data as p_family_summary);
			}
		}
		
		private function onNameLink(event:TextEvent):void{
			FamilyModule.getInstance().getFamilyInfoById(data.id);
		}
		
	}
}