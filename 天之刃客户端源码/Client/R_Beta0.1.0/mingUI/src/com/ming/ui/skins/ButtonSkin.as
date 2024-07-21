package com.ming.ui.skins
{
	import com.ming.ui.controls.Button;
	import com.ming.ui.style.BitmapDataPool;
	import com.ming.utils.ScaleShape;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * 按钮皮肤类
	 */ 	
	public class ButtonSkin extends Skin
	{
		private var overBitmap:ScaleShape;
		private var downBitmap:ScaleShape;
		private var skinBitmap:ScaleShape;
		private var selectedBitmap:ScaleShape;
		private var disableBitmap:ScaleShape;

		public var overSkin:BitmapData;
		public var downSkin:BitmapData;
		public var skin:BitmapData;
		public var disableSkin:BitmapData;
		public var selectedSkin:BitmapData;
		
		public var color:int = -1;
		public var overColor:int = -1;
		public var downColor:int = - 1;
		public var selectedColor:int = -1;
		
		public var topPadding:int;
		public var rect:Rectangle;
		
		private var currentBitmap:ScaleShape;
		
		public var soundFunc:Function;
		public function ButtonSkin()
		{
			super(null);
			mouseEnabled =  true;
			mouseChildren = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			addEventListener(MouseEvent.ROLL_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.ROLL_OUT, mouseOutHandler);
		}
		
		private function onAddedToStage(event:Event):void{
			if(enableMouse && !selected){
				addSkin();
			}
		}
		
		/**
		 * 当组件从舞台移除时调用该方法
		 */ 
		private function onRemoveFromStage(event:Event) : void
		{
			if(stage){
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
		}
		
		private function mouseDownHandler(event:MouseEvent) : void
		{
			if(selected || !enableMouse)return;
			addDownSkin();
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			if(soundFunc != null){
				soundFunc.apply(null,null);
			}
		}
		
		private function mouseOutHandler(event:MouseEvent) : void
		{
			if(selected || !enableMouse)return;
			addSkin();
		}
		
		private function stageUpHandler(event:MouseEvent) : void
		{
			if(selected || !enableMouse)return;
			if(event.target == this){
				addOverSkin();
			}else{
				addSkin();
			}
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}

		private function mouseOverHandler(event:MouseEvent) : void
		{
			if(selected || !enableMouse)return;
			if (event.buttonDown == false)
			{
				addOverSkin();
			}
		}
		
		override public function set enableMouse(value:Boolean):void{
			super.enableMouse = value;
			if(!enableMouse){
				addDisableSkin();
			}else{
				if(_selected){
					addSelectedSkin();
				}else{
					addSkin();
				}
			}
		}
		
		private var _selected:Boolean = false;
		public function set selected(value:Boolean):void{
			if(value != _selected){
				_selected = value;
				if(_selected){
					addSelectedSkin();
				}else{
					addSkin();
				}
			}
		}
		
		public function get selected():Boolean{
			return _selected;
		}
		
		private function addOverSkin():void{
			overBitmap = updateSkin(overSkin,overBitmap);
			if(overColor != -1){
				setButtonColor(overColor);
			}
		}
		
		private function addDownSkin():void{
			downBitmap = updateSkin(downSkin,downBitmap);	
			if(downColor != -1){
				setButtonColor(downColor);
			}
		}
		
		private function addSkin():void{
			skinBitmap = updateSkin(skin,skinBitmap);
			if(color != -1){
				setButtonColor(color);
			}
		}
		
		private function addDisableSkin():void{
			disableBitmap = updateSkin(disableSkin,disableBitmap);		
		}
		
		private function addSelectedSkin():void{
			selectedBitmap = updateSkin(selectedSkin,selectedBitmap);	
			if(selectedColor != -1){
				setButtonColor(selectedColor);
			}
		}
		
		
		private function setButtonColor(color:int):void{
			var btn:Button = Button(owner);
			if(btn && color >= 0){
				btn.setTextColor(color);
			}
		}
		
		private function updateSkin(skinBitmapdata:BitmapData,skinBitmap:ScaleShape):ScaleShape{
			if(skinBitmapdata == null && skinBitmap == null)return null;
			removeAllSkin();
			if(skinBitmap == null && skinBitmapdata != null){
				skinBitmap = new ScaleShape(skinBitmapdata);
				skinBitmap.setScale9Grid(rect);
			}
			if(skinBitmap){
				if(_w != 0 && _h != 0){
					skinBitmap.setSize(_w,_h);
				}
			}
			addChild(skinBitmap);	
			currentBitmap = skinBitmap;
			return skinBitmap;
		}
		
		private function removeAllSkin():void{
			if(numChildren > 0){
				removeChildAt(0);
			}
		}
		
		private var _w:Number=0;
		private var _h:Number=0;
		override public function setSize(w:Number, h:Number):void{
			_w = w;
			_h = h;
			if(currentBitmap){
				if(_w != 0 && _h != 0){
					currentBitmap.setSize(_w,_h);
				}
			}
		}
		
		override public function get realWidth():Number{
			if(skin){
				return skin.width;
			}
			return 0;
		}
		
		override public function get realHeight():Number{
			if(skin){
				return skin.height;
			}
			return 0;
		}
	
		override public function dispose():void{
			currentBitmap = null;
		}
	}
}