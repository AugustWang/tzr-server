package modules.warehouse
{
	import com.utils.MoneyTransformUtil;

	public class WarehouseActionType
	{
		
		
		public function WarehouseActionType()
		{
		}
		
		private static const depot2:int = 1000;  //单位 文
		private static const depot3:int = 10000;
		private static const depot4:int = 100000;
		
		
		public static function btn_num_To_cn(i:int):String
		{
			var str:String = "";
			switch(i)
			{
				case 1:
					str = "一"
					break;
				case 2:
					str = "二"
					break;
				case 3:
					str = "三"
					break;
				case 4:
					str = "四"
					break;
				case 5:
					str = "五";
					break;
				case 6:
					str = "六";
					break;
				
				default: break;
			}
			return str;
		}
		public static function newDepotMoney(id:int):String //开通下一级仓库所需的银子描述。
		{
			var str:String="";
			
			switch(id)
			{
				case 2:
					str = "开通第2个仓库价格" +
						MoneyTransformUtil.silverToOtherString(depot2) +
						"银子";
					break;
				case 3:
					str = "开通第3个仓库价格" +
						MoneyTransformUtil.silverToOtherString(depot3) +
						"银子";
					break;
				case 4:
					str = "开通第4个仓库价格" +
						MoneyTransformUtil.silverToOtherString(depot4) +
						"银子";
					break;
				default : break;
			}
			
			return str;
		}
		
		
	}
}