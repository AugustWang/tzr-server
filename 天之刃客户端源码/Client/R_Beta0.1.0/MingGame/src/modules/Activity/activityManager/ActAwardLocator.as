package modules.Activity.activityManager {
	import com.loaders.CommonLocator;

	import modules.Activity.vo.AwardVo;

	public class ActAwardLocator {

		public function ActAwardLocator() {
			todayXML=CommonLocator.getXML(CommonLocator.ACT_TODAY);
			awardXML=CommonLocator.getXML(CommonLocator.ACT_AWARD);
			giftXML=CommonLocator.getXML(CommonLocator.ACT_GIFT);


			listDatas=[];
		}

		public var todayXML:XML; // act_today.xml
		public var awardXML:XML; //awardXML
		public var giftXML:XML;
		public var listDatas:Array;

		private static var instance:ActAwardLocator;

		public static function getInstance():ActAwardLocator {
			if (instance == null) {
				instance=new ActAwardLocator();
			}
			return instance;
		}

		//parse giftXML update by handing @2011.4.25 19:02
		public function parseGiftXML():Array {
			var arr:Array=[];
			for each (var xml:XML in giftXML.gifts) {
//				var obj:Object = {};
//				obj.id = int(xml.@id);
//				obj.path=String(xml.@path);
//				obj.itemId=String(xml.@itemId);
//				obj.title = String(xml.@title);
//				obj.name = String(xml.@name);
//				obj.desc = String(xml.desc);
//				arr.push(obj);

				var obj:Object={};
				obj.id=int(xml.@id);
				obj.type=int(xml.@type);
				obj.name=String(xml.@name);
				obj.title=String(xml.@title);

				var childLength:int=xml.gift.length();
				var array:Array=new Array();
				for (var j:int=0; j < childLength; j++) {
					var childObject:Object=new Object();
					childObject.itemId=int(xml.gift[j].@itemId);
					childObject.num=int(xml.gift[j].@num);
					array.push(childObject);
				}
				obj.child=array;
				arr.push(obj);
			}
			return arr;
		}

		/*******************************************/
		/**
		 * 获得今日活动的xml配置数据 
		 * @param id
		 */		
		public function getTodayObjById(id:int):Object {
			var obj:Object={};


			var item:XML=todayXML.item.(@id == id)[0];
			if (!item) {
				return null;
			}
			obj.id=id;
			//obj.order_id=item.@order_id;
			obj.npc_id=[0, item.@npc_1, item.@npc_2, item.@npc_3]
			obj.name=String(item.@name);
			obj.time_segment=String(item.@time_segment);
			obj.period=String(item.@period);
			obj.total_times=String(item.@total_times);
//			obj.condition=String(item.@condition);
			obj.minLvl=String(item.@minLvl);
			obj.exp_stars=int(item.@exp_stars);
			obj.silver_stars=int(item.@silver_stars);
			obj.item_stars=int(item.@item_stars);

			obj.active_points=String(item.@active_points);
			obj.link_name=String(item.@link_name);
			obj.desc=String(item.@desc);
			obj.rewards=String(item.@reward).split(",");

			return obj;
		}

		public function getBaseAwardList():Array {
			var arr:Array=[];
			var len:int=awardXML.baseAward.award.length();
			for (var i:int=0; i < len; i++) {
				var obj:Object=xmlToObj(XML(awardXML.baseAward.award[i]));
				if (obj)
					arr.push(obj);
			}
			return arr;
		}

		public function getExtraAwardList():Array {
			var arr:Array=[];
			var len:int=awardXML.extraAward.items.length();
			for (var i:int=0; i < len; i++) {
				var obj:Object=xmlToObj(XML(awardXML.extraAward.items[i]));
				if (obj)
					arr.push(obj);
			}
			return arr;
		}


		/*<award id="1" name="" actpoint="3" expAdd="10000" expMult="410">
		 <item type="1" itemId="10100001" num="1" bind="true" />*/
		private function xmlToObj(xml:XML):Object {
			if (!xml)
				return null;

			var obj:AwardVo=new AwardVo();
			obj.id=int(xml.@id);
			obj.expAdd=int(xml.@expAdd);
			obj.expMult=int(xml.@expMult);
			obj.taskName=xml.@taskName;
			obj.taskCondition=xml.@taskCondition;
			obj.npcId=int(xml.@npcId);
			obj.mapId=int(xml.@mapId);

			for each (var it:XML in xml.item) {
				obj.itemArr.push(it);
			}

			return obj
		}

	}
}