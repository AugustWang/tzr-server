package modules.forgeshop.views.items
{
	import com.common.dragManager.DragItem;
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	public class UpdateEquipItem extends DragItem
	{
		public function UpdateEquipItem()
		{
			super(36);
		}
		
		override protected function createContent():void{
			super.createContent();
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			content.x = 2;
			content.y = 2;
		}

		override protected function rollOverHandler(tipCompare:Boolean=true):void{
			if(data){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				ItemToolTip.show(data as BaseItemVO,p.x + 10,p.y,false);
			}
		}

		override public function allowAccept(data:Object, name:String):Boolean{
			return false;
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{}
	}
}