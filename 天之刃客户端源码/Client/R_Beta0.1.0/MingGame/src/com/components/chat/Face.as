package com.components.chat
{
	
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.chat.ChatModule;
	
	public class Face extends Sprite
	{
		private var _width:Number;
		private var _height:Number;
		private var _source:Object;
		public var faceID:String;
		private var mc:MovieClip;
		public function Face()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void{
			addEventListener(Event.REMOVED_FROM_STAGE,onRemoveedToStage);
			play();
		}
		
		private function onRemoveedToStage(event:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE,onRemoveedToStage);
			stop();
		}
		
		override public function set width(value:Number) : void{
			this._width = value;
			if(mc){
				mc.width = _width;
			}
		}
		override public function get width() : Number{
			return _width;
		}
		override public function set height(value:Number) : void{
			_height = value;
			if(mc){
				mc.height = _height;
			}			
		}
		override public function get height() : Number{
			return _height;
		}
		
		public function set source(value:Object) : void{
			_source = value;
			if(_source < 10){
				faceID = "&0"+_source;
			}else{
				faceID = "&"+_source;
			}
			createFace();
		}
		public function get source() : Object{
			return _source;
		}	
		
		public var hasImg:Boolean = false;
		private function createFace():void{
			if (ResourcePool.hasResource(GameConfig.FACES_URL)) {
				try{
					var mcClass:Class = ResourcePool.getClass(GameConfig.FACES_URL,"Face"+source);
					mc = new mcClass();
					if(!isNaN(_width)){
						mc.width = _width;
					}
					if(!isNaN(_height)){
						mc.height = _height;
					}
					addChild(mc);
					this.hasImg = true;
				}catch(e:Error){
					trace(e.message);
					this.hasImg = false;
				}
			} else {
				this.hasImg = false;
				ChatModule.getInstance().silentLoadFaceResouce();
			}
		}
		
		public function stop():void{
			if(mc){
				mc.stop();
			}
		}
		
		public function play():void{
			if(mc){
				mc.play();
			}
		}
	}
}