package modules.trading.views
{
	import com.components.BasePanel;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.trading.TradingModule;
	import modules.trading.tradingManager.TradingManager;
	
	public class ExchangeTipPanel extends BasePanel
	{
		private var num_book:int = 1;
		private var contribution:int;
		private var npcId:int;
		
		private var duihuanTxt:TextField;
		private var inputtxt:TextInput;
		private var numBookTxt:TextField;
		private var costdescTxt:TextField;
		private var tipdescTxt:TextField;
		
		private var sureBtn:Button;
		private var cacelBtn:Button;
		
		public function ExchangeTipPanel()
		{
			super();
			
			this.width = 275;
			this.height = 195;
			initView();
			
		}
		private function onaddtostage(e:Event):void
		{
			if(inputtxt)
			{
				inputtxt.setFocus();
				inputtxt.validateNow();
				var len:int= inputtxt.text.length;
				inputtxt.textField.setSelection(0,len);
				
			}
		}
		
		private function initView():void
		{
			// w 255 h 122
			var bgUi:UIComponent = ComponentUtil.createUIComponent(10,5,255,122);
			Style.setBorder1Skin(bgUi);
			addChild(bgUi);
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xb3d5e6,null,null,null,null,null,"center"); 
			duihuanTxt = ComponentUtil.createTextField("兑换",38,12,tf,36,20,this);
			//38  12   36,20
			
			//70  12  68,22
			inputtxt = new TextInput();
			inputtxt.x = 70;
			inputtxt.y = 12;
			inputtxt.width =68;
			inputtxt.height = 22;
			inputtxt.restrict = "0-9";
			inputtxt.maxChars = 3;
			inputtxt.text = "1";
			inputtxt.addEventListener(Event.CHANGE,onInputChang);
			addChild(inputtxt);
			
			
			numBookTxt = ComponentUtil.createTextField("本【商贸宝典】",135,12,tf,95,20,this);
			//135  12  95  , 20
			
			costdescTxt = ComponentUtil.createTextField("需花费5点门派贡献",68,48,tf,122,20,this);
			//69  48   122 , 20
			
			var txtformat:TextFormat = new TextFormat("Tahoma",12,0xf53f3c,null,null,null,null,null,"center");  
			txtformat.leading = 8;
			tipdescTxt = ComponentUtil.createTextField("",15,79,txtformat,244,50,this); 
			tipdescTxt.wordWrap = true;
			tipdescTxt.multiline = true;
			tipdescTxt.text = "使用5点门派贡献可兑换一个【商贸宝典】，" +
				"交还商票时使用商贸宝典可获得双倍收益。"
			//  15 79         244   46
			
			sureBtn = ComponentUtil.createButton("确定",123,130,66,25,this);
			sureBtn.addEventListener(MouseEvent.CLICK,sureHandler);
			
			cacelBtn = ComponentUtil.createButton("取消",198,130,66,25,this);
			cacelBtn.addEventListener(MouseEvent.CLICK, cancelHandler);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onaddtostage);
			
		}
		
		private function onInputChang(e:Event):void
		{
			if(inputtxt.text==""||inputtxt.text == "0")
			{
				inputtxt.text = "1";
				num_book = 1;
				inputtxt.validateNow();
				inputtxt.textField.setSelection(0,1);
			}else{
				num_book = int(inputtxt.text);
				if(num_book>50)
				{
					num_book =50;
					inputtxt.text = "50";
				}
			}
			
			contribution = num_book *TradingManager.EX_POINT_P_BOOK;
			
			costdescTxt.text = "需花费" + contribution + 
				"点门派贡献";
		}
		public function setBtnEnabled():void
		{
			if(sureBtn)
			{
				sureBtn.enabled = true;
				cacelBtn.enabled = true;
			}
		}
		
		private function sureHandler(evt:MouseEvent):void
		{
			sureBtn.enabled = false;
			cacelBtn.enabled = false;
			contribution = num_book *TradingManager.EX_POINT_P_BOOK;
			TradingModule.getInstance().exchange_tos(contribution,npcId);
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
		
		public function set npcID(npc_id:int):void
		{
			npcId = npc_id;
		}
		
	}
}