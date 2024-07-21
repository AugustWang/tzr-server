package modules.achievement
{
	import com.common.GlobalObjectManager;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import modules.achievement.vo.AchievementGroupVO;
	import modules.achievement.vo.AchievementTypeVO;
	import modules.achievement.vo.AchievementVO;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_achievement_info;
	import proto.common.p_achievement_stat_info;
	
	public class AchievementDataManager extends EventDispatcher
	{
		public static const ACHIEVEMENTS_UPDATE:String = "ACHIEVEMENTS_UPDATE";
		public static const JUST_FINISH_ACHIEVEMENT_UPDATE:String = "JUST_FINISH_ACHIEVEMENT_UPDATE";
		public static const ACHIEVEMENT_INFO_UPDATE:String = "ACHIEVEMENT_INFO_UPDATE";
		public static const ACHIEVEMENT_POINTS_UPDATE:String = "ACHIEVEMENT_POINTS_UPDATE";
		public static const ACHIEVEMENT_FINISH:String = "ACHIEVEMENT_FINISH";
		public static const GROUP_FINISH:String = "GROUP_FINISH";
		public static const GROUP_UPDATE:String = "GROUP_UPDATE";
		
		private var achievementXML:XML;
		private var inited:Boolean = false;
		
		private var bigGroups:Array;
		private var smallGroupMap:Dictionary; //扁平化的小类型存储
		private var achievementDic:Dictionary;
		
		public var justFinishs:Array;
		public var totalPoints:int;
		public var stat_infos:Array;
		
		public function AchievementDataManager()
		{
			super();
			achievementDic = new Dictionary();
			smallGroupMap = new Dictionary();
			achievementXML = CommonLocator.getXML(CommonLocator.ACHIEVEMENT);
		}
		
		private static var _instance:AchievementDataManager;
		public static function getInstance():AchievementDataManager{
			if(!_instance){
				_instance = new AchievementDataManager();
			}
			return _instance;
		}
		
		/**
		 * 初始化成就数据
		 */		
		private function initAchievements():void{
			if(inited == false){
				bigGroups = [];
				var achievementList:XMLList = achievementXML..achievements;
				for each(var achievements:XML in achievementList){
					var typeVO:AchievementTypeVO = new AchievementTypeVO();
					typeVO.id = achievements.@id;
					typeVO.name = achievements.@label;
					typeVO.global = int(achievements.@global);
					bigGroups.push(typeVO);
					var smallGroupList:XMLList = achievements.group;
					typeVO.smallGroups = [];
					for each(var smallGroupXML:XML in smallGroupList){
						var groupVO:AchievementGroupVO = new AchievementGroupVO();
						groupVO.id = smallGroupXML.@id;
						groupVO.name = smallGroupXML.@label;
						groupVO.path = GameConfig.ROOT_URL + String(smallGroupXML.@grouppath);
						groupVO.childrenXML = smallGroupXML.achievement;
						groupVO.totalCount = groupVO.childrenXML.length();
						groupVO.parent = typeVO;
						if(smallGroupXML.desc.length() > 0){
							groupVO.desc = smallGroupXML.desc[0].text();
						}
						groupVO.goods = [];
						typeVO.smallGroups.push(groupVO);
						smallGroupMap[groupVO.id] = groupVO;
						var groupRewards:XMLList = smallGroupXML.groupReward;
						if(groupRewards.length() == 1){
							for each(var groupRewardXML:XML in groupRewards[0].goods){
								var itemVO:BaseItemVO = ItemLocator.getInstance().getObject(groupRewardXML.@typeId);
								itemVO.color = groupRewardXML.@color;
								itemVO.quality = groupRewardXML.@quality;
								itemVO.num = groupRewardXML.@num;
								itemVO.bind = int(groupRewardXML.@isBind) == 1;
								groupVO.goods.push(itemVO);
							}
						}
					}
				}
				inited = true;
			}
		}
		
		/**
		 * 通过p_achievement_info装配出AchievementVO
		 * 
		 */		
		private function wrapperAchievement(info:p_achievement_info):AchievementVO{
			var achievement:AchievementVO = new AchievementVO();
			try{
				achievement.id = info.achieve_id;
				achievement.bigGroup = getBigGroupVO(info.class_id);
				achievement.smallGroup = getSmallGroupVO(info.group_id);
				copyAchievement(info,achievement);
				var achievementItem:XML = achievementXML..achievement.(@id == achievement.id)[0];
				createAchievement(achievementItem,achievement);
			}catch(e:Error){
				trace(info.achieve_id+"不存在!");
			}
			return achievement;
		}
		/**
		 * 拷贝 p_achievement_info到AchievementVO
		 * @param info
		 * @param achievement
		 * 
		 */		
		private function copyAchievement(info:p_achievement_info,achievement:AchievementVO):void{
			achievement.points = info.points;
			achievement.currentStep = info.cur_progress;
			achievement.totalStep = info.total_progress;
			achievement.state = info.status;
			achievement.roleId = info.role_id;
			achievement.roleName = info.role_name;
			achievement.popType = info.pop_type;
		}
		/**
		 * 通过XML段构建一个完整的AchievementVO
		 * @return 
		 * 
		 */		
		private function createAchievement(achievementItem:XML,achievement:AchievementVO=null):AchievementVO{
			if(achievement == null){
				achievement = new AchievementVO();
			}
			var achievementItem:XML = achievementXML..achievement.(@id == achievement.id)[0];
			achievement.name = achievementItem.@name;
			achievement.desc = achievementItem.desc[0].text();
			if(achievementItem.@path != ""){
				achievement.path = GameConfig.ROOT_URL+achievementItem.@path;
			}
			achievement.sort = achievementItem.@sort;
			achievement.points = achievementItem.@points;
			if(achievementItem.reward.length() > 0){
				var rewardXML:XML = achievementItem.reward[0];
				achievement.hasGoodsReward = true;
				achievement.title = rewardXML.@title;
				achievement.goods = new Array();
				for each(var goodsXML:XML in rewardXML.goods){
					var itemVO:BaseItemVO = ItemLocator.getInstance().getObject(goodsXML.@typeId);
					itemVO.color = goodsXML.@color;
					itemVO.quality = goodsXML.@quality;
					itemVO.num = goodsXML.@num;
					itemVO.bind = int(goodsXML.@isBind) == 1;
					achievement.goods.push(itemVO);
				}
			}
			return achievement;
		}
		/**
		 * 初始化最近完成的成就 
		 * @param justAchievements
		 * 
		 */		
		public function setJustAchievements(justAchievements:Array):void{
			justFinishs = [];
			for each(var info:p_achievement_info in justAchievements){
				justFinishs.push(wrapperAchievement(info));
			}
			dispatchEvent(new ParamEvent(JUST_FINISH_ACHIEVEMENT_UPDATE));
		}
		
		/**
		 * 初始化成就总览信息 
		 * @param totalPoints
		 * @param stat_infos
		 * 
		 */		
		public function setAchievementInfo(totalPoints:int,stat_infos:Array):void{
			this.totalPoints = totalPoints;
			this.stat_infos = stat_infos;
			dispatchEvent(new ParamEvent(ACHIEVEMENT_INFO_UPDATE));
		}
		
		/**
		 * 更新总的成就点 
		 * @param totalPoints
		 * 
		 */		
		public function setAchievementPoints(value:int):void{
			if(value != totalPoints){
				this.totalPoints = value;
				dispatchEvent(new ParamEvent(ACHIEVEMENT_POINTS_UPDATE));
			}
		}
		/**
		 * 初始化某组的成就数据 
		 * @param smallGroupId
		 * @param achevements
		 * 
		 */		
		public function setAchievements(smallGroupId:int,achevements:Array):void{
			var datas:Array = [];
			var finishCount:int;
			for each(var info:p_achievement_info in achevements){
				if(info.status != AchievementConstant.STATE_DOING){
					finishCount++;	
				}
				datas.push(wrapperAchievement(info));
			}
			datas.sortOn("sort",Array.NUMERIC|Array.DESCENDING);
			achievementDic[smallGroupId] = datas;
			var smallGroupVO:AchievementGroupVO = getSmallGroupVO(smallGroupId);
			if(smallGroupVO){
				smallGroupVO.finishCount = finishCount;
			}
			dispatchEvent(new ParamEvent(ACHIEVEMENTS_UPDATE,{smallGroupId:smallGroupId}));
		}
		/**
		 * 更新成就点和某些成就的状态信息 
		 * @param points
		 * @param achievements
		 * 
		 */		
		public function updateAchievementInfos(points:int,achievements:Array):void{
			initAchievements();
			setAchievementPoints(points);
			for each(var info:p_achievement_info in achievements){
				updateAchievment(info);
			}
		}
		/**
		 * 更新当个成就信息 
		 * @param info
		 * 
		 */		
		public function updateAchievment(info:p_achievement_info):void{
			if(info.achieve_type == 0){
				var achievementVO:AchievementVO = getAchievmentVO(info.group_id,info.achieve_id);
				//如果当前成就数据还没有初始化，并且成就没有完成将忽略此次更新
				if(achievementVO == null && info.status == AchievementConstant.STATE_DOING){
					return;
				}
				if(info.status == AchievementConstant.STATE_FINISH){
					if(achievementVO == null){
						achievementVO = wrapperAchievement(info);
					}else{
						copyAchievement(info,achievementVO);
						achievementVO.update();
						achievementVO.smallGroup.finishCount++;
						dispatchEvent(new ParamEvent(GROUP_UPDATE,achievementVO.smallGroup));
					}
					dispatchEvent(new ParamEvent(ACHIEVEMENT_FINISH,achievementVO));
					addJustFinishAchievement(achievementVO);
					updateStatInfo(achievementVO);
				}else{
					copyAchievement(info,achievementVO);
					achievementVO.update();
				}
			}else if(info.achieve_type == 1){
				if(info.status == AchievementConstant.STATE_FINISH){
					var groupVO:AchievementGroupVO = getSmallGroupVO(info.achieve_id);	
					groupVO.state = info.status;
					groupVO.completeTime = info.complete_time;
					groupVO.popType = info.pop_type;
					dispatchEvent(new ParamEvent(GROUP_UPDATE,groupVO));
				}
			}else if(info.achieve_type == 2){
				achievementVO = getAchievmentVO(info.group_id,info.achieve_id);
				var roleId:int = GlobalObjectManager.getInstance().user.attr.role_id;
				if(info.status == AchievementConstant.STATE_FINISH){
					if(roleId != info.role_id && achievementVO == null)return;
					if(achievementVO == null){
						achievementVO = wrapperAchievement(info);
					}else{
						copyAchievement(info,achievementVO);
						achievementVO.update();
					}
					if(roleId == info.role_id){
						dispatchEvent(new ParamEvent(ACHIEVEMENT_FINISH,achievementVO));
					}
					addJustFinishAchievement(achievementVO);
				}else{
					copyAchievement(info,achievementVO);
					achievementVO.update();
				}
			}
		}
		/**
		 * 更新成就的状态 
		 * @param id
		 * @param state
		 * 
		 */		
		public function updateAchievementState(groupId:int,id:int,state:int):void{
			var achievementVO:AchievementVO = getAchievmentVO(groupId,id);
			if(achievementVO){
				achievementVO.state = state;
				achievementVO.update();
			}
			for each(var info:AchievementVO in justFinishs){
				if(info.id == id){
					info.state = state;
					info.update();
					break;
				}
			}
		}
		/**
		 * 添加最近完成的成就 
		 * @param vo
		 * 
		 */		
		public function addJustFinishAchievement(vo:AchievementVO):void{
			//如果未初始化将忽略
			if(justFinishs){
				var index:int = justFinishs.indexOf(vo);
				if(index == -1){
					justFinishs.push(vo);
				}
				dispatchEvent(new ParamEvent(JUST_FINISH_ACHIEVEMENT_UPDATE)); 
			}	
		}
		/**
		 * 当完成一个成就时，修改总预览信息的进度  
		 */
		public function updateStatInfo(vo:AchievementVO):void{
			if(stat_infos && vo){
				for each(var info:p_achievement_stat_info in stat_infos){
					if(info.type == 0 || info.type == vo.bigGroup.id){
						info.cur_progress++;
						info.cur_progress = Math.min(info.cur_progress,info.total_progress);
					}
				}
				dispatchEvent(new ParamEvent(ACHIEVEMENT_INFO_UPDATE));
			}
		}
		/**
		 * 获取大组集合 
		 * @return 
		 * 
		 */		
		public function getBigGroups():Array{
			initAchievements();
			return bigGroups;
		}
		
		/**
		 * 获取大组VO结构 
		 * @param groupId
		 * @return 
		 * 
		 */		
		public function getBigGroupVO(groupId:int):AchievementTypeVO{
			initAchievements();
			for each(var typeVO:AchievementTypeVO in bigGroups){
				if(typeVO.id == groupId){
					return typeVO;
				}
			}
			return null;
		}
		/**
		 * 获取小组VO结构 
		 * @param bigGroupId
		 * @param smallGroupId
		 * @return 
		 * 
		 */		
		public function getSmallGroupVO(smallGroupId:int):AchievementGroupVO{
			return smallGroupMap[smallGroupId];
		}
		/**
		 * 获取小组所有成就数据 
		 * @param smallGroupId
		 * @return 
		 * 
		 */		
		public function getAchievements(smallGroupId:int):Array{
			return achievementDic[smallGroupId];
		}
		/**
		 * 获取当个成绩VO数据 
		 * @param smallGroupId
		 * @param id
		 * @return 
		 * 
		 */		
		public function getAchievmentVO(smallGroupId:int,id:int):AchievementVO{
			var smallGroups:Array = getAchievements(smallGroupId);
			for each(var achievementVO:AchievementVO in smallGroups){
				if(achievementVO.id == id){
					return achievementVO;
				}
			}
			return null;
		}
	}
}