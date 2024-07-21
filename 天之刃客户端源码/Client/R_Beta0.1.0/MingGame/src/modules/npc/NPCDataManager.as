package modules.npc {
	import com.common.GlobalObjectManager;
	import com.scene.WorldManager;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import modules.educate.EducateModule;
	import modules.family.FamilyLocator;
	import modules.personalybc.PersonalYbcModule;
	import modules.system.SystemConfig;


	public class NPCDataManager {

		//NPC Base
		static public const NPC_BASE_ID_INDEX:int = 0;//NPC ID
		static public const NPC_BASE_NAME_INDEX:int = 1;//NPC 名
		static public const NPC_BASE_JOB_INDEX:int = 2;//NPC 职位ID
		static public const NPC_BASE_ACTION_INDEX:int = 3;//NPC 功能ID列表
		static public const NPC_BASE_AVATAR_INDEX:int = 4; //NPC 头像
		static public const NPC_BASE_SKIN_INDEX:int = 5; //NPC 皮肤
		static public const NPC_BASE_CONTENT_INDEX:int = 6; //NPC 默认内容
		static public const NPC_BASE_TYPE_INDEX:int = 7; //NPC 类型
		static public const NPC_BASE_MAP_ID_INDEX:int = 8;//NPC所在地图
		static public const NPC_BASE_ICON_INDEX:int = 9;//图标
		static public const NPC_BASE_CAN_SEARCH_WAY:int = 10;//是否可以寻路
		static public const NPC_BASE_NAME_COLOR:int = 11;//小地图名字颜色
		
		//NPC Job
		static public const NPC_JOB_ID_INDEX:int = 0;//NPC职位ID
		static public const NPC_JOB_NAME_INDEX:int = 1;//NPC职位名
		
		
		//NPC Action
		static public const NPC_ACTION_ID_INDEX:int = 0;//NPC 功能ID
		static public const NPC_ACTION_NAME_INDEX:int = 1;//NPC 功能名
		static public const NPC_ACTION_CONDITION_INDEX:int = 2;//NPC 显示该功能的条件列表
		
		static public const NPC_DEFAULT_ID:int = 0;//默认NPC ID  找不到数据时使用
		static public const NPC_DEFAULT_JOB_ID:int = 0;//默认NPC 职位 ID  找不到数据时使用
		static public const NPC_DEFAULT_ACTION_ID:int = 0;//默认NPC 功能 ID 找不到数据时使用
		
		
		public function NPCDataManager(singleton:singleton) {
			if (singleton) {
				super();
			} else {
				throw new Error("NpcDataManager Singleton.");
			}
		}

		private static var instance:NPCDataManager;

		public static function getInstance():NPCDataManager {
			if (instance == null) {
				instance=new NPCDataManager(new singleton());
			}
			return instance;
		}

		private var _npcBaseDataObj:Dictionary;
		private var _npcActionObj:Dictionary;
		private var _npcJobObj:Dictionary;
		private var _npcPos:Dictionary;
		
		public function initNpcData(dataBytes:ByteArray):void{
			dataBytes.uncompress();
			
			_npcBaseDataObj = new Dictionary();
			_npcActionObj = new Dictionary();
			_npcJobObj = new Dictionary();
			_npcPos = new Dictionary();//地图回来初始化它
			
			//NPC_ID	名字	职位ID	功能列表(ID1,ID2...)
			var npcBaseData:Array = dataBytes.readObject();
			//触发事件ID	功能名字	条件列表(条件ID,条件数据1,条件数据2...|第二个条件...)
			var npcActionData:Array = dataBytes.readObject();//NPC功能数据
			//职位ID	 职位名
			var npcJobData:Array = dataBytes.readObject();//NPC职位数据
			
			for each(var npcBaseDataItem:Array in npcBaseData){
				this._npcBaseDataObj[npcBaseDataItem[NPC_BASE_ID_INDEX]] = npcBaseDataItem;
			}
			
			for each(var npcActionItem:Array in npcActionData){
				this._npcActionObj[npcActionItem[NPC_ACTION_ID_INDEX]] = npcActionItem;
			}
			
			for each(var npcJobItem:Array in npcJobData){
				this._npcJobObj[npcJobItem[NPC_JOB_ID_INDEX]] = npcJobItem;
			}
			
		}
		
		/**
		 * 设置某只NPC的坐标
		 */
		public function setPos(npcID:int, mapID:int, tx:int, ty:int):void{
			this._npcPos[npcID] = [mapID, tx, ty];
		}
		
		/**
		 * 获取某只NPC的坐标
		 * [mapID, tx, ty]
		 */
		public function getPos(npcID:*):Array {
			return this._npcPos[npcID];
		}
		
		/**
		 * 获取NPC信息
		 * @return 
		 * 			id:NPC的ID
		 * 			name:NPC名字
		 * 			jobID:职位ID
		 *          actionArr:功能列表
		 *          avatar:头像
		 *          skin:皮肤
		 *          content:默认台词
		 *          type:类型 0普通 1功能
		 *          mapID:地图ID
		 *          mapName:地图名
		 */
		public function getNpcInfo(npcID:int):Object {
			
			var npcBaseObj:Object = this._npcBaseDataObj[npcID];
			if(!npcBaseObj){
				npcBaseObj = this._npcBaseDataObj[NPC_DEFAULT_ID];
			}
			
			var id:int = npcID;
			var name:String = npcBaseObj[NPC_BASE_NAME_INDEX];
			var jobID:int = parseInt(npcBaseObj[NPC_BASE_JOB_INDEX]);
			var jobName:String = this._npcJobObj[jobID][NPC_JOB_NAME_INDEX];
			var avatar:String = npcBaseObj[NPC_BASE_AVATAR_INDEX];
			var skin:String = npcBaseObj[NPC_BASE_SKIN_INDEX];
			var content:String = npcBaseObj[NPC_BASE_CONTENT_INDEX];
			var type:int = parseInt(npcBaseObj[NPC_BASE_TYPE_INDEX]);
			var mapID:int = parseInt(npcBaseObj[NPC_BASE_MAP_ID_INDEX]);
			var icon:int = parseInt(npcBaseObj[NPC_BASE_ICON_INDEX]);
			var canSearchWay:Boolean = npcBaseObj[NPC_BASE_CAN_SEARCH_WAY] == '1' ? true : false;
			var color:String = npcBaseObj[NPC_BASE_NAME_COLOR];
			
			var mapName:String = '';
			if(mapID == 0){
				mapName = '未知的地图';
			}else{
				mapName = WorldManager.getMapName(mapID);
			}
			
			if(jobName == name || jobID == 0){
				jobName = '';
			}
			
			return {
				'id':npcID, 'name':name, 
				'jobID':jobID, 'jobName':jobName, 
				'avatar':'com/npcs/'+avatar, 
				'skin':skin, 'content':content, 'type':type, 
				'mapID':mapID, 'mapName':mapName, 'canSearchWay':canSearchWay, 'color':color};
		}
		
		/**
		 * 获取NPC功能列表
		 */
		public function getNPCActionArr(npcID:int):Array {
			
			var npcBaseObj:Object = this._npcBaseDataObj[npcID];
			if(!npcBaseObj){
				return [];
			}
			
			var actionIDArr:Array = npcBaseObj[NPC_BASE_ACTION_INDEX];
			var actionArr:Array = [];
			for each(var actionID:int in actionIDArr){
				if(actionID == 0 || !this.authShowAction(this._npcActionObj[actionID])) {
					continue;
				}
				actionArr.push(this._npcActionObj[actionID]);
			}
			
			return actionArr;
		}
		
		/**
		 * 验证该链接是否能显示
		 */
		private function authShowAction(_actionData:Array):Boolean{
			if(!_actionData){
				return false;
			}
		
			// 0 为Action 
			//ID 61为创建门派
			var actionID:int = _actionData[0];
			if (actionID == 61 && GlobalObjectManager.getInstance().user.base.family_id > 0) {
				return false;
			}
			// 创建门派地图
			if (actionID == 62) {
				if (FamilyLocator.getInstance().familyInfo && FamilyLocator.getInstance().familyInfo.faction_id > 0) {
					if (GlobalObjectManager.getInstance().getRoleID() == FamilyLocator.getInstance().familyInfo.owner_role_id) {
						if (FamilyLocator.getInstance().familyInfo.enable_map) {
							return false;
						}
					} else {
						if (FamilyLocator.getInstance().familyInfo.enable_map) {
							return false;
						}
					}
				} else {
					return false;
				}
			}
			// 加入门派
			if (actionID == 63) {
				if (GlobalObjectManager.getInstance().getFamilyID() > 0) {
					return false;
				}
			}
			// 门派合并
			if (actionID == 66) {
				if (GlobalObjectManager.getInstance().getFamilyID() == 0) {
					return false;
				} else {
					if (GlobalObjectManager.getInstance().getRoleID() != FamilyLocator.getInstance().familyInfo.owner_role_id) {
						return false;
					}
				}
			}
			
			// 临时屏蔽门派合并功能
			if (actionID == 66) {
				return false;
			}
			
			// 国运镖车
			if (actionID == 45) {
				var startTime:int = PersonalYbcModule.getInstance().view.info_toc.info.faction_start_time;
				if (startTime > 0) {
					var limitTime:int = PersonalYbcModule.getInstance().view.info_toc.info.faction_time_limit;
					if ((startTime > SystemConfig.serverTime) || startTime + limitTime < SystemConfig.serverTime) {
						return false;
					}
				} else {
					return false;
				}
			}
			//升级导师资格
			if(actionID==96||actionID==67)
				return EducateModule.getInstance().hasTeacherTitle();			
			
			if(actionID==72)
				return (!EducateModule.getInstance().hasTeacherTitle()&&GlobalObjectManager.getInstance().user.attr.level>=25);
			if(actionID==73||actionID==74)
				return EducateModule.getInstance().educateInfo.moral_values>0;
			if(actionID==70)
				return EducateModule.getInstance().hasTeacher();
			if(actionID==71)
				return EducateModule.getInstance().educateInfo.student_num > 0;
			return true;
		}
		
	}
}

class singleton {
}