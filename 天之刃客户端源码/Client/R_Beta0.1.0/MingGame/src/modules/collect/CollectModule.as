package modules.collect
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.scene.sceneManager.SceneUnitManager;
	import com.utils.HtmlUtil;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.collect.views.CollectBar;
	import modules.mypackage.ItemConstant;
	import modules.scene.SceneDataManager;
	
	import proto.line.m_collect_get_grafts_info_toc;
	import proto.line.m_collect_get_grafts_info_tos;
	import proto.line.m_collect_grafts_toc;
	import proto.line.m_collect_remove_grafts_toc;
	import proto.line.m_collect_stop_tos;
	import proto.line.m_collect_updata_grafts_toc;

	public class CollectModule extends BaseModule
	{
		public static const COLLECT:String = "COLLECT";
		public static var selectTypeID:int;
		public static var catchTypeIds:Array = [11421006]
		
		public var isCollectIng:Boolean = false;
		public var collectXML:XML
		public var collestSkins:Dictionary = new Dictionary();
		
		private var _selectCollect:int;
		
		
		private var collectBar:CollectBar
		
		public function CollectModule(){
			init();
		}
		
		private static var _instance:CollectModule
		public static function getInstance():CollectModule{
			if(_instance == null)
				_instance = new CollectModule();
			return _instance;
		}
		
		private function init():void{
			if(collectXML == null){
				collectXML = CommonLocator.getXML(CommonLocator.COLLECT);
				var xmllist:XMLList = collectXML.collect;
				for(var i:int = 0; i < xmllist.length(); i++){
					collestSkins[int(xmllist[i].@typeid)] = GameConfig.COLLECT_PATH + xmllist[i].@skinid.toString() + ".swf";
				}
			}
		}
		
		public function createSkin(id:int):String{
			return collestSkins[id];
		}
		override protected function initListeners():void{
			//服务端消息
			this.addSocketListener(SocketCommand.COLLECT_GET_GRAFTS_INFO,collectGetGraftsInfoCallBack);
			this.addSocketListener(SocketCommand.COLLECT_GRAFTS,collectGraftsCallBack);
			this.addSocketListener(SocketCommand.COLLECT_REMOVE_GRAFTS,collectRemoveGraftsCallBack);
			this.addSocketListener(SocketCommand.COLLECT_UPDATA_GRAFTS,collectUpdataGraftsCallBack);
			
			//模块消息
			this.addMessageListener(ModuleCommand.COLLECT_STOP,collectStop);
		}
		
		private function cleanSelectCollect():void{
			_selectCollect = 0;
			isCollectIng = false;
		}
		
		private function setSelectCollect(value:int):void{
			_selectCollect = value;
			if(value != 0){
				isCollectIng = true;
			}
		}
		
		public function getSelectCollect():int{
			return _selectCollect;
		}
		
		private function collectUpdataGraftsCallBack(vo:m_collect_updata_grafts_toc):void{
			//刷新资源
			this.dispatch(ModuleCommand.UPDATE_COLLECTION,vo);
		}
		
		private function collectGetGraftsInfoCallBack(vo:m_collect_get_grafts_info_toc):void{
			if(vo.succ){
				//出现时间条
				setSelectCollect(vo.info.id);
				var times:int = vo.info.times
				if(collectBar == null){
					collectBar = new CollectBar();
					collectBar.initView();
				}
				WindowManager.getInstance().popUpWindow(collectBar,WindowManager.UNREMOVE);
				//WindowManager.getInstance().centerWindow(collectBar);
				collectBar.y = GlobalObjectManager.GAME_HEIGHT * 0.25;
				collectBar.x = (GlobalObjectManager.GAME_WIDTH - 166)*0.5;
				collectBar.updata(vo.info.times,vo.info.typeid);
				selectTypeID = vo.info.typeid;
				if(SceneUnitManager.getSelf()){
					SceneUnitManager.getSelf().checkCollectState();
				}
			}else{
				//输出错误消息
				if(SceneDataManager.mapData.map_id == 10500){
					Tips.getInstance().addTipsMsg(vo.reason.replace("采集","挖宝"));
					BroadcastSelf.getInstance().appendMsg(vo.reason.replace("采集","挖宝"));
				}else{
					Tips.getInstance().addTipsMsg(vo.reason);
					BroadcastSelf.getInstance().appendMsg(vo.reason);
				}
			}
		}
		
		private function collectGraftsCallBack(vo:m_collect_grafts_toc):void{
			cleanSelectCollect();
			if(vo.succ){
				//输出得到的东西
				var goods_list:Array = vo.goods_list;
				for(var i:int = 0; i < goods_list.length; i++){
					BroadcastSelf.getInstance().appendMsg('你得到了'+HtmlUtil.font('【'+ goods_list[i].name+'】',ItemConstant.COLOR_VALUES[goods_list[i].current_colour]));
				}
				
			}else{
				//输出错误消息
				if(SceneDataManager.mapData.map_id == 10500){
					Tips.getInstance().addTipsMsg(vo.reason.replace("采集","挖宝"));
					BroadcastSelf.getInstance().appendMsg(vo.reason.replace("采集","挖宝"));
				}else{
					Tips.getInstance().addTipsMsg(vo.reason);
					BroadcastSelf.getInstance().appendMsg(vo.reason);
				}
			}
			if(collectBar != null){
				collectBar.remove(vo.succ);
				//WindowManager.getInstance().removeWindow(collectBar);
			}
		}
		
		private function collectRemoveGraftsCallBack(vo:m_collect_remove_grafts_toc):void{
			//移除资源
			this.dispatch(ModuleCommand.REMOVE_COLLECTION,vo);
		}
		
		public function getGraftsInfoSend(id:int):void{
			var vo:m_collect_get_grafts_info_tos = new m_collect_get_grafts_info_tos();
			vo.id = id;
			this.sendSocketMessage(vo);
		}
		
		/**
		 * 取消收集 
		 * 
		 */		
		public function collectStop():void{
			if(collectBar != null){
				WindowManager.getInstance().removeWindow(collectBar);
			}
			if(getSelectCollect() == 0)return;
			var vo:m_collect_stop_tos = new m_collect_stop_tos();
			vo.id = _selectCollect;
			this.sendSocketMessage(vo);
			cleanSelectCollect();
		}
	}
}