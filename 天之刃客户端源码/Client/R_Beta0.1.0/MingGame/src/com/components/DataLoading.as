package com.components
{	
	import com.globals.GameConfig;
	
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	
	public class DataLoading extends Sprite
	{
		public static var dataLoadingClazz:Class;
		public function DataLoading()
		{
			super();
			_w=100;
			_h=100;
			loadData();
			addEventListener(Event.ADDED_TO_STAGE,startDraw);
			addEventListener(Event.REMOVED_FROM_STAGE,stop);
		}
		
		private function loadedFunc(event:Event):void
		{
			var loaderInfo:LoaderInfo = event.currentTarget as LoaderInfo;
			if(loaderInfo && loaderInfo.applicationDomain && loaderInfo.applicationDomain.hasDefinition("DataLoading")){
				dataLoadingClazz = event.currentTarget.applicationDomain.getDefinition("DataLoading") as Class;
				addLoading();
			}
		}
		
		private var dataloading:MovieClip;
		private function addLoading():void{
			dataloading = new dataLoadingClazz;
			dataloading.x = (_w - dataloading.width)/2 + dataloading.width/2;
			dataloading.y = (_h - dataloading.height)/2 ;		
			addChild(dataloading);
		}
		
		private function loadData():void{
			if(dataLoadingClazz){
				addLoading();
			}else{
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadedFunc);
				loader.load(new URLRequest(GameConfig.DATA_LOADING_URL));
			}
		}
		
		private function startDraw(event:Event):void{
			var g:Graphics = graphics;
			g.clear();
			g.beginFill(0x000000,0);
			g.drawRect(0,0,_w,_h);
			g.endFill();	
			if(dataloading){
				dataloading.x = (_w - dataloading.width)/2 + dataloading.width/2;
				dataloading.y = (_h - dataloading.height)/2 ;					
			}
			play();
		}
		
		private function play():void{
			if(dataloading){
				dataloading.play();
			}	
		}
		
		private function stop(event:Event):void{
			if(dataloading){
				dataloading.stop();
			}	
		}
		
		private var _w:Number;
		private var _h:Number;
		override public function set width(value:Number):void{
			this._w = value;
		}
		
		override public function set height(value:Number):void{
			this._h = value;
		}
		
		
	}
}