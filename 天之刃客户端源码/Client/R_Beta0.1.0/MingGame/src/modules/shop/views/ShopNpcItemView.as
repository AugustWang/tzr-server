package modules.shop.views
{
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.IDragItem;
	import com.components.alert.Alert;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObject;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.shop.ShopModule;

	public class ShopNpcItemView extends ShopItemImg implements IDragItem
	{
		private var content:*;
		
		public function ShopNpcItemView()
		{
			super();
			mouseChildren = false;
		}
		
		public function dragDrop(dragData:Object,dragTarget:DisplayObject,itemName:String):void{
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			
			if(tempData.desc.indexOf("任务物品")==0){
				Tips.getInstance().addTipsMsg("任务道具不能出售。");
				return;
			}
			
			ShopModule.getInstance().toSaleGoods(tempData.oid,tempData.typeId, tempData.position,tempData.num, tempData.name);
		}
		
		public function allowAccept(data:Object, name:String):Boolean
		{
			if(name == DragConstant.PACKAGE_ITEM){
				return true;
			}
			return false;
		}
		
		public function setContent(_content:*, _data:*):void
		{
			if(!_content)return;
			content = _content;
			super.data = _data;
			//			addChild(_content);
			//			this.buttonMode = useHandCursor = true;
		}
		
		public function getContent():*
		{
			return content;
		}
		
		public function disposeContent():void
		{
			if(!content)return;
			if(contains(content))
				removeChild(content);
			this.buttonMode = this.useHandCursor = false;
			content = null;
			data = null;	
		}
	}
}