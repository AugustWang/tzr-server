package modules.achievement.views
{
	import com.components.GoodsBox;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.achievement.AchievementConstant;
	import modules.achievement.AchievementDataManager;
	import modules.achievement.AchievementModule;
	import modules.achievement.views.items.AchievementDetailItem;
	import modules.achievement.vo.AchievementGroupVO;
	import modules.achievement.vo.AchievementTypeVO;
	import modules.mypackage.vo.BaseItemVO;
	
	public class AchievementDetailView extends Sprite
	{
		public var bigGroupVO:AchievementTypeVO;
		private var leftContainer:UIComponent;
		private var finishAllAchievementView:UIComponent;
		private var finishDesc:TextField;
		private var finishBar:ProgressBar;
		private var goodsBoxPool:Array;
		private var finishReward:Sprite;
		private var takeFinishRewardBtn:Button;
		private var rightContainer:UIComponent;
		private var list:List;
		private var selectedButton:ToggleButton;
		private var smallGroupVO:AchievementGroupVO;
		public function AchievementDetailView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			initView();
		}
		
		private function initView():void{
			leftContainer = new UIComponent();
			leftContainer.width = 130;
			leftContainer.height = 360;
			leftContainer.x = 0;
			leftContainer.y = 5;
			Style.setBorderSkin(leftContainer);
			addChild(leftContainer);
			
			var starty:Number = 15;
			for each(var groupVO:AchievementGroupVO in bigGroupVO.smallGroups){
				var toggleButton:ToggleButton = new ToggleButton();
				toggleButton.height = 25;
				toggleButton.width = 90;
				toggleButton.x = 20;
				toggleButton.y = starty;
				toggleButton.label = groupVO.name;
				toggleButton.data = groupVO;
				toggleButton.addEventListener(MouseEvent.CLICK,clickTypeHandler);
				leftContainer.addChild(toggleButton);	
				starty += 25;
			}
			
			rightContainer = new UIComponent();
			rightContainer.width = 440;
			rightContainer.height = 360;
			rightContainer.y = leftContainer.y;
			rightContainer.x = leftContainer.x+leftContainer.width;
			Style.setBorderSkin(rightContainer);
			addChild(rightContainer);
			
			list = new List();
			list.y = 5;
			list.x = 5;
			list.selected = false;
			list.bgSkin = null;
			list.width = 430;
			list.height = 350;
			list.itemHeight = 62;
			list.itemRenderer = AchievementDetailItem;
			rightContainer.addChild(list);
			AchievementDataManager.getInstance().addEventListener(AchievementDataManager.ACHIEVEMENTS_UPDATE,onAchievementsUpdate);
			AchievementDataManager.getInstance().addEventListener(AchievementDataManager.GROUP_UPDATE,onGroupUpdate);
			leftContainer.getChildAt(0).dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		private function createFinishAllView():void{
			goodsBoxPool = [];
			finishAllAchievementView = new UIComponent();
			finishAllAchievementView.width = rightContainer.width;
			finishAllAchievementView.height = 100;
			finishAllAchievementView.y = leftContainer.y;
			finishAllAchievementView.x = leftContainer.x+leftContainer.width;
			Style.setBorderSkin(finishAllAchievementView);
			addChild(finishAllAchievementView);
			
			finishDesc = ComponentUtil.createTextField("完成下列所有成就将可获得：",15,10,Style.themeTextFormat,300,25,finishAllAchievementView);
			finishReward = new Sprite();
			finishReward.y = 50;
			finishReward.x = 15;
			finishAllAchievementView.addChild(finishReward);
			
			finishBar = new ProgressBar();
			finishBar.bgSkin = Style.getSkin("processBarBg",GameConfig.ACHIEVEMENT_UI,new Rectangle(10,3,101,2));
			finishBar.bar = Style.getBitmap(GameConfig.ACHIEVEMENT_UI,"processBar");
			finishBar.x = 170;
			finishBar.y = 75;
			finishBar.width = 150;
			finishBar.height = 14;
			finishAllAchievementView.addChild(finishBar);
			
			takeFinishRewardBtn = ComponentUtil.createButton("领取奖励",350,65,75,25,finishAllAchievementView);
		}
		
		private function initFinishView(smallGroupVO:AchievementGroupVO):void{
			if(smallGroupVO.goods && smallGroupVO.goods.length > 0){
				while(finishReward && finishReward.numChildren){
					goodsBoxPool.push(finishReward.removeChildAt(0));
				}	
				for each(var itemVO:BaseItemVO in smallGroupVO.goods){
					var goodsBox:GoodsBox;
					if(goodsBoxPool.length > 0){
						goodsBox = goodsBoxPool.shift();
					}else{
						goodsBox = new GoodsBox();
					}
					goodsBox.baseItemVO = itemVO;
					finishReward.addChild(goodsBox);
				}
				if(smallGroupVO.state == AchievementConstant.STATE_FINISH){
					takeFinishRewardBtn.enabled = true;
				}else{
					takeFinishRewardBtn.enabled = false;
				}
				finishBar.htmlText = smallGroupVO.finishCount+"/"+smallGroupVO.totalCount;
				finishBar.value = smallGroupVO.finishCount/smallGroupVO.totalCount;
				LayoutUtil.layoutHorizontal(finishReward);
			}
		}
		
		private function onAchievementsUpdate(event:ParamEvent):void{
			if(smallGroupVO.id == event.data.smallGroupId){
				list.dataProvider = AchievementDataManager.getInstance().getAchievements(smallGroupVO.id)
				initFinishView(smallGroupVO);
			}	
		}
		
		private function onGroupUpdate(event:ParamEvent):void{
			var groupVO:AchievementGroupVO = event.data as 	AchievementGroupVO;
			if(groupVO && groupVO.id == smallGroupVO.id){
				initFinishView(groupVO);
			}
		}
		
		private function clickTypeHandler(event:MouseEvent):void{
			var toggleButton:ToggleButton = event.currentTarget as ToggleButton;
			if(selectedButton != toggleButton){
				if(selectedButton){
					selectedButton.selected = false;
				}
				selectedButton = toggleButton;
				selectedButton.selected = true;
				var groupVO:AchievementGroupVO = selectedButton.data as AchievementGroupVO;
				if(groupVO){
					smallGroupVO = groupVO;
					if(smallGroupVO.goods && smallGroupVO.goods.length > 0){
						if(finishAllAchievementView == null){
							createFinishAllView();
						}else{
							finishAllAchievementView.visible = true;
						}
					}else if(finishAllAchievementView){
						finishAllAchievementView.visible = false;
					}
					if(finishAllAchievementView && finishAllAchievementView.visible){
						rightContainer.y = 105;
						rightContainer.height = 259;
						list.height = 249;
					}else{
						rightContainer.y = leftContainer.y;
						rightContainer.height = 360;
						list.height = 350;
					}
					selectSmallGroup();
				}
			}
		}
		
		private function selectSmallGroup():void{
			var dataProvider:Array = AchievementDataManager.getInstance().getAchievements(smallGroupVO.id); 
			if(dataProvider == null){
				if(smallGroupVO.parent.global == 0){
					AchievementModule.getInstance().getAchievements(smallGroupVO.id);
				}else{
					AchievementModule.getInstance().getAchievements(smallGroupVO.id,5);
				}
			}else{
				list.dataProvider = dataProvider;
				initFinishView(smallGroupVO);
			}
		}
	}
}