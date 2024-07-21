package modules.shop.views
{
	import com.common.Constant;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.ShareObjectUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.mypackage.ItemConstant;
	import modules.shop.ShopConstant;
	import modules.shop.ShopItem;
	import modules.system.SystemConfig;
	
	public class BuyGoodsDialog extends BasePanel
	{
		private var text:TextField;
		private var todayTipChk:CheckBox;
		private var yesBtn:Button;
		private var noBtn:Button;
		
		public var yesCallBack:Function;
		
		public function BuyGoodsDialog()
		{
			initView();
		}
		
		private function initView():void{
			this.title = "购买物品";
			this.width = 300;
			this.height = 140;
			addContentBG(30,8,0);
			
			text = ComponentUtil.createTextField("",12,10,null,340,40,this);
			text.wordWrap = true;
			text.multiline = true;
			
			todayTipChk = ComponentUtil.createCheckBox("今天不再提示",180,40,this);
			todayTipChk.textFormat = Constant.TEXTFORMAT_COLOR_GRAYYELLOW;
			
			yesBtn = ComponentUtil.createButton("确定",50,72,70,25,this);
			noBtn = ComponentUtil.createButton("取消",width-120,72,70,25,this);
		
			todayTipChk.addEventListener(Event.CHANGE,changeHandler);
			yesBtn.addEventListener(MouseEvent.CLICK,yesHandler);
			noBtn.addEventListener(MouseEvent.CLICK,noHandler);
		}
		
		private static var _instance:BuyGoodsDialog;
		public static function getInstance():BuyGoodsDialog{
			if(_instance == null){
				_instance = new BuyGoodsDialog();
			}	
			return _instance;
		}
		
		private function changeHandler(event:Event):void{
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			if(todayTipChk.selected){
				var currentDate:Date = new Date();
				currentDate.time = SystemConfig.serverTime*1000;
				var key:String = "buyTip"+(currentDate.fullYear+"_"+currentDate.month+"_"+currentDate.day)+"_"+userId;
				ShareObjectUtil.save(key,0);
				ShopConstant.todayHasTip = false;
				ShopConstant.todayHasInit = true;
			}
		}
		
		public function openDialog(shopItem:ShopItem,count:int,yesHandler:Function):void{
			this.yesCallBack = yesHandler;
			var html:String = "    你是否花"+HtmlUtil.font(shopItem.calcMoney(count),"#00ff00")+"元宝，购买"+HtmlUtil.font("【" + shopItem.name + "】", shopItem.colour)+"x"+count;	
			text.htmlText = html;
			if(isPopUp){
				WindowManager.getInstance().bringToFront(this);	
			}else{
				centerOpen();
			}
		}
		
		private function yesHandler(event:MouseEvent):void{
			if(yesCallBack != null){
				yesCallBack();
			}
			closeWindow();
		}
		
		private function noHandler(event:MouseEvent):void{
			closeWindow();
		}
	}
}