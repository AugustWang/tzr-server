package com.scene.sceneData
{
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneData.MapTransferVo;

	public class MapDataVo
	{
		/**
		 * 地图背景图坐标矫正值
		 */
		public static const CORRECT_VALUE:int=10000000;
		public var map_id:int
		public var isSub:int;
		public var name:String;
		/**
		 * 网格哈希表 ，放格子的
		 */
		public var tiles:Array;
		public var tileRow:int; //格子行数
		public var tileCol:int; //格子列数
		//		public var length:int;//格子总数
		/**
		 * 文件保存的地址
		 */
		public var url:String;
		public var offsetX:int; //背景偏移量
		public var offsetY:int;
		public var width:int; //地图宽高
		public var height:int;
		public var fileName:String;
		public var imageLink:String

		public var elements:Vector.<MapElementVo>
		public var transfers:Vector.<MapTransferVo>

		public function MapDataVo()
		{
			super();
		}

		public function toString():String
		{
			return '\n{地图数据文件}-[' + name + ']: ';
		}
	}
}