package modules.mypackage.views
{
	import modules.mypackage.vo.BaseItemVO;

	/**
	 * 背包对外方法统一定义
	 */ 
	public interface IPack
	{
		function setGoods(items:Array):void;
		function updateGoods(pos:int,itemvo:BaseItemVO):void;
		function setLock(pos:int,lock:Boolean):void;
	}
}