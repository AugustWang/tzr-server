package modules.help
{
	import com.common.GlobalObjectManager;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import modules.playerGuide.TipsView;

	/**
	 * 遮罩功能 
	 */	
	public class HelpMask extends Sprite
	{
		private var _rect:Rectangle;
		private var _callBack:Function;
		private var _btn:Sprite;
		private var _clickMode:String = "";
		public function HelpMask()
		{
		}
		
		public function show(rect:Rectangle,callBack:Function,clickMode:String=MouseEvent.CLICK):void{
			this._rect = rect;
			this._callBack = callBack;
			this._clickMode = clickMode;
			update();
		}
		
		private function update():void{
			if(_btn && _btn.parent){
				_btn.removeEventListener(MouseEvent.CLICK,doBtnCallback);
				_btn.removeEventListener(MouseEvent.DOUBLE_CLICK,doBtnCallback);
				_btn.removeEventListener(MouseEvent.MOUSE_DOWN,doBtnCallback);
				_btn.parent.removeChild(_btn);
			}
			var gc:Graphics = this.graphics;
			gc.clear();
			gc.beginFill(0,0.5);
			gc.drawRect(0,0,_rect.x,_rect.y);
			gc.drawRect(0,_rect.y,_rect.x,_rect.height);
			gc.drawRect(0,_rect.y+_rect.height,_rect.x,GlobalObjectManager.GAME_HEIGHT-(_rect.y+_rect.height));
			
			gc.drawRect(_rect.x,0,_rect.width,_rect.y);
			gc.drawRect(_rect.x,_rect.y+_rect.height,_rect.width,GlobalObjectManager.GAME_HEIGHT-(_rect.y+_rect.height));
			
			gc.drawRect(_rect.x+_rect.width,0,GlobalObjectManager.GAME_WIDTH-(_rect.x+_rect.width),_rect.y);
			gc.drawRect(_rect.x+_rect.width,_rect.y,GlobalObjectManager.GAME_WIDTH-(_rect.x+_rect.width),_rect.height);
			gc.drawRect(_rect.x+_rect.width,_rect.y+_rect.height,GlobalObjectManager.GAME_WIDTH-(_rect.x+_rect.width),GlobalObjectManager.GAME_HEIGHT-(_rect.y+_rect.height));
			
			_btn = new Sprite();
			_btn.buttonMode = true;
			_btn.graphics.beginFill(0xff0000,0);
			_btn.graphics.drawRect(_rect.x,_rect.y,_rect.width,_rect.height);

			if ( _clickMode == MouseEvent.DOUBLE_CLICK ) {
				_btn.doubleClickEnabled=true;
				_btn.addEventListener( _clickMode, doBtnCallback );
			} else {
				_btn.addEventListener( _clickMode, doBtnCallback );
			}
			
			addChild(_btn);
			
			LayerManager.alertLayer.addChild(this);
		}
		
		private function doBtnCallback(event:MouseEvent):void{
			if(_callBack!=null){
				_callBack.call();
			}
			LayerManager.alertLayer.removeChild(this);
		}
	}
}