package modules.letter.view.detail
{
    import com.common.dragManager.DragConstant;
    import com.common.dragManager.IDragItem;
    import com.globals.GameConfig;
    import com.ming.ui.controls.core.UIComponent;
    
    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.utils.getTimer;
    
    import modules.mypackage.managers.PackManager;
    import modules.mypackage.vo.BaseItemVO;
	
	public class AccessoryItem extends UIComponent implements IDragItem
	{
		
		private var currentTime:int;
		public function AccessoryItem()
		{
			super();
			
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			addChild(bg);
			
			this.mouseChildren = false;
			this.width = 36;
			this.height = 36;
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, drag);
			this.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			
		}
		
		
		
		private function onMouseClickHandler(evt:MouseEvent):void{}
		
		protected function drag(evt:MouseEvent):void{}
		
		protected function onDoubleClick(evt:MouseEvent):void{}
		
		public function setContent(content:*, _data:*):void{return;}
		
		public function getContent():*{return null;}
		
		public function disposeContent():void{}
		
		public function allowAccept(data:Object, name:String):Boolean{
			if(name == DragConstant.PACKAGE_ITEM)
				return true;
			return false;
		}
		public function dragDrop(dragData:Object,dragTarget:DisplayObject,itemName:String):void{}
	}
}