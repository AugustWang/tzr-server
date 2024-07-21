package com.scene.sceneData
{
	import com.scene.tile.Pt;

	public class MacroPathVo
	{
		private var _mapid:int;
		private var _pt:Pt;

		public function MacroPathVo(mapid:int, pt:Pt)
		{
			_mapid=mapid;
			_pt=pt;
		}

		public function set mapid(value:int):void
		{
			_mapid=value;
		}

		public function get mapid():int
		{
			return _mapid;
		}

		public function set pt(value:Pt):void
		{
			_pt=value;
		}

		public function get pt():Pt
		{
			return _pt;
		}
	}
}