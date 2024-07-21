package modules.pet.view
{
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopDataManager;
	import modules.shop.ShopItem;

	public class GoodsToolTipView extends Sprite
	{
		private var startY:Number=8;
		//private var itemName:TextField;
		private var itemDesc:TextField;
		public function GoodsToolTipView()
		{
			var tf:TextFormat=Style.textFormat;
			tf.leading=4;
			itemDesc=ComponentUtil.createTextField("",8,0,tf,144,NaN,this,wrapperHandler);
		}
		private function wrapperHandler(text:TextField):void{
			text.wordWrap=true;
		}
		
		public function createItemTip(vo:BaseItemVO):void{
			
			clearTip();
			if(vo==null) return;
			startY=5;
			var htmlTxt:String="";
			htmlTxt=wrapperHTML(vo);
			itemDesc.y=startY;
			itemDesc.htmlText=htmlTxt;
			itemDesc.height=itemDesc.textHeight+5;
			startY+=itemDesc.height;
			
			
		}
		/*private function createTip(item:ShopItem):void{
			clearTip();
			if(item==null) return;
			startY=5;
			var htmlTxt:String="";
			htmlTxt=wrapperHTML(item);
			itemDesc.y=startY;
			itemDesc.htmlText=htmlTxt;
			itemDesc.height=itemDesc.textHeight+5;
			startY+=itemDesc.height;
		}*/
		private function clearTip():void{
			itemDesc.htmlText="";
		}
		private function wrapperHTML(vo:BaseItemVO):String{
			//var color:String=item.colour;
			//var item:ShopItem=ShopModule.getInstance().getShopItem(10103,vo.typeId);
			/*if(item==null){
				item=ShopModule.getInstance().getShopItem(101114,vo.typeId);
			} if(item==null){
				item=ShopModule.getInstance().getShopItem(101115,vo.typeId);
			} if(item==null){
				item=ShopModule.getInstance().getShopItem(101116,vo.typeId);
			}if(item==null){
				item=ShopModule.getInstance().getShopItem(101116,vo.typeId);
			}*/
			var itemp:ShopItem=null;
			var item:ShopItem=ShopDataManager.getInstance().getItem(vo.typeId,10103);
			var item1:ShopItem=ShopDataManager.getInstance().getItem(vo.typeId,10114);
			var item2:ShopItem=ShopDataManager.getInstance().getItem(vo.typeId,10115);
			var item3:ShopItem=ShopDataManager.getInstance().getItem(vo.typeId,10116);
			var item4:ShopItem=ShopDataManager.getInstance().getItem(vo.typeId,10117);
			itemp=item1!=null?item1:(item2!=null?item2:(item3!=null?item3:(item4!=null?item4:null)));
			if(itemp!=null){
				item=itemp;
			}
			
			var color:String=ItemConstant.COLOR_VALUES[vo.color];
			var htmlTxt:String="";
			var desc:String="";
			//var price:String="";
			/*if(item.colour!=null){
				color=item.colour;
			}*/
			
				htmlTxt=getName(vo.name,color,14);
			
			
				desc=vo.desc.split("\\n").join("\n");
				htmlTxt+=getDesc(desc,color,12);
			
			if(item!=null){
				//price=item.price;//此处只做原价显示，未有区分VIP，VIP的价格在商城购买时会有显示。
				htmlTxt+=getPrice(item.price,"#0099ff");
		
			
				htmlTxt+=item.sellTime;
			}
		
			return htmlTxt;
		}
		private function getName(name:String,color:String,fontSize:int):String{
			return HtmlUtil.fontBr(HtmlUtil.bold(name),color,fontSize);
		}
		private function getDesc(desc:String,color:String,fontSize:int):String{
			return HtmlUtil.fontBr(desc,color,fontSize);
		}
		private function getPrice(price:String,color:String):String{
			var priceStr:String=HtmlUtil.font("单价:",color);
			    priceStr+=HtmlUtil.font(price,color);
				priceStr+="\n";
				return priceStr;
		}
		override public function get height():Number{
			return startY+5;
		}
		override public function get width():Number{
			return 158;
		}
	}
}