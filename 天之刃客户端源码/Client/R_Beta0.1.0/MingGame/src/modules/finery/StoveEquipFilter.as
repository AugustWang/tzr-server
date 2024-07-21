package modules.finery
{
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_goods;
	import proto.common.p_refining;

	public class StoveEquipFilter
	{
		public function StoveEquipFilter()
		{
		}
		
		/**
		 * 可开孔的装备过滤 PUT_ADORN:int=10; //挂饰PUT_FASHION:int=11; //时装PUT_MOUNT:int=12; //坐骑
		 * 取身上装备，先屏蔽
		 * equips = GlobalObjectManager.getInstance().user.attr.equips.concat();
			l = equips.length;
			for(i = 0; i < l; i++){
				putWhere = equips[i].loadposition;
				if(putWhere != 7 && putWhere  != 8 && putWhere != 14 && putWhere != 15){
					vo = ItemConstant.wrapperItemVO(equips[i]) as EquipVO;
					punchEquip.push(vo);
				}
			}
		 */		
		public static function punch():Array{
			var equips:Array = PackManager.getInstance().getEquip();
			var punchEquip:Array = [];
			var l:int = equips.length;
			var putWhere:int;
			var vo:EquipVO;
			for(var i:int = 0; i < l; i++){
				putWhere = equips[i].putWhere;
				if(putWhere != ItemConstant.PUT_ADORN &&
					putWhere != ItemConstant.PUT_FASHION &&
					putWhere != ItemConstant.PUT_MOUNT &&
					StoveConstant.specialEquipArr.indexOf(EquipVO(equips[i]).typeId) == -1){
					punchEquip.push(equips[i]);
				}
			}
			return punchEquip;
		}
		
		public static function inset():Array{
			var equips:Array = PackManager.getInstance().getEquip();
			var result:Array = [];
			var l:int = equips.length;
			var putWhere:int;
			var vo:EquipVO;
			for(var i:int = 0; i < l; i++){
				putWhere = equips[i].putWhere;
				if(putWhere != ItemConstant.PUT_ADORN &&
					putWhere != ItemConstant.PUT_FASHION &&
					putWhere != ItemConstant.PUT_MOUNT &&
					StoveConstant.specialEquipArr.indexOf(EquipVO(equips[i]).typeId) == -1){
					if(equips[i].punch_num != 0 && equips[i].stone_num != equips[i].punch_num){
						result.push(equips[i]);
					}
				}
			}
			return result;
		}
		
		public static function disassembly():Array{
			var equips:Array = PackManager.getInstance().getEquip();
			var result:Array = [];
			var l:int = equips.length;
			var putWhere:int;
			var vo:EquipVO;
			for(var i:int = 0; i < l; i++){
				putWhere = equips[i].putWhere;
				if(putWhere != ItemConstant.PUT_ADORN &&
					putWhere != ItemConstant.PUT_FASHION &&
					putWhere != ItemConstant.PUT_MOUNT &&
					StoveConstant.specialEquipArr.indexOf(EquipVO(equips[i]).typeId) == -1){
					if(equips[i].stone_num != 0){
						result.push(equips[i]);
					}
				}
			}
			return result;
		}
		
		public static function extal(oid:int = 0):Array{
			var equips:Array = PackManager.getInstance().getEquip();
			var punchEquip:Array = [];
			var l:int = equips.length;
			var putWhere:int;
			var vo:EquipVO;
			for(var i:int = 0; i < l; i++){
				putWhere = equips[i].putWhere;
				if(putWhere != ItemConstant.PUT_ADORN &&
					putWhere != ItemConstant.PUT_FASHION &&
					putWhere != ItemConstant.PUT_MOUNT &&
					StoveConstant.specialEquipArr.indexOf(EquipVO(equips[i]).typeId) == -1
					&& equips[i].color > 1){
					if(oid == 0){
						punchEquip.push(equips[i]);
						continue;
					}
					if(oid !=0 && equips[i].oid != oid){
						var selectItem:BaseItemVO = PackManager.getInstance().getItemById(oid);
						if(StoveMaterialFilter.percent(selectItem,equips[i]) !=0){
							punchEquip.push(equips[i]);
						}
					}
				}
			}
			return punchEquip;
		}
		
		public static function findTarget(firing_list:Array,update_list:Array):EquipVO{
			var targetOID:int;
			var equip:EquipVO = new EquipVO();
			for(var i:int=0; i < firing_list.length;i++ ){
				var p:p_refining = firing_list[i];
				if(p.firing_type == StoveConstant.FIRING_TYPE_TARGET){
					targetOID = p.goods_id;
					break;
				}
			}
			for(i=0; i < update_list.length; i ++){
				var good:p_goods = update_list[i];
				if(good.id == targetOID){
					equip.copy(good);
					break;
				}
			}
			return equip;
		}
		
		public static function findMaterial(firing_list:Array):int{
			var targetOID:int;
			var baseItemVO:BaseItemVO;
			var p:p_refining;
			for(var i:int=0; i < firing_list.length;i++ ){
				p = firing_list[i];
				if(p.firing_type == StoveConstant.FIRING_TYPE_MATERIAL){
					return p.goods_type_id;
				}
			}
			return 0;
		}
	}
}