package modules.mission {
	import com.managers.Dispatch;
	
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mission.vo.MissionBaseIndex;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	public class MissionError {
		public function MissionError() {

		}

		static public const NO_ERROR:int=0; //正常
		static public const SYSTEM_ERROR:int=1; //系统错误

		/**
		 * 获取错误描述
		 */
		static public function getError(vo:Object):Boolean {
			if(!vo.code || !vo.code_data){
				return false;
			}
			
			var error:String = '';
			switch (vo.code) {
				case NO_ERROR:
					error = '';
					break;
				
				case SYSTEM_ERROR:
					error = '系统错误。';
					break;
				
				case 2:
					error = '未找到对应任务。';
					break;

				case 3:
					error = '任务所处状态不正常。';
					break;

				case 4:
					error = '请找到正确的NPC';
					break;

				case 5:
				case 6:
					Dispatch.dispatch(ModuleCommand.OPEN_PACK_PANEL_WHEN_NOT_POP_UP);
					var packFullTips:String = '背包空间不足，影响你完成任务，请整理背包。';
					Tips.getInstance().addTipsMsg(packFullTips);	
					error = packFullTips;
					break;
				
				case 7:
					error = '背包里找不到对应道具';
					break;
				
				case 8:
					error = '还没到时间呢，在边境再转转吧。';
					break;
				
				case 9:
					error = '请选择你要前往的国家。';
					break;
				
				case 10:
					error = '请选择另一个国家。';
					break;
				
				case 11:
					error = '';//守边前端频繁提交 应该是计时器出问题 或丢帧导致频繁提交
					break;
				
				case 12:
					var missionID:int = vo.code_data[0];
					var missionBaseInfo:Array = MissionDataManager.getInstance().getBase(missionID);
					var missionName:String = missionBaseInfo[MissionBaseIndex.NAME];
					error = '任务中不能领取 '+missionName;
					break;
				
				case 20:
					var faction:int = vo.code_data[0];
					var factionName:String = (faction == 1 ? '云州' : (faction == 2 ? '沧州' : '幽州'));
					error = '不能领取 '+factionName+' 的任务';
					break;
				
				case 21:
					var gender:int = vo.code_data[0];
					error = '该任务限定为 '+(gender == 1 ? '男玩家' : '女玩家')+' 可接';
					break;
				
				case 22:
					error = '该任务要求你在队伍中。';
					break;
					
				case 23:
					error = '该任务要求你加入门派。';
					break;
				 
				case 24:
					var minLV:int = vo.code_data[0];
					var maxLV:int = vo.code_data[1];
					error = '该任务需要满足等级在 <font color="#ffff00">'+minLV+'</font> 到 <font color="#ffff00">'+maxLV+'</font> 之间';
					break;
				
				case 25:
					var preMissionID:int = vo.code_data[0];
					var preMissionBaseInfo:Array = MissionDataManager.getInstance().getBase(preMissionID);
					var preMissionName:String = preMissionBaseInfo[MissionBaseIndex.NAME];
					error = '该任务要求先完成前置任务：<font color="#ffff00">'+preMissionName+'</font>';
					break;
				
				case 26:
					//vo.code_data = [CTimeType, CTimeStart, CTimeEnd] 啊~~优化啊优化~~
					error = '任务时间未到，无法领取。';
					break;
				
				case 27:
					error = '已达到今天所能领取的最大次数。';
					break;
				
				case 28:
					var needProp:BaseItemVO = ItemLocator.getInstance().getObject(vo.code_data[0]);
					error = '需要道具：<font color="#ffff00">'+needProp.name+'</font>';
					break;
				
				default:
					error = '系统错误。';
					break;
			}
			
			if(error == ''){
				return false;
			}else{
				BroadcastSelf.getInstance().appendMsg(error);
				return true;
			}
			
		}
	}
}