package modules.driver.vo
{
	public class DriverDataIndex
	{
		public function DriverDataIndex()
		{
		}
		
		static public const DRIVER_TARGET_DATA_MIN_LEVEL:int = 0;
		static public const DRIVER_TARGET_DATA_MAX_LEVEL:int = 1;
		static public const DRIVER_TARGET_DATA_COST:int = 2;//消耗银子
		static public const DRIVER_TARGET_DATA_COST_DES:int = 3;//消耗银子描述
		static public const DRIVER_TARGET_DATA_ABLED:int = 4;//这个数据为true标识是满足条件时允许传送 为false标识是满足条件时不允许传送
	}
}