package com.components
{
	import flash.display.Sprite;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class LoadingSprite extends Sprite
	{
		private var w:Number = 430;
		private var h:Number = 310;
		public function LoadingSprite()
		{
			super();
		}
		
		private var loading:DataLoading;
		private var timeOut:int;
		public function addDataLoading():void{
			if(loading == null){
				loading = new DataLoading();
				loading.x = 0;
				loading.y = 0;
				loading.width = w;
				loading.height = h;
			}
			addChild(loading);
			clearTimeout(timeOut);
			timeOut = setTimeout(removeDataLoading,10000);
		}
		
		public function removeDataLoading():void{
			if(loading && contains(loading)){
				removeChild(loading);
			}
		}
		
		protected function setLoadingSize(w:Number,h:Number):void{
			this.w = w;
			this.h = h;
		}
	}
}