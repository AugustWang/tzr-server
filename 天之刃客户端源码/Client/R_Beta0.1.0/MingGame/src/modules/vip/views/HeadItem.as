package modules.vip.views
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.vip.VipModule;
	
	import proto.common.p_role_vip;
	
	public class HeadItem extends Sprite
	{
		private var _starBg:Sprite;
		
		public function HeadItem()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			var headBox:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			var roleName:String = GlobalObjectManager.getInstance().user.base.role_name;
			var headIcon:Image = new Image;
			headIcon.width = 40;
			headIcon.height = 40;
			headIcon.source = GameConstant.getHeadImage(GlobalObjectManager.getInstance().user.base.head);
			addChild(headBox);
			addChild(headIcon);
			var tf:TextFormat = new TextFormat;
			tf.color = 0x00ff00;
			tf.bold = true;
			var nameTxt:TextField = ComponentUtil.createTextField(roleName, 45, 1, tf, 125, 25, this);
			addChild(nameTxt);
		}
		
		public function reset():void
		{
			var vipInfo:p_role_vip = VipModule.vipInfo;
			if (_starBg && _starBg.parent) {
				_starBg.parent.removeChild(_starBg);
			}
			_starBg = new Sprite;
			_starBg.x = 48;
			_starBg.y = 23;
			addChild(_starBg);
			var x:int = 0;
			var star:Bitmap;
			var level:int;
			if (!vipInfo) {
				level = 0;
			} else {
				level = vipInfo.vip_level;
			}
			for (var i:int=0; i < level; i ++) {
				star = new Bitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"xing"));
				star.x = x;
				_starBg.addChild(star);
				x += 13;
			}
		}
	}
}