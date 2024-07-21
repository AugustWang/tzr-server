package com.scene.sceneUtils
{
	import flash.utils.getTimer;
	
	/**
	 * 计数器
	 * @author lxy
	 *
	 */
	public class RoadCounter
	{
		public var time:Number
		public var enabled:Boolean;
		private var interval:Number=100;
		private var startTime:Number;
		
		
		public function RoadCounter()
		{
			
		}
		
		/**
		 *获取执行时间
		 * @return
		 *
		 */
		public function getTimes():Number
		{
			return this.time
		}
		
		/**
		 *更新
		 * @param res
		 *
		 */
		public function updataTimes():void
		{
			if (enabled)
			{
				this.time=getTimer() - startTime;
			}
		}
		
		/**
		 *重设
		 *
		 */
		public function reset():void
		{
			enabled=true;
			this.startTime=getTimer();
			this.time=0
		}
		
	}
}