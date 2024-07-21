package modules.factionsWar.views.items
{
	import com.events.ParamEvent;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.factionsWar.FactionWarDataManager;
	
	public class FactionGuardsItem extends Sprite implements IDataRenderer
	{
		public static const GUARD_BUY_EVENT:String="GUARD_BUY_EVENT";
		private var guard:TextField;
		private var cost:TextField;
		private var oper:TextField;
		private var vo:Object;
		private var _isLeft:Boolean;
		public function FactionGuardsItem()
		{
			super();
			var tf:TextFormat=Style.textFormat;
			tf.align="center";
			guard=ComponentUtil.createTextField("", 0, 0, tf, 120, 22, this);
			cost=ComponentUtil.createTextField("", 0, 0, tf, 120, 22, this);
			oper=ComponentUtil.createTextField("", 0, 0, tf, 76, 22, this);
			oper.mouseEnabled=true;
			LayoutUtil.layoutHorizontal(this);
			oper.addEventListener(TextEvent.LINK,onLink);
		}
		private function onLink(e:TextEvent):void{
			var guardLevel:int=vo.level;
			var typeid:int=FactionWarDataManager.getGuardTypeid(_isLeft,guardLevel);
			var evt:ParamEvent=new ParamEvent(GUARD_BUY_EVENT,typeid,true);
			this.dispatchEvent(evt);
		}
		public function set data(value:Object):void
		{
			vo=value;
			guard.text=vo.g;
			cost.text=vo.m;
			oper.htmlText=vo.o;
			_isLeft=vo.left;
		}
		
		public function get data():Object
		{
			return vo;
		}
		
	}
}