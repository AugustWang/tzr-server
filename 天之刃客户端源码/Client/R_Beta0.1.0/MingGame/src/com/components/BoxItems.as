package com.components
{
	import com.common.GlobalObjectManager;
	import com.common.effect.Tween;
	import com.globals.GameConfig;
	import com.gs.TweenMax;
	import com.managers.LayerManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.Skin;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	
	public class BoxItems extends Sprite
	{
		private var button:UIComponent;
		private var leftSkin:Skin;
		private var rightSkin:Skin;
		private var runing:Boolean = false;
		private var isSmall:Boolean = false;
		public function BoxItems()
		{
			super();
			mouseEnabled = false;
//			leftSkin = Style.getButtonSkin("box_leftSkin","box_leftOverSkin","box_leftOverSkin",null,GameConfig.T1_UI);
//			rightSkin = Style.getButtonSkin("box_rightSkin","box_rightOverSkin","box_rightOverSkin",null,GameConfig.T1_UI);
			button = new UIComponent();
			button.width = 14;
			button.height = 30;
			button.bgSkin = rightSkin;
			button.addEventListener(MouseEvent.CLICK,onMouseClick);
		}
		
		private function onMouseClick(event:MouseEvent):void{
			if(runing)return;
			runing = true;
			if(x < GlobalObjectManager.GAME_WIDTH){
				TweenMax.to(this,0.5,{x:GlobalObjectManager.GAME_WIDTH,onComplete:onComplete});
				isSmall = true;
				button.bgSkin = leftSkin;
			}else{
				isSmall = false;
				var endX:int = GlobalObjectManager.GAME_WIDTH - width - button.width;
				Tween.to(this,8,{x:endX,onComplete:onComplete});
				button.bgSkin = rightSkin;
			}
		}
		
		private function onComplete():void{
			runing = false;
		}
		
		public function addIcon(icon:DisplayObject):void{
			if(!contains(icon)){
				addChild(icon);
				LayoutUtil.layoutGrid(this,4,2,2);
				if(!isSmall){
					x = GlobalObjectManager.GAME_WIDTH - width - button.width;
				}
			}
			if(numChildren > 0 && button.parent == null){
				visible  = true;
				button.x = GlobalObjectManager.GAME_WIDTH - button.width;
				button.y = y;
				button.bgSkin = rightSkin;
				LayerManager.uiLayer.addChild(button);
			}
		}
		
		public function onStageResize(value:Object):void{
			if(isSmall){
				
				x = GlobalObjectManager.GAME_WIDTH;
				button.x = GlobalObjectManager.GAME_WIDTH - button.width;
			}else{
				x = GlobalObjectManager.GAME_WIDTH - width - button.width;
				button.x = GlobalObjectManager.GAME_WIDTH - button.width;
			}
		}
		
		public function removeIcon(icon:DisplayObject):void{
			if(icon && icon.parent == this){
				removeChild(icon);
				LayoutUtil.layoutGrid(this,4,2,2);
				if(!isSmall){
					x = GlobalObjectManager.GAME_WIDTH - width - button.width;
				}
			}
			if(numChildren == 0 && button.parent){
				button.parent.removeChild(button);
			}
		}
		
		public function removeAllIcon():void{
			while(numChildren > 0){
				removeChildAt(numChildren - 1);
			}
			if(button.parent){
				button.parent.removeChild(button);
			}
		}
	}
}