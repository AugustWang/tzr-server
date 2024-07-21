package modules.trading.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.trading.TradingModule;
	import modules.trading.tradingManager.TradingManager;
	import modules.trading.views.item.TradingItem;
	import modules.trading.views.item.TradingItemRender;
	import modules.trading.vo.TradingGoodVo;
	
	import proto.line.m_trading_shop_toc;
	
	public class TradingShopView extends BasePanel
	{
		private static const TIPS:String = "周日使用商贸宝典可获得双倍收益。"
		private static const JING_CHENG_TIP:String = "购买商品后可去" +
			"<a href='event:f_npcid=10102103'><u><font color='#00ff00'>平江</font></u></a>、" +
			"<a href='event:f_npcid=10105102'><u><font color='#00ff00'>边城</font></u></a>" +
			"的黑市商人处进行买卖。";
		
		private static const BLACK_SHOP_TIP:String = "购买商品后可去京城" +
			"<a href='event:f_npcid=10100104'><u><font color='#00ff00'>夏原吉</font></u></a>" +
			"处卖出商品、交还银票获得收益。";
		
		
		private static var huoCangURL:String = "assets/huoCangbg.jpg";//'com/assets/huoCangbg.jpg' ;
		
		
		private var  smallBtn:UIComponent; 
		private var shopDatagrid_L:DataGrid;
		private var shopDatagrid_R:DataGrid;
		
		private var itemSprite:Sprite;
		
		private var buyTimeTxt:TextField;
		private var saleTimeTxt:TextField;
		
		private var current_bill_Txt:TextField;
		private var max_bill:TextField;
		
		private var saleBtn:Button;  //出售
		private var sprite:Sprite;   // 放tooltip...
		
		private var tipsTf:TextField;
		
		private var update_time:int;
		private var max_sale_time:int;
		private var max_buy_time:int;
		private var timer:Timer;
		
		public function TradingShopView(key:String=null)
		{
			super(key);
			this.title = "商铺";
			
			this.width = 559;
			this.height = 416 + 45;
			
			var bigButtonSkin:ButtonSkin=Style.getButtonSkin("small_1skin",
				"small_2skin","small_3skin",null,GameConfig.T1_UI);
			
			//不显示最小化
//			smallBtn = createUIComponent(518,6,18,18,bigButtonSkin);
//			this.addChildToSuper(smallBtn);
//			smallBtn.addEventListener(MouseEvent.CLICK,onSmallClickHandler);
			
			//			533  279
			var uibg:UIComponent = ComponentUtil.createUIComponent(12,2,536,279);
			Style.setBorder1Skin(uibg);
			addChild(uibg);
			
			var mygood_uibg:UIComponent = ComponentUtil.createUIComponent(12,284,536,60);
			Style.setBorder1Skin(mygood_uibg);
			addChild(mygood_uibg);
			
			var tip_uibg:UIComponent = ComponentUtil.createUIComponent(12,349,536,25+46);
			Style.setBorder1Skin(tip_uibg);
			addChild(tip_uibg);
			
			shopDatagrid_L = createDataGrid();
			shopDatagrid_L.x = 14 ;
			addChild(shopDatagrid_L);
			
			shopDatagrid_R = createDataGrid();
			shopDatagrid_R.x = 279;
			addChild(shopDatagrid_R);
			
			
			// 392  264  最佳购买时间：YY秒后
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF53F3C);
//			buyTimeTxt = ComponentUtil.createTextField("最佳购买时间：YY秒后",390,262,tf,136,20,this);
			buyTimeTxt = ComponentUtil.createTextField("",390,262,tf,136,20,this);
			
			huoCangURL = GameConfig.ROOT_URL+'com/assets/huoCangbg.jpg' ;
			var myGoodImg_bg:Image = new Image();
			myGoodImg_bg.source = huoCangURL;
			myGoodImg_bg.x = 14;
			myGoodImg_bg.y = 284;
			addChild(myGoodImg_bg);
			
			itemSprite = new Sprite();
			itemSprite.x = 88;
			itemSprite.y = 286;
			addChild(itemSprite);
			//87   + 39
			createItems();
			
			saleBtn = ComponentUtil.createButton("出售",459,17,66,25,mygood_uibg);
			saleBtn.addEventListener(MouseEvent.CLICK,onSaleHandler);
			sprite = new Sprite();
			sprite.graphics.beginFill(0x00ff00,0);
			sprite.graphics.drawRect(0,0,66,25);
			sprite.graphics.endFill();
			sprite.x = 459;
			sprite.y = 17;
			mygood_uibg.addChild(sprite);
			
			sprite.addEventListener(MouseEvent.MOUSE_OVER,onTipshow);
			sprite.addEventListener(MouseEvent.MOUSE_OUT,onTipHide);
			
			
			
			// 404  329 最佳出售时间：YY秒后
//			saleTimeTxt = ComponentUtil.createTextField("最佳出售时间：YY秒后",390,326,tf,136,20,this);
			saleTimeTxt = ComponentUtil.createTextField("",390,326,tf,136,20,this);
			
			
			current_bill_Txt = ComponentUtil.createTextField("商票余额：xx文",8,2,tf,150,20,tip_uibg);
			current_bill_Txt.textColor = 0xAFE1EC;
			
			max_bill = ComponentUtil.createTextField("商票价值上限：0文",200,2,tf,188,20,tip_uibg);
			max_bill.textColor = 0xAFE1EC;
			
			var textformat:TextFormat = Style.textFormat;
			textformat.leading = 5;
			//			textformat.align = "center";
			tipsTf =ComponentUtil.createTextField(TIPS,8,24,textformat,518,48,tip_uibg);
			tipsTf.mouseEnabled = true;
			tipsTf.selectable = false;
			tipsTf.multiline=tipsTf.wordWrap = true;
			tipsTf.addEventListener(TextEvent.LINK,onLink);
		}
		
		private function onLink(e:TextEvent):void
		{
			TradingManager.getInstance().goToScenceByName(e);
		}
		
		private function onTipshow(e:MouseEvent):void
		{
			var str:String = "不能在购买的商店出售货物";
			if(saleBtn.enabled==false)
			{
			
				ToolTipManager.getInstance().show(str,100);
			}
		}
		private function onTipHide(e:MouseEvent):void
		{
				
				ToolTipManager.getInstance().hide();
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
		private function createDataGrid():DataGrid
		{
			var datagrid:DataGrid = new DataGrid();
			
			datagrid.itemRenderer = TradingItemRender;
			datagrid.list.selected = false;
			datagrid.y = 4;
			datagrid.width = 262;
			datagrid.height = 275;
			datagrid.addColumn("商品",58);
			datagrid.addColumn("数量",54);
			datagrid.addColumn("当前价格",80);
			datagrid.addColumn("操作",68);
			datagrid.itemHeight = 40;
			datagrid.pageCount = 6;
			datagrid.verticalScrollPolicy = ScrollPolicy.OFF;
			
			return datagrid;
		}
		
		//87   + 39
		private function createItems():void
		{
			for(var i:int =0;i<10;i++)
			{
				var item:TradingItem = new TradingItem();
				item.is_role_item = true;
				
				item.x = 2 + i* 38;
				item.y = 3;
				itemSprite.addChild(item);
			}
		}
		
		private var _update:int;
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
			saleTimeTxt.text = "";
			buyTimeTxt.text = "";
			
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
			
			if(TradingManager.current_trading_npcId == TradingManager.trading_goods_npcId)
			{
				saleBtn.enabled = false;
				sprite.mouseEnabled = true;
			}else{
				
				saleBtn.enabled = true;
				sprite.mouseEnabled = false;
			}
			
			if(TradingManager.current_trading_npcId==11100104||TradingManager.current_trading_npcId==12100104
				||TradingManager.current_trading_npcId==13100104)
			{
				tipsTf.htmlText = TIPS +JING_CHENG_TIP;
				//"<font color='#3be450'>"+JING_CHENG_TIP + "</font>";//"<font color='#00ff00'>" +  + "</font>";
				
			}else{
				
				tipsTf.htmlText = TIPS + BLACK_SHOP_TIP;//"<font color='#3be450'>"+BLACK_SHOP_TIP + "</font>";
			}
			
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
			buyTimeTxt.text = "";
			saleTimeTxt.text = "";
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
		
		
		public function setShopItemDatas(arr:Array):void
		{
			if(!arr||arr.length==0)
				return;
			var arr_L:Array = new Array();
			var arr_R:Array = new Array();
			
			for(var i:int=0;i<6;i++)
			{
				arr_L[i] = arr[i];
			}
			for(i=6;i<arr.length;i++)
			{
				arr_R[i-6] = arr[i];
			}
			
			shopDatagrid_L.dataProvider = arr_L;
			shopDatagrid_R.dataProvider = arr_R;
		}
		
		public function setItemDatas(arr:Array):void
		{
			if(!arr||arr.length==0)
			{
				return;
			}
			
			for(var i:int = 0;i<arr.length; i++)
			{
				var roleItem:TradingGoodVo = arr[i] as TradingGoodVo;
				var item:TradingItem = itemSprite.getChildAt(i) as TradingItem;
				item.data = roleItem;
				
			}
			if(TradingManager.current_trading_npcId == TradingManager.trading_goods_npcId)
			{
				saleBtn.enabled = false;
				sprite.mouseEnabled = true;
			}else{
				
				sprite.mouseEnabled = false;
				saleBtn.enabled = true;
			}
		}
		
		public function setBillData(bill:int =0, maxBill:int = 0):void
		{
			current_bill_Txt.text = "商票余额：" + bill +
				"文";
			if(maxBill>0)
			{
				max_bill.text = "商票价值上限：" + maxBill +
					"文";
			}
		}
		
		private function onSaleHandler(evt:MouseEvent):void
		{
			//			if(TradingManager.IS_LOCK)
			//			{
			//				Tips.getInstance().addTipsMsg("价格变动中，请稍候再操作。");
			//				return;
			//			}
			TradingModule.getInstance().sale_tos(TradingManager.current_trading_npcId);
		}
		
		public function clearRoleItem(len:int):void
		{
			for(var i:int = 0;i<len; i++)
			{
				var item:TradingItem = itemSprite.getChildAt(i) as TradingItem;
				item.updateContent(null);
			}
			
			if(TradingManager.current_trading_npcId == TradingManager.trading_goods_npcId)
			{
				saleBtn.enabled = false;
				sprite.mouseEnabled = true;
			}else{
				sprite.mouseEnabled = false;
				saleBtn.enabled = true;
			}
		}
		
		private function onSmallClickHandler(e:MouseEvent):void
		{
			TradingModule.getInstance().showSmallview(true);
		}
		
		override public function dispose():void
		{
			super.dispose();
			removetimer();
			clearRoleItem(10);
			var num:int = this.numChildren;
			for(var i:int=0;i<num;i++)
			{
				var obj:DisplayObject = this.getChildAt(0) as DisplayObject;
				this.removeChild(obj);
				obj = null;
			}
			
		}
		
		
	}
	
}
