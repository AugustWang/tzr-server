package com.utils
{
	public class MoneyTransformUtil
	{
		/**
		 *
		 * @param sumMoney 传入文的总数
		 * @return 数组顺序：绽、两、文。 
		 * 
		 */		
		public static function silverToOther(sumMoney:Number):Array
		{
			var arr:Array = [];
			var goldNum:String = Math.floor(sumMoney/10000).toString();
				//int(sumMoney/10000).toString();
			var silverNum:String =  int(sumMoney%10000/100).toString();
			var coinNum:String = (sumMoney%10000%100).toString();
			arr.push(goldNum,silverNum,coinNum);
			return arr;
		}
		
		public static function silverToOtherString(sumMoney:Number):String
		{
			var str:String = "";
			if(sumMoney <= 0)
				return "0" + "文";
			var arr:Array = silverToOther(sumMoney);
			
			if(arr[0]>0)
			{
				str = arr[0] + "锭";//int(arr[0]) + "锭";
			}
			if(arr[1]>0)
			{
				str += int(arr[1]) + "两";
			}
			if(arr[2]>0)
			{
				str += int(arr[2]) + "文";
			}
			return str;
		}
		
		public static function silverToOtherHtml(sumMoney:int,numColor:String="#ffffff",wordColor:String="#ffffff"):String
		{
			var str:String = "";
			if(sumMoney == 0)
			{
				str = "<font color='"+numColor +"'>"+ "0" +"</font>" + 
					"<font color='"+ wordColor +"'>"+"文</font>";
				return str;
			}
			
			var arr:Array = silverToOther(sumMoney);
			
			if(arr[0]>0)
			{
				str = "<font color='"+numColor +"'>"+arr[0] +"</font>" + 
					"<font color='"+ wordColor +"'>"+"锭</font>";
			}
			if(arr[1]>0)
			{
				str += "<font color='"+numColor +"'>"+arr[1] +"</font>" + 
					"<font color='"+ wordColor +"'>"+"两</font>";
				
			}
			if(arr[2]>0)
			{
				str += "<font color='"+numColor +"'>"+arr[2] +"</font>" + 
					"<font color='"+ wordColor +"'>"+"文</font>";
			}
			return str;
		}
		
		/**
		 * 
		 * @param value1 绽
		 * @param value2 两
		 * @param value3 文
		 * @return 返回文的总数
		 * 
		 */		
		public static function otherToSilver(value1:int,value2:int,value3:int):int
		{
			var sum:int = value1 * 10000 + value2 * 100 + value3 
			return sum;
		}
	}
}