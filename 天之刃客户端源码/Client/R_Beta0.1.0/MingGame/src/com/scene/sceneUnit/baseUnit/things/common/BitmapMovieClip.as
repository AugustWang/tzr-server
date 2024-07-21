package com.scene.sceneUnit.baseUnit.things.common {

	import com.scene.sceneUnit.baseUnit.OnlyIDCreater;
	import com.scene.sceneUnit.baseUnit.things.ThingFrame;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.utils.tick.ITick;
	import com.utils.tick.TickManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class BitmapMovieClip extends Sprite implements ITick{
		public static var END:String='end';
		public static var PLAY_STATE:int=0;
		public static var STOP_STATE:int=1;

		public var endFunction:Function;
		public var state:int=STOP_STATE;
		public var onlyKey:String;

		protected var _url:String;
		protected var _thingBMC:Bitmap;
		protected var _action:String;
		protected var _dir:int;
		protected var _actionAndDir:String=AvatarConstant.ACTION_DEFULT + '_d' + AvatarConstant.DIR_UP;
		protected var _speed:int;
		protected var _speedCount:int;
		protected var _isLoop:Boolean;
		protected var _maxFrame:int;
		protected var _currentFrame:int=0;
		protected var _startFrame:int=0;
		protected var _endFrame:int=0;

		public function BitmapMovieClip() {
			onlyKey=OnlyIDCreater.createID();
			_thingBMC=new Bitmap();
			addChild(_thingBMC);
			mouseChildren=false;
			mouseEnabled=false;
		}
		
		public function clean():void{
			if(_thingBMC)_thingBMC.bitmapData = null;
		}

		public function setURL(value:String):void {
			_url=value;
		}

		public function setAction(value:String):void {
			_action=value;
			if(SourceManager.getInstance().has(_url)){
				_maxFrame=SourceManager.getInstance().getResource(_url).getLight(_action) - 1;
			}
		}

		public function setCurrentFrame():void {
			if (_thingBMC && SourceManager.getInstance().has(_url)) {
				var e:BitmapFrame=SourceManager.getInstance().getResource(_url).getFrame(_actionAndDir.concat('_' + _currentFrame));
				if (e == null)
					return;
				_thingBMC.bitmapData=e.data;
				_thingBMC.x=e.offsetX;
				_thingBMC.y=e.offsetY;
			}
		}

		public function nextFrame():void {
			gotoAndStop(_url, _action, _dir, Math.min(_currentFrame + 1, _maxFrame));
		}

		public function prevFrame():void {
			gotoAndStop(_url, _action, _dir, Math.max(_currentFrame, 0));
		}

		public function play($url:String, $action:String, $dir:int, $speed:int=4, $isloop:Boolean=false):void {
			_url=$url;
			_currentFrame=0;
			setAction($action);
			_actionAndDir=$action.concat('_d').concat($dir);
			_speed=$speed;
			_isLoop=$isloop;
			//_startFrame = 0;
			_endFrame=_maxFrame;
			addToFrame();
		}

		public function gotoAndPlay($url:String, $action:String, $dir:int, $speed:int=4, $startFrame:int=0, $endFrame:int=
			0, $isLoop:Boolean=false):void {
			_url=$url;
			setAction($action);
			_actionAndDir=$action.concat('_d').concat($dir);
			_speed=$speed;
			_isLoop=$isLoop;
			_currentFrame=$startFrame;
			_startFrame=$startFrame;
			_endFrame=$endFrame;
			addToFrame();
		}

		public function gotoAndStop($url:String, $action:String, $dir:int, $frame:int):void {
			_url=$url;
			setAction($action);
			_actionAndDir=$action.concat('_d').concat($dir);
			_currentFrame=$frame;
			setCurrentFrame();
			stop();
		}

		public function stop():void {
			state=STOP_STATE;
			removeFromFrame();
		}

		/**
		 *
		 * @private
		 * 加入到thing的心跳管理
		 *
		 */
		protected function addToFrame():void {
			state=PLAY_STATE;
			_speedCount=0;
			TickManager.getInstance().addTick(this);
			//ThingFrame.getInstance().add(onlyKey, step);
			setCurrentFrame();
		}

		/**
		 * @private
		 * 从thing的心跳管理中去除
		 */
		protected function removeFromFrame():void {
			TickManager.getInstance().removeTick(this);
			//ThingFrame.getInstance().remove(onlyKey);
		}

//		public function step():void {
//			_speedCount++;
//			if (_speedCount >= _speed) {
//				updataStep();
//				_speedCount=0;
//			}
//		}

		protected function updataStep(addFrame:int=1):void {
			if (_currentFrame >= _endFrame) {
				if (_isLoop == false) {
					complete();
					return;
				}
				_currentFrame=_startFrame;
			} else {
				_currentFrame += addFrame;
			}
			setCurrentFrame();
		}

		public function unload():void {
			if(scaleX == -1)scaleX = 1;
			removeFromFrame();
			if (this.parent) {
				this.parent.removeChild(this);
			}
			_thingBMC.bitmapData=null;
		}

		protected function complete():void {
			stop();
			dispatchEvent(new Event(END));
			if (endFunction != null)
				endFunction();
		}
		
		public function setTransparent(bitmapdata:BitmapData):void{
			if(_thingBMC){
				_thingBMC.bitmapData = bitmapdata;
				_thingBMC.x = -24;
				_thingBMC.y = -77;
			}
		}
		
		public function onTick(framecount:int,dt:Number = 40):void{
			_speedCount += framecount;
			if (_speedCount >= _speed) {
				var elapseFrame:int = int(_speedCount/_speed);
				var life:int = _maxFrame - _currentFrame;
				if(life >0 && elapseFrame > life){
					elapseFrame = 1;
					_currentFrame = 0;
				}
				updataStep(elapseFrame);
				_speedCount=0;
			}
		}
	}
}
