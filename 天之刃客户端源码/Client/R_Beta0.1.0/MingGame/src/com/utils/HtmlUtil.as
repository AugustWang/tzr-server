package com.utils {

	/**
	 *
	 * HtmlUtil 工具类
	 */
	public class HtmlUtil {
		public function HtmlUtil() {
		}
		
		public static function wapper(name:String,data:Object,nameColor:String="#ffffff",textColor:String="#ffffff",space:String=""):String{
			return font(name,nameColor)+fontBr(space+data.toString(),textColor);
		}

		public static function fontBr(content:String, color:String, size:int=12):String {
			return font(content, color, size) + "\n";
		}

		public static function font(content:String, color:String, size:int=12):String {
			return "<font color='" + color + "' size='" + size + "'>" + content + "</font>";
		}

		public static function font2(content:String, color:uint, size:int=12):String {
			return font(content, "#" + color.toString(16));
		}

		public static function font3(content:String, color:String):String {
			return "<font color='" + color + "'>" + content + "</font>";
		}

		public static function br(content:String):String {
			return "<br>" + content + "</br>";
		}

		public static function bold(content:String):String {
			return "<b>" + content + "</b>";
		}

		public static function link(content:String, params:String="", underline:Boolean=false):String {
			if (underline) {
				return "<u><a href='event:" + params + "'>" + content + "</a></u>";
			}
			return "<a href='event:" + params + "'>" + content + "</a>";
		}

		public static function filterHtml(content:String):String {
			var result:String=content.replace(/\<\/?[^\<\>]+\>/gmi, "");
//			result = result.replace(/[\r\n ]+/g, ""); 
			return result;
		}
	}
}