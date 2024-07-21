package modules.deal
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.events.WindowEvent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	import com.scene.sceneData.HandlerAction;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.MyRole;
	import com.utils.MoneyTransformUtil;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.collect.CollectModule;
	import modules.deal.views.DealPanle;
	import modules.deal.views.HandleStallView;
	import modules.deal.views.OtherStallPanel;
	import modules.deal.views.StallPanel;
	import modules.deal.views.stallViews.SearchPanel;
	import modules.deal.views.stallViews.StallBuyWindow;
	import modules.deal.views.stallViews.StallPriceUI;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	import proto.common.p_goods;
	import proto.common.p_map_stall;
	import proto.common.p_pos;
	import proto.line.m_exchange_agree_toc;
	import proto.line.m_exchange_agree_tos;
	import proto.line.m_exchange_cancel_toc;
	import proto.line.m_exchange_cancel_tos;
	import proto.line.m_exchange_confirm_toc;
	import proto.line.m_exchange_confirm_tos;
	import proto.line.m_exchange_lock_toc;
	import proto.line.m_exchange_lock_tos;
	import proto.line.m_exchange_refuse_toc;
	import proto.line.m_exchange_refuse_tos;
	import proto.line.m_exchange_request_toc;
	import proto.line.m_exchange_request_tos;
	import proto.line.m_stall_buy_toc;
	import proto.line.m_stall_buy_tos;
	import proto.line.m_stall_chat_toc;
	import proto.line.m_stall_chat_tos;
	import proto.line.m_stall_detail_toc;
	import proto.line.m_stall_detail_tos;
	import proto.line.m_stall_employ_toc;
	import proto.line.m_stall_employ_tos;
	import proto.line.m_stall_extractmoney_toc;
	import proto.line.m_stall_extractmoney_tos;
	import proto.line.m_stall_finish_toc;
	import proto.line.m_stall_finish_tos;
	import proto.line.m_stall_getall_toc;
	import proto.line.m_stall_getall_tos;
	import proto.line.m_stall_getout_toc;
	import proto.line.m_stall_getout_tos;
	import proto.line.m_stall_list_toc;
	import proto.line.m_stall_list_tos;
	import proto.line.m_stall_move_toc;
	import proto.line.m_stall_move_tos;
	import proto.line.m_stall_open_toc;
	import proto.line.m_stall_open_tos;
	import proto.line.m_stall_putin_toc;
	import proto.line.m_stall_putin_tos;
	import proto.line.m_stall_request_toc;
	import proto.line.m_stall_request_tos;
	import proto.line.m_stall_state_toc;
	import proto.line.m_stall_state_tos;
	import proto.line.p_simple_goods;
	import proto.line.p_stall_info;
	
	public class DealModule extends BaseModule
	{
		private var timer:Timer;
		public function DealModule(){
			
		}

		private static var instance:DealModule;
		
		public static function getInstance():DealModule{
			if( instance == null){
				instance = new DealModule();
			}
			return instance;
		}
		override protected function initListeners():void{
			//服务端消息
			this.addSocketListener(SocketCommand.EXCHANGE_REQUEST,dealRequestBack);
			this.addSocketListener(SocketCommand.EXCHANGE_AGREE,dealAgreeBack);
			this.addSocketListener(SocketCommand.EXCHANGE_REFUSE,dealRefuseBack);
			this.addSocketListener(SocketCommand.EXCHANGE_LOCK,dealLockBack);
			this.addSocketListener(SocketCommand.EXCHANGE_CONFIRM,dealConfirmBack);
			this.addSocketListener(SocketCommand.EXCHANGE_CANCEL,dealCancelBack);
			this.addSocketListener(SocketCommand.STALL_OPEN,openStallSelf);
			this.addSocketListener(SocketCommand.STALL_REQUEST,stallReturn);
			this.addSocketListener(SocketCommand.STALL_PUTIN,putinGoods);
			this.addSocketListener(SocketCommand.STALL_GETOUT,getOutReturn);
			this.addSocketListener(SocketCommand.STALL_GETALL,getAllBackResult);
			this.addSocketListener(SocketCommand.STALL_CHAT,receiveMsg);
			this.addSocketListener(SocketCommand.STALL_EMPLOY,employResult);
			this.addSocketListener(SocketCommand.STALL_EXTRACTMONEY,extractMoney);
			
			this.addSocketListener(SocketCommand.STALL_BUY,buyResult);
//			this.addSocketListener(SocketCommand.STALL_LIST,openSearchPanel);
			this.addSocketListener(SocketCommand.STALL_DETAIL,showOtherStall);
			this.addSocketListener(SocketCommand.STALL_FINISH,finishStallResult);
			this.addSocketListener(SocketCommand.STALL_MOVE,swapItemResult);
			this.addSocketListener(SocketCommand.STALL_STATE,stallState_toc);
			
			//模块消息
			this.addMessageListener(ModuleCommand.OPEN_STALL_PANEL,requestStallPanel);
			this.addMessageListener(ModuleCommand.SELETED_STALL,doSeletedStall);
			this.addMessageListener(ModuleCommand.SKILL_CLOSE_DEAL,battleCloseDeal);
			
		}
		
		private function doSeletedStall(data:Object):void{
			var role_id:int = data as int;
			if(role_id != GlobalObjectManager.getInstance().user.base.role_id){//请求其他人的摊位
				requestStallOther(role_id);
			}else{//请求自己的摊位。
				requestStallSelf();
			}
		}
		
		private function acceptHandler(obj:Object):void
		{
			var tmp:m_exchange_request_toc = obj as m_exchange_request_toc;
			var vo:m_exchange_agree_tos = new m_exchange_agree_tos();
			vo.src_roleid = tmp.src_role_id;//_srcRoleId;
			_srcRoleId = tmp.src_role_id;
			_srcRoleName = tmp.src_role_name;
			
			this.sendSocketMessage(vo);
			for (var i:int=0; i < _prompts.length; i++)
			{
				var key:String=_prompts[i];
				Prompt.removePromptItem(key);
			}
			_prompts=[];
		}
		
		private function refuseHandler(obj:Object):void
		{
			var tmp:m_exchange_request_toc = obj as m_exchange_request_toc;
			var vo:m_exchange_refuse_tos = new m_exchange_refuse_tos();
			vo.src_roleid = tmp.src_role_id;//_srcRoleId;
			_srcRoleName = tmp.src_role_name;
			this.sendSocketMessage(vo);
		}
		
		private var _dealPanle:DealPanle;
		private function openDealPanel(srcRoleName:String,tarRoleName:String):void
		{
			if(!_dealPanle)
			{
				_dealPanle = new DealPanle(srcRoleName,tarRoleName);
				_dealPanle.addEventListener(CloseEvent.CLOSE,onCloseHandler);
			}else
			{
				_dealPanle.setRoleName(srcRoleName,tarRoleName);
			}
			_dealPanle.x = 323;
			_dealPanle.y = 80;
			WindowManager.getInstance().popUpWindow(_dealPanle);
			PackManager.getInstance().popUpWindow(PackManager.PACK_1,_dealPanle.x+_dealPanle.width,80,false);
			
			checkDistance();
		}
		
		private function onCloseHandler(evt:CloseEvent=null):void
		{
			if(evt !=null)
			{
				closeDeal(DealConstant.DEAL_NORMAL_CANCEL);
				
			}
		}
		
		private function checkDistance():void
		{
			if(!timer)
			{
				timer = new Timer(1000);
				timer.addEventListener(TimerEvent.TIMER,onCheckDistance);
				timer.start();
			}
		}
		private function stopCheckDistance():void
		{
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,onCheckDistance);
				timer = null;
			}
		}
		
		
		private function onCheckDistance(e:TimerEvent):void
		{
			var roleId:int;
			if(_tarRoleId)
			{
				roleId = _tarRoleId;
			}
			if(_srcRoleId)
			{
				roleId = _srcRoleId;
			}
			var handler:HandlerAction=new HandlerAction(distanceCloseDeal,[roleId]);
			this.dispatch(ModuleCommand.DEAL_CHECK_DISTANCE,handler);
		}
		
		public function distanceCloseDeal():void
		{
			
			closeDeal(DealConstant.DEAL_SPACE_CANCEL);
		}
		
		private function battleCloseDeal(data:Object):void
		{
			closeDeal(DealConstant.DEAL_BATTLE_CANCEL);
		}
		
		private function closeDeal(type:int):void  //普通　1；战斗2　；　距离远3
		{
			if(_dealPanle)
			{
				baseItemArr = _dealPanle.setlfTile.itemArr;//_dealPanle.setlfTile.baseItemArr;
				reFreshPackageGoods();
				var vo:m_exchange_cancel_tos = new m_exchange_cancel_tos();
				if(_tarRoleId)
				{
					vo.src_roleid = _tarRoleId;
					OperateMode.getInstance().removeMode(OperateMode.DEAL_MODE);
				}
				if(_srcRoleId)
				{
					vo.src_roleid = _srcRoleId;
					OperateMode.getInstance().removeMode(OperateMode.DEAL_MODE);
				}
				vo.cancel_type = type;
				this.sendSocketMessage(vo);
				
				if(type == DealConstant.DEAL_BATTLE_CANCEL)
					BroadcastSelf.getInstance().appendMsg("进入战斗状态，交易取消！");
				else if(type==DealConstant.DEAL_SPACE_CANCEL)
					BroadcastSelf.getInstance().appendMsg("距离过远，交易取消！");
				else if(type==DealConstant.DEAL_NORMAL_CANCEL)
					BroadcastSelf.getInstance().appendMsg("你取消了交易");
			}
			stopCheckDistance();
			
		}
		private function resetConfirmFlag():void
		{
			_selfConfirm = false;
			_otherConfirm = false;
		}
		
		/**
		 * 交易取消
		 * @param vo
		 * 
		 */		
		private function dealCancelBack(vo:m_exchange_cancel_toc):void
		{
			if(vo.succ)
			{
				
				if(!vo.return_self)
				{
					BroadcastSelf.getInstance().appendMsg(vo.reason);//"对方取消了交易"
					OperateMode.getInstance().removeMode(OperateMode.DEAL_MODE);
				}else
				{
//					BroadcastSelf.getInstance().appendMsg("你取消了交易");
				}
				reFreshPackageGoods();
				removeDealPanel();
			}else
			{
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		
		private function reFreshPackageGoods():void
		{
			if(_dealPanle)
			{
				baseItemArr = _dealPanle.setlfTile.itemArr;
			}
			if(baseItemArr && baseItemArr.length!=0)
			{
				for(var i:int=0;i<baseItemArr.length;i++)
				{
					var bsItem:BaseItemVO = baseItemArr[i] as BaseItemVO;
					bsItem.state = 0;
//					PackManager.getInstance().lockUpdateGoods(bsItem,false);
					PackManager.getInstance().lockGoods(bsItem,false);
				}
				baseItemArr.length = 0;
			}
		}
		
		public function requestDeal(roleId:int):void
		{
//			sceneRequestDeal()
			var handler:HandlerAction = new HandlerAction(sceneRequestDeal,[roleId]);
			
			this.dispatch(ModuleCommand.ACTION_RUN_TO_DEAL.toString(),roleId);
			
		}
		public function sceneRequestDeal(roleId:int):void
		{
			var role:MyRole=SceneUnitManager.unitHash["1_"+roleId];
			if(role&&role.pvo&&role.pvo.state==1)//RoleActState.DEAD
			{
				BroadcastSelf.logger("对方处于死亡状态，不可交易。");
				return;
			}
			
			var vo:m_exchange_request_tos=new m_exchange_request_tos();
			
			vo.target_roleid= roleId;//selectRoleVo.id;
			this.sendSocketMessage(vo);
		}
		
		
		/**
		 *交易发起返回 
		 * @param vo
		 * 
		 */
		private var _srcRoleName:String;
		private var _srcRoleId:int;
		private var _prompts:Array = [];
		
		private function dealRequestBack(vo:m_exchange_request_toc):void
		{
			if(vo.succ)
			{
				if(vo.src_role_name && vo.src_role_id)
				{
//					_srcRoleName = vo.src_role_name;
//					_srcRoleId = vo.src_role_id;
				}
				if(!vo.return_self)
				{
					var key:String = Prompt.show(vo.src_role_name + " 向你发出交易请求","交易请求",acceptHandler,refuseHandler,"确定","取消",[vo],true,false,new Point(Math.random() * 200 + 300, Math.random() * 200 + 200));
					_prompts.push(key);
//					Alert.show(_srcRoleName + " 向你发出交易请求","交易请求",acceptHandler,refuseHandler);
				}else
				{
					BroadcastSelf.getInstance().appendMsg("你的交易请求已发送");
				}
			}else
			{
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		/**
		 *交易同意返回 
		 * @param vo
		 * 
		 */
		private var _tarRoleName:String;
		private var _tarRoleId:int;
		private function dealAgreeBack(vo:m_exchange_agree_toc):void
		{
			if(vo.succ)
			{
				if(vo.target_role_id && vo.target_role_name)
				{
					_tarRoleName = vo.target_role_name;
					_tarRoleId = vo.target_role_id;
				}
				var selfName:String = GlobalObjectManager.getInstance().user.base.role_name;
				if(!vo.return_self)
				{
					OperateMode.getInstance().setMode(OperateMode.DEAL_MODE);
					BroadcastSelf.getInstance().appendMsg(_tarRoleName + "同意了你的交易请求");
					openDealPanel(selfName,_tarRoleName);
				}else
				{
					OperateMode.getInstance().setMode(OperateMode.DEAL_MODE);
					BroadcastSelf.getInstance().appendMsg("你同意了" + _srcRoleName +"的交易请求");
					openDealPanel(selfName,_srcRoleName);
				}
				
				CollectModule.getInstance().collectStop();
			}else
			{
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		
		/**
		 *交易拒绝返回 
		 * @param vo
		 * 
		 */		
		private function dealRefuseBack(vo:m_exchange_refuse_toc):void
		{
			if(vo.succ)
			{
				if(!vo.return_self)
				{
					BroadcastSelf.getInstance().appendMsg(vo.role_name + "拒绝了你的交易请求");
					
				}else
				{
					BroadcastSelf.getInstance().appendMsg("你拒绝了" + _srcRoleName + "的交易请求");
				}
			}else
			{
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		/**
		 *交易确定返回 
		 * @param vo
		 * 
		 */
		private function dealConfirmBack(vo:m_exchange_confirm_toc):void
		{
			if(vo.succ)
			{
				if(!vo.return_self)
				{
					_otherConfirm = true;
					BroadcastSelf.getInstance().appendMsg("对方已确定交易。");
				}else
				{
					_selfConfirm = true;
					BroadcastSelf.getInstance().appendMsg("你确定了交易。");
				}
				
				if(_selfConfirm && _otherConfirm)
				{
					OperateMode.getInstance().removeMode(OperateMode.DEAL_MODE);
					BroadcastSelf.getInstance().appendMsg("交易成功。");
					
					if(dealMoney)
					{
						BroadcastSelf.getInstance().appendMsg("失去银子："+MoneyTransformUtil.silverToOtherString(dealMoney));
						dealMoney = 0;
					}
					if (dealGold)
					{
						BroadcastSelf.getInstance().appendMsg("失去元宝：" + dealGold);
						dealGold = 0;
					}
					
					if(otherMoney)
					{
						BroadcastSelf.getInstance().appendMsg("得到银子："+MoneyTransformUtil.silverToOtherString(otherMoney));
						otherMoney = 0;
					}
					if (otherGold)
					{
						BroadcastSelf.getInstance().appendMsg("得到元宝：" + otherGold);
						otherGold = 0;
					}
					removeDealPanel();

					var currentGoods:Array = vo.goods_info;
					for(var i:int=0;i<currentGoods.length;i++)
					{
						var currentGood:p_simple_goods = currentGoods[i];
						for(var j:int=0;j<otherGoods.length;j++)
						{
							var otherGood:p_goods = otherGoods[j];
							if(currentGood.goodsid == otherGood.id)
							{
								otherGood.id = currentGood.goodsid;
								otherGood.bagid = currentGood.bagid;
								otherGood.bagposition = currentGood.pos;
								var baseItemVO:BaseItemVO = getBaseItemVO(otherGood);
								PackManager.getInstance().updateGoods(baseItemVO.bagid,baseItemVO.position,baseItemVO);//lockGoods(baseItemVO,false);
							}
						}
					}
					
					for(var n:int=0;n<baseItemArr.length;n++)
					{
						var removeGoods1:BaseItemVO = baseItemArr[n];
						PackManager.getInstance().removeGoods(removeGoods1.oid,removeGoods1.bagid);
					}
					
					stopCheckDistance();
				}
			}else
			{
				BroadcastSelf.getInstance().appendMsg(vo.reason);
				reFreshPackageGoods();
				removeDealPanel();
				OperateMode.getInstance().removeMode(OperateMode.DEAL_MODE);
				
			}
		}
		
		private function sendToPackage():void
		{
			
			var object:Object = new Object();
			object.send = _itemArr;
			object.riturn = _returnItemArr
			this.dispatch(ModuleCommand.DEAL_ITEM_CHANGE,object);
		}
		
		/**
		 *通知角色模块更新 
		 * 
		 */		
		private function sendToRoleStateModel(sum:int):void
		{
			GlobalObjectManager.getInstance().user.attr.silver=GlobalObjectManager.getInstance().user.attr.silver + sum;
			changeMoney();
		}
		
		private function changeMoney():void
		{
			dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
		}
		
		private function removeDealPanel():void
		{
			if(_dealPanle)
			{
				_dealPanle.disposeTile();
				WindowManager.getInstance().removeWindow(_dealPanle);
				_dealPanle.reset(false);
				resetConfirmFlag();
				_dealPanle.dispose();
				_dealPanle = null;
			}
		}
		
		private var _selfConfirm:Boolean;
		private var _otherConfirm:Boolean;
		private var _returnItemArr:Array;
		public var otherGoods:Array;
		/**
		 *交易商品锁定返回
		 */
		private function dealLockBack(vo:m_exchange_lock_toc):void
		{
			if(vo.succ)
			{
				if(!vo.return_self)
				{
					BroadcastSelf.getInstance().appendMsg("对方的交易物品已锁定。");
					
					otherGoods = vo.goods;
					var items:Array = [];
					_returnItemArr = [];
					for each(var goodsVO:p_goods in otherGoods)
					{
						var baseItemVO:BaseItemVO = getBaseItemVO(goodsVO);
						if(baseItemVO){
							items.push(baseItemVO);
							var object:Object = new Object();
							object.bagid = goodsVO.bagid;
							object.position = goodsVO.bagposition;
							object.baseItemVO = baseItemVO;
							_returnItemArr.push(object);
						}
					}
					otherMoney = vo.silver;
					otherGold = vo.gold;
					
					var sumArr:Array = DealConstant.silverToOther(vo.silver);
					var ding:String = sumArr[0];
					var liang:String = sumArr[1];
					var wen:String = sumArr[2];
					if(_dealPanle){
						_dealPanle.lockOther(items,vo.gold, ding,liang,wen);
					}
				}else
				{
					BroadcastSelf.getInstance().appendMsg("你的交易物品已锁定。");
					if(_dealPanle){
						_dealPanle.lockSelf();
					}
				}
			}else
			{
				if(_dealPanle){
					_dealPanle.locklBtn.enabled = true;
					_dealPanle.setTextInputEditable(true);
				}
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}
		
		private function getBaseItemVO(vo:p_goods):BaseItemVO{
			var baseItemVO:BaseItemVO;
			if(vo.id == 0)return null;
			switch(vo.type){
				case ItemConstant.TYPE_EQUIP:baseItemVO = new EquipVO();break;
				case ItemConstant.TYPE_GENERAL:baseItemVO = new GeneralVO();break;
				case ItemConstant.TYPE_STONE:baseItemVO = new StoneVO();
			}
			baseItemVO.copy(vo);
			return baseItemVO;
		}
		
		public function dragDrop(vo:BaseItemVO):void
		{
			_dealPanle.setlfTile.onDragEnter(vo);
		}
		
		/**
		 * 物品搞回背包  交易位置上的清空 
		 * @param vo
		 * 
		 */		
		public function dealBackPackage(vo:BaseItemVO):void
		{
			_dealPanle.deleteItem(vo);
		}
		
		public function dealLock(gold:int, ding:int,liang:int,wen:int,itemsArr:Array):void
		{
			var vo:m_exchange_lock_tos = new m_exchange_lock_tos();
			var sum:int = ding * 10000 + liang * 100 + wen;
			dealMoney = sum;
			dealGold = gold;
			vo.silver = sum;
			vo.gold = gold;
			vo.goods = itemsArr;
			this.sendSocketMessage(vo);
		}
		
		private var _itemArr:Array;
		public function setItemsPos(itemArr:Array):void
		{
			_itemArr = itemArr;			
		}
		
		private var _baseItemArr:Array
		public function set baseItemArr(arr:Array):void
		{
			_baseItemArr = arr;	
		}
		
		public function get baseItemArr():Array
		{
			return _baseItemArr;
		}
		
		/**
		 *交易确定 
		 * 
		 */		
		public function dealCommit():void
		{
			BroadcastSelf.getInstance().appendMsg("你的交易确定已发送。");
			var vo:m_exchange_confirm_tos = new m_exchange_confirm_tos;
			this.sendSocketMessage(vo);
		}
		
		private var _dealMoney:int
		public function set dealMoney(value:int):void
		{
			_dealMoney = value
		}
		
		public function get dealMoney():int
		{
			return _dealMoney;
		}
		
		private var _otherMoney:int;
		public  function set otherMoney(money:int):void
		{
			_otherMoney = money;
		}
		
		public function get otherMoney():int
		{
			return _otherMoney;
		}
		
		private var _dealGold:int;
		public function set dealGold(value:int):void
		{
			_dealGold = value;
		}
		
		public function get dealGold():int
		{
			return _dealGold;
		}
		
		private var _otherGold:int;
		public function set otherGold(value:int):void
		{
			_otherGold = value;
		}
		
		public function get otherGold():int
		{
			return _otherGold;
		}

		
		
		
		////////////////  /////////////////////////
		public function requestStallState():void
		{
			var vo:m_stall_state_tos = new m_stall_state_tos();
			this.sendSocketMessage(vo);
		}
		private function stallState_toc(vo:m_stall_state_toc):void
		{
//			vo.stall_state=0;//未摆，、1;摆着　//2; 过期
//			if(vo.stall_state == 2)
//			{
				PackManager.getInstance().setBtButtonFilter(vo.stall_state);
//			}
		}
		
		private function requestStallPanel(data:Object):void
		{
			var stallingType:int = data as int;
			switch(stallingType)
			{
				case 0:                     //未摆    场景测试 sence test 
					
					if(_stallPanel && WindowManager.getInstance().isPopUp(_stallPanel))
					{
						WindowManager.getInstance().removeWindow(_stallPanel);
					}
					
					else if(_handleStallPanel && WindowManager.getInstance().isPopUp(_handleStallPanel))
					{
						WindowManager.getInstance().removeWindow(_handleStallPanel);						
					}else
					{
						SenceRequestStall();
						
					}
					
//					////test
//					var str:String = "<font color='#ffff33'>"+"<a href='event:moveto#333'>"+"ＮＰＣ" +"</a></font>";
//					BroadcastSelf.getInstance().appendMsg(str);
//					requestStallSelf();
					break;
				case 1:               //摆摊中。。。
					requestStallSelf();
					break;
				case 2:       //  过期收摊              //摊位
					requestStallSelf();
//					finishStall();
					
					break;
				case 3:                     //雇员摊位
					requestStallSelf();
					
					break;
				default : break;
			}
			
			CollectModule.getInstance().collectStop();
		}
		
		private function SenceRequestStall():void
		{
			var handler:HandlerAction = new HandlerAction(requestStallSelf);
			
			this.dispatch(ModuleCommand.OPEN_STALL,handler);
		}
		
		
		/**
		 * 物品的价格。 
		 */		
		private var priceUi:StallPriceUI ;
		private var sure:Boolean;
		/**
		 * 添加物品时 弹出的填价界面 
		 * @param index
		 * @param bsItemVo
		 * @param state  //1 雇佣摆摊中  2 自己摆摊中 3 尚未摆摊 （可能会用）
		 * 
		 */		
		public function openPriceUi(index:int,bsItemVo:BaseItemVO,state:int):void
		{
			if(!priceUi)
			{
				priceUi = new StallPriceUI();
				
				priceUi.x = int((1002 - priceUi.width) / 2);
				priceUi.y = int((GlobalObjectManager.GAME_HEIGHT - priceUi.height) / 2 - 20);
				WindowManager.getInstance().openDialog(priceUi);
				priceUi.itemData = bsItemVo;
				
				sure = false;
				priceUi.addEventListener(CloseEvent.CLOSE, priceUiClose);
				
				priceUi.pos = index+1;
				priceUi.state = state;
			}
		}
		
		
		public function priceUiCancel():void
		{
			priceUiClose();
		}
		
		/**
		 * 搞定了价格，放在摊位格子里的 BaseItemVo 里 
		 * @param pos
		 * @param price
		 * @param state //1 雇佣摆摊中  2 自己摆摊中 3 尚未摆摊
		 * 
		 */		
		public function setStallPrice(pos:int, price:int, priceType:int, bsItemVo:BaseItemVO, state:int):void
		{
			if(pos<=0 || price < 0)
				return;
			
			var vo:m_stall_putin_tos = new m_stall_putin_tos();
			
			vo.goods_id = bsItemVo.oid;
			vo.pos = pos;
			vo.price = price;
			vo.price_type = priceType;
			
			this.sendSocketMessage(vo);
			putin_pos = pos;
			if(_handleStallPanel)
			{
				_handleStallPanel.setItemVoPrice(pos, price, priceType);
			}
			else if(_stallPanel)
			{
				_stallPanel.setTileContent(pos,null,bsItemVo);
				_stallPanel.setItemPrice(pos,price, priceType);
			}
			sure = true;
			priceUiClose();
		}
		
		
		private function putinGoods(vo:m_stall_putin_toc):void
		{
			if(vo.succ)
			{
				//  trace();
				//  trace("   。。。放上物品成功。。。  ");
				if(_stallPanel)
				{
					_stallPanel.deletePackGoods(putin_pos);
					
				}
			}
			else{
				//  trace("   。。。放上物品失败。。。  ");
				Alert.show(vo.reason,"放置物品失败：");
				putinFalse();
			}
		}
		
		private var putin_pos:int =-1;  // 临时放 位置。 失败时打回背包。
		private function putinFalse():void
		{
			if(_handleStallPanel)
			{
				_handleStallPanel.sendToPackage(putin_pos);
				
			}
			else if(_stallPanel)
			{
				_stallPanel.sendToPackage(putin_pos);
			}
		}
		
		private function priceUiClose(evt:CloseEvent = null):void
		{
			if(priceUi)
			{
				if(!sure)
				{
					if(_handleStallPanel)
					{
						_handleStallPanel.sendToPackage(priceUi.pos);
					}
					if(_stallPanel)
					{
						_stallPanel.sendToPackage(priceUi.pos);
					}
				}
				
				WindowManager.getInstance().closeDialog(priceUi);
				priceUi.removeEventListener(CloseEvent.CLOSE, priceUiClose);
				priceUi.dispose();
				priceUi = null;
			}
		}
		
		
		/**
		 * 确认摆摊 
		 * @param name       摊位名
		 * @param mode       摆摊模式  //摆摊模式 0为自己摆摊 1为系统托管
		 * @param goods      摆摊的商品  repeated p_stall_good
		 * @param time_hour  如果摆摊模式是雇佣小二， 则为雇佣的时间，否则为 0；
		 * name:String, mode:int, goods:Array, time_hour:int 
		 */		
		public function StallConfirm(vo:m_stall_request_tos):void
		{
			if(!vo)
				return;
			
			var needmoney:int = vo.time_hour * DealConstant.EMPLOY_P_HOUR + 20;
			var m_money:int = GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind;
			
			if(needmoney > m_money )
			{
				if(vo.time_hour == 0)  //银子不足，摆摊费需要XXX
				{
					Alert.show("银子不足，摆摊费需要"+DealConstant.silverToOtherString( needmoney),"失败提示：",null,null,"确定","",null,false);
					return;
					
				}else{  //银子不足，摆摊费和店小二工资共需支付XXX
					
					Alert.show("银子不足，摆摊费和店小二工资共需支付"+DealConstant.silverToOtherString( needmoney) ,"失败提示：",null,null,"确定","",null,false);
					return;
				}
			}
			
			selfStallVo = vo;
			this.sendSocketMessage(vo);
			
		}
		
		
		private var selfStallVo:m_stall_request_tos;   //摊位名　（自家用的）
		public var _stallPanel:StallPanel ;
		/**
		 * 提交 确定摆摊  返回！ 
		 * @param vo
		 * 
		 */		
		private function stallReturn(vo:m_stall_request_toc):void
		{
			var map_stall_vo:p_map_stall;// = new p_map_stall();
			if(vo.return_self)
			{
				if(!vo.succ)
				{
					Alert.show(vo.reason,"失败提示：",null,null,"确定","",null,false);
					return;
				}
				
				map_stall_vo = new p_map_stall();
				map_stall_vo.mode = selfStallVo.mode;   // 1 雇佣  , 0亲自摆摊
				map_stall_vo.pos = null;
				map_stall_vo.role_id = GlobalObjectManager.getInstance().user.base.role_id;
				map_stall_vo.role_name = GlobalObjectManager.getInstance().user.base.role_name;
				map_stall_vo.stall_name = selfStallVo.name;
				
				this.dispatch(ModuleCommand.DEAL_STALL_START, map_stall_vo);
				//  trace("...request_toc>>>succ!");
				//没在摆摊成功的返回里 返回摊位基本情况  
				//去请求的用 p_stall_sell_goods 跟 界面上的 p_stall_goods 不一样！ 
				if(_handleStallPanel)
				{
					_handleStallPanel.deletePackGoods();
					_handleStallPanel.dispose();
					
					WindowManager.getInstance().removeWindow(_handleStallPanel);
					_handleStallPanel = null;
					
				}
				
				requestStallSelf();
				
				var str:String = "成功摆摊";
				if(vo.bind_silver + vo.silver > 20 )
				{
					var m_money:int = vo.bind_silver + vo.silver - 20;
//					str += ",扣除店小二工资"+ DealConstant.silverToOtherString(m_money);
					str = "摆摊成功，扣除店小二工资" + DealConstant.silverToOtherString(m_money) + ",摆摊费20文。";
					
				}else{
					
					str = "摆摊成功，扣除摆摊费20文。"
				}
				
				if(vo.bind_silver>0)//(silver_bind < cost)
				{
					todoChangeMoney(-vo.bind_silver, DealConstant.STALL_PRICE_TYPE_SILVER);
//					str += ",扣除绑定银子："+DealConstant.silverToOtherString(vo.bind_silver);
					
				}
				if(vo.silver>0){
					
					todoChangeMoney(-vo.silver, DealConstant.STALL_PRICE_TYPE_SILVER);
//					str += ", 扣除银子："+DealConstant.silverToOtherString(vo.silver);
					
				}
				BroadcastSelf.logger(str);
				
//				todoChangeMoney(-vo.silver);
//				todoChangeMoney(-vo.bind_silver,RoleStateConstant.SILVER_BIND);
				
			}else {
				this.dispatch(ModuleCommand.DEAL_STALL_END,vo.stall_info);
				this.dispatch(ModuleCommand.DEAL_STALL_START,vo.stall_info);
			}

		}
		
		/**
		 * 请求自己的摊位内容！ 
		 * 
		 */		
		public function requestStallSelf():void
		{
			if (_handleStallPanel && WindowManager.getInstance().isPopUp(_handleStallPanel)) {
				WindowManager.getInstance().removeWindow(_handleStallPanel);
				return;
			}
			
			var vo:m_stall_open_tos = new m_stall_open_tos();
			this.sendSocketMessage(vo);
			
		}
		
		
		public var _handleStallPanel:HandleStallView;
		/**
		 * 请求数据返回，打开自己的摊位。 
		 * 
		 */		
		private function openStallSelf(vo:m_stall_open_toc):void
		{
			if(!vo.succ){
				
				Alert.show(vo.reason,"失败提示：");
				this.dispatch(ModuleCommand.OPEN_STALL,true);
				return;
			}
			
			//摆摊操作时 不能使用背包物品
			OperateMode.getInstance().setMode(OperateMode.BT_MODE);
			
			if(_otherStall)
			{
				closeOtherStall();
			}
			
			DealConstant.remain_time = 0;
			
			if(vo.state == 3 ) //非摆摊 状态下 
			{
				DealConstant.OVERDUE = false;
				
				if(!_handleStallPanel)
				{
					_handleStallPanel = new HandleStallView();
					_handleStallPanel.addEventListener(WindowEvent.CLOSEED, closeHandleringPanel);
				}
				
//				if(vo.goods.length > 0)
//				{
					_handleStallPanel.setDatas(vo);
//				}
				
				if(!WindowManager.getInstance().isPopUp(_handleStallPanel))
				{
					_handleStallPanel.x = 323;//630;
					_handleStallPanel.y = 80;//92;
					WindowManager.getInstance().popUpWindow(_handleStallPanel);
					PackManager.getInstance().popUpWindow(PackManager.PACK_1,600,80,false);
				}
			}
			else if(vo.state ==4){                //to do 过期 情况下
				selfStalling = false;
				
				if(!_stallPanel)
				{
					_stallPanel = new StallPanel();
					
					WindowManager.getInstance().popUpWindow(_stallPanel);
					_stallPanel.addEventListener(WindowEvent.CLOSEED, closeStallHandler);
					
					_stallPanel.x= 400;  //_stallPanel.stage.stageWidth - _stallPanel.width-200;
					_stallPanel.y= 100; //_stallPanel.stage.stageHeight - _stallPanel.height-100;
					
				}
				
				_stallPanel.setDatas(vo);
				
			}
			else{   //摆摊中  state ==1 自动摆摊， ==2 自己摆摊
			
				if(_handleStallPanel)
				{
					_handleStallPanel.dispose();
					
					WindowManager.getInstance().removeWindow(_handleStallPanel);
					_handleStallPanel = null;
					
				}
				
				if(!_stallPanel)
				{
					_stallPanel = new StallPanel();
					_stallPanel.x= 400;  
					_stallPanel.y= 100;
					
					_stallPanel.addEventListener(WindowEvent.CLOSEED,closeStallHandler);
				}
				
				if(vo.state == 1)
				{
					selfStalling=false;
				}else if(vo.state == 2)
				{
					selfStalling=true;
				}
				
				_stallPanel.setDatas(vo);
				WindowManager.getInstance().popUpWindow(_stallPanel);
			}
			
		}
		
		public function isStalling():Boolean{
			return selfStalling;
		}
		
		private var selfStalling:Boolean = false;
		
		private var employTime:int; // hour
		private var continueEmploy:Boolean;
		/**
		 * 雇佣店小二 
		 * @param salaryTime
		 * 
		 */		
		public function requstSalaryTime(salaryTime:int,isGoOn:Boolean=false):void
		{
			employTime = salaryTime;
			continueEmploy = isGoOn;
			var vo:m_stall_employ_tos = new m_stall_employ_tos();
			vo.hour = salaryTime;
			this.sendSocketMessage(vo);
		
		}
		
		private function employResult(msg:m_stall_employ_toc):void
		{
			if(!msg.succ)
			{
//				if(continueEmploy)
//				{
					Alert.show(msg.reason,"提示：",null,null,"确定","",null,false);
//				}
				return;
			}
			
			// 先收摊　再　雇佣摆!
			if(!continueEmploy)   //非续期!
			{
				
				var map_stall:p_map_stall = new p_map_stall();
				map_stall.role_id = GlobalObjectManager.getInstance().user.base.role_id;
				this.dispatch(ModuleCommand.DEAL_STALL_END,map_stall);
				
				var map_stall_vo:p_map_stall = new p_map_stall();
				map_stall_vo.mode = 1;//selfStallVo.mode;
				map_stall_vo.pos = null;
				map_stall_vo.role_id = GlobalObjectManager.getInstance().user.base.role_id;
//				map_stall_vo.role_name = GlobalObjectManager.instance.user.rolename;
				map_stall_vo.stall_name = _stallPanel.stallName;//selfStallVo.name;
				this.dispatch(ModuleCommand.DEAL_STALL_START,map_stall_vo);
			}
			
			_stallPanel.removeSalary();
			
//			var silver_bind:int = GlobalObjectManager.instance.user.attr.silver_bind ;
//			var silver:int = GlobalObjectManager.instance.user.attr.silver;
//			var cost:int = DealConstant.EMPLOY_P_HOUR * employTime;
			var str:String = "成功雇佣店小二";
			if(msg.bind_silver>0)//(silver_bind < cost)
			{
				todoChangeMoney(-msg.bind_silver,DealConstant.STALL_PRICE_TYPE_SILVER_BIND);
				str += ",扣除绑定银子："+ DealConstant.silverToOtherString(msg.bind_silver);
				
			}
			if(msg.silver>0){
				
				todoChangeMoney(-msg.silver, DealConstant.STALL_PRICE_TYPE_SILVER);
				str += ", 扣除银子："+DealConstant.silverToOtherString(msg.silver);
					
			}
			str += "。";
			BroadcastSelf.logger(str);
			
//			_stallPanel.salaryReturn(0,employTime);//雇佣或续期成功　本来是前端自己处理不请求
			requestStallSelf();　　//请求自己摊位数据，　不自己处理了！
		}
		
		/**
		 * 取钱 
		 * 
		 */		
		public function getStallMoney():void
		{
			var vo:m_stall_extractmoney_tos = new m_stall_extractmoney_tos();
			this.sendSocketMessage(vo);
			
		}
		/**
		 * 取钱返回 
		 * @param msg
		 * 
		 */		
		private function extractMoney(msg:m_stall_extractmoney_toc):void
		{
			if(!msg.succ)
			{
				Alert.show(msg.reason,"提取失败：",null,null,"确定","",null,false);
				return;
			}
			var tax:String = DealConstant.silverToOtherString(msg.tax);
			var silver:int = msg.silver;
			var addMoney:String = DealConstant.silverToOtherString(msg.silver);
			
			var str:String = "";
			if (msg.gold > 0 && msg.silver > 0) {
				str += "扣除税收"+ tax +"，你获得元宝：" + msg.gold + "元宝，银子：" + addMoney;
			} else if (msg.gold > 0 && msg.silver <= 0) {
				str += "你获得" + msg.gold + "元宝";
			} else {
				str += "扣除税收"+ tax +"，你获得银子：" + addMoney;
			}
			
			Alert.show(str, "提取成功：",null,null,"确定","",null,false);
			
			todoChangeMoney(msg.silver, DealConstant.STALL_PRICE_TYPE_SILVER);
			todoChangeMoney(msg.gold, DealConstant.STALL_PRCIE_TYPE_GOLD);
			
			_stallPanel.getMoneyReturn(msg);
		}
		
		private var moveGoodsVo:m_stall_move_tos;
		private var srcPosition:int;
		private var desPosition:int;
		/**
		 *  物品移动位置  
		 * @param goodsId
		 * @param pos
		 * @param srcPos   原来的位置，失败时可以返回
		 * 
		 */		
		public function swapGoods(goodsId:int,pos:int,srcPos:int):void
		{
			var vo:m_stall_move_tos = new m_stall_move_tos();
			vo.goodsid = goodsId;
			vo.pos = pos;
			srcPosition = srcPos;
			desPosition = pos;
			moveGoodsVo = vo;
			this.sendSocketMessage(vo);
			
		}
		
		private function swapItemResult(vo:m_stall_move_toc):void
		{
//			vo.reason;vo.succ
			var bsitem:BaseItemVO ;
			
			if(!vo.succ)
			{
				
//				BroadcastSelf.logger("<font color='#ff0000'>移动物品失败：" + vo.reason + "</font>");
				Alert.show(vo.reason,"移动物品失败：",null,null,"确定","",null,false);
				
			}else{
				
				if(_stallPanel)
				{
					bsitem = _stallPanel.getGoodsVoById(moveGoodsVo.goodsid);
					_stallPanel.setTileContent(srcPosition,null,null);
					_stallPanel.setTileContent(desPosition,null,bsitem); 
					
				}else if(_handleStallPanel)
				{
					bsitem = _handleStallPanel.getGoodsVoById(moveGoodsVo.goodsid);
					_handleStallPanel.setTileContent(srcPosition,null,null); 
					_handleStallPanel.setTileContent(desPosition,null,bsitem); 
				}
			}
			
		}
		
		
		/**
		 * 收摊了！ 
		 * 
		 */		
		public function finishStall():void
		{
			var vo:m_stall_finish_tos = new m_stall_finish_tos();
			this.sendSocketMessage(vo);
		}
		
		private function finishStallResult(vo:m_stall_finish_toc):void
		{
			var map_stall:p_map_stall = new p_map_stall();
			map_stall.role_id = vo.role_id;
			
			
			if(!vo.return_self)
			{
				// to do  其它人收摊  要不要  摆摊模块 通知 场景 呢 ？
				this.dispatch(ModuleCommand.DEAL_STALL_END, map_stall);
				
				if(_otherStall)
				{
					closeOtherStall();
				}
				return;
			}
			
			if(vo.succ)
			{			
				OperateMode.getInstance().removeMode(OperateMode.BT_MODE);  //作用：解除背包物品的不可操作状态
				PackManager.getInstance().setBtButtonFilter(0);
				
				if(_stallPanel)
				{
					WindowManager.getInstance().removeWindow(_stallPanel);
				}
				if(vo.time_over)
				{
					BroadcastSelf.logger("你的店小二摊位已经过期！");
					return;
				}
				
				//  trace("...收摊成功 ...");
				if(vo.bind_silver>0)
				{
					BroadcastSelf.logger("由于雇佣时间提前结束，扣除已消耗雇佣金后，您获得"  + DealConstant.silverToOtherString(vo.bind_silver)　
						+"绑定银子的雇佣金返款。");
					
					//"由于雇用时间提前结束，扣除已消耗雇佣金后，您获得A银子的雇佣金返款"
					
				}else if(vo.silver>0){
					
					BroadcastSelf.logger("由于雇佣时间提前结束，扣除已消耗雇佣金后，您获得"  + DealConstant.silverToOtherString(vo.silver)　
						+"银子的雇佣金返款。");
				}
				
				
				BroadcastSelf.logger("收摊成功，卖出所得元宝：" + vo.get_gold + "元宝，银子："+ DealConstant.silverToOtherString(vo.get_silver));
					
				if(vo.get_silver>0||vo.silver>0)
				{
					var addMoney:int = vo.get_silver +  vo.silver;
					todoChangeMoney(addMoney, DealConstant.STALL_PRICE_TYPE_SILVER);
				}
				if(vo.bind_silver>0){
					
					todoChangeMoney(vo.bind_silver, DealConstant.STALL_PRICE_TYPE_SILVER_BIND);
				}
				if (vo.get_gold > 0) {
					todoChangeMoney(vo.get_gold, DealConstant.STALL_PRCIE_TYPE_GOLD);
				}
				
				selfStalling= false;
				
				
			}else{
				
				//  trace("收摊不成功 ...");
				Alert.show(vo.reason,"失败提示：",null,null,"确定","",null,false);
			}
		}
		
		
		/**
		 * 查看他人的摊位 
		 * 
		 */		
		private function requestStallOther(role_id:int):void
		{
//			var role_id :int = msg.data as int;
			
			var vo:m_stall_detail_tos = new m_stall_detail_tos();
			vo.role_id = role_id;
			this.sendSocketMessage(vo);
			
			//  trace(" 查看他人的摊位  ");
		}
		
		private var _otherStall:OtherStallPanel;
		private function showOtherStall(vo:m_stall_detail_toc):void
		{
			if(!vo)
				return;
			if(!_otherStall)
			{
				_otherStall = new OtherStallPanel();
				_otherStall.x = 250;
				_otherStall.y = 88;
				
				WindowManager.getInstance().popUpWindow(_otherStall);
				_otherStall.addEventListener(CloseEvent.CLOSE,closeOtherStall);
				
			}
			if(_buywindow)
			{
				closeBuyWindow();
			}
			
			if(_stallPanel)
			{
				WindowManager.getInstance().removeWindow(_stallPanel);
//				_stallPanel.removeEventListener(CloseEvent.CLOSE,closeStallHandler);
//				_stallPanel.dispose();
//				_stallPanel = null;
			}
			if(_handleStallPanel)
			{
				closeHandleringPanel()
			}
			
			_otherStall.setDatas(vo);
		}
		
		/**
		 * 打开购买面板 
		 */		
		private var _buywindow:StallBuyWindow;
		public function openBuyWindow(ownerID:int, pos:int,vo:BaseItemVO):void
		{
			if(!_buywindow)
			{
				_buywindow = new StallBuyWindow();
				_buywindow.x = 320;
				_buywindow.y = 100;
				
//				WindowManager.getInstance().popUpWindow(_buywindow);
				WindowManager.getInstance().openDialog(_buywindow);
				
				_buywindow.addEventListener(CloseEvent.CLOSE,closeBuyWindow);
				
			}
			
			_buywindow.setGoodsVo(ownerID,pos,vo);
		}
		
		private var buy_tos:m_stall_buy_tos;
		private var bsItemVo:BaseItemVO;
		/**
		 * 购买物品 
		 * @param roleID    摊主的roleId
		 * @param goodsID
		 * @param num
		 * 
		 */		
		public function requestBuy(roleID:int,goodsID:int,num:int,currentPrice:int):void
		{
			if(buy_tos)
			{
				buy_tos = null;
			}
			buy_tos = new m_stall_buy_tos();
			buy_tos.goods_id = goodsID;
			buy_tos.role_id = roleID;
			buy_tos.number = num;
			buy_tos.goods_price = currentPrice;
			buy_tos.buy_from = 1;
			bsItemVo = _otherStall.getGoodsVoById(goodsID);
			this.sendSocketMessage(buy_tos);
		}
		
		public function buyResult(msg:m_stall_buy_toc):void
		{
			// to do 
			
			if(!msg.succ)
			{
				Alert.show(msg.reason, "提示",null,null,"确定","",null,false);
				if(msg.stall_finish)
				{
					if(_otherStall)
					{
						closeOtherStall();
					}
					return;
				}
				
				if (_otherStall)
					requestStallOther(_otherStall.getRoleId());
				return;
			}
			if(msg.return_self)
			{
				if(!buy_tos)
					return;
				
				if(bsItemVo) //通知改变钱　　角色模块的钱
				{
					var coast:int = bsItemVo.unit_price * buy_tos.number;
					todoChangeMoney(-coast, bsItemVo.price_type);
				}

				msg.goods_id = buy_tos.goods_id;
				msg.num = buy_tos.number;
				msg.role_id = GlobalObjectManager.getInstance().user.base.role_id;
				msg.role_name = GlobalObjectManager.getInstance().user.base.role_name;
				buy_tos = null;
			}
			
			//成功购买，
			if(_otherStall)
			{
				_otherStall.receiveBuyMsg(msg);
			}
			else if(_stallPanel)
			{
				requestStallSelf();
				//var vo:m_stall_open_tos
			}
			
			closeBuyWindow();
			
		}
		
		private function todoChangeMoney(changeMoney:int, moneyType:int):void
		{
			if(!changeMoney||changeMoney==0)
				return;
			
			var mType:String;
			if(moneyType == DealConstant.STALL_PRICE_TYPE_SILVER)
			{
				mType = DealConstant.SILVER; // RoleStateConstant.SILVER;
			} else if (moneyType == DealConstant.STALL_PRCIE_TYPE_GOLD) {
				mType = DealConstant.GOLD;
			} else {
				mType = DealConstant.SILVER_BIND;
			}
			
			var obj:Object = new Object();
			obj.num = changeMoney;
			obj.moneyType = mType;		
			setStallMoney(obj);
		}
		
		private function setStallMoney(moneyObj:Object):void
		{
			var moneyNum:int=(moneyObj.num as int);
			switch (moneyObj.moneyType)
			{
				case DealConstant.GOLD:
					GlobalObjectManager.getInstance().user.attr.gold=GlobalObjectManager.getInstance().user.attr.gold + moneyNum;
					break;
				case DealConstant.SILVER:
					GlobalObjectManager.getInstance().user.attr.silver=GlobalObjectManager.getInstance().user.attr.silver + moneyNum;
					break;
				case DealConstant.SILVER_BIND:
					GlobalObjectManager.getInstance().user.attr.silver_bind=GlobalObjectManager.getInstance().user.attr.silver_bind + moneyNum;
					break;
				default:
					break;
			}
			changeMoney();
		}
		
		
		
		/**
		 * 发送摊位界面留言 
		 * @param to_role_id
		 * @param conten
		 * 
		 */		
		public function sendMsg(to_role_id:int, conten:String):void
		{
			var vo:m_stall_chat_tos = new m_stall_chat_tos();
			vo.target_role_id = to_role_id;
			vo.content = conten;
			this.sendSocketMessage(vo);
			
		}
		
		/**
		 * 接收留言 
		 * @param vo
		 * 
		 */		
		private function receiveMsg(vo:m_stall_chat_toc):void
		{
			if(vo.return_self)
			{
				if(!vo.succ)
				{
					Tips.getInstance().addTipsMsg("留言失败："+vo.reason);//,"留言失败："
					return ;
				}
				Tips.getInstance().addTipsMsg("成功给摊主留言");
				if(_otherStall)
				{
					
					_otherStall.receiveMsg(vo);
				}
			}else{
				
				if(_stallPanel)
				{
					_stallPanel.receiveMsg(vo);
				}
//				if(_otherStall)
//				{
//					_otherStall.receiveMsg(vo);
//				}
			}
		}
		
		public function getGoodsVoBuyId(goods_id:int):BaseItemVO //为了应付　buy里的 没有 goods_name　goods_id
		{
			if(_stallPanel)
			{
				return _stallPanel.getGoodsVoById(goods_id);
				
			}else if(_otherStall)
			{
				return _otherStall.getGoodsVoById(goods_id);
			}
			
			return null;
		}
		
		
		public function requestSearch(page:int = 1):void
		{
			var vo:m_stall_list_tos = new m_stall_list_tos();
			vo.page = page;
			this.sendSocketMessage(vo);
		}
		private var _searchPanel:SearchPanel;
		/**
		 * 搜索面板 
		 * 
		 */		
		public function openSearchPanel(vo:m_stall_list_toc):void
		{
			if(!_searchPanel)
			{
				_searchPanel = new SearchPanel();
				_searchPanel.x = 250;
				_searchPanel.y = 88;
				
				WindowManager.getInstance().popUpWindow(_searchPanel);
//				sendToUIManager(_searchPanel);
				_searchPanel.addEventListener(CloseEvent.CLOSE,closeSearchHandler);
			}
			
			_searchPanel.setDatas(vo);
		}
		
		
		public function walkToStall(vo:p_stall_info):void
		{
			var pos:p_pos = new p_pos();
			pos.tx = vo.tx;
			pos.ty = vo.ty;
			
//			var getter:Vector.<int> = new Vector.<int>;
//			getter.push(ModelConstant.SCENE_MODEL);
//			
//			var body:MessageBody = new MessageBody();
//			body.setUp(null,null,requestStallOther,vo.role_id);        // requestStallOther  请求某个　id 的摊位信息
//			
//			
//			var message:IMessage = model.createMessage(MessageConstant.MODEL_TO_MODEL,MessageConstant.CALL,getter,body);
//			message.name = DealActionType.STALL_WALK_TO.toString();
//			message.data = pos;
//			model.send(message);
			this.dispatch(ModuleCommand.DEAL_STALL_WALK_TO.toString(),pos);
		}
		
		private var getGoodId:int;
		public function getOut(bsItemVo:BaseItemVO,bagId:int,pos:int):void  // request  goods_id:int
		{
			if(_handleStallPanel)
			{
				PackManager.getInstance().lockGoods(bsItemVo,false);
			}
			var vo:m_stall_getout_tos = new m_stall_getout_tos();
			vo.goods_id = bsItemVo.oid;
			vo.bagid = bagId;
			vo.pos = pos;
			getGoodId = bsItemVo.oid;
			this.sendSocketMessage(vo);
		}
		
		private function getOutReturn(vo:m_stall_getout_toc):void
		{
			if(vo.succ)
			{
				//  trace("  ..getout 成功..  ");
				if(_handleStallPanel)
				{
					_handleStallPanel.delItemById(getGoodId);
					
				}else if(_stallPanel)
				{
					_stallPanel.delItemById(getGoodId);
				}
			}
			else{
				
				//  trace("  ..getout 失败..  ");
				Alert.show(vo.reason,"失败提示：",handler,null,"确定","",null,false);
			}
		}
		private function handler():void
		{
//			if(_stallPanel)
//			{
				requestStallSelf();
				if(_handleStallPanel)
				{
					var item:BaseItemVO = PackManager.getInstance().getItemById(getGoodId);
					PackManager.getInstance().lockGoods(item,true);
				}
//			}
		}
		
		public function getAllBack():void
		{
			var vo:m_stall_getall_tos = new m_stall_getall_tos();
			this.sendSocketMessage(vo);
			if(priceUi){
				priceUiClose();
			}
		}
		
		public function getAllBackResult(vo:m_stall_getall_toc):void
		{
			if(vo.succ)
			{
				//  trace("。。。清空成功。。。");
				Tips.getInstance().addTipsMsg("清空成功");
//				Tips.getInstance().addTipsMsg("。。。清空成功。。。");
				_handleStallPanel.sendAllToPackage();
			}else{
				
				//  trace("。。。清空失败。。。");
				Alert.show(vo.reason,"清空失败：");
			}
		}
		
		private function closeHandleringPanel(evt:WindowEvent=null):void
		{
			//  要把已经放上来的东西 原数 原位 发回给 背包。
			//不发回背包了，　物品还剩在这个界面上。　如果该实例还在，下次请求直接打开，　不在则还要判断　赋值。
			
//			_handleStallPanel.sendAllToPackage();
			
			OperateMode.getInstance().removeMode(OperateMode.BT_MODE);
			
//			if(GlobalObjectManager.instance.user.base.status==RoleActState.TRAINING
//				|| GlobalObjectManager.instance.user.base.status==RoleActState.ON_HOOK){
//				return;
//			}
			var map_stall:p_map_stall = new p_map_stall();
			map_stall.role_id = GlobalObjectManager.getInstance().user.base.role_id;
			this.dispatch(ModuleCommand.DEAL_STALL_END,map_stall);
		}
		
		private function　closeSearchHandler(evt:CloseEvent):void
		{
			WindowManager.getInstance().removeWindow(_searchPanel);
			
			_searchPanel.dispose();
			_searchPanel = null;
			
		}
		
		private function closeStallHandler(evt:WindowEvent = null):void
		{
			if (!selfStalling)
				OperateMode.getInstance().removeMode(OperateMode.BT_MODE);
			
			_stallPanel.removeEventListener(WindowEvent.CLOSEED, closeStallHandler);
			_stallPanel.dispose();
			
			_stallPanel = null;
			
		}
		
		public function closeOtherStall(evt:CloseEvent=null):void
		{
			if(_otherStall)
			{
				WindowManager.getInstance().removeWindow(_otherStall);
				_otherStall.dispose();
				_otherStall = null;
			}
			closeBuyWindow();
		}
		
		public function closeBuyWindow(evt:CloseEvent = null):void
		{
			if(!_buywindow)
			{
				return;
			}
			
			WindowManager.getInstance().closeDialog(_buywindow);
			_buywindow.removeEventListener(CloseEvent.CLOSE, closeBuyWindow);
			_buywindow.dispose();
			
			_buywindow = null;
		}
			
		public var _dealItemArr:Array = [];
		public function get dealItemArr():Array
		{
			return _dealItemArr;
		}
		
		public function get dealPanle():DealPanle
		{
			if(_dealPanle)
			{
				return _dealPanle;
			}
			return null;
		}
		
	}
}