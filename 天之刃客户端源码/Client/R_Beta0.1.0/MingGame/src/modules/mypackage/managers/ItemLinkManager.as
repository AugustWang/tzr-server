package modules.mypackage.managers {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.managers.Dispatch;
	import com.utils.PathUtil;
	
	import flash.events.TextEvent;
	
	import modules.ModuleCommand;
	import modules.mypackage.vo.GeneralVO;

	/**
	 *
	 * @author 需要增加各种链接的道具
	 *
	 */
	public class ItemLinkManager {
		private static var _instance:ItemLinkManager;

		public static function getInstance():ItemLinkManager {
			if (!_instance) {
				_instance=new ItemLinkManager();
			}
			return _instance;
		}

		public function ItemLinkManager() {

		}

		/**
		 *
		 * @param judgeLvl
		 * @param lvl
		 * @param faction_id
		 * @param npcIdArr_tai
		 * @param npcIdArr_jing
		 * @return
		 *
		 */
		private function theSameFunc(judgeLvl:int, lvl:int, faction_id:int, npcIdArr_tai:Array, npcIdArr_jing:Array):String {
			if (npcIdArr_tai.length == 1 && npcIdArr_jing.length == 1) {
				return "0";
			}
			var npcId:String;
			if (judgeLvl != 0) { //需要有等级来判断
				if (lvl < judgeLvl) {
					npcId=npcIdArr_tai[faction_id - 1].toString();
				} else {
					npcId=npcIdArr_jing[faction_id - 1].toString();
				}
			} else { //==0说明不需要有等级来判断
				if (faction_id == 1) { //云州
					npcId=npcIdArr_jing[0].toString();
				} else if (faction_id == 2) { //沧州
					npcId=npcIdArr_jing[1].toString();
				} else if (faction_id == 3) { //幽州
					npcId=npcIdArr_jing[2].toString();
				}
			}

			return npcId;
		}

		/**
		 *能过国家和等级判断
		 *
		 */
		public function judgeByEffectType(generalVO:GeneralVO):void {
			var effectType:int = generalVO.effectType;
			var itemObject:Object=ItemLocator.getInstance().getItemLinkByEffectType(effectType);
			if (ItemLocator.getInstance().allTypes) {
				if (ItemLocator.getInstance().allTypes.indexOf(effectType.toString()) == -1)
					return;
			}
			if (!itemObject.hasOwnProperty("desc"))
				return;
			var npcIdArr_tai:Array=String(itemObject.npcId_tai).split("|"); //太平村npc的ID
			var npcIdArr_jing:Array=String(itemObject.npcId_jing).split("|"); //京城npc的ID
			var judgeLvl:int=itemObject.judgeLvl; //用来作判断的等级
			var faction_id:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var lvl:int=GlobalObjectManager.getInstance().user.attr.level;
			var npcId:String;
			npcId=theSameFunc(judgeLvl, lvl, faction_id, npcIdArr_tai, npcIdArr_jing);

			//"头像卡无法直接使用，可到<font color='#00ff00'><u><a href='event:tie'>京城美容师</a></u></font>处更换头像！"
			if (npcId == "0") { //(天工炉的是直接打开界面，要特殊处理)
				Alert.show(generalVO.desc, "提示", function okHandler():void {
						Dispatch.dispatch(ModuleCommand.OPEN_STOVE_WINDOW);
					}, null, "打开天工炉", "取消", null, true, true, null, null,false);
			} else {
				Alert.show(itemObject.desc, "提示", function okHandler():void {
						PathUtil.findNpcAndOpen(npcId);
					}, null, "确定", "取消", null, true, true, null, function linkHandler(evt:TextEvent):void {
						if (evt.text == "tou") {
							PathUtil.findNpcAndOpen(npcId);
						}
					},false);
			}
		}
	}
}