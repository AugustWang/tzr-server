package com.components
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	public class HeaderBar extends UIComponent
	{
		private var sortField:String;
		private var isDescending:Boolean = true;
		private var sortButtons:Array;
		public function HeaderBar()
		{
			super();
			titles = [];
			textFormat = Style.textFormat;
			textColor = 0xFFFFFF;
			bgSkin = Style.getSkin("titleBar",GameConfig.T1_VIEWUI,new Rectangle(15,10,138,2));//
		}
		
		private function createLine(x:int):Bitmap{
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"vline");
			line.x = x;
			line.y = 4;
			addChild(line);
			return line;
		}
		
		private var _tf:TextFormat;
		public function set textFormat(value:TextFormat):void{
			this._tf = value;
		}
		
		public function get textFormat():TextFormat{
			return _tf;
		}
		
		private var _color:uint;
		public function set textColor(value:uint):void{
			_color = value;
			_tf.color = _color;
		}
		
		private var titles:Array;
		private var startX:Number = 0;
		private var createChildChanged:Boolean = false;
		public function add(column:DataGridColumn):void{
			titles.push(column);
			createChildChanged = true;
			invalidateDisplayList();
		}
		
		public function addColumn(headerText:String,w:Number):void{
			var column:DataGridColumn = new DataGridColumn("",w);
			column.headerText = headerText;
			add(column);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(createChildChanged){
				createChildChanged = false;
				startX = 0;
				sortButtons = [];
				var size:int = titles.length;
				for(var i:int=0;i<size;i++){
					var desc:DataGridColumn = titles[i] as DataGridColumn;
					_tf.align = "center";
					if(desc.sortable){
						var sortButton:SortButton = new SortButton();
						var sortWidth:Number = i != size - 1 ? desc.width-2 : desc.width-4;
						sortButton.width = sortWidth;
						sortButton.height = 20;
						sortButton.x = startX+2;
						sortButton.y = 1;
						sortButton.data = desc;
						sortButton.useHandCursor = sortButton.buttonMode = true;
						sortButton.addEventListener(MouseEvent.CLICK,onMouseClick);
						addChild(sortButton);
						sortButtons.push(sortButton);
					}
					var text:TextField = ComponentUtil.createTextField(desc.headerText,startX,2,_tf,desc.width,25,this);
					startX += desc.width;
					if(i != titles.length - 1){
						createLine(startX);
					}
				}
			}
		}
		
		private function onMouseClick(event:MouseEvent):void{
			var sortButton:SortButton = event.currentTarget as SortButton;
			var dataGrid:DataGrid = parent as DataGrid;
			if(sortButton && dataGrid){
				clearOthers(sortButton);
				var column:DataGridColumn = sortButton.data as DataGridColumn;
				var dataProvider:Array = dataGrid.list.dataProvider;
				var options:* = isDescending ? Array.DESCENDING : null;
				sortButton.desc = isDescending
				if(column.sortCompareFunc != null){
					if(options){
						dataProvider.sort(column.sortCompareFunc,options);
					}else{
						dataProvider.sort(column.sortCompareFunc);
					}
				}else if(column.label != ""){
					if(column.sortOptions){
						if(options){
							options = options | column.sortOptions;
						}else{
							options = column.sortOptions;
						}
					}
					if(options){
						dataProvider.sortOn(column.label,options);
					}else{
						dataProvider.sortOn(column.label);
					}
				}else{
					dataProvider.sort(options);
				}
				isDescending = !isDescending;
				dataGrid.list.invalidateList();
			}
		}
		
		private function clearOthers(sortButton:SortButton):void{
			for each(var sort:SortButton in sortButtons){
				if(sortButton != sort){
					sort.clear();
				}
			}
		}
	}
}