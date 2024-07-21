package com.ming.ui.controls
{
	import com.gs.TweenLite;
	import com.ming.ui.containers.Container;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObject;
	
	public class TabContainer extends UIComponent
	{
		public var isTween:Boolean = true;
		private var indexChanged:Boolean = false;
		private var _index:int = 0;
		private var _list:Array;
		
		private var currentView:DisplayObject;
		public function TabContainer()
		{
			_list = [];
			bgAlpha = 0;
		}
		
		public function getDisplayObjectIndex(displayObject:DisplayObject):int{
			var l:int = _list.length;
			for(var i:int=0; i < l; i++){
				if(_list[i] == displayObject){
					return i;
				}
			}
			return -1;
		}
		
		public function getDisplayObject(index:int) : DisplayObject
		{
			if (index >= 0 && _list.length > 0 && index < _list.length)
			{
				return _list[index];
			}
			return null;
		}
		
		public function set selectIndex(index:int) : void
		{
			if (index >= 0 && _list.length > 0 && index < _list.length)
			{
				_index = index;
				indexChanged = true;
				invalidateDisplayList();
				validateNow();
			}
		}
		public function get selectIndex() : int
		{
			return _index;
		}
		
		public function addItem(obj:DisplayObject,index:Number=-1) : void
		{
			if(index == -1){
				_list.push(obj);
			}else{
				_list.splice(index,0,obj);
			}
		}
		
		public function removeItems():void{
			_list = [];
		}
		
		public function removeItemByIndex(index:int):void{
			_list.splice(index,1);
		}
		
		private function updateDisplayContainer() : void
		{
			var newView:DisplayObject = _list[selectIndex] as DisplayObject;
			if(newView == currentView){
				return;
			}
			if(currentView && currentView.parent){
				removeChild(currentView);
			}
			currentView = newView;
			if(isTween){
				currentView.alpha = 0;
			}
			addChild(currentView);
			if(isTween){
				TweenLite.to(currentView, 1, {alpha:1});
			}
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void
		{
			super.updateDisplayList(w, h);
			if (indexChanged)
			{
				updateDisplayContainer();
				indexChanged = false;
			}
		}
	}
}