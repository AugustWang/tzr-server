package com.ming.ui.containers
{
	import com.ming.core.ClassFactory;
	import com.ming.core.IDataRenderer;
	import com.ming.core.IDisposable;
	import com.ming.core.IFactory;
	import com.ming.events.ItemEvent;
	import com.ming.events.ResizeEvent;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	/**
	 * 网格布局容器
	 */ 
	public class TileList extends Container
	{
		private var _rowsCount:int = 0; //行数
		private var _columnsCount:int = 0; //列数
		private var _hPadding:Number = 5; //水平间距
		private var _vPadding:Number = 5; //垂直间距
		
		private var _itemWidth:Number = 60; //网格宽度
		private var _itemHeight:Number = 60; //网格高度
		private var layoutChanged:Boolean = false; 
		
		private var dataChanged:Boolean = false; //数据和项目渲染器发生改变
		
		private var _dataProvider:Array; //数据提供者
		private var _itemRender:Class; //渲染项 必须实现IdataRender接口
		private var _paddingLeft:Number = 0 ; //内容距左边的距离
		private var _paddingTop:Number = 0; //内容距上边的距离
		private var _paddingRight:Number = 0; //内容距右边的距离
		private var _paddingBottom:Number = 0;//内容距底部的距离
		public var itemDoubleClickEnabled:Boolean = false;
		public function TileList()
		{
			super();
		}
		
		public function set paddingRight(value:Number):void{
			if(_paddingRight != value){
				_paddingRight = value;
				layoutChanged = true;
				invalidateDisplayList();				
			}
		}
		public function get paddingRight():Number{
			return this._paddingRight;
		}
		
		public function set paddingBottom(value:Number):void{
			if(_paddingBottom != value){
				_paddingBottom = value;
				layoutChanged = true;
				invalidateDisplayList();				
			}
		}
		public function get paddingBottom():Number{
			return this._paddingBottom;
		}
		
		public function set hPadding(value:Number):void{
			if(_hPadding != value){
				_hPadding = value;
				layoutChanged = true;
				invalidateDisplayList();				
			}
		}
		public function get hPadding():Number{
			return this._hPadding;
		}
		
		public function set vPadding(value:Number):void{
			if(_vPadding != value){
				_vPadding = value;
				layoutChanged = true;
				invalidateDisplayList();				
			}			
		}
		public function get vPadding():Number{
			return this._vPadding;
		}
		
		public function set paddingLeft(value:Number):void{
			if(_paddingLeft != value){
				_paddingLeft = value;
				layoutChanged = true;
				invalidateDisplayList();			
			}
		}
		public function get paddingLeft():Number{
			return this._paddingLeft;
		}
		
		public function set paddingTop(value:Number):void{
			if(_paddingTop != value){
				_paddingTop = value;
				layoutChanged = true;
				invalidateDisplayList();				
			}
		}
		public function get paddingTop():Number{
			return this._paddingTop;
		}
		
		public function set rowCount(value:int):void{
			if(_rowsCount != value){
				this._rowsCount = value;
				layoutChanged = true;
				invalidateDisplayList();
			}
		}
		public function get rowCount():int{
			return this._rowsCount;
		}
		
		public function set columnCount(value:int):void{
			if(_columnsCount != value){
				this._columnsCount = value;
				layoutChanged = true;
				invalidateDisplayList();
			}
		}
		public function get columnCount():int{
			return this._columnsCount;
		}
		
		public function set itemWidth(value:int):void{
			if(_itemWidth != value){
				this._itemWidth = value;
				layoutChanged = true;
				invalidateDisplayList();
			}
		}
		public function get itemWidth():int{
			return this._itemWidth;
		}
		
		public function set itemHeight(value:int):void{
			if(_itemHeight != value){
				this._itemHeight = value;
				layoutChanged = true;
				invalidateDisplayList();
			}
		}
		public function get itemHeight():int{
			return this._itemHeight;
		}		

		public function set dataProvider(value:Array):void{
			this._dataProvider = value;
			dataChanged = true;
			layoutChanged = true;
			invalidateDisplayList();				
		}
		public function get dataProvider():Array{
			return this._dataProvider;
		}
		
		public function set itemRender(value:Class):void{
			if(value){
				this._itemRender = value; 
				dataChanged = true;
				invalidateDisplayList();				
			}
		}
		public function get itemRender():Class{
			return this._itemRender;
		}						
		
		private function createChildren():void{
			if(!dataProvider)return;
			 var _factory:IFactory = new ClassFactory(itemRender);
			 var size:int = dataProvider.length;
			for(var i:int;i<size;i++){
				var child:IDataRenderer = _factory.newInstance();
				var disChild:DisplayObject = DisplayObject(child);
				child.data = dataProvider[i];
				disChild.addEventListener(MouseEvent.CLICK,itemHandler);
				disChild.addEventListener(MouseEvent.MOUSE_DOWN,itemHandler);
				disChild.addEventListener(MouseEvent.ROLL_OVER,itemHandler);
				disChild.addEventListener(MouseEvent.ROLL_OUT,itemHandler);
				if(itemDoubleClickEnabled){
					disChild["doubleClickEnabled"] = itemDoubleClickEnabled;
					disChild.addEventListener(MouseEvent.DOUBLE_CLICK,itemHandler);
				}
				addChild(disChild);
			}
		}
		
		private function updateLayout():void{
			var size:int = numChildren;
			if(_rowsCount == 0 && _columnsCount == 0){
				_columnsCount = 4;
			}
			if(_columnsCount==0 && _rowsCount > 0){
				_columnsCount = Math.ceil(size / _rowsCount);
			}
			if(_rowsCount == 0 && _columnsCount > 0){
				_rowsCount = Math.ceil(size / _columnsCount);
			}
			for(var i:int = 0 ; i < size;i++){
				var disChild:DisplayObject = getChildAt(i);
				var row:int = i / _columnsCount;
				var column:int = i % _columnsCount;
				disChild.x = column*itemWidth + column*_hPadding + paddingLeft;
				disChild.y = row*itemHeight + row*_vPadding + paddingTop;
			}		
		}
		
		private function itemHandler(event:MouseEvent):void{
			var type:String;
			switch(event.type){
				case MouseEvent.CLICK:type = ItemEvent.ITEM_CLICK;break;
				case MouseEvent.MOUSE_DOWN:type = ItemEvent.ITEM_MOUSE_DOWN;break;
				case MouseEvent.ROLL_OVER:type = ItemEvent.ITEM_ROLL_OVER;break;
				case MouseEvent.ROLL_OUT:type = ItemEvent.ITEM_ROLL_OUT;break;
				case MouseEvent.DOUBLE_CLICK:type = ItemEvent.ITEM_DOUBLE_CLICK;break;
			}
			var itemEvent:ItemEvent = new ItemEvent(type);	
			itemEvent.selectItem = event.currentTarget;
			itemEvent.selectIndex = getChildIndex(itemEvent.selectItem as DisplayObject);
			dispatchEvent(itemEvent);
		}
		
		private function removeAllItem():void{
			while(numChildren > 0){
				var child:DisplayObject = getChildAt(0);
				if(child is IDisposable){
					IDisposable(child).dispose();
				}
				if(child.parent){
					child.parent.removeChild(child);
				}
			}
		}

		protected override function onReisze(event:ResizeEvent):void{
			super.onReisze(event);
			updateLayout();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			if(dataChanged){
				dataChanged = false;
				removeAllItem();
				createChildren();
			}
			if(layoutChanged){
				layoutChanged = false;
				updateLayout();
			}
			super.updateDisplayList(w,h);
		}
		
		override protected function getContentSize():Array{
			var w:Number = _itemWidth*_columnsCount + hPadding*(_columnsCount-1) + paddingLeft + paddingRight;
			var h:Number = _itemHeight*_rowsCount + vPadding*(_rowsCount-1) + paddingBottom + paddingTop;
			return [w,h];
		}
	}
}