package modules.shop.views.items
{
	import com.common.dragManager.DragItem;
	
	import flash.display.Sprite;
	
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	
	public class BuyBackItem extends DragItem
	{
		public function BuyBackItem()
		{
			super(36);
		}
		
		override public function allowAccept(data:Object, name:String):Boolean{
			return false;
		}
		
		public function updateContent(itemVO:BaseItemVO):void{
			if(itemVO == null){
				disposeContent();
				return;
			}
			if(data == null){
				data = itemVO;
			}else{
				setData(itemVO);
				content.updateContent(itemVO);
			}
			showTip();
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			super.createContent();
		}
	}
}