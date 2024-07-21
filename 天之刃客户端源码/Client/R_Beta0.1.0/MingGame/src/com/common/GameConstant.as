package com.common {
	import com.globals.GameConfig;

	public class GameConstant {

		public static const FACTIONS:Array=["中立", "云州", "沧州", "幽州"];
		public static const CATEGORY:Array=["","战神","剑仙","天师","医圣"];//战神---战士剑仙---射手天师---侠客医圣---医仙

		public function GameConstant() {
		}

		/**
		 * 通过头像ID获取头像图片路径
		 * @param value
		 * @return
		 *
		 */
		public static function getHeadImage(skin_id:int):String //sex:int,
		{
			return GameConfig.ROOT_URL + "com/assets/headImage/"+skin_id+".png";
		}

		/**
		 * 获取国家名称
		 * @param id
		 * @return
		 *
		 */
		public static function getNation(id:int):String {
			if (id >= 0 && id <= 3) {
				return FACTIONS[id];
			}
			return "未知";
		}
		
		public static function get transformCategory():int{
			var category:int = GlobalObjectManager.getInstance().user.attr.category;
			if(category == 3){
				return 4;
			}else if(category == 4){
				return 3;
			}
			return category;
			
		}
	}
}