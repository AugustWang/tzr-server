package modules.rank.view
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import modules.mypackage.components.BaseTip;
	import modules.mypackage.components.EquipTip;
	import modules.mypackage.components.ItemTip;
	import modules.mypackage.views.ToolTipContainer;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class RankEquipToolTip extends DragUIComponent 
	{
		private var closeBtn:UIComponent;
		private var tip:BaseTip;
		private static var _instance:RankEquipToolTip;
		public function RankEquipToolTip()
		{
			super();
			this.bgSkin = Style.getInstance().tipSkin;
			closeBtn = new UIComponent();
			closeBtn.y = 2;
			closeBtn.buttonMode=true;
			closeBtn.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI)
			closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
			addChild(closeBtn);
		}
		
		public static function getInstance():RankEquipToolTip{
			if(!_instance){
				_instance = new RankEquipToolTip();
			}
			return _instance;
		}
		
		public function closeHandler(event:MouseEvent=null):void{
			if(ui && LayerManager.alertLayer.contains(this)){
				WindowManager.getInstance().closeDialog(this);
			}
		}
		
		private var ui:UIComponent;
		private var posX:int;
		private var posY:int;
		public function point(x:int,y:int,$parent:UIComponent):void{
			posX = x;
			posY = y;
			ui = $parent;
		}
		
		public function show(itemVO:BaseItemVO):void{
			if(itemVO != null){
				WindowManager.getInstance().openDialog(this,false);
				setItemVO(itemVO);
			}
		}
		
		public var playerName:String;
		private function setItemVO(itemVO:BaseItemVO):void{
			if(tip && tip.parent){
				removeChild(tip);
			}
			if(itemVO is EquipVO){
				tip = new EquipTip();
			}else{
				tip = new ItemTip();
			}
			tip.roleName = playerName;
			tip.type = BaseTip.CHAT_TOOLTIP;
			tip.createItemTip(itemVO);
			addChild(tip);
			width = tip.width;
			height = tip.height;
			this.x = posX;
			if(posY + this.height >GlobalObjectManager.GAME_HEIGHT){
				this.y = GlobalObjectManager.GAME_HEIGHT - this.height-5;
			}else{
				this.y = this.posY;
			}
			closeBtn.x = width - 22;
		}
	}
}