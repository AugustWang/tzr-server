package modules.npc.views {
	import com.globals.GameConfig;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.npc.NPCConstant;

	public class NPCLinkItem extends Sprite {
		private var icon:Bitmap;
		private var labelText:TextField;
		private var skin:Skin;

		public function NPCLinkItem() {
			init();
		}

		private function init():void {
			mouseChildren=false;
			useHandCursor=buttonMode=true;

			skin=Style.getSkin("listItemOver",GameConfig.T1_UI,new Rectangle(4,4,154,10));
			skin.x = 15;
			skin.width = 220;
			skin.visible=false;
			addChild(skin);
			
			icon=new Bitmap();
			icon.x = 15;
			addChild(icon);
			var tf:TextFormat=new TextFormat();
			tf.color = 0xffff00;
			
			labelText=ComponentUtil.createTextField("", 35, 0, tf, 220, 20, this);
			labelText.multiline = true;
			labelText.wordWrap = true;
			labelText.autoSize = TextFieldAutoSize.LEFT;
			labelText.filters=[Style.BLACK_FILTER];
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}

		private var _icon_style:Number;

		public function get iconStyle():Number {
			return _icon_style;
		}

		public function set iconStyle(value:Number):void {
			_icon_style=value;
			layout();
		}

		private var _data:Object;

		public function set data(value:Object):void {
			_data=value;
		}

		public function get data():Object {
			return _data;
		}

		private var _label:String;

		public function set label(value:String):void {
			_label=value;
			layout();
		}

		public function get label():String {
			return _label;
		}

		private var _selected:Boolean;

		public function set selected(value:Boolean):void {
			_selected=value;
			layout();
			skin.visible=true;
		}

		public function get selected():Boolean {
			return _selected;
		}

		private function layout():void {
			if (label) {
				labelText.htmlText=label;
				createIcon();
			}
		}

		private function createIcon():void {
			switch (this.iconStyle) {
				
				case NPCConstant.LINK_ICON_STYLE_MISSION_ACCEPT:
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"npc_tanhao");
					icon.y = 1.5;
					break;
				
				case NPCConstant.LINK_ICON_STYLE_MISSION_NEXT:
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"npc_diandian");
					icon.y = 1.5;
					break;
				
				case NPCConstant.LINK_ICON_STYLE_MISSION_FINISH:
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"npc_wenhao");
					icon.y = 1.5;
					break;
				
				case NPCConstant.LINK_ICON_STYLE_MISSION_ANSWER:
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"deng_pao");
					icon.y = 1.5;
					break;
				
				default:
					icon.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"npc_fun_icon");
					icon.y = 1.5;
					break;
			}
		}

		private function onMouseOut(param1:MouseEvent):void {
			if (_selected == false) {
				skin.visible=false;
			}
		}

		private function onMouseOver(param1:MouseEvent):void {
			if (_selected == false) {
				skin.visible=true;
			}
		}

	}
}