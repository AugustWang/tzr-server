package com.common.effect
{
	import com.managers.LayerManager;
	import com.ming.ui.controls.Image;
	
	import flash.display.DisplayObject;

	public class ZoomEffect
	{
		private var runing:Boolean = false;
		private var queues:Vector.<Object>;
		public function ZoomEffect()
		{
			queues = new Vector.<Object>();
		}
		
		public function zoomTo(source:*,x:Number=0,y:Number=0,toX:Number=0,toY:Number=0,cX:int=590,cY:int=410,scaleX:Number=1,scaleY:Number=1,duration:Number=10):void{
			var desc:Object = {source:source,x:x,y:y,toX:toX,toY:toY,cX:cX,cY:cY,scaleX:scaleX,scaleY:scaleY,duration:duration};
			if(runing){
				queues.push(desc);
				return;	
			}
			zoom(desc);
		}
		
		private function zoom(desc:Object):void{
			var mc:DisplayObject; 
			if(desc.source is String){
				var img:Image = new Image();
				img.mouseChildren = img.mouseEnabled = false;
				img.defaultIcon = null;
				img.source = desc.source;
				mc = img;
			}else if(desc.source is DisplayObject){
				mc = desc.source;
			}
			if(mc){
				LayerManager.main.addChild(mc);
				mc.x = desc.x;
				mc.y = desc.y;
				Tween.to(mc,10, {x:desc.cX, y:desc.cY,scaleX:1.5, scaleY:1.5,onComplete:onCenterComplete,onCompleteParams:[mc,desc]});
				runing = true;
			}
		}
		
		private function onCenterComplete(mc:DisplayObject,desc:Object):void{
			Tween.to(mc,desc.duration, {x:desc.toX, y:desc.toY,scaleX:desc.scaleX, scaleY:desc.scaleY,onComplete:onComplete,onCompleteParams:[mc]});
			if(queues.length > 0){
				var source:Object = queues.shift();
				zoom(source);
			}
		}
		
		private function onComplete(mc:DisplayObject):void{
			if(mc && mc.parent){
				mc.parent.removeChild(mc);
			}
			mc = null;
			runing = false;
			if(queues.length > 0){
				var source:Object = queues.shift();
				zoomTo(source.source,source.x,source.y,source.toX,source.toY,source.cX,source.cY,source.scaleX,source.scaleY,source.duration);
			}
		}
	}
}