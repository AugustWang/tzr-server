package modules.family.views
{
	
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.friend.FriendsManager;
	
	import proto.line.p_family_summary;
	import proto.line.p_friend_info;
	
	public class JoinFamilyToolTip extends UIComponent
	{
		public var userId:int;
		private var text:TextField;
		public function JoinFamilyToolTip()
		{
			width = 90;
			height = 65;
			Style.setRectBorder(this);
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffffff;} a:hover {color: #00ff00;}");
			var tf:TextFormat = Style.textFormat;
			tf.leading = 3;
			text = ComponentUtil.createTextField("",10,5,tf,NaN,NaN,this); 
			text.styleSheet = css;
			text.mouseEnabled = true;
			text.wordWrap = true;
			text.multiline = true;
			text.addEventListener(TextEvent.LINK, onLink);
		}
		
		private function onLink(event:TextEvent):void{
			var action:String = event.text;
			if(action == "ML"){
				ChatModule.getInstance().priChatHandler(info.name);
			}else if(action == "CKLT"){
				openChatWindow();
			}else if(action == "FZ"){
				System.setClipboard(info.owner_role_name);
			}else if(action == "JWHY"){
				addFriend();
			}
		}
		
		private function openChatWindow():void{
			var p:p_friend_info = new p_friend_info();
			p.roleid = info.owner_role_id;
			p.rolename = info.owner_role_name;
			p.head = 1;
			Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE,p);
		}
		
		private function addFriend():void{
			Dispatch.dispatch(ModuleCommand.ADD_FRIEND,info.name);
		}
		
		private static var instance:JoinFamilyToolTip;
		public static function getInstance():JoinFamilyToolTip{
			if(instance == null){
				instance = new JoinFamilyToolTip();
			}
			return instance;
		}
		
		private var info:p_family_summary;
		public function show(info:p_family_summary):void{
			this.info = info;
			var html:String = "<a href='event:ML'>私聊</a>\n<a href='event:CKLT'>窗口聊天</a>";
			if(FriendsManager.getInstance().isMyFriend(info.owner_role_id)){
				html += "\n<a href='event:JWHY'>加为好友</a>"
			}
			html += "\n<a href='event:FZ'>复制人名</a>"
			text.htmlText = html;
			text.height = text.textHeight + 5;
			LayerManager.main.addChild(this);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseClick);
			height = text.height + 10;
			validateNow();
			this.x = stage.mouseX;
			this.y = stage.mouseY;
		}
		
		private function onMouseClick(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseClick);
			if(parent){
				close();
			}	
		}
		
		public function close():void{
			if(parent){
				parent.removeChild(this);
			}
		}
	}
}