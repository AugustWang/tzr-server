package modules.deal.views.stallViews
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.ming.events.ItemEvent;
	import com.ming.managers.DragManager;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	
	public class StallItem extends DragItem
	{
		public var index:int;
		public var state:int;    //1 雇佣摆摊中  2 自己摆摊中 3 尚未摆摊
//		public var settingPrice:Boolean = false;  //设置价格中，防止这时摊位上有物品卖出重新请求数据，会清掉之前的物品。
		
		private var _baseItemVo:BaseItemVO;
		private var _price:int;
		private var _isOtherStall:Boolean = false;
		
		public function StallItem(size:int=36)
		{
			super(36);
			
			addEventListener(MouseEvent.CLICK, onClickHandler);
		}
		
		private function onClickHandler(evt:MouseEvent):void
		{
			//var gooditem:GoodsItem =  getContent() as GoodsItem; 物品信息
			if(!_baseItemVo)
			{
				return;
			}
			if(!DragManager.isDragging)
				dispatchEvent(new ItemEvent(ItemEvent.ITEM_CLICK));
			
		}
		
		
		override public function allowAccept(data:Object,name:String):Boolean{
			
			if(DealConstant.OVERDUE == true)
			{
				// 过期　。。。。。
				return false;
			}
			if(this.isOtherStall)
			{
				// 逛他人的店 不接收拖拽事件。
				return false;
			}
			
			if(name == DragConstant.PACKAGE_ITEM || name == DragConstant.STALL_ITEM) //
			{
				if(this.getContent()!=null)
				{
					return false;
				}
				var goodsVo:BaseItemVO = data as BaseItemVO; //GoodsItem;
				if(goodsVo && !goodsVo.bind)
				{
					return true;
				}
			}
			return false;
		}
		
		
		
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				createContent();
			}
		}
		override protected function createContent():void{
//			baseItemVo = data as BaseItemVO
			content = new GoodsItem(data as BaseItemVO);//new GoodsItem(baseItemVo);// 
			addChild(content);
			super.createContent();
			
		}
		
		override public function disposeContent():void
		{
			//DealConstant.price_arr[index] = null;
			baseItemVo = null;
			super.disposeContent();
			while(numChildren > 1){
				removeChildAt(1);
			}
		}
		
		override public function setContent(_content:*, _data:*):void
		{
			super.setContent(_content,_data);
			baseItemVo = _data as BaseItemVO;
			baseItemVo.stall_pos = index +1;
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			// to do 
			if(itemName == DragConstant.PACKAGE_ITEM)
			{
				data = dragData;
				this.baseItemVo = tempData;
				this.baseItemVo.stall_pos = index + 1;
				if(state == 3)   //未摆
				{
					
					
				}
				else if(state == 1)  //雇佣摆摊中
				{
					
					
				}
				else if(state == 2)   //自己摆摊中
				{
					
				}
				
				DealModule.getInstance().openPriceUi(index, tempData,state);
				PackManager.getInstance().lockGoods(tempData, true)
			}
			else if(itemName == DragConstant.STALL_ITEM)
			{
					
//					this.baseItemVo = tempData;
				DealModule.getInstance().swapGoods(tempData.oid, index+1,tempData.stall_pos);
//				setContent(item,tempData);
				
			}
			
			//其它判断
			
		}
		
		public function updateContent(itemVO:BaseItemVO):void{
			if(itemVO == null){
				disposeContent();
				return;
			}
			if(content == null){
				data = itemVO;
			}else{
				setData(itemVO);
				content.updateContent(itemVO);
			}
			baseItemVo = itemVO;
			baseItemVo.stall_pos = index + 1 ;
		}
		
		
		public function set price(value:int):void
		{
			if(value)
				_price = value;
			
		}
		public function get price():int
		{
			return _price;
		}
		
		public function set baseItemVo(value:BaseItemVO):void
		{
			_baseItemVo = value;
		}
		public function get baseItemVo():BaseItemVO
		{
			return _baseItemVo;
		}
		
		public function set isOtherStall(value:Boolean):void
		{
			_isOtherStall = value;
		}
		
		public function get isOtherStall():Boolean
		{
			return _isOtherStall;
		}
		
	}
}

