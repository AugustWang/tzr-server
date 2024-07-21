package modules.family.views.fmlDepotViews {
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.family.FamilyDepotModule;
	import modules.mypackage.vo.BaseItemVO;

	public class FMLdepotTile extends Sprite {
		public var rowCount:int=6;
		public var columnCount:int=7;
		public static const HPADDING:int=0;
		public static const VPADDING:int=0;

		public function FMLdepotTile() {
			super();
			createItems();
//			addEventListener(DragItemEvent.DRAG_THREW,onDragThrew);
		}

//		private function onDragThrew(event:DragItemEvent):void{			
//			var itemVo:BaseItemVO = event.dragData as BaseItemVO;
//			var color:String = ItemConstant.COLOR_VALUES[itemVo.color];
//			Alert.show("你是否确定要丢弃"+HtmlUtil.font("【"+itemVo.name+"】",color)+"?","警告",desctoryGoods,updateItem);
//			function desctoryGoods():void{
//				WarehouseModel.getInstance().depotDestroy(itemVo.oid);
//			}
//			function updateItem():void{
//				updateGoods(itemVo.position,itemVo);
//			}
//		}

		private var wareItems:Array;

		private function createItems():void {
			//			wareItems = [];
			var size:int=rowCount * columnCount;
			for (var i:int=0; i < size; i++) {
				var item:FMLdepotItem=new FMLdepotItem();
				item.index=i;
				//				item.packId = packId;
				item.addEventListener(MouseEvent.MOUSE_DOWN, itemDownHandler);
				item.addEventListener(MouseEvent.CLICK, onItemClick);

//				item.doubleClickEnabled = true;
//				item.addEventListener(MouseEvent.DOUBLE_CLICK,onItemDoubleClick);				
				var row:int=i / columnCount;
				var column:int=i % columnCount;
				item.x=column * item.width + column * HPADDING;
				item.y=row * item.height + row * VPADDING;
				addChild(item);
					//				wareItems.push(item);
			}
		}

		private function itemDownHandler(event:MouseEvent):void {
			var item:FMLdepotItem=event.currentTarget as FMLdepotItem;
			if (item.data && !DragItemManager.isDragging()) {

				DragItemManager.instance.startDragItem(this, item.getContent(), DragConstant.FMLDEPOT_ITEM, item.data);
			}
		}

		private function onItemClick(e:MouseEvent):void {
			var item:FMLdepotItem=e.currentTarget as FMLdepotItem;
			var baseItemVO:BaseItemVO=item.data as BaseItemVO;
			if (baseItemVO == null || DragItemManager.isDragging())
				return;
			showGetPanel(baseItemVO);

		}

		private var getPanel:FMLdepotGetPanel;

		private function showGetPanel(itemVo:BaseItemVO):void {
//			var itemVo:BaseItemVO = item.data as BaseItemVO;
			if (itemVo) //&& generalVO.usenum != ItemConstant.LOCK
			{
				if (!getPanel) {
					getPanel=new FMLdepotGetPanel();
					getPanel.addEventListener(CloseEvent.CLOSE, buyPanelClose);
				}
				if (FamilyDepotModule.getInstance().getDepotPanel()) {
					getPanel.x=FamilyDepotModule.getInstance().getDepotPanel().x + 33;
					getPanel.y=FamilyDepotModule.getInstance().getDepotPanel().y + 124;
				} else {
					getPanel.x=100;
					getPanel.y=200;
				}
				getPanel.setBaseItemVo(itemVo);
				WindowManager.getInstance().openDialog(getPanel);
			}


		}

		public function buyPanelClose(evt:CloseEvent=null):void {
			if (getPanel) {
				WindowManager.getInstance().closeDialog(getPanel);
				getPanel.dispose();
				getPanel=null;
			}
		}

		public function updateGoods(goodsId:int, itemvo:BaseItemVO):void {
//			if(pos<1)
//				return;
			for (var i:int=0; i < rowCount * columnCount; i++) {
				var item:FMLdepotItem=getChildAt(i) as FMLdepotItem;
				if (item && item.data) {
					var itemdata:BaseItemVO=item.data as BaseItemVO;
					if (itemdata && itemdata.oid == goodsId) {
						item.updateContent(itemvo);
						break;
					}
				} else {
					if (item && itemvo) {
						item.updateContent(itemvo);
						break;
					}
				}
			}
		}

		public function disposeItems():void {
			var size:int=numChildren;
			for (var i:int=0; i < size; i++) {
				var item:FMLdepotItem=getChildAt(i) as FMLdepotItem;
				item.disposeContent();
			}
		}
	}
}