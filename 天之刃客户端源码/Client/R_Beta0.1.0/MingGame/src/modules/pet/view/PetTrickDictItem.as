package modules.pet.view {
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;

	import flash.display.Sprite;
	import flash.text.TextField;

	public class PetTrickDictItem extends Sprite implements IDataRenderer {
		private var img:Image;
		private var txt:TextField;
		private var _data:Object;

		public function PetTrickDictItem() {
			super();
			img=new Image;
			addChild(img);
			txt=ComponentUtil.createTextField("", 33, 5, Style.textFormat, 150, 22, this);
		}

		public function set data(obj:Object):void {
			img.source=GameConfig.ROOT_URL + "com/assets/skills/" + obj.id + ".png";
			txt.text=obj.name;
			_data=obj;
		}

		public function get data():Object {
			return _data;
		}
	}
}