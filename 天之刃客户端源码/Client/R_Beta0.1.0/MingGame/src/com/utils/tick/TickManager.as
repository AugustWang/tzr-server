package com.utils.tick
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;

	/**
	 * 定时器 
	 * @author huyongbo
	 * 
	 */
    public class TickManager extends EventDispatcher
    {
		/**
		 * 使用外挂的玩家，你伤不起，有木有有木有！  
		 */		
		public static const INVALID_PLAYER:String = "INVALID_PLAYER";
		
        private var _frameCount:int; //记录帧数，每60帧来检测一次加速外挂
        private var _totalTime:Number; //记录60帧消耗的实际时间，然后和理论时间比较，来判断是否使用加速外挂
        private var _lastSysTimes:Number; //最后一次计算机时间戳
        private var _lastSec:Number; //记录当前帧的flash AVM运行时间
		private var _ticks:Vector.<ITick>; //需要定时更新的定时对象集合
		private var _frameShape:Shape; //定时器触发对象
		private var _invalidTime:Number;
        public static var frameRateTime:int = 24/1000;//执行每帧的毫秒数

        public function TickManager()
        {
			_frameShape = new Shape()
			_frameShape.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			_ticks = new Vector.<ITick>();
            _lastSec = getTimer();
			_invalidTime = frameRateTime*60-200;
            _frameCount = 0;
            _lastSysTimes = 0;
            _totalTime = 0;
        }
		
		private static var instance:TickManager;
		public static function getInstance():TickManager{
			if(instance == null){
				instance = new TickManager();
			}
			return instance;
		}
		
		public function addTick(tick:ITick) : void{
			if (!hasTick(tick)){
				_ticks.push(tick);
			}
		}
		
        public function removeTick(tick:ITick) : void{
            var index:int = _ticks.indexOf(tick);
            if (index > -1){
                _ticks.splice(index, 1);
            }
		}
		
        public function hasTick(tick:ITick) : Boolean{
            return _ticks.indexOf(tick) > -1;
        }

        private function enterFrameHandler(event:Event) : void{
            var currentTimer:int = getTimer();
            var dt:Number = currentTimer - _lastSec;
            var framecount:int = dt / frameRateTime;
            if (dt > 500){
                onTick(framecount, dt);
            }else{
                onTick(1, dt);
            }
            _lastSec = currentTimer;
            _frameCount++;
            var sysTimes:Number = (new Date()).getTime();
            if (_lastSysTimes == 0){
                _totalTime = _totalTime + dt;
            }else{
                _totalTime = _totalTime + (sysTimes - _lastSysTimes);
            }
            _lastSysTimes = sysTimes;
            if (_frameCount == 60){
				_frameCount = 0;
                if (_totalTime < _invalidTime){
                   dispatchEvent(new Event(INVALID_PLAYER));
                }
                _totalTime = 0;
            }
        }

        private function onTick(frameCount:int,dt:Number) : void{
            for each(var tick:ITick in _ticks){
				if(tick){
					tick.onTick(frameCount,dt);
				}
			}	
		}

    }
}
