package com.ming.ui.containers
{
	import com.ming.core.ClassFactory;
	import com.ming.core.IDataRenderer;
	import com.ming.events.ItemEvent;
	import com.ming.events.ResizeEvent;
	import com.ming.events.ScrollEvent;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.treeList.ICellRenderer;
	import com.ming.ui.containers.treeList.events.DataChangeEvent;
	import com.ming.ui.containers.treeList.events.DataChangeType;
	import com.ming.ui.controls.rendererClass.ListItemRenderer;
	import com.ming.ui.skins.ListSkin;
	import com.ming.ui.skins.OverItemSkin;
	import com.ming.ui.skins.SelectItemSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class List extends Canvas
	{
		public var itemRenderer:Class;
		public var labelField:String;
		public var itemDoubleClickEnabled:Boolean;
		
		protected var activeCellRenderers:Array;
		protected var availableCellRenderers:Array;
		protected var renderedItems:Dictionary;
		protected var invalidItems:Dictionary;
		protected var startIndex:int = -1;
		
		private var selectedRenderer:IDataRenderer;
		public var scrollRow:Boolean;
		/**
		 * 悬停和选择样式 
		 */		
		private var overSkin:OverItemSkin;
		private var selectedSkin:SelectItemSkin;
		public var itemSkinLeft:Number = 2;
		public var itemSkinRight:Number = 3;
		public function List()
		{
			itemRenderer = ListItemRenderer;
			activeCellRenderers = [];
			availableCellRenderers = [];
			renderedItems = new Dictionary(true);
			invalidItems = new Dictionary(true);
			overSkin = new OverItemSkin();
			selectedSkin = new SelectItemSkin();	
			listSkin = StyleManager.listSkin;
			addEventListener(MouseEvent.CLICK,onMouseClick);
			selected = true;
		}
		/**
		 * 是否需要选择效果 
		 */		
		private var _selected:Boolean = true;
		public function set selected(value:Boolean):void{
			_selected = value;
			if(_selected){
				addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				addEventListener(MouseEvent.ROLL_OUT,onMouseOut);
			}else{
				removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
				removeEventListener(MouseEvent.ROLL_OUT,onMouseOut);
			}	
		}
		
		private var _listSkin:ListSkin;
		public function set listSkin(value:ListSkin):void{
			_listSkin = value;
			if(_listSkin){
				bgSkin = _listSkin.borderSkin;
				overSkin.bgSkin = _listSkin.overSkin;
				selectedSkin.bgSkin = _listSkin.selectedSkin;
			}
		}
		
		public function get listSkin():ListSkin{
			return _listSkin	
		}
		
		private var _itemHeight:Number = 20;
		public function set itemHeight(value:Number):void{
			_itemHeight = value;
			if(_autoJustSize){
				overSkin.height = selectedSkin.height = itemHeight;
			}
		}
		
		public function get itemHeight():Number{
			return _itemHeight;
		}
		
		private var _autoJustSize:Boolean = false;
		public function set autoJustSize(value:Boolean):void{
			_autoJustSize = value;
			if(_autoJustSize){
				overSkin.height = selectedSkin.height = itemHeight;
			}
		}
		
		public function get autoJustSize():Boolean{
			return _autoJustSize;
		}
		
		public function setOverItemSkin(skin:Skin):void{
			if(overSkin){
				overSkin.bgSkin = skin;
			}	
		}
		
		public function setSelectItemSkin(skin:Skin):void{
			if(selectedSkin){
				selectedSkin.bgSkin = skin;
			}	
		}
		
		private var selectedIndexChanged:Boolean = false;
		private var _selectedIndex:int = -1;
		public function set selectedIndex(value:int):void{
			if(value != _selectedIndex){
				_selectedIndex = value;
				selectedIndexChanged = true;
				invalidateDisplayList();
			}
		}	
		
		public function get selectedIndex():int{
			return _selectedIndex;
		}
		
		private var selectedItemChanged:Boolean = false;
		private var _selectedItem:Object;
		public function set selectedItem(value:Object):void{
			if(value != _selectedItem){
				_selectedItem = value;
				selectedItemChanged = true;
				invalidateDisplayList();
			}
		}	
		
		public function get selectedItem():Object{
			return _selectedItem;
		}
		
		private var dataChanged:Boolean = false;
		protected var _dataProvider:Array;
		public function set dataProvider(_datas:Array):void{
			dataChanged = true;
			_dataProvider = _datas;
			invalidateDisplayList();
		}
		
		public function get dataProvider():Array{
			return _dataProvider;	
		}
		
		private function clearSelection():void{
			_selectedIndex = -1;
			_selectedItem = null;
			selectedRenderer = null;
		}
		
		private var redrawList:Boolean = false;
		public function invalidateList():void{
			redrawList = true;
			startIndex = -1;
			invalidateDisplayList();
		}
		
		override protected function verticalScroll(event:ScrollEvent):void{
			drawList(false);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(dataChanged){
				dataChanged = false;
				selectedIndexChanged = true;
				redrawList = true;
			}
			if(redrawList){
				redrawList = false;
				resizeScrollBar();
				drawList();
			}
			if(selectedIndexChanged && dataProvider){
				selectedIndexChanged = false;
				_selectedIndex = Math.min(_selectedIndex,dataProvider.length-1);
				_selectedItem = dataProvider[selectedIndex];
				selectedItemChanged = true;
				if(_selectedItem){
					dispatchItemChanged();
				}
			}else if(dataProvider == null){
				_selectedIndex = -1;
				_selectedItem = null;
			}
			if(selectedItemChanged){
				selectedItemChanged = false;
				if(selectedItem){
					var cell:IDataRenderer = renderedItems[selectedItem];
					if(cell){
						setSelectItem(cell);
						selectedRenderer = cell;
					}
				}else{
					setSelectItem(null,false);
				}
			}
		}
		
		override protected function contentChanged():void{}
		
		protected function drawList(invidate:Boolean=true):void{
			var i:uint;
			var listData:Object;
			var cellRender:IDataRenderer;
			var cellSprite:Sprite;
			var start:int = Math.floor( vScrollPosition / itemHeight);
			if(!invidate && start == startIndex)return;
			startIndex = start;
			selectedRenderer = null;
			var length:int = _dataProvider ? _dataProvider.length : 0;
			var end:int = Math.min(length, start + rowCount + 1);
			var useItems:Dictionary= new Dictionary(true);
			renderedItems = new Dictionary(true);
			i = start;
			while (i < end){
				useItems[_dataProvider[i]] = true;
				i++;
			}
			while (activeCellRenderers.length > 0){	
				cellRender = activeCellRenderers.pop() as IDataRenderer;
				listData = cellRender.data;
				if (useItems[listData] == null || invalidItems[listData] == true){
					availableCellRenderers.push(cellRender);
				}else{
					renderedItems[listData] = cellRender;
					invalidItems[listData] = true;
				}
				if(contains(cellRender as DisplayObject)){
					removeChild(cellRender as DisplayObject);
				}
			}
			i = start;
			invalidItems = new Dictionary(true);
			setSelectItem(null,false);
			while (i < end){
				listData = _dataProvider[i];
				if (renderedItems[listData] != null){
					cellRender = renderedItems[listData];
					cellSprite = cellRender as Sprite;
					delete renderedItems[listData];
				}else if (availableCellRenderers.length > 0){
					cellRender = availableCellRenderers.pop() as IDataRenderer;
					cellSprite = cellRender as Sprite;
				}else{
					var factory:ClassFactory = new ClassFactory(itemRenderer);
					cellRender = factory.newInstance() as IDataRenderer;
					cellSprite = cellRender as Sprite;
					if (cellSprite != null && itemDoubleClickEnabled){
						cellSprite.doubleClickEnabled = true;
						cellSprite.addEventListener(MouseEvent.DOUBLE_CLICK, handleCellRendererDoubleClick, false, 0, true);
					}
					if(cellSprite.hasOwnProperty("labelField")){
						cellSprite["labelField"] = labelField;
					}
				}
				addChild(cellSprite);
				activeCellRenderers.push(cellRender);
				renderedItems[listData] = cellRender;
				cellSprite.y = itemHeight * (i - start);
				var scrollWidth:Number = vScrollBar ? vScrollBar.width : 0;
				cellRender.data = listData;
				if(listData == selectedItem){
					_selectedIndex = i;
					selectedRenderer = cellRender;
					setSelectItem(selectedRenderer);
				}
				i++;
			}
		}
		
		public function get rowCount() : uint{
			return Math.ceil(height/itemHeight);
		}
		
		public function invalidateItem(item:Object):void{
			if (renderedItems[item] == null){
				return;
			}
			invalidItems[item] = true;
			invalidateList();
		}
		
		override protected function getContentSize():Array{
			var h:Number = 0;
			if(_dataProvider){
				var module:Number = height%itemHeight == 0 ? 0 : itemHeight;
				h = _dataProvider.length*itemHeight + module;
			}
			return [width,h];
		}
				
	
		private function handleCellRendererDoubleClick(event:MouseEvent):void{
			var cellRender:IDataRenderer = event.currentTarget as IDataRenderer;
			if(cellRender){
				var evt:ItemEvent = new ItemEvent(ItemEvent.ITEM_DOUBLE_CLICK);
				evt.selectItem = cellRender.data;
				dispatchEvent(evt);
			}
		}
		
		private function setSelectItem(renderer:IDataRenderer,selected:Boolean=true):void{
			if(_selected == false)return;
			if(renderer && selected){
				if(!contains(selectedSkin)){
					rawChildren.addChild(selectedSkin);
				}
				if(vScrollBar){
					selectedSkin.width = width - vScrollBar.width-itemSkinRight-itemSkinLeft;
				}else{
					selectedSkin.width = width-itemSkinRight-itemSkinLeft;
				}
				selectedSkin.x = DisplayObject(renderer).x+itemSkinLeft;
				selectedSkin.y = DisplayObject(renderer).y + (itemHeight - selectedSkin.height)/2;
			}else{
				if(contains(selectedSkin)){
					rawChildren.removeChild(selectedSkin);
				}
			}
		}
		
		private function onMouseMove(event:MouseEvent):void{
			if(event.buttonDown)return;
			if(isScrollBar(event)){
				onMouseOut(null);
				return;
			}
			var child:DisplayObject = getCurrentChild();
			if(child){
				if(!contains(overSkin)){
					rawChildren.addChild(overSkin);
				}
				overSkin.x = child.x+itemSkinLeft;
				overSkin.y = child.y + (itemHeight - overSkin.height)/2;
				if(vScrollBar){
					overSkin.width = width - vScrollBar.width-itemSkinRight-itemSkinLeft;
				}else{
					overSkin.width = width-itemSkinRight-itemSkinLeft;
				}	
			}else{
				onMouseOut(null);
			}	
		}
		
		private function onMouseOut(event:MouseEvent):void{
			if(contains(overSkin)){
				rawChildren.removeChild(overSkin);	
			}			
		}
		
		private function onMouseClick(event:MouseEvent):void{
			if(isScrollBar(event))return;
			var cellRender:IDataRenderer = getCurrentChild() as IDataRenderer;
			if(cellRender){
				if(cellRender.data != _selectedItem){
					setSelectItem(cellRender);
					selectedRenderer = cellRender;
					_selectedIndex = _dataProvider.indexOf(cellRender.data);
					_selectedItem = cellRender.data;
					dispatchItemChanged();
				}
				var evt:ItemEvent = new ItemEvent(ItemEvent.ITEM_CLICK);
				evt.selectItem = _selectedItem;
				dispatchEvent(evt);
			}
		}
		
		private function getCurrentChild():DisplayObject{
			var hh:Number = 0;
			for each(var child:DisplayObject in activeCellRenderers){
				if(mouseY < child.y + itemHeight){					
					return child;
				}
			}
			return null;
		}
		
		private function isScrollBar(event:MouseEvent):Boolean{
			if(event == null)return false;
			var target:DisplayObject = event.target as DisplayObject;
			if(vScrollBar && vScrollBar.contains(target))return true;
			return false;
		}
		
		public function getItemByData(item:Object):IDataRenderer{
			for each(var itemRenderer:IDataRenderer in activeCellRenderers){
				if(item == itemRenderer.data){
					return itemRenderer;
				}
			}
			return null;
		}
		
		public function refreshItem(item:Object):void{
			var cellRenderer:IDataRenderer = renderedItems[item];
			if (cellRenderer){
				cellRenderer.data = item;	
			}
		}
		
		public function get selectedChild():*{
			return selectedRenderer;
		}
		
		private function dispatchItemChanged():void{
			var event:ItemEvent = new ItemEvent(ItemEvent.ITEM_CHANGE);
			event.selectItem = _selectedItem;
			event.selectIndex = _selectedIndex;
			dispatchEvent(event);
		}
	}
}
