package modules.shop.views
{
	import com.managers.ReSizeManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopItem;
	
	import proto.common.p_property_add;
	
	public class ShopTip extends UIComponent
	{
		private var tip:ShopTipView;
		
		public function ShopTip()
		{
			super();
			initView();
		}
		
		private static var _instance:ShopTip;
		public static function getInstance():ShopTip{
			if(!_instance){
				_instance = new ShopTip();
			}
			return _instance;
		}
		
		private function initView():void{
			this.bgSkin = Style.getInstance().tipSkin;
		}
		
		public function closeHandler(event:MouseEvent=null):void{
			if(ui && s.contains(this)){
				s.removeChild(this);
			}
		}

		private var ui:UIComponent;
		private var posX:int;
		private var posY:int;
		private var s:Stage;
		public function point(x:int,y:int,parent:UIComponent):void{
			posX = x;
			posY = y;
			s = parent.stage;
			ui = parent;
		}
			
		public function show(item:ShopItem):void{
			if(item != null){
				s.addChild(this);
				setItem(item);
		 	}
		}
		
		public function hide():void{
			if(tip && tip.parent){
				removeChild(tip);
				tip = null;
			}
			if(ui && s.contains(this)){
				s.removeChild(this);
			}
		}
		
		public var playerName:String;
		private function setItem(item:ShopItem):void{
			if(tip && tip.parent){
				removeChild(tip);
			}
		
			tip = new ShopTipView();
			tip.createItemTip(item);
			addChild(tip);
			width = tip.width;
			height = tip.height;
			this.x = posX;
			if(posY + this.height > ReSizeManager.minHeight){
				this.y = ReSizeManager.minHeight - this.height;
			}else{
				this.y = this.posY;
			}
		}
		
	}
}

