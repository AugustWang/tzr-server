package modules.mypackage.views
{
	import com.common.GlobalObjectManager;
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
	
	public class ChatItemToolTip extends DragUIComponent
	{
		private static var queue:Dictionary = new Dictionary();
		private static var arrayTips:Array = [];
		private var closeBtn:UIComponent;
		private var tip:BaseTip;
		public var roleName:String;
		public var sex:int;
		public function ChatItemToolTip()
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
			delete queue[itemId];
			arrayTips.splice(arrayTips.indexOf(this),1);
			if(parent){
				WindowManager.getInstance().closeDialog(this);
				unLoad();
			}
			updatePostion();
		}
		
		public static function remove(itemId:int):void{
			delete queue[itemId];	
		}
		
		
		public static function add(itemId:int,roleName:String,sex:int):void{
			var tipDesc:Object = queue[itemId];
			if(tipDesc == null){
				queue[itemId] = {itemId:itemId,roleName:roleName,sex:sex};
				ChatModule.getInstance().getGoodsInfo(itemId);
			}
		}
		
		public static function show(itemVO:BaseItemVO):void{
			var tipDesc:Object = queue[itemVO.oid];
			if(tipDesc){
				var tip:ChatItemToolTip;
				if(arrayTips.length == 3){
					tip = arrayTips.pop() as ChatItemToolTip;
				}else{
					tip = new ChatItemToolTip();
				}
				tip.roleName = tipDesc.roleName;
				tip.sex = tipDesc.sex;
				arrayTips.unshift(tip);
				tip.setItemVO(itemVO);
				WindowManager.getInstance().openDialog(tip,false);
				updatePostion();
			}
		}
		
		private static function updatePostion():void{
			var start:Number = 270;
			for(var i:int=0;i<arrayTips.length;i++){
				var tip:ChatItemToolTip = arrayTips[i] as ChatItemToolTip;
				tip.x = start;
				if(tip.height + 150 > GlobalObjectManager.GAME_HEIGHT){
					tip.y = GlobalObjectManager.GAME_HEIGHT - (tip.height + 5);
				}else{
					tip.y = 150;
				}
				start += tip.width;
			}
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