package modules.finery.views.item
{
	import flash.display.DisplayObject;
	
	import modules.mypackage.views.PackageItem;

	public class BoxPackageItem extends PackageItem
	{
		public function BoxPackageItem()
		{
			super();
		}
		
		override public function set lock(value:Boolean):void{
			return;
		}
		
		override public function get lock():Boolean{
			return _lock;
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			return;
		}
	}
}