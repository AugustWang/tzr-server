package modules.goal.views
{
	import com.components.BasePanel;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.TabNavigationEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import modules.goal.GoalConstants;
	import modules.goal.GoalDataManager;
	import modules.goal.GoalModule;
	import modules.goal.vo.GoalItemVO;
	import modules.goal.vo.GoalVO;
	
	public class GoalPanel extends BasePanel
	{
		private var tabbar:TabBar;
		private var goalItemsBar:GoalItemsBar;
		private var container:UIComponent;
		private var goalInfoView:GoalInfoView;
		private var takeRewardBtn:Button;
		private var lingqu:Bitmap;
		private var errorTxt:TextField;
		private var enabledTip:TextField;
		
		private var goalList:Array;
		private var currentGoal:GoalVO;
		private var currentGoalItem:GoalItemVO;
		
		public function GoalPanel()
		{
			super();
		}
		
		override protected function init():void{
			title = "传奇目标";
			width = 642;
			height = 469;
			
			tabbar = new TabBar();
			tabbar.x = 12;
			tabbar.y = 8;
			tabbar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,selectTabChangedHandler);
			addChild(tabbar);
			
			container = new UIComponent();
			Style.setBorderSkin(container);
			container.x = 7;
			container.y = 32;
			container.width = 628;
			container.height = 402;
			addChild(container);
			
			goalItemsBar = new GoalItemsBar();
			goalItemsBar.x = 28;
			goalItemsBar.y = 25;
			goalItemsBar.addEventListener(GoalItemsBar.GOAL_ITEM_CLICK,goalItemClickHandler);
			container.addChild(goalItemsBar);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.x = 20;
			line.y = 131;
			line.width = 590;
			container.addChild(line);
			
			goalInfoView = new GoalInfoView();
			goalInfoView.x = 20;
			goalInfoView.y = 145;
			container.addChild(goalInfoView);
			
			enabledTip = ComponentUtil.createTextField("",330,300,null,270,20,this);
			enabledTip.textColor = 0xff0000;
			enabledTip.filters = [new GlowFilter(0x0,1,3,3,3)];
			
			takeRewardBtn = ComponentUtil.createButton("领取奖励",536,366,80,25,container);
			takeRewardBtn.enabled = false;
			takeRewardBtn.addEventListener(MouseEvent.CLICK,takeRewardHandler);
			
			lingqu = Style.getBitmap(GameConfig.T1_VIEWUI,"lingqu");
			lingqu.x = 415;
			lingqu.y = 213;
			lingqu.visible = false;
			container.addChild(lingqu);
			
			var tf:TextFormat = Style.textFormat;
			tf.size = 14;
			tf.color = 0xff0000;
			errorTxt = ComponentUtil.createTextField("",160,375,tf,300,25,container);
			errorTxt.filters = [new GlowFilter(0x0,1,3,3,3)];
			
			Dispatch.register(GoalConstants.GOAL_ITEM_UPDATE,onGoalItemUpdate);
			
		}
		
		private var inited:Boolean = false;
		public function initView():void{
			if(!inited){
				var loginDay:int = GoalDataManager.getInstance().day;
				goalList = GoalDataManager.getInstance().getGoals();
				tabbar.removeItems();
				for each(var goalVO:GoalVO in goalList){
					tabbar.addItem(goalVO.label,60,26);
					var tabBtn:Button = tabbar.buttonList[goalVO.index];
					tabBtn.data = goalVO;
					tabBtn.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
					tabBtn.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
				}
				tabbar.selectIndex = 0;
				validateNow();
				inited = true;
			}
		}
		
		private function onRollOver(event:MouseEvent):void{
			var tabBtn:Button = event.currentTarget as Button;
			var goal:GoalVO = tabBtn.data as GoalVO;
			var count:int = 0;
			var size:int = goal.goalItems.length;
			for each(var goalItemVO:GoalItemVO in goal.goalItems){
				if(!goalItemVO.finished){
					count++;	
				}
			}
			var html:String = "";
			if(size > count){
				html = HtmlUtil.font("你已经完成"+(size - count)+"个目标","#00ff00")+"\n";	
			}
			if(count != 0){
				html += "你还有"+count+"个未完成目标";
			}
			ToolTipManager.getInstance().show(html,0);
		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		
		private function selectTabChangedHandler(event:TabNavigationEvent):void{
			var index:int = event.index;
			if(goalList){
				currentGoal = goalList[index];
				goalItemsBar.goalItems = currentGoal.goalItems;
			}
		}	
		
		private function goalItemClickHandler(event:ParamEvent):void{
			currentGoalItem = event.data as GoalItemVO;
			goalInfoView.goalItemVO = currentGoalItem;
			updateView();
		}
		
		private function takeRewardHandler(event:MouseEvent):void{
			if(currentGoalItem){
				 var typeId:int = goalInfoView.chooseGoods ? goalInfoView.chooseGoods.typeId : 0;
				 GoalModule.getInstance().goalFetch(currentGoalItem.id,typeId);
			}
		}
		
		private function onGoalItemUpdate(goalItemVo:GoalItemVO):void{
			if(currentGoalItem && currentGoalItem == goalItemVo){
				goalInfoView.goalItemVO = currentGoalItem;
				goalItemsBar.update(goalItemVo);
				updateView();
			}else if(goalItemVo.parent == currentGoal){
				goalItemsBar.update(goalItemVo);
			}	
		}
		
		private function updateView():void{
			lingqu.visible = currentGoalItem.takeReward;
			takeRewardBtn.enabled = !currentGoalItem.takeReward && currentGoalItem.status == 2;
			if(currentGoalItem.status == 3 && currentGoalItem.parent.active > GoalDataManager.getInstance().day){
				enabledTip.text = "当前进行的是第"+GoalDataManager.getInstance().day+"天目标，到第"+currentGoalItem.parent.active+"天即可领取奖励。";
			}else{
				enabledTip.text = "";
			}
		}
		
		
		public function addMessage(msg:String):void{
			errorTxt.text = msg;
			setTimeout(clearMessage,5000);
		}
		
		private function clearMessage():void{
			errorTxt.text = "";
		}
	}
}