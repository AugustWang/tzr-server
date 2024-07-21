package modules.friend.views.messageBox
{
	import com.common.GameConstant;
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	import modules.friend.views.vo.GroupVO;
	
	import proto.line.p_friend_info;
	
	public class MessageBoxItem extends Sprite implements IDataRenderer
	{
		private var head:Image;
		private var nameText:TextField;
		private var countText:TextField;
		public function MessageBoxItem()
		{	
			head = new Image();
			head.width = 20;
			head.height = 20;
			addChild(head);
			
			var css:StyleSheet = new StyleSheet();
			css.parseCSS("a {color: #ffff00;} a:hover {color: #AFE1EC;}");
			
			nameText = ComponentUtil.createTextField("",20,0,null,100,22,this);
			countText = ComponentUtil.createTextField("",120,0,null,60,22,this);
			countText.mouseEnabled = true;
			countText.styleSheet = css;
			countText.addEventListener(TextEvent.LINK,onTextLink);
		}
		
		private var _data:Object;
		public function set data(value:Object):void{
			_data = value;
			if(_data.type == MessageBox.PRIVATE){
				var info:p_friend_info = _data.messageInfo as p_friend_info;
				head.source = GameConstant.getHeadImage(info.head);
				nameText.htmlText = info.rolename;	
			}else if(_data.type == MessageBox.GROUP){
				var groupVO:GroupVO = _data.messageInfo as GroupVO;
				head.source = GameConfig.ROOT_URL + "com/assets/friend/group.png";
				nameText.htmlText = groupVO.name;
			}
			countText.htmlText = "<a href='event:ignore'>取消</a>"+"("+_data.count+")";
		}
		
		public function get data():Object{
			return _data;
		}
		
		private function onTextLink(event:TextEvent):void{
			var id:String = _data.type == MessageBox.PRIVATE ? _data.messageInfo.roleid : _data.messageInfo.id;
			_data["cancel"] = true;
			MessageBox.getInstance().removeMessage(id,_data.type);
		}
	}
}