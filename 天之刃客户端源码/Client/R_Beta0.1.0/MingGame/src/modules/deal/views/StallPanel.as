package modules.deal.views
{
	import com.common.GlobalObjectManager;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItemManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.broadcast.KeyWord;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.deal.DealModule;
	import modules.deal.views.stallViews.StallItem;
	import modules.deal.views.stallViews.StallList;
	import modules.deal.views.stallViews.StallSalaryTime;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_stall_buy_toc;
	import proto.line.m_stall_chat_toc;
	import proto.line.m_stall_extractmoney_toc;
	import proto.line.m_stall_open_toc;
	import proto.line.p_stall_goods;
	
	/**
	 * 摊位界面
	 * @author Administrator
	 * 
	 */	
	public class StallPanel extends BasePanel
	{
		
		public static const COUNT:int = 30;
		public static const COLUMN_COUNT:int = 6;
		public static const HPADDING:int = 3;
		public static const VPADDING:int = 3;
		
		private var tileSprite:Sprite;
		
		private var salaryTimeTxt:TextField;      //结束雇佣时间：18:00
		
		private var stallNameTxt:TextField;    //摊位名
		private var _stallName:String;      //摊位名
		private var sallDesc:TextField;        //"当前售出得到银子：\nXX锭XX两XX文　提取"
		private var stall_chat:StallList;         //聊天，　售出物品信息面板
		private var pullStakesBtn:Button;        //收摊
		private var salaryEarnerBtn:Button;      //雇佣店小二  //续期
		private var getBtn:Button;
		
		private var salaryTimeUI:StallSalaryTime;  //雇佣店小二的面板
		
		private var input:TextInput;
		private var sendBtn:Button;
		private var content:String;
		private var ownerId:int;
		
		private var profit:int ;
		
		private var timeStrArr:Array=new Array(2);
		
		public function StallPanel()
		{
			super();
			
			title = "摆  摊";
			this.width = 433;//468;
			this.height = 304;//362;
			
			initView();
		}
	
		private function initView():void
		{	
			var txtformat:TextFormat = new TextFormat("宋体",12,0xffeeee);
			salaryTimeTxt = ComponentUtil.createTextField("",12,240,txtformat,232,22); // new TextField();
			
			salaryTimeTxt.htmlText = "<font color='#ffeeee'>结束雇佣时间：<font color='#ffff00'>18:00</font></font>" ;//"<font color='#1e90ff'>结束雇佣时间：18:00</font>";
			addChild(salaryTimeTxt);
			
			var backBg:UIComponent = ComponentUtil.createUIComponent(10,5,234,228); //(6,5,243,228); 
			Style.setBorder1Skin(backBg);
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			var infoBg:UIComponent = ComponentUtil.createUIComponent(252,5,168,228); 
			Style.setBorder1Skin(infoBg);
			infoBg.mouseEnabled = false;
			addChild(infoBg);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 163;
			line.height = 3;
			line.x = 2;
			line.y = 53;
			infoBg.addChild(line);
			
			var inputbg:UIComponent = new UIComponent();
			inputbg.x = 16;
			inputbg.y = 11;
			inputbg.width = 220;
			inputbg.height = 23;
			inputbg.bgSkin = Style.getInstance().textInputSkin;
			addChild(inputbg);
			
			stallNameTxt = ComponentUtil.createTextField("骑着驴的帅哥的摊位",20,13,null,218,22,this); //// new TextField();
			
			
			tileSprite = new Sprite();
			tileSprite.x = 13;
			tileSprite.y = 40;
			addChild(tileSprite);
			
			createItems();
			
			sallDesc = new TextField();// ComponentUtil.createTextField("",256,12,null,145,40,this); //
			sallDesc.x = 256;
			sallDesc.y = 9;//12;
			sallDesc.width = 145;
			sallDesc.height = 50;
			addChild(sallDesc);
			
//			sallDesc.border = true;
//			sallDesc.borderColor = 0xd9d6c3;
			
			sallDesc.htmlText = "<font size='12' color='#ebe7ba'>当前售出得到收益：\n" +
				"<font color='#ffff22'>获得银子：XX锭XX两XX文\n" +
				"获得元宝：XXXX元宝\n</font>" +
				"</font>";
			
//			sallDesc.addEventListener(TextEvent.LINK, getMoneyHandler);
			getBtn = ComponentUtil.createButton("提取",368,39,35,16,this);
			getBtn.bgSkin=Style.getButtonSkin("yellow","yellowOver","yellowDown",null,GameConfig.T1_UI,new Rectangle(3,3,9,9));
//			getBtn.textColor = 0xff0000;
//			Style.setRedBtnStyle(getBtn);
			getBtn.enabled = false;
			getBtn.addEventListener(MouseEvent.CLICK, getMoneyHandler);
			
			stall_chat = new StallList();
			stall_chat.x = 256;
			stall_chat.y = 60;
			addChild(stall_chat);
			
			input = new TextInput();
			input.x = 253;
			input.y = 207;// 242;
			input.width = 115;
			input.maxChars = 30;
			
			input.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			addChild(input);
			
			sendBtn = ComponentUtil.createButton("发送",368,207,50,22,this);
			Style.setRedBtnStyle(sendBtn);
			sendBtn.addEventListener(MouseEvent.CLICK, onSendHandler);
			
			
			pullStakesBtn = ComponentUtil.createButton("收摊",260,236, 67,23,this);// new Button();
			
			pullStakesBtn.addEventListener(MouseEvent.CLICK, onPullStakes);
			
			salaryEarnerBtn = ComponentUtil.createButton("雇佣店小二",340,236, 75,23,this);//new Button();
			//雇佣店小二  //续期  salaryEarnerBtn.setSize(77,25);
			
			salaryEarnerBtn.addEventListener(MouseEvent.CLICK, onsalaryclick);
			
			salaryEarnerBtn.addEventListener(MouseEvent.ROLL_OVER, ontipShow);
			// tooltip: 有了店小二，不管是去练级还是下线休息，都不用收摊了。
			salaryEarnerBtn.addEventListener(MouseEvent.ROLL_OUT, ontiphide);
			
			
		}
		
		private function keyUpHandler(evt:KeyboardEvent):void
		{
			if(evt.keyCode == Keyboard.ENTER)
			{
				sendMsg();
			}
		}
		
		private function onSendHandler(evt:MouseEvent):void
		{
			sendMsg();
		}
		private function sendMsg():void
		{
			if(!input.text||input.text == "")
			{
				return;
			}
			
			content = KeyWord.instance().replace(input.text,KeyWord.TALK_WORDS);
			var message:String = StringUtil.trim(content);
			ownerId = GlobalObjectManager.getInstance().user.base.role_id;
			DealModule.getInstance().sendMsg(ownerId,message);
			
			input.text = "";
		}
		
		private function getMoneyHandler(evt:MouseEvent):void
		{
//			//  trace("evt.text:" + evt.text);
			// to do  通知服务端，　提取卖出物品所得的银子。
			if(profit>0)
				DealModule.getInstance().getStallMoney();
			else
			{
				Tips.getInstance().addTipsMsg("当前出售所得为0");
			}
			
			
		}
		public function getMoneyReturn(vo:m_stall_extractmoney_toc):void
		{
			setSaleMoney(0, 0);
			
		}
		
		
		private function setSaleMoney(allSilver:int, allGold:int):void
		{
			profit = allSilver + allGold;
			if(profit>0)
			{
				getBtn.enabled = true;
				getBtn.textColor = 0xf4a460;
				
			}else{
				getBtn.enabled = false;
				getBtn.textColor = 0xffffff;
			}
			var allMoneyStr:String = DealConstant.silverToOtherHtml(allSilver,"#ffff22","#ffff22");
			sallDesc.htmlText = "<font size='12' color='#ebe7ba'>当前售出得到收益：\n" +
				"<font color='#ffff22'>获得银子：" + allMoneyStr + "\n" +
				"获得元宝：" + allGold + "元宝\n</font>" +
				"</font>";
				
		}
		
		private function onPullStakes(evt:MouseEvent):void
		{
			//to do 通知服务端收摊了　 物品返回背包
			DealModule.getInstance().finishStall();
			
			
		}
		private function onsalaryclick(evt:MouseEvent):void
		{
			//onsalaryclick  雇佣 请求， param  雇佣多长时间。
			//
			var remain_time:int=0;
			if(salaryEarnerBtn.label != "雇佣店小二")
			{
				remain_time = Math.ceil(DealConstant.remain_time/3600);
				if(remain_time >= 24)
				{
					Tips.getInstance().addTipsMsg("雇佣剩余时间大于23小时，您不需要续期。");
					BroadcastSelf.logger("雇佣剩余时间大于23小时，您不需要续期。");
					return;
				}
			}
			if(!salaryTimeUI)
			{
				salaryTimeUI = new StallSalaryTime();
				salaryTimeUI.x = (this.width - salaryTimeUI.width) * 0.5;
				salaryTimeUI.y = (this.height - salaryTimeUI.height) * 0.5;
				addChild(salaryTimeUI);
				salaryTimeUI.addEventListener(CloseEvent.CLOSE, onsalaryClose);
				
			}
			
			if(salaryEarnerBtn.label == "雇佣店小二")
			{
				salaryTimeUI.initSalary(false); //非雇用中。
			}else{
				salaryTimeUI.initSalary(true); //雇用中。
			}
			
			//返回 之后 
			//salaryEarnerBtn.label = "续期";
		}
		
		private function onsalaryClose(e:CloseEvent):void
		{
			removeSalary();
		}
		
		public function removeSalary():void
		{
			if(salaryTimeUI)
			{
				salaryTimeUI.removeEventListener(CloseEvent.CLOSE, onsalaryClose);
				salaryTimeUI.dispose();
				salaryTimeUI = null;
			}
		}
		
		private var endTime:Number;
		private var endDate:Date;
		
		//雇佣成功返回后的摆摊面板处理  
		public function salaryReturn(remain_time:int ,hour:int=0):void
		{
			var timeOver:String = "";
			var date:Date = new Date();
			
			if(hour>0)
			{
				//to do"续期";
				if(endDate)//(timeStrArr[0] !="")
				{
					/*var tmpHour:int = (int(timeStrArr[0]) + hour)%24;
					timeStrArr[0] = String(tmpHour); 
					salaryTimeTxt.htmlText = "<font color='#ffeeee'>结束雇佣时间：" + 
						"<font color='#ffff00'>" + timeStrArr[0] + timeStrArr[1] + "</font></font>";
					*/
					
//					endTime = endTime + 3600 * hour;
					endDate = DateFormatUtil.addHours(endDate,hour);
					
					timeOver = DateFormatUtil.getDefaultDateString(endDate);
					salaryTimeTxt.htmlText = "<font color='#ffeeee'>结束雇佣时间：" + 
						"<font color='#ffff00'>" + timeOver + "</font></font>";
					
					return;
				}else{  //　从　亲自摆——>雇佣摆摊。
					
					remain_time = hour *3600;
					
				}
				
			}
			
			
			
			
//			endTime = int(date.getTime()/1000) + remain_time ;
			endDate = DateFormatUtil.addSeconds(date,remain_time);
			timeOver = DateFormatUtil.getDefaultDateString(endDate);//DateUtil.getHMBysecond(endTime);
			
//			timeStrArr = timeOver.split(":");
			
			if(remain_time <=0 )
			{
				DealConstant.remain_time = 0;
				if(contains(salaryTimeTxt))
				{
					removeChild(salaryTimeTxt);
				}
				salaryEarnerBtn.setSize(82,25);
				salaryEarnerBtn.label = "雇佣店小二"; 
				endDate = null;
			}else{
			
				DealConstant.remain_time = remain_time;
				if(!contains(salaryTimeTxt))
				{
					addChild(salaryTimeTxt);
				}
				//结束雇佣时间
				salaryTimeTxt.htmlText = "<font color='#ffeeee'>结束雇佣时间："+ "<font color='#ffff00'>"
					+timeOver + "</font></font>";
				//返回 之后 
				salaryEarnerBtn.setSize(77,25);
				salaryEarnerBtn.label = "续期";
			}
		}
		
		/**
		 * 显示已经过期 
		 * 
		 */		
		private function salaryOverdue():void
		{
			if(!contains(salaryTimeTxt))
			{
				addChild(salaryTimeTxt);
			}
			salaryTimeTxt.htmlText = "<font color='#ffeeee'>已过期...</font>";
			
			salaryEarnerBtn.visible = false;
			salaryEarnerBtn.enabled = false;
			salaryEarnerBtn.mouseEnabled = false;
			
		}
		
		
		private function ontipShow(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().show("有了店小二，不管是去练级还是下线休息，都不用收摊了。");
		}
		private function ontiphide(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		
		private function createItems():void
		{
			for(var i:int=0;i<COUNT;i++){
				var item:StallItem = new StallItem();//PackageItem = new PackageItem();
				//				item.packId = PACK_1;
				item.index = i;
				item.addEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				//				item.doubleClickEnabled = true;
				//				item.addEventListener(ItemEvent.ITEM_DOUBLE_CLICK,onItemDoubleClick);				
				var row:int = i / COLUMN_COUNT;
				var column:int = i % COLUMN_COUNT;
				item.x = column*item.width + column*HPADDING;
				item.y = row*item.height + row*VPADDING;
				tileSprite.addChild(item);
			}			
		}
		
		// 发送物品回背包，用在 刚从背包里拖出来的物品在定价时取消了 的时候！
		public function sendToPackage(pos:int):void
		{
			if(pos <= 0 || pos >tileSprite.numChildren)
				return;
			var item:StallItem = tileSprite.getChildAt( pos-1) as StallItem;
			var tempData:BaseItemVO = item.baseItemVo;
			
			if(tempData)
			{
				tempData.unit_price = -1;
//				PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,tempData);
				PackManager.getInstance().lockGoods(tempData , false);
//				item.removeEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				item.disposeContent();
			}
		}
		/**
		 * 删背包里的一个物品副本！ 
		 * @param pos
		 * 
		 */		
		public function deletePackGoods(pos:int):void 
		{
			if(pos <= 0 || pos >tileSprite.numChildren)
				return;
			var item:StallItem = tileSprite.getChildAt( pos-1) as StallItem;
			var tempData:BaseItemVO = item.baseItemVo;
			
			if(tempData)
			{
				PackManager.getInstance().updateGoods(tempData.bagid,tempData.position,null);
			}
		}
		
		/**
		 * 界面数据赋值！ 
		 * @param vo
		 * 
		 */		
		public function setDatas(vo:m_stall_open_toc):void
		{
			if(vo.state == 1)
			{
				// 系统摆摊
				DealConstant.OVERDUE = false;
				salaryReturn(vo.remain_time);
					
			}else if(vo.state == 2){
				DealConstant.OVERDUE = false;
				salaryReturn(-1)
			}
//			else if(vo.state == 3)
//			{
//				
//			}
			else if(vo.state == 4){
				// 过期处理 
				
				DealConstant.OVERDUE = true;
				salaryOverdue();
			}
			
			// 不管过不过期，物品都有摆出来看。
			delItems();
			
			for(var i:int = 0; i<vo.goods.length ; i++)
			{
				var stallGood:p_stall_goods = vo.goods[i] as p_stall_goods;
				
				var bsItemVo:BaseItemVO = PackageModule.getInstance().getBaseItemVO(stallGood.goods);
				bsItemVo.unit_price = stallGood.price;
				bsItemVo.price_type = stallGood.price_type;
				
				setTileContent(stallGood.pos,null,bsItemVo);
			}
//			to do
			stallName = vo.name;
			//stallNameTxt.text = vo.name;
			
			setSaleMoney(vo.get_silver, vo.get_gold);
			stall_chat.resetInit();
			
			if(vo.buy_logs.length>0)
				stall_chat.stall_log(vo.buy_logs,true);
			if(vo.chat_logs.length>0)
				stall_chat.stall_log(vo.chat_logs,false);
			
			
		}
		
		public function set stallName(str:String):void
		{
			if(str)
			{
				_stallName = str;
				stallNameTxt.text = str;
			}
		}
		public function get stallName():String
		{
			return _stallName;
		}
		
		private function delItems():void
		{
			var num:int = tileSprite.numChildren;
			for(var i:int = 0; i<num; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				
//				item.removeEventListener(MouseEvent.MOUSE_DOWN,itemDownHandler);
				if(item.baseItemVo &&item.baseItemVo.unit_price!=0)
				{
					item.disposeContent();
					setTileContent(i+1,null,null);
				}
				
				
			}
		}
		
		public function delItemById(goods_id:int):void
		{
			var item:BaseItemVO = getGoodsVoById(goods_id);
			deleteByItemVo(item);
		}
		
		private function deleteByItemVo(bsItemVo:BaseItemVO):void
		{
			if(!bsItemVo)
			{
				return;
			}
			for(var i:int = 0; i<tileSprite.numChildren; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				if(item.baseItemVo == bsItemVo)
				{
					setTileContent(i+1,null,null);
					return;
				}
			}
		}
		
		public function getGoodsVoById(goods_id:int):BaseItemVO
		{
			for(var i:int = 0; i<tileSprite.numChildren; i++)
			{
				var item:StallItem = tileSprite.getChildAt(i) as StallItem;
				if(item.baseItemVo)
				{
					var bsvo:BaseItemVO = item.baseItemVo;
					if(bsvo.oid == goods_id)
					{
						return bsvo;
					}
				}
			}
			return null;
		}
		
		public function receiveMsg(vo:m_stall_chat_toc):void
		{
			stall_chat.appendMsg(vo, false);
		}
		
		public function receiveBuyMsg(vo:m_stall_buy_toc):void
		{
			stall_chat.appendMsg( vo, true);
		}
		
		
		/**
		 * 添加售价。 
		 * @param pos
		 * @param price
		 * 
		 */		
		public function setItemPrice(pos:int, price:int, priceType:int):void
		{
			var stallItem:StallItem = tileSprite.getChildAt(pos-1) as StallItem;
			stallItem.baseItemVo.unit_price = price;
			stallItem.baseItemVo.price_type = priceType;
		}
		
		/**
		 * 改变格子里的物品内容 
		 * @param pos
		 * @param content
		 * @param vo
		 * 
		 */		
		public function setTileContent(pos:int,content:*,vo:BaseItemVO):void
		{
			var stallItem:StallItem = tileSprite.getChildAt(pos-1) as StallItem;
			//stallItem.setContent(content,vo);
			stallItem.updateContent(vo);
		}
		
		private function itemDownHandler(event:MouseEvent):void
		{
			var item:StallItem = event.currentTarget as StallItem;
			if(item.data && !DragItemManager.isDragging()){
				
				DragItemManager.instance.startDragItem(this,item.getContent(),DragConstant.STALL_ITEM,item.data);
			}
		}
		
		
		
		override public function dispose():void
		{
			sallDesc.removeEventListener(TextEvent.LINK, getMoneyHandler);
			pullStakesBtn.removeEventListener(MouseEvent.CLICK, onPullStakes);
			salaryEarnerBtn.removeEventListener(MouseEvent.CLICK, onsalaryclick);
			salaryEarnerBtn.removeEventListener(MouseEvent.ROLL_OVER, ontipShow);
			salaryEarnerBtn.removeEventListener(MouseEvent.ROLL_OUT, ontiphide);
			
			super.dispose();
		}
		
	}
}
