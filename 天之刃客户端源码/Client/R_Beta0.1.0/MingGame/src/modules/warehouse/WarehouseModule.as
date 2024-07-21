package modules.warehouse
{
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.warehouse.views.WarehousePanel;
	
	import proto.common.p_goods;
	import proto.line.m_depot_destroy_toc;
	import proto.line.m_depot_destroy_tos;
	import proto.line.m_depot_divide_toc;
	import proto.line.m_depot_divide_tos;
	import proto.line.m_depot_dredge_toc;
	import proto.line.m_depot_dredge_tos;
	import proto.line.m_depot_get_goods_toc;
	import proto.line.m_depot_get_goods_tos;
	import proto.line.m_depot_swap_toc;
	import proto.line.m_depot_swap_tos;
	import proto.line.m_depot_tidy_toc;
	import proto.line.m_depot_tidy_tos;
	import proto.line.p_depot_bag;
	
	public class WarehouseModule extends BaseModule
	{
		private var _warehouse:WarehousePanel;
		
		public var isVipOpen:Boolean = false;
		public var hash:Dictionary;
		public var depotNum:int = 0;
		public var firstdepotId:int = 6;
		public var hashId:int=1;        //当前操作的 仓库 id 
		
		private var _npcId:int;
		
		public function WarehouseModule()
		{
			
		}
		
		public function get warehouse():WarehousePanel
		{
			return _warehouse;
		}
		
		private static var instance:WarehouseModule;
		public static function getInstance():WarehouseModule
		{
			if(!instance)
			{
				instance = new WarehouseModule();
			}
			return instance;
		}
		
		override protected function initListeners():void{
			addSocketListener(SocketCommand.DEPOT_GET_GOODS,initDepotGoods);
			addSocketListener(SocketCommand.DEPOT_DREDGE,dredgeResult);
			addSocketListener(SocketCommand.DEPOT_SWAP,swapResult);
			addSocketListener(SocketCommand.DEPOT_DIVIDE,divideResult);
			addSocketListener(SocketCommand.DEPOT_DESTROY,destroyResult);
			addSocketListener(SocketCommand.DEPOT_TIDY,clearUpReturn);
			
			addMessageListener(NPCActionType.NA_31, onOpenWareHouse);
		}
		
		/**
		 * 设置仓库标签，在仓库已经打开情况下
		 */
		
		public function setSelectIndex(index:int):void
		{
			if (_warehouse)
				_warehouse.selectIndex(index);
		}
		
		public function openWareHouse(npcId:int):void
		{
			if (npcId == 0) {
				isVipOpen = true;
			}
			
			if(!_warehouse)
			{
				_warehouse = new WarehousePanel();
				_warehouse.x = 330;
				_warehouse.y = 137;
				_warehouse.addEventListener(CloseEvent.CLOSE, closeWarehouse);
			}

			if (WindowManager.getInstance().isPopUp(_warehouse)) {
				WindowManager.getInstance().removeWindow(_warehouse);
				isVipOpen = false;
			} else {
				if(npcId == 0){
					WindowManager.getInstance().popUpWindow(_warehouse);
				}else{
					WindowManager.getInstance().openDistanceWindow(_warehouse);
				}
				PackManager.getInstance().popUpWindow(PackManager.PACK_1,(_warehouse.x + _warehouse.width)>>0,_warehouse.y >> 0,false);
				_warehouse.onOpenPanel();
				
				hashId = 6;
				if (hash && hash[6]) {
					_warehouse.setGoodsData(hash[6]);
				} else {
					_npcId = npcId;
					
					var vo:m_depot_get_goods_tos = new m_depot_get_goods_tos();
					vo.npcid = npcId;
					vo.depot_id = 6;
					sendSocketMessage(vo);
				}
			}
		}
		
		private function onOpenWareHouse(vo:NpcLinkVO):void
		{
			openWareHouse(vo.npcID);	
		}
		
		public function closeWarehouse(e:CloseEvent = null):void
		{
			isVipOpen = false;
		}
		
		/**
		 * 拿其它仓库里的数据，前端保存了！ 
		 * @param depotId
		 * 
		 */		
		public function requestDepotGoods(depotId:int):void
		{
			hashId = 5 + depotId;
			if (hash && hash[5+depotId]) {
				_warehouse.setGoodsData(hash[hashId]);
			} else {
				var vo:m_depot_get_goods_tos = new m_depot_get_goods_tos();
				vo.npcid = _npcId;
				vo.depot_id = hashId;
				sendSocketMessage(vo);
			}
		}
		
		private function initDepotGoods(vo:m_depot_get_goods_toc):void
		{
			var depot:p_depot_bag = vo.depots[0] as p_depot_bag;
			
			if(!hash)
			{
				hash = new Dictionary();
 			}
			saveGoods(depot.bagid, depot.goods_list);	
			
			depotNum = vo.depot_num;
			_warehouse.initTabBar(vo.depot_num);
			_warehouse.setGoodsData(depot.goods_list);
			
		}
		
		//整理背包。
		public function clearUp():void
		{
			var vo:m_depot_tidy_tos = new m_depot_tidy_tos();
			vo.bagid = hashId;//  1001   ;//
			sendSocketMessage(vo);
		}
		
		private function clearUpReturn(vo:m_depot_tidy_toc):void
		{
			if(vo.succ)
			{
				saveGoods(vo.bagid,vo.goods_list);
				_warehouse.setGoodsData(vo.goods_list);
			}else{
				
				BroadcastSelf.logger("<font color='#ff0000'>提示：整理失败。</font>");
			}
		}

		/**
		 * 开通新的仓库  
		 * @param depotId  仓库 ID
		 * 
		 */		
		public function depotDredge(depotId:int):void
		{
			var vo:m_depot_dredge_tos = new m_depot_dredge_tos();
			vo.bagid = firstdepotId + depotId ;
			sendSocketMessage(vo);
		}
		
		private function dredgeResult(vo:m_depot_dredge_toc):void
		{
			if(vo.succ)
			{
				trace("开通新的仓库成功！");
				hashId = firstdepotId + depotNum;
				
				depotNum += 1; 
				saveGoods(hashId,[]);
				_warehouse.addTabBar(depotNum);
				_warehouse.setGoodsData(hash[hashId]);
				
			}else{
				Alert.show(vo.reason,"开通新仓库失败！",null,null,"确定","",null,false);
				_warehouse.setPreIndex();
			}
		}
		
		/**
		 * 销毁物品 
		 * @param id   物品id
		 * 
		 */		
		public function depotDestroy(id:int):void
		{
			var vo:m_depot_destroy_tos = new m_depot_destroy_tos();
			vo.id = id;
			sendSocketMessage(vo);
		}

		/**
		 * 更新删除物品
		 * @param goods
		 *
		 */
		public function deleteGoods( goodsVO:p_goods ):void {
			if ( goodsVO && goodsVO.current_num == 0 ) {
				deleteRecodeByPos( goodsVO.bagposition );
				_warehouse.updateGoods( goodsVO.bagposition, null );
			}
		}
		
		private function destroyResult(vo:m_depot_destroy_toc):void
		{
			if(vo.succ)
			{
				//  trace("销毁成功！");
				var goods:p_goods = getGoodsById(vo.id);
				
				if(goods)
				{
					var item:BaseItemVO = PackageModule.getInstance().getBaseItemVO(goods);
					if(item)
					{
						var color:String = ItemConstant.COLOR_VALUES[item.color];
						BroadcastSelf.logger("成功丢弃"+ HtmlUtil.font("【"+ item.name + "】x "+item.num,color) );
					}
					deleteRecodeByPos(goods.bagposition);
					_warehouse.updateGoods(goods.bagposition, null);
				}
				
			}else{
				
				Alert.show(vo.reason,"销毁失败！",null,null,"确定","",null,false);
			}
		}
		/**
		 * 位置交换或者合并 
		 * @param srcGoodsId  原物品的 goods_id
		 * @param decPos      拖到的目标位置
		 * 
		 */			
		public function depotSwap(srcGoodsId:int,decPos:int):void
		{
			var vo:m_depot_swap_tos = new m_depot_swap_tos();
			vo.goodsid = srcGoodsId;
			vo.position = decPos;
			vo.bagid = hashId;
			sendSocketMessage(vo);
		}
		private function swapResult(vo:m_depot_swap_toc):void
		{
			if(!vo.succ)
			{
				Alert.show(vo.reason,"失败提示：",null,null,"确定","",null,false);
				
			}
			else{
				var baseItem1:BaseItemVO = PackageModule.getInstance().getBaseItemVO(vo.goods1);
				var baseItem2:BaseItemVO = PackageModule.getInstance().getBaseItemVO(vo.goods2);
				if(baseItem1)///(vo.goods1)
				{
					if(vo.goods1.bagid>=firstdepotId)
					{
						deleteRecodeByPos(vo.goods1.bagposition);
						addGoods(hashId,vo.goods1);
							
					}else{
							//
						PackManager.getInstance().updateGoods(vo.goods1.bagid,vo.goods1.bagposition,baseItem1);
							
					}
					
				}else{
					
					if(vo.goods1.bagid>=firstdepotId)
					{
						deleteRecodeByPos(vo.goods1.bagposition);
						_warehouse.updateGoods(vo.goods1.bagposition, baseItem1);
						
					}else{
						
						PackManager.getInstance().updateGoods(vo.goods1.bagid,vo.goods1.bagposition,baseItem1);
					}
				}
				
				if(baseItem2)
				{
					if(vo.goods2.bagid>=firstdepotId)
					{
						deleteRecodeByPos(vo.goods2.bagposition);
						addGoods(hashId,vo.goods2);
						
					}else{
						
						PackManager.getInstance().updateGoods(vo.goods2.bagid,vo.goods2.bagposition,baseItem2);
					}
					
				}else{
					
					if(vo.goods2.bagid>=firstdepotId)
					{
						deleteRecodeByPos(vo.goods2.bagposition);
						_warehouse.updateGoods(vo.goods2.bagposition, baseItem2);
						
					}else{
						
						PackManager.getInstance().updateGoods(vo.goods2.bagid,vo.goods2.bagposition,baseItem2);
					}
				}
				
			}
			
		}
		
		/**
		 * 拖入仓库 
		 * @param goodsId    物品id
		 * @param pos        放置物品的目标位置
		 * 
		 */			
		public function depotDrag(goodsId:int, pos:int):void
		{
			var vo:m_depot_swap_tos = new m_depot_swap_tos();   // m_depot_drag_tos();
			vo.bagid = hashId;  
			vo.goodsid = goodsId;
			vo.position = pos;
			sendSocketMessage(vo);
		}		
		/**
		 * 取出物品（双击） 
		 * @param goodsId
		 * @param pos
		 * 
		 */		
		public function takeOut(goodsId:int, pos:int, packId:int=-1):void
		{
			var vo:m_depot_swap_tos = new m_depot_swap_tos();
			vo.goodsid = goodsId;
			if(pos>0)
				vo.position = pos;
			if(packId>-1)
				vo.bagid = packId;
			sendSocketMessage(vo);
		}
				
		/**
		 * 拆分物品 
		 * @param goodsId      物品 oid
		 * @param pos          新物品要放入的位置
		 * @param num          拆出的个数
		 * 
		 */		
		public function depotDivide(goodsId:int,pos:int,num:int):void //depotId:int,
		{
			var vo:m_depot_divide_tos = new m_depot_divide_tos();
			vo.position = pos;
			vo.id = goodsId;
			vo.num = num;
			vo.bagid = hashId;
			sendSocketMessage(vo);
		}
		private function divideResult(vo:m_depot_divide_toc):void
		{
			if(!vo.succ)
			{
				Alert.show(vo.reason,"失败提示：",null,null,"确定","",null,false);
				if(vo.goods1)
				{
					var item:BaseItemVO = PackageModule.getInstance().getBaseItemVO(vo.goods1);
					_warehouse.updateGoods(vo.goods1.bagposition,item );
				}
			}
			else 
			{
				deleteRecodeByPos(vo.goods1.bagposition,vo.goods1.bagid);
				deleteRecodeByPos(vo.goods2.bagposition,vo.goods2.bagid);
				addGoods(vo.goods1.bagid,vo.goods1);
				addGoods(vo.goods2.bagid,vo.goods2);
				
			}
		}
		private function saveGoods(depotId:int,goods:Array):void
		{
			hash[depotId] = goods;
		}
		
		private function addGoods(depotId:int,goods:p_goods):void
		{
			if(goods)
			{
				var item:BaseItemVO = PackageModule.getInstance().getBaseItemVO(goods);
				var arr:Array = hash[depotId] as Array;
				arr.push(goods);
				hash[depotId] = arr;
				if(depotId == hashId)
					_warehouse.updateGoods(goods.bagposition, item);
			}
		}
		/**
		 * 取出物品时先移除掉 hash 里的该物品 
		 * @param goodsId
		 * 
		 */		
		public function deleteRecodeByPos(pos:int,bagid:int=0):void
		{
			if(bagid==0)
				bagid = hashId;
			for each(var goods:p_goods in hash[bagid] )
			{
				if(goods.bagposition == pos)
				{
					var arr:Array = hash[bagid];
					var index:int = arr.indexOf(goods);
					arr.splice(index, 1);
					hash[bagid] = arr;
					return;
				}
			}
		}
		
		private function getGoodsById(goodsId:int):p_goods
		{
			for each(var goods:p_goods in hash[hashId] )
			{
				if(goods.id == goodsId)
				{
					return goods;
				}
			}
			return null;
			
		}
		
	}
}