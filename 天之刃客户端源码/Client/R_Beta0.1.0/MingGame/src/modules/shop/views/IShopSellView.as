package modules.shop.views
{
	import flash.events.IEventDispatcher;
	
	public interface IShopSellView extends IEventDispatcher
	{
		function set dataProvider(values:Array):void;
		function set pageCount(value:int):void;
	}
}