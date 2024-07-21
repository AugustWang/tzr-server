package com.common
{
	import flash.text.TextFormat;
	
	public class Constant
	{
		public static const COLOR_RED:uint =  0xff0000;     //红色
		public static const COLOR_PURPLE:uint = 0xB726B7;  //紫色
		public static const COLOR_GREEN:uint = 0x00ff00;   //绿色
		public static const COLOR_BLUE:uint = 0x0000ff;    //蓝色
		public static const COLOR_YELLOW:uint = 0xffff00;   //黄色
		public static const COLOR_BLACK:uint = 0x000000;   //黑色
		public static const COLOR_WHILE:uint = 0xffffff;   //白色
		
		
		
		public static const TEXTFORMAT_DEFAULT: TextFormat = new TextFormat(null, 12, COLOR_WHILE);//默认
		public static const TEXTFORMAT_COLOR_GREEN: TextFormat = new TextFormat(null, 12, COLOR_GREEN); 
		public static const TEXTFORMAT_COLOR_RED: TextFormat = new TextFormat(null, 12, COLOR_RED); 
		public static const TEXTFORMAT_COLOR_BLACK: TextFormat = new TextFormat(null, 12, COLOR_BLACK); 
		public static const TEXTFORMAT_COLOR_BLUE: TextFormat = new TextFormat(null, 12, COLOR_BLUE); 		
		public static const TEXTFORMAT_COLOR_GRAY: TextFormat = new TextFormat(null, 12, 0x7B7B7B); //灰色
		
		public static const TEXTFORMAT_COLOR_GRAYYELLOW: TextFormat = new TextFormat(null, 12, 0xE6CE6C);
		
		//灰黄色
		
		// 攻击模式
		public static const PEACE:int=0;
		public static const ALL:int=1;
		public static const TEAM:int=2;
		public static const FAMILY:int=3;
		public static const FACTION:int=4;
		public static const KINDEVIL:int=5;
		
		public function Constant()
		{
		}
	}
}