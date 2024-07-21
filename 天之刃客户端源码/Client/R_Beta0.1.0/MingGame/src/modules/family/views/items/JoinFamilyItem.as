package modules.family.views.items
{
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	import com.managers.Dispatch;
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
	
	import proto.line.p_family_summary;
	
	public class JoinFamilyItem extends Sprite implements IDataRenderer
	{
		public static const JOINED_FAMILY:String = "joinedFamily";
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var creator:TextField;
		private var familyName:TextField;
		private var familyGlory:TextField;
		private var memberCount:TextField;
		private var action:TextField;
		public var showTipFunc:Function;
		public function JoinFamilyItem()
		{
			super();
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #AFE1EC;}");
			creator = ComponentUtil.createTextField("",0,2,tf,100,25,this);
			creator.mouseEnabled = true;
			familyName = ComponentUtil.createTextField("",100,2,tf,120,25,this);
			familyName.styleSheet = css;
			familyName.mouseEnabled = true;
			familyGlory = ComponentUtil.createTextField("",220,2,tf,80,25,this);
			memberCount = ComponentUtil.createTextField("",300,2,tf,50,25,this);
			action = ComponentUtil.createTextField("",350,2,tf,85,25,this);
			action.mouseEnabled = true;
			action.styleSheet = css;
			creator.addEventListener(TextEvent.LINK,onTextLink);
			action.addEventListener(TextEvent.LINK,onTextLink);
			familyName.addEventListener(TextEvent.LINK,onNameLink);
			Dispatch.register(JOINED_FAMILY,joinedFamilyHandler);
		}
		
		private var _data:Object;
		public function set data(value:Object):void{
			this._data = value;
			if(_data){
				wrapperContent();
			}else{
				clearContent();
			}
		}
		
		public function get data():Object{
			return _data;
		}
		
		private function joinedFamilyHandler(id:int):void{
			var info:p_family_summary = data as p_family_summary;
			if(id == info.id){
				action.htmlText = "<font color='#9d9966'>已经申请</font>";
			}
		}
		
		private function wrapperContent():void{
			var info:p_family_summary = data as p_family_summary;
			if(info){
				creator.htmlText = "<a href='event:showInfo'>"+info.owner_role_name+"</a>";
				familyName.text = "("+info.level+"级)"+"<a href='event:showInfo'>"+info.name+"</a>";
				familyGlory.text = info.active_points.toString();
				var totalCount:int = FamilyConstants.counts[info.level];
				if(totalCount == info.cur_members){
					memberCount.htmlText = HtmlUtil.font(info.cur_members+"/"+totalCount,"#ff0000");
				}else{
					memberCount.htmlText = HtmlUtil.font(info.cur_members.toString(),"#00ff00")+"/"+totalCount;
				}
				if(totalCount == info.cur_members){
					action.htmlText = "<font color='#9d9966'>申请加入</font>";
				}else if(info.cur_members <= 100){
					action.htmlText = "<a href='event:join'>申请加入</a>";	
				}
				if(FamilyModule.getInstance().isRequest(info.id)){ //是否已经申请
					action.htmlText = "<font color='#9d9966'>已经申请</font>";
				}
			}
		}
		
		private function clearContent():void{
			creator.htmlText = "";
			familyName.text = "";
			familyGlory.text = "";
			memberCount.text = "";
			action.htmlText = "";
		}	
		
		
		private var menuItems:Array;
		private var targetInfo:TargetRoleInfo;
		private function onTextLink(event:TextEvent):void{
			var text:String = event.text;
			var info:p_family_summary = data as p_family_summary;
			if(text == "showInfo"){
				if(menuItems == null){
					targetInfo = new TargetRoleInfo();
					menuItems = [];
					menuItems.push(MenuItemConstant.CHAT,MenuItemConstant.OPEN_FRIEND_CHAT,MenuItemConstant.FRIEND,MenuItemConstant.COPYNAME);
				}
				targetInfo.roleId = info.id;
				targetInfo.roleName = info.owner_role_name;
				targetInfo.faction_id = info.faction_id;
				GameMenuItems.getInstance().show(menuItems,targetInfo);
			}else if(text == "join"){
				FamilyModule.getInstance().joinFamilyRequest(info.id);
			}
		}
		
		private function onNameLink(event:TextEvent):void{
			FamilyModule.getInstance().getFamilyInfoById(data.id);
		}
		
	}
}