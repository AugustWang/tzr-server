package modules.deal
{
	

	public class DealConstant
	{
		public static const DEAL_NORMAL_CANCEL:int = 1;
		public static const DEAL_BATTLE_CANCEL:int = 2;
		public static const DEAL_SPACE_CANCEL:int = 3;
		
		public static const STALL_PRICE_TYPE_SILVER:int = 1;
		public static const STALL_PRCIE_TYPE_GOLD:int = 2;
		public static const STALL_PRICE_TYPE_SILVER_BIND:int = 3;
		
		
		public static const EMPLOY_P_HOUR:int = 10;      //　雇佣店小二，一小时花费　1　银子 = 100 文。
		                                                        
		public static const STALL_COST:int = 20;       //摆摊扣费 20 文
		
		public static var DEAL_ITEM_LEN:int = 0;
		
		public static var OVERDUE:Boolean = false ;  //是否过期，默认没过期
		
		public static var remain_time:int = 0 ; 
		
		public static const GOLD:String="GOLD";
		public static const GOLD_BIND:String="GOLD_BIND";
		public static const SILVER:String="SILVER";
		public static const SILVER_BIND:String="SILVER_BIND";
		
		
		public static const SELF_STALL_TIP:String = "亲自摆摊，交易税1%" +
			"\n雇佣店小二，练级、下线，都不用收摊。";
		
		/**
		 *
		 * @param sumMoney 传入文的总数
		 * @return 数组顺序：绽、两、文。 
		 * 
		 */		
		public static function silverToOther(sumMoney:int):Array
		{
			var arr:Array = [];
			var goldNum:String = int(sumMoney/10000).toString();
			var silverNum:String =  int(sumMoney%10000/100).toString();
			var coinNum:String = (sumMoney%10000%100).toString();
			arr.push(goldNum,silverNum,coinNum);
			return arr;
		}
		
		public static function silverToOtherString(sumMoney:int):String
		{
			var str:String = "";
			if(sumMoney == 0)
				return "0" + "文";
			
			var arr:Array = silverToOther(sumMoney);
			
			
			if(arr[0]>0)
			{
				str = arr[0] + "锭";
			}
			if(arr[1]>0)
			{
				str += arr[1] + "两";
			}
			if(arr[2]>0)
			{
				str += arr[2] + "文";
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
//				if(numColor == null)
//				{
//					if(wordColor == null)
//					{
//						str = arr[2] + "文";
//					}else{
//						
//						str = arr[2] + 
//							"<font color='"+ wordColor +"'>"+"文</font>";
//					}
//					
//					
//				}else{
//					if(wordColor == null)
//					{
//						str = "<font color='"+numColor +"'>"+arr[2] +"</font>" + 
//							"文";
//					}else{
//						
//						str = "<font color='"+numColor +"'>"+arr[2] +"</font>" + 
//							"<font color='"+ wordColor +"'>"+"文</font>";
//					}
//				}
				
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