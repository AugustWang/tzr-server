package com.common.dragManager
{
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	public class DragItem extends UIComponent implements IDragItem
	{
		protected var content:*;
		protected var isIn:Boolean = false;
		public static const overBorder:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemOverBg") ;
		public function DragItem(size:int,bgName:String="packItemBg")
		{
			super();
			this.height = this.width = 36;
			this.mouseChildren = false;
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,bgName));
			addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			addEventListener(MouseEvent.ROLL_OUT,onRollOut);
		}		
		
		protected function updatePosition():void{
			if(content){
				content.x = 3;
				content.y = 3;
			}
		}
		
		protected function updateBorder(x:int,y:int):void{
			if(overBorder){
				overBorder.x = x;
				overBorder.y = y;
			}	
		}
		
		private function onRollOver(event:MouseEvent=null):void{
			isIn = true;
			rollOverHandler();
			updateBorder(-2,-2);
			addChild(overBorder);
		}
		
		private function onRollOut(event:MouseEvent=null):void{
			rollOutHandler();
			isIn = false;
			if(overBorder && overBorder.parent == this){
				removeChild(overBorder);
			}
		}
		
		protected function rollOverHandler(tipCompare:Boolean=true):void{
			if(data){
				var p:Point = new Point(x+width,y);
				p = parent.localToGlobal(p);
				ItemToolTip.show(data as BaseItemVO,p.x,p.y,tipCompare);
			}
		}
		
		protected function rollOutHandler():void{
			hideTip();
		}
		
		protected function showTip():void{
			if(isIn){
				onRollOver();
			} 
		}
		
		public function hideTip():void{
			if(isIn && data){
				ItemToolTip.hide();
			}
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				createContent();
			}
		}
		
		protected function createContent():void{
			updatePosition();
		}
		
		public function setContent(_content:*,_data:*):void{
			content = _content;
			setData(_data);
			addChild(_content);
			updatePosition();
			showTip();
		}		
		
		public function getContent():*{		
			return content;
		}
		
		public function setData(value:*):void{
			super.data = value;
		}
		
		public function disposeContent():void{
			hideTip();
			if(content && contains(content)){
				removeChild(content);
			}
			content = null;
			setData(null);
			
		}
		
		public function allowAccept(data:Object,name:String):Boolean{
			return true;
		}
		
		public function dragDrop(dragData:Object,dragTarget:DisplayObject,itemName:String):void{
			
		}
		
		public function getItemName():String{
			return "";
		}
	}
}