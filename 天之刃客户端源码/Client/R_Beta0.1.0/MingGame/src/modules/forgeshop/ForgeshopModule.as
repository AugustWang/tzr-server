package modules.forgeshop
{
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	
	import flash.display.Sprite;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.forgeshop.views.ForgeshopWindows;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.EquipVO;
	import modules.npc.NPCActionType;
	
	import proto.line.m_equip_build_build_toc;
	import proto.line.m_equip_build_build_tos;
	import proto.line.m_equip_build_decompose_tos;
	import proto.line.m_equip_build_fiveele_goods_tos;
	import proto.line.m_equip_build_fiveele_tos;
	import proto.line.m_equip_build_goods_tos;
	import proto.line.m_equip_build_list_tos;
	import proto.line.m_equip_build_quality_goods_tos;
	import proto.line.m_equip_build_quality_tos;
	import proto.line.m_equip_build_signature_tos;
	import proto.line.m_equip_build_upgrade_goods_tos;
	import proto.line.m_equip_build_upgrade_link_tos;
	import proto.line.m_equip_build_upgrade_tos;
	
	
	public class ForgeshopModule extends BaseModule
	{
		private static var _instance:ForgeshopModule;
		private var view:Sprite;
		private var forgeshopWindows:ForgeshopWindows;
		
		public function ForgeshopModule(){
			
		}
		
		public static function getInstance():ForgeshopModule
		{
			if(_instance == null){
				_instance = new ForgeshopModule();
			}
			return _instance;
		}
			
		
		private var openCount:int = 0;
		public function openWindow():void{
			openPackage();
			if(forgeshopWindows == null){
				forgeshopWindows = new ForgeshopWindows();
			}
			
			if(openCount>0){
				switch(this.index()){
					case 0:
						this.requestCurrentMaterialList(0);
						break;
					case 1:
						break;
					case 2:
						break;
					case 3:
						break;
					case 4:
						break;
				}
			}
			openCount++;
			WindowManager.getInstance().openDistanceWindow(forgeshopWindows);
			PackManager.getInstance().popUpWindow(PackManager.PACK_1,forgeshopWindows.x + forgeshopWindows.width,forgeshopWindows.y,false);
		}
		
		public function closeForWindow():void{
			if(forgeshopWindows){
			WindowManager.getInstance().removeWindow(forgeshopWindows);
			forgeshopWindows.onCloseHandler();
			}
		}
		
		override protected function initListeners():void{
			addMessageListener(NPCActionType.NA_35,npcHandler);
			addMessageListener(ModuleCommand.OPEN_FORGESHOP_WINDOW,openWindow);
			addSocketListener(SocketCommand.EQUIP_BUILD_LIST,buildEquipList);
			addSocketListener(SocketCommand.EQUIP_BUILD_BUILD,buildEquip);
			addSocketListener(SocketCommand.EQUIP_BUILD_GOODS,currentMaterialList);
			addSocketListener(SocketCommand.EQUIP_BUILD_QUALITY_GOODS,equipChangeMaterialBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_QUALITY,equipChangBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_SIGNATURE,equipChangeNameBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_DECOMPOSE,equipDestroyBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_UPGRADE_GOODS,equipUpdateMaterialBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_UPGRADE_LINK,nextLvlEquipBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_UPGRADE,equipUpdateBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_FIVEELE_GOODS,WuXingMaterialBack);
			addSocketListener(SocketCommand.EQUIP_BUILD_FIVEELE,wuXingChagneBack);
		}
		
		private function npcHandler(npcObj:Object):void{
			openWindow();
		}
		
		//找开背包
		private function openPackage():void{
			this.dispatch(ModuleCommand.OPEN_PACK_PANEL);
		}
		 
		
		/**
		 * 请求打造装备列表
		 * @param buildLevel		
		 */
		public function requestBuildEquipList(buildLevel:int):void{
			var vo:m_equip_build_list_tos  = new m_equip_build_list_tos();
			vo.build_level = buildLevel;
		 	this.sendSocketMessage(vo);
		}
		
		/**打造装备列表 返回
		 * 
		 * @param data
		 * 
		 */		
		private function buildEquipList(data:Object):void{		
			if(forgeshopWindows != null)
			   forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_LIST);	 
		 
		}
		
		
		/**
		 * 请求拥有的材料列表
		 * @param material		
		 */
		public function requestCurrentMaterialList(material:int):void{
			var vo:m_equip_build_goods_tos  = new m_equip_build_goods_tos();
			vo.material = material;
			
			this.sendSocketMessage(vo);
		}
		
		/**拥有的材料列表 返回
		 * 
		 * @param data
		 * 
		 */		
		private function currentMaterialList(data:Object):void{		
			if(forgeshopWindows != null){
			   forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_GOODS);
			}	
		}
		
		
		/**
		 * 请求打造
		 * @param buildLevel		
		 */
		public function requestBuildEquip(vo:m_equip_build_build_tos):void{				
			this.sendSocketMessage(vo);
		}
		
		/**打造装备 返回
		 * 
		 * @param data
		 * 
		 */		
		private function buildEquip(data:Object):void{
			var build :m_equip_build_build_toc = data as m_equip_build_build_toc;	
			forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_BUILD);
		}
		/**
		 *请求品质改造的材料 
		 * @param material
		 * 
		 */		
		public function requestEquipChangeMaterial(material:int):void{
			var vo:m_equip_build_quality_goods_tos = new m_equip_build_quality_goods_tos();
			vo.material = material;
			
			this.sendSocketMessage(vo);
		}
		/**
		 * 请求品质改造的材料 返回
		 * @param data
		 * 
		 */		
		private function equipChangeMaterialBack(data:Object):void{
			if(forgeshopWindows != null){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_QUALITY_GOODS);
			}	
		}
		/**
		 * 请求品质改造
		 * @return 
		 * 
		 */		
		public function requestEquipChange(vo:m_equip_build_quality_tos):void{
			this.sendSocketMessage(vo);
		}
		/**
		 * 
		 *请求品质改造返回
		 * 
		 */		
		private function equipChangBack(data:Object):void{
			if(forgeshopWindows != null){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_QUALITY);
			}
		}
		/**
		 * 请求装备分解
		 * @param equipVo
		 * 
		 */		
		public function requestEquipDestroy(vo:m_equip_build_decompose_tos):void{
			this.sendSocketMessage(vo);
		}
		/**
		 *装备分解返回 
		 * 
		 */		
		private function equipDestroyBack(data:Object):void{
			if(forgeshopWindows != null){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_DECOMPOSE);
			}
		}
		/**
		 *请求装备签名 
		 * @param vo
		 * 
		 */		
		public function requestEquipChangeName(vo:m_equip_build_signature_tos):void{
			this.sendSocketMessage(vo);
		}
		/**
		 *请求签名返回 
		 * @param data
		 * 
		 */		
		private function equipChangeNameBack(data:Object):void{
			if(forgeshopWindows){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_SIGNATURE);
			}
		}
		/**
		 *请求装备升级的材料 
		 * @param material
		 * 
		 */		
		public function requestEquipUpdateMaterial(material:int):void{
			var vo:m_equip_build_upgrade_goods_tos = new m_equip_build_upgrade_goods_tos();
			vo.material = material;
			
			this.sendSocketMessage(vo);
		}
		/**
		 *请求升级材料返回 
		 * @param data
		 * 
		 */		
		private function equipUpdateMaterialBack(data:Object):void{
			if(forgeshopWindows){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_UPGRADE_GOODS);
			}
		}
		/**
		 *请求升级到下一级的装备的信息 
		 * @param equipId
		 * 
		 */		
		public function requestNextLvlEquip(equipId:int,isQulity:Boolean,isRefine:Boolean,isFive:Boolean,isBind:Boolean):void{
			var vo:m_equip_build_upgrade_link_tos = new m_equip_build_upgrade_link_tos();
			vo.equip_id = equipId;
			vo.is_quality = isQulity;
			vo.is_reinforce = isRefine;
			vo.is_five_ele = isFive;
			vo.is_bind_attr = isBind;

			
			this.sendSocketMessage(vo);
		}
		/**
		 *请求升级到下一级的装备信息返回 
		 * @param data
		 * 
		 */		
		private function nextLvlEquipBack(data:Object):void{
			if(forgeshopWindows){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_UPGRADE_LINK);
			}
		}
		/**
		 *请求装备升级 
		 * @param vo
		 * 
		 */		
		public function requestEquipUpdate(vo:m_equip_build_upgrade_tos):void{
			this.sendSocketMessage(vo);
		}
		/**
		 *请求装备升级返回 
		 * @param data
		 * 
		 */		
		private function equipUpdateBack(data:Object):void{
			if(forgeshopWindows){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_UPGRADE);
			}
		}
		/**
		 * 更改签名的数据获取
		 * @return 
		 * 
		 */		
		public function equipChangeName(equipVo:EquipVO):void{
			if(forgeshopWindows){
				forgeshopWindows.getChangeNameInfo(equipVo);
			}
		}
		
		/**
		 * 清除
		 * @param
		 * 
		 */	
		
		public function cleanGoods():void{
			if(forgeshopWindows){
				forgeshopWindows.cleanGoods();
			}
		}
		
		/**
		 * 把已存在的物品替换
		 * @param
		 * 
		 */
		public function swapGoods():void{
			if(forgeshopWindows){
				forgeshopWindows.swapGoods();
			}
		}
		
		/**
		 *装备分解的数据的获取 
		 * @param equipVo
		 * 
		 */		
		public function equipDestroy(equipVo:EquipVO):void{
			if(forgeshopWindows){
				forgeshopWindows.getEquipDestroyInfo(equipVo);
			}
		}
		
		/**
		 *五行改造材料请求 
		 * @return 
		 * 
		 */
		
		public function requestWuXingMaterial(materialVo:int):void{
			var vo:m_equip_build_fiveele_goods_tos = new m_equip_build_fiveele_goods_tos();
			vo.material = materialVo;
			this.sendSocketMessage(vo);
		}
		
		/**
		 *五行改造材料请求返回 
		 * @return 
		 * 
		 */		
		private function WuXingMaterialBack(data:Object):void{
			if(forgeshopWindows){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_FIVEELE_GOODS);
			}
		}
		
		/**
		 *五行改造请求 
		 * @return 
		 * 
		 */		
		public function requestWuXingChange(wuXingVo:m_equip_build_fiveele_tos):void{
			var vo:m_equip_build_fiveele_tos = wuXingVo;
			this.sendSocketMessage(vo);
		}
		
		/**
		 *五行改造返回 
		 * @return 
		 * 
		 */		
		private function wuXingChagneBack(data:Object):void{
			if(forgeshopWindows){
				forgeshopWindows.responseResult(data,SocketCommand.EQUIP_BUILD_FIVEELE);
			}
		}
		/**
		 *导航按钮的索引
		 *  
		 */
		
		public function index():int{
			return forgeshopWindows.navigationSelectIndex;
		}
		/**
		 *判断框图里是否有装备 
		 * @return 
		 * 
		 */		
		public function isHasData():Boolean{
			return forgeshopWindows.isHasData();
		}
		/**
		 *判断升级框框里是否有装备 
		 * @return 
		 * 
		 */		
		public function isUpdateBoxHasData():Boolean{
			return forgeshopWindows.isUpdateBoxHasData();
		}
		/**
		 *清除升级框的物品 
		 * 
		 */		
		public function cleanUpdateGoods():void{
			forgeshopWindows.cleanUpdateGoods();
		}
		
		/**
		 *当拿掉装备时，把右边的所有数据都清除掉 (升级)
		 */	
		public function disposeEquipUpdate():void{
			forgeshopWindows.disposeEquipData();
		}
		/**
		 *当拿掉装备时，把右边的所有数据都清除掉 (品质)
		 */	
		public function dispseQulityData():void{
			forgeshopWindows.disposeQulityData();
		}
		
		/**
		 * 当拿掉装备时，把右边的所有数据都清除掉 (打造)
		 */	
		public function disposeEquipCreateData():void{
			forgeshopWindows.disposeEquipCreateData();
		}
		
		/**
		 * 当拿掉装备时，把右边的所有数据都清除掉 (签名)
		 */	
		public function disposeSignNameData():void{
			forgeshopWindows.disposeSignNameData();
		}
		
		/**
		 * 当拿掉装备时，把右边的所有数据都清除掉 (分解)
		 */
		public function disposeEquipRemoveData():void{
			forgeshopWindows.disposeEquipRemoveData();
		}
		
		/**
		 * 当拿掉装备时，把右边的所有数据都清除掉 (五行)
		 */		
		public function disposeWuXingData():void{
			forgeshopWindows.disposeWuXingData();
		}
	}
}