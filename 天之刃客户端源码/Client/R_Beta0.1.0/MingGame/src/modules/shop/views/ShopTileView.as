package modules.shop.views
{
	import com.events.ParamEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import modules.shop.ShopConstant;
	
	public class ShopTileView extends Sprite implements IShopSellView
	{
		public var VPADDING:int = -3;
		public var HPADDING:int = 0;
		
		private var inited:Boolean = false;
		private var shopGoodsItems:Array;
		private var perPageCount:int;
		public function ShopTileView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private var _rows:int = 4;
		public function set rows(value:int):void{
			if(value != _rows){
				this._rows = value;
			}
		}
		
		public function get rows():int{
			return _rows;
		}
		
		private var _columns:int = 3;
		public function set columns(value:int):void{
			if(value != _columns){
				this._columns = value;
			}
		}
		
		public function get columns():int{
			return _columns;
		}
		
		private var _dataProvider:Array;
		public function set dataProvider(values:Array):void{
			_dataProvider = values == null ? [] : values;
			if(inited == false){
				addedToStageHandler(null);
			}
			perPageCount = _rows*_columns;
			var size:int = _dataProvider ? _dataProvider.length : 0;
			totalCount = size%perPageCount == 0 ? size/perPageCount : size/perPageCount+1;
		}
		
		public function get dataProvider():Array{
			return _dataProvider;
		}
			
		private function addedToStageHandler(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			initView();
			inited = true;
		}
		
		private var _pageCount:int;
		public function set pageCount(value:int):void{
			_pageCount = value;
			renderItems();
		}
		
		public function get pageCount():int{
			return _pageCount;	
		}
		
		private var _totalCount:int = 1;
		public function set totalCount(value:int):void{
			_totalCount = value;
			dispatchEvent(new ParamEvent(ShopConstant.SHOP_PAGE_CHANGED,_totalCount,true));
		}
		
		public function get totalCount():int{
			return _totalCount;	
		}
		
		private function initView():void{
			dispose();
			var totalCount:int = _columns*_rows;
			shopGoodsItems = new Array(totalCount);
			for(var i:int=0;i<totalCount;i++){
				createItem(i);
			}
		}
		
		protected function renderItems():void{
			var start:int = (pageCount-1)*perPageCount;
			var end:int = Math.min(start+perPageCount,_dataProvider.length);
			var pageDatas:Array = _dataProvider.slice(start,end);
			var size:int = shopGoodsItems.length;
			var item:ShopGoodsItem;
			for(var i:int;i<size;i++){
				item = shopGoodsItems[i];
				if(pageDatas && pageDatas[i]){
					item.data = pageDatas[i];
				}else{
					item.data = null;
				}
			}
		}
		
		protected function removeItem(item:ShopGoodsItem):void{
			if(item){
				var index:int = shopGoodsItems.indexOf(item);
				if(index != -1){
					shopGoodsItems.splice(index,1);
				}
				if(item.parent){
					item.parent.removeChild(item);
				}
			}
		}
		
		protected function createItem(index:int):ShopGoodsItem{
			var item:ShopGoodsItem = new ShopGoodsItem();
			var row:int=index / columns;
			var column:int=index % columns;
			item.x=4 + column * item.width + column * HPADDING;
			item.y=5 + row * item.height + row * VPADDING;
			addChild(item);
			shopGoodsItems[index] = item;
			return item;
		}
		
		public function dispose():void{
			for each(var item:ShopGoodsItem in shopGoodsItems){
				removeItem(item);
			}
		}
	}
}