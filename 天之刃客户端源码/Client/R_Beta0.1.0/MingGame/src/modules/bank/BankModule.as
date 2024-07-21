package modules.bank
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.LinkButton;
	import com.net.SocketCommand;
	import com.utils.MoneyTransformUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.bank.views.BankItRender;
	import modules.bank.views.BankItemRender;
	import modules.bank.views.BankPanel;
	import modules.bank.views.BankSaleItemRender;
	import modules.bank.views.BuyPanel;
	import modules.bank.views.SalePanel;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.line.m_bank_add_gold_toc;
	import proto.line.m_bank_add_silver_toc;
	import proto.line.m_bank_buy_toc;
	import proto.line.m_bank_buy_tos;
	import proto.line.m_bank_init_toc;
	import proto.line.m_bank_init_tos;
	import proto.line.m_bank_sell_toc;
	import proto.line.m_bank_sell_tos;
	import proto.line.m_bank_undo_toc;
	import proto.line.m_bank_undo_tos;
	import proto.line.p_bank_sheet;
	import proto.line.p_bank_simple_sheet;
	
	public class BankModule extends BaseModule
	{
		private var cancelArr:Array = [];  //撤销挂单 【"buy"   "sale"】
		private var cancelstr:String = "";    // buy   sale;
		private static const BUY:String = "buy";
		private static const SALE:String = "sale";
		
		
		public function BankModule()
		{
//			super(ModelConstant.BANK_MODEL);
		}
		
		private static var instance:BankModule;
		public static function getInstance():BankModule
		{
			if (instance == null)
			{
				instance=new BankModule();
			}
			return instance;
		}
		
		
		override protected function initListeners():void
		{
			addMessageListener(NPCActionType.NA_34, requestBankInit);
			
			addSocketListener(SocketCommand.BANK_INIT,onInitBank);
			addSocketListener(SocketCommand.BANK_BUY_REQUEST,onBuyHandler);
			addSocketListener(SocketCommand.BANK_SELL_REQUEST,onSaleHandler);
			addSocketListener(SocketCommand.BANK_BUY,onBuyHandler);             ////可能没有用了。。。。。
			addSocketListener(SocketCommand.BANK_SELL,onSaleHandler);
			addSocketListener(SocketCommand.BANK_ADD_GOLD,addGold);
			addSocketListener(SocketCommand.BANK_ADD_SILVER,addSilver);
			addSocketListener(SocketCommand.BANK_UNDO,onBankUndo);
		}
		
		private function requestBankInit(vo:NpcLinkVO):void
		{
			sendSocketMessage(new m_bank_init_tos);
		}
		
		
		private function  onInitBank(vo:m_bank_init_toc):void
		{
			if(vo.succ)
			{
				selfSaleArr =  vo.self_sell.sortOn("price",Array.NUMERIC|Array.DESCENDING); //左上  从高到低 　降
				selfBuyArr = vo.self_buy.sortOn("price",Array.NUMERIC);  //左下 低到高  升
				marketSaleArr = vo.bank_sell.sortOn("price",Array.NUMERIC);  //右上 低到高  升
				marketBuyArr = vo.bank_buy.sortOn("price",Array.NUMERIC|Array.DESCENDING); //右下  从高到低 　降
				
				if(!reFresh)
				{
					openBankPanel(vo);
				}else
				{
					reFresh = false;
					bankPanel.reFreshDataSource(vo.self_sell,vo.self_buy,vo.bank_sell,vo.bank_buy);
				}
				
			}else
			{
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		public function buyHandler(price:int,buyNum:int,sumYBNum:int = 0):void
		{
			//  trace("=========购买")
			var vo:m_bank_buy_tos = new m_bank_buy_tos();
			vo.price = price;
			vo.num = buyNum;
			
			if(price>0&&buyNum>0)
			{
				perPrice = price;
				buyOrSaleNum = buyNum;
				sumNum = sumYBNum;
				sendSocketMessage(vo);
//				toBuy(perPrice,buyOrSaleNum);
			}
		}
		
		private function onBuyHandler(vo:m_bank_buy_toc):void
		{
			if(vo.succ)
			{
				
				GlobalObjectManager.getInstance().user.attr.gold = vo.gold;
				GlobalObjectManager.getInstance().user.attr.silver = vo.silver;
				
				var currentBuyNum:int = vo.num;
				var price:int = vo.price;
				toUpdateMoneyBuy(currentBuyNum,price);
				
				var curItemID:int = currentItemID;
				if(vo.sheet && vo.sheet.sheet_id!=0)
				{
					//					updateMarketBuyList(vo.price,vo.sheet.num);
					curItemID = getSalseIdByPrice(vo.price);//
					if(curItemID>=0)
						marketSaleArr.splice(curItemID,1);
					
					///////////////挂单部分的
					buyhandler(vo.sheet);
					banksellHandler(vo.sheet);  //操作的是　marketBuyArr
				}
				else
				{
					curItemID = getSalseIdByPrice(vo.price);//
					//					var leftNum:int = currentSumNum - currentBuyNum;
					var vo1:p_bank_simple_sheet = marketSaleArr[curItemID] as p_bank_simple_sheet
					vo1.num = vo1.num - currentBuyNum; //leftNum;
					if(vo1.num==0)
						marketSaleArr.splice(curItemID,1);
					
				}
				var currentMarketSaleArr:Array = marketSaleArr;
				var object:Object = new Object();
				object.voType = BankConstant.MARKET_SALE;
				object.source = currentMarketSaleArr;
				bankPanel.updateDataSource(object);
			}else
			{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			closeBuyWindow();
		}
		private function toUpdateMoneyBuy(buyNum:int,perPrice:int):void
		{
			var cost:int = buyNum * perPrice;
			var fee:int = cost *0.02;
			
			changeMoney();
			if(cost>0)
				BroadcastSelf.getInstance().appendMsg("成功购买元宝" + buyNum +"个,花费" + MoneyTransformUtil.silverToOtherString(cost)+
					"银子，扣除手续费:" + MoneyTransformUtil.silverToOtherString(fee) + "银子");
		}
		private function buyhandler(shee:p_bank_sheet):void
		{
			//左下， 挂 买 单 的 ；  低到高；
			updateMoney(shee);
			var selfBuyArr:Array = selfBuyArr;
			var perPrice:int = shee.price;
			if(selfBuyArr.length == 0)
			{
				selfBuyArr.push(shee);
				var object1:Object = new Object();
				object1.voType = BankConstant.SELF_BUY;
				object1.source = selfBuyArr;
				bankPanel.updateDataSource(object1);
				return ;
			}
			
			if(selfBuyArr.length!=0 && perPrice<(selfBuyArr[0] as p_bank_sheet).price) //>
			{
				selfBuyArr.unshift(shee);
				var object2:Object = new Object();
				object2.voType = BankConstant.SELF_BUY;
				object2.source = selfBuyArr;
				bankPanel.updateDataSource(object2);
				return;
			}
			
			for(var i:int=0;i<selfBuyArr.length;i++)
			{
				var currentPrice:int = (selfBuyArr[i] as p_bank_sheet).price;
				if(selfBuyArr[i+1])
				{
					var nextPrice:int = (selfBuyArr[i+1] as p_bank_sheet).price;
					if(currentPrice <= perPrice && perPrice < nextPrice)            //>=
					{
						selfBuyArr.splice(i+1,0,shee);
						var object3:Object = new Object();
						object3.voType = BankConstant.SELF_BUY;
						object3.source = selfBuyArr;
						bankPanel.updateDataSource(object3);
						return;
					}
				}else
				{
					selfBuyArr.push(shee);
					var object4:Object = new Object();
					object4.voType = BankConstant.SELF_BUY;
					object4.source = selfBuyArr;
					bankPanel.updateDataSource(object4);
					return;
				}
			}
		}
		private function updateMoney(sheet:p_bank_sheet):void //挂上单 的 。
		{
			var sumItem:int = sheet.num * sheet.price;
			var fee:int = int(sumItem * 0.02)
			var cost:int = sumItem + fee;
			
			BroadcastSelf.getInstance().appendMsg("成功提交求购挂单，扣除"+MoneyTransformUtil.silverToOtherString(sumItem)+"银子,扣除手续费:" + MoneyTransformUtil.silverToOtherString(fee) + "银子");
		}
		
		
		private function banksellHandler(shee:p_bank_sheet):void
		{
			// 右下， 元宝卖出（所有人的求购）  从高到低价格。
			var simpleShee:p_bank_simple_sheet = new p_bank_simple_sheet();
			simpleShee.num = shee.num;
			simpleShee.price = shee.price;
			var perPrice:int = shee.price;
			var bankBuyArr:Array = marketBuyArr;
			
			
			if(bankBuyArr.length == 0 || perPrice<(bankBuyArr[bankBuyArr.length-1] as p_bank_simple_sheet).price)
			{
				marketBuyArr.push(simpleShee);
				if(marketBuyArr.length ==8)
				{
					marketBuyArr.pop();
				}
				var object1:Object = new Object();
				object1.voType = BankConstant.MARKET_BUY;
				object1.source = marketBuyArr;
				bankPanel.updateDataSource(object1);
				return ;
			}
			
			for(var i:int=0;i<bankBuyArr.length;i++)
			{
				var currentPrice:int = (bankBuyArr[i] as p_bank_simple_sheet).price;
				if(bankBuyArr[i+1])
				{
					//
					if(perPrice == currentPrice)
					{
						var tempSheet:p_bank_simple_sheet = marketBuyArr[i]
						tempSheet.num = shee.num + tempSheet.num;
						var object5:Object = new Object();
						object5.voType = BankConstant.MARKET_BUY;
						object5.source = marketBuyArr;
						bankPanel.updateDataSource(object5);
						return;	
					}
				}
			}
			
			marketBuyArr.push(simpleShee);
			marketBuyArr.sortOn("price",Array.NUMERIC|Array.DESCENDING);
			if(marketBuyArr.length ==8)
			{
				marketBuyArr.pop();
			}
			var object2:Object = new Object();
			object2.voType = BankConstant.MARKET_BUY;
			object2.source = marketBuyArr;
			bankPanel.updateDataSource(object2);
			
		}
		
		public function saleHandler(price:int,saleNum:int,sumYBNum:int=0):void
		{
			if(price<=0 || saleNum<=0)
			{
				return;
			}
			//  trace("=========出售")
			var vo:m_bank_sell_tos = new m_bank_sell_tos();
			
			perPrice = price;
			buyOrSaleNum = saleNum;
			sumNum = sumYBNum;
			vo.price = perPrice;
			vo.num = buyOrSaleNum;
			this.sendSocketMessage(vo);
		}
		
		////////////////////卖单返回
		private function onSaleHandler(vo:m_bank_sell_toc):void
		{
			if(vo.succ)
			{
				GlobalObjectManager.getInstance().user.attr.gold = vo.gold;
				GlobalObjectManager.getInstance().user.attr.silver = vo.silver;
				
				toUpdateMoneySale(vo.num,vo.price);
				
				
				var currentSaleNum:int = BankModule.getInstance().buyOrSaleNum;
				//				var currentSumNum:int = BankModel.getInstance().sumNum;
				
				var currentItemID:int = BankModule.getInstance().currentItemID;
				if(vo.sheet && vo.sheet.sheet_id!=0)
				{
					//					updateMarketSaleList(vo.price,vo.sheet.num);
					currentItemID = BankModule.getInstance().getBuyIdByPrice(vo.price);
					if(currentItemID>=0)
						BankModule.getInstance().marketBuyArr.splice(currentItemID,1);
					
					///////////////挂单部分的
					
					sellhandler(vo.sheet);
					bankBuyHandler(vo.sheet);
					
				}
				else
				{
					currentItemID = BankModule.getInstance().getBuyIdByPrice(vo.price);//
					//					var leftNum:int = currentSumNum - currentSaleNum;
					var vo1:p_bank_simple_sheet = BankModule.getInstance().marketBuyArr[currentItemID] as p_bank_simple_sheet
					vo1.num = vo1.num - currentSaleNum;//leftNum;
					if(vo1.num==0)
						BankModule.getInstance().marketBuyArr.splice(currentItemID,1);
				}
				
				
				var currentMarketBuyArr:Array = BankModule.getInstance().marketBuyArr;
				var object:Object = new Object();
				object.voType = BankConstant.MARKET_BUY;
				object.source = currentMarketBuyArr
				BankModule.getInstance().bankPanel.updateDataSource(object);
				
			}else
			{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
			BankModule.getInstance().onCloseSale();
		}
		
		private function toUpdateMoneySale(saleNum:int,perPrice:int):void
		{
			var fee:int = saleNum*perPrice *0.02;
			var get:int = saleNum*perPrice - fee;
			changeMoney();
			if(get>0)
				BroadcastSelf.getInstance().appendMsg("成功出售元宝" + saleNum +"个,扣除手续费:" + MoneyTransformUtil.silverToOtherString(fee) + "银子后你获得 "+MoneyTransformUtil.silverToOtherString(get)+"银子");
		}
		private function sellhandler(shee:p_bank_sheet):void
		{
			BroadcastSelf.getInstance().appendMsg("出售元宝挂单成功提交。");
			
			// 左上， 出售  从高到低价格。
			//			toUpdateMoney();         
			
			var perPrice:int = shee.price;
			var selfSaleArr:Array = BankModule.getInstance().selfSaleArr;
			
			if(selfSaleArr.length == 0 || perPrice<(selfSaleArr[selfSaleArr.length-1] as p_bank_sheet).price)
			{
				BankModule.getInstance().selfSaleArr.push(shee);
				var object1:Object = new Object();
				object1.voType = BankConstant.SELF_SALE;
				object1.source = BankModule.getInstance().selfSaleArr;
				BankModule.getInstance().bankPanel.updateDataSource(object1);
				return ;
			}
			
			if(selfSaleArr.length!=0 && perPrice>(selfSaleArr[0] as p_bank_sheet).price)//<
			{
				BankModule.getInstance().selfSaleArr.unshift(shee);
				var object2:Object = new Object();
				object2.voType = BankConstant.SELF_SALE;
				object2.source = BankModule.getInstance().selfSaleArr;
				BankModule.getInstance().bankPanel.updateDataSource(object2);
				return;
			}
			
			for(var i:int=0;i<selfSaleArr.length;i++)
			{
				var currentPrice:int = (selfSaleArr[i] as p_bank_sheet).price;
				if(selfSaleArr[i+1])
				{
					var nextPrice:int = (selfSaleArr[i+1] as p_bank_sheet).price;
					if(currentPrice >= perPrice && perPrice >= nextPrice)// <=
					{
						BankModule.getInstance().selfSaleArr.splice(i+1,0,shee);//i+1
						var object3:Object = new Object();
						object3.voType = BankConstant.SELF_SALE;
						object3.source = BankModule.getInstance().selfSaleArr;
						BankModule.getInstance().bankPanel.updateDataSource(object3);
						return;
					}
				}else
				{
					BankModule.getInstance().selfSaleArr.push(shee);
					var object4:Object = new Object();
					object4.voType = BankConstant.SELF_SALE;
					object4.source = BankModule.getInstance().selfSaleArr;
					BankModule.getInstance().bankPanel.updateDataSource(object4);
					return;
				}
			}
		}
		
		private function bankBuyHandler(shee:p_bank_sheet):void
		{
			//右上， 买入元宝（所有人的卖出） ；  低到高；
			var simpleShee:p_bank_simple_sheet = new p_bank_simple_sheet();
			simpleShee.num = shee.num;
			simpleShee.price = shee.price;
			
			//			updateMoney(simpleShee);
			var bankSellArr:Array = BankModule.getInstance().marketSaleArr;
			var perPrice:int = shee.price;
			if(bankSellArr.length == 0)
			{
				BankModule.getInstance().marketSaleArr.push(simpleShee);
				var object1:Object = new Object();
				object1.voType = BankConstant.MARKET_SALE;
				object1.source = BankModule.getInstance().marketSaleArr;
				BankModule.getInstance().bankPanel.updateDataSource(object1);
				return ;
			}
			for(var i:int=0;i<bankSellArr.length;i++)
			{
				var currentPrice:int = (bankSellArr[i] as p_bank_simple_sheet).price;
				if(currentPrice == perPrice)
				{
					var tempSheet:p_bank_simple_sheet = marketSaleArr[i];
					tempSheet.num = shee.num + tempSheet.num;
					var object5:Object = new Object();
					object5.voType = BankConstant.MARKET_SALE;
					object5.source = BankModule.getInstance().marketSaleArr;
					BankModule.getInstance().bankPanel.updateDataSource(object5);
					return;	
				}
			}
			marketSaleArr.push(simpleShee);
			marketSaleArr.sortOn("price",Array.NUMERIC);
			var object3:Object = new Object();
			object3.voType = BankConstant.MARKET_SALE;
			object3.source = marketSaleArr;
			bankPanel.updateDataSource(object3);
			return;
			
		}
		
		private function onBankUndo(vo:m_bank_undo_toc):void
		{
			var canceltype:String = cancelArr.shift();
			if(!canceltype || canceltype=="")
				return;
			if(canceltype == SALE)
			{
				onSaleCancel(vo);
			}else if(canceltype == BUY){
				onBuyCancel(vo);
			}
			
		}
		
		////    buy cancel    ///
		private  function onBuyCancel(vo:m_bank_undo_toc):void
		{
			if(vo.succ)
			{
				updateMarketBuyList_undo();
				
				GlobalObjectManager.getInstance().user.attr.silver=GlobalObjectManager.getInstance().user.attr.silver + vo.return_back;
				changeMoney();   //更新钱
				BroadcastSelf.getInstance().appendMsg("求购挂单撤销成功。");
				var currentItemID:int = BankModule.getInstance().currentItemID;
				BankModule.getInstance().selfBuyArr.splice(currentItemID,1);
				var currentSelfBuyArr:Array = BankModule.getInstance().selfBuyArr;
				var object:Object = new Object();
				object.voType = BankConstant.SELF_BUY;
				object.source = currentSelfBuyArr
				BankModule.getInstance().bankPanel.updateDataSource(object);
			}else
			{
				BroadcastSelf.getInstance().appendMsg("求购挂单撤销失败。");
				BankModule.getInstance().selfBuyArr = vo.self_buy;
				var object1:Object = new Object();
				object1.voType = BankConstant.SELF_BUY;
				object1.source = vo.self_buy
				BankModule.getInstance().bankPanel.updateDataSource(object1);
				
				BankModule.getInstance().marketBuyArr = vo.bank_buy;
				var object2:Object = new Object();
				object2.voType = BankConstant.BANK_BUY;
				object2.source = vo.bank_buy;
				BankModule.getInstance().bankPanel.updateDataSource(object2);
			}
		}
		
		private function updateMarketBuyList_undo():void
		{
//			var currentItemID:int = BankModel.getInstance().currentItemID;
			var sheet:p_bank_sheet = BankModule.getInstance().selfBuyArr[currentItemID] as p_bank_sheet;
			if(!sheet)
				return;
			var perPrice:int = sheet.price;
			var num:int = sheet.num;
			var marketBuyArr:Array = BankModule.getInstance().marketBuyArr;
			if(marketBuyArr.length == 0)
			{
				return;
			}
			
			if(marketBuyArr.length != 0 && perPrice > (marketBuyArr[0] as p_bank_simple_sheet).price)
			{
				return;	
			}
			
			for(var i:int=0;i<marketBuyArr.length;i++)
			{
				var currentPrice:int = (marketBuyArr[i] as p_bank_simple_sheet).price
				if(perPrice == currentPrice)
				{
					var simpleSheet:p_bank_simple_sheet = BankModule.getInstance().marketBuyArr[i] as p_bank_simple_sheet
					if(simpleSheet.num > num)
					{
						simpleSheet.num = simpleSheet.num - num;
					}else
					{
						BankModule.getInstance().marketBuyArr.splice(i,1);
					}
					var object:Object = new Object();
					object.voType = BankConstant.MARKET_BUY;
					object.source = BankModule.getInstance().marketBuyArr
					BankModule.getInstance().bankPanel.updateDataSource(object);
					return;
				}
			}
		}
		
		private  function onSaleCancel(vo:m_bank_undo_toc):void
		{
			if(vo.succ)
			{
				updateMarketSellArr();
				updateMoney_undoBuy(vo);
				BroadcastSelf.getInstance().appendMsg("求售挂单撤销成功。");
				var currentItemID:int = BankModule.getInstance().currentItemID;
				BankModule.getInstance().selfSaleArr.splice(currentItemID,1);
				var currentSelfSaleArr:Array = BankModule.getInstance().selfSaleArr;
				var object:Object = new Object();
				object.voType = BankConstant.SELF_SALE;
				object.source = currentSelfSaleArr
				BankModule.getInstance().bankPanel.updateDataSource(object);
			}else
			{
				BroadcastSelf.getInstance().appendMsg("求售挂单撤销失败。")
				BankModule.getInstance().selfSaleArr = vo.self_sell;
				var object1:Object = new Object();
				object1.voType = BankConstant.SELF_SALE;
				object1.source = vo.self_sell
				BankModule.getInstance().bankPanel.updateDataSource(object1);
				
				BankModule.getInstance().marketSaleArr = vo.bank_sell;
				var object2:Object = new Object();
				object2.voType = BankConstant.BANK_SELL;
				object2.source = vo.bank_sell;
				BankModule.getInstance().bankPanel.updateDataSource(object2);
			}
		}
		private function updateMoney_undoBuy(vo:m_bank_undo_toc):void
		{
			var num:int = vo.return_back;
			GlobalObjectManager.getInstance().user.attr.gold = GlobalObjectManager.getInstance().user.attr.gold + num;
			changeMoney();
		}
		
		private function updateMarketSellArr():void
		{
			var currentItemID:int = BankModule.getInstance().currentItemID;
			//  trace("++++++++++++++++++++++");
			//  trace(BankModel.getInstance().selfSaleArr.length,currentItemID);
			var sheet:p_bank_sheet = BankModule.getInstance().selfSaleArr[currentItemID] as p_bank_sheet;
			if(!sheet)
				return;
			var perPrice:int = sheet.price;
			var num:int = sheet.num;
			var marketSaleArr:Array = BankModule.getInstance().marketSaleArr;
			
			if(marketSaleArr.length == 0)
			{
				return;
			}
			
			if(marketSaleArr.length != 0 && perPrice > (marketSaleArr[0] as p_bank_simple_sheet).price)
			{
				return;	
			}
			
			for(var i:int=0;i<marketSaleArr.length;i++)
			{
				var currentPrice:int = (marketSaleArr[i] as p_bank_simple_sheet).price
				if(perPrice == currentPrice)
				{
					var simpleSheet:p_bank_simple_sheet = BankModule.getInstance().marketSaleArr[i] as p_bank_simple_sheet
					if(simpleSheet.num > num)
					{
						simpleSheet.num = simpleSheet.num - num;
					}else
					{
						BankModule.getInstance().marketSaleArr.splice(i,1);
					}
					var object:Object = new Object();
					object.voType = BankConstant.MARKET_SALE;
					object.source = BankModule.getInstance().marketSaleArr;
					BankModule.getInstance().bankPanel.updateDataSource(object);
					return;
				}
			}
		}
		
		private function upDateSelfArr(type:int,sheetId:int,num:int,if_self:Boolean):void
		{
			var i:int;
			var price:int;
			var reduce:int;
			var sheet:p_bank_sheet;
			var obj:Object = new Object();
			if(type == BankConstant.SELF_BUY && selfBuyArr)
			{
				for(i=0;i<selfBuyArr.length;i++)
				{
					sheet = selfBuyArr[i] as p_bank_sheet;
					if(sheetId == sheet.sheet_id)
					{
						price = sheet.price;
						if(num==0)
						{
							reduce = sheet.num;
							selfBuyArr.splice(i,1);
						}else{
							reduce = sheet.num - num;
							sheet.num =  num;
						}
						
						break;
					}
				}
				
				obj.voType = BankConstant.SELF_BUY;
				obj.source = selfBuyArr;
				if(price>0&&reduce>0&&(!if_self))
					upDateMarketArr(BankConstant.MARKET_BUY,price,reduce);
				
			}else if(type == BankConstant.SELF_SALE && selfSaleArr)
			{
				for(i=0;i<selfSaleArr.length;i++)
				{
					sheet = selfSaleArr[i] as p_bank_sheet;
					if(sheetId == sheet.sheet_id)
					{
						price = sheet.price;
						if(num==0)
						{
							reduce = sheet.num;
							selfSaleArr.splice(i,1);
						}else{
							reduce = sheet.num - num;
							sheet.num =  num;
						}
						
						break;
					}
				}
				
				obj.voType = BankConstant.SELF_SALE;
				obj.source = selfSaleArr;
				if(price>0&&reduce>0&&(!if_self))
					upDateMarketArr(BankConstant.MARKET_SALE,price,reduce);
			}
			
			if(bankPanel)
			{
				
				bankPanel.updateDataSource(obj);
			}
			
		}
		private function upDateMarketArr(type:int,price:int,num:int):void
		{
			var i:int ;
			var sheet:p_bank_simple_sheet;
			var obj:Object = new Object();
			if(type == BankConstant.MARKET_BUY && marketBuyArr)
			{
				for(i=0;i<marketBuyArr.length;i++)
				{
					sheet = marketBuyArr[i] as p_bank_simple_sheet;
					if(price == sheet.price)
					{
						if(sheet.num == num)
						{
							marketBuyArr.splice(i,1);
						}else{
							
							sheet.num = sheet.num-num;
						}
						
						break;
					}
				}
				obj.voType = BankConstant.MARKET_BUY;
				obj.source = marketBuyArr;
				
				
			}else if(type == BankConstant.MARKET_SALE && marketSaleArr)
			{
				for(i=0;i<marketSaleArr.length;i++)
				{
					sheet = marketSaleArr[i] as p_bank_simple_sheet;
					if(price == sheet.price)
					{
						if(sheet.num == num)
						{
							marketSaleArr.splice(i,1);
						}else{
							
							sheet.num = sheet.num-num;
						}
						
						break;
					}
				}
				obj.voType = BankConstant.MARKET_SALE;
				obj.source = marketSaleArr;
			}
			
			if(bankPanel)
			{
				bankPanel.updateDataSource(obj);
			}
		}
		
		private function addGold(vo:m_bank_add_gold_toc):void
		{
			if(vo.type)
			{
				BroadcastSelf.getInstance().appendMsg("钱庄求购元宝挂单成功，增加" + vo.gold + "元宝");
				upDateSelfArr(BankConstant.SELF_BUY,vo.sheet_id,vo.num,vo.if_self);
				
			}else
			{
				BroadcastSelf.getInstance().appendMsg("钱庄求售挂单到期，系统退回" + vo.gold + "元宝");
			}
			
			GlobalObjectManager.getInstance().user.attr.gold=GlobalObjectManager.getInstance().user.attr.gold + vo.gold;
			changeMoney();
			
		}
		
		public function changeMoney():void
		{
			dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
		}
		
		private function addSilver(vo:m_bank_add_silver_toc):void
		{
			
			if(vo.type)
			{
				var currentSilver:int = GlobalObjectManager.getInstance().user.attr.silver;
				BroadcastSelf.getInstance().appendMsg("钱庄出售元宝挂单成功，增加" + MoneyTransformUtil.silverToOtherString(vo.silver) + "银子(已扣除手续费)");
				upDateSelfArr(BankConstant.SELF_SALE,vo.sheet_id,vo.num,vo.if_self);
				
			}else
			{
				BroadcastSelf.getInstance().appendMsg("钱庄求购挂单到期，系统退回" + MoneyTransformUtil.silverToOtherString(vo.silver) + "银子");
			}
			
			GlobalObjectManager.getInstance().user.attr.silver=GlobalObjectManager.getInstance().user.attr.silver + vo.silver;
			changeMoney();
		}
		
		private var _reFresh:Boolean;
		public function set reFresh(value:Boolean):void
		{
			_reFresh = value;
		}
		
		public function get reFresh():Boolean
		{
			return _reFresh;
		}
		
		
		public function openBankPanel(vo:m_bank_init_toc):void
		{
			if(!bankPanel)
			{
				bankPanel = new BankPanel();
				bankPanel.saleCancelFn = saleCancelFn;
				bankPanel.buyCancelFn = buyCancelFn;
				bankPanel.buyFn = popUpBuyPanel;
				bankPanel.saleFn = popUpSalePanel;
				bankPanel.itemClickFn = itemClickHandler;
				bankPanel.reFreshDataFn = reFreshDataFn;
				bankPanel.setDataSource(selfSaleArr,selfBuyArr,marketSaleArr,marketBuyArr);
				bankPanel.setupUI();
			}
			
			
			WindowManager.getInstance().popUpWindow(bankPanel);
			WindowManager.getInstance().centerWindow(bankPanel);
			bankPanel.reFreshDataSource(vo.self_sell, vo.self_buy, vo.bank_sell, vo.bank_buy);
		}
		
		public  function saleCancelFn(evt:MouseEvent):void
		{
			Alert.show("您确定要撤回该挂单吗？","提示",yesHandler,noHandler);
			function yesHandler():void
			{
//				var bankSaleCancelBody:BankSaleCancelBody = new BankSaleCancelBody();
				var bankItem:*;
				if((evt.target as LinkButton).parent is BankItemRender)
				{
					bankItem = (evt.target as LinkButton).parent as BankItemRender;	
				}else
				{
					bankItem = (evt.target as LinkButton).parent as BankSaleItemRender;	
				}
				currentItemID = bankItem.itemID;
				var sheetID:int = bankItem.sheetID;
//				bankSaleCancelBody.toCancel(sheetID);
					
				cancelArr.push(SALE);
				var vo:m_bank_undo_tos = new m_bank_undo_tos();
				vo.sheet_id = sheetID;
				sendSocketMessage(vo);
				
			}
			
			function noHandler():void
			{
				BroadcastSelf.getInstance().appendMsg("取消撤销操作");
			}
		}
		
		public  function buyCancelFn(evt:MouseEvent):void
		{
			Alert.show("您确定要撤回该挂单吗？","提示",yesHandler,noHandler);
			function yesHandler():void
			{
//				var bankBuyCancelBody:BankBuyCancelBody = new BankBuyCancelBody();
				var bankItem:*;
				if((evt.target as LinkButton).parent is BankItemRender)
				{
					bankItem = (evt.target as LinkButton).parent as BankItemRender;	
				}else
				{
					bankItem = (evt.target as LinkButton).parent as BankSaleItemRender;	
				}
				currentItemID = bankItem.itemID;
				cancelNum = bankItem.YBNum;
				perPrice = bankItem.unitPrice;
				var sheetID:int = bankItem.sheetID;
//				bankBuyCancelBody.toCancel(sheetID);
				
				cancelArr.push(BUY);
				var vo:m_bank_undo_tos = new m_bank_undo_tos();
				vo.sheet_id = sheetID;
				sendSocketMessage(vo);
				
			}
			
			function noHandler():void
			{
				BroadcastSelf.getInstance().appendMsg("取消撤销操作");
			}
		}
		

		public function popUpBuyPanel(evt:MouseEvent=null):void
		{
			
			//  trace("========弹出购买窗口")
			var unitPrice:int=0;
			var YBNum:int=0; 
			
			if(evt)
			{
				var bankItem:*;
				if((evt.target as LinkButton).parent is BankItRender)
				{
					bankItem = (evt.target as LinkButton).parent as BankItRender;	
				}
				if(!bankItem)
					return;
				
				currentItemID = bankItem.itemID;
				unitPrice = bankItem.unitPrice;
				YBNum = bankItem.YBNum;
				
			}else{
				if(selfBuyArr.length>=5)
				{
					Tips.getInstance().addTipsMsg("您最多只能挂5个买单。");
					return;
				}
				
			}
			
			if(!buyPanel)
			{
				buyPanel = new BuyPanel();
				buyPanel.addEventListener(CloseEvent.CLOSE,closeBuyWindow);
			}
			buyPanel.setUnitPrice(unitPrice);
			buyPanel.setYBSumNum(YBNum);
			
			buyPanel.x = int((1002 - buyPanel.width)/2);
			buyPanel.y = int((GlobalObjectManager.GAME_HEIGHT - buyPanel.height)/2);
			
			WindowManager.getInstance().openDialog(buyPanel,true);
			
			
		}
		
		public function closeBuyWindow(evt:CloseEvent=null):void
		{
			if(buyPanel&&buyPanel.parent)
			{
				buyPanel.clear();
				WindowManager.getInstance().closeDialog(buyPanel);
			}
		}
		
		public function popUpSalePanel(evt:MouseEvent = null):void
		{
			//  trace("========弹出出售窗口")
			
			var unitPrice:int = 0;
			var YBNum:int = 0;
			if(evt)
			{
				var bankItem:*;
				if((evt.target as LinkButton).parent is BankItRender)
				{
					bankItem = (evt.target as LinkButton).parent as BankItRender;	
				}
				if(!bankItem)
				{
					return;
				}
				currentItemID = bankItem.itemID;
				unitPrice = bankItem.unitPrice;
				YBNum = bankItem.YBNum;
			}else{
				
				if(selfSaleArr.length>=5)
				{
					Tips.getInstance().addTipsMsg("您最多只能挂5个卖单。");
					return;
				}
			}	
			
			if(!salePanel)
			{
				salePanel = new SalePanel();
				salePanel.addEventListener(CloseEvent.CLOSE,onCloseSale);
				
			}
			
			salePanel.setUnitPrice(unitPrice);
			salePanel.setYBSumNum(YBNum);
			salePanel.x = int((1002 - salePanel.width)/2);
			salePanel.y = int((GlobalObjectManager.GAME_HEIGHT - salePanel.height)/2);
			
			WindowManager.getInstance().openDialog(salePanel,true);
			
		}
		
		public function onCloseSale(evt:CloseEvent = null):void
		{
			if(salePanel&&salePanel.parent)
			{
				salePanel.clear();
				WindowManager.getInstance().closeDialog(salePanel);
			}
		}
		
		private var _sheetID:int = 100;
		
		
		public function itemClickHandler(evt:ItemEvent):void
		{
			//  trace("数据项点击")
		}
		
		public function reFreshDataFn(evt:TimerEvent):void
		{
			getInstance().reFresh = true;
			sendSocketMessage(new m_bank_init_tos);
		}
		
		private var _bankPanel:BankPanel;
		public function set bankPanel(value:BankPanel):void
		{
			_bankPanel = value;	
		}
		
		public function get bankPanel():BankPanel
		{
			if(_bankPanel)
				return _bankPanel;
			return null;
		}
		
		private var _buyPanel:BuyPanel;
		public function set buyPanel(value:BuyPanel):void
		{
			_buyPanel = value;	
		}
		
		public function get buyPanel():BuyPanel
		{
			if(_buyPanel)
				return _buyPanel;
			return null;
		}
		
		private var _salePanel:SalePanel;
		public function set salePanel(value:SalePanel):void
		{
			_salePanel = value;
		}
		
		public function get salePanel():SalePanel
		{
			if(_salePanel)
				return _salePanel;
			return null;
		}
		
		private var _selfSaleArr:Array;
		private var _selfBuyArr:Array;
		private var _marketSaleArr:Array;
		private var _marketBuyArr:Array;
		public function set selfSaleArr(value:Array):void
		{
			_selfSaleArr = value;
		}
		
		public function get selfSaleArr():Array
		{
			return _selfSaleArr;
		}
		
		public function set selfBuyArr(value:Array):void
		{
			_selfBuyArr = value;
		}
		
		public function get selfBuyArr():Array
		{
			return _selfBuyArr;
		}
		
		public function set marketSaleArr(value:Array):void
		{
			_marketSaleArr = value;
		}
		
		public function get marketSaleArr():Array
		{
			return _marketSaleArr;
		}
		
		public function set marketBuyArr(value:Array):void
		{
			_marketBuyArr = value;
		}
		
		public function get marketBuyArr():Array
		{
			return _marketBuyArr;
		}
		
		public function getSalseIdByPrice(value:int):int   //上面是　sale
		{
			var itemId:int = -1;
			if(marketBuyArr)
			{
				for(var i:int=0; i<marketSaleArr.length;i++)
				{
					var bankseet:p_bank_simple_sheet =marketSaleArr[i] as p_bank_simple_sheet;
					if(bankseet.price == value)
					{
						itemId = i;
						return itemId;
					}
				}
			}
			
			return itemId;
		}
		
		public function getBuyIdByPrice(value:int):int  //下面是　buy
		{
			var itemId:int = -1;
			if(marketBuyArr)
			{
				for(var i:int=0; i<marketBuyArr.length;i++)
				{
					var bankseet:p_bank_simple_sheet =marketBuyArr[i] as p_bank_simple_sheet;
					if(bankseet.price == value)
					{
						itemId = i;
						return itemId;
					}
				}
			}
			
			return itemId;
		}
		
		private var _selfBankType:int = 0;// 0：求购;1:出售
		public function set selfBankType(value:int):void
		{
			_selfBankType = value;
		}
		
		public function get selfBankType():int
		{
			return _selfBankType;
		}
		
		private var _currentItemID:int
		public function set currentItemID(value:int):void
		{
			_currentItemID = value;
		}
		
		public function get currentItemID():int
		{
			return _currentItemID;
		}
		
		private var _buyOrSaleNum:int;
		public function set buyOrSaleNum(value:int):void
		{
			_buyOrSaleNum = value
		}
		
		public function get buyOrSaleNum():int
		{
			return _buyOrSaleNum;
		}
		
		private var _cancelNum:int
		public function set cancelNum(value:int):void
		{
			_cancelNum = value;
		}
		
		public function get cancelNum():int
		{
			return _cancelNum;
		}
		
		private var _sumNum:int
		public function set sumNum(value:int):void
		{
			_sumNum = value;			
		}
		
		public function get sumNum():int
		{
			return _sumNum;
		}
		
		private var _perPrice:int
		public function set perPrice(value:int):void
		{
			_perPrice = value;
		}
		
		public function get perPrice():int
		{
			return _perPrice;
		}
		
		public function updateMarketBuyList(vo:p_bank_sheet):void
		{
			var perPrice:int = vo.price;
			var num:int = vo.num;
			updateMkBuyList(perPrice,num);
		}
		
		public function updateMkBuyList(price:int,num:int):void
		{	
			var sheet:p_bank_simple_sheet = new p_bank_simple_sheet();
			sheet.num = num;
			sheet.price = price;
			var marketBuyArr:Array = BankModule.getInstance().marketBuyArr;
			if(marketBuyArr.length == 0)
			{
				BankModule.getInstance().marketBuyArr.push(sheet);
				var object1:Object = new Object();
				object1.voType = BankConstant.MARKET_BUY;
				object1.source = BankModule.getInstance().marketBuyArr;
				BankModule.getInstance().bankPanel.updateDataSource(object1);
				return ;
			}
			
			if(marketBuyArr.length!=0 && price>(marketBuyArr[0] as p_bank_simple_sheet).price)
			{
				BankModule.getInstance().marketBuyArr.unshift(sheet);
				if(BankModule.getInstance().marketBuyArr.length == 8)
				{
					BankModule.getInstance().marketBuyArr.pop();
				}
				var object2:Object = new Object();
				object2.voType = BankConstant.MARKET_BUY;
				object2.source = BankModule.getInstance().marketBuyArr;
				BankModule.getInstance().bankPanel.updateDataSource(object2);
				return;
			}
			
			for(var i:int=0;i<marketBuyArr.length;i++)
			{
				var currentPrice:int = (marketBuyArr[i] as p_bank_simple_sheet).price;
				if(marketBuyArr[i+1])
				{
					if(price == currentPrice)
					{
						var tempSheet:p_bank_simple_sheet = BankModule.getInstance().marketBuyArr[i]
						tempSheet.num = sheet.num + tempSheet.num;
						var object5:Object = new Object();
						object5.voType = BankConstant.MARKET_BUY;
						object5.source = BankModule.getInstance().marketBuyArr;
						BankModule.getInstance().bankPanel.updateDataSource(object5);
						return;	
					}
					
					var nextItemPrice:int = (marketBuyArr[i+1] as p_bank_simple_sheet).price;	
					if(currentPrice > price && price > nextItemPrice)
					{
						BankModule.getInstance().marketBuyArr.splice(i+1,0,sheet);
						if(BankModule.getInstance().marketBuyArr.length ==8)
						{
							BankModule.getInstance().marketBuyArr.pop();
						}
						var object3:Object = new Object();
						object3.voType = BankConstant.MARKET_BUY;
						object3.source = BankModule.getInstance().marketBuyArr;
						BankModule.getInstance().bankPanel.updateDataSource(object3);
						return;
					}
				}else
				{
					if(price == currentPrice)
					{
						var tempSheet1:p_bank_simple_sheet = BankModule.getInstance().marketBuyArr[i]
						tempSheet1.num = sheet.num + tempSheet1.num;
						var object6:Object = new Object();
						object6.voType = BankConstant.MARKET_BUY;
						object6.source = BankModule.getInstance().marketBuyArr;
						BankModule.getInstance().bankPanel.updateDataSource(object6);
						return;	
					}
					
					BankModule.getInstance().marketBuyArr.push(sheet);
					if(BankModule.getInstance().marketBuyArr.length ==8)
					{
						BankModule.getInstance().marketBuyArr.pop();
					}
					var object4:Object = new Object();
					object4.voType = BankConstant.MARKET_BUY;
					object4.source = BankModule.getInstance().marketBuyArr;
					BankModule.getInstance().bankPanel.updateDataSource(object4);
					return;	
				}
			}
		}
		
		
	}
}