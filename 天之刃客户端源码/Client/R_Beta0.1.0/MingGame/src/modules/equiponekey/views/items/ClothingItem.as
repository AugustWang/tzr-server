package modules.equiponekey.views.items
{		
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.common.dragManager.DragItemManager;
	import com.components.cooling.CoolingManager;
	import com.components.cooling.ICooling;
	import com.ming.managers.ToolTipManager;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;

		/**
		 * 换装装备项
		 */	
		public class ClothingItem extends DragItem implements ICooling
		{
			private var img:Bitmap;
			public function ClothingItem()
			{
				super(36);
				addEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				img = new Bitmap();
				img.x = img.y = 4;
				addChild(img);
				CoolingManager.getInstance().registerObserver(this);
			}
			
			private function itemDownHandler(event:MouseEvent):void{
				DragItemManager.instance.startDragItem(this,img,DragConstant.CLOTHING_ITEM,data);
			}
			
			override protected function rollOverHandler(tipCompare:Boolean=true):void{
				ToolTipManager.getInstance().show("点击可以拖动到快捷栏");
			}
			
			override protected function rollOutHandler():void{
				ToolTipManager.getInstance().hide();
			}
			
			override public function set data(value:Object):void{
				super.data = value;
				img.bitmapData = null;
				if(data){
					ClothingItemVO(data).draw();
					img.bitmapData = ClothingItemVO(data).path;
				}
			}
			
			override public function allowAccept(data:Object,name:String):Boolean{
				return false;
			}
			
			override public function getItemName():String{
				return DragConstant.CLOTHING_ITEM;
			}	
			
			public function getName():String{
				return data ? data.typeId : "";
			}
			
			private var _coolingId:int;
			public function get coolingID():int{
				return _coolingId;
			}
			
			public function set coolingID(value:int):void{
				this._coolingId = value;
			}
		}
	}