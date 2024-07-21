package modules.vip
{
	import com.common.GameColors;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_role_vip;

	public class VipDataManager
	{
		
		private static var _instance:VipDataManager;
		private var _cardAry:Array = ["【VIP半年卡】","【VIP月卡】","【VIP周卡】"];
		private var _remoteDepotMinLevel:int;
		private var _remoteDepotFeeAry:Array;
		
		public var commonDesc:Array;
		public var specDesc:Array;
		public var vipLevel:Array;
		public var vipCard:Array;
		
		public function VipDataManager()
		{
			load();
		}
		
		public static function getInstance():VipDataManager
		{
			if (!_instance) {
				_instance = new VipDataManager;
			}
			
			return _instance;
		}
		
		private function load():void
		{
			commonDesc = new Array;
			specDesc = new Array;
			vipLevel = new Array;
			vipCard = new Array;
			
			var xml:XML = CommonLocator.getXML(CommonLocator.VIP);
			
			_remoteDepotMinLevel = int(xml.@remote_depot_min_level);
			_remoteDepotFeeAry = String(xml.@remote_depot_fee).split("#");		
			
			for each (var m:XML in xml.commonDesc.desc) {
				var obj:Object = {};
				obj.name = m.@name.toString();
				obj.id = int(m.@id);
				obj.desc = m.@description.toString();
				commonDesc.push(obj);
			}
			commonDesc.sortOn("id", Array.NUMERIC);
			
			for each (var mSpec:XML in xml.specDesc.desc) {
				var objSpec:Object = {};
				objSpec.name = mSpec.@name.toString();
				objSpec.id = int(mSpec.@id);
				objSpec.desc = mSpec.@description.toString();
				specDesc.push(objSpec);
			}
			specDesc.sortOn("id", Array.NUMERIC);
			
			for each (var mLevel:XML in xml.vipLevel.level) {
				var objLevel:Object = {};
				objLevel.name = mLevel.@name.toString();
				objLevel.id = int(mLevel.@id);
				objLevel.transfer = int(mLevel.@transfer);
				objLevel.discount = int(mLevel.@discount);
				objLevel.point = int(mLevel.@point);
				objLevel.color = mLevel.@color.toString();
				objLevel.coloru = mLevel.@coloru.toString();
				objLevel.petURate = int(mLevel.@petUnderstandingRate);
				vipLevel.push(objLevel);
			}
			vipLevel.sortOn("id", Array.NUMERIC);
			
			for each (var mCard:XML in xml.vipCard.card) {
				var objCard:Object = {};
				objCard.name = mCard.@name.toString();
				objCard.id = int(mCard.@id);
				objCard.lastTime = int(mCard.@lastTime);
				objCard.timeAdd = int(mCard.@timeAdd);
				objCard.gold = int(mCard.@gold);
				objCard.typeid = int(mCard.@typeid);
				vipCard.push(objCard);
			}
			vipCard.sortOn("id", Array.NUMERIC);
		}
		
		/**
		 * @doc 是否可以免费开通仓库
		 */
		
		public function isDepotDredgeFree():Boolean
		{
			if (VipModule.getInstance().getRoleVipLevel() >= _remoteDepotMinLevel) {
				return true;
			}
			return false;
		}
		
		/**
		 * 开通某个远程仓库需要多少元宝
		 */
		
		public function getRemoteDepotFee(num:int):int
		{
			return _remoteDepotFeeAry[num-1];
		}
		
		/**
		 * 能够使用远程仓库最低等级
		 */
		
		public function getRemoteDepotMinLevel():int
		{
			return _remoteDepotMinLevel;
		}
		
		
		public function getVipLevelComDesc(level:int):String
		{
			return commonDesc[level-1].desc;
		}
		
		public function getVipLevelSpecDesc(level:int):String
		{
			return specDesc[level-1].desc;
		}
		
		/**
		 * 升级到指定等级需要什么卡
		 */
		
		public function getUpLevelCardType(upLevel:int):int
		{
			var vipInfo:p_role_vip = VipModule.vipInfo;
			var totalTime:int = 0;
			var level:int = 0;
			
			if (vipInfo && vipInfo.role_id !=0) {
				totalTime = vipInfo.total_time;
				level = vipInfo.vip_level;
			}
			
			if (level == 3)
				return -1;
			
			var nextTime:int = vipLevel[upLevel-1].point;
			var pointDiff:int = nextTime - totalTime;
			
			for (var i:int = 1; i <= vipCard.length; i ++) {
				if (vipCard[i-1].timeAdd >= pointDiff) {
					return i;
				}
			}
			
			return -1;
		}
		
		/**
		 * 升级到指定等级需要多少元宝
		 */
		
		public function getUpLevelGold(upLevel:int):int
		{
			var cardType:int = getUpLevelCardType(upLevel);
			
			if (cardType == -1)
				return 0;
			
			return vipCard[cardType-1].gold;
		}
		
		public function getUpLevelCardName(upLevel:int):String
		{
			var cardType:int = getUpLevelCardType(upLevel);
			
			if (cardType == -1)
				return "";
			
			var vo:BaseItemVO = ItemLocator.getInstance().getObject(vipCard[cardType-1].typeid);
			return "<font color='" + GameColors.HTML_COLORS[vo.color] + "'>" + _cardAry[cardType-1] + "</font>";
		}
		
		public function getNewVipLevel(cardType:int):int
		{
			var vipInfo:p_role_vip = VipModule.vipInfo;
			var totalTime:int = 0;
			
			if (vipInfo && vipInfo.role_id != 0)
				totalTime = vipInfo.total_time;
			
			totalTime += vipCard[cardType].timeAdd;
			
			return VipModule.getInstance().getVipLevel(totalTime);
		}
		
		/**
		 * 获取宠物提悟提升概率
		 */
		
		public function getPetUnderstandingRateAdd():String
		{
			var roleVipLevel:int = VipModule.getInstance().getRoleVipLevel();			
			if (roleVipLevel == 0 || roleVipLevel == 1)
				return "（<font color='#00ff00'><u><a href='event:openVip'>VIP2</a></u></font>增加成功率）";
			
			var rate:int = Object(VipDataManager.getInstance().vipLevel[roleVipLevel-1]).petURate / 100;
			return "+"+rate + "%（VIP" + roleVipLevel+"）";
		}
	}
}