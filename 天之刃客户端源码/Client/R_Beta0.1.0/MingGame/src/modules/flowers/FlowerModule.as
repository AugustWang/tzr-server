package modules.flowers
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.components.menuItems.TargetRoleInfo;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	
	import flash.utils.setTimeout;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;
	import modules.flowers.views.HuaQuan;
	import modules.flowers.views.RecieveView;
	import modules.flowers.views.SendFlowerView;
	import modules.flowers.views.ToWhoInput;
	import modules.mypackage.vo.BaseItemVO;
	import modules.system.SystemConfig;
	
	import proto.common.p_role_base;
	import proto.line.m_flowers_accept_toc;
	import proto.line.m_flowers_accept_tos;
	import proto.line.m_flowers_get_accept_list_toc;
	import proto.line.m_flowers_get_recever_info_toc;
	import proto.line.m_flowers_get_recever_info_tos;
	import proto.line.m_flowers_give_faction_broadcast_toc;
	import proto.line.m_flowers_give_map_broadcast_toc;
	import proto.line.m_flowers_give_toc;
	import proto.line.m_flowers_give_tos;
	import proto.line.m_flowers_give_world_broadcast_toc;
	import proto.line.m_flowers_update_accept_toc;
	import proto.line.p_flowers_give_info;
	
	public class FlowerModule extends BaseModule
	{
		public function FlowerModule(){
			FlowersTypes.loadData();
		}
		
		private static var instance:FlowerModule;
		
		public static function getInstance():FlowerModule
		{
			if (instance == null)
			{
				instance=new FlowerModule();
			}
			return instance;
		}
		
		override protected function initListeners():void{
			//服务端消息
			this.addSocketListener(SocketCommand.FLOWERS_GET_ACCEPT_LIST,acceptList_toc);
			this.addSocketListener(SocketCommand.FLOWERS_GIVE,send_return_toc);
			this.addSocketListener(SocketCommand.FLOWERS_ACCEPT, accepted_toc);
			this.addSocketListener(SocketCommand.FLOWERS_UPDATE_ACCEPT,recieveflowerHandler);
			this.addSocketListener(SocketCommand.FLOWERS_GIVE_WORLD_BROADCAST,recieveWorldBroadcast);
			this.addSocketListener(SocketCommand.FLOWERS_GIVE_FACTION_BROADCAST,recieveFactionBroadcast);
			this.addSocketListener(SocketCommand.FLOWERS_GIVE_MAP_BROADCAST,recieveMapBroadcast);
			this.addSocketListener(SocketCommand.FLOWERS_GET_RECEVER_INFO,toWhoReturn_toc);
			
			//模块消息
			this.addMessageListener(ModuleCommand.OPEN_FLOWER_VIEW,initSendFlowerView);
			this.addMessageListener(ModuleCommand.USE_FLOWER_GOODS,sendToWhowView);
			this.addMessageListener(ModuleCommand.CONFIG_CHANGED,onConfigChange);
			 
		} 
		
		private var listlen:int;
		private function acceptList_toc(vo:m_flowers_get_accept_list_toc):void
		{
			if(vo&&vo.list.length>0)
			{
				recieveL = vo.list;
				listlen = vo.list.length;
				setTimeout(openflowerRecPanel,500);
			}
		}
		
		//双击花出来的东西。。。
		//to do 　需要 id  （type_id　或者　name ）。　
		private var toWhoView:ToWhoInput;
		private var goods_id:int;          
		private var types_id:int;
		public function sendToWhowView(vo:BaseItemVO):void
		{
			goods_id = vo.oid;
			types_id = vo.typeId;
			if(!toWhoView)
			{
				toWhoView = new ToWhoInput();
				toWhoView.x = 350;
				toWhoView.y = 210;
			}
			WindowManager.getInstance().popUpWindow(toWhoView);
			WindowManager.getInstance().centerWindow(toWhoView);
		}
		
		public function requestToWhow_tos(toWho:String):void
		{
			var vo:m_flowers_get_recever_info_tos = new m_flowers_get_recever_info_tos();
			vo.role_name = toWho;
			
			sendSocketMessage(vo);
		}
		
		private var roleInfo:TargetRoleInfo;
		private function toWhoReturn_toc(vo:m_flowers_get_recever_info_toc):void
		{
			if(vo.succ)
			{
				var voInfo:p_role_base = vo.rolebase;
				if(roleInfo)
					roleInfo = null;
				
				roleInfo = new TargetRoleInfo(); 
				var num:int;
				if(types_id !=0)
					num= FlowersTypes.getNumByType(types_id);
				
				roleInfo.roleId = voInfo.role_id;
				roleInfo.roleName = voInfo.role_name;
				roleInfo.sex = voInfo.sex;
				
				openSendFlowerView();
				if(toWhoView)
				{
					if(toWhoView.parent)
					{
						WindowManager.getInstance().removeWindow(toWhoView);
					}
					toWhoView = null;
				}
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
			
		private function openSendFlowerView():void
		{
			if(!sendView)
			{
				sourceLoader = new SourceLoader();
				var url:String = GameConfig.ROOT_URL+"com/assets/flowers/flowers.swf";
				SendFlowerView.flowerBg_URL = url;
				var msg:String = "加载鲜花界面资源...";
				sourceLoader.loadSource(url,msg,showSendView);
			}
		}
		private function showSendView():void
		{
			var num:int;
			if(!sendView)
			{
				sendView = new SendFlowerView();
				sendView.x = 300;
				sendView.y = 117;
				sendView.initView(sourceLoader);
				sendView.addEventListener(CloseEvent.CLOSE,closeSendView);
			}
			WindowManager.getInstance().popUpWindow(sendView);
			WindowManager.getInstance().centerWindow(sendView);
			
			if(types_id!=0)
			{
				num= FlowersTypes.getNumByType(types_id);
				sendView.sendUseGoods(roleInfo,num);
				types_id = 0;
			}else{
				
				sendView.sendFlower(roleInfo);
			}
		}
		
		
		private var sendView:SendFlowerView;
		public function initSendFlowerView(roleInfo:TargetRoleInfo):void
		{
			var vo:m_flowers_get_recever_info_tos = new m_flowers_get_recever_info_tos();
			vo.role_name = roleInfo.roleName;
			sendSocketMessage(vo);
		}
		
		
		public function send_tos(to_role_id:int,niMing:Boolean,goodsTypes:int=0):void
		{
			var vo:m_flowers_give_tos = new m_flowers_give_tos();
			vo.rece_role_id = to_role_id;
			vo.flowers_type = goodsTypes;
			vo.goods_id = goods_id;
			vo.is_anonymous = niMing;
			goods_id=0;
			sendSocketMessage(vo);
		}
		private function send_return_toc(vo:m_flowers_give_toc):void
		{
			if(vo.succ)
			{
				BroadcastSelf.logger(vo.tips);
				closeSendView();
			}else
			{
				if(vo.is_buy)
				{
					//鲜花数量不足，
					//Alert.show(vo.tips+"<a href='event:openShopFlower'><u>点击到商店购买</u></a>","提示",null,null,"确定","",null,false);
					Alert.show("背包中没有你要赠送的鲜花","提示",null,null,"确定","",null,false);
				}else
				{
					Alert.show(vo.tips,"提示",null,null,"确定","",null,false);
				}
				
			}
		}
		
		private var recieveL:Array=[];
		private var recieveV:RecieveView;
		private function recieveflowerHandler(vo:m_flowers_update_accept_toc):void
		{
			if(!vo)
			{
				return;
			}
			var give_info:p_flowers_give_info = vo.info;
			if(!give_info)
				return;
			
			recieveL.push(vo.info);
			
			if(vo.info.flowers_type == FlowersTypes.getTypeByNum(1) && recieveL.length==1)
			{
				openflowerRecPanel();
			}
		}
		
		private var sourceLoader:SourceLoader;
		public function openflowerRecPanel():void
		{
			if(!recieveV)
			{
				sourceLoader = new SourceLoader();
				var url:String = GameConfig.ROOT_URL+"com/assets/flowers/flowers.swf";
				var msg:String = "加载鲜花界面资源...";
				sourceLoader.loadSource(url,msg,showRecieveView);
			}else{
				showRecieveView();
			}
		}
		
		private var quanLoader:SourceLoader;
		private var huaquan:HuaQuan;
		public function showRecieveView():void
		{
			if((isAccepToc && isQuanOver))
			{
				if(recieveL.length>0)
				{
					var recieveInfo:p_flowers_give_info = recieveL[0] ;
					if(!recieveV)
					{
						recieveV = new RecieveView();
						recieveV.x = 300;
						recieveV.y = 117;
						recieveV.initView(sourceLoader);
						sourceLoader = null;
					}
					WindowManager.getInstance().popUpWindow(recieveV, WindowManager.UNREMOVE);
					WindowManager.getInstance().centerWindow(recieveV);
					recieveV.setData(recieveL[0]);
					
					isAccepToc =false;
					
					if(FlowersTypes.getNumByType(recieveInfo.flowers_type)==999)
					{
						setTimeout(showHuaQuan,500);
						isQuanOver = false;
					}
				}
			}
		}
		
		public function showHuaQuan():void
		{
			if(!huaquan)
			{
				huaquan = new HuaQuan();
			}
			huaquan.initView();
			LayerManager.uiLayer.addChildAt(huaquan,0)
		}
		
		private function recieveWorldBroadcast(vo:m_flowers_give_world_broadcast_toc):void
		{
			if(vo)
			{
				FlowersTypes.addWorldBroadcast(vo);
				
			}
			if(listlen == 0)
			{
				FlowersBroacastManager.getInstance().playFlowers();
			}
		}
		
		private function recieveFactionBroadcast(vo:m_flowers_give_faction_broadcast_toc):void
		{
			if(vo)
			{
				FlowersTypes.addFactionBroadcast(vo);
				
			}
			if(listlen == 0)
			{
				FlowersBroacastManager.getInstance().playFlowers();
			}
		}
		private function recieveMapBroadcast(vo:m_flowers_give_map_broadcast_toc):void
		{
			if(vo)
			{
				FlowersTypes.addMapBroadcast(vo);
				
			}
			if(listlen == 0)
			{
				FlowersBroacastManager.getInstance().playFlowers();
			}
			
		}
		
		////回复的类型，1:联系，2:谢谢，3:回吻   // 点　x 回复　2：谢谢
		public function accept_tos(id:int,sender:String,replyId:int=2):void
		{
			var vo:m_flowers_accept_tos = new m_flowers_accept_tos();
			vo.id = id;
			vo.reply_id = replyId;
			if(replyId==4)
			{
				vo.reply_id = 2;
			}
			
			sendSocketMessage(vo);
			
			
			switch(replyId)
			{
				case 1:
					if(sender == GlobalObjectManager.getInstance().user.base.role_name)
					{
						
					}else{
						ChatModule.getInstance().priChatHandler(sender);
					}
					break;
				case 2:
					if(sender == GlobalObjectManager.getInstance().user.base.role_name)
					{
						
					}else{
					
						ChatModule.getInstance().chat.pre_private_msg = FlowersTypes.REPYTYPE2+"";
						ChatModule.getInstance().priChatHandler(sender);
					}
					break;
				case 3:
					ChatModule.getInstance().chat.pre_private_msg = FlowersTypes.REPYTYPE3+"";
					ChatModule.getInstance().priChatHandler(sender);
					break;
				default: break;
			}
			
			recieveL.shift();
			if(listlen>0)
				listlen--;
			if(listlen == 0)
			{
				FlowersBroacastManager.getInstance().playFlowers();
			}
		}
		
		private function accepted_toc(vo:m_flowers_accept_toc):void
		{
			if(!vo.succ)
			{
				BroadcastSelf.logger("回复失败。");
				return;
			}
			
			ChatModule.getInstance().chat.resetEchoTimes();
			isAccepToc = true;
			var info:p_flowers_give_info
			if(recieveL.length> 0)
			{
				info = recieveL[0] as p_flowers_give_info;
				
				if(info.flowers_type == FlowersTypes.getTypeByNum(1)||listlen>0)
				{
					openflowerRecPanel();
				}
				else if(listlen == 0)
				{
					FlowersBroacastManager.getInstance().playFlowers();
				}
			}
		}
		public var isAccepToc:Boolean = true;
		public var isQuanOver:Boolean = true;
		
		public function closeSendView(e:CloseEvent= null):void
		{
			if(sendView)
			{
				sendView.removeEventListener(CloseEvent.CLOSE,closeSendView);
				if(sendView.parent)
					WindowManager.getInstance().removeWindow(sendView);
				sendView.dispose();
				sendView = null;
			}
		}
		
		private function onConfigChange():void
		{
			if(!SystemConfig.openEffect)
			{
				FlowersBroacastManager.getInstance().closeEffect();
			}
		}
	}
}


