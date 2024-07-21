package com.scene.sceneKit {
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.ming.utils.ScaleBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * 角色说的话
	 * @author LXY
	 *
	 */
	public class SayWords extends Sprite {
		private var startAlpha:Number=3.84;
		private var ySpeed:Number=3;
		private var alpSpeed:Number=0.02;
		private var scaleAcc:Number=-0.3;
		private var scaleSpeed:Number=1.2;
		private var format:TextFormat;
		private var txt:BubbleText;
		private var th:Number;
		private var bg:ScaleBitmap

		private var BGClass:Class;

		public function SayWords():void {
			var pic:BitmapData;
			var app:ApplicationDomain=ResourcePool.get(GameConfig.T1_VIEWUI) as ApplicationDomain;
			if(app && app.hasDefinition("MaoPao")){
				BGClass=app.getDefinition("MaoPao") as Class;
				pic=new BGClass(0, 0);
			}else{
				pic=new BitmapData(0,0);
			}
			bg=new ScaleBitmap(pic);
			var grid:Rectangle=new Rectangle(16, 16, 140, 60);
			bg.setScale9Grid(grid);
			this.addChild(bg);
			txt=new BubbleText();
			this.addChild(txt);
		}

		public function execute(words:String):void {
			if (words == "")
				return;
			txt.htmlText=words;
			txt.x=8;
			txt.y=8;
			bg.setSize(txt.width + 20, txt.height + 44);
			startAlpha=3.84;
			this.addEventListener(Event.ENTER_FRAME, efHandler);
		}

		private function efHandler(e:Event):void {
			startAlpha-=alpSpeed
			txt.alpha=startAlpha;
			bg.alpha=txt.alpha;
			if (txt.alpha <= 0)
				kill()
		}

		public function kill():void {
			this.removeEventListener(Event.ENTER_FRAME, efHandler);
			if (this.parent)
				this.parent.removeChild(this);
		}

		public function unload():void {
			this.bg=null;
			this.txt=null;
		}
	}
}