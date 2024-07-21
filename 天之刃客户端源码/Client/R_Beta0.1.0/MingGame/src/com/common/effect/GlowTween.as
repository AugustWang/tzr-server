package com.common.effect
{
        import flash.display.DisplayObject;
        import flash.display.InteractiveObject;
        import flash.events.Event;
        import flash.events.MouseEvent;
        import flash.filters.GlowFilter;
		/**
		 * 
		 * 发光效果类
		 * 
		 */		
        public class GlowTween
        {
				/**
				 *目标对象 
				 */			
                private var _target:DisplayObject; 
				/**
				 * 发光颜色 
				 */				
                private var _color:uint;
				/**
				 * 用来表示是逐渐向外发光还是向内缩小 
				 */				
                private var _toggle:Boolean;
                private var _blur:Number;
				/**
				 *高亮 (0:默认的发光，1...：高亮)
				 */  
				private var hightLight:int = 0;
				private var streght:Number = 2;
				private var alpha:Number = 1;
                public static const  min:Number = 5;
                public static const  max:Number = 15;

                public function GlowTween()
                {

                }

                public function startGlow(target:DisplayObject,$alpha:Number = 1, color:uint=0xFFFFFF,$hightLight:int=0,$streght:Number = 2):void
                {
					if(target==null)return;
					_target=target;
					_color=color;
					_toggle=true;
					_blur=min;
					alpha = $alpha;
					hightLight = $hightLight;
					streght = $streght;
                    _target.addEventListener(Event.ENTER_FRAME, blinkHandler, false, 0, true);
                }

                public function stopGlow():void
                {
					if(_target){
                        _target.removeEventListener(Event.ENTER_FRAME, blinkHandler);
                        _target.filters=null;
						_target = null;
					}
                }
				
				public function running():Boolean{
					return _target != null;
				}
				
                private function blinkHandler(evt:Event):void
                {
                        if (_blur >= max)
                                _toggle=false;
                        else if (_blur <= min)
                                _toggle=true;
						if(hightLight == 0){
                        	_toggle ? _blur++ : _blur--;
						}else{
							_blur = 6;
						}
                        var glow:GlowFilter=new GlowFilter(_color, alpha, _blur, _blur, 4, streght, false, false);
                        var temp:Array = new Array(glow);
                        _target.filters = temp;
                }
        }
}