package com.ming.ui.controls
{
	import com.ming.core.IDataRenderer;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.treeList.events.DataChangeEvent;
	import com.ming.ui.containers.treeList.events.DataChangeType;
	import com.ming.ui.controls.accordion.AccordionDataProvider;
	import com.ming.ui.controls.accordion.AccordionNode;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class AccordionList extends UIComponent
	{
		public var branchItemRenderer:Class;
		public var leafItemRenderer:Class;
		public var branchWidth:Number = 100;
		public var branchHeight:Number = 25;
		public var leafWidth:Number = 80;
		public var leafHeight:Number = 25;
		public var vpadding:Number = 1;
		public var isOpen:Boolean = false;
		public var itemDoubleClickEnabled:Boolean;
		
		private var branchs:Array;
		private var nodeLists:Dictionary;
		private var _openNode:AccordionNode;
		public function AccordionList()
		{
			super();
		}
			
		
		private var dataChanged:Boolean = false;
		private var _dataProvider:AccordionDataProvider;
		public function set dataProvider(_datas:AccordionDataProvider):void{
			if(_dataProvider){
				_dataProvider.removeEventListener(DataChangeEvent.DATA_CHANGE, onDataChange);
			}
			dataChanged = true;
			_dataProvider = _datas;
			if(_dataProvider){
				_dataProvider.addEventListener(DataChangeEvent.DATA_CHANGE, onDataChange, false, 0, true);
				invalidateDisplayList();
			}
		}
		
		public function get dataProvider():AccordionDataProvider{
			return _dataProvider;
		}
		
		private var selectNodeChanged:Boolean = false;
		private var _selectNode:AccordionNode;
		public function set selectNode(node:AccordionNode):void{
			if(_selectNode != node){
				_selectNode = node;
				selectNodeChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get selectNode():AccordionNode{
			return _selectNode;	
		}
		
		private function onDataChange(event:DataChangeEvent):void{
			var i:uint;
			var startIndex:int = event.startIndex;
			var endIndex:int = event.endIndex;
			var changeType:String = event.changeType;
			if (changeType == DataChangeType.INVALIDATE_ALL){
				var accordionNode:AccordionNode = event.items[0];
				var list:List = nodeLists[accordionNode]
				if(list){
					list.dataProvider = accordionNode.childs;
				}
			}else if (changeType == DataChangeType.INVALIDATE){
				var node:AccordionNode = event.items[0];
				invidateItem(node);
			}else if (changeType == DataChangeType.CHANGE){
				dataChanged = true;
				invalidateDisplayList();
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(dataChanged){
				dataChanged = false;
				removeChildren();
				if(_dataProvider && _dataProvider.length > 0){
					createChildren();
				}
			}
			if(selectNodeChanged){
				selectNodeChanged = false;
				if(_selectNode){
					if(_selectNode.type == AccordionNode.BRANCH){
						openNodes(_selectNode);
					}
				}
			}
		}
		
		public function invidateItem(node:AccordionNode):void{
			if(node.type == AccordionNode.BRANCH){
				for each(var renderer:IDataRenderer in branchs){
					if(renderer.data == node){
						renderer.data = node;
						break;
					}
				}
			}else{
				var list:List = nodeLists[node.parent];
				if(list){
					list.refreshItem(node);
				}
			}
		}
		/**
		 *构建子对象 
		 * 
		 */		
		protected function createChildren():void{
			branchs = [];
			nodeLists = new Dictionary();
			for each(var nodeData:AccordionNode in _dataProvider.toArray()){
				nodeData.type = AccordionNode.BRANCH;
				var branchItem:DisplayObject = createNode(nodeData);
				branchs.push(branchItem);
				addChild(branchItem);
			}
			layout();
		}
		/**
		 * 删除子对象 
		 * 
		 */		
		protected function removeChildren():void{
			var button:Button;
			while(branchs && branchs.length > 0){
				button = branchs.shift() as Button;
				button.dispose();
			}
			for each(var list:List in nodeLists){
				list.dispose();
			}
			branchs = null;
			nodeLists = null;
		}
		/**
		 * 布局子组件
		 */		
		protected function layout():void{
			var size:int = branchs.length;
			var startY:Number = 0;
			for(var i:int=0;i<size;i++){
				var renderer:IDataRenderer = branchs[i];
				var item:DisplayObject = renderer as DisplayObject;
				item.y = startY;
				startY += branchHeight;
				if(_openNode && renderer.data == _openNode){
					var list:List = nodeLists[_openNode];
					list.y = startY;
					list.x = width - list.width >> 1;
					startY += list.height;
				}
				startY += vpadding;
			}
		}
		
		/**
		 * 创建节点对象 
		 * @param nodeData
		 * @return 
		 * 
		 */		
		protected function createNode(nodeData:AccordionNode):DisplayObject{
			var itemNode:IDataRenderer; 
			if(nodeData.type == AccordionNode.BRANCH){
				itemNode = new  branchItemRenderer();
				itemNode.data = nodeData;
				DisplayObject(itemNode).x = width - DisplayObject(itemNode).width >> 1;
				DisplayObject(itemNode).addEventListener(MouseEvent.CLICK,clickNodeHandler);
			}
			return DisplayObject(itemNode);
		}
		/**
		 * 点击节点 
		 * @param event
		 * 
		 */		
		protected function clickNodeHandler(event:MouseEvent):void{
			var renderer:IDataRenderer = event.currentTarget as IDataRenderer;
			openNodes(renderer.data as AccordionNode);
		}
		
		/**
		 * 打开节点
		 */
		protected function openNodes(node:AccordionNode):void{
			if(_openNode == node && isOpen){
				closeNodes();
				return;
			}
			if(_openNode != node && node.type == AccordionNode.BRANCH){
				var currentList:List = nodeLists[_openNode];
				if(currentList){
					currentList.visible = false;
				}
				_openNode = node;
				_openNode.isOpen = true;
				invidateItem(_openNode);
				var list:List = nodeLists[_openNode];
				if(list == null){
					list = new List();
					list.itemDoubleClickEnabled = itemDoubleClickEnabled;
					list.itemRenderer = leafItemRenderer;
					list.itemHeight = leafHeight;
					list.width = leafWidth;
					list.height = height - (branchs.length*branchHeight+vpadding*(branchs.length-1));
					list.dataProvider = node.childs;
					list.addEventListener(ItemEvent.ITEM_CLICK,itemEventHandler);
					list.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,itemEventHandler);
					addChild(list);
					nodeLists[_openNode] = list;
				}else{
					list.visible = true;
				}
				isOpen = true;
				layout();
			}
		}
		
		private function itemEventHandler(event:ItemEvent):void{
			dispatchEvent(event.clone())
		}
		
		/**
		 * 关闭节点
		 */		
		protected function closeNodes():void{
			if(_openNode){
				_openNode.isOpen = false;
				invidateItem(_openNode);
			}
			var currentList:List = nodeLists[_openNode];
			if(currentList){
				currentList.visible = false;
			}
			isOpen = false;
			_openNode = null;
			layout();
		}
	}
}