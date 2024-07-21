package modules.warOfCity.view
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.layout.LayoutUtil;
	import com.scene.WorldManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.line.p_warofcity;
	
	public class WarCityItem extends Sprite implements IDataRenderer
	{
		public static const EVENT_SIGN_UP:String="EVENT_SIGN_UP";
		private var pvo:p_warofcity;
		private var map_map:TextField;
		private var family_name:TextField;
		private var cost:TextField;
		private var level:TextField;
		private var sign:TextField;
		
		public function WarCityItem()
		{
			var tf:TextFormat=Style.textFormat;
			tf.align="center";
			map_map=ComponentUtil.createTextField("", 0, 0, tf, 108, 22, this);
			family_name=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			cost=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			level=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			sign=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			LayoutUtil.layoutHorizontal(this);
			sign.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void
		{
			var uie:UIEvent=new UIEvent(EVENT_SIGN_UP, true, false, pvo.map_id);
			this.dispatchEvent(uie);
		}
		
		public function set data(obj:Object):void
		{
			pvo=obj as p_warofcity;
			var mapName:String=WorldManager.getMapName(vo.map_id);
			map_map.text=mapName;
			family_name.text=pvo.family_name;
			cost.text="2";
			level.text="2";
			sign.text=pvo.family_id > 0 ? "申请挑战" : "申请占领";
		}
		
		public function get data():Object
		{
			return pvo;
		}
	}
}
