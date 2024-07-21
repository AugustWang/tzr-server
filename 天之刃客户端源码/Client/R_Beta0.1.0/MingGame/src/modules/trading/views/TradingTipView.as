package modules.trading.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.trading.tradingManager.TradingManager;
	import modules.trading.vo.TradingGoodVo;

	public class TradingTipView extends Sprite
	{
		private var startY:Number = 8;
		
		private var itemName:TextField; //名称描述 和 打造描述
		private var border:Sprite;
		private var icon:Image; //装备图像
		private var itemDesc:TextField; //商品描述
		
		public function TradingTipView()
		{
			super();
			var tf:TextFormat = Style.textFormat;
			tf.leading = 4;
			itemName = ComponentUtil.createTextField("",8,0,tf,170,NaN,this,wrapperHandler);
			border = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			border.x = 10;
			addChild(border);
			icon = new Image();
			icon.x = icon.y = 2;
			border.addChild(icon);
			
			itemDesc = ComponentUtil.createTextField("",8,0,tf,180,NaN,this,wrapperHandler);
		}
		private function wrapperHandler(text:TextField):void{
			text.wordWrap = true;
		}
		
		public function createItemTip(itemVo:TradingGoodVo):void
		{
			clearTip();
			
			if(itemVo == null)return;
			startY = 8;
			var htmlText:String = "";
			var color:String = ItemConstant.COLOR_VALUES[itemVo.color];
			htmlText = getName(itemVo.name,color);
			
			itemName.htmlText = htmlText;
			itemName.y = startY;
			
			startY  = startY + itemName.textHeight + 5;
			htmlText = "";
			
			icon.source = itemVo.url;
			
			startY = startY + 3;
			border.y = startY;
			
			htmlText += wapper("数量",itemVo.num);
			
			htmlText += wapper("",itemVo.desc,color,color);
			if(itemVo.showType == 1){
				if(itemVo.buy_price > 0){
					htmlText += wapper("买入价格",itemVo.buy_price);
				}
				if(itemVo.npcId !=TradingManager.current_trading_npcId){
					htmlText += wapper("卖出价格",itemVo.sale_price);
				}
			}else{
				if(itemVo.buy_price > 0){
					htmlText += wapper("买入价格",itemVo.sale_price);
				}
			}
			
			itemDesc.htmlText = htmlText;
			startY = startY + border.width + 5;
			itemDesc.y = startY;
			itemDesc.height = itemDesc.textHeight + 5;
			
			startY = startY + itemDesc.height + 5;
			
		}
		
		private function clearTip():void{
			itemName.htmlText = "";
			itemDesc.htmlText = "";
		}
		
		private function getName(name:String,color:String):String{	
			return HtmlUtil.fontBr(HtmlUtil.bold(name),color,14);
		}
		
		
		protected function wapper(name:String,data:Object,nameColor:String="#ffffff",textColor:String="#ffffff",space:String="    "):String{
			if(data == null)return "";
			if(name == "" && data == "")return "";
			if(name == ""){
				return HtmlUtil.fontBr(data.toString(),textColor)
			}
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr(space+data.toString(),textColor);
		}
		
		override public function get height():Number{
			return startY + 5;
		}
		
		override public function get width():Number{
			return 190;
		}
		
	}
}


