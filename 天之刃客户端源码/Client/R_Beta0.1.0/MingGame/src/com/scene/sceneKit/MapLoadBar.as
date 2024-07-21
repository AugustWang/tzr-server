package com.scene.sceneKit {
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.scene.sceneUnit.baseUnit.SceneStyle;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class MapLoadBar extends Sprite {
		private var logo:Image;
		private var title:TextField;
		public var txtTip:TextField;

		public function MapLoadBar() {
			super();
			initView();
		}

		private function initView():void {

			logo=new Image();
			logo.cache = false;
			logo.source = GameConfig.ROOT_URL+"assets/loading/logo.png";
			logo.x= 500 - 243 >> 1;
			addChild(logo);

			var format1:TextFormat=new TextFormat(null, 14, 0x00ff00, null, null, null, null, null, "center");
			title=new TextField;
			title.defaultTextFormat=format1;
			title.selectable=false;
			title.width=500;
			title.filters=[new GlowFilter(0, 1, 2, 2, 200)];
			title.y=120;
			addChild(title);

			var format2:TextFormat=new TextFormat(null, 12, 0xffffff, null, null, null, null, null, "center");

			txtTip=new TextField;
			txtTip.defaultTextFormat=format2;
			txtTip.selectable=false;
			txtTip.width=500;
			txtTip.y=title.y + 10;
			txtTip.filters=SceneStyle.nameFilter;
			addChild(txtTip);
		}
		
		override public function get height():Number{
			return 160;
		}
		
		public function randomTip():void {
			var tipIndex:int=int(Math.random() * LoadingSetter.ChangeMapTips.length);
			txtTip.text=LoadingSetter.ChangeMapTips[tipIndex];
		}

		public function update(percent:Number, msg:String):void {
			//由于加载msg对于玩家来没有任何意义，所以暂时设定不显示
			title.text = "正在加载..."+int(percent*100)+"%";
		}
	}
}