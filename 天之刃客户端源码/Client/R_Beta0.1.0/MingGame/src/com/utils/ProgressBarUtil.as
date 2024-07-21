package com.utils
{
	public class ProgressBarUtil
	{
		public static function calculateScale(current:Number,total:Number):Number
		{
			var scale:Number = int((current/total)*100)/100;
			scale>1?scale=1:''
			scale<0?scale=0:''
			return scale;
		}
		
		public static function calculateTextScale(current:Number,total:Number):Number
		{
			var scale:Number = int((current/total)*100);
			scale>1?scale=1:''
			scale<0?scale=0:''
			return scale;
		}
	}
}