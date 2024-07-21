package modules.mount.views
{
	import com.ming.managers.DragManager;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.common.dragManager.DragItemManager;
	import com.utils.ComponentUtil;
	import modules.forgeshop.ForgeshopModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	public class MountUpgradeItem extends DragItem
	{
		public static var mountID:int;
		private var txt:TextField;
		private var  accept:Boolean = true;
		private var targetData:EquipVO;
		public var updataCallBack:Function;
		
		public function MountUpgradeItem()
		{
			super(36,"skyItem");
			var textField:TextField = ComponentUtil.createTextField("坐骑",26,30,new TextFormat("宋体",12,0xffcc00),30,20,this);
			textField.selectable = false; 
			textField.filters = [new GlowFilter(0x000000)];
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDownHandler);
		}
		
		override protected function updateBorder(x:int, y:int):void{
			if(overBorder){
				overBorder.x = 21;
				overBorder.y = 20;
			}
		}
		
		override protected function rollOverHandler(tipCompare:Boolean=true):void{
			if(data){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				ItemToolTip.show(data as BaseItemVO,p.x + 20,p.y + 20,false);
			}
		}
		
		override protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);	
			super.createContent();
		}
		
		override protected function updatePosition():void{
			if(this.content){
				this.content.x = 23;
				this.content.y = 22;
			}
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
			this.updatePosition();
		}
		
		override public function allowAccept(data:Object,name:String):Boolean{
			if((data is EquipVO) && name == DragConstant.PACKAGE_ITEM && data.kind == ItemConstant.KIND_EQUIP_MOUNT){
				return true;
			}
			return false;
		}
		
		private function onMouseDownHandler(evt:MouseEvent):void{
			if(data && !DragManager.isDragging){
				DragItemManager.instance.startDragItem(this,getContent(),DragConstant.MOUNT_UPGRADE_ITEM,data);
			}
		}
		
		override public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			//已存在物品，想替换
			swapGoods();
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:EquipVO = dragData as EquipVO;
			data = tempData;
			PackManager.getInstance().lockGoods(tempData,true);
		}	
		
		private function swapGoods():void{
			if(data){
				var equipVo:BaseItemVO = data as BaseItemVO;
				PackManager.getInstance().lockGoods(equipVo,false);
				PackManager.getInstance().updateGoods(equipVo.bagid,equipVo.position,equipVo);
				disposeContent();
			}
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			mountID = data.oid;
			if(updataCallBack != null)updataCallBack.apply();
		}
		
		
	}
}