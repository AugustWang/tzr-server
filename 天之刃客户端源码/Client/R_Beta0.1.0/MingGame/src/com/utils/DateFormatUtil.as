package com.utils
{
	
	public class DateFormatUtil
	{
		
		public function DateFormatUtil()
		{
		}
		
		public static function formatHours(time:int):String
		{
			var date:Date=new Date();
			date.time=time * 1000;
			var timeString:String="";
			var hour:int=date.getHours();
			if (hour < 10)
			{
				timeString+="0" + hour.toString();
			}
			else
			{
				timeString+="" + hour;
			}
			
			var minutes:int=date.getMinutes();
			if (minutes < 10)
			{
				timeString+=":0" + minutes.toString();
			}
			else
			{
				timeString+=":" + minutes;
			}
			
			var seconds:int=date.getSeconds();
			if (seconds < 10)
			{
				timeString+=":0" + seconds.toString();
			}
			else
			{
				timeString+=":" + seconds;
			}
			
			return timeString;
		}
		
		//格式化为 00:00这种
		public static function formatHM(time:int):String
		{
			var date:Date=new Date();
			date.time=time * 1000;
			var timeString:String="";
			var hour:int=date.getHours();
			if (hour < 10)
			{
				timeString+="0" + hour.toString();
			}
			else
			{
				timeString+="" + hour;
			}
			
			var minutes:int=date.getMinutes();
			if (minutes < 10)
			{
				timeString+=":0" + minutes.toString();
			}
			else
			{
				timeString+=":" + minutes;
			}
			
			return timeString;
		}
		
		public static function formatTime(totalSeconds:int):String
		{
			var hour:int=int(totalSeconds / 3600);
			var minutes:int=int((totalSeconds-hour*3600)/60);
			var seconds:int=(totalSeconds-hour*3600)%60
			var time:String="";
			if (hour >= 0 && hour < 10)
			{
				time+="0" + hour+":";
			}
			else if (hour >= 10)
			{
				time+=hour+":";
			}
			if (minutes < 10)
			{
				time+="0" + minutes;
			}
			else
			{
				time+=minutes;
			}
			
			if (seconds < 10)
			{
				time+=":0" + seconds;
			}
			else
			{
				time+=":" + seconds;
			}
			return time;
		}
		
		public static function format(totalSeconds:int):String
		{
			var date:Date=new Date();
			date.time=totalSeconds * 1000;
			var timeString:String=date.getFullYear() + "-";
			var month:int=date.getMonth() + 1;
			if (month < 10)
			{
				timeString+="0" + month.toString() + "-";
			}
			else
			{
				timeString+=month + "-";
			}
			var day:int=date.getDate();
			if (day < 10)
			{
				timeString+="0" + day.toString() + " ";
			}
			else
			{
				timeString+=day + " ";
			}
			var hour:int=date.getHours();
			if (hour < 10)
			{
				timeString+="0" + hour.toString();
			}
			else
			{
				timeString+="" + hour;
			}
			
			var minutes:int=date.getMinutes();
			if (minutes < 10)
			{
				timeString+=":0" + minutes.toString();
			}
			else
			{
				timeString+=":" + minutes;
			}
			
			var seconds:int=date.getSeconds();
			if (seconds < 10)
			{
				timeString+=":0" + seconds.toString();
			}
			else
			{
				timeString+=":" + seconds;
			}
			return timeString;
		}
		
		public static function formatTickToCNTimes(totalSeconds:int):String
		{
			var hour:int=int(totalSeconds / 3600);
			var minutes:int=int((totalSeconds-hour*3600)/60);
			var seconds:int=(totalSeconds-hour*3600)%60
			var time:String="";
			if (hour > 0)
			{
				time+= hour + "小时 ";
			}
			if (minutes == 0)
			{
				time+="00分 ";
			}
			else if (minutes < 10)
			{
				time+="0" + minutes + "分 ";
			}
			else
			{
				time+=minutes + "分 ";
			}
			
			if (seconds == 0)
			{
				time+="00秒 ";
			}
			else if (seconds < 10)
			{
				time+="0" + seconds + "秒";
			}
			else
			{
				time+= + seconds + "秒";
			}
			return time;
		}
		
		
		public static function formatPassDate(totalSeconds:int):String
		{
			var date:Date=new Date();
			date.time=totalSeconds * 1000;
			var timeString:String=date.getFullYear() + "-";
			var month:int=date.getMonth() + 1;
			if (month < 10)
			{
				timeString+="0" + month.toString() + "-";
			}
			else
			{
				timeString+=month + "-";
			}
			var day:int=date.getDate();
			if (day < 10)
			{
				timeString+="0" + day.toString() + " ";
			}
			else
			{
				timeString+=day + " ";
			}
			var hour:int=date.getHours();
			if (hour < 10)
			{
				timeString+="0" + hour.toString();
			}
			else
			{
				timeString+="" + hour;
			}
			timeString += "时";
			return timeString;
		}
		
		public static function secToDateCn(totalSeconds:int):String
		{
			var date:Date=new Date();
			date.time=totalSeconds * 1000;
			var timeString:String=date.getFullYear() + "年";
			var month:int=date.getMonth() + 1;
			if (month < 10)
			{
				timeString+="0" + month.toString() + "月";
			}
			else
			{
				timeString+=month + "月";
			}
			var day:int=date.getDate();
			if (day < 10)
			{
				timeString+="0" + day.toString() + "日 ";
			}
			else
			{
				timeString+=day + "日 ";
			}
			var hour:int=date.getHours();
			if (hour < 10)
			{
				timeString+="0" + hour.toString();
			}
			else
			{
				timeString+="" + hour;
			}
			
			var minutes:int=date.getMinutes();
			if (minutes < 10)
			{
				timeString+=":0" + minutes.toString();
			}
			else
			{
				timeString+=":" + minutes;
			}
			
			return timeString;
		}
		
		public static function addHours(date:Date,hours:Number = 0):Date
		{
			date.hours = date.hours + hours;
			return date;
		}
		
		public static function getDefaultDateString(date:Date,needTime:Boolean = true):String
		{
			var year:String = date.fullYear + "";
			var month:String = addZero((date.month + 1) + "");
			var dayOfMonth:String = addZero(date.date + "");
			var hours:String = addZero(date.hours + "");
			var min:String = addZero(date.minutes + "");
			var sec:String = addZero(date.seconds + "");
			if(needTime)
			{
				return year + "-" + month + "-" + dayOfMonth + " " + hours + ":" + min + ":" + sec;
			}
			else
			{
				return year + "-" + month + "-" + dayOfMonth;
			}
		}
		
		private static function addZero(str:String):String
		{
			if(str.length == 1)
			{
				str = "0" + str;
			}
			return str;
		}
		
		public static function addSeconds(date:Date,seconds:Number = 0):Date
		{
			date.seconds = date.seconds + seconds;
			return date;
		}
		
		public static function getHMBysecond(second:Number,division:String = ":"):String
		{
			var result:String = "";
			
			var time:Number = int(second)*1000;
			var date:Date = new Date(time);
			//  trace("time (second):"+time);
			//  trace(date.getTime());
			var m:String;
			
			result = String(date.hours) + division;
			m = String(date.getMinutes());
			if(m.length <2)
			{
				m = "0"+m;
			}
			result += m;
			
			return result;
		}
		
		public static function getSubDate(a:Date,b:Date):Number
		{
			var newA:Date = clearHourse(a);
			var newB:Date = clearHourse(b); 
			return Math.abs(Math.round((newA.time - newB.time)/(24 * 3600 * 1000)));
		}
		
		public static function clearHourse(date:Date):Date
		{
			var result:Date = new Date(date.time);
			result.hours = result.minutes = result.seconds = 0;
			return result;	
		}
		
		public static var dayStrings:Array = ["星期日","星期一","星期二","星期三","星期四","星期五","星期六"];
	}
}