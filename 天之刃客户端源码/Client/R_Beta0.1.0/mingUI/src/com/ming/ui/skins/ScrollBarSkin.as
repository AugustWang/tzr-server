package com.ming.ui.skins
{
	import flash.geom.Rectangle;

	public class ScrollBarSkin
	{
		public var width:Number = 18;
		public var buttonHeight:Number = 18;
		public var buttonWidth:Number = 18;
		public var thumbBarWidth:Number = 17;
		public var traceBarWidth:Number = 17;
		public var minThumbBarHeight:Number = 20;
		public var minButtonHeight:Number = 20;
		
		public var thumbSkin:Skin;
		public var upSkin:Skin;
		public var downSkin:Skin;
		public var trackSkin:Skin;
		
		public var barIcon:Class;
		
		public function ScrollBarSkin(){
			buttonHeight = width;
			buttonWidth = width;
			thumbBarWidth = width;
			traceBarWidth = width;
		}
	}
}