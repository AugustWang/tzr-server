package modules.deal.views.stallViews
{
	
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.shop.ShopItem;

//	import modules.shop.views.ShopGoodsItem;
	
	public class StallBuyWindow extends BasePanel
	{
		
		private var goodsItem:GoodsImage;
		private var goodsName:TextField; // "商品：大力丸";
		
		private var price_txt:TextField; // 单价
		private var priceTxt:TextField;
		private var timeTxt:TextField;
		
		private var buyTxt:TextField;     //输入购买数量：   fontSize = 14
		
		private var numInputTxt:TextInput;     // 输入个数
		
		private var totalNumTxt:TextField;    // "/37个"
		
		private var costTxt:TextField;     //  需花费银子：XX锭XX两XX文
		
		private var OK_btn:Button;        //确定
		
		private var CANCEl_btn:Button;    //取消
		
		//   变量  ///
		private var totalNum:int = 0;
		
		private var num:int=1;
		
		private var price:int = 10;//String = "10银子";
		
		private var _priceType:int;
		
		private var priceObjArr:Array = [];
		
		private var totalCost:String;

		private var pos:int;
		
		private var ownerId:int;
		
		private var goodsId:int;
		
		private var bsItemVo:BaseItemVO;
		
		public function StallBuyWindow()
		{
//			this.bgSkin = Style.getInstance().buyPanelSkin;
			this.showCloseButton = false;
			
			this.width = 279;//298;
			this.height = 190;//216;
			
			var hui_bg:Sprite = Style.getBlackSprite(255,148,3,0.5);
			hui_bg.x = 12 ;
			hui_bg.y = 2;
			addChild(hui_bg);
			
			initBuy();
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		/**
		 * 设置单格物品的信息。 
		 * @param vo
		 * 
		 */		
		public function setGoodsVo(ownerID:int,position:int,vo:BaseItemVO):void
		{
			if(!vo)
				return;
			
			bsItemVo = vo;
			ownerId = ownerID;
			pos = position;             //为了更新对应位置的物品个数，需要位置
			
			goodsId = vo.oid;
//			bsItemVo = vo;
			
//			var goods:p_goods = vo.goods;
//			var bsItemVo:BaseItemVO = PackageModel.getInstance().getBaseItemVO(goods);
			
			setGoodsName(vo.name);
			setPricePone(vo.unit_price, vo.price_type);
			setTimeLimit(vo);
			setTotalNum(vo.num);
			setCost(vo.unit_price);
			goodsItem.setImageContent(vo, vo.path);
			
			//_price = vo.price;
			
		}
		
		private function onAdded(e:Event):void
		{
			if(numInputTxt)
			{
				numInputTxt.setFocus();
				numInputTxt.validateNow();
				numInputTxt.textField.setSelection(0,1);
				//				_moneyNumTI.textField.setSelection(0,1);
			}
		}
		
		private function initBuy():void
		{
			goodsItem = new GoodsImage();
			goodsItem.x = 20;
			goodsItem.y = 13;
			addChild(goodsItem);
			goodsItem.addEventListener(MouseEvent.ROLL_OVER, showImgTips);
			goodsItem.addEventListener(MouseEvent.ROLL_OUT, hideImgTips);
			
			var textformat:TextFormat = new TextFormat("Tahoma",12,0xfff799);
			goodsName = ComponentUtil.createTextField("商品：大力丸",75,8,textformat,200,24,this);
			
			price_txt = ComponentUtil.createTextField("单价：",75,32,textformat,55,20,this);
			priceTxt = ComponentUtil.createTextField("",110, 32,textformat,198,24,this);//单价：xx两xx文
			
			timeTxt = ComponentUtil.createTextField("",20,55,Style.textFormat,237,22,this);
			timeTxt.textColor = 0xff0000;
			//			timeTxt.filters=[new GlowFilter(0x0, 1, 2, 2, 20)];//
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0x00ff00);
			buyTxt = ComponentUtil.createTextField("输入购买数量：",18,77,tf,144,24,this); // new TextField();
			
			
			
			numInputTxt = new TextInput();
			numInputTxt.x = 122;
			numInputTxt.y = 77;
			numInputTxt.width = 50;
			numInputTxt.height = 22;
			numInputTxt.restrict = "0-9";
			numInputTxt.text = "1";
			numInputTxt.maxChars = 3;
			
			addChild(numInputTxt);
			numInputTxt.addEventListener(Event.CHANGE, onInputHandler);
			//			numInputTxt.addEventListener(Event.ENTER_FRAME
			
			totalNumTxt = ComponentUtil.createTextField("/37个",185,77,textformat,58,22,this); // new TextField();
			
			costTxt =  ComponentUtil.createTextField("",18,99,null,272,22,this); 
			costTxt.htmlText = "<font color='#00ff00'>需花费银子：</font>";
			
			//			numAndCost.htmlText = "/37个，共花费<font color='#ff1212'>XXXX</font>银";
			
			
			OK_btn = ComponentUtil.createButton("确定",66,123,66,24,this); // new Button();
			
			OK_btn.addEventListener(MouseEvent.CLICK, onOKhandler);
			
			CANCEl_btn = ComponentUtil.createButton("取消",144,123,66,24,this);
			CANCEl_btn.addEventListener(MouseEvent.CLICK, onCANCEl);
			
		}
		
		private function showImgTips(e:Event):void
		{
			if (bsItemVo)
				ToolTipManager.getInstance().show(bsItemVo, 0, 0, 0, "targetToolTip");
		}
		
		private function hideImgTips(e:Event):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		private function onInputHandler(evt:Event):void
		{
			if(numInputTxt.text =="" ||numInputTxt.text=="0")
			{
				num = 1;
				numInputTxt.text = "1" ;
				numInputTxt.validateNow();
				numInputTxt.textField.setSelection(0,1);
				
			}else{
				num = int(numInputTxt.text);
				if( num>totalNum)
				{
					num = totalNum;
					numInputTxt.text = num.toString();
				}
			}
			
			costTxtChange(num);
		}
		
		private function costTxtChange(buyNum:int):void
		{
//			numAndCost.htmlText = "/37个，共花费<font color='#ff1212'>" +
//				(buyNum * price) + "</font>银";
			setCost(buyNum * price);
		}
		
		/**
		 * 商品名 
		 * @param value
		 * 
		 */		
		private function setGoodsName(value:String):void
		{
			if(!value)
				return;
			goodsName.text = "商品：" + value;
		}
		
		/**
		 * 设置单价 
		 * @param one_price
		 * 
		 */		
		private function setPricePone(one_price:int, priceType:int):void
		{
			if(one_price < 0)
				return;
			
			price = one_price;
			_priceType = priceType;
			
			if (priceType == DealConstant.STALL_PRICE_TYPE_SILVER) {
				priceTxt.text = DealConstant.silverToOtherString(one_price);
			} else {
				priceTxt.text = one_price + "元宝";
			}
		}
		
		/**
		 * 设该商品有多少个。 
		 * @param totalNum
		 * 
		 */		
		private function setTotalNum(ttNum:int):void
		{
			totalNum = ttNum;
			totalNumTxt.text = "/"+ totalNum + "个";
		}
		
		/**
		 * 显示总共得花多少银子。 
		 * @param costSilver
		 * 
		 */		
		private function setCost(costPrice:int):void
		{
			var silver:int = GlobalObjectManager.getInstance().user.attr.silver ;
			var gold:int = GlobalObjectManager.getInstance().user.attr.gold;
			
			if (_priceType == DealConstant.STALL_PRICE_TYPE_SILVER) {
				if(costPrice > silver)
				{
					costTxt.htmlText = "<font color='#ff1212'>需花费银子：" + DealConstant.silverToOtherString(costPrice)+
						"（银子不足）</font>";
				}else{
					
					costTxt.htmlText = "<font color='#00ff00'>需花费银子：" + DealConstant.silverToOtherString(costPrice)+
						"</font>";
				}
			} else {
				if (costPrice > gold) {
					costTxt.htmlText = "<font color='#ff1212'>需花费元宝：" + costPrice +
						"元宝（元宝不足）</font>";
				} else {
					costTxt.htmlText = "<font color='#00ff00'>需花费元宝：" + costPrice + 
						"元宝</font>";
				}
			}
		}
		private function setTimeLimit(itemVO:BaseItemVO):void
		{
			var status:int = itemVO.getItemStatus();
			var str:String;
			if(status == BaseItemVO.UN_STARTUP){
				str = DateFormatUtil.formatPassDate(itemVO.timeoutData) + "  购买请注意";
				timeTxt.htmlText= wapper("启用时间：",str,"#f53f3c","#f53f3c","");
				return;
			}else if(status == BaseItemVO.PASS_DATE){
				timeTxt.htmlText= wapper("已过期无法使用   购买请注意","","#f53f3c");
				return;
			}else if(itemVO.timeoutData != 0){
				str = DateFormatUtil.formatPassDate(itemVO.timeoutData) + "  购买请注意";
				timeTxt.htmlText= wapper("过期时间：",str,"#f53f3c","#f53f3c","");
				return;
			}
			var equip:EquipVO = itemVO as EquipVO;
			if(equip)
			{
				var equipName:String = ItemConstant.getEquipKindName(equip.putWhere,equip.kind);
				if(equipName =="时装" ||equipName =="坐骑" )
				{
					timeTxt.htmlText = wapper("有效期：","永久","#f53f3c","#f53f3c","");
					
					//					return wapper("有效期：","永久","#ffffff","#3BE450","");
				}
			}
		}
		protected function wapper(name:String,data:Object,nameColor:String="#ffffff",textColor:String="#ffffff",space:String="    "):String{
			if(data == null)return "";
			if(name == "" && data == "")return "";
			if(name == ""){
				return HtmlUtil.fontBr(data.toString(),textColor)
			}
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr(space+data.toString(),textColor);
		}	
		
		
		private function onOKhandler(evt:MouseEvent):void
		{
			if(num > 0)
			{
				DealModule.getInstance().requestBuy(ownerId,goodsId,num,price);
			}else{
				Alert.show("请输入购买的个数","提示：");
			}
		}
		
		private function onCANCEl(evt:MouseEvent):void
		{
			DealModule.getInstance().closeBuyWindow();
		}
		
		
	}
}