package com.scene.sceneUnit.baseUnit.things.effect
{
	
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapMovieClip;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class ArrowEffect extends BitmapMovieClip
	{
		private static var EFFECT_ACTION:String = AvatarConstant.ACTION_DEFULT;
		private static var EFFECT_DIR:int = AvatarConstant.DIR_UP;
		public static var pool:Array = [];
		private var _ballIsIMG:Boolean;
		private var _delay:Number;
		private var _isFlyLoop:Boolean;
		private var _isRotation:Boolean;
		private var _fromX:Number;
		private var _fromY:Number;
		private var _targetX:Number;
		private var _targetY:Number;
		private var _time:Number;
		public var _target:DisplayObject;
		public var _endFunArg:Object;
		
		public function ArrowEffect()
		{
			super();
		}
		
		public static function getEffect():ArrowEffect{
			if( pool.length > 0 ){
				return pool.pop();
			}
			return new ArrowEffect();
		}
		
		public function show($url:String,$fromX:Number,$fromY:Number,$targetX:Number,$targetY:Number,
							 $parent:Sprite,$delay:Number = 0,$ballIsIMG:Boolean = true,$ballSpeed:Number = 4,
							 $isRotation:Boolean = true,$isFlyLoop:Boolean = false):void{
			this.visible = false;
			_time = 2500;
			_url = $url;
			this.x = $fromX;
			this.y = $fromY;
			_fromX = $fromX;
			_fromY = $fromY;
			_targetX = $targetX;
			_targetY = $targetY;
			_delay = $delay;
			_speed = $ballSpeed;
			_ballIsIMG = $ballIsIMG;
			_isLoop = !$ballIsIMG;
			_isRotation = $isRotation;
			_isFlyLoop = $isFlyLoop;
			if(_isRotation)this.rotation = Math.atan2(_targetY - this.y, _targetX - this.x) * (180 / Math.PI) + 90;
			if($parent != null)$parent.addChild(this);
			if(SourceManager.getInstance().has(_url)){
				if(SourceManager.getInstance().hasComplete(_url)){
					if(_ballIsIMG){
						addToFrame();
					}else{
						play(_url,EFFECT_ACTION,EFFECT_DIR,_speed,_isLoop);
					}
				}else{
					SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE,onCreateComplete);
				}
			}else{
				SourceManager.getInstance().addEventListener(SourceManager.CREATE_COMPLETE,onCreateComplete);
				SourceManager.getInstance().load(_url);
			}
		}
		
		protected function onCreateComplete(event:DataEvent):void{
			if(event.data == _url){
				SourceManager.getInstance().removeEventListener(SourceManager.CREATE_COMPLETE,onCreateComplete);
				if(_ballIsIMG){
					addToFrame();
				}else{
					play(_url,EFFECT_ACTION,EFFECT_DIR,_speed,_isLoop);
				}
			}
		}
		
		override protected function addToFrame():void{
			super.addToFrame();
		}
		
//		override public function step():void{
//			if((getTimer() - _time) > 2500){
//				unload();
//				return;
//			}
//			if(_delay == 0){
//				this.visible = true;
//				_speedCount++;
//				updataPosition();
//				if(_isLoop && _speedCount >= _speed){
//					if(state != STOP_STATE)updataStep();
//					_speedCount = 0;
//				}
//			}else{
//				this.visible = false;
//				_delay--;
//			}
//		}
		
		override public function onTick(framecount:int, dt:Number=40):void{
			_time = _time - dt;
			if(_time <= 0){
				unload();
				return;
			}
			if(_delay == 0){
				this.visible = true;
				_speedCount += framecount;
				updataPosition();
				if(_isLoop && _speedCount >= _speed){
					var elapseFrame:int = _speedCount/_speed;
					var life:int = _maxFrame - _currentFrame;
					if(life >0 && elapseFrame > life){
						_currentFrame = 0;
						elapseFrame = 1
					}
					if(state != STOP_STATE)updataStep(elapseFrame);
					_speedCount = 0;
				}
			}else{
				this.visible = false;
				_delay--;
			}
		}
		
		override protected function complete():void{
		}
		
		override public function unload():void{
			super.unload();
			pool.push(this);
		}
		
		
		protected function updataPosition():void{
			if(_target){
				_targetX = _target.x;
				_targetY = _target.y - 75;
			}
			this.x = this.x - (_fromX - _targetX) * 0.2;
			this.y = this.y - (_fromY - _targetY) * 0.2;
			if(_isRotation)this.rotation = Math.atan2(_targetY - this.y, _targetX - this.x) * 57.3 + 90;
			if ((this.y - _targetY) * (this.y - _targetY) + (this.x - _targetX) * (this.x - _targetX) < 200)
			{
				flyComplete();
			}
		}
		
		protected function flyComplete():void{
			if(_isFlyLoop){
				this.x = _fromX;
				this.y = _fromY;
			}else{
				stop();
				dispatchEvent(new Event(END));
				if(endFunction != null)endFunction(_endFunArg);
				unload();
			}
		}
	}
}