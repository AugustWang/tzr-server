package com.scene.sceneUnit.baseUnit.things.avatar
{
	import com.scene.sceneUnit.baseUnit.things.common.BitmapFrame;
	import com.scene.sceneUnit.baseUnit.things.common.BitmapMovieClip;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	
	import flash.utils.setTimeout;
	
	public class AvatarBMC extends BitmapMovieClip
	{
		public var _skyStandOffsetY:int=0;
		public var _skyMountOffsetY:int=0;
		
		public function AvatarBMC()
		{
		}
		
//		override public function step():void
//		{
//			_speedCount++;
//			if (_speedCount >= checkSpeed())
//			{
//				updataStep();
//				_speedCount=0;
//			}
//		}
		
		override public function onTick(framecount:int, dt:Number=33):void{
			_speedCount += framecount;
			var speed:int = checkSpeed();
			if (_speedCount >= speed)
			{
				var elapseFrame:int = int(_speedCount/speed);
				var life:int = _maxFrame - _currentFrame;
				if(life >0 && elapseFrame > life){
					_currentFrame = 0;
					elapseFrame = 1;
				}
				updataStep(elapseFrame);
				_speedCount=0;
			}
		}
		
		override public function setCurrentFrame():void
		{
			if (_thingBMC && SourceManager.getInstance().has(_url))
			{
				var e:BitmapFrame=SourceManager.getInstance().getResource(_url).getFrame(_actionAndDir.concat('_' + _currentFrame));
				_thingBMC.bitmapData=e.data;
				_thingBMC.x=e.offsetX;
				_thingBMC.y=e.offsetY + _skyMountOffsetY + _skyStandOffsetY;
			}
		}
		
		override public function play($url:String, $action:String, $dir:int, $speed:int=4, $isloop:Boolean=false):void
		{
			_url=$url;
			if ($action != _action)
			{
				_currentFrame=0;
			}
			setAction($action);
			_actionAndDir=$action.concat('_d').concat($dir);
			_speed=$speed;
			_isLoop=$isloop;
			_startFrame=0;
			_endFrame=_maxFrame;
			addToFrame();
		}
		
		/**
		 * 根据动作返回每帧特定的速度
		 * @return
		 */
		private function checkSpeed():int
		{
			switch (_action)
			{
				case AvatarConstant.ACTION_ATTACK_CASTING:
					switch (_currentFrame)
					{
						case 0:
							return 3;
						case 1:
							return 4;
						case 2:
							return 4;
						case 3:
							return 6;
						case 4:
							return 5;
						case 5:
							return 5;
					}
					break;
				case AvatarConstant.ACTION_ATTACK_ARROW:
					switch (_currentFrame)
					{
						case 0:
							return 3;
						case 1:
							return 3;
						case 2:
							return 3;
						case 3:
							return 6;
						case 4:
							return 6;
						case 5:
							return 5;
					}
					break;
				case AvatarConstant.ACTION_ATTACK:
					switch (_currentFrame)
					{
						case 0:
							return 3;
						case 1:
							return 3;
						case 2:
							return 5;
						case 3:
							return 1;
						case 4:
							return 5;
						case 5:
							return 5;
					}
					break;
			}
			return _speed;
		}
		
		public function get offsetX():Number{
			return _thingBMC.x;
		}
		
		public function get offsetY():Number{
			return _thingBMC.y;
		}
		
	}
}