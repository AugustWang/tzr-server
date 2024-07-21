package modules.trading.views
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.trading.TradingModule;
	import modules.trading.tradingManager.TradingManager;
	
	import proto.line.m_trading_shop_toc;
	
	public class TradingsmallView extends BasePanel
	{
		private var  smallBtn:UIComponent; 
		private var saleTimeTxt:TextField;
		private var buyTimeTxt:TextField;
		
		private var max_sale_time:int;
		private var max_buy_time:int;
		
		private var update_time:int;
		private var _update:int;
		
		private var timer:Timer  ;
		
		
		
		public function TradingsmallView(key:String=null)
		{
			super(key);
			
			this.width = 220;
			this.height = 94;//95
			
			var bigButtonSkin:ButtonSkin=Style.getButtonSkin("task_big",
				"task_bigOver","task_bigDown",null,GameConfig.T1_UI);
			
			smallBtn = createUIComponent(178,6,18,18,bigButtonSkin);
			this.addChildToSuper(smallBtn);
			
			smallBtn.addEventListener(MouseEvent.CLICK,onSmallClickHandler);
			
			var m_bg:UIComponent = ComponentUtil.createUIComponent(12,2,195,50);
			Style.setBorder1Skin(m_bg);
			addChild(m_bg);
			
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF53F3C,null,null,null,null,null,"center");
			
			saleTimeTxt = ComponentUtil.createTextField("最佳出售时间：YY秒后",18,28,tf,183,20,this);
			
			buyTimeTxt = ComponentUtil.createTextField("最佳购买时间：YY秒后",18,6,tf,183,20,this);
			
		}
		
		private function createUIComponent(xValue:Number, yValue:Number, width:Number, height:Number, skin:Skin):UIComponent
		{
			var result:UIComponent = new UIComponent();
			result.x = xValue;
			result.y = yValue;
			result.width = width;
			result.height = height;
			
			skin == null ? '' : result.bgSkin = skin;
			
			return result;
		}
		
		public function setData(vo:m_trading_shop_toc):void
		{
			_update = vo.update_time;
			update_time = vo.update_time;
			if(update_time>40)
			{
				update_time = int(update_time/4);
				
			}else if(update_time>20)
			{
				update_time = int(update_time/2);
				
			}
			max_sale_time = vo.max_sale_time;
			max_buy_time = vo.max_buy_time;
			if(max_sale_time >0)
			{
				saleTimeTxt.text = "最佳出售时间：" + max_sale_time +
					"秒后";
			}else if(max_sale_time==0){
				saleTimeTxt.text = "最佳出售时间：现在" ;
			}
			if(max_buy_time >0)
			{
				buyTimeTxt.text = "最佳购买时间：" + max_buy_time +
					"秒后";
			}else if(max_buy_time==0){
				buyTimeTxt.text = "最佳购买时间：现在" ;
			}
			
			
			if(_update>1)
			{
				TradingManager.IS_LOCK = false;
			}
			if(timer)
			{
				removetimer();
			}
			timer = new Timer(1000,update_time);
			timer.addEventListener(TimerEvent.TIMER,ontimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,onUpdateRequest);
			timer.start();
			
		}
		
		private function onUpdateRequest(evt:TimerEvent):void
		{
			if(timer)
			{
				timer.removeEventListener(TimerEvent.TIMER,ontimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onUpdateRequest);
				timer.stop();
				timer = null;
			}
			TradingModule.getInstance().getTradingShop_tos(TradingManager.current_trading_npcId);
		}
		
		private function removetimer():void
		{
			if(timer)
			{
				timer.removeEventListener(TimerEvent.TIMER,ontimer);
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onUpdateRequest);
				timer.stop();
				timer = null;
			}
		}
		
		private function ontimer(evt:TimerEvent):void
		{
			if(timer.currentCount == _update-1)
			{
				TradingManager.IS_LOCK = true;
			}
			if(max_sale_time>0)
			{
				max_sale_time--;
				saleTimeTxt.text = "最佳出售时间：" + max_sale_time +
					"秒后";
			}else if(max_sale_time==0)
			{
				saleTimeTxt.text = "最佳出售时间：现在" ;
			}
			if(max_buy_time>0)
			{
				max_buy_time--;
				buyTimeTxt.text = "最佳购买时间：" + max_buy_time +
					"秒后";
			}else if(max_buy_time==0){
				buyTimeTxt.text = "最佳购买时间：现在" ;
			}
		}
		
		private function onSmallClickHandler(e:MouseEvent):void
		{
			TradingModule.getInstance().showSmallview(false);
		}
		override public function dispose():void
		{
			super.dispose();
			removetimer();
		}
		
	}
}

