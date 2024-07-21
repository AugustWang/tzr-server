package com.scene.sceneUnit.baseUnit.things.effect {
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapMovieClip;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.utils.tick.TickManager;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.DataEvent;
	import flash.utils.getTimer;

	public class Effect extends BitmapMovieClip {
		private static var EFFECT_ACTION:String=AvatarConstant.ACTION_DEFULT;
		private static var EFFECT_DIR:int=AvatarConstant.DIR_UP;
		private static var pool:Array=[];
		private var _delay:Number;
		private var _time:Number;
		private var _times:int;
		public var timeOut:int=3000;

		public function Effect() {
			super();
		}

		public static function getEffect():Effect {
			if (pool.length > 0) {
				return pool.pop();
			}
			return new Effect()
		}

		public function show($url:String, $x:Number, $y:Number, $parent:DisplayObjectContainer, $speed:Number=4, $delay:Number=0, $isLoop:Boolean=
			false, $timeOut:int=3000, $times:int=1):void {
			_time=$timeOut;
			_url=$url;
			x=$x;
			y=$y;
			_delay=$delay;
			_speed=$speed;
			_isLoop=$isLoop;
			_isLoop ? _startFrame=1 : _startFrame=0 //由于编辑器犯错误特效由1开始
			_times=$times;
			timeOut=$timeOut;
			if ($parent != null)
				$parent.addChild(this);
			if (SourceManager.getInstance().has(_url)) {
				if (SourceManager.getInstance().hasComplete(_url)) {
					play(_url, EFFECT_ACTION, EFFECT_DIR, _speed, _isLoop);
				} else {
					SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, onCreateComplete);
				}
			} else {
				SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE, onCreateComplete);
				SourceManager.getInstance().load(_url);
			}
		}

		override public function play($url:String, $action:String, $dir:int, $speed:int=4, $isloop:Boolean=false):void {
			_url=$url;
			_currentFrame=0;
			setAction($action);
			_actionAndDir=$action.concat('_d').concat($dir);
			_speed=$speed;
			_isLoop=$isloop;
			_startFrame=1;
			_endFrame=_maxFrame;
			addToFrame();
		}

		protected function onCreateComplete(event:DataEvent):void {
			if (event.data == _url) {
				SourceManager.getInstance().removeEventListener(SourceManager.CREATE_COMPLETE, onCreateComplete);
				play(_url, EFFECT_ACTION, EFFECT_DIR, _speed, _isLoop);
			}
		}

		override protected function addToFrame():void {
			TickManager.getInstance().addTick(this);
			//ThingFrame.getInstance().add(onlyKey, step);
			if (_delay == 0)
				setCurrentFrame();
		}

		override public function onTick(framecount:int, dt:Number=40):void{
			_time = _time - dt;
			if (_time <= 0) {
				unload();
				return;
			}
			if (_delay == 0) {
				_speedCount += framecount;
				if (_speedCount >= _speed) {
					var elapseFrame:int = _speedCount/_speed;
					var life:int = _maxFrame - _currentFrame;
					if(life >0 && elapseFrame > life){
						if(!_isLoop){
							complete();
							return;
						}else{
							_currentFrame = 0;
							elapseFrame = 1;
						}
					}
					updataStep(elapseFrame);
					_speedCount=0;
				}
			} else {
				_delay--;
			}
		}
		
//		override public function step():void {
//			if ((getTimer() - _time) > timeOut) {
//				unload();
//				return;
//			}
//			if (_delay == 0) {
//				_speedCount++;
//				if (_speedCount >= _speed) {
//					updataStep();
//					_speedCount=0;
//				}
//			} else {
//				_delay--;
//			}
//		}

		override protected function updataStep(addFrame:int=1):void {
			if (_currentFrame >= _endFrame) {
				_times--
				if (_isLoop == false && _times <= 0) {
					complete();
					return;
				}
				_currentFrame=_startFrame;
			} else {
				_currentFrame += addFrame;
			}
			setCurrentFrame();
		}

		override protected function complete():void {
			super.complete();
			unload();
		}

		override public function unload():void {
			super.unload();
			pool.push(this);
		}
	}
}