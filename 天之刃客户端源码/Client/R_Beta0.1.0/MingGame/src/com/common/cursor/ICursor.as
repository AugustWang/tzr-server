package com.common.cursor
{
	import com.ming.core.IDataRenderer;
	
	import flash.events.MouseEvent;

	/**
	 * 光标接口定义 
	 */	
	public interface ICursor extends IDataRenderer
	{
		function downHandler(event:MouseEvent):void;
		function upHandler(event:MouseEvent):void;
		function normalHandler():void;
		function stop():void;
	}
}