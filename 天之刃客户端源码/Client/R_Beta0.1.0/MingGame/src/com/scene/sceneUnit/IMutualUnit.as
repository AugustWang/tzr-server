package com.scene.sceneUnit
{
	import com.ming.ui.containers.Container;
	import com.scene.tile.Pt;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.IBitmapDrawable;
	import flash.geom.Rectangle;
	
	public interface IMutualUnit extends IBitmapDrawable
	{
		function set sceneType(value:int):void;
		function get sceneType():int;
		function set x(value:Number):void;
		function get x():Number;
		function set y(value:Number):void;
		function get y():Number;
		function get unitKey():String;
		function get index():Pt;
		function mouseOver():void;
		
		function mouseOut():void;
		
		function mouseDown():void;
		//		
		//		function mouseUp(e:MouseEvent):void;
		
		function remove():void;
		
		function get parent():DisplayObjectContainer;
		function get mouseX():Number;
		function get mouseY():Number;
	}
}