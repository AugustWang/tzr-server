package modules.pet.view {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.pet.config.PetConfig;
	
	import proto.common.p_pet_id_name;

	public class PetListRender extends UIComponent {
		private var text:TextField;
		private var vo:p_pet_id_name;

		public function PetListRender():void {
			mouseChildren=false;
			useHandCursor=true;
			buttonMode=true;
			var tf:TextFormat=new TextFormat(null, 12, 0xffffff);
			text=new TextField();

			text.defaultTextFormat=tf;
			text.selectable=false;
			text.height=36;
			text.y=2;
			text.x=5;
			var skin:Skin=StyleManager.listItemSkin;
			if (skin) {
				bgSkin=skin;
				bgSkin.height=34;
			}
			addChild(text);
			addEventListener(Event.ADDED, onAdded);
			var line:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y=25;
			line.width=146;
			addChild(line);

		}

		private function onAdded(event:Event):void {
			width=146;
			height=36;
		}

		public override function set data(value:Object):void {
			super.data=value;
			vo=value as p_pet_id_name;
			var skinid:int=PetConfig.getPetSkin(vo.type_id);
			if (vo != null) {
				text.htmlText=vo.name;
			} else {
				text.htmlText="";
			}
		}
	}
}