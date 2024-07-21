package modules.achievement.views
{
	import com.common.FilterCommon;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.achievement.AchievementDataManager;
	import modules.achievement.AchievementModule;
	import modules.achievement.views.items.AchievementBar;
	import modules.achievement.views.items.AchievementDetailItem;
	import modules.achievement.vo.AchievementTypeVO;
	
	import proto.common.p_achievement_stat_info;
	
	public class AchievementFinishView extends Sprite
	{
		private var achievementValue:TextField;
		private var finishAchievementBar:ProgressBar;
		
		private var barDic:Dictionary;
		
		private var justFinishList:List;
		
		public function AchievementFinishView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			initView();
		}
		
		private function initView():void{
			
			var topBg:UIComponent = new UIComponent();
			topBg.y = 2;
			topBg.width = 570;
			topBg.height = 150;
			Style.setBorderSkin(topBg);
			addChild(topBg);
			
			var tf:TextFormat = Style.themeTextFormat;
			var proName:TextField = ComponentUtil.createTextField("成就点：",20,20,tf,50,20,this);
			achievementValue = ComponentUtil.createTextField("",proName.x+proName.width+5,proName.y,tf,100,20,this);
			
			proName = ComponentUtil.createTextField("完成成就：",174,proName.y,tf,55,20,this);
			finishAchievementBar = createProcessBar(proName.x+proName.width+5,proName.y+4,320);
			
			var barContainer:Sprite = new Sprite();
			barContainer.x = 20;
			barContainer.y = 50;
			addChild(barContainer);
			
			barDic = new Dictionary();
			var bigGroups:Array = AchievementDataManager.getInstance().getBigGroups();
			for each(var typeVO:AchievementTypeVO in bigGroups){
				if(typeVO.global == 1)continue;
				var bar:AchievementBar = new AchievementBar();
				bar.initView(typeVO);
				barContainer.addChild(bar);
				barDic[typeVO.id] = bar;
			}
			
			LayoutUtil.layoutGrid(barContainer,2,50,5);
			
			tf.size = 16;
			var justFinishText:TextField = ComponentUtil.createTextField("最\n近\n完\n成\n成\n就",40,190,tf,25,120,this);
			justFinishText.filters = FilterCommon.FONT_BLACK_FILTERS;
			justFinishText.multiline = true;
			justFinishText.textColor = 0xffff00;
			
			var justFinishBG:UIComponent = new UIComponent();
			justFinishBG.width = 440;
			justFinishBG.height = 203;
			justFinishBG.y = topBg.y+topBg.height+5;
			justFinishBG.x = 130;
			Style.setBorderSkin(justFinishBG);
			addChild(justFinishBG);
			
			justFinishList = new List();
			justFinishList.bgSkin = null;
			justFinishList.selected = false;
			justFinishList.y = 5;
			justFinishList.x = 5;
			justFinishList.width = 430;
			justFinishList.height = 190;
			justFinishList.itemHeight = 62;
			justFinishList.itemRenderer = AchievementDetailItem;
			justFinishBG.addChild(justFinishList);
			
			AchievementDataManager.getInstance().addEventListener(AchievementDataManager.JUST_FINISH_ACHIEVEMENT_UPDATE,onJustFinishAchievement);
			AchievementDataManager.getInstance().addEventListener(AchievementDataManager.ACHIEVEMENT_INFO_UPDATE,onAchievementInfoUpdate);
			AchievementDataManager.getInstance().addEventListener(AchievementDataManager.ACHIEVEMENT_POINTS_UPDATE,onAchievementPointUpdate);
			AchievementModule.getInstance().getAchievementInfo();
		}
		
		private function onJustFinishAchievement(event:ParamEvent):void{
			justFinishList.dataProvider = AchievementDataManager.getInstance().justFinishs;
		}
		
		private function onAchievementInfoUpdate(event:ParamEvent):void{
			achievementValue.text = AchievementDataManager.getInstance().totalPoints.toString();
			var statInfos:Array = AchievementDataManager.getInstance().stat_infos;
			for each(var statInfo:p_achievement_stat_info in statInfos){
				if(statInfo.type > 0){
					var bar:AchievementBar = barDic[statInfo.type];
					if(bar){
						bar.setAchievementInfo(statInfo.award_point,statInfo.cur_progress,statInfo.total_progress);
					}
				}else{
					finishAchievementBar.htmlText = statInfo.cur_progress+"/"+statInfo.total_progress;
					finishAchievementBar.value = statInfo.cur_progress/statInfo.total_progress;
				}
			}
		}
		
		private function onAchievementPointUpdate(event:ParamEvent):void{
			achievementValue.text = AchievementDataManager.getInstance().totalPoints.toString();
		}
		
		private function createProcessBar(x:int,y:int,w:Number = 100):ProgressBar{
			var bar:ProgressBar = new ProgressBar();
			bar.bgSkin = Style.getSkin("processBarBg",GameConfig.ACHIEVEMENT_UI,new Rectangle(10,3,101,2));
			bar.bar = Style.getBitmap(GameConfig.ACHIEVEMENT_UI,"processBar");
			bar.x = x;
			bar.y = y;
			bar.width = w;
			bar.height = 14;
			addChild(bar);
			return bar;
		}
	}
}