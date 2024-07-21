package modules.trading.views
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.trading.TradingModule;
	import modules.trading.tradingManager.TradingManager;
	
	public class DoubleTipView extends BasePanel
	{
		private var icon:Image;
		private var descTxt:TextField;
		private var getSilverTf:TextField;
		
		private var checkbox:CheckBox;
		private var sureBtn:Button;
		private var cacelBtn:Button;
		private var type:int = 1;        //1 普通交票，  2 使用宝典。 
		private var getbill:int=0;
		private var award_type:int = 1;
		
		public function DoubleTipView()
		{
			super();
			
			this.width = 275;
			this.height = 195;
			
			initView();
		}
		
		private function initView():void
		{
			// w 255 h 122
			var bgUi:UIComponent = ComponentUtil.createUIComponent(10,5,255,125);
			Style.setBorder1Skin(bgUi);
			addChild(bgUi);
			
			var overBorder:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg") ;// shangdian_kuang //borderItemBg
			overBorder.x = 16;
			overBorder.y = 22;
			addChild(overBorder);
			
			var bookItem:Object = ItemLocator.getInstance().getGeneral(TradingManager.BOOK_TYPE);
			icon = new Image();
			icon.source =  bookItem.path;//GameConfig.ROOT_URL +
			icon.x = 22;
			icon.y = 28;
			addChild(icon);
			
//			84 20
			var tf:TextFormat = Style.textFormat;
			tf.leading = 8;
			descTxt = ComponentUtil.createTextField("",84,16,tf,166,66,this);
//			descTxt.textColor = 0xF6F5CD;
			descTxt.wordWrap = true;
			descTxt.multiline = true;
			descTxt.text = "周日使用商贸宝典可获得双倍收益，商贸宝典可使用门派贡献度在门派长老处兑换。";
			
			//"使用商贸宝典可获得双倍收益,商贸宝典可以使用门派贡献度去门派长老处兑换获得。";
			
			getSilverTf = ComponentUtil.createTextField("",18,83,tf,230,22,this);
			getSilverTf.htmlText = "此时交还商票将获得不绑定银子<font color='#00ff00'>"+getbill+"</font>文。"  ;
			
			checkbox = new CheckBox();
			checkbox.width = 185;
			checkbox.height = 25;
			checkbox.x = 18;
			checkbox.y = 102;
			checkbox.htmlText = "<font color='#ffff00'>使用商贸宝典交还商票</font>";
			checkbox.addEventListener(Event.CHANGE, checkHandler);
			
			addChild(checkbox);
			
			sureBtn = ComponentUtil.createButton("确定",123,130,66,25,this);
			sureBtn.addEventListener(MouseEvent.CLICK,sureHandler);
			
			cacelBtn = ComponentUtil.createButton("取消",198,130,66,25,this);
			cacelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			
			var itemVo:BaseItemVO = PackManager.getInstance().getGoodsVOByType(TradingManager.BOOK_TYPE);
			
			if(itemVo)
			{
				setCheckBoxSeleted(true);
				type = 2;
			}else{
				setCheckBoxSeleted(false);
				type = 1;
			}
			
		}
		
		public function setGetBill(bill:int,award:int=1):void  // 1 不绑定的银子，  2绑定的银子
		{
			getbill = bill;
			award_type = award;
			setBillTf();
		}
		private function setBillTf():void
		{
			var is_no_bind:String = "不";
			if(award_type==2)
				is_no_bind = "";
			getSilverTf.htmlText = "此时交还商票将获得"+ is_no_bind+"绑定银子<font color='#00ff00'>"+(getbill * type)+"</font>文。"; 
		}
		
		private function setCheckBoxSeleted(flag:Boolean):void
		{
			checkbox.setSelected(flag);
		}
		
		
		private function checkHandler(evt:Event):void
		{
			 if(checkbox.selected)
			 {
				 type = 2 ;
				 
			 }else{ 
				 type = 1;
				 
			 }
			 setBillTf();
		}
		
		private function sureHandler(evt:MouseEvent):void
		{
			TradingModule.getInstance().return_tos(TradingManager.current_trading_npcId,type,true);
			sureBtn.enabled = false;
			cacelBtn.enabled = false;
		}
		public function setBtnEnabled():void
		{
			sureBtn.enabled = true;
			cacelBtn.enabled = true;
		}
		
		private function cancelHandler(evt:MouseEvent):void
		{
//			closeHandler();
			var event:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			this.dispatchEvent(event);
		}
		
//		override protected function closeHandler(event:CloseEvent=null):void
//		{
//			var event:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
//			this.dispatchEvent(event);
//		}
		
	}
}


