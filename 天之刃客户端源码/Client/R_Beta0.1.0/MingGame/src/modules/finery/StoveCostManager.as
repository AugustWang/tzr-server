package modules.finery
{
	import modules.deal.DealConstant;
	import modules.mypackage.vo.EquipVO;

	public class StoveCostManager
	{
		/**
		 *装备开孔费用
		 * 开孔收费＝装备等级×开孔锥等级^3 × 2 
		 */		
		public static function openHoleCost(equipVo:EquipVO):int{
            var punchNumber:int = 1;
            if(equipVo.punch_num > 0){
                punchNumber = equipVo.punch_num;
            }
			return equipVo.equipLvl * Math.pow(punchNumber,3)*2;
		}
		
		/**
		 *镶嵌宝石的费用
		 * 镶嵌收费＝装备等级×镶嵌符等级^3 × 2 
		 */	
		public static function insertStoneCost(equipVo:EquipVO):int{
            var stoneNumber:int = 1;
            if(equipVo.stone_num > 0){
                stoneNumber = equipVo.stone_num;
            }
			return equipVo.equipLvl * Math.pow(stoneNumber,3) * 2;
		}
		
		/**
		 *拆御灵石的费用
		 * 	拆卸费用＝装备等级×镶嵌灵石数量^3 × 2 
		 */	
		public static function removeStoneCost(equipVo:EquipVO):int{
            var stoneNumber:int = 1;
            if(equipVo.stone_num > 0){
                stoneNumber = equipVo.stone_num;
            }
			return equipVo.equipLvl * Math.pow(stoneNumber,3)*2;
		}
		
		/**
		 *装备强化的费用
		 * 强化收费＝装备等级×强化级别^3×2（银子） 
		 */	
		public static function eqiupStrengthCost(equipVo:EquipVO,materialLvl:int):int{
			return equipVo.equipLvl * Math.pow(materialLvl,3) * 2;
		}
		
		/**
		 *装备绑定的费用
		 * 绑定收费＝装备等级^2 ÷ 40  （银子） （40级之内较便宜，等级上升之后增加）
		 * 重新绑定收费＝装备等级×材料等级^3×2 （银子） 
		 * flag= true:属于绑定绑定收费，否则就是提升绑定收费
		 */	
		public static const PRICE:int = 40;
		public static function eqiupBindCost(equipVo:EquipVO,flag:Boolean,materialLvl:int=0):int{
			if(flag){
				return Math.ceil(Math.pow(equipVo.equipLvl,2)/PRICE);
			}else{
				return equipVo.equipLvl * Math.pow(materialLvl,3) * 2;
			}
		}
		/**
		 *装备升级费用 
		 * 装备升级收费：收取银子数目＝（升级后装备等级^1.5）×（颜色值^4）×0.2
		 * 
		 */		
		public static function equipUpgradeCost(equipVo:EquipVO):int{
			return Math.ceil(Math.pow(equipVo.equipLvl,1.5) * Math.pow(equipVo.color,4) * 0.2);
		}
		/**
		 *材料合成收费 
		 */		
		public static function maxMaterialCost():String{
			return "";
		}
		
		public static function equipRecastCost(equipVo:EquipVO,materialLv:int):int{
			var money:int = equipVo.equipLvl*Math.pow(materialLv,3)*2;
			return money;
		}
		
		private static var exaltPrice:Array = [0,0,300,1000,3000,10000,10000];
		public static function exaltCost(equipVo:EquipVO):int{
			return exaltPrice[equipVo.color];
		}
	}
}