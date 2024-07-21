package com.loaders.queueloader {

	public class LoaderItem {
		public static const SWF:String="swf";
		public static const FILE:String="file";
		public static const IMAGE:String="image";

		public var data:Object;
		public var url:String;

		public function LoaderItem() {
		}

		public function get type():String {
			//此处匹配如果需要更智能匹配，可以换成正则表达式
			var endFix:String=url.substr(-3, 3);
			endFix=endFix.toLowerCase();
			if (endFix == SWF) {
				return SWF;
			} else if (endFix == "xml" || endFix == "txt" || endFix == "lib" || endFix == "mcm" || endFix == "cms") {
				return FILE;
			} else if (endFix == "png" || endFix == "jpg") {
				return IMAGE;
			}
			throw new Error("非法文件类型！-->" + url + '-->' + endFix);
		}
	}
}