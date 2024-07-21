package modules.family.views.items
{
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.chat.ChatModule;
	import modules.family.FamilyModule;
	import modules.letter.LetterModule;
	
	import proto.common.p_recommend_member_info;
	
	public class RecruitItem extends Sprite implements IDataRenderer
	{
		public static const tf:TextFormat = new TextFormat("Arail",12,0xffffff,null,null,null,null,null,"center");
		private var sexText:TextField;
		private var playerText:TextField;
		private var level:TextField;
		private var officialText:TextField;
		private var action:TextField;
		private static const OFFICIAL:Array = ["战士","射手","侠客","医仙"];
		public function RecruitItem()
		{
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #ffffff;}");

			sexText = ComponentUtil.createTextField("",0,2,tf,50,25,this);
			playerText = ComponentUtil.createTextField("",50,2,tf,100,25,this);
			level = ComponentUtil.createTextField("",150,2,tf,50,25,this);
			officialText = ComponentUtil.createTextField("",200,2,tf,60,25,this);
			action = ComponentUtil.createTextField("",260,2,tf,160,25,this);
			action.mouseEnabled = true;
			action.styleSheet = css;
			action.addEventListener(TextEvent.LINK,onTextLink);
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
			var info:p_recommend_member_info = data as p_recommend_member_info;
			if(info){
				sexText.text = info.sex == 1 ? "男" : "女"; 
				playerText.text = info.role_name;
				level.text = info.level.toString();
				officialText.text = OFFICIAL[info.category-1];
				action.htmlText = "<a href='event:0'>[私聊]</a>  <a href='event:1'>[发信]</a>  <a href='event:2'>[邀请加入]</a>";
			}
		}	
		
		private function onTextLink(event:TextEvent):void{
			var text:String = event.text;
			var info:p_recommend_member_info = data as p_recommend_member_info;
			if(text == "0"){
				ChatModule.getInstance().priChatHandler(info.role_name);
			}else if(text == "1"){
				LetterModule.getInstance().openLetter(info.role_name);
			}else if(text == "2"){
				FamilyModule.getInstance().inviteJoinFamily(info.role_name);
				action.htmlText = "<a href='event:0'>[私聊]</a>  <a href='event:1'>[发信]</a>  <font color='#9d9966'>[已经邀请]</font>";
			}
		}

	}
}