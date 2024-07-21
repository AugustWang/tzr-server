package com.scene.tile
{

	import flash.geom.Point;

	/**
	 * 等角坐标系于平面坐标系的换算工具类
	 * @author Sai
	 * @playerversion flashplayer 10
	 */
	public class TileUitls
	{
		/**
		 * 等角坐标与平面转换的矫正值
		 */
		public static const CORRECT_VALUE:Number=Math.cos(-Math.PI / 6) * Math.SQRT2;

		/**
		 * 角度转弧度
		 * @param angle
		 * @return
		 *
		 */
		public static function angleToradian(angle:Number):Number
		{
			return angle * 180 / Math.PI * angle;
		}

		/**
		 * 弧度转角度
		 * @param radian
		 * @return
		 *
		 */
		public static function radianToangle(radian:Number):Number
		{
			return radian * Math.PI / 180 * radian
		}

		/**
		 * 将等角坐标系点转换为平面坐标系的点
		 * @param pos
		 * @return
		 * @see com.engine.core.tile.Pt
		 *
		 */
		public static function isoToFlat(pt:Pt):Point
		{
			var x:Number=pt.x - pt.z;
			var y:Number=pt.y * CORRECT_VALUE + (pt.x + pt.z) * .5;
			return new Point(x, y);
		}


		/**
		 *	将一个平面坐标点转换为等角坐标系的pt点
		 * @param point 一个平面点
		 * @param height 高度等于等角坐标系的z轴值
		 * @return
		 * @see com.engine.core.tile.Pt
		 */
		public static function flatToIso(point:Point, height:Number=0):Pt
		{
			var x:Number=point.y + point.x * .5;
			var y:Number=height;
			var z:Number=point.y - point.x * .5;
			return new Pt(x, y, z);
		}

		/**
		 * 将一个指定单元格大小的索引转换为平面点
		 * @param pt
		 * @param size 单元格大小
		 * @return
		 * @see com.engine.core.tile.Pt
		 * @see com.engine.core.tile.TileConstant
		 *
		 */
		public static function indexToFlat(pt:Pt, size:Number=-1):Point
		{
			if (size == -1)
				size=TileConstant.TILE_SIZE;
			var x:Number=pt.x - pt.z;
			var y:Number=pt.y * CORRECT_VALUE + (pt.x + pt.z) * .5;
			return new Point(x * size, y * size)
		}

		/**
		 * 获取指定大小方格的索引
		 * @param point 平面坐标
		 * @param size  单元格大小（面积）
		 * @param height 高度
		 * @return
		 * @see com.engine.core.tile.Pt
		 *
		 */
		public static function getIndex(point:Point, size:Number=-1, height:Number=0):Pt
		{
			if (size == -1)
				size=TileConstant.TILE_SIZE;
			var pt:Pt=flatToIso(point, height)
			pt.x=Math.floor(pt.x / size);
			pt.y=Math.floor(pt.y / size);
			pt.z=Math.floor(pt.z / size);
			return pt
		}

		/**
		 * 将一个等角坐标系点转换为索引
		 * @param pt
		 * @return
		 * @see com.engine.core.tile.Pt
		 * @see com.engine.core.tile.TileConstant
		 */
		public static function isoToIndex(pt:Pt, size:int=-1):Pt
		{
			if (size == -1)
				size=TileConstant.TILE_SIZE;
			var pt2:Pt=new Pt(Math.floor(pt.x / size), Math.floor(pt.y / size), Math.floor(pt.z / size))
			return pt2
		}

		/**
		 * 旋转一次视角
		 * @param cameraIndex 旋转轴索引
		 * @param index 要旋转的点
		 * @param dir 旋转方向为左--TileConstant.LEFT -1， 右--TileConstant.RIGHT 1
		 * @return
		 * @see com.engine.core.tile.Pt
		 * @see com.engine.core.tile.TileConstant
		 * @private
		 */
		private static function whirlPrivate(cameraIndex:Pt, index:Pt, dir:int=-1):Pt
		{

			var x:Number=index.x - cameraIndex.x;
			var y:Number=index.z - cameraIndex.z
			var radius:Number=Math.sqrt(x * x + y * y)
			var angle2:Number=Math.atan2(x, y)
			var u:Number=Math.round(cameraIndex.x + Math.sin(dir * Math.PI * .5 + angle2) * radius);
			var v:Number=Math.round(cameraIndex.y + Math.cos(dir * Math.PI * .5 + angle2) * radius)
			var point:Pt=new Pt(u, 0, v);
			return point
		}

		/**
		 * 按指定方向旋转1次或多次
		 * @param camerIndex 旋转轴索引
		 * @param index  要旋转的点
		 * @param dir 旋转方向为左--TileConstant.LEFT -1， 右--TileConstant.RIGHT 1
		 * @param time 旋转次数
		 * @return
		 * @see com.engine.core.tile.Pt
		 * @see com.engine.core.tile.TileConstant
		 *
		 */
		public static function whirl(camerIndex:Pt, index:Pt, time:int=1, dir:int=-1):Pt
		{
			var p:Pt=index;
			for (var i:int=0; i < time; i++)
				p=whirlPrivate(camerIndex, p, dir);
			return p;
		}

		public static function getIsoIndexMidVertex(pt:Pt):Point
		{
			var p:Point=indexToFlat(pt)
			return new Point(p.x, p.y + TileConstant.TILE_SIZE / 2)
		}

		public static function getMidPoint(p:Point):Point
		{
			var pt:Pt=getIndex(p);
			var center:Point=getIsoIndexMidVertex(pt);
			return center;
		}
	}
}