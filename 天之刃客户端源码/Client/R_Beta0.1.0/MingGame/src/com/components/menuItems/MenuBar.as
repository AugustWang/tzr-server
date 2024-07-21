package com.components.menuItems
{
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class MenuBar extends UIComponent
	{
		public var top:Number = 5;
		public var left:Number = 5;
		
		public var labelField:String;
		public var iconField:String;
		private var cacheItems:Dictionary;
		private var _dataProvider:Vector.<MenuItemData>;
//		private var lines:Vector.<Skin>;
		private var items:Array;
		private var sizeChanged:Boolean;
		public function MenuBar()
		{
			super();
			Style.setMenuItemBg(this);
			cacheItems = new Dictionary();
//			lines = new Vector.<Skin>();
			items = [];
		}
		
		public var _itemHeight:Number = 26;
		public function set itemHeight(value:Number):void{
			if(value != _itemWidth){
				_itemHeight = value;
				sizeChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get itemHeight():Number{
			return _itemHeight;
		}
		
		public var _itemWidth:Number = 100;
		public function set itemWidth(value:Number):void{
			if(_itemWidth != value){
				_itemWidth = value;
				sizeChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get itemWidth():Number{
			return _itemWidth;
		}
		
		public function show(xValue:Number=NaN,yValue:Number = NaN):void{
			var stage:Stage = LayerManager.stage;
			if(isNaN(xValue))
				x = stage.mouseX;
			else
				x = xValue;
			
			if(isNaN(yValue))
				y = stage.mouseY;
			else
				y = yValue;
			
			if(x + width > stage.stageWidth)
				x  = stage.stageWidth - width;
			else if(x < 0)
				x = 0;
			if(y + height > stage.stageHeight)
				y = stage.stageHeight - height;
			
			LayerManager.main.addChild(this);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		private function onMouseDown(event:MouseEvent):void{
			var target:DisplayObject = event.target as DisplayObject;
			if(!contains(target)){
				close();
			}	
		}
		
		public function close():void{
			if(parent){
				stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				parent.removeChild(this);
			}	
		}
		
		private var dataChanged:Boolean;
		public function set dataProvider(value:Vector.<MenuItemData>):void{
			dataChanged = true;
			_dataProvider = value;
			invalidateDisplayList();
		}
		
		public function get dataProvider():Vector.<MenuItemData>{
			return _dataProvider;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			if(dataChanged){
				dataChanged = false;
				sizeChanged = false;
				while(items.length > 0){
					var btn:MenuBarItem = items.shift() as MenuBarItem;
					btn.dispose();
				}
//				while(lines.length > 0){
//					removeChild(lines.shift() as DisplayObject);
//				}
				var size:int = _dataProvider ? _dataProvider.length : 0;
				var startY:int = top;
				for(var i:int = 0;i<size ; i++){
					var value:Object = _dataProvider[i];
					var button:MenuBarItem = new MenuBarItem();
					button.x = left;
					button.y = startY;
					button.width = itemWidth;
					button.height = itemHeight;
					button.labelField = labelField;
					button.iconField = iconField;
					button.data = value;
					button.addEventListener(MouseEvent.CLICK,onItemClick);
					startY = button.y + button.height + 2;
					addChild(button);
					items.push(button);
//					if(i != size - 1){
//						var sp:Skin = cacheItems["line"+i];
//						if(sp == null){
//							sp = Style.getSkin("sparete",GameConfig.T1_UI);
//							cacheItems["line"+i] = sp;
//							sp.x = 10;
//						}
//						sp.setSize((left*2 + itemWidth)-2*10,2);
//						sp.y = startY - 2;
//						addChild(sp);
//						lines.push(sp);
//					}
				}
				height = startY + top;
				width = left*2 + itemWidth;
			}
			if(sizeChanged){
				sizeChanged = false;
				var _h:Number = top;
				for each(var item:MenuBarItem in items){
					item.width = itemWidth;
					item.height = itemHeight;
					_h = item.y + item.height + 2;
				}
				height = _h + top;
				width = left*2 + itemWidth;
			}
			super.updateDisplayList(w,h);
		}
		
		private function onItemClick(evt:MouseEvent):void{
			var menuBarItem:MenuBarItem = evt.currentTarget as MenuBarItem;
			if(menuBarItem){
				var event:ItemEvent = new ItemEvent(ItemEvent.ITEM_CLICK);
				event.selectIndex = _dataProvider.indexOf(menuBarItem.data);
				event.selectItem = menuBarItem.data;
				dispatchEvent(event);
				close();
			}
		}
	}
}