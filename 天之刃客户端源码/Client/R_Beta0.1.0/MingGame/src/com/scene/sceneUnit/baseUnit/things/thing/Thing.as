package com.scene.sceneUnit.baseUnit.things.thing {
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapMovieClip;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;

	/**
	 *
	 * 简单的图片序列动画类
	 * @author yingbf
	 *
	 */
	public class Thing extends Sprite {
		private static var MODE_PALY:String='play';
		private static var MODE_GOTO_AND_STOP:String='gotoAndStop';
		private static var MODE_GOTO_ADN_PLAY:String='gotoAndPlay';
		private static var THING_ACTION:String=AvatarConstant.ACTION_DEFULT;
		private static var THING_DIR:int=AvatarConstant.DIR_UP;

		private var _thingBMC:BitmapMovieClip;
		private var _loadComplete:Boolean=false;
		private var _url:String;
		private var _speed:int;
		private var _startFrame:int;
		private var _endFrame:int;
		private var _frame:int;
		private var _isLoop:Boolean;
		private var _playMode:String;

		/**
		 *
		 * 构造函数
		 *
		 */
		public function Thing() {
			super();
			_thingBMC=new BitmapMovieClip();
			_thingBMC.addEventListener(BitmapMovieClip.END, onEnd);
			addChild(_thingBMC);
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}

		public function onEnd(event:Event):void {
			//dispatchEvent(new ThingsEvent(ThingsEvent.THING_PLAY_END));
		}

		public function get path():String {
			return this._url
		}

		/**
		 * 是否加载完成
		 * @return
		 *
		 */
		public function isLoaderComplete():Boolean {
			return _loadComplete;
		}

		/**
		 * 加载资源
		 * @param $url 资源地址
		 */
		public function load($url:String):void {
			_loadComplete = false;
			_url=$url;
			if (SourceManager.getInstance().has($url)) {
				if (SourceManager.getInstance().hasComplete($url)) {
					_loadComplete=true;
				} else {
					SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, createCompleteHandler);
					SourceManager.getInstance().load($url);
				}
			} else {
				SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, createCompleteHandler);
				SourceManager.getInstance().load($url);
			}
		}

		/**
		 *
		 * 加载完成，播放图片序列
		 * @private
		 * @param e
		 *
		 */
		private function createCompleteHandler(event:DataEvent):void {
			if (event.data == _url) {
				switch (_playMode) {
					case MODE_PALY:
						_thingBMC.play(_url, THING_ACTION, THING_DIR, _speed, _isLoop);
						break;
					case MODE_GOTO_ADN_PLAY:
						_thingBMC.gotoAndPlay(_url, THING_ACTION, THING_DIR, _speed, _startFrame, _endFrame, _isLoop);
						break;
					case MODE_GOTO_AND_STOP:
						_thingBMC.gotoAndStop(_url, THING_ACTION, THING_DIR, _frame);
						break;
				}
				_loadComplete=true;
				SourceManager.getInstance().removeEventListener(SourceManager.CREATE_COMPLETE, createCompleteHandler);
				dispatchEvent(new ThingsEvent(ThingsEvent.THING_LOAD_COMPLETE,this.height));
			}
		}

		/**
		 * 播放
		 * @param $speed 播放速度
		 * @param $isLoop 是否循环
		 */
		public function play($speed:int, $isLoop:Boolean=false):void {
			_playMode=MODE_PALY;
			_speed=$speed;
			_isLoop=$isLoop;
			if (_loadComplete) {
				_thingBMC.play(_url, THING_ACTION, THING_DIR, _speed, _isLoop);
			}
		}

		/**
		 * 停止播放
		 */
		public function stop():void {
			_thingBMC.stop();
		}

		public function resume():void {
//			switch (_playMode) {
//				case MODE_PALY:
//					_thingBMC.play(_url, THING_ACTION, THING_DIR, _speed, _isLoop);
//					break;
//				case MODE_GOTO_ADN_PLAY:
//					_thingBMC.gotoAndPlay(_url, THING_ACTION, THING_DIR, _speed, _startFrame, _endFrame, _isLoop);
//					break;
//				case MODE_GOTO_AND_STOP:
//					_thingBMC.gotoAndStop(_url, THING_ACTION, THING_DIR, _frame);
//					break;
//			}
		}

		public function unload():void {
			if(this.parent)this.parent.removeChild(this);
			_thingBMC.removeEventListener(BitmapMovieClip.END, onEnd);
			_thingBMC.stop();
			_thingBMC.unload();
		}

		public function gotoAndStop($frame:int):void {
			_playMode=MODE_GOTO_AND_STOP;
			_frame=$frame;
			if (_loadComplete)
				_thingBMC.gotoAndStop(_url, THING_ACTION, THING_DIR, _frame);
		}

		public function gotoAndPlay($speed:int, $startFrame:int, $endFrame:int, $isLoop:Boolean=false):void {
			_playMode=MODE_GOTO_ADN_PLAY;
			_speed=$speed;
			_startFrame=$startFrame;
			_endFrame=$endFrame;
			_isLoop=$isLoop;
			if (_loadComplete)
				_thingBMC.gotoAndPlay(_url, THING_ACTION, THING_DIR, _speed, _startFrame, _endFrame, _isLoop);
		}
	}
}