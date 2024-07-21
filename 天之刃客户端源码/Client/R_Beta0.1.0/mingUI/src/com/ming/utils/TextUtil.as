package com.ming.utils
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;

	/**
	 * 文本工具类 
	 * @author Administrator
	 * 
	 */
	public class TextUtil
	{
		/**
		 * 当TextField的宽度不够放入s时就会以...的形式省略 
		 * @param ts 文本域
		 * @param s 字符串
		 * @param maxW 最大宽度
		 * 
		 */		
		public static function fitText(ts:TextField, s:String, maxW:Number):void {
			const tf:TextField = ts;
			var len:int = s.length;
			ts.text = s;
			var tm:TextLineMetrics = tf.getLineMetrics(0);
			while (len > 0 && tm.width > maxW) {
				len = len - 2; 
				s = s.substr(0, len);
				ts.text = s + "…";
				tm = tf.getLineMetrics(0);
			}
			if (len <= 0) {
				ts.text = "";
			}
		}
		
		private static var text:TextField;
		private static var textformat:TextFormat;
		public static function getTextWidth(s:String,fontSize:int=12,fontBold:Boolean=false):Number{
			if(text == null){
				text = new TextField();
				textformat = new TextFormat();
			}
			textformat.size = fontSize;
			textformat.bold = fontBold;
			text.defaultTextFormat = textformat;
			text.text = s;
			return text.textWidth;
		}
	}
}