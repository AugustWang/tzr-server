package modules.system
{
	import flash.events.IOErrorEvent;
	
	/**
	 * 防沉迷 
	 * 
	 * 
	 */	
	public class Anti_addiction
	{
		public static const OPEN_VIEW:String = "openView";
		public var complete:Function;
		public var error:Function;
		
		public function Anti_addiction()
		{
		}
		
		public function timeFormat(time:Number):String{
			var minutes:String = (int(time/60%60)).toString(); 
			var hours:String = (int(time/60/60)).toString(); 
			if(int(hours) == 0)return minutes + '分钟';
			if(int(hours) != 0 && int(minutes)== 0)return hours + '小时';
			return hours + '小时' + minutes + '分钟';
		}
		
		public function createMsg():String{
			return ''
		}
		
		//账号名
		//		身份证
		//		真实姓名
		private var card:String;
		public function check(id:String, name:String):void{
			var card:String = id.replace(/\s/g,"");
			if (!this.validationCard(card)) {
				error("身份证填写错误，请检查确认");
			} else {
				var realName:String = name.replace(/\s/g,"");
				var reg:RegExp = /^[\u4e00-\u9fa5]+$/;
				if (!reg.test(realName)) {
					error("姓名必须全部为汉字");
					return;
				} 
				if (realName.length < 2) {
					error("姓名长度至少为2");
					return;
				}
				if (realName.length > 6) {
					error("姓名长度不能超过6个汉字");
					return;
				}
				SystemModule.getInstance().setFCM(card,realName);
			}
		}
		
		public function ming2_fcmHandler(value:String):void{
			if(value == '1'){
				complete()
			}else{
				error(value)
			}
		}
				
		public function urlLoaderError(event:IOErrorEvent):void{
			error('连接错误!');
		}
		
		/**
		 * 判断身份证是否合法
		 * @param string card
		 * @return bool
		 */
		private function validationCard(card:String):Boolean {
			var born:String = card.slice(6, 14);
			var year:int = int(card.slice(6, 10));
			var month:int = int(card.slice(10, 12));
			var day:int = int(card.slice(12, 14));
			if (month > 12 || month < 1) {
				return false;
			}
			if (day > 31 || day < 1) {
				return false;
			}
			var date:Date = new Date;
			if (date.fullYear - year < 18) {
				return false;
			}
			if (year < 1900) {
				return false;
			}
//			// http://zh.wikipedia.org/zh-cn/%E4%B8%AD%E5%8D%8E%E4%BA%BA%E6%B0%91%E5%85%B1%E5%92%8C%E5%9B%BD%E5%85%AC%E6%B0%91%E8%BA%AB%E4%BB%BD%E5%8F%B7%E7%A0%81
//			var iW:Array = new Array(7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2,1);
//			var iSum:int = 0;
//			for(var i:int=0; i<17; i++) {
//				var tempI:int = int(card.charAt(i));
//				iSum += tempI * iW[i];
//			}
//			var iJYM:int = iSum % 11;
//			var sJYM:String = '';
//			if (iJYM == 0) {
//				sJYM = "1";
//			} else if (iJYM == 1) {
//				sJYM = "0";
//			} else if (iJYM == 2) {
//				sJYM = "x";
//			} else if (iJYM == 3) {
//				sJYM = "9";
//			} else if (iJYM == 4) {
//				sJYM = "8";
//			} else if (iJYM == 5) {
//				sJYM = "7";
//			} else if (iJYM == 6) {
//				sJYM = "6";
//			} else if (iJYM == 7) {
//				sJYM = "5";
//			} else if (iJYM == 8) {
//				sJYM = "4";
//			} else if (iJYM == 9) {
//				sJYM = "3";
//			} else if (iJYM == 10) {
//				sJYM = "2";
//			}
//			if (card.charAt(17).toLowerCase() != sJYM) {
//				return false;
//			}
			return true;
		}
	}
}