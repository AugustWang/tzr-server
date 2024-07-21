package modules.educate.items
{
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.educate.EducateModule;
	import modules.educate.views.EducateHandlerTip;
	import modules.friend.FriendsModule;
	import modules.team.TeamModule;
	import modules.team.TeamProcessor;
	
	import proto.line.p_educate_role_info;
	import proto.line.p_friend_info;
	
	public class CommendStudentItem extends Sprite implements IDataRenderer
	{
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		public static const tf1:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"left");
		private var playerText:TextField;
		private var sex:TextField;
		private var level:TextField;
		private var msg:TextField;
		
		private var action:TextField;
		public function CommendStudentItem()
		{
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #ffffff;}");
			playerText = ComponentUtil.createTextField("",0,2,tf,110,25,this);
			sex = ComponentUtil.createTextField("",110,2,tf,60,25,this);
			level = ComponentUtil.createTextField("",170,2,tf,60,25,this);
			msg = ComponentUtil.createTextField("",230,2,tf1,244,25,this);
			
			playerText.mouseEnabled = true;
			playerText.mouseEnabled = true;
			playerText.styleSheet = css;
			playerText.addEventListener(TextEvent.LINK,onNameLink);
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
				playerText.text = "<a href='event:showInfo'>"+info.name+"</a>";
				switch(info.sex){case 1: sex.text="男";break; case 2: sex.text="女";break;}
				level.text = info.level.toString();
				msg.text = info.rel_app_msg;
			}
		}	
		
		private function onNameLink(evet:TextEvent):void{
			EducateHandlerTip.getInstance().show(data as p_educate_role_info);
		}
		
		private function onTextLink(event:TextEvent):void{
			var text:String = event.text;
			var info:p_educate_role_info = data as p_educate_role_info;
			if(text == "0"){
				var friendInfo:p_friend_info = new p_friend_info();
				friendInfo.roleid = info.roleid;
				friendInfo.rolename = info.name;
				Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE,friendInfo);
			}else if(text == "1"){
				Dispatch.dispatch(ModuleCommand.START_TEAM, {"role_id":info.roleid, "type_id":1});
			}
		}
		
	}
}