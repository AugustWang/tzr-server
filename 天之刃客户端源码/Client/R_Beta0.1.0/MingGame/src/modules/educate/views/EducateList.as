package modules.educate.views
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.educate.EducateModule;
	import modules.educate.items.EducateListItem;
	import modules.friend.views.part.ChatWindowManager;
	
	import proto.line.p_educate_role_info;
	import proto.line.p_friend_info;
	
	public class EducateList extends Sprite
	{
		public static const LEVEL_TIP:String = "等级不够10级，无法拜师。";
		public static const COMMEND_TEACHER:String = HtmlUtil.link("寻访名师","bs",true);
		private var text:TextField;
		private var memberList:List;
		public function EducateList()
		{
			super();
			var bg:UIComponent = new UIComponent();
			bg.bgSkin = Style.getSkin("friend_Border",GameConfig.T1_VIEWUI,new Rectangle(20,20,160,324));
			bg.x = 3;
			bg.width = 200;
			bg.height = 386;
			addChild(bg);
			memberList = new List();
			memberList.width = 196;
			memberList.height = 382;
			memberList.y = 2;
			memberList.x = 6;
			memberList.bgSkin = null;
			memberList.itemRenderer = EducateListItem;
			memberList.itemHeight = 25;
			memberList.itemDoubleClickEnabled = true;
			memberList.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);
			memberList.addEventListener(ItemEvent.ITEM_CLICK,onItemClick);
			addChild(memberList);
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
			
		private function onAddedToStage(event:Event):void{
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			var educateInfo:p_educate_role_info = EducateModule.getInstance().educateInfo;
			if(level < 10){
				addDefualtText(LEVEL_TIP);
			}else if(educateInfo== null || (educateInfo.teacher == 0 && educateInfo.student_max_num == 0)){
				addDefualtText(COMMEND_TEACHER);
			}else{
				EducateModule.getInstance().getRelatePeoples();
			}	
		}
			
		private function addDefualtText(value:String):void{
			if(text == null){
				var tf:TextFormat = Style.textFormat;
				tf.align = "center";
				tf.color = 0x00ff00;
				text = ComponentUtil.createTextField("",0,190,tf,196,25,this);
				text.filters = FilterCommon.FONT_BLACK_FILTERS;
				text.mouseEnabled = true;
				text.addEventListener(TextEvent.LINK,onLinkHandler);
			}
			text.htmlText = value;
		}
		
		private function removeText():void{
			if(text){
				text.removeEventListener(TextEvent.LINK,onLinkHandler);
				text.parent.removeChild(text);
				text = null;
			}	
		}
		
		private function onLinkHandler(event:TextEvent):void{
			EducateModule.getInstance().openCTeacherPanel();
		}
		
		private function onItemDoubleClick(event:ItemEvent):void{
			var item:p_educate_role_info = event.selectItem as p_educate_role_info;
			if(item){
				var friend:p_friend_info = new p_friend_info();
				friend.roleid = item.roleid;
				friend.rolename = item.name;
				friend.head = item.sex;
				friend.head = item.sex; //p_educate_role_info不包含head，暂时这样处理。。。
				ChatWindowManager.getInstance().openChatWindow(friend);
			}
		}
		
		private function onItemClick(event:ItemEvent):void{
			var item:p_educate_role_info = event.selectItem as p_educate_role_info;
			if(item){
				EducateHandlerTip.getInstance().show(item,EducateHandlerTip.ITEM_VIEW);
			}
		}
		
		public function set dataProvider(values:Array):void{
			removeText();
			if(values){
				values.sort(sortHandler);
			}
			memberList.dataProvider = values;
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