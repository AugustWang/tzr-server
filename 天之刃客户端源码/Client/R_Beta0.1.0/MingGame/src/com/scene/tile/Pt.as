package com.scene.tile
{
	

	/**
	 *  <br>等角坐标系3维数据的点
	 * 	<br>这是等角坐标系主程的基础部分
	 * @author sai
	 * @playerversion flashplayer 10
	 */	
	public class Pt
	{
		/**
		 *@private 
		 * 等角坐标系x 
		 */		
		private var _x:Number;
		/**
		 *@private
		 * 等角坐标系y轴 
		 */		
		private var _y:Number;
		/**
		 *@private
		 * 等角坐标系z轴 
		 */		
		private var _z:Number;
		private var _key:String;
		
		public function Pt(x:Number=0,y:Number=0,z:Number=0)
		{
			this._x=x;
			this._y=y;
			this._z=z
			_key=_x+'|'+this._y+'|'+this._z
		}
		public function get key():String
		{
			return _key
			
		}
		public function toString():String
		{
			return '[Pt('+this._x+','+this._y+','+this._z+')]'
		}
		/**
		 * 等角坐标系z轴； 
		 * @return 
		 * 
		 */		
		public function get z():Number
		{
			return _z;
		}

		public function set z(value:Number):void
		{
			_z = value;
			_key=this._x+'|'+this._y+'|'+this._z
		}
		/**
		 * 等角坐标系x轴 
		 * @return 
		 * 
		 */		
		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
			_key=this._x+'|'+this._y+'|'+this._z
		}
		/**
		 * 等角坐标系y轴 
		 * @return 
		 * 
		 */		
		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
			_key=this._x+'|'+this._y+'|'+this._z
		}
		public static  function distance(pt1:Pt,pt2:Pt):Number
		{
			var x:Number=Math.pow(2,(pt1.x-pt2.x))
			var y:Number=Math.pow(2,(pt1.z-pt2.z))
			return Math.sqrt(x+y)
		}
	}
}