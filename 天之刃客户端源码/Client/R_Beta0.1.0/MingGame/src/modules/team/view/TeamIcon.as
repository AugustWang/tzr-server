package modules.team.view {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.team.TeamDataManager;
	import modules.team.TeamMenuManager;

	public class TeamIcon extends Sprite {
		private var _txt:TextField;
		private var img:UIComponent;
		private var captain:Bitmap;
		private var _isCaptain:Boolean;
		private var menu:TeamMenuManager;

		public function TeamIcon() {
			super();

		}

		public function init():void {
			this.buttonMode=true;
			img=new UIComponent();
			img.width=70;
			img.height=25;
			img.bgSkin = Style.getButtonSkin("send_1skin", "send_2skin", "send_3skin", "", GameConfig.T1_UI, new Rectangle(5, 5, 18, 17));
			img.x=-img.width / 2 - 1;
			img.y=-img.height / 2;
			addChild(img);
			var textFormat:TextFormat=new TextFormat("Tahoma", 11, 0xffeecc);
			_txt=new TextField;
			_txt.defaultTextFormat=textFormat;
			_txt.mouseEnabled=false;
			_txt.autoSize=TextFieldAutoSize.CENTER;
			_txt.filters=Style.textBlackFilter;
			_txt.text="组队菜单▼";
			_txt.x=-_txt.width / 2 - 1;
			_txt.y=-_txt.height / 2 - 1;
			addChild(_txt);
			captain=Style.getBitmap(GameConfig.T1_VIEWUI,"Captain");
			captain.x=img.x + img.width ;
			captain.y=img.y + 5;
			captain.visible=false;
			addChild(captain);
			this.addEventListener(MouseEvent.CLICK, onClick);
			menu=TeamMenuManager.instance;
		}

		public function reFresh(isCaptain:Boolean):void {
			_isCaptain=isCaptain;
			captain.visible=_isCaptain;
		}

		private function onClick(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
			var pick_type:int=TeamDataManager.pickMode;
			if (pick_type == 1) {
				menu.freePickItem.label="√物品自由拾取";
				menu.turnPickItem.label="物品独自拾取";
				menu.freePickItem.enabled=false;
				menu.turnPickItem.enabled=true;
			} else if (pick_type == 2) {
				menu.freePickItem.label="物品自由拾取";
				menu.turnPickItem.label="√物品独自拾取";
				menu.freePickItem.enabled=true;
				menu.turnPickItem.enabled=false;
			}
			if (_isCaptain == true) {
				menu.show(TeamMenuManager.LEADER_SELF);
			} else {
				menu.show(TeamMenuManager.MEMBER_SELF);
			}
		}
	}
}