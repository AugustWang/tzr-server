package modules.forgeshop
{
	import modules.deal.DealConstant;
	import modules.forgeshop.views.ForgeshopUtils;
	import modules.mypackage.vo.EquipVO;

	public class CostManager
	{
		/**
		 *装备打造费用 
		 */
		public static const EQUIPBUILD_EXPENSE:Array = [10,100,500,1100,2200,3300,4400,5500,6600,7700,8800,9900,11000,12300,13400,14500,15600,17800,19000,21000];
		public static function equipCreateCost(cost:int):String{
			return DealConstant.silverToOtherString(EQUIPBUILD_EXPENSE[cost]);
		}
		
		/**
		 *品质改造费用 
		 * 	品质改造每次收费：银子数量＝装备等级×附加材料等级^3 × 2
		 */		
		public static function qulityChangeCost(equipLvl:int,material_lvl:int):String{
			var money:int = equipLvl*Math.pow(material_lvl,3)*2;
			return DealConstant.silverToOtherString(money);
		}
		
		/**
		 *装备升级费用 
		 * 装备升级收费：收取银子数目＝（升级后装备等级^1.5）×（颜色值^4）×0.2
		 * 
		 */		
		public static function equipUpgradeCost(equipVo:EquipVO):String{
			return DealConstant.silverToOtherString(Math.ceil(Math.pow(equipVo.equipLvl,1.5) * Math.pow(equipVo.color,4) * 0.2));
		}
		
		/**
		 *装备分解费用 
		 * 分解费用＝roundup（装备精炼系数/5）^ 3 ×100文
		 */		
		public static function equpRemoveCost(refine:int):String{
			return DealConstant.silverToOtherString(Math.pow(Math.ceil(refine/5),3)*100);
		}
		
		/**
		 *五行改造费用 
		 *  五行珠：价格＝装备等级×100（银子)
		 *  手续费＝装备等级×附加材料等级^3×2
		 * equipInfo:装备对象，attachId:附加材料ID
		 */		
		public static function wuXingChangeCost(equipInfo:EquipVO,attachId:int):String{
			if(attachId == 23200001){//五行珠
				return DealConstant.silverToOtherString(equipInfo.equipLvl * 100);
			}else{
				var materialLvl:int = ForgeshopUtils.getAttachGrade(equipInfo.material,attachId);
				return DealConstant.silverToOtherString(equipInfo.equipLvl * Math.pow(materialLvl,3) * 2);
			}
		}
	}
}