package modules.Activity.view
{
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.view.itemRender.*;
	import modules.Activity.vo.AwardVo;
	import modules.ModuleCommand;
	
	import proto.line.m_activity_benefit_list_toc;

	public class BenefitView extends UIComponent
	{
		private var activeStateTxt:TextField; //活跃度获得情况
		private var benefits:TextField; //可领取福利

		private static const itemHeight:int=77;
		private var list:DataGrid; //List;
		private var itemList:DataGrid; //List;
		private var curTxt:TextField;
		private var btnGetBuyAll:Button;
		private var btnGetReward:Button;

		private var tfYellow:TextFormat;
		private var rewardedSp:Bitmap;

		private var listBase:List; //List;
		private var listExtra:List; //List;

		private var award_i:int=-1;
		private var maxActpoint:int=0;

		private var txtCurrTasks:TextField;
		private var txtBuyTip:TextField;
		private var txtExpAward:TextField;
		private var txtItemAward:TextField;

		private static const leftWidth:int=409;
		private static const rightWidth:int=210;
		private static const panelHight:int=248;

		private var bgLeft:UIComponent, bgRight:UIComponent, bgBottom:Sprite;
		private var inited:Boolean=false;

		public function BenefitView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}

		private function addToStageHandler(event:Event):void
		{
			init();
		}

		private function init():void
		{
			inited=true
			removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
			tfYellow=new TextFormat("Tahoma", 18, 0xFFFF00);
			tfYellow.align = TextFormatAlign.CENTER;

			bgRight=ComponentUtil.createUIComponent(471, 8, 164, 344);
			Style.setBorderSkin(bgRight);

			addChild(bgRight);

			listBase=new List(); //List;
			listBase.bgSkin=null;
			listBase.x=8;
			listBase.y=8; //2
			listBase.width=460;
			listBase.height=288;
			listBase.itemHeight=72;
			listBase.itemRenderer=AwardBaseItemRender;
			listBase.selected=false;
			listBase.verticalScrollPolicy=ScrollPolicy.ON;
			addChild(listBase);

			var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "hightLightLine");
			tiao.width=460;
			tiao.y=300;
			tiao.x=8;
			addChild(tiao);

			var headBar:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI, "titleBar");
			bgRight.addChild(headBar);
			headBar.width=163;
			headBar.height=19;

			var textformat:TextFormat=new TextFormat("", 12, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.CENTER);
			var rightTitle:TextField = ComponentUtil.createTextField("勋章兑换预览", 0, 3, textformat, headBar.width, 20, bgRight);
			rightTitle.filters = Style.textBlackFilter;
			
			listExtra=new List(); //List;
			listExtra.bgSkin=null;
			listExtra.x=2;
			listExtra.y=22; //2
			listExtra.width=160;
			listExtra.height=316;
			listExtra.itemHeight=73;
			listExtra.itemRenderer=AwardExtraItemRender;
			listExtra.selected=false;
			listExtra.verticalScrollPolicy=ScrollPolicy.ON;
			bgRight.addChild(listExtra);

			txtCurrTasks=ComponentUtil.createTextField("当前已完成0 个任务", 10, 312, tfYellow, 346, 60, this);

			btnGetBuyAll=ComponentUtil.createButton("获得全部勋章", 354, 306, 98, 25, this);
			btnGetBuyAll.addEventListener(MouseEvent.CLICK, onGetBuyAllClick);

			btnGetReward=ComponentUtil.createButton("领取今日奖励", 354, 332, 98, 25, this);
			btnGetReward.addEventListener(MouseEvent.CLICK, onGetRewardClick);
			btnGetReward.enabled=false;

			rewardedSp=Style.getBitmap(GameConfig.T1_VIEWUI, "lingqu");
			rewardedSp.x=355;
			rewardedSp.y=190;
			this.addChild(rewardedSp);
			rewardedSp.visible=false;
		}

		private function hideTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}

		private function showExpAwardTip(e:MouseEvent):void
		{
			var baseExp:int=ActivityModule.getInstance().benefitList.base_exp;
			var extraExp:int=ActivityModule.getInstance().benefitList.extra_exp;
			ToolTipManager.getInstance().show("基础奖励：" + baseExp + " 经验\n额外奖励：" + extraExp + " 经验", 0);
		}

		private function onGetBuyAllClick(e:MouseEvent):void
		{
			var count:int=0;
			if (ActivityModule.getInstance().benefitList)
			{
				count=ActivityModule.getInstance().benefitList.act_task_list.length;
			}
			var goldNeed:int=(9 - count) * 3;
			Alert.show("使用" + goldNeed + "个不绑定元宝可获取全部勋章，请确认是否获取！", "提示", yesHandler, null, "确定", "取消");
			function yesHandler():void
			{
				var m_gold:int=GlobalObjectManager.getInstance().user.attr.gold;
				if (m_gold >= goldNeed)
				{
					ActivityModule.getInstance().requestBuyAllBenefit();

				}
				else
				{
					Alert.show("<font color='#F6F5CD'>需要" + goldNeed + "个不绑定元宝，您的元宝不足，无法获取全部勋章！" + "<font color='#00ff00'><a href='event:chongZhi'><u>立即充值</u></a></font></font>", "提示", null, null, "确定", "", null, false, true, null, linkPay);
				}
			}
		}

		private function onGetRewardClick(e:MouseEvent):void
		{
			if (ActivityModule.getInstance().benefitList && ActivityModule.getInstance().benefitList.act_task_list.length > 0)
			{
				if (ActivityModule.getInstance().benefitList.act_task_list.length < 9)
				{
					Alert.show("每天只可以领取1次奖励，你当前奖励未达到最高级别，是否确定领取？", "提示", onConfirmRewardClick, null, "确定", "取消");
				}
				else
				{
					onConfirmRewardClick();
				}
			}
			else
			{
				Alert.show("你未完成任何1个任务，无法领取奖励。", "提示", null, null, "确定", "", null, false);
			}
		}


		private function onConfirmRewardClick():void
		{
			ActivityModule.getInstance().requestAward();
		}

		private function linkPay(e:TextEvent):void
		{
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);
		}

		public function setListResult(vo:m_activity_benefit_list_toc):void
		{
			if (!inited)
			{
				init();
			}
			if (vo.act_task_list)
			{
				var count:int=vo.act_task_list.length;
				if (count > 0)
				{
					btnGetReward.enabled=true;
				}
				count=count > 1 ? count : 1;
				if (listExtra.vScrollBar)
				{
					listExtra.vScrollPosition=(count - 1) * 87;
				}

				listBase.dataProvider=updateBaseMatchList(vo);
				listExtra.dataProvider=updateExtraMatchList(vo);
				updateTasksSummary(vo);

				if (listExtra.vScrollBar)
				{
					listExtra.vScrollPosition=(count - 1) * 87;
				}

				if (count >= ActivityModule.getInstance().baseAwardList.length)
				{
					btnGetBuyAll.enabled=false;
				}

				showItemImg(getExtraAwardVo(vo.act_task_list.length));
			}
			if (vo.is_rewarded)
			{
				rewardedSp.visible=true;
				btnGetBuyAll.visible=btnGetReward.visible=false;
			}
			else
			{
				rewardedSp.visible=false;
				btnGetBuyAll.visible=btnGetReward.visible=true;
			}
		}

		private function updateTasksSummary(vo:m_activity_benefit_list_toc):void
		{
			var count:int=vo.act_task_list.length;
			var baseExp:int=vo.base_exp;
			var extraExp:int=vo.extra_exp;
			txtCurrTasks.htmlText=HtmlUtil.font("当前"+HtmlUtil.font(String(count),"#fffd4b",18)+"个完成","#FFFFFF",18);
		}

		private function updateBaseMatchList(vo:m_activity_benefit_list_toc):Array
		{
			var taskList:Array=vo.act_task_list;
			var awardList:Array=ActivityModule.getInstance().baseAwardList;

			for (var i:int=0; i < awardList.length; i++)
			{
				awardList[i].isRewarded=vo.is_rewarded;
				awardList[i].isMatch=false;
				for (var j:int=0; j < taskList.length; j++)
				{
					if (awardList[i].id == taskList[j])
					{
						awardList[i].isMatch=true;
					}
				}
			}
			return awardList;
		}

		private function updateExtraMatchList(vo:m_activity_benefit_list_toc):Array
		{
			var count:int=vo.act_task_list.length;
			var awardList:Array=ActivityModule.getInstance().extraAwardList;
			for (var i:int=0; i < awardList.length; i++)
			{
				if (awardList[i].id == count)
				{
					awardList[i].isMatch=true;
				}
				else
				{
					awardList[i].isMatch=false;
				}
			}
			return awardList;
		}

		private function getExtraAwardVo(count:int):AwardVo
		{
			if (count <= 0)
				return null;

			var awardList:Array=ActivityModule.getInstance().extraAwardList;
			for (var i:int=0; i < awardList.length; i++)
			{
				if (awardList[i].id == count)
				{
					return awardList[i];
				}
			}

			return null;
		}

		private function showItemImg(vo:AwardVo):void
		{
			return;
			if (vo == null)
				return;

			var arr:Array=vo.itemArr;
			if (!arr || arr.length == 0)
				return;

			for (var i:int=0; i < arr.length; i++)
			{
				var obj:XML=arr[i];

				var itemImg:ActGoodsItem=new ActGoodsItem(int(obj.@itemId), int(obj.@num));
				itemImg.x=320 + 40 * i;
				itemImg.y=-2;
				bgBottom.addChild(itemImg);
				if (!vo.isMatch)
				{ // 0.212671   0.715160    0.072169
					itemImg.filters=[new ColorMatrixFilter([0.212671, 0.715160, 0.072169, 0, 0, 0.212671, 0.715160, 0.072169, 0, 0, 0.212671, 0.715160, 0.072169, 0, 0, 0, 0, 0, 1, 0])];

				}
				else
				{
					itemImg.filters=[];
				}
			}

		}


		public function setRewardResult():void
		{
			rewardedSp.visible=true;
			btnGetBuyAll.visible=btnGetReward.visible=false;
		}

	}
}