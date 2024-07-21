package com.components.components
{
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.events.ResizeEvent;
	import com.ming.managers.DragManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class DragUIComponent extends UIComponent
	{
		private var dragSprite:Sprite;
		private var closeButton:UIComponent;
		public function DragUIComponent()
		{
			Style.setPopUpSkin(this);
			dragSprite = new Sprite();
			addChild(dragSprite);
			addEventListener(ResizeEvent.RESIZE,onResize);
			DragManager.register(dragSprite,this,null,DragManager.BORDER);
		}
		
		private function onResize(event:ResizeEvent):void{
			dragSprite.graphics.beginFill(0x00,0);
			dragSprite.graphics.drawRect(0,0,width,height);
			dragSprite.graphics.endFill();
		}
		
		public function unLoad():void{
			DragManager.unregister(this);
		}
		
		protected function close():void{
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}
		
		protected function wrapperButton(btn:Button):void{
			//Style.setRedBtnStyle(btn);
		}
		
		private var _showCloseButton:Boolean = false;
		public function set showCloseButton(value:Boolean):void{
			if(value != _showCloseButton){
				_showCloseButton = value;
				invalidateDisplayList();
			}
		}
		
		public function get showCloseButton():Boolean{
			return _showCloseButton;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(_showCloseButton){
				if(closeButton == null){
					closeButton = new UIComponent();
					closeButton.useHandCursor = closeButton.buttonMode = true;
					closeButton.addEventListener(MouseEvent.CLICK,onCloseHandler);
					closeButton.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI);
				}
				closeButton.validateNow();
				closeButton.x = w - closeButton.width-4;
				closeButton.y = 3;
				addChild(closeButton);
			}else if(closeButton){
				closeButton.dispose();
				closeButton = null;
			}
		}
		
		protected function onCloseHandler(event:MouseEvent):void{
			
		}
	}
}