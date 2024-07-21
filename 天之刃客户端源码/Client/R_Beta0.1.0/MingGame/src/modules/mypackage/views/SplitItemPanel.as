package modules.mypackage.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	import modules.warehouse.views.WarehouseItem;
	
	public class SplitItemPanel extends DragUIComponent
	{
		private var titleField:TextField;
		private var textInput:TextInput;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		public var packageItem:PackageItem;
		public var warehouseItem:WarehouseItem;
		public function SplitItemPanel()
		{
			super();
			init();
		}
		
		private function init():void{
			width = 200;
			height = 105;

			titleField = ComponentUtil.createTextField("请输入要拆分的数量",20,10,null,200,NaN,this);
			titleField.textColor = 0x3DEA42;
			titleField.selectable = false;
			titleField.mouseEnabled = false;
			
			textInput = new TextInput();
			textInput.text = "1";
			textInput.restrict = "[0-9]";
			textInput.maxChars = 2;
			textInput.addEventListener(Event.CHANGE,onChange);
			textInput.addEventListener(ComponentEvent.ENTER,onEnter);
			textInput.width = 160;
			textInput.x = 20;
			textInput.y = 35;
			
			btn_ok = ComponentUtil.createButton("确定",30,65,60,25,this,wrapperButton);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",110,65,60,25,this,wrapperButton);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
			textInput.validateNow();
			addChild(textInput);
		
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(event:Event):void{
			textInput.setFocus();
			textInput.textField.setSelection(0,textInput.text.length);
		}
		
		private function onChange(event:Event):void{
			
			var maxSize:int;
			if(!packageItem)
			{
				if(!warehouseItem)
				{
					return;
				}else{
					
					maxSize = parseInt(warehouseItem.data.num)-1;
					
				}
				
			}else
			{
				maxSize = parseInt(packageItem.data.num)-1;
				
			}
			var size:int = parseInt(textInput.text);
			if(size > maxSize){
				textInput.text = maxSize.toString();
			}
			if(size == 0){
				textInput.text = "1";
			}
		}
		
		private function onEnter(event:ComponentEvent):void{
			onOKhandler();
		}
		
		private function onOKhandler(event:MouseEvent=null):void{
			if(textInput.text.length != 0){
				var size:int = parseInt(textInput.text);
				var baseItemVO:BaseItemVO;
				if(packageItem)
				{
					var itemSnapShot:GoodsItem;
					if(packageItem.data is GeneralVO){
						baseItemVO = new GeneralVO();
					}else if(packageItem.data is StoneVO){
						baseItemVO = new StoneVO();
						(baseItemVO as StoneVO).level = packageItem.data.level;
					}else if(packageItem.data is EquipVO){
						baseItemVO = new EquipVO();
					}
					baseItemVO.typeId = packageItem.data.typeId;
					baseItemVO.bagid = packageItem.data.bagid;
					baseItemVO.oid = packageItem.data.oid;
					baseItemVO.path = packageItem.data.path;
					baseItemVO.timeoutData = packageItem.data.timeoutData;
					baseItemVO.bind = packageItem.data.bind;
					baseItemVO.num = size;
					baseItemVO.position = -1; //表示没有位置
					packageItem.updateCount(packageItem.data.num - size);
					itemSnapShot = new GoodsItem(baseItemVO);
					DragItemManager.instance.startAdhereItem(this,itemSnapShot,DragConstant.SPLIT_ITEM,baseItemVO);
					
				}else if(warehouseItem){
					
					if(warehouseItem.data is GeneralVO){
						baseItemVO = new GeneralVO();
					}else if(warehouseItem.data is StoneVO){
						baseItemVO = new StoneVO();
						(baseItemVO as StoneVO).level = warehouseItem.data.level;
					}else if(warehouseItem.data is EquipVO){
						baseItemVO = new EquipVO();
					}
					baseItemVO.typeId = warehouseItem.data.typeId;
					baseItemVO.bagid = warehouseItem.data.bagid;
					baseItemVO.oid = warehouseItem.data.oid;
					baseItemVO.path = warehouseItem.data.path;
					baseItemVO.timeoutData = warehouseItem.data.timeoutData;
					baseItemVO.bind = warehouseItem.data.bind;
					baseItemVO.num = size;
					baseItemVO.position = -1; //表示没有位置
					warehouseItem.updateCount(warehouseItem.data.num - size);
					itemSnapShot = new GoodsItem(baseItemVO);
					DragItemManager.instance.startAdhereItem(this,itemSnapShot,DragConstant.WARE_ITEM_SPLIT,baseItemVO);
				}
				
			}
			onCancelhandler();			
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			packageItem = null;
			warehouseItem = null;
			WindowManager.getInstance().closeDialog(this);
			textInput.text = "";
			unLoad();
		}
	}
}