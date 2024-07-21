package com.ming.ui.containers.treeList
{
	import com.ming.ui.containers.treeList.events.DataChangeEvent;
	import com.ming.ui.containers.treeList.events.DataChangeType;
	
	import flash.events.EventDispatcher;
	
	public class DataProvider extends EventDispatcher
	{
		protected var data:Array;
		public function DataProvider(values:Object = null){
			if (values == null){
				data = [];
			}else{
				data = getDataFromObject(values);
			}
		}
		
		protected function dispatchPreChangeEvent(changeType:String, items:Array, startIndex:int, endIndex:int) : void{
			dispatchEvent(new DataChangeEvent(DataChangeEvent.PRE_DATA_CHANGE, changeType, items, startIndex, endIndex));
		}
		
		public function invalidateItemAt(index:int) : void{
			checkIndex(index, data.length-1);
			dispatchChangeEvent(DataChangeType.INVALIDATE, [data[index]], index, index);
		}
		
		public function getItemIndex(item:Object) : int{
			return data.indexOf(item);
		}
		
		protected function getDataFromObject(values:Object) : Array{
			var resultArray:Array;
			var changeToArray:Array;
			var i:uint;
			var obj:Object;
			var changeToXML:XML;
			var children:XMLList;
			var itemXML:XML;
			var attrubutesXMLList:XMLList;
			var attrubutesXML:XML;
			var childXMLList:XMLList;
			var childXML:XML;
			if (values is Array){
				changeToArray = values as Array;
				if (changeToArray.length > 0){
					if (changeToArray[0] is String || changeToArray[0] is Number){
						resultArray = [];
						i = 0;
						while (i++ < changeToArray.length){
							obj = {label:String(changeToArray[i]), data:changeToArray[i]};
							resultArray.push(obj);
						}
						return resultArray;
					}
				}
				return values.concat();
			}
			else{
				if (values is DataProvider){
					return values.toArray();
				}
				if (values is XML){
					changeToXML = values as XML;
					resultArray = [];
					children = changeToXML.*;
					for each (itemXML in children){
						values = {};
						attrubutesXMLList = itemXML.attributes();
						for each (attrubutesXML in attrubutesXMLList){
							
							values[attrubutesXML.localName()] = attrubutesXML.toString();
						}
						childXMLList = itemXML.*;
						for each (childXML in childXMLList){
							if (childXML.hasSimpleContent()){
								values[childXML.localName()] = childXML.toString();
							}
						}
						resultArray.push(values);
					}
					return resultArray;
				}
			}
			throw new TypeError("Error: Type Coercion failed: cannot convert " + values + " to Array or DataProvider.");
		}
		
		public function removeItemAt(item:uint) : Object{
			checkIndex(item, data.length-1);
			dispatchPreChangeEvent(DataChangeType.REMOVE, data.slice(item, item + 1), item, item);
			var datas:Array = data.splice(item, 1);
			dispatchChangeEvent(DataChangeType.REMOVE, datas, item, item);
			return datas[0];
		}
		
		public function addItem(item:Object) : void{
			var size:int = data.length;
			dispatchPreChangeEvent(DataChangeType.ADD, [item], size--, size--);
			data.push(item);
			size = data.length;
			dispatchChangeEvent(DataChangeType.ADD, [item], size--, size--);
		}
		
		public function sortOn(item1:Object,item2:Object = null):Array{
			dispatchPreChangeEvent(DataChangeType.SORT, data.concat(), 0, data.length-1);
			var results:Array = data.sortOn(item1, item2);
			dispatchChangeEvent(DataChangeType.SORT, data.concat(), 0, data.length-1);
			return results;
		}
		
		public function sort(... args):Array{
			dispatchPreChangeEvent(DataChangeType.SORT, data.concat(), 0, data.length-1);
			var results:Array = data.sort.apply(data, args);
			dispatchChangeEvent(DataChangeType.SORT, data.concat(), 0,data.length-1);
			return results;
		}
		
		public function addItems(item:Object) : void{
			addItemsAt(item, data.length);
		}
		
		public function concat(item:Object) : void{
			addItems(item);
		}
		
		public function clone() : DataProvider{
			return new DataProvider(data);
		}
		
		public function toArray() : Array{
			return data.concat();
		}
		
		public function get length() : uint{
			return data.length;
		}
		
		public function addItemAt(item:Object, index:uint) : void{
			checkIndex(index, data.length);
			dispatchPreChangeEvent(DataChangeType.ADD, [item], index, index);
			data.splice(index, 0, item);
			dispatchChangeEvent(DataChangeType.ADD, [item], index, index);
		}
		
		public function getItemAt(index:uint) : Object{
			checkIndex(index, data.length);
			return data[index];
		}
		
		override public function toString() : String{
			return "DataProvider [" + data.join(" , ") + "]";
		}
		
		public function invalidateItem(item:Object) : void{
			var index:int = getItemIndex(item);
			if (index == -1){
				return;
			}
			invalidateItemAt(index);
		}
		
		protected function dispatchChangeEvent(changeType:String, items:Array, startIndex:int, endIndex:int) : void{
			dispatchEvent(new DataChangeEvent(DataChangeEvent.DATA_CHANGE, changeType, items, startIndex, endIndex));
		}
		
		protected function checkIndex(index:int, size:int) : void{
			if (index > size || index < 0){
				throw new RangeError("DataProvider index (" + index + ") is not in acceptable range (0 - " + size + ")");
			}
		}
		
		public function addItemsAt(item:Object, index:uint) : void{
			checkIndex(index, data.length);
			var datas:Array = getDataFromObject(item);
			var end:int = (index + datas.length);
			dispatchPreChangeEvent(DataChangeType.ADD, datas, index, end--);
			data.splice.apply(data, [index, 0].concat(datas));
			end = (index + datas.length);
			dispatchChangeEvent(DataChangeType.ADD, datas, index, end--);
		}
		
		public function replaceItem(item1:Object, item2:Object) : Object{
			var index:int = getItemIndex(item2);
			if (index != -1){
				return replaceItemAt(item1, index);
			}
			return null;
		}
		
		public function removeItem(item:Object) : Object{
			var index:int = getItemIndex(item);
			if (index != -1){
				return removeItemAt(index);
			}
			return null;
		}
		
		public function merge(item:Object) : void
		{
			var results:Array;
			var size:uint;
			var _datalength:uint;
			var i:uint;
			var item:Object;
			results = getDataFromObject(item);
			size = results.length;
			_datalength = data.length;
			dispatchPreChangeEvent(DataChangeType.ADD, data.slice(_datalength, data.length), _datalength, data.length-1);
			while (i++ < size){
				item = results[i];
				if (getItemIndex(item) == -1){
					data.push(item);
				}
			}
			if (data.length > _datalength){
				dispatchChangeEvent(DataChangeType.ADD, data.slice(_datalength, data.length), _datalength, data.length-1);
			}
			else{
				dispatchChangeEvent(DataChangeType.ADD, [], -1, -1);
			}
		}
		
		public function replaceItemAt(item:Object, index:uint) : Object{
			checkIndex(index, data.length-1);
			var datas:Array = [data[index]];
			dispatchPreChangeEvent(DataChangeType.REPLACE, datas, index, index);
			data[index] = item;
			dispatchChangeEvent(DataChangeType.REPLACE, datas, index, index);
			return datas[0];
		}
		
		public function invalidate() : void{
			dispatchEvent(new DataChangeEvent(DataChangeEvent.DATA_CHANGE, DataChangeType.INVALIDATE_ALL, data.concat(), 0, data.length));
		}
		
		public function removeAll() : void{
			var copys:Array = data.concat();
			dispatchPreChangeEvent(DataChangeType.REMOVE_ALL, copys, 0, copys.length);
			data = [];
			dispatchChangeEvent(DataChangeType.REMOVE_ALL, copys, 0, copys.length);
		}
	}
}
