package modules.letter.view.detail
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import modules.letter.LetterModule;
	import modules.mypackage.PackageModule;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_goods;
	/**
	 * 信件详情面板的附件
	 * @author
	 * 
	 */	
	public class DetailAccessoryItem extends AccessoryItem
	{
		
		private var _param:p_goods;
		private var dragItem:BaseItemVO;
		private var image:GoodsItem;
		
		private var self:Boolean;
		public function DetailAccessoryItem()
		{
			super();
		}
		
		
		public function setParam(vo:p_goods, selfSend:Boolean = false):void
		{
			this.self = selfSend;
			this._param = vo;
//			this.visible = true;
			if(vo == null){
				if(image != null && contains(image))
					removeChild(image);
//					this.visible = false;
				if(this.hasEventListener(MouseEvent.MOUSE_OVER))
					this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOver);
				return;
			}else{
				dragItem = PackageModule.getInstance().getBaseItemVO(vo);
				if(image == null){
					image = new GoodsItem(dragItem);
				}else{
					image.updateContent(dragItem);
				}
				addChild(image);
				image.x = 2;
				image.y = 2;
				this.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			}
		}
		
		private function mouseOver(evt:MouseEvent):void{
			var p:Point = new Point(x+36 , y);
			p = parent.localToGlobal(p);
			ItemToolTip.show(dragItem , p.x , p.y , false);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		private function mouseOut(evt:MouseEvent):void{
			ItemToolTip.hide();
			this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		public function get param():p_goods{
			return this._param;
		}
		
	/*	public function lock():void
		{
			
		}*/
		/**
		 * 解除锁定，bool为true标志成功提取，为false标志提取失败. 
		 * @param bool
		 * 
		 */		
		public function unlock(bool:Boolean):void{
			if(bool){
				setParam(null);
				dragItem = null;
				if(contains(image))
					removeChild(image);
			}else{
				this.addChild(image);
			}
		}
		
		override protected function drag(evt:MouseEvent):void
		{
			if(_param == null || self == true)
				return;
			DragItemManager.instance.startDragItem(this,image,DragConstant.LETTER_ITEM,dragItem);
			
			super.drag(evt);
		}
		
		override public function setContent(content:*, _data:*):void{
			this.addChild(image);
		}
		
		override public function disposeContent():void{
			if(image.parent != null)
				image.parent.removeChild(image);
		}
		
		override public function allowAccept(data:Object, name:String):Boolean{
			if(name == DragConstant.LETTER_ITEM)
				return true;
			return false;
		}
		
		/**
		 * 只有自己拖到自己身上才会触发
		 */		
		override public function dragDrop(dragData:Object,dragTarget:DisplayObject,itemName:String):void
		{
			dragTarget.x = 2;
			dragTarget.y = 2;
			this.addChild(dragTarget);
			return;
		}
	}
}