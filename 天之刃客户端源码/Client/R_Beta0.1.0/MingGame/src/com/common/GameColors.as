package com.common
{
	
	public class GameColors
	{
		
		public function GameColors()
		{
		}
		public static const COLOR_VALUES:Array=[0xffffff, 0xffffff, 0x12cc95, 0x0d79ff, 0xfe00e9, 0xff7e00, 0xFFD700];
		public static const HTML_COLORS:Array=["#ffffff", "#ffffff", "#12cc95", "#0d79ff", "#fe00e9", "#ff7e00", "#FFD700"];
		public static const white:Array=[1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0];
		public static const green:Array=[0, 0, 0, 0, 0, 0.8, 0, 0, 0, 0, 0.6, 0, 0, 0, 0, 0, 0, 0, 1, 0];
		public static const bule:Array=[0.25, 0, 0, 0, 0, 0.87, 0, 0, 0, 0, 0.97, 0, 0, 0, 0, 0, 0, 0, 1, 0];
		public static const purple:Array=[0.99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.91, 0, 0, 0, 0, 0, 0, 0, 1, 0];
		public static const orange:Array=[1, 0, 0, 0, 0, 0.49, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0];
		public static const glod:Array=[1, 0, 0, 0, 0, 0.84, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0];
		
		public static function getColorByIndex(index:int):uint
		{
			var color:uint=0xffffff;
			if (index >= 0 && index <= 6)
			{
				color=COLOR_VALUES[index];
			}
			else
			{
				throw new Error("颜色索引超出范围！");
			}
			return color;
		}
		
		public static function getHtmlColorByIndex(index:int):String
		{
			var color:String="#ffffff";
			if (index >= 0 && index <= 6)
			{
				color=HTML_COLORS[index];
			}
			else
			{
				throw new Error("颜色索引超出范围！");
			}
			return color;
		}
		
		public static function color(index:int):Array
		{
			var arr:Array;
			switch (index)
			{
				case 1:
					arr=white;
					break;
				case 2:
					arr=green;
					break;
				case 3:
					arr=bule;
					break;
				case 4:
					arr=purple;
					break;
				case 5:
					arr=orange;
					break;
				case 6:
					arr=glod;
					break;
				default:
					arr=white;
					break;
			}
			return arr;
		}
	}
}