package modules.official.views.items
{
	import com.common.GlobalObjectManager;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import modules.official.OfficialModule;
	import modules.official.views.OrdainPanel;
	
	import proto.line.p_office_position;
	
	public class OfficialItem extends Sprite
	{
		public static const DISMISS:int = 0;
		public static const CANCEL:int = 1;
		public static const ORDAIN:int = 2;
		
		public var state:int;
		
		public var kingId:int;
		private var text:TextField;
		private var handlerText:TextField;
		
		public var officeId:int;
		public function OfficialItem()
		{
			super();
			text = ComponentUtil.createTextField("",0,0,null,208,25,this);
			text.filters = [new GlowFilter(0x000000,1,3,3,3)];
			handlerText = ComponentUtil.createTextField("",165,0,null,35,25,this);
			handlerText.mouseEnabled = true;
			handlerText.filters = [new GlowFilter(0x000000,1,3,3,3)];
			
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {text-decoration: underline;color: #ffff00;} a:hover {color: #00ff00;}");
			
			handlerText.styleSheet = css;
			handlerText.addEventListener(TextEvent.LINK,onLinkHandler);
		}
		
		private var roleId:int;
		private var roleName:String;
		private var inviteRoleName:String;
		public function setRoleInfo(roleId:int,roleName:String,inviteRoleName:String=""):void{
			this.roleId = roleId;
			this.roleName = roleName;
			this.inviteRoleName = inviteRoleName;
		}
		
		public function setState(_state:int):void{
			state = _state
			switch(_state){
				case DISMISS:
					text.htmlText = HtmlUtil.font(roleName,"#FFE485");
					handlerText.htmlText = a("开除",state);
					break;
				case CANCEL:
					text.htmlText = HtmlUtil.font("等待","##00FF00")+HtmlUtil.font(inviteRoleName,"#FFE485")+HtmlUtil.font("接受","#00FF00");
					handlerText.htmlText = a("撤销",state);
					break;
				case ORDAIN:
					text.htmlText = HtmlUtil.font("职位空缺","#FFE485");
					handlerText.htmlText = a("任命",state);
					break;
			}
		}
		
		private function onLinkHandler(event:TextEvent):void{
			var type:int = int(event.text);
			if(type == DISMISS){
				 OfficialModule.getInstance().disappoint(officeId,roleName);
			}else if(type == CANCEL){
				OfficialModule.getInstance().cancelAppoint(officeId);
			}else if(type == ORDAIN){
				OrdainPanel.getInstance().officeId = officeId;
				OrdainPanel.getInstance().show();
			}
		}
		
		private function a(str:String,handleType:int):String{
			var roleId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if(kingId == roleId){
				return "<a href='event:"+handleType+"'>"+str+"</a>";
			}
			return "";
		}
	}
}