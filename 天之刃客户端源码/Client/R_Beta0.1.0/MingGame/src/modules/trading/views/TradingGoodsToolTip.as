package modules.trading.views
{
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import modules.trading.vo.TradingGoodVo;
	
	public class TradingGoodsToolTip extends UIComponent
	{
		
		private var tip:TradingTipView;//BaseTip;
		private static var _instance:TradingGoodsToolTip;
		public function TradingGoodsToolTip()
		{
			super();
			this.bgSkin = Style.getInstance().tipSkin;
		}
		
		public static function getInstance():TradingGoodsToolTip{
			if(!_instance){
				_instance = new TradingGoodsToolTip();
			}
			return _instance;
		}
		
		public function closeHandler(event:MouseEvent=null):void{
			if(ui && s.contains(this)){
				s.removeChild(this);
			}
		}
//		ToolTipManager.getInstance().getContainer();
		private var ui:UIComponent;
		private var posX:int;
		private var posY:int;
		private var s:Stage;
		public function point(x:int,y:int,$parent:UIComponent):void{
			posX = x;
			posY = y;
			s = $parent.stage;
			ui = $parent;
		}
		
		public function show(itemVO:TradingGoodVo):void{
			if(itemVO != null){
				s.addChild(this);
				setItemVO(itemVO);
			}
		}
		
		public function hide():void
		{
			if(tip && tip.parent){
				removeChild(tip);
				tip = null;
			}
			if(ui && s.contains(this)){
				s.removeChild(this);
			}
		}
		
		public var playerName:String;
		private function setItemVO(itemVO:TradingGoodVo):void{
			if(tip && tip.parent){
				removeChild(tip);
			}
			
			tip = new TradingTipView();
			
			tip.createItemTip(itemVO);
			addChild(tip);
			width = tip.width;
			height = tip.height;
			this.x = posX;
			if(posY + this.height >GlobalObjectManager.GAME_HEIGHT){
				this.y = GlobalObjectManager.GAME_HEIGHT - this.height;
			}else{
				this.y = this.posY;
			}
//			closeBtn.x = width - 22;
		}
	}
}

