package modules.equiponekey
{	
	import com.components.cooling.CoolingManager;
	import com.net.SocketCommand;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.equiponekey.views.RoleChangeClothingView;
	import modules.equiponekey.views.items.ClothingItemVO;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_equip_onekey_info;
	import proto.common.p_goods;
	import proto.line.m_equiponekey_info_toc;
	import proto.line.m_equiponekey_info_tos;
	import proto.line.m_equiponekey_list_toc;
	import proto.line.m_equiponekey_list_tos;
	import proto.line.m_equiponekey_load_toc;
	import proto.line.m_equiponekey_load_tos;
	import proto.line.m_equiponekey_save_toc;
	import proto.line.m_equiponekey_save_tos;

	public class EquipOneKeyModule extends BaseModule
	{
		private var clothing:RoleChangeClothingView;
		private var equipsDic:Dictionary;
		public function EquipOneKeyModule()
		{
			equipsDic = new Dictionary();
		}
		
		private static var instance:EquipOneKeyModule;
		public static function getInstance():EquipOneKeyModule{
			if(instance == null){
				instance = new EquipOneKeyModule();
			}
			return instance;
		}
		
		override protected function initListeners():void{
			addSocketListener(SocketCommand.EQUIPONEKEY_INFO,setEquipInfo);
			addSocketListener(SocketCommand.EQUIPONEKEY_LIST,setEquipOnekeyList);
			addSocketListener(SocketCommand.EQUIPONEKEY_LOAD,setLoadEquips);
			addSocketListener(SocketCommand.EQUIPONEKEY_SAVE,setSaveEquips);	
		}
		
		public function getClothingView():RoleChangeClothingView{
			if(clothing == null){
				clothing = new RoleChangeClothingView();
				getEquipOnekeyList();
			}	
			return clothing;
		}

		/**
		 * 衣服名称发送更改通知快捷栏 
		 */		
		public function clothingNameChanged(clothingItemVo:ClothingItemVO):void{
			dispatch(ModuleCommand.CLOTHING_NAME_CHANGED,clothingItemVo);
		}
		
		public function getEquipsById(suitId:int):Array{
			return equipsDic[suitId];
		}
		/**********************************消息发送 ********************************************/ 		
		
		/**
		 * 获取一键换装所有列表 
		 */		
		private function getEquipOnekeyList():void{
			sendSocketMessage(new m_equiponekey_list_tos());	
		}
		/**
		 * 获取套装的详细信息 
		 */		
		public function getEquipsInfo(suitId:int):void{
			if(equipsDic[suitId] && clothing){
				clothing.setEquipsInfo(equipsDic[suitId] as Array);
				return;
			}
			var vo:m_equiponekey_info_tos = new m_equiponekey_info_tos();
			vo.equips_id = suitId;
			sendSocketMessage(vo);	
		}
		/**
		 * 使用当前套装 
		 */		
		public function loadEquips(suitId:int):void{
			if(CoolingManager.getInstance().isCoolingByName(ModuleCommand.CLOTHING_ID)){
				BroadcastSelf.logger("一键换装冷却中。");
				return;
			}
			var vo:m_equiponekey_load_tos = new m_equiponekey_load_tos();
			vo.equips_id = suitId;
			CoolingManager.getInstance().startCooling(ModuleCommand.CLOTHING_ID,3000);
			sendSocketMessage(vo);	
		}
		/**
		 * 保存套装信息
		 */		
		public function saveEquips(equips_Info:p_equip_onekey_info):void{
			var vo:m_equiponekey_save_tos = new m_equiponekey_save_tos();
			vo.equips_list = equips_Info;
			sendSocketMessage(vo);	
		}
		/**********************************消息接受  ********************************************/ 		
		/**
		 * 获取所有装备列表 (返回)
		 */		
		private function setEquipOnekeyList(vo:m_equiponekey_list_toc):void{
			if(vo.succ){
				if(clothing){
					clothing.setEquipOneKeyList(vo.equips_list);
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 获取套装详细信息（返回） 
		 */		
		private function setEquipInfo(vo:m_equiponekey_info_toc):void{
			if(vo.succ){
				if(clothing){
					var equips:Array = [];
					for each(var goods:p_goods in vo.equips_list.equips_list){
						var equipVO:EquipVO = ItemConstant.wrapperItemVO(goods) as EquipVO;
						equips.push(equipVO);
					}
					clothing.setEquipsInfo(equips);
					equipsDic[vo.equips_list.equips_id] = equips;
				}
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 使用当前套装 （返回） 
		 */		
		private function setLoadEquips(vo:m_equiponekey_load_toc):void{
			if(!vo.succ){
				BroadcastSelf.logger(vo.reason);
			}
		}
		/**
		 * 保存套装信息（返回） 
		 */		
		private function setSaveEquips(vo:m_equiponekey_save_toc):void{
			if(vo.succ){
				delete equipsDic[vo.equips_id];//防止脏读
				if(clothing){
					clothing.updateEquipsName(vo.equips_id,vo.equips_name);
				}
				Tips.getInstance().addTipsMsg("保存套装配置成功");
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
	}
}