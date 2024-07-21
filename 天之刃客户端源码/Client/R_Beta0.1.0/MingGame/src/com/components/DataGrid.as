package com.components
{
	import com.globals.GameConfig;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class DataGrid extends UIComponent
	{
		private var lines:Array;
		public var headerBar:HeaderBar;
		public var list:List;
		
		public function DataGrid()
		{
			super();
			init();
		}
		
		private function init():void{
			headerBar = new HeaderBar();
			addChild(headerBar);
			
			list = new List();
			list.scrollRow = true;
			list.bgSkin = null;
			addChild(list);
		}
		
		public function set verticalScrollPolicy(value:String):void{
			list.verticalScrollPolicy = value;	
		}
		
		private var _itemHeight:Number = 0;
		public function set itemHeight(value:Number):void{
			this._itemHeight = value;
			list.itemHeight = _itemHeight;
		}
		
		private var pageCountChanged:Boolean = false;
		private var _pageCount:int = 0;
		public function set pageCount(value:int):void{
			if(_pageCount != value){
				_pageCount = value;
				pageCountChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function addColumn(headerText:String,w:Number):void{
			headerBar.addColumn(headerText,w);
		}
		
		public function add(column:DataGridColumn):void{
			headerBar.add(column);
		}
		
		public function set itemRenderer(value:Class):void{
			if(list && value){
				list.itemRenderer = value;
			}
		}
		
		public function set dataProvider(value:Array):void{
			if(list){
				list.dataProvider = value;
			}
		}
		
		override public function set width(value:Number):void{
			super.width = value;
			if(list){
				list.width = width;
			}
		}
		
		override public function set height(value:Number):void{
			super.height = value;
			if(list){
				list.height = height - 23;
			}
		}
		
		public function createColumn(headText:String,w:Number,label:String,sortable:Boolean=true):DataGridColumn{
			var column:DataGridColumn = new DataGridColumn(label,w);
			column.headerText = headText;
			column.sortable = sortable;
			return column;
		}
		
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			headerBar.x = headerBar.y = 0;
			headerBar.width = width;
			
			list.y = 23; 
			list.width = width;
			list.height = height - 23;
			
			if(pageCountChanged){
				pageCountChanged = false;
				while(lines && lines.length > 0){
					var child:Sprite = lines.shift() as Sprite;
					if(child && child.parent){
						child.parent.removeChild(child);
					}
				}
				lines = []
				for(var i:int=1;i<_pageCount;i++){
					var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
					line.y = i*_itemHeight + 23;
					line.width = width;
					if(bgSkin){
						addChildAt(line,1);
					}else{
						addChildAt(line,0);
					}
					lines.push(line);
				}
			}
		}
		
		override public function validateNow():void{
			super.validateNow();
			list.validateNow();
		}
		
	}
}