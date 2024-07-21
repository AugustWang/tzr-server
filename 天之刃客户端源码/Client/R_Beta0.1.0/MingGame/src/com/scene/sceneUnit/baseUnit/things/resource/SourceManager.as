package com.scene.sceneUnit.baseUnit.things.resource {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.loaders.gameLoader.GameLoader;
	import com.loaders.gameLoader.GameLoaderEvent;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapClipData;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapFrame;

	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillEffectItemVO;
	import modules.skill.vo.SkillEffectVO;

	public class SourceManager extends EventDispatcher {
		/**事件**/
		public static const CREATE_COMPLETE:String='createComplete'; //加载完成
		/**优先级**/
		public static var LEVEL:int=1;
		/**资源存储池**/
		private var cache:Dictionary;
		/**阴影资源**/
		private var _shadow:BitmapData;
		private var _mountShadow:BitmapData;
		private var _silhouette:BitmapData;

		public function SourceManager() {
			init();
		}

		/**
		 *初始化
		 */
		private function init():void {
			cache=new Dictionary();
		}

		/**
		 *
		 * 单例
		 */
		private static var _instance:SourceManager;

		public static function getInstance():SourceManager {
			if (_instance == null) {
				_instance=new SourceManager();
			}
			return _instance;
		}

		public function hasComplete(url:String):Boolean {
			return cache[url].complete;
		}

		public function has(url:String):Boolean {
			return cache[url] != undefined;
		}

		public function getResource(url:String):BitmapClipData {
			return cache[url]
		}

		/**
		 * 影子
		 */
		public function getShadow():BitmapData {
			if (!_shadow) {
				var m:Matrix=new Matrix();
				m.createGradientBox(54, 28);
				var _s:Shape=new Shape();
				_s.graphics.beginGradientFill(GradientType.RADIAL, [0x000000, 0x000000], [0.4, 0], [150, 255], m, 'pad',
					'rgb', 0);
				_s.graphics.drawEllipse(0, 0, 54, 28);
				_s.graphics.endFill();
				_shadow=new BitmapData(_s.width, _s.height, true, 0x00FFFFFF);
				_shadow.draw(_s);
			}
			return _shadow;
		}

		/**
		 * 马影子
		 */
		public function getMountShadow():BitmapData {
			if (!_mountShadow) {
				var m:Matrix=new Matrix();
				m.createGradientBox(108, 28);
				var _s:Shape=new Shape();
				_s.graphics.beginGradientFill(GradientType.RADIAL, [0x000000, 0x000000], [0.4, 0], [150, 255], m, 'pad',
					'rgb', 0);
				_s.graphics.drawEllipse(0, 0, 108, 28);
				_s.graphics.endFill();
				_mountShadow=new BitmapData(_s.width, _s.height, true, 0x00FFFFFF);
				_mountShadow.draw(_s);
			}
			return _mountShadow;
		}

		/**
		 * 黑影
		 */
		public function getSilhouette():BitmapData {
			if (!_silhouette) {
				//var actionAndDir:String=AvatarConstant.ACTION_STAND.concat('_d').concat(AvatarConstant.DIR_DOWN).concat('_0');
//				var e:BitmapFrame = getResource(GameConfig.DEFLUT_BODY_TRANSPARENT).getFrame(actionAndDir);
//				var _silhouette:BitmapData = new BitmapData(e.data.width,e.data.height);
				var _silhouette:BitmapData=Style.getUIBitmapData(GameConfig.T1_VIEWUI, "transparent");
				_silhouette.copyPixels(_silhouette, new Rectangle(0, 0, 41, 100), new Point(-20, -100));
			}
			return _silhouette;
		}

		public function loadFristSkillEffect():void {
			var skill:String=GlobalObjectManager.getInstance().user.attr.category + "1101001";
			var effectVo:SkillEffectVO=SkillDataManager.getSkill(int(skill)).effect;
			var effectItem:SkillEffectItemVO;
			for (var i:int=0; i < effectVo.effects.length; i++) {
				effectItem=effectVo.effects[i];
				SourceManager.getInstance().load(GameConfig.EFFECT_SKILL_PATH + effectItem.id + '.swf');
			}
			for (i=0; i < effectVo.arrowEndEffects.length; i++) {
				effectItem=effectVo.arrowEndEffects[i];
				SourceManager.getInstance().load(GameConfig.EFFECT_SKILL_PATH + effectItem.id + '.swf');
			}
		}

		public function load(url:String):void {
			if (!has(url)) {
				createBitmapClip(url);
				GameLoader.getInstance().add(url, LEVEL, null, onLoaderComplete);
			} else {
				if (!hasComplete(url)) {
					GameLoader.getInstance().add(url, LEVEL, null, onLoaderComplete);
				}
			}
		}

		public function createBitmapClip(url:String):void {
			var bitmapMovieClip:BitmapClipData=new BitmapClipData();
			bitmapMovieClip.url=url;
			cache[url]=bitmapMovieClip;
		}

		public function onLoaderComplete(loader:Loader, url:String):void {
			var domain:ApplicationDomain=loader.contentLoaderInfo.applicationDomain;
			cache[url].domain=domain;
			cache[url].source=loader.content as MovieClip;
			cache[url].complete=true;

			dispatchEvent(new DataEvent(CREATE_COMPLETE, false, false, url));
		}

		/**
		 *销毁
		 */
		public function unload():void {

		}
	}
}