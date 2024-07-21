package modules.heroFB {
	import com.common.GlobalObjectManager;
	import com.loaders.CommonLocator;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	
	import flash.utils.Dictionary;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_hero_fb_barrier;

	public class HeroFBDataManager {
		private static var _instance:HeroFBDataManager;

		private var xml:XML;
		private var barriers:Dictionary=new Dictionary;

		public function HeroFBDataManager() {
			loadConfig();
		}

		public static function getInstance():HeroFBDataManager {
			if (!_instance)
				_instance=new HeroFBDataManager;

			return _instance;
		}

		private function loadConfig():void {
			xml=CommonLocator.getXML(CommonLocator.HERO_FB);
		}

		/**
		 * 获取某章信息
		 */

		public function getChapterInfo(chapId:int):XML {
			return (xml.chapInfo.chap.(@id == chapId.toString()))[0];
		}

		/**
		 * 获取某关配置
		 */

		public function getBarrierInfo(barrierId:int):XML {
			return (xml.barrierInfo.barrier.(@id == barrierId.toString()))[0];
		}

		/**
		 * 获取最大章节
		 */

		public function getChapterNum():int {
			return (xml.chapInfo.@chapNum);
		}

		/**
		 * 获取所有副本地图ID列表
		 */

		public function getHeroFBMapIdList():Array {
			var list:XMLList=xml.barrierInfo.barrier.@mapId;
			var ary:Array=new Array;

			for (var i:int=0; i < list.length(); i++)
				ary.push(int(XML(list[i]).valueOf()));

			return ary;
		}

		/**
		 * 根据地图ID获取关卡ID
		 */

		public function getBarrierIdByMapId(mapId:int):int {
			var xml:XML=(xml.barrierInfo.barrier.(@mapId == mapId.toString()))[0];

			return int(xml.@id);
		}

		/**
		 * 获取进入英雄副本最低等级
		 */

		public function getEnterMinLevel():int {
			return xml.@min_enter_level;
		}

		/**
		 * 获取一天最多进入次数
		 */

		public function getMaxEnterTimes():int {
			return xml.@max_times_per_day;
		}

		/**
		 * 获取购买默认元宝
		 */

		private function getBuyDefaultGold():int {
			return xml.@buy_default_gold;
		}

		/**
		 * 获取元宝增加步长
		 */

		private function getBuyGoldStep():int {
			return xml.@buy_gold_step;
		}

		/**
		 * 购买使用次数最多需要多少元宝
		 */

		private function getBuyMaxGold():int {
			return xml.@max_gold;
		}

		/**
		 * 获取每天最大购买次数
		 */

		public function getMaxBuyTimes():int {
			return xml.@max_buy_time;
		}

		/**
		 * 获取某一关卡bossid
		 */

		public function getBossVoByBarrierId(barrierId:int):MonsterType {
			var xml:XML=(xml.barrierInfo.barrier.(@id == barrierId.toString()))[0];
			var typeId:int=int(xml.@bossTypeId);

			return MonsterConfig.hash[typeId];
		}

		/**
		 * 获取关卡描述
		 */

		public function getBarrierDesc(id:int):String {
			var xml:XML=(xml.barrierInfo.barrier.(@id == id.toString()))[0];

			return xml.desc;
		}

		/**
		 * 获取关卡掉落描述
		 */

		public function getBarrierDropDesc(id:int):String {
			var xml:XML=(xml.barrierInfo.barrier.(@id == id.toString()))[0];

			return xml.dropDesc;
		}

		/**
		 * 获取每关卡奖励道具
		 */

		public function getDropItemVo(id:int):BaseItemVO {
			var xml:XML=(xml.barrierInfo.barrier.(@id == id.toString()))[0];
			var typeId:int=int(xml.@rewardTypeId);
			var color:int=int(xml.@rewardColor);

			var vo:BaseItemVO=ItemLocator.getInstance().getObject(typeId);
			if (!vo)
				return null;

			vo.color=color;
			return vo;
		}

		/**
		 * 获取英雄副本传送员ID
		 */

		public function getHeroFbNpcId():int {
			var factionId:int=GlobalObjectManager.getInstance().user.base.faction_id;
			return 10000000 + factionId * 1000000 + 100133;
		}

		/**
		 * @doc 获取某关的下一关ID
		 */

		public function getNextBarrierID(id:int):int {
			if (getBarrierInfo(id + 1)) {
				return (id + 1);
			}

			if ((int(id / 10) + 1) > getChapterNum()) {
				return 0;
			}

			return (int(id / 10 + 1) * 10 + 1);
		}

		/**
		 * @doc 获取第*次购买需要的元宝
		 */

		public function getBuyGold(time:int):int {
			var maxGold:int=getBuyMaxGold();
			var goldNeed:int=getBuyDefaultGold() + time * getBuyGoldStep();
			if (goldNeed > maxGold)
				goldNeed=maxGold;

			return goldNeed;
		}

		public function setBarriers($barriers:Array):void {
			for (var i:int=0; i < $barriers.length; i++) {
				var item:p_hero_fb_barrier = $barriers[i];
				barriers[item.barrier_id] = $barriers[i];
			}
		}
		
		public function getBarrierStateById(barrierId:int):p_hero_fb_barrier{
			if(barriers.hasOwnProperty(barrierId)){
				return barriers[barrierId];
			}
			return null;
		}
		
		public function setBarrierState(info:p_hero_fb_barrier):void{
			barriers[info.barrier_id] = info;
		}
	}
}