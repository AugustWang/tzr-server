package com.scene.tile
{
	/**
	 *  为Tile包成员提供静态常量或变量
	 * @author Sai
	 * @playerversion flashplayer 10
	 */	
	public class TileConstant
	{
		/**
		 * Cell单元格类型数据--不可走类型  
		 * @see com.engine.core.tile.Cell
		 */		
		public static const BLOCK_TYPE:int=0;
		/**
		 * Cell单元格类型数据--可走类型  
		 * @see com.engine.core.tile.Cell
		 */
		public static const ROAD_TYPE:int=1;
		/**
		 * Cell大小静态变量
		 * @see com.engine.core.tile.Cell
		 */
		public static var TILE_SIZE:int=44;
		/**
		 *等角坐标系左方向 
		 */		
		public static const  LEFT:int=-1;
		/**
		 *等角坐标系右方向 
		 */		
		public static const RIGHT:int=1;
			
		
	}
}