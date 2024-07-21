package com.scene.sceneData
{
	
	import flash.utils.Dictionary;
	
	public class CityVo
	{
		public var id:int;
		public var name:String;
		public var level:int;
		public var parents:Dictionary;
		public var children:Dictionary;
		public var renascence:Vector.<MacroPathVo>;
		public var countryId:int;
		public var url:String;
		public var livePoints:Vector.<MacroPathVo>
		public var macVo:MacroPathVo;
		public var posx:int;
		public var posy:int;
		public var scale:Number;
		public var music:String;
		public var turn_map_abled:int;
		
		public function CityVo()
		{
			super();
		}
		
		public function init():void
		{
			parents=new Dictionary;
			children=new Dictionary;
			renascence=new Vector.<MacroPathVo>;
			livePoints=new Vector.<MacroPathVo>;
		}
		
		public function unload():void
		{
			parents=null;
			children=null
			renascence=null;
			livePoints=null;
		}
	}
}