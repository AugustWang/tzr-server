package com.ming.ui.containers.treeList
{
	import com.ming.core.ClassFactory;
	import com.ming.events.ItemEvent;
	import com.ming.events.ScrollEvent;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.treeList.events.DataChangeEvent;
	import com.ming.ui.containers.treeList.events.DataChangeType;
	import com.ming.ui.skins.ListSkin;
	import com.ming.ui.skins.OverItemSkin;
	import com.ming.ui.skins.SelectItemSkin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class Tree extends Canvas
	{
		public var cellRenderer:Class;
		public var iconField:String = "icon";
		public var labelField:String = "label";
		public var rowHeight:Number = 20;
		public var itemDoubleClickEnabled:Boolean = false;
		
		protected var activeCellRenderers:Array;
		protected var availableCellRenderers:Array;
		protected var renderedItems:Dictionary;
		protected var invalidItems:Dictionary;
		protected var startIndex:int = -1;
		
		private var selectedRenderer:ICellRenderer;
		/**
		 * 悬停和选择样式 
		 */		
		public var overSkin:OverItemSkin;
		public var selectedSkin:SelectItemSkin;
		public var itemSkinLeft:Number = 5;
		public var itemSkinRight:Number = 5;
		public var autoJustSize:Boolean = true;
		public var allowSelectBranch:Boolean = false;
		public function Tree()
		{
			activeCellRenderers = [];
			availableCellRenderers = [];
			renderedItems = new Dictionary(true);
			invalidItems = new Dictionary(true);
			overSkin = new OverItemSkin();
			selectedSkin = new SelectItemSkin();	
			var listSkin:ListSkin = StyleManager.listSkin;
			if(listSkin){
				if(listSkin.borderSkin)
					overSkin.bgSkin = listSkin.overSkin;
				if(listSkin.selectedSkin)
					selectedSkin.bgSkin = listSkin.selectedSkin;
			}
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			addEventListener(MouseEvent.ROLL_OUT,onMouseOut);
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
		private var _selectedItem:TreeNode;
		public function set selectedItem(value:TreeNode):void{
			if(value != _selectedItem){
				_selectedItem = value;
				selectedItemChanged = true;
				invalidateDisplayList();
			}
		}	
		
		public function get selectedItem():TreeNode{
			return _selectedItem;
		}
		
		private var dataChanged:Boolean = false;
		protected var _dataProvider:TreeDataProvider;
		public function set dataProvider(_datas:TreeDataProvider):void{
			if(_dataProvider){
				_dataProvider.removeEventListener(DataChangeEvent.DATA_CHANGE, onDataChange);
				_dataProvider.removeEventListener(DataChangeEvent.PRE_DATA_CHANGE, onPreChange);
			}
			dataChanged = true;
			_dataProvider = _datas;
			if(_dataProvider){
				_dataProvider.addEventListener(DataChangeEvent.DATA_CHANGE, onDataChange, false, 0, true);
				_dataProvider.addEventListener(DataChangeEvent.PRE_DATA_CHANGE, onPreChange, false, 0, true);
				invalidateDisplayList();
			}else{
				_dataProvider.removeAll();
			}
		}
		
		public function get dataProvider():TreeDataProvider{
			return _dataProvider;	
		}
		
		public function scrollToItem(treeNode:TreeNode):void{
			if(treeNode){
				var index:int = _dataProvider.getItemIndex(treeNode);
				if(index != -1){
					selectedItem = treeNode;
					validateNow();
					vScrollPosition = index*rowHeight;
				}
			}
		}
		
		private function onDataChange(event:DataChangeEvent):void{
			var i:uint;
			var startIndex:int = event.startIndex;
			var endIndex:int = event.endIndex;
			var changeType:String = event.changeType;
			if (changeType == DataChangeType.INVALIDATE_ALL){
				clearSelection();
			}
			else if (changeType == DataChangeType.INVALIDATE){
				i = 0;
				while (i++ < event.items.length){
					invalidateItem(event.items[i]);
				}
			}
			else if (changeType == DataChangeType.ADD){
//				if(_selectedIndex > 0){
//					_selectedIndex = _selectedIndex + (startIndex - endIndex);
//				}
			}
			else if (changeType == DataChangeType.REMOVE){
//				if(_selectedIndex > 0){
//					_selectedIndex = _selectedIndex - (startIndex - endIndex + 1);
//				}
			}
			else if (changeType == DataChangeType.REMOVE_ALL){
				clearSelection();
			}
			else if (changeType == DataChangeType.REPLACE){
			}
			else{
			}
			invalidateList();
		}
		
		private function onPreChange(event:DataChangeEvent):void{
			switch(event.changeType){
				case DataChangeType.REMOVE:
				case DataChangeType.ADD:
				case DataChangeType.INVALIDATE:
				case DataChangeType.REMOVE_ALL:
				case DataChangeType.REPLACE:
				case DataChangeType.INVALIDATE_ALL:{
					break;
				}
				default:{
				}
			}
		}
		
		private function clearSelection():void{
			_selectedIndex = -1;
			_selectedItem = null;
			selectedRenderer = null;
		}
		
		private var redrawList:Boolean = false;
		public function invalidateList():void{
			redrawList = true;
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
				if(_selectedIndex >= 0){
					var tempItem:TreeNode = dataProvider.getItemAt(selectedIndex) as TreeNode;
					if(tempItem != _selectedItem){
						_selectedItem = tempItem;
						selectedItemChanged = true;
					}
				}
			}else if(dataProvider == null){
				_selectedIndex = -1;
				_selectedItem = null;
			}
			if(selectedItemChanged){
				selectedItemChanged = false;
				if(selectedRenderer){
					selectedRenderer.selected = false;
				}
				if(selectedItem && selectedItem.nodeType == TreeNode.LEAF_NODE || allowSelectBranch){
					var cell:ICellRenderer = renderedItems[selectedItem];
					if(cell){
						cell.selected = true;
						setSelectItem(cell);
						selectedRenderer = cell;
					}
				}else{
					setSelectItem(null,false);
				}
				dispatchChangeEvent();
			}
		}

		override protected function contentChanged():void{}
		
		protected function drawList(invidate:Boolean=true):void{
			var i:uint;
			var listData:Object;
			var cellRender:ICellRenderer;
			var cellSprite:Sprite;
			var start:int = Math.floor( vScrollPosition / rowHeight);
			if(!invidate && start == startIndex)return;
			startIndex = start;
			selectedRenderer = null;
			var length:int = _dataProvider ? _dataProvider.length : 0;
			var end:int = Math.min(length, start + rowCount + 1);
			var useItems:Dictionary= new Dictionary(true);
			renderedItems = new Dictionary(true);
			i = start;
			setSelectItem(null,false);
			while (i < end){
				useItems[_dataProvider.getItemAt(i)] = true;
				i++;
			}
			while (activeCellRenderers.length > 0){	
				cellRender = activeCellRenderers.pop() as ICellRenderer;
				listData = cellRenderer.data;
				if (useItems[listData] == null || invalidItems[listData] == true){
					availableCellRenderers.push(cellRender);
				}else{
					renderedItems[listData] = cellRender;
					invalidItems[listData] = true;
				}
				removeChild(cellRender as DisplayObject);
			}
			i = start;
			invalidItems = new Dictionary(true);
			while (i < end){
				listData = _dataProvider.getItemAt(i);
				if (renderedItems[listData] != null){
					cellRender = renderedItems[listData];
					cellSprite = cellRender as Sprite;
					delete renderedItems[listData];
				}else if (availableCellRenderers.length > 0){
					cellRender = availableCellRenderers.pop() as ICellRenderer;
					cellSprite = cellRender as Sprite;
				}else{
					var factory:ClassFactory = new ClassFactory(cellRenderer);
					cellRender = factory.newInstance() as ICellRenderer;
					cellSprite = cellRender as Sprite;
					if (cellSprite != null){
						cellSprite.addEventListener(MouseEvent.MOUSE_UP, handleCellRendererClick, false, 0, true);
						cellSprite.doubleClickEnabled = true;
						cellSprite.addEventListener(MouseEvent.DOUBLE_CLICK, handleCellRendererDoubleClick, false, 0, true);
					}
				}
				addChild(cellSprite);
				activeCellRenderers.push(cellRender);
				renderedItems[listData] = cellRender;
				cellSprite.y = rowHeight * (i - start);
				var scrollWidth:Number = vScrollBar ? vScrollBar.width : 0;
				cellRender.setSize(width - scrollWidth, rowHeight);
				cellRender.data = listData;
				if(listData == selectedItem && selectedItem.nodeType == TreeNode.LEAF_NODE || allowSelectBranch){
					_selectedIndex = i;
					selectedRenderer = cellRender;
					cellRender.selected = true;
					setSelectItem(selectedRenderer);
				}else{
					cellRender.selected = false;
				}
				i++;
			}
		}
			
		public function get rowCount() : uint{
			return Math.ceil(height/rowHeight);
		}
		
		public function invalidateItem(item:Object):void{
			if (renderedItems[item] == null){
				return;
			}
			invalidItems[item] = true;
		}
				
		override protected function getContentSize():Array{
			var h:Number = 0;
			if(_dataProvider){
				var module:Number = height%rowHeight == 0 ? 0 : rowHeight;
				h = _dataProvider.length*rowHeight + module;
			}
			return [width,h];
		}
		
		private function handleCellRendererClick(event:MouseEvent):void{
			var cellRender:ICellRenderer = event.currentTarget as ICellRenderer;
			var treeNode:TreeNode = cellRender.data as TreeNode;
			if(treeNode){
				var branchNode:BranchNode = treeNode as BranchNode;
				if(branchNode){
					branchNode.isOpen() ? branchNode.closeNode() : branchNode.openNode();
				}
				var index:int = _dataProvider.getItemIndex(treeNode);
				if(treeNode != _selectedItem && treeNode.nodeType == TreeNode.LEAF_NODE || allowSelectBranch){
					if(selectedRenderer){
						selectedRenderer.selected = false;
					}
					cellRender.selected = true;
					setSelectItem(cellRender);
					selectedRenderer = cellRender;
					_selectedIndex = index;
					_selectedItem = treeNode;
					dispatchChangeEvent();
				}
				var evt:ItemEvent = new ItemEvent(ItemEvent.ITEM_CLICK);
				evt.selectItem = treeNode;
				dispatchEvent(evt);
			}
		}
		
		private function dispatchChangeEvent():void{
			var evt:ItemEvent = new ItemEvent(ItemEvent.ITEM_CHANGE);
			evt.selectItem = selectedItem;
			evt.selectIndex = selectedIndex;
			dispatchEvent(evt);
		}
		
		private function handleCellRendererDoubleClick(event:MouseEvent):void{
			var cellRender:ICellRenderer = event.currentTarget as ICellRenderer;
			var treeNode:TreeNode = cellRender.data as TreeNode;
			if(treeNode){
				var evt:ItemEvent = new ItemEvent(ItemEvent.ITEM_DOUBLE_CLICK);
				evt.selectItem = treeNode;
				dispatchEvent(evt);
			}
		}
		
		private function setSelectItem(renderer:ICellRenderer,selected:Boolean=true):void{
			if(renderer && selected){
				if(!contains(selectedSkin)){
					rawChildren.addChild(selectedSkin);
					if(autoJustSize){
						selectedSkin.height = rowHeight;
					}
				}
				if(vScrollBar){
					selectedSkin.width = width - vScrollBar.width-itemSkinRight;
				}else{
					selectedSkin.width = width-itemSkinRight;
				}
				selectedSkin.x = DisplayObject(renderer).x+itemSkinLeft;
				selectedSkin.y = DisplayObject(renderer).y + (rowHeight - selectedSkin.height)/2;
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
				var cellRender:ICellRenderer = child as ICellRenderer;
				var branchNode:BranchNode = cellRender.data as BranchNode;
				if(branchNode && allowSelectBranch == false){
					onMouseOut(null);
					return;
				}
				if(!contains(overSkin)){
					rawChildren.addChild(overSkin);
					if(autoJustSize){
						overSkin.height = rowHeight;
					}
				}
				overSkin.x = child.x+itemSkinLeft;
				overSkin.y = child.y + (rowHeight - overSkin.height)/2;
				if(vScrollBar){
					overSkin.width = width - vScrollBar.width-itemSkinRight;
				}else{
					overSkin.width = width-itemSkinRight;
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
		
		private function getCurrentChild():DisplayObject{
			var hh:Number = 0;
			for each(var child:DisplayObject in activeCellRenderers){
				if(mouseY < child.y + rowHeight){					
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
		
		
	}
}
