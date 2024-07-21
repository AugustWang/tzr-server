package modules.goal
{
	import com.managers.Dispatch;
	
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.goal.vo.GoalItemVO;
	
	import proto.common.p_role_goal_item;

	public class GoalDataManager
	{
		public var day:int = 1;
		private var goalData:Dictionary;
		private var goalItemData:Dictionary;
		private var _goals:Array;
		public function GoalDataManager()
		{
			goalData = new Dictionary();
			goalItemData = new Dictionary();
		}
		
		private static var _instance:GoalDataManager;
		public static function getInstance():GoalDataManager{
			if(_instance == null){
				_instance = new GoalDataManager();
			}
			return _instance;
		}
		
		public function setGoalData(goals:Array):void{
			for each(var item:p_role_goal_item in goals){
				goalData[item.goal_id] = item;
			}
			_goals = GoalResource.getGoals();
		}
		
		public function wrapperGoalItem(goalItemVO:GoalItemVO):void{
			var item:p_role_goal_item = goalData[goalItemVO.id];
			if(item){
				goalItemVO.finished = item.finished;
				goalItemVO.takeReward = item.fetched;
			}
			updateGoalItemStatus(goalItemVO);
			goalItemData[goalItemVO.id] = goalItemVO;
		}
		
		public function updateGoalItem(item:p_role_goal_item):void{
			var goalItemVO:GoalItemVO = goalItemData[item.goal_id];
			if(goalItemVO){
				goalItemVO.finished = item.finished;
				goalItemVO.takeReward = item.fetched;
				updateGoalItemStatus(goalItemVO);
				goalData[item.goal_id] = item;
				Dispatch.dispatch(GoalConstants.GOAL_ITEM_UPDATE,goalItemVO);
			}
		}		
		
		private function updateGoalItemStatus(goalItemVO:GoalItemVO):void{
			if(day >= goalItemVO.parent.active && !goalItemVO.finished){
				goalItemVO.status = 1;
			}else if(day < goalItemVO.parent.active){
				if(goalItemVO.finished){
					goalItemVO.status = 3;
				}else{
					goalItemVO.status = 0;
				}
			}else if(goalItemVO.finished && !goalItemVO.takeReward){
				goalItemVO.status = 2;
			}else if(goalItemVO.takeReward){
				goalItemVO.status = 3;
			}
			if(goalItemVO.status == 2){
				Dispatch.dispatch(ModuleCommand.GOAL_START_FLICK);
			}
		}
		
		public function fetchGoal(goal_id:int):void{
			var goalItemVO:GoalItemVO = goalItemData[goal_id];
			var item:p_role_goal_item = goalData[goal_id];
			goalItemVO.takeReward = true;
			item.finished = true;
			goalItemVO.finished = true;
			goalItemVO.status = 3;
			Dispatch.dispatch(GoalConstants.GOAL_ITEM_UPDATE,goalItemVO);
		}
		
		public function getGoals():Array{
			return _goals;
		}
	}
}