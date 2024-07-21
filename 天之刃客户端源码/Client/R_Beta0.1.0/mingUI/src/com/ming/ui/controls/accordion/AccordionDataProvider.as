package com.ming.ui.controls.accordion
{
	import com.ming.ui.containers.treeList.events.DataChangeEvent;
	import com.ming.ui.containers.treeList.events.DataChangeType;
	
	import flash.events.EventDispatcher;
	
	public class AccordionDataProvider extends EventDispatcher
	{
		protected var data:Array;
		public function AccordionDataProvider(values:Object = null){
			if (values == null){
				data = [];
			}
		}
		
		public function addItem(item:Object):void{
			if(!isExists(item)){
				data.push(item);
				dispatchChangeEvent(DataChangeType.CHANGE);
			}
		}
		
		public function addItems(...items):void{
			data = data.concat(items);
			dispatchChangeEvent(DataChangeType.CHANGE);
		}
		
		public function addItemAt(item:Object,index:int):void{
			if(!isExists(item)){
				data[index] = item;
				dispatchChangeEvent(DataChangeType.CHANGE);
			}
		}
		
		public function removeItem(item:Object):void{
			if(isExists(item)){
				var index:int = data.indexOf(item);
				data.splice(index,1);
				dispatchChangeEvent(DataChangeType.CHANGE);
			}
		}
		
		public function invalidateItem(item:Object) : void{
			dispatchChangeEvent(DataChangeType.INVALIDATE,[item]);
		}
		
		public function invalidateAll(item:Object):void{
			dispatchChangeEvent(DataChangeType.INVALIDATE_ALL,[item]);
		}
		
		private function isExists(item:Object):Boolean{
			return data.indexOf(item) != -1;
		}
		
		protected function dispatchChangeEvent(changeType:String, items:Array=null) : void{
			dispatchEvent(new DataChangeEvent(DataChangeEvent.DATA_CHANGE, changeType,items));
		}
		
		public function toArray() : Array{
			return data.concat();
		}
		
		public function get length() : uint{
			return data.length;
		}
	}
}
