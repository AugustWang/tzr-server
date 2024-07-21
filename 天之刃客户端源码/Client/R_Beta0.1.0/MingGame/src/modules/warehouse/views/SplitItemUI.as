package modules.warehouse.views
{
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.ming.events.ComponentEvent;
	import com.ming.managers.DragManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	public class SplitItemUI extends UIComponent
	{
		private var titleField:TextField;
		private var textInput:TextInput;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		public var warehouseItem:WarehouseItem;
		private var dragSprite:Sprite;
		
		public function SplitItemUI()
		{
			super();
			init();
		}
		private function init():void{
			width = 200;
			height = 100;
			this.bgColor = 0x123456;
			dragSprite = new Sprite();
			dragSprite.graphics.beginFill(0x00,0);
			dragSprite.graphics.drawRect(0,0,width,height);
			dragSprite.graphics.endFill();
			addChild(dragSprite);
			
			titleField = ComponentUtil.createTextField("请输入要拆分的数量",20,10,StyleManager.textFormat,200,NaN,this);
			titleField.selectable = false;
			titleField.mouseEnabled = false;
			
			textInput = new TextInput();
			textInput.restrict = "[0-9]";
			textInput.addEventListener(Event.CHANGE,onChange);
			textInput.addEventListener(ComponentEvent.ENTER,onEnter);
			textInput.width = 160;
			textInput.x = 20;
			textInput.y = 40;
			
			btn_ok = ComponentUtil.createButton("确定",50,70,40,NaN,this);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",110,70,40,NaN,this);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
			
			addChild(textInput);
			DragManager.register(dragSprite,this,null,DragManager.BORDER);
			addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
		}
		
		private function onAddToStage(event:Event):void{
			textInput.setFocus();
		}
		
		private function onChange(event:Event):void{
			if(!warehouseItem)return;
			var size:int = parseInt(textInput.text);
			var maxSize:int = parseInt(warehouseItem.data.num)-1;
			if(size > maxSize){
				textInput.text = maxSize.toString();
			}
		}
		
		private function onEnter(event:ComponentEvent):void{
			onOKhandler();
		}
		
		private function onOKhandler(event:MouseEvent=null):void{
			if(textInput.text.length != 0){
				var size:int = parseInt(textInput.text);
				var baseItemVO:BaseItemVO;
				if(warehouseItem.data is GeneralVO){
					baseItemVO = new GeneralVO();
				}else if(warehouseItem.data is StoneVO){
					baseItemVO = new StoneVO();
					(baseItemVO as StoneVO).level = warehouseItem.data.level;
				}
				baseItemVO.typeId = warehouseItem.data.typeId;
				baseItemVO.oid = warehouseItem.data.oid;
				baseItemVO.path = warehouseItem.data.path;
				baseItemVO.timeoutData = warehouseItem.data.timeoutData
				baseItemVO.bind = warehouseItem.data.bind;
				baseItemVO.num = size;
				baseItemVO.position = -1; //表示没有位置
				warehouseItem.updateCount(warehouseItem.data.num - size);
				var itemSnapShot:GoodsItem = new GoodsItem(baseItemVO);
				DragItemManager.instance.startAdhereItem(this,itemSnapShot,DragConstant.WARE_ITEM_SPLIT,baseItemVO);				
			}
			onCancelhandler();			
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			warehouseItem = null;
			parent.removeChild(this);
			textInput.text = "";
			DragManager.unregister(this);
		}
		
		
	}
}