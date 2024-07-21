package modules.family {
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.family.views.fmlDepotViews.FMLdepotGetPanel;
	import modules.family.views.fmlDepotViews.FMLdepotLog;
	import modules.family.views.fmlDepotViews.FMLdepotPanel;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.operateMode.OperateMode;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.common.p_fmldepot_bag;
	import proto.common.p_goods;
	import proto.line.m_fmldepot_create_toc;
	import proto.line.m_fmldepot_create_tos;
	import proto.line.m_fmldepot_getout_toc;
	import proto.line.m_fmldepot_getout_tos;
	import proto.line.m_fmldepot_list_goods_toc;
	import proto.line.m_fmldepot_list_goods_tos;
	import proto.line.m_fmldepot_list_log_toc;
	import proto.line.m_fmldepot_list_log_tos;
	import proto.line.m_fmldepot_putin_toc;
	import proto.line.m_fmldepot_putin_tos;
	import proto.line.m_fmldepot_update_goods_toc;

	public class FamilyDepotModule extends BaseModule {
		private var fmldepotpanel:FMLdepotPanel;
		private var bagHash:Dictionary;
		public var depotNum:int;
		private var bag_id_1:int=0;

		public function FamilyDepotModule() {
			bagHash = new Dictionary();
		}

		private static var _instance:FamilyDepotModule;

		public static function getInstance():FamilyDepotModule {
			if (_instance == null)
				_instance=new FamilyDepotModule();
			return _instance;
		}

		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_19, openFMLdepot);
			addMessageListener(NPCActionType.NA_20, openLogPanel);

			addSocketListener(SocketCommand.FMLDEPOT_LIST_GOODS, handlerDepotList);
			addSocketListener(SocketCommand.FMLDEPOT_GETOUT, handlerGetOut);
			addSocketListener(SocketCommand.FMLDEPOT_PUTIN, handlerPutIn);
			addSocketListener(SocketCommand.FMLDEPOT_UPDATE_GOODS, handlerUpdata);
			addSocketListener(SocketCommand.FMLDEPOT_CREATE, handlerNewDepot);
			addSocketListener(SocketCommand.FMLDEPOT_LIST_LOG, handlerListLog);

		}

		public function getDepotPanel():FMLdepotPanel {
			if (fmldepotpanel)
				return fmldepotpanel;
			return null;
		}

		private var getPanel:FMLdepotGetPanel;

		public function openFMLget(itemVo:BaseItemVO):void {
			//			var itemVo:BaseItemVO = item.data as BaseItemVO;
			if (itemVo) //&& generalVO.usenum != ItemConstant.LOCK
			{
				if (!getPanel) {
					getPanel=new FMLdepotGetPanel();
					getPanel.addEventListener(CloseEvent.CLOSE, buyPanelClose);
				}
				if (FamilyDepotModule.getInstance().getDepotPanel()) {
					getPanel.x=getDepotPanel().x + 33;
					getPanel.y=getDepotPanel().y + 124;
				} else {
					getPanel.x=100;
					getPanel.y=200;
				}
				getPanel.setBaseItemVo(itemVo);
				WindowManager.getInstance().openDialog(getPanel);
			}
		}

		public function buyPanelClose(evt:CloseEvent=null):void {
			if (getPanel) {
				WindowManager.getInstance().closeDialog(getPanel);
				getPanel.dispose();
				getPanel=null;
			}
		}

		public function openFMLdepot(vo:NpcLinkVO=null):void {
			if (!fmldepotpanel) {
				fmldepotpanel=new FMLdepotPanel();
				WindowManager.getInstance().centerWindow(fmldepotpanel);
				WindowManager.getInstance().openDistanceWindow(fmldepotpanel);
				OperateMode.getInstance().setMode(OperateMode.FML_DEPOT_MODE);
				//				WindowManager.getInstance().centerWindow(_warehouse);
				fmldepotpanel.addEventListener(CloseEvent.CLOSE, closeFMLdepotPanel);
				PackManager.getInstance().popUpWindow(PackManager.PACK_1, int(fmldepotpanel.x + fmldepotpanel.width), int(fmldepotpanel.y), false);
				getDepotList();
			} else {
				closeFMLdepotPanel();
				return;
			}
		}

		public function closeFMLdepotPanel(e:CloseEvent=null):void {
			if (fmldepotpanel) {
				OperateMode.getInstance().removeMode(OperateMode.FML_DEPOT_MODE);
				fmldepotpanel.removeEventListener(CloseEvent.CLOSE, closeFMLdepotPanel);
				WindowManager.getInstance().removeWindow(fmldepotpanel);
				fmldepotpanel.dispose();
				fmldepotpanel=null;
			}
		}


		public function getDepotList():void {
			var vo:m_fmldepot_list_goods_tos=new m_fmldepot_list_goods_tos();
			sendSocketMessage(vo);
		}

		private function handlerDepotList(vo:m_fmldepot_list_goods_toc):void {
			if (!vo || !vo.depots || vo.depots.length < 1) {
				BroadcastSelf.getInstance().appendMsg("仓库列表长度为零。。。");
				return;
			}
			if (!bagHash) {
				bagHash=new Dictionary();
			}
			depotNum=vo.depots.length;
			for (var i:int=0; i < vo.depots.length; i++) {

				var fmldepotinfo:p_fmldepot_bag=vo.depots[i] as p_fmldepot_bag;
				if (bag_id_1 == 0) {
					bag_id_1=fmldepotinfo.bag_id;
					curId=bag_id_1;
				}
//				fmldepotinfo.bag_id;fmldepotinfo.goods_list;
				saveDepotData(fmldepotinfo.bag_id, fmldepotinfo.goods_list);
			}
			if (fmldepotpanel) {
				fmldepotpanel.setGoodsData(bagHash[bag_id_1]);
				fmldepotpanel.initTabBar(depotNum);
			}
		}

		public function getOut(goodsId:int, num:int):void {
			var vo:m_fmldepot_getout_tos=new m_fmldepot_getout_tos();
			vo.bag_id=curId;
			vo.goods_id=goodsId;
			vo.num=num;
			sendSocketMessage(vo);

		}

		private function handlerGetOut(vo:m_fmldepot_getout_toc):void {
//			vo.goods_id;vo.num;
			var goods:p_goods;
			if (vo.succ && vo.goods_id && vo.goods_id>0) {
				goods=getGoodsById(vo.goods_id);
				updateNumById(vo.goods_id, vo.remain_num);

				var baseItem1:BaseItemVO=PackageModule.getInstance().getBaseItemVO(goods);
				if (fmldepotpanel && baseItem1) {
					baseItem1.num=vo.remain_num;
					if (vo.remain_num > 0)
						fmldepotpanel.updateGoods(vo.goods_id, baseItem1);
					else {
						fmldepotpanel.updateGoods(vo.goods_id, null);
					}
				}
//				PackManager.getInstance().updateGoods(goods.bagid,baseItem1.position,baseItem1);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}



		public function requestDepotGoods(depotId:int):void {
			curId=bag_id_1 + depotId;
//			var id:String = depotId.toString();
			if (bagHash[curId]) {

			} else {

				bagHash[curId]=new Array();
			}
			if (fmldepotpanel) {
				fmldepotpanel.setGoodsData(bagHash[curId]);
			}
		}

		public function putIn(goodsId:int):void {
			var vo:m_fmldepot_putin_tos=new m_fmldepot_putin_tos();
			vo.bag_id=curId;
			vo.goods_id=goodsId;

			sendSocketMessage(vo);
		}

		private function handlerPutIn(vo:m_fmldepot_putin_toc):void {
//			vo.add_goods;
			if (vo.succ) {
				var itemVo:BaseItemVO=PackageModule.getInstance().getBaseItemVO(vo.add_goods);
				addGoods(vo.add_goods);
				fmldepotpanel.updateGoods(vo.add_goods.id, itemVo);
			} else {

				BroadcastSelf.logger(vo.reason);
			}
		}

		public function newDepot():void //depotId:int
		{
			var vo:m_fmldepot_create_tos=new m_fmldepot_create_tos();
			vo.bag_id=bag_id_1 + depotNum;
			sendSocketMessage(vo);
		}

		private function handlerNewDepot(vo:m_fmldepot_create_toc):void {
			if (vo.succ) {
				depotNum+=1;
				curId=bag_id_1 + depotNum;
				saveDepotData(curId, []);
				if (fmldepotpanel)
					fmldepotpanel.addTabBar(depotNum);
			} else {
				BroadcastSelf.logger(vo.reason);
				Tips.getInstance().addTipsMsg(vo.reason);
				if (fmldepotpanel)
					fmldepotpanel.setPreIndex();

			}
		}

		private function handlerUpdata(vo:m_fmldepot_update_goods_toc):void {
//			vo.goods;vo.update_type;   ////   1 存入 ， 2 取出
			if (vo == null) {
				return;
			}
			if (vo.update_type == 1 && vo.goods) {
				for (var i:int=0; i < vo.goods.length; i++) {
					var good:p_goods=vo.goods[i] as p_goods
					addGoods(good);
					var itemVo:BaseItemVO=PackageModule.getInstance().getBaseItemVO(good);
					if (itemVo && fmldepotpanel)
						fmldepotpanel.updateGoods(good.id, itemVo);

				}
			} else if (vo.update_type == 2 && vo.goods) {
				for (var j:int=0; j < vo.goods.length; j++) {
					var dgood:p_goods=vo.goods[i] as p_goods;

//					delGoodById(dgood.bagid,dgood.id);
					updateNumById(dgood.id, dgood.current_num);

					var dItemVo:BaseItemVO=PackageModule.getInstance().getBaseItemVO(dgood);
					if (dItemVo && fmldepotpanel) {
						if (dgood.current_num == 0) {
							fmldepotpanel.updateGoods(dgood.id, null);
						} else {
							fmldepotpanel.updateGoods(dgood.id, dItemVo);
						}
					}
				}
			}

		}

		public function clearUp():void {
			if (bagHash[curId]) {
				sortHash(bagHash[curId]);
				fmldepotpanel.setGoodsData(bagHash[curId]);
			}
		}


		private var logpanel:FMLdepotLog;

		public function openLogPanel(vo:NpcLinkVO=null):void {
			if (!logpanel) {
				logpanel=new FMLdepotLog();
				logpanel.addEventListener(CloseEvent.CLOSE, closeLogpanel);
				WindowManager.getInstance().openDistanceWindow(logpanel);
				WindowManager.getInstance().centerWindow(logpanel);
			} else {
				closeLogpanel();
			}


		}

		public function closeLogpanel(evt:CloseEvent=null):void {
			if (logpanel) {
				WindowManager.getInstance().removeWindow(logpanel);
				logpanel.dispose();
				logpanel=null;
			}
		}

		public function getDepotLog(type:int, page:int):void //type 1表示存入，2表示取出
		{
			var vo:m_fmldepot_list_log_tos=new m_fmldepot_list_log_tos();
			vo.log_type=type;
			vo.page_num=page;

			sendSocketMessage(vo);
		}

		private function handlerListLog(vo:m_fmldepot_list_log_toc):void {
//			vo.log_type;vo.page_num;   vo.logs
			if (!vo.succ) {
				BroadcastSelf.logger(vo.reason);
				return;
			}

			_logType=vo.log_type;
			if (logpanel) {
				logpanel.setLogData(vo.logs);
				logpanel.PageSize=vo.log_count;
			}
		}



		private function saveDepotData(bagId:int, goods:Array):void {
			if (goods.length > 0)
				sortHash(goods);
			if (!bagHash[bagId]) {
				bagHash[bagId]=new Array();
				bagHash[bagId]=goods;
			} else {
				var arr:Array=goods;
				bagHash[bagId]=arr;
			}
		}

		private function addGoods(good:p_goods):void {
			if (!good)
				return;
			var id:int=good.bagid;
			var arr:Array;
			if (bagHash && bagHash[id]) {
				arr=bagHash[id];
				arr.push(good);
			} else {
				arr=new Array();
				arr.push(good);
				if (bagHash) {
					bagHash[id]=arr;
				}
			}

		}

		private function delGoodById(bagId:int, goodId:int):void {
			if (bagHash[bagId]) {
				var arr:Array=bagHash[bagId];
				for (var i:int=0; i < arr.length; i++) {
					var good:p_goods=arr[i] as p_goods;
					if (good.id == goodId) {
						arr.splice(i, 1);
						break;
					}
				}
			}
		}

		private function updateNumById(goodId:int, remainNum:int):void {
			if (bagHash[curId]) {
				var arr:Array=bagHash[curId];
				for (var i:int=0; i < arr.length; i++) {
					var good:p_goods=arr[i] as p_goods;
					if (good.id == goodId) {
						good.current_num=remainNum;
						if (remainNum <= 0) {
							arr.splice(i, 1);
						}
						break;
					}
				}
			}
		}

		private function sortHash(arr:Array):void {
			arr.sortOn("id", Array.NUMERIC);
		}

		public var curId:int;

		private function getGoodsById(gooid:int):p_goods {
			var good:p_goods;
			var arr:Array=bagHash[curId];
			if (!arr)
				return good;
			for (var i:int=0; i < arr.length; i++) {
				good=arr[i];
				if (good.id == gooid) {
					break;
				}
			}

			return good;
		}

		private var _logType:int; // 1存入   2 取出

		public function get logType():int {

			return _logType
		}

	}
}