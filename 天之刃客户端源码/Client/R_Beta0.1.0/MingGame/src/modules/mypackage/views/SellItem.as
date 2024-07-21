package modules.mypackage.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.components.alert.Alert;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	
	/**
	 * 背包卖出的格子类 
	 * @author Qingliangcn
	 * 
	 */	
	public class SellItem extends DragItem
	{
		public static const ITEM_SIZE:int = 36;
		public var index:int = 0;
		private var items:Dictionary = new Dictionary;
		
		private var lock:Boolean = false;
		public function SellItem()
		{
			super(ITEM_SIZE);
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			super.createContent();
		}
		
		public function islock():Boolean
		{
			return lock;
		}
		
		public function unlock():void
		{
			lock = false;
		}
		
		public function insert(baseVo:BaseItemVO):void
		{
			data = baseVo;
			Dictionary[baseVo] = baseVo;
			PackageModule.getInstance().onDragInSell(baseVo);
			lock = true;
		}
		
		//拖过来后回调这个函数
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			if(itemName == DragConstant.PACKAGE_ITEM){
				if (tempData.color > 1) {
					Alert.show("你确定卖出<font color='" +
						ItemConstant.COLOR_VALUES[tempData.color]
						+ "'>【"+  tempData.name + "】</font> x " + tempData.num, "卖出提示", sureSell, null, "卖出", "取消", new Array(tempData));
				} else {
					data = tempData;
					Dictionary[tempData] = tempData;
					PackageModule.getInstance().onDragInSell(tempData);
					lock = true;
				}
			}
		}
		
		private function sureSell(tempData:BaseItemVO):void{
			data = tempData;
			Dictionary[tempData] = tempData;
			PackageModule.getInstance().onDragInSell(tempData);
			lock = true;
		}
		
		override public function allowAccept(itemVO:Object,name:String):Boolean{
			if (name == DragConstant.PACKAGE_ITEM && !lock) {
				return true;
			}
			return false;
		}
	}
}