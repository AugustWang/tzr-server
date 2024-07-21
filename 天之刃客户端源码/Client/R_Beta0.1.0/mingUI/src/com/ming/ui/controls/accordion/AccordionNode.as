package com.ming.ui.controls.accordion
{
	
	
	public class AccordionNode
	{
		public static const BRANCH:String = "BRANCH";
		public static const LEAF:String = "LEAF";
		
		public var dataProvider:AccordionDataProvider;
		public var label:String;
		public var data:Object;
		public var childs:Array;
		public var type:String = LEAF;
		public var parent:AccordionNode;
		public var isOpen:Boolean;
		
		public function AccordionNode()
		{
			
		}
		
		public function addItem(node:AccordionNode):void{
			if(node == null)return;
			if(childs == null){
				childs = new Array();
			}
			node.parent = this;
			childs.push(node);
			if(dataProvider){
				dataProvider.invalidateAll(this);
			}
		}
		
		public function addItemAt(node:AccordionNode,index:int):void{
			if(node == null)return;
			if(childs == null){
				childs = new Array();
			}
			node.parent = this;
			childs.splice(index,0,node);
			if(dataProvider){
				dataProvider.invalidateAll(this);
			}
		}
		
		public function removeItem(item:AccordionNode):void{
			if(type == BRANCH && childs){
				var index:int = childs.indexOf(item);
				if(index != -1){
					childs.splice(index,1);
				}
				if(dataProvider){
					dataProvider.invalidateAll(this);
				}
			}
		}
		
		public function invalidate():void{
			if(dataProvider){
				dataProvider.invalidateItem(this);
			}
		}
		
		public function removeNode():void{
			if(dataProvider){ 
				if(type == BRANCH){
					dataProvider.removeItem(this);
				}else if(parent){
					parent.removeItem(this);
				}
			}
		}
		
		public static function createNode(label:String,data:Object,parent:AccordionNode=null):AccordionNode{
			var node:AccordionNode = new AccordionNode();
			node.label = label;
			node.data = data;
			if(parent != null){
				parent.addItem(node);
			}
			return node;
		}
	}
}