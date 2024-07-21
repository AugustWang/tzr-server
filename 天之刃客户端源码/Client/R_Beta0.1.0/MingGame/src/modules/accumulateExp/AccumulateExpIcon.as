package modules.accumulateExp
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class AccumulateExpIcon extends Sprite
	{
		private var _tip:String;
		private var thing:Thing;
		
		public function AccumulateExpIcon()
		{
			super();
			init();
		}
		
		public function set tip(str:String):void
		{
			this._tip = str;
		}
		
		private function init():void
		{
			this.addChild(Style.getSprite(GameConfig.T1_VIEWUI,'lixianjingyan'));
			this.addEventListener(MouseEvent.MOUSE_OVER, showTip);
			this.addEventListener(MouseEvent.MOUSE_OUT, removeTip);
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:Event):void
		{
			AccumulateExpModule.getInstace().showAccumulateView();
		}
		
		
		private function showTip(e:Event):void
		{
			if(_tip != ""){
				ToolTipManager.getInstance().show(_tip);
			}
			this.useHandCursor = true;
		}
		
		private function removeTip(e:Event):void
		{
			ToolTipManager.getInstance().hide();
			this.useHandCursor = false;
		}
	}
}