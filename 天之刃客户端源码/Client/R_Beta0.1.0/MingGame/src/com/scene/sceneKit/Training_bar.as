package com.scene.sceneKit {
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import modules.ModuleCommand;

	public class Training_bar extends Sprite {
		private var bg:Skin;
		private var bar:Bitmap;

		public function Training_bar() {
			super();
			this.name="TrainBar"
			initView();
		}

		private function initView():void {
			bg=new Skin(Style.getUIBitmapData(GameConfig.T1_VIEWUI, "Training_bg"));
			bg.x=-bg.width / 2; //166/2
			addChild(bg);
			bar=new Bitmap;
			bar.bitmapData=Style.getUIBitmapData(GameConfig.T1_VIEWUI, "Training_bar");
			bar.x=bg.x + 17;
			bar.y=42;
			bar.scaleX=0;
			addChild(bar);
			bg.y-=108;
			bar.y-=108;
			this.buttonMode=true;
			this.addEventListener(MouseEvent.CLICK, onClickBar);
			this.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);
		}
		
		private function onMouseOver(e:Event):void
		{
			if (bg) {
				this.bg.filters = [new GlowFilter(0xffffff)];
			}
		}
		
		private function onMouseOut(e:Event):void
		{
			if (bg) {
				this.bg.filters = [];
			}
		}
		
		private function onClickBar(e:Event):void
		{
			Dispatch.dispatch(ModuleCommand.OPEN_TRAIN);
		}


		public function update(percent:Number):void {
			bar.scaleX=percent;

		}
	}
}