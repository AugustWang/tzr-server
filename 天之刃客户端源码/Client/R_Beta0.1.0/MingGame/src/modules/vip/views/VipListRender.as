package modules.vip.views
{
	import com.common.GameConstant;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.ModuleCommand;
	import modules.vip.VipModule;
	
	import proto.common.p_vip_list_info;
	import proto.line.p_friend_info;
	
	public class VipListRender extends Sprite implements IDataRenderer
	{
		private var _head:Image;
		private var _name:TextField;
		private var _level:TextField;
		private var _familyName:TextField;
		private var _vo:p_vip_list_info;
		private var _vipIcon:Bitmap;
		
		public function VipListRender()
		{
			_head = new Image;
			_head.width = 25;
			_head.height = 25;
			_head.x = 7;
			addChild(_head);

			var tf:TextFormat = new TextFormat;
			tf.align = TextAlign.CENTER;
			tf.color = 0xFFF3DE;
			
			_name = ComponentUtil.createTextField("", 67, 3, tf, 106, 20, this);
			_level = ComponentUtil.createTextField("", 173, 3, tf, 62, 20, this);
			_familyName = ComponentUtil.createTextField("", 235, 3, tf, 122, 20, this);
			
			var operate:TextField = ComponentUtil.createTextField("", 357, 3, tf, 172, 20, this);
			operate.mouseEnabled = true;
			operate.addEventListener(TextEvent.LINK, linkHandler);
			operate.htmlText = "<font color='#3be450'><a href='event:chat'><u>窗口聊天</u></a>    <a href='event:addFriend'><u>加为好友</u></a></font>";
		}
		
		private function linkHandler(evt:TextEvent):void
		{
			if (evt.text == "chat") {
				var friendInfo:p_friend_info = new p_friend_info();
				friendInfo.roleid =	_vo.role_id;
				friendInfo.rolename = _vo.role_name;
				friendInfo.head = _vo.skin_id;
				Dispatch.dispatch(ModuleCommand.OPEN_FRIEND_PRIVATE, friendInfo);
			}
			
			if (evt.text == "addFriend") {
				Dispatch.dispatch(ModuleCommand.ADD_FRIEND, _vo.role_name);
			}
		}
		
		public function get data():Object
		{
			return _vo;
		}
		
		public function set data(value:Object):void
		{
			_vo = value as p_vip_list_info;
			
			_head.source = GameConstant.getHeadImage(value.skin_id);
			if (_vipIcon)
				this.removeChild(_vipIcon);
			_vipIcon = Style.getBitmap(GameConfig.T1_VIEWUI,"vip"+VipModule.getInstance().getVipLevel(_vo.total_time));
			_vipIcon.x = 33;
			_vipIcon.y = 7;
			addChild(_vipIcon);
			_name.text = _vo.role_name;
			_level.text = _vo.level.toString();
			_familyName.text = _vo.family_name;
		}
	}
}