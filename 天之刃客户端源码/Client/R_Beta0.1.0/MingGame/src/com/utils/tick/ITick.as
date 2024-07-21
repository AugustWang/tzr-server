package com.utils.tick
{
	/**
	 * 定时执行接口 
	 * @author huyongbo
	 * 
	 */	
	public interface ITick
	{
		/**
		 * 执行更新函数 
		 * @param framecount  一次Tick运行执行的时间/理论每帧消耗时间，因为在flashPlayer最小化的，帧数会减低到2次/1s,所以可以选择性的丢帧。
		 * @param dt 定时器连续两次的执行间隔时间
		 */		
		function onTick(framecount:int,dt:Number = 40) : void;
	}
}