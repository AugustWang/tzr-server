package com.ming.ui.controls
{
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.accordion.AccordionNode;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.AccordionSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	public class Accordion extends UIComponent
	{
		public var branchWidth:Number = 100;
		public var branchHeight:Number = 25;
		public var leafWidth:Number = 80;
		public var leafHeight:Number = 25;
		public var containerHeight:Number = 100;
		public var vpadding:Number = 1;
		public var isOpen:Boolean = false;
	
		private var pools:Array;
		private var branchs:Array;
		private var nodes:Dictionary; 
		private var leafContainer:Sprite;
		private var selectedButton:ToggleButton;
		public function Accordion()
		{
			width = branchWidth;
			nodes = new Dictionary();	
			pools = new Array();
			leafContainer = new Sprite();
			leafContainer.mouseEnabled = false;
			addChild(leafContainer);
			if(StyleManager.accordionSkin){
				accordionSkin = StyleManager.accordionSkin;
			}
		}
		
		private var dataChanged:Boolean = false;
		private var _dataProvider:Array;
		public function set dataProvider(_datas:Array):void{
			dataChanged = true;
			_dataProvider = _datas;
			invalidateDisplayList();
		}
		
		public function get dataProvider():Array{
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
		
		private var _accordionSkin:AccordionSkin;
		public function set accordionSkin(skin:AccordionSkin):void{
			_accordionSkin = skin;
		}
		
		public function get accordionSkin():AccordionSkin{
			return _accordionSkin;
		}
		
		private var _openNode:AccordionNode;
		public function get openNode():AccordionNode{
			return _openNode;
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
				var changeEvent:ItemEvent = new ItemEvent(ItemEvent.ITEM_CHANGE);
				changeEvent.selectItem = _selectNode;
				dispatchEvent(changeEvent);
				if(_selectNode){
					if(_selectNode.type == AccordionNode.BRANCH){
						openNodes(_selectNode);
					}else if(_selectNode.type == AccordionNode.LEAF){
						openNodes(_selectNode.parent);
					}
					toggleButtons();
				}
			}
		}
		/**
		 *构建子对象 
		 * 
		 */		
		protected function createChildren():void{
			branchs = [];
			for each(var nodeData:AccordionNode in _dataProvider){
				nodeData.type = AccordionNode.BRANCH;
				var branchButton:Button = createNodeButton(nodeData);
				branchs.push(branchButton);
				addChild(branchButton);
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
			while(leafContainer.numChildren > 0){
				button = leafContainer.getChildAt(0) as Button;
				button.dispose();
			}
			pools = [];
			branchs = null;
			nodes = new Dictionary();
		}
		/**
		 * 创建节点对象（Flex的Accordion不是这样设计的，目前只是为了更方便实用） 
		 * @param nodeData
		 * @return 
		 * 
		 */		
		protected function createNodeButton(nodeData:AccordionNode):Button{
			var button:ToggleButton = pools.shift(); 
			if(button == null){
				button = new ToggleButton();
			}
			if(nodeData.type == AccordionNode.BRANCH){
				if(_accordionSkin){
					_accordionSkin.branchSkin(button);
				}
				button.width = branchWidth;
				button.height = branchHeight;
			}else{
				if(_accordionSkin){
					_accordionSkin.leafSkin(button);
				}
				button.width = leafWidth;
				button.height = leafHeight;
			}
			button.label = nodeData.label;
			button.data = nodeData;
			nodes[nodeData] = button;
			button.addEventListener(MouseEvent.CLICK,clickNodeHandler);
			return button;
		}
		/**
		 * 处理节点单击事件 
		 * @param event
		 * 
		 */		
		protected function clickNodeHandler(event:MouseEvent):void{
			var button:ToggleButton = event.currentTarget as ToggleButton;
			if(button.data != _selectNode){
				_selectNode = button.data as AccordionNode;
				var changeEvent:ItemEvent = new ItemEvent(ItemEvent.ITEM_CHANGE);
				changeEvent.selectItem = button.data;
				dispatchEvent(changeEvent);
				if(_selectNode.type == AccordionNode.BRANCH){
					if(_openNode == _selectNode){
						closeNodes();
					}else{
						openNodes(_selectNode);
					}
				}
			}else if(_selectNode.type == AccordionNode.BRANCH){
				if(isOpen){
					closeNodes();
				}else{
					openNodes(_selectNode)
				}
			}
			toggleButtons();
			var itemEvent:ItemEvent = new ItemEvent(ItemEvent.ITEM_CLICK);
			itemEvent.selectItem = button.data;
			dispatchEvent(itemEvent);
		}
		
		/**
		 * 打开节点
		 */
		protected function openNodes(node:AccordionNode):void{
			if(_openNode != node && node.type == AccordionNode.BRANCH){
				_openNode = node;
				while(leafContainer.numChildren > 0){
					pools.push(leafContainer.removeChildAt(0));
				}
				var childs:Array = node.childs;
				for each(var nodeData:AccordionNode in childs){
					nodeData.type = AccordionNode.LEAF;
					leafContainer.addChild(createNodeButton(nodeData));
				}
				LayoutUtil.layoutVectical(leafContainer);
				isOpen = true;
				layout();
			}
		}
		/**
		 * 关闭节点
		 */		
		protected function closeNodes():void{
			while(leafContainer.numChildren > 0){
				pools.push(leafContainer.removeChildAt(0));
			}
			isOpen = false;
			_openNode = null;
			layout();
		}
		
		/**
		 * 调整选中的按钮状态
		 */		
		protected function toggleButtons():void{
			var button:ToggleButton = nodes[_selectNode];
			if(button && button != selectedButton){
				if(selectedButton){
					selectedButton.selected = false;
				}
				button.selected = true;
				selectedButton = button;
			}
		}
		
		/**
		 * 布局子组件
		 */		
		protected function layout():void{
			var size:int = branchs.length;
			var startY:Number = 0;
			for(var i:int=0;i<size;i++){
				var branchButton:Button = branchs[i];
				branchButton.y = startY;
				startY += branchButton.height;
				if(_openNode && branchButton.data == _openNode){
					leafContainer.y = startY;
					leafContainer.x = branchWidth - leafWidth >> 1;
					startY += containerHeight;
				}
				startY += vpadding;
			}
		}
		
		override public function dispose():void{
			super.dispose();
			removeChildren();
		}
	}
}