package com.scene.sceneKit {
	import com.common.GlobalObjectManager;
	import com.loaders.ResourcePool;
	import com.managers.LayerManager;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;


	public class LoadingSetter {
		public static var inited:Boolean;
		private static var masker:Sprite;
		private static var mapLoader:MapLoadBar;
		private static var pureMask:Shape;
		private static var logo:Bitmap;

		public static function mapLoading(show:Boolean, percent:Number=0, msg:String="", bgAlpha:Number=0.0):void {
			if (show == true) {
				if (mapLoader == null) {
					masker=new Sprite;
					mapLoader=new MapLoadBar;
					masker.addChild(mapLoader);
				}
				masker.graphics.clear();
				masker.graphics.beginFill(0x0, bgAlpha);
				masker.graphics.drawRect(0, 0, GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
				masker.graphics.endFill();
				mapLoader.x=(GlobalObjectManager.GAME_WIDTH - mapLoader.width) / 2 + 20;
				mapLoader.y=(GlobalObjectManager.GAME_HEIGHT - mapLoader.height) / 2;
				if (bgAlpha == 0) {
					mapLoader.txtTip.visible=false;
				} else {
					mapLoader.txtTip.visible=true;
				}
				mapLoader.update(percent, msg);
				if (masker.parent == null) {
					mapLoader.randomTip();
					LayerManager.stage.addChild(masker);
				}
			} else {
				if (masker != null && masker.parent != null) {
					masker.parent.removeChild(masker);
				}
			}
		}


		public static function showMasker(show:Boolean):void {
			if (show == true) {
				if (pureMask == null) {
					pureMask=new Shape;
					pureMask.graphics.beginFill(0x0, 0.6);
					pureMask.graphics.drawRect(0, 0, GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
					pureMask.graphics.endFill();
				}
				if (pureMask.parent == null) {
					LayerManager.stage.addChild(pureMask);
				}
			} else {
				if (pureMask != null && pureMask.parent != null) {
					pureMask.parent.removeChild(pureMask);
				}
			}
		}
		public static const ChangeMapTips:Array=["打怪时，按Z或者右上角的“挂”可以使用自动挂机功能", "等级≥20级且加入门派后，可接拉镖任务，获得海量银子", "等级≥25级，在京城找到李梦阳领取导师称号，即可收徒", "按E即可打开天工炉界面", "16级后完成五行任务即可获得五行属性，组队打怪更轻松", "按O打开社会界面，拜师、收徒、加好友、进门派", "想要充满个性的称号吗？加入门派吧！", "没时间上线？太平村的武学宗师张三丰可以帮你离线挂机", "邀请你的朋友，一起来玩《天之刃》", "按M打开小地图，查看怪物分布", "按F打开附近玩家列表，组队、加好友", "打开NPC商店，把不需要的物品拖进去可以赚到银子"];
	}
}