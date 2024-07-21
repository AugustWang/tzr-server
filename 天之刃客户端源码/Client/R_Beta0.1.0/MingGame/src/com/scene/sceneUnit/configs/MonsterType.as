package com.scene.sceneUnit.configs
{
	
	public class MonsterType
	{
		public var type:int=0;
		public var monstername:String;
		public var icon:String;
		public var level:int;
		public var skinid:int;
		public var rarity:int;
		public var say:String="1,2,3";
		
		public function get rarityName():String
		{
			var str:String;
			if (rarity == 1)
			{
				str="";
			}
			else if (rarity == 2)
			{
				str="精英";
			}
			else if (rarity == 3)
			{
				str="BOSS";
			}
			else
			{
				str="";
			}
			return str;
		}
		
		public function get rarityColor():uint
		{
			var color:uint;
			if (rarity == 1)
			{
				color=0xffffff;
			}
			else if (rarity == 2)
			{
				color=0x00CC99;
			}
			else if (rarity == 3)
			{
				color=0xFF0000;
			}
			else
			{
				color=0xffffff;
			}
			return color;
		}
		
		public function get rarityHtmlColor():String
		{
			var color:String;
			if (rarity == 1)
			{
				color="#ffffff";
			}
			else if (rarity == 2)
			{
				color="#00CC99";
			}
			else if (rarity == 3)
			{
				color="#FF0000";
			}
			else
			{
				color="#ffffff";
			}
			return color;
		}
	}
}