package modules.trading.views.item
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.broadcast.views.Tips;
	import modules.trading.TradingModule;
	import modules.trading.tradingManager.TradingManager;
	import modules.trading.vo.TradingGoodVo;
	
	public class TradingItemRender extends Sprite implements IDataRenderer
	{
		protected var item:TradingItem;
		protected var numText:TextField;
		protected var priceText:TextField;
		protected var familyText:TextField;
		protected var oprateText:TextField;
		
		protected var textFormat:TextFormat;
		
		public static var ItemHeight:Number = 38;
		
		public function TradingItemRender()
		{
			super();
			item = new TradingItem();
			item.width = 36;
			item.height = 36;
			item.y = 2;
			addChild(item);
			
			textFormat =new TextFormat(null, 12, 0xEBE7BA);// Constant.TEXTFORMAT_DEFAULT;
			textFormat.align = TextFormatAlign.CENTER;
			numText =  ComponentUtil.buildTextField("",textFormat,52,ItemHeight,this);
			numText.y = 12;
			
			priceText =  ComponentUtil.buildTextField("",textFormat,84,ItemHeight,this);
			priceText.y = 12;
			
//			familyText =  ComponentUtil.buildTextField("",textFormat,100,ItemHeight,this);
//			familyText.y = 2;
			
			oprateText =  ComponentUtil.buildTextField("",textFormat,68,ItemHeight,this);
			oprateText.mouseEnabled = true;
			oprateText.y = 12;
			oprateText.addEventListener(TextEvent.LINK, buyHandler);
			
			LayoutUtil.layoutHorizontal(this,0,18);
		}
		private function buyHandler(e:TextEvent):void
		{
			if(TradingManager.IS_LOCK)
			{
				Tips.getInstance().addTipsMsg("商品数量变动中，请稍候再操作。");
				return;
			}
			if(TradingModule.getInstance().getBeginBill()==0)
			{
				//没有商票，不能购买。请先到夏原吉领取商票。
				Tips.getInstance().addTipsMsg("没有商票，不能购买。请先到夏原吉领取商票。");
				return;
			}
			
			var vo:TradingGoodVo = data as TradingGoodVo;
			if(vo.num==0)
			{
				Tips.getInstance().addTipsMsg("该商品已出售完");
				return;
			}
			
			TradingModule.getInstance().openBuyPanle(vo);
		}
		
		protected var _data:Object;
		public function set data(value:Object):void{
			_data = value; 
			var goods:TradingGoodVo = value as TradingGoodVo;
			if(goods!=null){
				item.data = goods;
				numText.text = String(goods.num);
				priceText.text = String(goods.sale_price) + "文";
				oprateText.htmlText = "<font color='#00ff00'><a href='event:openBuy' ><u>购买</u></a></font>";
				
				/*item.data = GameConstant.getHeaditem(friend.head);
				numText.text = friend.rolename;
				priceText.text = GameConstant.getNation(friend.faction_id);
				familyText.text = friend.family_name;
				oprateText.text = friend.office_name;*/
			}			
		}
		
		public function get data():Object{
			return _data;
		}
	}
}