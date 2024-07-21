package modules.mission {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.scene.WorldManager;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.HtmlUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.mission.vo.MissionBaseIndex;
	import modules.mission.vo.MissionCitanRewardIndex;
	import modules.mission.vo.MissionGroupRewardIndex;
	import modules.mission.vo.MissionPreviewIndex;
	import modules.mission.vo.MissionPropRewardVO;
	import modules.mission.vo.MissionRewardVO;
	import modules.mission.vo.MissionShouBianRewardIndex;
	import modules.mission.vo.MissionStatusCollectIndex;
	import modules.mission.vo.MissionStatusDataIndex;
	import modules.mission.vo.MissionStatusNPCIndex;
	import modules.mission.vo.MissionVO;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.npc.NPCDataManager;
	import modules.playerGuide.GuideConstant;
	import modules.playerGuide.PlayerGuideModule;
	import modules.spy.SpyModule;
	
	import proto.common.p_role_attr;
	import proto.common.p_role_base;
	import proto.line.m_mission_cancel_tos;
	import proto.line.p_mission_info;
	import proto.line.p_mission_listener;


	public class MissionDataManager {

		public function MissionDataManager(singleton:singleton) {
			if (singleton) {
				super();
			} else {
				throw new Error("MissionDataManager Singleton.");
			}
		}

		private static var instance:MissionDataManager;
		
		public static function getInstance():MissionDataManager {
			if (instance == null) {
				instance=new MissionDataManager(new singleton());
			}
			return instance;
		}

		/**
		 * 初始化任务数据
		 */
		private var _baseInfoList:Object={};

		public function initBaseList(listBytes:ByteArray):void {
			listBytes.uncompress();
			this._baseInfoList=new Object();

			while (listBytes.bytesAvailable > 0) {
				var baseDataArr:Array;
				baseDataArr=listBytes.readObject();
				this._baseInfoList[baseDataArr[0]]=baseDataArr;
			}
		
		}

		/**
		 * 获取任务基础信息
		 */
		public function getBase(missionID:int):Array {
			return this._baseInfoList[missionID];
		}

		/**
		 * 任务列表/NPC列表
		 */
		private var _currentMissionList:Object;
		private var _canAcceptMissionList:Object;
		private var _autoMissionList:Array;
		private var _npcMissionList:Object;
		
		/**
		 * 重新初始化任务列表
		 */
		public function initMissionList(pinfoList:Array):void {
			
			this._mainMission = null;
			if(this._npcMissionList){
				for(var npcID:String in this._npcMissionList){
					NPCTeamManager.removeNPCSign(npcID);
				}
			}
			
			this._currentMissionList=new Object();
			this._canAcceptMissionList=new Object();

			this._npcMissionList=new Object();
			for each (var pinfo:p_mission_info in pinfoList) {
				this.formatRenderVO(pinfo);
			}
			
			this.dispatchMissionListUpdate();
		}

		/**
		 * 根据删除列表和更新列表来有选择的更新玩家任务列表
		 */
		public function updateMissionList(delList:Array, updateList:Array):void {

			this._mainMission = null;
			for each (var delMissionID:int in delList) {
				var oldMissionVO:MissionVO=this.getListMission(delMissionID);
				if (oldMissionVO) {
					switch (oldMissionVO.model) {
						case MissionConstant.MODEL_9:
							Dispatch.dispatch(ModuleCommand.MISSION_REMOVE_SHOU_BIAN_TIME_VIEW);
							break;
						default:
							break;
					}
				}
				this.removeFromCanAcceptList(delMissionID);
				this.removeFromCurrentList(delMissionID);

			}
			
			for each (var pinfo:p_mission_info in updateList) {
				this.formatRenderVO(pinfo);
			}
			
			this.dispatchMissionListUpdate();
		}

		/**
		 * 单条更新可接任务列表
		 */
		public function updateCanAcceptList(missionVO:MissionVO):void {
			var missionID:int=missionVO.id;
			if (this._canAcceptMissionList[missionID]) {
				if (missionVO.currentStatus != MissionConstant.STATUS_ACCEPT) {
					this._canAcceptMissionList[missionID]=null;
					delete this._canAcceptMissionList[missionID];
				} else {
					this._canAcceptMissionList[missionVO.id]=missionVO;
				}
			} else if (missionVO.currentStatus == MissionConstant.STATUS_ACCEPT) {
				this._canAcceptMissionList[missionVO.id]=missionVO;
			}
		}

		/**
		 * 从可接列表中将某个任务移除
		 */
		private function removeFromCanAcceptList(delMissionID:int):void {
			if (this._canAcceptMissionList && this._canAcceptMissionList[delMissionID]) {
				var missionVO:MissionVO=this._canAcceptMissionList[delMissionID] as MissionVO;
				for each (var npcID:int in missionVO.statusNpcList) {
					this.removNpcMission(npcID, missionVO.id);
				}
				this._canAcceptMissionList[delMissionID]=null
				delete this._canAcceptMissionList[delMissionID];
			}
		}

		/**
		 * 单条更新当前任务列表
		 */
		public function updateCurrentList(missionVO:MissionVO):void {
			var missionID:int=missionVO.id;
			if (this._currentMissionList[missionID]) {
				if (missionVO.currentStatus == MissionConstant.STATUS_ACCEPT) {
					this._currentMissionList[missionID]=null;
					delete this._currentMissionList[missionID];
				} else {
					this._currentMissionList[missionVO.id]=missionVO;
				}
			} else if (missionVO.currentStatus != MissionConstant.STATUS_ACCEPT) {
				this._currentMissionList[missionVO.id]=missionVO;
			}
		}

		/**
		 * 从当前已接列表中将某个任务移除
		 */
		private function removeFromCurrentList(delMissionID:int):void {
			if (this._currentMissionList[delMissionID]) {
				var missionVO:MissionVO=this._currentMissionList[delMissionID] as MissionVO;
				for each (var npcID:int in missionVO.statusNpcList) {
					this.removNpcMission(npcID, missionVO.id);
				}
				this._currentMissionList[delMissionID]=null
				delete this._currentMissionList[delMissionID];
			}
		}

		/**
		 * 当前任务已经排序好的任务ID列表
		 */
		private var _currentMissionSortedIDList:Array;
		public function get currentMissionSortedIDList():Array{
			if(!this._currentMissionSortedIDList){
				this._currentMissionSortedIDList = this.sortMission(this._currentMissionList);
			}
			return _currentMissionSortedIDList;
		}
		
		/**
		 * 获取当前任务列表
		 */
		public function get currentMissionList():Object {
			return this._currentMissionList;
		}

		
		/**
		 * 可接任务已经排序好的任务ID列表
		 */
		private var _canAcceptMissionSortedIDList:Array;
		public function get canAcceptMissionSortedIDList():Array{
			if(!this._canAcceptMissionSortedIDList){
				this._canAcceptMissionSortedIDList = this.sortMission(this._canAcceptMissionList);
			}
			return _canAcceptMissionSortedIDList;
		}
		
		/**
		 * 获取可接任务列表
		 */
		public function get canAcceptMissionList():Object {
			return this._canAcceptMissionList;
		}
		
		public function set autoMissionList(value:Array):void{
			_autoMissionList = value;
		}
		
		public function get autoMissionList():Array{
			return _autoMissionList;
		}
		
		/**
		 * 从玩家任务列表中获取一条任务
		 */
		public function getListMission(missionID:int):MissionVO {
			if (this._canAcceptMissionList[missionID]) {
				return this._canAcceptMissionList[missionID] as MissionVO;
			} else {
				return this._currentMissionList[missionID] as MissionVO;
			}
		}

		/**
		 * 存放排序好的各个NPC身上的任务
		 */
		private var _npcMissionSorted:Object;
		/**
		 * 获取排序好的NPC任务ID列表
		 */
		public function getNpcMissionIDListSorted(npcID:int):Array{
			if(!this._npcMissionSorted){
				this._npcMissionSorted = {};
			}
			
			if(!this._npcMissionSorted[npcID]){
				var missionList:Object = this.getNpcMissionList(npcID);
				if(missionList){
					this._npcMissionSorted[npcID] = this.sortMission(missionList);
				}
			}
			
			return this._npcMissionSorted[npcID];
		}
		
		/**
		 * 获取NPC身上的任务
		 */
		public function getNpcMissionList(npcID:int):Object {
			
			if (!this._npcMissionList) {
				return null;
			}
			
			return this._npcMissionList[npcID];
		}

		/**
		 * 对任务数组进行排序
		 */
		private function sortMission(missionList:Object):Array{
			var sortedArr:Array = [];
			for each(var missionVO:MissionVO in missionList){
				var missionSortID:int = missionVO.sortID;
				var sortedLength:int = sortedArr.length;
				var replaceMissionVO:MissionVO;
				
				if(sortedLength > 0){
					var insertIndex:int = 0;
					var needSwap:Boolean = false;
					for(var i:int = 0; i < sortedLength; i++){
						replaceMissionVO = missionList[sortedArr[i]] as MissionVO;
						var replaceSortID:int = replaceMissionVO.sortID;
						insertIndex = i;
						if(missionSortID >= replaceSortID){
							needSwap = true;
							break;
						}
					}	
					if(needSwap){
						sortedArr[insertIndex] = missionVO.id;
						sortedArr.splice(insertIndex+1, 0, replaceMissionVO.id);
					}else{
						sortedArr.push(missionVO.id);
					}
				}else{
					sortedArr.push(missionVO.id);
				}
			}
			return sortedArr;
		}
		
		
		/**
		 * 任务列表更新时调用
		 */
		public function dispatchMissionListUpdate():void {
			this._npcMissionSorted = null;
			this._currentMissionSortedIDList = null
			this._canAcceptMissionSortedIDList = null;
		
			var previewMission:MissionVO = this.getPreviewMission();
			if(previewMission != null){
				this.canAcceptMissionList[previewMission.id] = previewMission;
			}
			
			Dispatch.dispatch(ModuleCommand.MISSION_LIST_UPDATE);
			//更新NPC头上的任务标记
			for(var npcID:String in this._npcMissionList){
				NPCTeamManager.updateNPCSign(npcID);
			}
			Dispatch.dispatch(GuideConstant.TASK_LIST_UPDATE, this.currentMissionList);
		}
		
		/**
		 * 获取当前的主线任务  用于新手引导 
		 * 
		 */		
		public function getMainMission():MissionVO
		{
			return _mainMission;
		}
		
		/**
		 * 保存主线任务，用于新手引导 
		 */		
		private var _mainMission:MissionVO;

		/**------------------------各个模型数据渲染区--Start------------------------------**/

		private function formatRenderVO(pinfo:p_mission_info):MissionVO {
			
			var baseInfo:Array=this.getBase(pinfo.id);
			var statusArrData:Array=baseInfo[MissionBaseIndex.STATUS_DATA][pinfo.current_model_status];
			
			if(!statusArrData){
				var cancelVO:m_mission_cancel_tos = new m_mission_cancel_tos();
				cancelVO.id = pinfo.id;
				Dispatch.dispatch(ModuleCommand.MISSION_CANCEL, cancelVO);
				return null;
			}
			
			var missionVO:MissionVO=new MissionVO();
			missionVO.currentStatus=pinfo.current_status;
			missionVO.currentModelStatus=pinfo.current_model_status;
			missionVO.preModelStatus=pinfo.pre_model_status;
			missionVO.succTimes = pinfo.succ_times;
			missionVO.pinfo_int_list_1=pinfo.int_list_1;
			missionVO.pinfo_int_list_2=pinfo.int_list_2;
			missionVO.pinfo_int_list_3=pinfo.int_list_3;
			missionVO.pinfo_int_list_4=pinfo.int_list_4;
			missionVO.commitTimes = pinfo.commit_times;
			
			missionVO.npcDialogues=new Object();
			missionVO.maxModelStatus=baseInfo[MissionBaseIndex.MAX_MODEL_STATUS];
			missionVO.smallGroup = baseInfo[MissionBaseIndex.SMALL_GROUP];
			missionVO.bigGroup = baseInfo[MissionBaseIndex.BIG_GROUP];
			
			missionVO.maxDotimes = baseInfo[MissionBaseIndex.MAX_DO_TIMES];
				
			//清理旧状态的NPC 否则已经搞定的NPC还会继续显示
			var oldMissionVO:MissionVO=this.getListMission(pinfo.id);
			//假如任务已经在列表里了才要处理
			if (oldMissionVO && oldMissionVO.statusNpcList) {
				for each (var npcIDOld:int in oldMissionVO.statusNpcList) {
					this.removNpcMission(npcIDOld, oldMissionVO.id);
				}
			}

			var statusNPCArr:Array=statusArrData[MissionStatusDataIndex.I_NPC_LIST];
			var statusNPCList:Vector.<int>=new Vector.<int>();
			for each (var statusNPC:Array in statusNPCArr) {
				var npcIDNew:int=statusNPC[MissionStatusNPCIndex.I_NPCID];
				var dialogues:Array=statusNPC[MissionStatusNPCIndex.I_DIALOGUES];
				missionVO.npcDialogues[npcIDNew]=dialogues;
				statusNPCList.push(npcIDNew);
			}

			missionVO.statusCollectList=statusArrData[MissionStatusDataIndex.I_COLLECT_LIST];
			missionVO.statusTimeLlimit=parseInt(statusArrData[MissionStatusDataIndex.I_TIME_LIMIT]);
			
			var rewardArrData:Array=baseInfo[MissionBaseIndex.REWARD_DATA];
			var rewardVOData:MissionRewardVO=new MissionRewardVO();
			rewardVOData.attr_reward_formula=rewardArrData[MissionRewardVO.I_ATTR_REWARD_FORMULA];
			rewardVOData.exp=rewardArrData[MissionRewardVO.I_EXP];
			rewardVOData.prestige = rewardArrData[MissionRewardVO.I_PRESTIGE];//声望
			var propRewardArr:Array=rewardArrData[MissionRewardVO.I_PROP_REWARD];
			rewardVOData.prop_reward=new Vector.<MissionPropRewardVO>();
			for each (var propReward:Array in propRewardArr) {
				var propRewardVO:MissionPropRewardVO=new MissionPropRewardVO();
				propRewardVO.prop_id=propReward[MissionPropRewardVO.I_PROP_ID];
				propRewardVO.prop_type=propReward[MissionPropRewardVO.I_PROP_TYPE];
				propRewardVO.prop_num=propReward[MissionPropRewardVO.I_PROP_NUM];
				propRewardVO.bind=propReward[MissionPropRewardVO.I_BIND];
				rewardVOData.prop_reward.push(propRewardVO);
			}
			
			rewardVOData.prop_reward_formula=rewardArrData[MissionRewardVO.I_PROP_REWARD_FORMULA];
			rewardVOData.rollback_times=rewardArrData[MissionRewardVO.I_ROLLBACK_TIMES];
			rewardVOData.silver=rewardArrData[MissionRewardVO.I_SILVER];
			rewardVOData.silver_bind=rewardArrData[MissionRewardVO.I_SILVER_BIND];

			missionVO.rewardData=rewardVOData;

			missionVO.statusNpcList=statusNPCList;
			missionVO.id=baseInfo[MissionBaseIndex.ID];
			missionVO.model=baseInfo[MissionBaseIndex.MODEL];
			missionVO.desc=baseInfo[MissionBaseIndex.DESC];
			missionVO.name=baseInfo[MissionBaseIndex.NAME];
			
			var nameRegExp:RegExp = /\d?/g;
			
			missionVO.name = missionVO.name.replace(nameRegExp, '');
			missionVO.type=baseInfo[MissionBaseIndex.TYPE];
			
			var followTitle:String = this.htmlFMType(missionVO.type)+'<font color="#ffde5a">'+missionVO.name+'</font>';
			
			if(missionVO.currentModelStatus == missionVO.maxModelStatus){
				missionVO.followTitle = followTitle+'<font color="#39ff0b">（可提交）</font>\n';
			} else if(missionVO.currentModelStatus == MissionConstant.FIRST_STATUS){
				missionVO.followTitle = followTitle+'<font color="#39ff0b">（可接）</font>\n';
			} else{
				//对守边进行特殊处理 
				if( missionVO.model == MissionConstant.MODEL_9 
					&& missionVO.currentStatus == MissionConstant.STATUS_FINISH ){
					missionVO.followTitle = followTitle+'<font color="#39ff0b">（可提交）</font>\n';
				}else{
					missionVO.followTitle = followTitle+'<font color="#FF0000">（进行中）</font>\n';
				}
				
			}
				

			missionVO.statusChangeTime=pinfo.status_change_time;
			missionVO.acceptLevel=pinfo.accept_level;
			missionVO.acceptTime=pinfo.accept_time;
			
			missionVO.listenerList=new Object();
			for each (var listener:p_mission_listener in pinfo.listener_list) {
				var listenerKey:String = "";
				listenerKey = listener.type + '_' + listener.value;
				missionVO.listenerList[listenerKey]=listener;
			}
			
			missionVO.sortID = MissionConstant.STATUS_SORT_BY[missionVO.currentStatus];
			missionVO.sortID += MissionConstant.TYPE_SORT_BY[missionVO.type];
			
			//拼装过程放在这里 是防止不同模型有自己特殊的拼装要求
			this.addNpcMission(missionVO);
			this.makeMissionVO(missionVO);
			
			this.updateCanAcceptList(missionVO);
			this.updateCurrentList(missionVO);
			
			if (missionVO.type ==  MissionConstant.TYPE_MAIN) {
				this._mainMission = missionVO;
			}
			
			if(missionVO.currentModelStatus == missionVO.maxModelStatus){
				PlayerGuideModule.getInstance().hookMissionCanCommit(missionVO);
			}
			
			return missionVO;
		}
		

		/**
		 * 生成任务预告vo
		 */
		public function getPreviewMission():MissionVO{
			
			if(this.getMainMission() != null){
				return null;
			}
			
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level+1;
			var missionID:int = this._setting['preview'][roleLevel];
			if(!missionID){
				return null;
			}
			
			var missionVO:MissionVO = new MissionVO();
			var baseInfo:Array=this.getBase(missionID);
			var statusArrData:Array=baseInfo[MissionBaseIndex.STATUS_DATA][MissionConstant.FIRST_STATUS];
			
			missionVO.currentStatus=MissionConstant.STATUS_ACCEPT;
			missionVO.currentModelStatus=MissionConstant.FIRST_STATUS;
			missionVO.preModelStatus=MissionConstant.FIRST_STATUS;
			missionVO.succTimes = 0;
			missionVO.pinfo_int_list_1=[];
			missionVO.pinfo_int_list_2= [];
			missionVO.pinfo_int_list_3= [];
			missionVO.pinfo_int_list_4= [];
			missionVO.commitTimes = 0;
			missionVO.isPreview = true;
			missionVO.npcDialogues=new Object();
			missionVO.maxModelStatus=baseInfo[MissionBaseIndex.MAX_MODEL_STATUS];
			missionVO.smallGroup = baseInfo[MissionBaseIndex.SMALL_GROUP];
			missionVO.bigGroup = baseInfo[MissionBaseIndex.BIG_GROUP];
			
			missionVO.maxDotimes = baseInfo[MissionBaseIndex.MAX_DO_TIMES];
			
			
			
			missionVO.statusCollectList=[];
			missionVO.statusTimeLlimit=0;
			
			var rewardArrData:Array=baseInfo[MissionBaseIndex.REWARD_DATA];
			var rewardVOData:MissionRewardVO=new MissionRewardVO();
			rewardVOData.attr_reward_formula=rewardArrData[MissionRewardVO.I_ATTR_REWARD_FORMULA];
			rewardVOData.exp=rewardArrData[MissionRewardVO.I_EXP];
			var propRewardArr:Array=rewardArrData[MissionRewardVO.I_PROP_REWARD];
			rewardVOData.prop_reward=new Vector.<MissionPropRewardVO>();
			for each (var propReward:Array in propRewardArr) {
				var propRewardVO:MissionPropRewardVO=new MissionPropRewardVO();
				propRewardVO.prop_id=propReward[MissionPropRewardVO.I_PROP_ID];
				propRewardVO.prop_type=propReward[MissionPropRewardVO.I_PROP_TYPE];
				propRewardVO.prop_num=propReward[MissionPropRewardVO.I_PROP_NUM];
				propRewardVO.bind=propReward[MissionPropRewardVO.I_BIND];
				rewardVOData.prop_reward.push(propRewardVO);
			}
			
			rewardVOData.prop_reward_formula=rewardArrData[MissionRewardVO.I_PROP_REWARD_FORMULA];
			rewardVOData.rollback_times=rewardArrData[MissionRewardVO.I_ROLLBACK_TIMES];
			rewardVOData.silver=rewardArrData[MissionRewardVO.I_SILVER];
			rewardVOData.silver_bind=rewardArrData[MissionRewardVO.I_SILVER_BIND];
			
			missionVO.rewardData=rewardVOData;
			
			missionVO.statusNpcList=new Vector.<int>();
			missionVO.id=baseInfo[MissionBaseIndex.ID];
			missionVO.model=baseInfo[MissionBaseIndex.MODEL];
			missionVO.desc=baseInfo[MissionBaseIndex.DESC];
			missionVO.name=baseInfo[MissionBaseIndex.NAME];
			
			var nameRegExp:RegExp = /\d?/g;
			
			var minLV:int = baseInfo[MissionBaseIndex.MIN_LEVEL];
			missionVO.name = missionVO.name.replace(nameRegExp, '');
			missionVO.type=baseInfo[MissionBaseIndex.TYPE];
			
			var followTitle:String = this.htmlFMType(missionVO.type)+'<font color="#ffde5a">'+missionVO.name+'（'+minLV+'级可接）</font>';
			missionVO.followTitle = followTitle;
			
			missionVO.statusChangeTime=0;
			missionVO.acceptLevel=0;
			missionVO.acceptTime=0;
			
			missionVO.listenerList=new Object();
			
			missionVO.sortID = MissionConstant.STATUS_SORT_BY[missionVO.currentStatus];
			missionVO.sortID += MissionConstant.TYPE_SORT_BY[missionVO.type];
			
			this.makeMissionVO(missionVO);
			
			return missionVO;
		}
		
		//TODO构造整整的NPC任务列表数据
		/**
		 * 将任务插入到npc身上
		 */
		private function addNpcMission(missionVO:MissionVO):void {
			for each (var npcID:int in missionVO.statusNpcList) {
				if (!this._npcMissionList[npcID]) {
					this._npcMissionList[npcID]=new Object;
				}
				this._npcMissionList[npcID][missionVO.id]=missionVO;
			}
		}

		/**
		 * 将一个任务从NPC身上移除
		 */
		private function removNpcMission(npcID:int, missionID:int):void {
			if (this._npcMissionList[npcID]) {
				if (this._npcMissionList[npcID][missionID] != null) {
					delete this._npcMissionList[npcID][missionID];
				}
			}
		}
		
		/**
		 * case不同模型渲染数据
		 */
		public function makeMissionVO(missionVO:MissionVO):MissionVO {
			switch (missionVO.model) {
				//打怪模型
				case MissionConstant.MODEL_2:
					if (this.isFirstOrLast(missionVO)) {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					} else {
						missionVO=this.makeMissionVO_Monster(missionVO);
					}
					break;

				case MissionConstant.MODEL_3:
					if (this.isFirstOrLast(missionVO)) {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					} else {
						missionVO=this.makeMissionVO_MonsterProp(missionVO);
					}
					break;

				case MissionConstant.MODEL_4:
				case MissionConstant.MODEL_5:
					if (this.isFirstOrLast(missionVO)) {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					} else {
						missionVO=this.makeMissionVO_Prop(missionVO);
					}
					break;
				
				case MissionConstant.MODEL_6:
					if (this.isFirstOrLast(missionVO)) {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					} else {
						missionVO=this.makeMissionVO_ShopBuyProp(missionVO);
					}
					break;
					
				//3次对话第一次给道具
				case MissionConstant.MODEL_7:
					if (this.isFirst(missionVO)) {
						missionVO=this.makeMissionVO_Prop(missionVO);
					} else {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					}
					break;

				case MissionConstant.MODEL_8:
					if (this.isFirstOrLast(missionVO)) {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					} else {
						missionVO=this.makeMissionVO_Collect(missionVO);
					}
					break;

				case MissionConstant.MODEL_9:
					missionVO=this.makeMissionVO_ShouBian(missionVO);
					break;
				
				case MissionConstant.MODEL_10:
					missionVO=this.makeMissionVO_Citan(missionVO);
					break;
				case MissionConstant.MODEL_12:
					if (this.isFirstOrLast(missionVO)) {
						missionVO=this.makeMissionVO_Dialog(missionVO);
					} else {
						missionVO=this.makeMissionVO_LevelUp(missionVO);
					}
					
					break;
				default:
					missionVO=this.makeMissionVO_Dialog(missionVO);
					break;
			}

			return this.computeReward(missionVO);
		}
		
		
		/**
		 * 返回是否是最后一个状态或是第一个状态
		 */
		private function isFirstOrLast(missionVO:MissionVO):Boolean{
			var result:Boolean = missionVO.currentModelStatus == MissionConstant.FIRST_STATUS;
			return (result ? result : missionVO.currentModelStatus == missionVO.maxModelStatus);
		}
		
		/**
		 * 判断是否是第一个状态
		 */
		private function isFirst(missionVO:MissionVO):Boolean{
			return missionVO.currentModelStatus == MissionConstant.FIRST_STATUS;
		}
		
		private function makeMissionVO_ShouBian(missionVO:MissionVO):MissionVO {
			var shoubianRewardVO:MissionRewardVO=new MissionRewardVO();
			var shouBianReward:Object=this.getShouBianReward(GlobalObjectManager.getInstance().user.attr.level);
			var shouBinSuccExp:int=0;
			var shouBianPropList:Vector.<MissionPropRewardVO>=new Vector.<MissionPropRewardVO>();
			
			if (shouBianReward.status == 'ok') {
				shouBianReward=shouBianReward.data;
				var propArrList:Array=shouBianReward[MissionShouBianRewardIndex.SBR_PROP_INDEX];
				for each (var propArrData:Array in propArrList) {
					var propVO:MissionPropRewardVO=new MissionPropRewardVO();
					propVO.bind=propArrData[MissionPropRewardVO.I_BIND];
					propVO.prop_id=propArrData[MissionPropRewardVO.I_PROP_ID];
					propVO.prop_num=propArrData[MissionPropRewardVO.I_PROP_NUM];
					propVO.prop_type=propArrData[MissionPropRewardVO.I_PROP_TYPE];
					shouBianPropList.push(propVO);
				}
			}
			
			shouBinSuccExp=shouBianReward[MissionShouBianRewardIndex.SBR_SUCC_EXP_INDEX];
			shoubianRewardVO.exp=shouBinSuccExp*(missionVO.succTimes+1);
			shoubianRewardVO.prop_reward=shouBianPropList;
			shoubianRewardVO.prop_reward_formula=MissionRewardVO.PROP_REWARD_FORMULA_CHOOSE_ONE;
			shoubianRewardVO.attr_reward_formula=MissionRewardVO.ATTR_REWARD_FORMULA_CALC_ALL_TIMES;
			shoubianRewardVO.prestige = shouBianReward[MissionShouBianRewardIndex.SBR_SUCC_PRESTIGE_INDEX];//声望
			missionVO.rewardData=shoubianRewardVO;
			missionVO = this.makeMissionVO_Dialog(missionVO);
			
			Dispatch.dispatch(ModuleCommand.MISSION_UPDATE_SHOU_BIAN_TIME_VIEW_VO, missionVO);
			return missionVO;
		}
		
		/**
		 * 渲染刺探任务
		 */
		private function makeMissionVO_Citan(missionVO:MissionVO):MissionVO {
			
			var citanRewardVO:MissionRewardVO=new MissionRewardVO();
			var citanReward:Object=this.getCitanReward(GlobalObjectManager.getInstance().user.attr.level);
			var citanSilverBind:int=0;
			var citanExp:int = 0;
			var citanPrestige:int = 0;
			if (citanReward.status == 'ok') {
				citanReward=citanReward.data;
				var pinfoSPY:int = missionVO.pinfo_int_list_3[0];
				
				if(pinfoSPY == 1 && SpyModule.isInSpyFaction == true){
					//国探	
					citanExp=citanReward[MissionCitanRewardIndex.I_SPY_EXP];
					citanSilverBind=citanReward[MissionCitanRewardIndex.I_SPY_SILVER_BIND];
					citanPrestige = citanReward[MissionCitanRewardIndex.I_SPY_PRESTIGE];
				}else{
					//普通
					citanExp=citanReward[MissionCitanRewardIndex.I_EXP];
					citanSilverBind=citanReward[MissionCitanRewardIndex.I_SILVER_BIND];
					citanPrestige = citanReward[MissionCitanRewardIndex.I_PRESTIGE];
				}
				
			}
			citanRewardVO.exp=citanExp*(missionVO.succTimes+1);
			citanRewardVO.silver_bind=citanSilverBind*(missionVO.succTimes+1);
			citanRewardVO.prestige = citanPrestige;
			citanRewardVO.prop_reward_formula=MissionRewardVO.PROP_REWARD_FORMULA_ALL;//后策划如果要修改刺探道具为选择 请改这里
			citanRewardVO.attr_reward_formula=MissionRewardVO.ATTR_REWARD_FORMULA_CALC_ALL_TIMES;
			missionVO.rewardData=citanRewardVO;
			citanRewardVO.prop_reward = new Vector.<MissionPropRewardVO>();
			
			var npcID:int = 0;
			if(missionVO.currentModelStatus == MissionConstant.CI_TAN_STATUS_DOING){
				var intList2:Array = missionVO.pinfo_int_list_2;
				npcID = intList2[0];
				//这里其实可以销毁另一个没有选择到的npc的npc_dialogues数据的 算了 麻烦
				missionVO.statusNpcList = new Vector.<int>();
				missionVO.statusNpcList.push(npcID);
			}else{
				//很明显 刺探每个状态只有一只npc 就不用循环遍历了
				npcID = missionVO.statusNpcList[0];
			}
			
			missionVO.target=this.htmlFNPC(missionVO.id, npcID);
			missionVO = this.makeMissionVO_Dialog(missionVO);
			
			return missionVO;
		}
		
		/**
		 * 渲染对话任务
		 */
		private function makeMissionVO_Dialog(missionVO:MissionVO):MissionVO {

			var targetArr:Array=[];
			for each (var npcID:int in missionVO.statusNpcList) {
				targetArr.push(this.htmlFNPC(missionVO.id, npcID));
				missionVO.targetName = getNpcName(npcID);
				missionVO.targetId = npcID;
			}
			missionVO.target=targetArr.join('\n');
			return missionVO;
		}

		/**
		 * 渲染打怪任务
		 */
		private function makeMissionVO_Monster(missionVO:MissionVO):MissionVO {
			//TODO 渲染怪物名字 坐标等
			var targetArr:Array=[];

			if (missionVO.currentModelStatus == 1) {
				for each (var listener2:p_mission_listener in missionVO.listenerList) {
					var suffix:String='（' + listener2.current_num + '/' + listener2.need_num + '）';
					var monsterTypeID:int = listener2.value;
					var targetStr:String = htmlFMonster(missionVO.id, listener2.int_list[0], listener2.value, suffix);
					targetArr.push(targetStr);
					missionVO.targetName = getMonsterName(monsterTypeID);
					missionVO.targetId = monsterTypeID;
				}
			} else {
				for each (var npcID:int in missionVO.statusNpcList) {
					targetArr.push(this.htmlFNPC(missionVO.id, npcID));
					missionVO.targetName = getNpcName(npcID);
					missionVO.targetId = npcID;
				}
			}
			
			missionVO.target=targetArr.join('\n');
			return missionVO;
		}

		
		/**
		 * 渲染道具搜集任务
		 */
		private function makeMissionVO_Prop(missionVO:MissionVO):MissionVO {
			var targetArr:Array=[];

			for each (var listener2:p_mission_listener in missionVO.listenerList) {
				var suffix:String = '（' + listener2.current_num + '/' + listener2.need_num + '）';
				var npcID:int = listener2.int_list[0];
				targetArr.push(this.htmlFProp(missionVO.id, listener2.int_list[0], listener2.value, suffix));
				missionVO.targetName = getNpcName(npcID);
				missionVO.targetId = npcID;
			}

			missionVO.target=targetArr.join('');
			return missionVO;
		}

		/**
		 * 渲染道具搜集任务
		 */
		private function makeMissionVO_MonsterProp(missionVO:MissionVO):MissionVO {
			//TODO 渲染怪物名字 坐标等
			var targetArr:Array=[];
			var nearlyStepNum:int=0;

			if (missionVO.currentModelStatus == 1) {
				for each (var listener2:p_mission_listener in missionVO.listenerList) {
					var suffix:String = '（'+listener2.current_num+'/'+listener2.need_num+'）';
					var monsterTypeID:int = listener2.int_list[1];
					var targetStr:String = this.htmlFMonsterProp(
											missionVO.id, 
											listener2.int_list[0], 
											listener2.int_list[1], 
											listener2.value, 
											suffix);
					targetArr.push(targetStr);
					missionVO.targetName = getMonsterName(monsterTypeID);
					missionVO.targetId = monsterTypeID;
				}
			} else {
				for each (var npcID:int in missionVO.statusNpcList) {
					targetArr.push(this.htmlFNPC(missionVO.id, npcID));
					missionVO.targetName = getNpcName(npcID);
					missionVO.targetId = npcID;
				}
			}
			
			missionVO.target=targetArr.join('\n');
			return missionVO;
		}

		/**
		 * 渲染采集搜集任务
		 */
	
		private function makeMissionVO_Collect(missionVO:MissionVO):MissionVO {
			
			var targetArr:Array=[];

			if (missionVO.currentModelStatus == 1) {
				for each (var collectData:Array in missionVO.statusCollectList) {
					var mapID:int=collectData[MissionStatusCollectIndex.I_MAP];
					var pointName:String=collectData[MissionStatusCollectIndex.I_POINT_NAME];
					var tx:int = collectData[MissionStatusCollectIndex.I_TX];
					var ty:int = collectData[MissionStatusCollectIndex.I_TY];
					
					var propTypeID:int=collectData[MissionStatusCollectIndex.I_PROP];
					var listenerKey:String=MissionConstant.LISTENER_TYPE_PROP + '_' + propTypeID;
					var listener2:p_mission_listener=missionVO.listenerList[listenerKey];
					
					var suffix:String='（' + listener2.current_num + '/' + listener2.need_num + '）';
					var pointBaseID:int = collectData[MissionStatusCollectIndex.I_BASEID];
					targetArr.push(this.htmlFCollect(missionVO.id, mapID, pointName, pointBaseID, propTypeID, tx, ty, suffix));
					missionVO.targetName = getCollectPropName(propTypeID);
					missionVO.targetId = propTypeID;
				}
			} else {
				for each (var npcID:int in missionVO.statusNpcList) {
					targetArr.push(this.htmlFNPC(missionVO.id, npcID));
					missionVO.targetName = getNpcName(npcID);
					missionVO.targetId = npcID;
				}
			}
			
			missionVO.target=targetArr.join('\n');
			return missionVO;
		}

		/**
		 * 获得道具名称 
		 * @param propTypeID
		 */		
		private function getCollectPropName( propTypeID:int ):String {
			var baseItemVO:BaseItemVO=ItemLocator.getInstance().getObject( propTypeID );
			if( baseItemVO ){
				return baseItemVO.name;	
			}else{
				return "";
			}
			
		}

		/**
		 * 获得NPC名称 
		 * @param npcID
		 */		
		private function getNpcName( npcID:int ):String {
			var npcInfo:Object=NPCDataManager.getInstance().getNpcInfo( npcID );
			if( npcInfo ){
				return npcInfo.name;	
			}else{
				return "";
			}
			
		}

		/**
		 * 获得怪物名称 
		 * @param monsterTypeID
		 */		
		private function getMonsterName( monsterTypeID:int ):String {
			var monster:MonsterType=MonsterConfig.hash[ monsterTypeID ];
			if( monster ){
				return monster.monstername;	
			}else{
				return "";
			}
			
		}


		private function makeMissionVO_LevelUp( missionVO:MissionVO ):MissionVO {
			//TODO 渲染怪物名字 坐标等
			var targetArr:Array = [];
			var targetStr:String;
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;

			if ( missionVO && missionVO.listenerList ) {
				for each ( var model12Listener:p_mission_listener in missionVO.listenerList ) {
					if( model12Listener.type == MissionConstant.MISSION_LISTENER_TYPE_ROLE_LEVEL ){
						var toLevel:int = model12Listener.value;
						targetStr = htmlFLevelUp(roleLevel,toLevel);
						targetArr.push( targetStr );
						break;
					}
				}
			}

			missionVO.target = targetArr.join( '\n' );
			missionVO.targetName = "";
			missionVO.targetId = 0;
			return missionVO;
		}
		
		
		/**
		 * 渲染在商城购买道具 
		 * @param missionVO
		 * @return MissionVO
		 * 
		 */		
		private function makeMissionVO_ShopBuyProp(missionVO:MissionVO):MissionVO {
			//TODO 渲染怪物名字 坐标等
			var targetArr:Array=[];
			var targetStr:String;
			
			if(missionVO && missionVO.listenerList){
				for each(var model6Listener:p_mission_listener in missionVO.listenerList){
					var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(model6Listener.value);
					var shopID:int = model6Listener.int_list[0];
					if(baseItemVO){
						targetStr =  htmlFShopBuyProp(missionVO.id, shopID, baseItemVO.name, model6Listener.need_num);
						targetArr.push(targetStr);
					}
				}
			}
			
			if(targetArr.length == 0){
				targetArr = [ htmlFShopBuyProp(missionVO.id)];
			}
			
			missionVO.target= targetArr.join('\n');
			missionVO.targetName = "";
			missionVO.targetId = 0;
			return missionVO;
		}

		/**
		 * 根据奖励公式返回正确的奖励值
		 */
		private function computeReward(missionVO:MissionVO):MissionVO {
			if(missionVO.bigGroup > 0){
				//处理分组任务的奖励数据
				//分组任务的奖励是放在前端独立配置文件的 mission_setting.txt
				
				var level:int = GlobalObjectManager.getInstance().user.attr.level;
				var groupRewardData:Object = MissionDataManager.getInstance().getGroupReward(missionVO.bigGroup, level);
				if(groupRewardData && groupRewardData.status == 'ok'){
					groupRewardData = groupRewardData.data;
					var succTimes:int = missionVO.succTimes+1;
					var rollbackTimes:int = missionVO.rewardData.rollback_times;
					var mulTimes:int = succTimes;
					if(rollbackTimes < succTimes){
						mulTimes = 1;
					}
					missionVO.rewardData.exp = groupRewardData[MissionGroupRewardIndex.GROUP_EXP_INDEX]*mulTimes;
					missionVO.rewardData.silver_bind = groupRewardData[MissionGroupRewardIndex.GROUP_SILVER_BIND_INDEX]*mulTimes;
					missionVO.rewardData.prop_reward_formula=MissionRewardVO.PROP_REWARD_FORMULA_CHOOSE_ONE;
					missionVO.rewardData.attr_reward_formula=MissionRewardVO.ATTR_REWARD_FORMULA_CALC_ALL_TIMES;
					missionVO.rewardData.prestige = groupRewardData[MissionGroupRewardIndex.GROUP_PRESTIGE_INDEX];
					var propListConfig:Array =groupRewardData[MissionGroupRewardIndex.GROUP_PROP_LIST_INDEX][0];
					var propRewardList:Vector.<MissionPropRewardVO> = new Vector.<MissionPropRewardVO>();
					if(propListConfig){
						var propNeedSuccNum:int = propListConfig[MissionGroupRewardIndex.GROUP_PROP_LIST_NUM_INDEX];
						if(propNeedSuccNum == succTimes){
							var propList:Array = propListConfig[MissionGroupRewardIndex.GROUP_PROP_LIST_PROP_INDEX];
							for each(var propArr:Array in propList){
								var propVO:MissionPropRewardVO = new MissionPropRewardVO();
								propVO.bind = propArr[MissionGroupRewardIndex.GROUP_PROP_PROP_BIND];
								propVO.prop_id = propArr[MissionGroupRewardIndex.GROUP_PROP_PROP_ID];
								propVO.prop_num = propArr[MissionGroupRewardIndex.GROUP_PROP_PROP_NUM];
								propVO.prop_type = propArr[MissionGroupRewardIndex.GROUP_PROP_PROP_TYPE];
								propRewardList.push(propVO);
							}
						}
					}
					missionVO.rewardData.prop_reward = propRewardList;
				}
			}
			
			//过滤武器、服装、内外功
			if(missionVO.rewardData.prop_reward && missionVO.rewardData.prop_reward.length > 0){
				var roleAttr:p_role_attr = GlobalObjectManager.getInstance().user.attr;
				var roleBase:p_role_base = GlobalObjectManager.getInstance().user.base;
				
				var roleCategory:int = roleAttr.category;//职业
				
				var equipType:int = roleCategory;
				if(roleCategory == GameConfig.CATEGORY_RANGER){
					equipType = GameConfig.CATEGORY_DOCTOR;//该死的策划写反啦
				}else if(roleCategory == GameConfig.CATEGORY_DOCTOR){
					equipType = GameConfig.CATEGORY_RANGER;
				}
				equipType += 100;
				
				var skillBookType:int = roleCategory;
				
				var gender:int = roleBase.sex;
				var attackIO:int = 0;//1外攻 2内攻
				if(roleCategory == GameConfig.CATEGORY_HUNTER || roleCategory == GameConfig.CATEGORY_WARRIOR){
					attackIO = 1;
				}else{
					attackIO = 2;
				}
				
				var propListFiltered:Vector.<MissionPropRewardVO> = new Vector.<MissionPropRewardVO>();
				for each(var propVOFiltered:MissionPropRewardVO in missionVO.rewardData.prop_reward){
					var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(propVOFiltered.prop_id);
					switch(baseItemVO.kind){
						
						//武器
						case 101:
						case 102:
						case 103:
						case 104:
							if(baseItemVO.kind == equipType){
								propVOFiltered.baseItemVO = baseItemVO;
								propListFiltered.push(propVOFiltered);
							}
							break;
						
						//服装
						case 1101:
						case 501:
							var equipVO:Object = ItemLocator.getInstance().getEquip(propVOFiltered.prop_id);
							if(equipVO.sex == 0 || equipVO.sex == gender){
								propVOFiltered.baseItemVO = baseItemVO;
								propListFiltered.push(propVOFiltered);
							}
							break;
						
						//技能书
						case 3:
							var kind:int = parseInt(propVOFiltered.prop_id.toString().substr(3, 2));
							if(kind == skillBookType){
								propVOFiltered.baseItemVO = baseItemVO;
								propListFiltered.push(propVOFiltered);
							}
							break;
						
						//戒指 项链
						case 201:
						case 301:
							var zhaoYangCheck:String = propVOFiltered.prop_id.toString().substr(0, 3); 
							if(zhaoYangCheck == '301'){
								//朝阳套装不区分内外功
								propVOFiltered.baseItemVO = baseItemVO;
								propListFiltered.push(propVOFiltered);
							}else{
								var ioType:int = parseInt(propVOFiltered.prop_id.toString().substr(-1, 1));
								if(ioType == attackIO){
									propVOFiltered.baseItemVO = baseItemVO;
									propListFiltered.push(propVOFiltered);
								}
							}
							break;
						
						default:
							propVOFiltered.baseItemVO = baseItemVO;
							propListFiltered.push(propVOFiltered);
							break;
					}
				}
				
				PlayerGuideModule.getInstance().filterPropReward(missionVO,propListFiltered);
				
				missionVO.rewardData.prop_reward = null;
				missionVO.rewardData.prop_reward = propListFiltered;
			}
			
			return missionVO;
		}

		/**
		 * 任务配置字典
		 * 守边
		 * 分组奖励
		 */
		private var _setting:Dictionary;

		/**
		 * 初始化任务配置
		 * 注意：这里原来设计思路是需要时才开始加载 但没时间实现
		 * 所以 你将看到像 getCitanReward/getGroupRewardKey 会返回status 里面有个奇怪的状态是 loading 其实是不可能出现的 因为没实现
		 */
		public function initMissionSetting(dataBytes:ByteArray):void {
			_setting=new Dictionary();

			dataBytes.uncompress();
			var shouBianRewardArr:Array=dataBytes.readObject();
			_setting['shou_bian_reward']=new Dictionary();
			for each (var shouBianReward:Array in shouBianRewardArr) {
				var sbrLevel:int=shouBianReward[MissionShouBianRewardIndex.SBR_LEVEL_INDEX];
				_setting['shou_bian_reward'][sbrLevel]=shouBianReward;
			}

			var groupRewardArr:Array=dataBytes.readObject();
			_setting['group_reward']=new Dictionary();
			for each (var groupReward:Array in groupRewardArr) {
				var groupLevel:int=groupReward[MissionGroupRewardIndex.GROUP_LEVEL_INDEX];
				var groupID:int=groupReward[MissionGroupRewardIndex.GROUP_ID_INDEX];
				var key:String=this.getGroupRewardKey(groupID, groupLevel);
				_setting['group_reward'][key]=groupReward;
			}

			var citanRewrdArr:Array=dataBytes.readObject();
			_setting['citan_reward']=new Dictionary();
			for each (var citanReward:Array in citanRewrdArr) {
				var ctLevel:int=citanReward[MissionCitanRewardIndex.I_LEVEL];
				_setting['citan_reward'][ctLevel]=citanReward;
			}
			
			var previewArr:Array=dataBytes.readObject();
			_setting['preview'] = new Dictionary();
			for each (var preview:Array in previewArr) {
				var previewLV:int = preview[MissionPreviewIndex.I_LEVEL];
				var previewMissionID:int = preview[MissionPreviewIndex.I_MISISON_ID];
				_setting['preview'][previewLV]=previewMissionID;
			}
		}

		private var _dispatchedLoadSettingMsg:Boolean=false;

		/**
		 * 获取守边任务奖励数组
		 * @param level 等级
		 * @return Object
		 * 		   Object.status == 'level_limit' 等级不够无法获取
		 *         Object.status == 'loading'; 加载中 Object.data = null; //loading 其实是不可能出现的 因为没实现
		 *         Object.status == 'ok'; 可以获取数据 Object.data = array;
		 */
		public function getShouBianReward(level:int):Object {
			if (level >= MissionConstant.SHOU_BIAN_MIN_LEVEL && level <= MissionConstant.SHOU_BIAN_MAX_LEVEL) {
				return {'status': 'ok', 'data': this._setting['shou_bian_reward'][level]};
			}

			return {'status': 'level_limit', 'data': null};
		}

		/**
		 * 获取分组奖励对象
		 * @param bigGroupID 大分组ID
		 * @param level 等级
		 * @return Object
		 * 		   Object.status == 'level_limit' 等级不够无法获取
		 *         Object.status == 'loading'; 加载中 Object.data = null;//loading 其实是不可能出现的 因为没实现
		 *         Object.status == 'ok'; 可以获取数据 Object.data = array;
		 */
		public function getGroupReward(bigGroupID:int, level:int):Object {
			if (level >= MissionConstant.GROUP_MISSION_MIN_LEVEL && level <= MissionConstant.GROUP_MISSION_MAX_LEVEL) {
				var key:String=this.getGroupRewardKey(bigGroupID, level);
				return {'status': 'ok', 'data': this._setting['group_reward'][key]};
			}

			return {'status': 'level_limit', 'data': null};
		}

		/**
		 * 获取分组奖励的查询key
		 * 在获取分组奖励时内部调用
		 */
		private function getGroupRewardKey(groupID:int, level:int):String {
			return groupID + '_' + level;
		}

		/**
		 * 获取刺探任务奖励
		 * @param level 等级
		 * @return Object
		 * 		   Object.status == 'level_limit' 等级不够无法获取
		 *         Object.status == 'loading'; 加载中 Object.data = null;
		 *         Object.status == 'ok'; 可以获取数据 Object.data = array;
		 */
		public function getCitanReward(level:int):Object {
			if (level >= MissionConstant.CI_TAN_MIN_LEVEL && level <= MissionConstant.CI_TAN_MAX_LEVEL) {
				return {'status': 'ok', 'data': this._setting['citan_reward'][level]};
			}
			
			return {'status': 'level_limit', 'data': null};
		}

		/**
		 * 获取任务的主支线类型字符串
		 */
		private function htmlFMType(missionType:int):String{
			var color:String = '#39ff0b';
			var str:String = ''
			switch(missionType){
				case MissionConstant.TYPE_MAIN:
					str = '<font color="'+color+'">[主]</font>';
					break;
				case MissionConstant.MISSION_TYPE_BRANCH:
					str = '<font color="'+color+'">[支]</font>';
					break;
				case MissionConstant.TYPE_CIRCLE:
					str = '<font color="'+color+'">[循]</font>';
					break;
			}
			
			return str;
		}
		
		/**
		 * 渲染找NPC的寻路链接
		 * event:1,npcID
		 */
		private function htmlFNPC(missionID:int, npcID:int):String{
			var npcInfo:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			var linkStart:String = '<a href="event:'+MissionConstant.FOLLOW_LINK_TYPE_NPC+','+missionID+','+npcID+'"><u>';
			var linkEnd:String = '</u></a>';
			var str:String = '到'+linkStart+'<font color="#00f0ff">'+npcInfo.mapName+'</font>'+linkEnd;
			str += '找'+linkStart+'<font color="#39ff0b">'+npcInfo.name+'</font>'+linkEnd;
			return MissionConstant.TARGET_S_STR+str+MissionConstant.TRANS_GO_STR;
		}
		
		/**
		 * 渲染攻击怪物的链接
		 * event:2,mapID,怪物ID
		 */
		private function htmlFMonster(missionID:int, mapID:int, monsterTypeID:int, suffix:String):String{
			var monster:MonsterType=MonsterConfig.hash[monsterTypeID];
			var mapName:String=WorldManager.getMapName(mapID);
			var linkStart:String = '<a href="event:'+MissionConstant.FOLLOW_LINK_TYPE_MONSTER+','+missionID+','+mapID+','+monsterTypeID+'"><u>';
			var linkEnd:String = '</u></a>';
			var str:String = '到'+linkStart+'<font color="#00f0ff">'+mapName+'</font>'+linkEnd;
			str += '击杀'+linkStart+'<font color="#39ff0b">'+monster.monstername+'</font>'+linkEnd;
			str += '<font color="#ffff00">'+suffix+'</font>';
			return MissionConstant.TARGET_S_STR+str+MissionConstant.TRANS_GO_STR;
		}
		
		/**
		 * 渲染道具搜集
		 * event:1,npcID
		 */
		private function htmlFProp(missionID:int, npcID:int, propTypeID:int, suffix:String):String {
			var npcInfo:Object=NPCDataManager.getInstance().getNpcInfo(npcID);
			var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(propTypeID);
			var linkStart:String = '<a href="event:'+MissionConstant.FOLLOW_LINK_TYPE_NPC+','+missionID+','+npcID+'"><u>';
			var linkEnd:String = '</u></a>';
			
			var str:String = '到'+linkStart+'<font color="#00f0ff">'+npcInfo.mapName+'</font>'+linkEnd;
			str += '向'+linkStart+'<font color="#39ff0b">'+npcInfo.name+'</font>'+linkEnd;
			str += '索取<font color="#00f0ff">'+baseItemVO.name+'</font>';
			str += '<font color="#ffff00">'+suffix+'</font>';
			return MissionConstant.TARGET_S_STR+str+MissionConstant.TRANS_GO_STR;
		}
		
		/**
		 * 渲染打怪搜集道具
		 * event:2,地图ID,怪物TypeID
		 */
		private function htmlFMonsterProp(missionID:int, mapID:int, monsterTypeID:int, propTypeID:int, suffix:String):String{
			
			var monster:MonsterType=MonsterConfig.hash[monsterTypeID];
			var mapName:String=WorldManager.getMapName(mapID);
			var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(propTypeID);
			var linkStart:String = '<a href="event:'+MissionConstant.FOLLOW_LINK_TYPE_MONSTER+','+missionID+','+mapID+','+monsterTypeID+'"><u>';
			var linkEnd:String = '</u></a>';
			
			var str:String = '到'+linkStart+'<font color="#00f0ff">'+mapName+'</font>'+linkEnd;
			str += '击杀'+linkStart+'<font color="#39ff0b">'+monster.monstername+'</font>'+linkEnd;
			str += '搜集<font color="#00f0ff">'+baseItemVO.name+'</font>';
			str += '<font color="#ffff00">'+suffix+'</font>';
			return MissionConstant.TARGET_S_STR+str+MissionConstant.TRANS_GO_STR;
		}
		
		/**
		 * 渲染采集任务链接
		 * event:3,采集物baseID,地图ID,x坐标,y坐标
		 */
		private function htmlFCollect(missionID:int, mapID:int, posName:String, pointBaseID:int, propTypeID:int, tx:int, ty:int, suffix:String):String{
			var mapName:String=WorldManager.getMapName(mapID);
			var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(propTypeID);
			//TOOD获取采集物坐标
			var linkStart:String = '<a href="event:'+MissionConstant.FOLLOW_LINK_TYPE_COLLECT+','+missionID+','+pointBaseID+','+mapID+','+tx+','+ty+'"><u>';
			var linkEnd:String = '</u></a>';
			var str:String = '到'+linkStart+'<font color="#39ff0b"><u>'+posName+'</u></font>'+linkEnd;
			//TODO: 先临时hardcode,之后修改到任务数据中
			if( propTypeID == 10900087 ){
				str += '捕捉'+linkStart+'<font color="#00f0ff">'+baseItemVO.name+'</font>'+linkEnd;
			}else{
				str += '采集'+linkStart+'<font color="#00f0ff">'+baseItemVO.name+'</font>'+linkEnd;	
			}
			str += '<font color="#ffff00">'+suffix+'</font>';
			return MissionConstant.TARGET_S_STR+str+MissionConstant.TRANS_GO_STR;
		}


		/**
		 *  渲染打开玩家升级任务的 任务链接
		 */
		private function htmlFLevelUp( roleLevel:int, toLevel:int ):String {

			var str:String = "升到<font color='#00ff00'>"+ roleLevel + "/" + toLevel +"</font>级。" 
				+"参与<a href='event:open_activity_benefit'><u><font color='#00ff00'>活动</font></u></a>获得经验，" 
				+ "参加<a href='event:find_hero_fb'><u><font color='#00ff00'>大明英雄</font></u></a>、" +
				"<a href='event:find_poyanghu_fb'><u><font color='#00ff00'>鄱阳湖副本</font></u></a>可快速升级，"
				+ "使用<a href='event:open_forgeshop_window'><u><font color='#00ff00'>铁匠铺</font></u></a>、<a href='event:open_stove_window'><u><font color='#00ff00'>天工炉</font></u></a>能让你的实力更强";
			return MissionConstant.TARGET_S_STR + str + MissionConstant.TRANS_GO_STR;
		}
		
		
		/**
		 * 渲染打开商城面板买东西 任务链接 
		 *///(missionVO.id, shopID, baseItemVO.name, model6Listener.need_num);'打开商店购买 <font color="#39ff0b">' + +'×'+
		private function htmlFShopBuyProp(missionID:int, shopID:int=0, propName:String='', needNum:int=0):String {
			
			if(propName ==''){
				propName = '任务所需道具';
			}
			
			if(needNum > 0){
				propName += '×'+needNum;
			}
			
			var linkStart:String = '<a href="event:'+MissionConstant.FOLLOW_LINK_TYPE_SHOP_BUY_GROUP+','+missionID+','+shopID+'"><u>';
			var linkEnd:String = '</u></a>';
			var str:String = linkStart+'<font color="#00f0ff">打开商店</font>'+linkEnd;
			str += '购买'+linkStart+'<font color="#00f0ff">'+propName+'</font>'+linkEnd;
			str += "<br/>       完成任务获得可升级的紫色项链";
			return MissionConstant.TARGET_S_STR+str+MissionConstant.TRANS_GO_STR;
		}
		
		/**
		 * 格式化没有单位的数值奖励
		 */
		public function wrapperInt(name:String, value:Number, suffix:String = '\n'):String {
			if (value > 0) {
				var str:String = '<font color="#ffff00">' + name + '：</font>' + HtmlUtil.font(value.toString(),"#00ff00") +suffix;
				return str;
			}
			return "";
		}
		
		/**
		 * 格式化道具奖励
		 */
		public function wrapperProp(name:String, value:Number, suffix:String = '\n'):String {
			if (value > 0) {
				var str:String = '<font color="#ffff00">' + name + '×' + value + '</font>'+suffix;
				return str;
			}
			return "";
		}
		
		/**
		 * 格式化银子奖励
		 */
		public function wrapperSilver(name:String, value:Number, suffix:String = '\n'):String {
			if (value > 0) {
				var str:String =  '<font color="#ffff00">' + name + '：</font>';
				str +=  HtmlUtil.font(MoneyTransformUtil.silverToOtherString(value),"#00ff00") +suffix;
				return str;
			}
			return "";
		}
		
		/**
		 * 根据任务ID返回任务模型号
		 */
		public function getMissionModel(missionID:int):int {
			var missionBaseInfo:Array = this.getBase(missionID);
			if(!missionBaseInfo){
				return 0;
			}
			return missionBaseInfo[MissionBaseIndex.MODEL];
		}

		/**
		 * 查询指定NPC是否有任务
		 */
		public function hasNpcMission( npcID:int ):Boolean {
			if ( _npcMissionList && _npcMissionList[ npcID ]) {
				for ( var miss:Object in _npcMissionList[ npcID ]) {
					return true;
				}
			}

			return false;
		}
	}
}

class singleton {
}