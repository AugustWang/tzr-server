package modules.forgeshop.views.items
{
	import proto.line.p_equip_build_equip;

	public class EquipExtendProto
	{
		private var _build_equip:p_equip_build_equip;
		
		private var _level:int;  //装备等级段
		
		private var _base_list:Array = new Array();  //背包拥有基本材料的数量
		
		
		public function EquipExtendProto()
		{
		}

		public function get build_equip():p_equip_build_equip
		{
			return _build_equip;
		}

		public function set build_equip(value:p_equip_build_equip):void
		{
			_build_equip = value;
		}

		public function get level():int
		{
			return _level;
		}

		public function set level(value:int):void
		{
			_level = value;
		}

		public function get base_list():Array
		{
			return _base_list;
		}

		public function set base_list(value:Array):void
		{
			_base_list = value;
		}

	}
}