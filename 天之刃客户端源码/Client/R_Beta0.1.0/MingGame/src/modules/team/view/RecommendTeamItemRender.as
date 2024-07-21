package modules.team.view
{
	
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.friend.FriendsModule;
	
	import proto.common.p_recommend_member_info;
	
	public class RecommendTeamItemRender extends UIComponent
	{
		private var playerNameTxt:TextField;
		private var levelTxt:TextField;
		private var teamTxt:TextField;
		private var recommendTxt:TextField;
		
		public function RecommendTeamItemRender()
		{
			var textformate:TextFormat=new TextFormat(null, 12, 0xe0e7c6, null, null, null, null, null, TextFormatAlign.CENTER);
			playerNameTxt=ComponentUtil.createTextField("", 0, 2, textformate, 108, 23, this);
			levelTxt=ComponentUtil.createTextField("", playerNameTxt.x + playerNameTxt.width, playerNameTxt.y, textformate, 50, 23, this);
			teamTxt=ComponentUtil.createTextField("", levelTxt.x + levelTxt.width, levelTxt.y, new TextFormat(null, 12, 0x00fc34, null, null, true, null, null), 50, 23, this);
			teamTxt.mouseEnabled=true;
			teamTxt.name="team";
			teamTxt.addEventListener(TextEvent.LINK, onLinkHandler);
			teamTxt.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
			teamTxt.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
			
			recommendTxt=ComponentUtil.createTextField("", teamTxt.x + teamTxt.width, teamTxt.y, new TextFormat(null, 12, 0x00fc34, null, null, true, null, null), 70, 23, this);
			recommendTxt.mouseEnabled=true;
			recommendTxt.name="recommend";
			recommendTxt.addEventListener(TextEvent.LINK, onLinkHandler);
			recommendTxt.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
			recommendTxt.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
		}
		
		private function onLinkHandler(evt:TextEvent):void
		{
			if (evt.currentTarget.name == "team")
			{
				//ChatModel.getInstance().sendToModule(TeamActionType.START_TEAM.toString(), info.role_id, ModelConstant.TEAM_MODEL);
			}
			else
			{
				FriendsModule.getInstance().requestFriend(info.role_name);
			}
		}
		
		private function onRollOverHandler(evt:MouseEvent):void
		{
			if (evt.currentTarget.name == "team")
			{
				teamTxt.textColor=0xffcc00;
			}
			else
			{
				recommendTxt.textColor=0xffcc00;
			}
		}
		
		private function onRollOutHandler(evt:MouseEvent):void
		{
			if (evt.currentTarget.name == "team")
			{
				teamTxt.textColor=0x00fc34;
			}
			else
			{
				recommendTxt.textColor=0x00fc34;
			}
		}
		
		private function setValue(name:String, lvl:int, team:String, recommend:String):void
		{
			playerNameTxt.text=name;
			levelTxt.text=lvl.toString();
			teamTxt.htmlText="<a href='event:recommed'>" + team + "</a>";
			recommendTxt.htmlText="<a href='event:recommed'>" + recommend + "</a>";
		}
		
		override public function get data():Object
		{
			return super.data;
		}
		
		private var info:p_recommend_member_info;
		
		override public function set data(value:Object):void
		{
			super.data=value;
			info=value as p_recommend_member_info;
			setValue(info.role_name, info.level, "组队", "加为好友");
		}
	}
}