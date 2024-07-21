package modules.countrytreasure.views
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.ming.core.IDataRenderer;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import proto.line.p_country_points;
	
	public class CountryPointsItem extends Sprite implements IDataRenderer
	{
		private var _vo:p_country_points;
		private var factionName:TextField;
		private var points:TextField;
		
		public function CountryPointsItem()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			factionName = new TextField;
			addChild(factionName);
			
			points = new TextField;
			points.x = 96;
			addChild(points);
		}
		
		public function get data():Object
		{
			return _vo;
		}
		
		public function set data(value:Object):void
		{
			var vo:p_country_points = p_country_points(value);
			_vo = vo;
			
			if (vo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id) {
				factionName.textColor = 0x00ff00;
				points.textColor = 0x00ff00;
			} else {
				factionName.textColor = 0xff0000;
				points.textColor = 0xff0000;
			}
			factionName.text = GameConstant.getNation(vo.faction_id);
			points.text = vo.points + " ";
		}
	}
}