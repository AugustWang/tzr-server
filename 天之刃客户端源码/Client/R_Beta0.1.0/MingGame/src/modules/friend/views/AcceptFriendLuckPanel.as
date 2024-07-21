package modules.friend.views
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.Button;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.components.BasePanel;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import modules.friend.FriendsManager;
	import modules.friend.views.part.ChatWindowManager;
	
	import proto.line.p_friend_info;
	
	public class AcceptFriendLuckPanel extends BasePanel
	{
		private var contentText:TextField;
		private var remark:TextField;
		private var thinksBtn:Button;
		private var okButton:Button;
		public function AcceptFriendLuckPanel()
		{
			super();
			this.title = "好友祝福";
			width = 365;
			height = 155;
			
			
			var back:Sprite = Style.getBlackSprite(341,83);
			back.x = 12;
			back.y = 2;
			addChild(back);
			var tf:TextFormat = Style.textFormat;
			tf.leading = 5;

			contentText = ComponentUtil.createTextField("",3,3,tf,335,60,back);
			contentText.wordWrap = true;
			contentText.multiline = true;

			remark = ComponentUtil.createTextField("",191,63,null,150,25,back);
			remark.autoSize = "right"

			thinksBtn = ComponentUtil.createButton("答谢",241,87,52,25,this);
			thinksBtn.addEventListener(MouseEvent.CLICK,onThinksHandler);
			
			okButton = ComponentUtil.createButton("确定",300,87,52,25,this);
			okButton.addEventListener(MouseEvent.CLICK,onOkHandler);
			
			var tipText:TextField = ComponentUtil.createTextField("",13,92,null,250,25,this);
			tipText.htmlText = HtmlUtil.font("前20个好友祝福，将获得丰厚的经验奖励！","#ffff00");
		}
		
		private var fromFriendName:String;
		public function setLuck(fromFriendName:String,content:String):void{
			this.fromFriendName = fromFriendName;
			var myName:String = GlobalObjectManager.getInstance().user.attr.role_name;
			var html:String = "亲爱的好友"+HtmlUtil.font("["+myName+"]","#ffff00")+"：\n";
			html += "      "+content;
			contentText.htmlText = html;
			remark.htmlText = "好友"+HtmlUtil.font("["+fromFriendName+"]","#ffff00");
		}
		
		private function onThinksHandler(event:MouseEvent):void{
			var friendVO:p_friend_info = FriendsManager.getInstance().getFriendByName(fromFriendName);
			if(friendVO){
				ChatWindowManager.getInstance().openChatWindow(friendVO,"谢谢你的祝福！");
				onOkHandler(null);
			}
		}
		
		private function onOkHandler(event:MouseEvent):void{
			closeWindow();
			dispose();
		}
	}
}