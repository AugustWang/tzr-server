package modules.finery.views.item
{
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import modules.chat.ChatModule;
	import modules.mypackage.components.BaseTip;
	import modules.mypackage.components.EquipTip;
	import modules.mypackage.components.ItemTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class BoxItemToolTip extends DragUIComponent
	{
		private var closeBtn:UIComponent;
		private var tip:BaseTip;
		public var roleName:String;
		public var sex:int;
		public function BoxItemToolTip()
		{
			super();
			this.bgSkin = Style.getInstance().tipSkin;
			closeBtn = new UIComponent();
			closeBtn.y = 2;
			closeBtn.buttonMode=true
			closeBtn.bgSkin = Style.getButtonSkin("close_1skin","close_2skin","close_3skin",null,GameConfig.T1_UI)
			closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
			addChild(closeBtn);
		}
		
		private function closeHandler(event:MouseEvent):void{
			unLoad();
		}
		
		override public function unLoad():void{
			if(parent){
				WindowManager.getInstance().closeDialog(this);
			}
			//super.unLoad();
		}
		
		public function show(itemVO:BaseItemVO,roleName:String,sex:int):void{
			this.roleName = roleName;
			this.sex = sex;
			setItemVO(itemVO);
			WindowManager.getInstance().openDialog(this,false);
		}
		
		private var itemId:int;
		private function setItemVO(itemVO:BaseItemVO):void{
			itemId = itemVO.oid;
			if(tip && tip.parent){
				removeChild(tip);
			}
			if(itemVO is EquipVO){
				tip = new EquipTip();
			}else{
				tip = new ItemTip();
			}
			tip.roleName = roleName;
			tip.sex = sex;
			tip.type = BaseTip.CHAT_TOOLTIP;
			addChild(tip);
			tip.createItemTip(itemVO);
			width = tip.width+22;
			height = tip.height;
			closeBtn.x = width - 19;
		}
	}
}