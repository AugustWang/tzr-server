package modules.Activity.view {
	import com.components.BasePanel;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.activityManager.BossGroupManager;
	import modules.conlogin.ConloginModule;
	
	import proto.common.p_goods;
	import proto.line.*;

	public class ActivityWindow extends BasePanel {
		public function ActivityWindow() {
			super("");
		}

		override protected function closeHandler(event:CloseEvent=null):void {
			super.closeHandler();
			ActivityModule.getInstance().isOpen=false;
		}

		public var tabNavigation:TabNavigation;
		public var getIndex:String="任务";
		public static var NAVIGATION_NAME:Object={EVERYDAY: "副本", BENEFIT: "今日进度", GIFT: "礼包", UPDATELVL: "活动", ADDMONEY: "BOSS",
				PERCIOUS: "道具", HORTATION:"登陆奖励",NOTICE:"公告",SPECIALACTIVITY:"节日活动"};
		public var everydayView:EveryDayActivityView;
		private var benefitView:BenefitView;
		private var giftView:GiftView;
		private var updateLvlView:EveryDayActivityView;
		private var addMoneyView:BossGroupPanel;
		private var perciousView:EveryDayActivityView;
		private var tmetext:TextField;
		private var bgsp:Sprite;
		private static const TAB_WIDTH:int=65;
		private static const TAB_HEIGHT:int=21;
		//奖励面板
		public var hortationView:HortatiaoView;
		private var noticeView:NoticeView;
		private var specialActivityView:SpecialActivityView;
		override protected function init():void {
			this.width=660;
			this.height=432;
			addImageTitle("title_todayActivety");
			addTitleBG(446);
			addContentBG(8,10,18);

			everydayView=new EveryDayActivityView(EveryDayActivityView.FB);//原
			benefitView=new BenefitView();
			giftView=new GiftView();
			updateLvlView=new EveryDayActivityView(EveryDayActivityView.ACTIVITY);
			addMoneyView=new BossGroupPanel();
			perciousView=new EveryDayActivityView();
			hortationView = new HortatiaoView();
			noticeView = new NoticeView();
			specialActivityView = new SpecialActivityView();
			tabNavigation=new TabNavigation();
			this.addChild(tabNavigation);

			tabNavigation.width=this.width - 10;
			tabNavigation.height=370;//315
			tabNavigation.x=8;
			tabNavigation.y=0;
			tabNavigation.tabBarPaddingLeft = 16;
			tabNavigation.selectedIndex=0;
			tabNavigation.addItem(NAVIGATION_NAME.BENEFIT, benefitView, TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.EVERYDAY, everydayView, TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.UPDATELVL, updateLvlView, TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.ADDMONEY, addMoneyView, TAB_WIDTH, TAB_HEIGHT);
			//tabNavigation.addItem(NAVIGATION_NAME.PERCIOUS, perciousView, TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.GIFT, giftView, TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.HORTATION, hortationView,TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.NOTICE, noticeView,TAB_WIDTH, TAB_HEIGHT);
			tabNavigation.addItem(NAVIGATION_NAME.SPECIALACTIVITY,specialActivityView,TAB_WIDTH,TAB_HEIGHT);
			tabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onTabChange);

//			var conloginBtn:Button=ComponentUtil.createButton("登陆奖励", this.width - 134, 8, 120, 25, this);
//			conloginBtn.addEventListener(MouseEvent.CLICK, onConloginTextLink);

			//请求每日活动的数据
			//ActivityModel.getInstance().requestEverydayData();
		}

		private function onConloginTextLink(e:Event):void {
			ConloginModule.getInstance().requestInfo();
		}

		private var cnt:int=0;

		//%% type::integer() 活动类型：1=普通活动，2=升级,3=赚钱,4=宝藏
		private function onTabChange(evt:TabNavigationEvent):void {
			switch (tabNavigation.selectedIndex) {
				case 0:
					getIndex=NAVIGATION_NAME.BENEFIT; // 请求领取福利
					ActivityModule.getInstance().requestBenefitList();
					break;
				case 1:
					getIndex=NAVIGATION_NAME.EVERYDAY;
					ActivityModule.getInstance().requestEverydayData(1);
					break;
				case 2: //升级
					getIndex=NAVIGATION_NAME.UPDATELVL;
					ActivityModule.getInstance().requestEverydayData(2);
					break;
				case 3: //赚钱
					getIndex=NAVIGATION_NAME.ADDMONEY;
					addMoneyView.init();
					//ActivityModule.getInstance().requestEverydayData(3);
					break;
				case 4: //礼包
					getIndex=NAVIGATION_NAME.GIFT;
					ActivityModule.getInstance().requestDynamicGift();
					break;
				case 5:
					getIndex=NAVIGATION_NAME.HORTATION;
					ActivityModule.getInstance().requestAccumulateAndContinueLogin();
					break;
				case 6:
					getIndex=NAVIGATION_NAME.NOTICE;
					break;
				case 7:
					getIndex=NAVIGATION_NAME.SPECIALACTIVITY;
					ActivityModule.getInstance().requestSpecialActivityList();
					break;
			}
		}

		/**
		 * 更新日常任务
		 * @param data
		 *
		 */
		public function setActivityEveryday(data:Object):void {
			var everydayVo:m_activity_today_toc=data as m_activity_today_toc;
			if (everydayVo == null)
				return;
			if (everydayVo.succ) {
				var arr:Array=[];
				var temArr:Array=everydayVo.activity_list;
				if (temArr.length != 0) {
					arr=temArr;
					arr.sortOn("order_id", Array.NUMERIC);
					if (getIndex == NAVIGATION_NAME.EVERYDAY) { //日程活动
						everydayView.setEveryDayData(arr);
					} else if (getIndex == NAVIGATION_NAME.UPDATELVL) {
						updateLvlView.setEveryDayData(arr);
					} else if (getIndex == NAVIGATION_NAME.ADDMONEY) {
						//addMoneyView.setEveryDayData(arr);
					} else if (getIndex == NAVIGATION_NAME.PERCIOUS) {
						perciousView.setEveryDayData(arr);
					}
				}
			}
		}

		/**
		 *更新日常福利
		 * @param data
		 *
		 */
		public function benefitListResult(vo:m_activity_benefit_list_toc):void {
			benefitView.setListResult(vo);
		}

		public function benefitRewardResult():void {
			benefitView.setRewardResult();
		}
		
		/**
		 *打开累积经验面板 
		 * 
		 */		
		public function openAccView():void{
			getIndex=NAVIGATION_NAME.HORTATION;
			tabNavigation.selectedIndex = 5;
		}

		public function updateDynamicGift(vo:m_activity_pay_gift_info_toc):void {
//			var data:Object=new Object();
//			data.id=3;
//			data.name="极品礼包";
//			data.type=3;
//			var array:Array=[];
//			var childData:Object=new Object();
//			childData.itemId=vo.typeid;
//			childData.num=1;
//			childData.msg=vo;
//			array.push(childData);
//			data.child=array;
			
			giftView.updateData(vo);
			
			//giftView.dynamicRender.data=data;
		}
		
		/**
		 * 特殊活动列表
		 * @param data
		 */
		public function specialActivityList(vo:m_special_activity_list_toc):void{
			specialActivityView.getSpecialActivityList(vo);
		}
		public function specialActivityDetail(vo:m_special_activity_detail_toc):void{
			specialActivityView.showSpecialActivityDetail(vo);
		}
	}
}