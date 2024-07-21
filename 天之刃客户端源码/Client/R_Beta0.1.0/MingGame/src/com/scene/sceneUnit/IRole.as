package com.scene.sceneUnit {
	import flash.display.DisplayObject;

	import proto.common.p_map_role;
	import proto.common.p_map_stall;

	public interface IRole {
		function doStall(stall:Boolean, stallName:String=""):void;
		function doTraining(value:Boolean):void;
		function doNameJob():void;
		function doHook(value:Boolean):void;
		function showCloth(value:Boolean):void;
		function get x():Number;
		function get y():Number;
		function addChild(obj:DisplayObject):DisplayObject;
		function set pvo(vo:p_map_role):void
		function get pvo():p_map_role;
	}
}