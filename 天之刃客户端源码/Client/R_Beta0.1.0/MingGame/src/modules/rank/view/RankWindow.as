package modules.rank.view {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	
	import modules.broadcast.views.Tips;
	import modules.heroFB.HeroFBDataManager;
	import modules.rank.RankModule;
	import modules.rank.view.items.MyselfItemRender;
	
	import proto.common.p_hero_fb_rank;
	import proto.common.p_ranking;
	import proto.line.m_ranking_config_toc;
	import proto.line.m_ranking_equip_join_rank_toc;
	import proto.line.m_ranking_equip_refining_rank_toc;
	import proto.line.m_ranking_equip_reinforce_rank_toc;
	import proto.line.m_ranking_equip_stone_rank_toc;
	import proto.line.m_ranking_family_active_rank_toc;
	import proto.line.m_ranking_family_gongxun_rank_toc;
	import proto.line.m_ranking_hero_fb_rank_toc;
	import proto.line.m_ranking_pet_join_rank_toc;
	import proto.line.m_ranking_role_all_rank_toc;
	import proto.line.m_ranking_role_give_flowers_last_week_rank_toc;
	import proto.line.m_ranking_role_give_flowers_rank_toc;
	import proto.line.m_ranking_role_give_flowers_today_rank_toc;
	import proto.line.m_ranking_role_give_flowers_yesterday_rank_toc;
	import proto.line.m_ranking_role_gongxun_rank_toc;
	import proto.line.m_ranking_role_level_rank_toc;
	import proto.line.m_ranking_role_pet_rank_toc;
	import proto.line.m_ranking_role_pkpoint_rank_toc;
	import proto.line.m_ranking_role_rece_flowers_last_week_rank_toc;
	import proto.line.m_ranking_role_rece_flowers_rank_toc;
	import proto.line.m_ranking_role_rece_flowers_today_rank_toc;
	import proto.line.m_ranking_role_rece_flowers_yesterday_rank_toc;
	import proto.line.m_ranking_role_today_gongxun_rank_toc;
	import proto.line.m_ranking_role_world_pkpoint_rank_toc;
	import proto.line.m_ranking_role_yesterday_gongxun_rank_toc;

	public class RankWindow extends BasePanel {
		private var levelRankBtn:ToggleButton;
		private var familyRankBtn:ToggleButton;
		private var equipRankBtn:ToggleButton; //神兵
		private var evilRankBtn:ToggleButton; //恶人
		private var protectStateRankBtn:ToggleButton; //护国
		private var flowerRankBtn:ToggleButton;
		private var giveFlowerRankBtn:ToggleButton; //送花
		private var petRankBtn:ToggleButton; //宠物
		private var heroFbRankBtn:ToggleButton; // 大明英雄
		private var myselfRankBtn:ToggleButton;
		private var blueSprite:Sprite;
		private var selectBtnIndex:int=0;
		private static var everyRankId_arr:Array;
		private var timeTxt:TextField;
		private static const TEN_MINUTE:String="每十分钟更新一次";
		private static const ONE_HOUR:String="每一小时更新一次";
//		private static const UPDATEEVILRANKTIME:String = "每一小时更新一次";
//		private static const UPDATEHERORANKTIME:String = "每一小时更新一次";
		private static const TWENTY_FOUR:String="每天24：00更新";
		private static const UPDATE_RIGHTNOW:String="即时更新";
		private static const UPDATE_WEEKDAYS:String="每周周日24：00更新";

		public function RankWindow() {
			super("RankWindow");
			this.addEventListener(CloseEvent.CLOSE, onCloseHandler);
		}

		private function onCloseHandler(evt:CloseEvent):void {
//			RankEquipToolTip.getInstance().closeHandler();
			WindowManager.getInstance().removeWindow(this);
		}

		//服务端主要推的各个排行榜的ID
		public static var soldierRankId:int;
		public static var shooterRankId:int;
		public static var travelerRankId:int;
		public static var doctorRankId:int;
		public static var worldRankId:int;
		public static var stateRankId:int;
		public static var totalRankId:int;
		public static var refineRankId:int;
		public static var insertRankId:int;
		public static var myselfRankId:int;
		public static var flourishRankId:int; //门派繁荣
		public static var graceRankId:int; //功勋
		public static var totalHeroRankId:int;
		public static var yestodayHeroId:int;
		public static var todayHeroId:int;
		public static var hundredRankId:int;
		public static var yestodayRankId:int;
		public static var todayRankId:int;
		public static var lastWeekFlowerRankId:int;
		public static var giveFlowerId:int;
		public static var yestodayGiveFlowerId:int;
		public static var todayGiveFlowerId:int;
		public static var lastWeekGiveFlowerId:int;
		public static var petId:int;
		public static var heroFbId:int;
		private var totalSprite:Sprite;

		public static function everyRankId(data:Object):void {
			var configVo:m_ranking_config_toc=data as m_ranking_config_toc;
			everyRankId_arr=configVo.rankings;
			for each (var rankVo:p_ranking in everyRankId_arr) {
				if (rankVo.rank_row == 1) { //等级
					if (rankVo.rank_column == 1) { //战士
						soldierRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) { //射手
						shooterRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 3) { //侠客
						travelerRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 4) { //医仙
						doctorRankId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 2) { //门派
					if (rankVo.rank_column == 1) { //繁荣榜
						flourishRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) { //功勋榜
						graceRankId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 3) { //总兵
					if (rankVo.rank_column == 1) { //总排名
						totalRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) { //强化排行榜
						refineRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 3) { //镶嵌排行榜
						insertRankId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 4) { //恶人榜
					if (rankVo.rank_column == 1) { //世界恶人榜
						worldRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) { //国家恶人榜
						stateRankId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 5) { //护国英雄榜
					if (rankVo.rank_column == 1) {
						totalHeroRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) { //昨日战功值
						yestodayHeroId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 3) { //今日战功值
						todayHeroId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 6) { //鲜花排行榜
					if (rankVo.rank_column == 1) {
						hundredRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) {
						yestodayRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 3) {
						todayRankId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 4) {
						lastWeekFlowerRankId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 7) { //送花排行榜
					if (rankVo.rank_column == 1) {
						giveFlowerId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 2) {
						yestodayGiveFlowerId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 3) {
						todayGiveFlowerId=rankVo.rank_id;
					}
					if (rankVo.rank_column == 4) {
						lastWeekGiveFlowerId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 8) { //宠物排行榜
					if (rankVo.rank_column == 1) {
						petId=rankVo.rank_id;
					}
				}
				if (rankVo.rank_row == 9) { // 大明英雄榜
					if (rankVo.rank_column == 1) {
						heroFbId = rankVo.rank_id;
					}
				}
//				if(rankVo.rank_row == 6){//我的排行
//					myselfRankId = rankVo.rank_id;
//				}
			}
		}

		override protected function init():void {
			
			this.width=579;
			this.height=400;
			addTitleBG(446);
			addImageTitle("title_rank")
			this.x=(1000 - this.width) / 2;
			this.y=(GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			
			//左边蓝色背景
			var leftBackUI:UIComponent = ComponentUtil.createUIComponent(10,10,115,343);
			Style.setBorderSkin(leftBackUI);
			this.addChild(leftBackUI);
			//时间的背景
			var purpleUI:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"paihangBar");
			this.addChild(purpleUI);
			purpleUI.x=389;
			purpleUI.y=12;

			//时间
			var tf:TextFormat=new TextFormat();
			tf.color=0xffffff;
			tf.align=TextFormatAlign.RIGHT;
			timeTxt=ComponentUtil.createTextField("", 428, 15, tf, 120, 26, this);

			//深蓝色背景
//			blueSprite=Style.getBlackSprite(433, 305, 2);
			blueSprite=new Sprite();
			this.addChild(blueSprite);
			blueSprite.x=leftBackUI.x + leftBackUI.width + 4;
			blueSprite.y=40;

			//各个按钮
			levelRankBtn=ComponentUtil.createToggleButton("等级排行榜", 7, 11, 100, 25, leftBackUI);
			levelRankBtn.name="levelRankBtn";
			levelRankBtn.selected=true;
			preToggleButton=levelRankBtn;
			levelRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			familyRankBtn=ComponentUtil.createToggleButton("门派排行榜", levelRankBtn.x, levelRankBtn.y + levelRankBtn.height, 100, 25, leftBackUI);
			familyRankBtn.name="familyRankBtn";
			familyRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			equipRankBtn=ComponentUtil.createToggleButton("神兵排行榜", familyRankBtn.x, familyRankBtn.y + familyRankBtn.height, 100, 25, leftBackUI);
			equipRankBtn.name="equipRankBtn";
			equipRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			evilRankBtn=ComponentUtil.createToggleButton("恶人排行榜", equipRankBtn.x, equipRankBtn.y + equipRankBtn.height, 100, 25, leftBackUI);
			evilRankBtn.name="evilRankBtn";
			evilRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			protectStateRankBtn=ComponentUtil.createToggleButton("护国英雄榜", evilRankBtn.x, evilRankBtn.y + evilRankBtn.height, 100, 25, leftBackUI);
			protectStateRankBtn.name="protectStateRankBtn";
			protectStateRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			flowerRankBtn=ComponentUtil.createToggleButton("鲜花排行榜", protectStateRankBtn.x, protectStateRankBtn.y + protectStateRankBtn.height, 100, 25, leftBackUI);
			flowerRankBtn.name="flowerRankBtn";
			flowerRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			giveFlowerRankBtn=ComponentUtil.createToggleButton("送花排行榜", flowerRankBtn.x, flowerRankBtn.y + flowerRankBtn.height, 100, 25, leftBackUI);
			giveFlowerRankBtn.name="giveFlowerRankBtn";
			giveFlowerRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			petRankBtn=ComponentUtil.createToggleButton("宠物排行榜", giveFlowerRankBtn.x, giveFlowerRankBtn.y + giveFlowerRankBtn.height, 100, 25, leftBackUI);
			petRankBtn.name="petRankBtn";
			petRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			
			heroFbRankBtn=ComponentUtil.createToggleButton("战役排行榜", petRankBtn.x, petRankBtn.y + petRankBtn.height, 100, 25, leftBackUI);
			heroFbRankBtn.name="heroFbRankBtn";
			heroFbRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			myselfRankBtn=ComponentUtil.createToggleButton("我的排行", protectStateRankBtn.x, 315, 100, 25, leftBackUI);
			myselfRankBtn.name="myselfRankBtn";
			myselfRankBtn.addEventListener(MouseEvent.CLICK, onMouseClickHandler);

			//各个功能模块都装载到这个sprite里，方便移除
			totalSprite=new Sprite();
			this.addChild(totalSprite);
			totalSprite.x=blueSprite.x;
			totalSprite.y=12;
		}

		public function getCurrentIndex():int {
			return this.selectBtnIndex;
		}

		private function clear():void {
			blueSprite.height=305;
			blueSprite.y=40;

			while (totalSprite.numChildren > 0) {
				totalSprite.removeChildAt(0);
			}
		}

		//事件的处理
		private var level_time:int;
		private var family_time:int;
		private var equip_time:int;
		private var evil_time:int;
		private var hero_time:int;
		private var my_time:int;
		private var flower_time:int;
		private var give_flower_time:int;
		private var pet_time:int;
		private var heroFbTime:int;
		private var preToggleButton:ToggleButton;

		private function onMouseClickHandler(evt:MouseEvent):void {
			if (evt.currentTarget.name == "levelRankBtn") {
				setSeleteBtn(1, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "familyRankBtn") {
				setSeleteBtn(2, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "equipRankBtn") {
				setSeleteBtn(3, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "evilRankBtn") {
				setSeleteBtn(4, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "protectStateRankBtn") {
				setSeleteBtn(5, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "myselfRankBtn") {
				setSeleteBtn(6, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "flowerRankBtn") {
				setSeleteBtn(7, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "giveFlowerRankBtn") {
				setSeleteBtn(8, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "petRankBtn") {
				setSeleteBtn(9, ToggleButton(evt.currentTarget));
			} else if (evt.currentTarget.name == "heroFbRankBtn") {
				setSeleteBtn(10, ToggleButton(evt.currentTarget));
			}
		}
		
		public function setSeleteBtn(index:int, currentTarget:ToggleButton=null):void
		{
			clear();
			var name:String = "";
			switch (index) {
				case 1:
					name = "levelRankBtn";
					levelRank();
					selectBtnIndex=1;
					timeTxt.text=TEN_MINUTE;
					if (getTimer() - level_time < 5000) {
						this.casheData();
						return;
					}
					level_time=getTimer();
					RankModule.getInstance().requestLevelRankData(soldierRankId);
					break;
				case 2:
					name = "familyRankBtn";
					familyRank();
					selectBtnIndex=2;
					timeTxt.text=ONE_HOUR;
					if (getTimer() - family_time < 5000) {
						this.casheData();
						return;
					}
					family_time=getTimer();
					RankModule.getInstance().requestLevelRankData(flourishRankId);
					break;
				case 3:
					name = "equipRankBtn";
					equipRank();
					selectBtnIndex=3;
					timeTxt.text="";
					if (getTimer() - equip_time < 5000) {
						this.casheData();
						return;
					}
					equip_time=getTimer();
					RankModule.getInstance().requestLevelRankData(totalRankId);
					break;
				case 4:
					name = "evilRankBtn";
					evilRank();
					selectBtnIndex=4;
					timeTxt.text=ONE_HOUR;
					if (getTimer() - evil_time < 5000) {
						this.casheData();
						return;
					}
					evil_time=getTimer();
					RankModule.getInstance().requestLevelRankData(worldRankId);
					break
				case 5:
					name = "protectStateRankBtn";
					heroRank();
					selectBtnIndex=5;
					timeTxt.text=ONE_HOUR;
					if (getTimer() - hero_time < 5000) {
						this.casheData();
						return;
					}
					hero_time=getTimer();
					RankModule.getInstance().requestLevelRankData(totalHeroRankId);
					break
				case 6:
					name = "myselfRankBtn";
					myselfRank();
					selectBtnIndex=6;
					timeTxt.text="";
					if (getTimer() - my_time < 5000) {
						this.casheData();
						return;
					}
					my_time=getTimer();
					RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
					break
				case 7:
					name = "flowerRankBtn";
					flowerRank();
					selectBtnIndex=7;
					timeTxt.text=UPDATE_RIGHTNOW;
					if (getTimer() - flower_time < 5000) {
						this.casheData();
						return;
					}
					flower_time=getTimer();
					RankModule.getInstance().requestLevelRankData(todayRankId);
					break
				case 8:
					name = "giveFlowerRankBtn";
					giveFlowerRank();
					selectBtnIndex=8;
					timeTxt.text=UPDATE_RIGHTNOW;
					if (getTimer() - give_flower_time < 5000) {
						this.casheData();
						return;
					}
					give_flower_time=getTimer();
					RankModule.getInstance().requestLevelRankData(todayGiveFlowerId);
					break
				case 9:
					name = "petRankBtn";
					petRank();
					selectBtnIndex=9;
					timeTxt.text="";
					if (getTimer() - pet_time < 5000) {
						this.casheData();
						return;
					}
					pet_time=getTimer();
					RankModule.getInstance().requestLevelRankData(petId);
					break
				case 10:
					name = "heroFbRankBtn";
					heroFbRank();
					selectBtnIndex = 10;
					timeTxt.text = "";
					if (getTimer() - heroFbTime < 5000) {
						this.casheData();
						return;
					}
					heroFbTime = getTimer();
					RankModule.getInstance().requestLevelRankData(heroFbId);
					break;
			}
			
			var target:ToggleButton = currentTarget;
			if (target == null) {
				target = this.getChildByName(name) as ToggleButton;
			}
			if (preToggleButton && preToggleButton != target) {
				preToggleButton.selected = false;
			}
			if (target) {
				preToggleButton = target;
				target.selected = true;
			}
		}

		//等级排行榜
		private var levelTabNavigation:TabNavigation;
		private var soldierRankView:SoldierRankView;
		private var shooterRankView:ShooterRankView;
		private var travelerRankView:TravelerRankView;
		private var doctorRankView:DoctorRankView;

		private function levelRank():void {
			if (!soldierRankView) {
				soldierRankView=new SoldierRankView();
			}
			if (!shooterRankView) {
				shooterRankView=new ShooterRankView();
			}
			if (!travelerRankView) {
				travelerRankView=new TravelerRankView();
			}
			if (!doctorRankView) {
				doctorRankView=new DoctorRankView();
			}
			if (!levelTabNavigation) {
				levelTabNavigation=new TabNavigation();
				Style.setBorderSkin(levelTabNavigation.tabContainer);
				levelTabNavigation.width=440;
				levelTabNavigation.height=343;
				soldierRankView.y = shooterRankView.y = travelerRankView.y = doctorRankView.y = 5;
				levelTabNavigation.addItem("战士排行榜", soldierRankView, 75, 25);
				levelTabNavigation.addItem("射手排行榜", shooterRankView, 75, 25);
				levelTabNavigation.addItem("侠客排行榜", travelerRankView, 75, 25);
				levelTabNavigation.addItem("医仙排行榜", doctorRankView, 75, 25);
				levelTabNavigation.selectedIndex=0;
				levelTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeLevelHandler);
			}
			totalSprite.addChild(levelTabNavigation);
		}

		private var levelCnt:int=0;

		private function onChangeLevelHandler(evt:TabNavigationEvent):void {
			if (levelTabNavigation.selectedIndex == 0) {
				if (levelCnt != 0) {
					RankModule.getInstance().requestLevelRankData(soldierRankId);
				}
				levelCnt++;
			} else if (levelTabNavigation.selectedIndex == 1) {
				RankModule.getInstance().requestLevelRankData(shooterRankId);
			} else if (levelTabNavigation.selectedIndex == 2) {
				RankModule.getInstance().requestLevelRankData(travelerRankId);
			} else if (levelTabNavigation.selectedIndex == 3) {
				RankModule.getInstance().requestLevelRankData(doctorRankId);
			}
		}

		//门派排行榜
		private var familyTabNavigation:TabNavigation;
		private var familyFlourishView:FamilyFlourishView;
		private var graceRankView:GraceRankView;

		private function familyRank():void {
			if (!familyFlourishView) {
				familyFlourishView=new FamilyFlourishView();
			}
			if (!graceRankView) {
				graceRankView=new GraceRankView();
			}
			if (!familyTabNavigation) {
				familyTabNavigation=new TabNavigation();
				Style.setBorderSkin(familyTabNavigation.tabContainer);
				familyTabNavigation.width=440;
				familyTabNavigation.height=343;
				familyFlourishView.y = graceRankView.y = 5;
				familyTabNavigation.addItem("世界门派排行榜", familyFlourishView, 110, 25);
				familyTabNavigation.addItem("本国门派战功榜", graceRankView, 110, 25);
				familyTabNavigation.selectedIndex=0;
				familyTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeFamilyHandler);
			}
			totalSprite.addChild(familyTabNavigation);
		}

		private var familyCnt:int=0;

		private function onChangeFamilyHandler(evt:TabNavigationEvent):void {
			if (familyTabNavigation.selectedIndex == 0) {
				if (familyCnt != 0) {
					RankModule.getInstance().requestLevelRankData(flourishRankId);
				}
				familyCnt++;
			} else {
				RankModule.getInstance().requestLevelRankData(graceRankId);
			}
		}

		//神兵排行榜
		private var equipTabNavigation:TabNavigation;
		private var totalRankView:TotalRankView;
		private var refineRankView:RefineRankView;
		private var insertRankView:InsertRankView;
		private var joinBtn:Button;

		private function equipRank():void {
			if (!totalRankView) {
				totalRankView=new TotalRankView();
			}
			if (!refineRankView) {
				refineRankView=new RefineRankView();	
			}
			if (!insertRankView) {
				insertRankView=new InsertRankView();
				
			}
			if (!equipTabNavigation) {
				equipTabNavigation=new TabNavigation();
				Style.setBorderSkin(equipTabNavigation.tabContainer);
				equipTabNavigation.selectedIndex=0;
				equipTabNavigation.width=440;
				equipTabNavigation.height=343;
				totalRankView.y = insertRankView.y = refineRankView.y = 5;
				equipTabNavigation.addItem("神兵总分榜", totalRankView, 75, 25);
				equipTabNavigation.addItem("强化排行榜", refineRankView, 75, 25);
				equipTabNavigation.addItem("镶嵌排行榜", insertRankView, 75, 25);
				equipTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeEquipHandler);
			}
			totalSprite.addChild(equipTabNavigation);

			//我要参与
			if (!joinBtn) {
				joinBtn=new Button();
				joinBtn.label="我要参与排名";
				joinBtn.width=85;
				joinBtn.height=25;
				joinBtn.x=350;
				joinBtn.y=equipTabNavigation.y;
				joinBtn.addEventListener(MouseEvent.CLICK, onMouseClickJoinHandler);
			}
			totalSprite.addChild(joinBtn);

		}

		private var equipCnt:int=0;

		private function onChangeEquipHandler(evt:TabNavigationEvent):void {
			if (equipTabNavigation.selectedIndex == 0) {
				if (equipCnt != 0) {
					RankModule.getInstance().requestLevelRankData(totalRankId);
				}
				equipCnt++;
			} else if (equipTabNavigation.selectedIndex == 1) {
				RankModule.getInstance().requestLevelRankData(refineRankId);
			} else if (equipTabNavigation.selectedIndex == 2) {
				RankModule.getInstance().requestLevelRankData(insertRankId);
			}
		}
		private var equipListView:EquipListView;

		private function onMouseClickJoinHandler(evt:MouseEvent):void {
			if (!equipListView) {
				equipListView=new EquipListView();
			}
			if (equipTabNavigation.selectedIndex == 0) {
				equipListView.updateTileListData(totalRankId, 0);
			} else if (equipTabNavigation.selectedIndex == 1) {
				equipListView.updateTileListData(refineRankId, 1);
			} else if (equipTabNavigation.selectedIndex == 2) {
				equipListView.updateTileListData(insertRankId, 2);
			}
			WindowManager.getInstance().popUpWindow(equipListView, WindowManager.UNREMOVE);
		}

		//恶人榜
		private var EvilTabNavgation:TabNavigation;
		private var worldEvilView:WorldEvilView;
		private var stateEvilView:StateEvilView;

		private function evilRank():void {
			if (!worldEvilView) {
				worldEvilView=new WorldEvilView();
			}
			if (!stateEvilView) {
				stateEvilView=new StateEvilView();
			}
			if (!EvilTabNavgation) {
				EvilTabNavgation=new TabNavigation();
				Style.setBorderSkin(EvilTabNavgation.tabContainer);
				EvilTabNavgation.width=440;
				EvilTabNavgation.height=343;
				worldEvilView.y = stateEvilView.y = 5;
				EvilTabNavgation.addItem("世界恶人榜", worldEvilView, 70, 25);
				EvilTabNavgation.addItem("国家恶人榜", stateEvilView, 70, 25);
				EvilTabNavgation.selectedIndex=0;
				EvilTabNavgation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeEvilHandler);
			}
			totalSprite.addChild(EvilTabNavgation);
		}

		private var EvilCnt:int=0;

		private function onChangeEvilHandler(evt:TabNavigationEvent):void {
			if (EvilTabNavgation.selectedIndex == 0) { //世界恶人榜
				if (EvilCnt != 0) {
					RankModule.getInstance().requestLevelRankData(worldRankId);
				}
				EvilCnt++;
			} else {
				RankModule.getInstance().requestLevelRankData(stateRankId);
			}
		}

		//护国英雄榜
		private var heroSprite:Sprite;
		private var heroTabNavigation:TabNavigation;
		private var totalHeroRankView:TotalHeroRankView;
		private var yestodayHeroRankView:YestodayHeroRankView;
		private var todayHeroRankView:TodayHeroRankView;

		private function heroRank():void {
			if (!totalHeroRankView) {
				totalHeroRankView=new TotalHeroRankView();
			}
			if (!yestodayHeroRankView) {
				yestodayHeroRankView=new YestodayHeroRankView();
			}
			if (!todayHeroRankView) {
				todayHeroRankView=new TodayHeroRankView();
			}
			if (!heroTabNavigation) {
				heroTabNavigation=new TabNavigation();
				Style.setBorderSkin(heroTabNavigation.tabContainer);
				heroTabNavigation.width=440;
				heroTabNavigation.height=343;
				totalHeroRankView.y = yestodayHeroRankView.y = todayHeroRankView.y = 5;
				heroTabNavigation.addItem("护国总分榜", totalHeroRankView, 70, 25);
				heroTabNavigation.addItem("昨日护国榜", yestodayHeroRankView, 70, 25);
				heroTabNavigation.addItem("今日护国榜", todayHeroRankView, 70, 25);
				heroTabNavigation.selectedIndex=0;
				heroTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeHeroHandler);
			}
			totalSprite.addChild(heroTabNavigation);

		}

		private var heroCnt:int=0;

		private function onChangeHeroHandler(evt:TabNavigationEvent):void {
			if (heroTabNavigation.selectedIndex == 0) { //护国英雄榜
				if (heroCnt != 0) {
					RankModule.getInstance().requestLevelRankData(totalHeroRankId);
					timeTxt.text=ONE_HOUR;
				}
				heroCnt++;
			} else if (heroTabNavigation.selectedIndex == 1) {
				RankModule.getInstance().requestLevelRankData(yestodayHeroId);
				timeTxt.text=TWENTY_FOUR;
			} else if (heroTabNavigation.selectedIndex == 2) {
				RankModule.getInstance().requestLevelRankData(todayHeroId);
				timeTxt.text=ONE_HOUR;
			}
		}

		//鲜花排行榜
		private var flowerTabNavigation:TabNavigation;
		private var hundredFlowerRankView:HundredFlowerRankView;
		private var yestodayFlowerRankView:YestodayFlowerRankView;
		private var todayFlowerRankView:TodayFlowerRankView;
		private var lastWeekFlowerRankView:LastWeekFlowerRankView;

		private function flowerRank():void {
			if (!hundredFlowerRankView) {
				hundredFlowerRankView=new HundredFlowerRankView();
			}
			if (!yestodayFlowerRankView) {
				yestodayFlowerRankView=new YestodayFlowerRankView();
			}
			if (!todayFlowerRankView) {
				todayFlowerRankView=new TodayFlowerRankView();
			}
			if (!lastWeekFlowerRankView) {
				lastWeekFlowerRankView=new LastWeekFlowerRankView();
			}
			if (!flowerTabNavigation) {
				flowerTabNavigation=new TabNavigation();
				Style.setBorderSkin(flowerTabNavigation.tabContainer);
				flowerTabNavigation.width=440;
				flowerTabNavigation.height=343;
				todayFlowerRankView.y = yestodayFlowerRankView.y = lastWeekFlowerRankView.y = hundredFlowerRankView.y = 5;
				flowerTabNavigation.addItem("今日鲜花榜", todayFlowerRankView, 70, 25);
				flowerTabNavigation.addItem("昨日鲜花榜", yestodayFlowerRankView, 70, 25);
				flowerTabNavigation.addItem("上周鲜花榜", lastWeekFlowerRankView, 70, 25);
				flowerTabNavigation.addItem("百花谱", hundredFlowerRankView, 70, 25);
				flowerTabNavigation.selectedIndex=0;
				flowerTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeFlowerHandler);
			}
			totalSprite.addChild(flowerTabNavigation);
		}

		private var flowerCnt:int=0;

		private function onChangeFlowerHandler(evt:TabNavigationEvent):void {
			if (flowerTabNavigation.selectedIndex == 0) { //今日
				if (flowerCnt != 0) {
					RankModule.getInstance().requestLevelRankData(todayRankId);
				}
				flowerCnt++;
				timeTxt.text=UPDATE_RIGHTNOW;
			} else if (flowerTabNavigation.selectedIndex == 1) { //昨日
				RankModule.getInstance().requestLevelRankData(yestodayRankId);
				timeTxt.text=TWENTY_FOUR;
			} else if (flowerTabNavigation.selectedIndex == 2) { //上周
				RankModule.getInstance().requestLevelRankData(lastWeekFlowerRankId);
				timeTxt.text=UPDATE_WEEKDAYS;
			} else if (flowerTabNavigation.selectedIndex == 3) { //百花谱
				RankModule.getInstance().requestLevelRankData(hundredRankId);
				timeTxt.text=TWENTY_FOUR;
			}
		}

		//送花排行榜
		private var giveFlowerTabNavigation:TabNavigation;
		private var giveFlowerRankView:GiveFlowerRankView;
		private var yestodayGiveFlowerRankView:YestodayGiveFlowerRankView;
		private var todayGiveFlowerRankView:TodayGiveFlowerRankView;
		private var lastWeekGiveFlowerRankView:LastWeekGiveFlowerRankView;

		private function giveFlowerRank():void {
			if (!giveFlowerRankView) {
				giveFlowerRankView=new GiveFlowerRankView();
			}
			if (!yestodayGiveFlowerRankView) {
				yestodayGiveFlowerRankView=new YestodayGiveFlowerRankView();
			}
			if (!todayGiveFlowerRankView) {
				todayGiveFlowerRankView=new TodayGiveFlowerRankView();
			}
			if (!lastWeekGiveFlowerRankView) {
				lastWeekGiveFlowerRankView=new LastWeekGiveFlowerRankView();
			}
			if (!giveFlowerTabNavigation) {
				giveFlowerTabNavigation=new TabNavigation();
				Style.setBorderSkin(giveFlowerTabNavigation.tabContainer);
				giveFlowerTabNavigation.width=440;
				giveFlowerTabNavigation.height=343;
				todayGiveFlowerRankView.y = yestodayGiveFlowerRankView.y = lastWeekGiveFlowerRankView.y = giveFlowerRankView.y = 5;
				giveFlowerTabNavigation.addItem("今日送花榜", todayGiveFlowerRankView, 70, 25);
				giveFlowerTabNavigation.addItem("昨日送花榜", yestodayGiveFlowerRankView, 70, 25);
				giveFlowerTabNavigation.addItem("上周送花榜", lastWeekGiveFlowerRankView, 70, 25);
				giveFlowerTabNavigation.addItem("送花谱", giveFlowerRankView, 70, 25);
				giveFlowerTabNavigation.selectedIndex=0;
				giveFlowerTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeGiveFlowerHandler);
			}
			totalSprite.addChild(giveFlowerTabNavigation);
		}

		private var giveFlowerCnt:int=0;

		private function onChangeGiveFlowerHandler(evt:TabNavigationEvent):void {
			if (giveFlowerTabNavigation.selectedIndex == 0) { //今日
				if (giveFlowerCnt != 0) {
					RankModule.getInstance().requestLevelRankData(todayGiveFlowerId);
				}
				giveFlowerCnt++;
				timeTxt.text=UPDATE_RIGHTNOW;
			} else if (giveFlowerTabNavigation.selectedIndex == 1) { //昨日
				RankModule.getInstance().requestLevelRankData(yestodayGiveFlowerId);
				timeTxt.text=TWENTY_FOUR;
			} else if (giveFlowerTabNavigation.selectedIndex == 2) { //上周
				RankModule.getInstance().requestLevelRankData(lastWeekGiveFlowerId);
				timeTxt.text=UPDATE_WEEKDAYS;
			} else if (giveFlowerTabNavigation.selectedIndex == 3) { //送花谱
				RankModule.getInstance().requestLevelRankData(giveFlowerId);
				timeTxt.text=TWENTY_FOUR;
			}
		}
		
		// 大明英雄榜
		private var heroFbTab:TabNavigation;
		private var heroFBRankView:HeroFBRankView;
		private var heroFBGoBtn:Button;
		
		private function heroFbRank():void
		{
			if (!heroFBRankView)
				heroFBRankView = new HeroFBRankView;
			if (!heroFbTab) {
				heroFbTab = new TabNavigation;
				Style.setBorderSkin(heroFbTab.tabContainer);
				heroFbTab.selectedIndex = 0;
				heroFbTab.width=440;
				heroFbTab.height=343;
				heroFBRankView.y = 5;
				heroFbTab.addItem("战役排行榜", heroFBRankView, 75, 25);
				heroFbTab.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeHeroFBHandler);
			}
			totalSprite.addChild(heroFbTab);
			
			if (!heroFBGoBtn) {
				heroFBGoBtn=new Button();
				heroFBGoBtn.label="前往副本";
				heroFBGoBtn.width=85;
				heroFBGoBtn.height=25;
				heroFBGoBtn.x=350;
				heroFBGoBtn.y=heroFbTab.y;
				heroFBGoBtn.addEventListener(MouseEvent.CLICK, onMouseClickHeroFBGoHandler);
			}
			totalSprite.addChild(heroFBGoBtn);
		}
		
		private var heroFBCnt:int=0;
		
		private function onChangeHeroFBHandler(evt:TabNavigationEvent):void {
			if (heroFbTab.selectedIndex == 0) {
				if (heroFBCnt != 0) {
					RankModule.getInstance().requestLevelRankData(heroFbId);
				}
				heroFBCnt++;
			}
		}
		
		private function onMouseClickHeroFBGoHandler(evt:MouseEvent):void
		{
			Alert.show("花费一个传送卷可以传送到大明英雄副本传送员附近，也可以点击寻路前往", "温馨提示", yesHandler, noHandler, "传送", "寻路前往", null, true, true);
			
			function yesHandler():void
			{
				PathUtil.carryNPC(HeroFBDataManager.getInstance().getHeroFbNpcId().toString());	
			}
			
			function noHandler():void
			{
				PathUtil.findNPC(HeroFBDataManager.getInstance().getHeroFbNpcId().toString());
			}
		}

		//宠物排行榜
		private var petTabNavigation:TabNavigation;
		private var petTotalRankView:PetTotalRankView;

		private var petJoinBtn:Button;

		private function petRank():void {
			if (!petTotalRankView) {
				petTotalRankView=new PetTotalRankView();
			}
			if (!petTabNavigation) {
				petTabNavigation=new TabNavigation();
				Style.setBorderSkin(petTabNavigation.tabContainer);
				petTabNavigation.width=440;
				petTabNavigation.height=343;
				petTabNavigation.selectedIndex=0;
				petTotalRankView.y = 5;
				petTabNavigation.addItem("总分榜", petTotalRankView, 75, 25);

				petTabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangePetHandler);
			}
			totalSprite.addChild(petTabNavigation);

			//我要参与
			if (!petJoinBtn) {
				petJoinBtn=new Button();
				petJoinBtn.label="我要参与排名";
				petJoinBtn.width=85;
				petJoinBtn.height=25;
				petJoinBtn.x=350;
				petJoinBtn.y=petTabNavigation.y;
				petJoinBtn.addEventListener(MouseEvent.CLICK, onMouseClickPetJoinHandler);
			}
			totalSprite.addChild(petJoinBtn);

		}

		private var petCnt:int=0;

		private function onChangePetHandler(evt:TabNavigationEvent):void {
			if (petTabNavigation.selectedIndex == 0) {
				if (petCnt != 0) {
					RankModule.getInstance().requestLevelRankData(petId);
				}
				petCnt++;
			}
		}
		private var petListView:PetListView;

		private function onMouseClickPetJoinHandler(evt:MouseEvent):void {
			if (!petListView) {
				petListView=PetListView.getInstance();
			}
			if (petTabNavigation.selectedIndex == 0) {
				petListView.joinRank(petId);
			}
			WindowManager.getInstance().popUpWindow(petListView, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(petListView);
		}

		//我的排行(玩家排行榜)
		private var myGrid:DataGrid;
		private var skin:Skin=new Skin();

		private function myselfRank():void {
			blueSprite.height=335;
			blueSprite.y=12;
			if (!myGrid) {
				myGrid=new DataGrid();
				Style.setBorderSkin(myGrid);
				myGrid.width=437;
				myGrid.height=340;
				
//				var bg:UIComponent=new UIComponent();
//				bg.width=myGrid.width;
//				bg.height=myGrid.height;
//				Style.setBorderSkin(bg);
//				totalSprite.addChild(bg);
				
				myGrid.mouseEnabled=false;
				myGrid.addColumn("序号", 50);
				myGrid.addColumn("排行名称", 80);
				myGrid.addColumn("对应值", 242);
				myGrid.addColumn("排名", 67); //-17
				myGrid.itemHeight=25;
				myGrid.itemRenderer=MyselfItemRender;
				myGrid.list.setOverItemSkin(skin);
				myGrid.list.setSelectItemSkin(skin);
			}
			totalSprite.addChild(myGrid);
		}

		//服务端返回的数据处理
		public static var levelIndex:int=0;
		public static var familyIndex:int=0;
		public static var selectIndex:int=0;
		public static var evilIndex:int=-1;
		public static var heroIndex:int=0;
		public static var flowerIndex:int=0;
		public static var giveFlowerIndex:int=0;
		public static var petIndex:int=0;
		public static var heroFBIndex:int = 0;
		private var levelArr:Array=[]; //缓存等级排行的数据
		private var familyArr:Array=[];
		private var equipArr:Array=[];
		private var evilArr:Array=[];
		private var heroArr:Array=[];
		private var myselfArr:Array=[];
		private var flowerArr:Array=[];
		private var giveFlowerArr:Array=[];
		private var petArr:Array=[];
		private var heroFBArr:Array = [];

		public function handlerDataFromService(data:Object):void {
			switch (selectBtnIndex) {
				case 1: //等级排行榜
					if (data is m_ranking_role_level_rank_toc) {
						levelIndex=levelTabNavigation.selectedIndex;
						var levelVo:m_ranking_role_level_rank_toc=data as m_ranking_role_level_rank_toc;
						if (levelTabNavigation.selectedIndex == 0) {
							if (levelArr == null)
								return;
							levelArr=levelVo.role_level_ranks;
							if (levelArr.length != 0) {
								soldierRankView.changeData(levelArr);
							}
						} else if (levelTabNavigation.selectedIndex == 1) {
							if (levelArr == null)
								return;
							levelArr=levelVo.role_level_ranks;
							if (levelArr.length != 0) {
								shooterRankView.changeData(levelArr);
							}
						} else if (levelTabNavigation.selectedIndex == 2) {
							if (levelArr == null)
								return;
							levelArr=levelVo.role_level_ranks;
							if (levelArr.length != 0) {
								travelerRankView.changeData(levelArr);
							}
						} else if (levelTabNavigation.selectedIndex == 3) {
							if (levelArr == null)
								return;
							levelArr=levelVo.role_level_ranks;
							if (levelArr.length != 0) {
								doctorRankView.changeData(levelArr);
							}
						}
					} else {
						var playerVo:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo == null)
							return;
						if (playerVo.is_self == false) {
							if (playerVo.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo.role_all_ranks, playerVo.role_name, playerVo.level, playerVo.family_name);
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}
					break;
				case 2: //门派繁荣排行榜
					familyIndex=familyTabNavigation.selectedIndex;
					if (familyTabNavigation.selectedIndex == 0) {
						var familyVo:m_ranking_family_active_rank_toc=data as m_ranking_family_active_rank_toc;
						if (familyVo == null)
							return;
						familyArr=familyVo.family_active_ranks;
						if (familyArr.length != 0) {
							familyFlourishView.changeData(familyArr);
						}
					} else {
						var graceVo:m_ranking_family_gongxun_rank_toc=data as m_ranking_family_gongxun_rank_toc;
						if (graceVo == null)
							return;
						familyArr=graceVo.family_gongxun_ranks;
						if (familyArr.length != 0) {
							graceRankView.changeData(familyArr);
						}
					}
					break;
				case 3: //神兵排行榜
					if (data is m_ranking_role_all_rank_toc) {
						var playerVo1:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo1 == null)
							return;
						if (playerVo1.is_self == false) {
							if (playerVo1.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo1.role_all_ranks, playerVo1.role_name, playerVo1.level, playerVo1.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}

					selectIndex=equipTabNavigation.selectedIndex;
					if (data is m_ranking_equip_join_rank_toc) {
						var joinVo:m_ranking_equip_join_rank_toc=data as m_ranking_equip_join_rank_toc;
						if (joinVo == null)
							return;
						if (joinVo.succ) {
							if (equipTabNavigation.selectedIndex == 0) {
								RankModule.getInstance().requestLevelRankData(totalRankId);
								selectIndex=0;
							} else if (equipTabNavigation.selectedIndex == 1) {
								RankModule.getInstance().requestLevelRankData(refineRankId);
								selectIndex=1;
							} else if (equipTabNavigation.selectedIndex == 2) {
								RankModule.getInstance().requestLevelRankData(insertRankId);
							}
						} else {
							Tips.getInstance().addTipsMsg(joinVo.reason);
						}
					} else {
						if (equipTabNavigation.selectedIndex == 0) {
							var totalVo:m_ranking_equip_refining_rank_toc=data as m_ranking_equip_refining_rank_toc;
							if (totalVo == null)
								return;
							equipArr=totalVo.equip_refining_ranks;
							totalRankView.changeData(equipArr);
						} else if (equipTabNavigation.selectedIndex == 1) {
							var refineVo:m_ranking_equip_reinforce_rank_toc=data as m_ranking_equip_reinforce_rank_toc;
							if (refineVo == null)
								return;
							equipArr=refineVo.equip_reinforce_ranks;
							refineRankView.changeData(equipArr);
						} else if (equipTabNavigation.selectedIndex == 2) {
							var insertVo:m_ranking_equip_stone_rank_toc=data as m_ranking_equip_stone_rank_toc;
							if (insertVo == null)
								return;
							equipArr=insertVo.equip_stone_ranks;
							insertRankView.changeData(equipArr);
						}
					}

					break;
				case 4: //恶人排行榜
					if (data is m_ranking_role_all_rank_toc) {
						var playerVo3:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo3 == null)
							return;
						if (playerVo3.is_self == false) {
							if (playerVo3.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo3.role_all_ranks, playerVo3.role_name, playerVo3.level, playerVo3.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}
					evilIndex=EvilTabNavgation.selectedIndex;
					if (EvilTabNavgation.selectedIndex == 0) { //世界恶人榜
						var wordEvilVo:m_ranking_role_world_pkpoint_rank_toc=data as m_ranking_role_world_pkpoint_rank_toc;
						if (wordEvilVo == null)
							return;
						evilArr=wordEvilVo.role_world_pkpoint_ranks;
						if (evilArr.length != 0) {
							worldEvilView.changeData(evilArr);
						}
					} else { //国家恶人榜
						var stateEvilVo:m_ranking_role_pkpoint_rank_toc=data as m_ranking_role_pkpoint_rank_toc;
						if (stateEvilVo == null)
							return;
						evilArr=stateEvilVo.role_pkpoint_ranks;
						if (evilArr.length != 0) {
							stateEvilView.changeData(evilArr);
						}
					}

					break;
				case 5: //护国英雄榜
					if (data is m_ranking_role_gongxun_rank_toc) {
						heroIndex=heroTabNavigation.selectedIndex;
						if (heroTabNavigation.selectedIndex == 0) {
							var totalHeroVo:m_ranking_role_gongxun_rank_toc=data as m_ranking_role_gongxun_rank_toc;
							if (totalHeroVo == null)
								return;
							heroArr=totalHeroVo.role_gongxun_ranks;
							if (heroArr.length != 0) {
								heroArr.sortOn("ranking", Array.NUMERIC);
								totalHeroRankView.changeData(heroArr);
							}
						}
					} else if (data is m_ranking_role_yesterday_gongxun_rank_toc) {
						heroIndex=heroTabNavigation.selectedIndex;
						if (heroTabNavigation.selectedIndex == 1) {
							var yestodayHeroVo:m_ranking_role_yesterday_gongxun_rank_toc=data as m_ranking_role_yesterday_gongxun_rank_toc;
							if (yestodayHeroVo == null) {
								return;
							}
							heroArr=yestodayHeroVo.role_gongxun_ranks;
							if (heroArr.length != 0) {
								heroArr.sortOn("ranking", Array.NUMERIC);
								yestodayHeroRankView.changeData(heroArr);
							}
						}
					} else if (data is m_ranking_role_today_gongxun_rank_toc) {
						heroIndex=heroTabNavigation.selectedIndex;
						if (heroTabNavigation.selectedIndex == 2) {
							var todayHeroVo:m_ranking_role_today_gongxun_rank_toc=data as m_ranking_role_today_gongxun_rank_toc;
							if (todayHeroVo == null) {
								todayHeroRankView.setNull();
								return;
							}
							heroArr=todayHeroVo.role_gongxun_ranks;
							if (heroArr.length != 0) {
								heroArr.sortOn("ranking", Array.NUMERIC);
								todayHeroRankView.changeData(heroArr);
							}
						}
					} else {
						var playerVo4:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo4 == null)
							return;
						if (playerVo4.is_self == false) {
							if (playerVo4.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo4.role_all_ranks, playerVo4.role_name, playerVo4.level, playerVo4.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}
					break;
				case 6: //我的排行(玩家排行)
					var vo:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
					if (vo == null)
						return;
					myselfArr=vo.role_all_ranks;
					preToggleButton.selected=false;
					preToggleButton=myselfRankBtn;
					preToggleButton.selected=true;
					if (vo.is_self) {
						if (myselfArr.length != 0) {
							var arr:Array=[];
							myselfArr.sortOn("ranking", Array.NUMERIC);
							for (var i:int=0; i < myselfArr.length; i++) {
								var obj:Object={};
								obj.number=i + 1;
								obj.key_name=myselfArr[i].key_name;
								obj.key_value=myselfArr[i].key_value;
								obj.rank_name=myselfArr[i].rank_name;
								obj.ranking=myselfArr[i].ranking;
								arr.push(obj);
							}
							myGrid.dataProvider=arr;
							if (myselfArr.length + 1 < 12) {
								myGrid.pageCount=myselfArr.length + 1;
							} else {
								myGrid.pageCount=12;
							}
							myGrid.invalidateDisplayList();
						}
					}
					break;
				case 7: //鲜花排行榜
					if (data is m_ranking_role_rece_flowers_rank_toc) {
						var flowerVo:m_ranking_role_rece_flowers_rank_toc=data as m_ranking_role_rece_flowers_rank_toc;
						if (flowerVo == null)
							return;
						flowerArr=flowerVo.role_rece_flowers;
						if (flowerArr.length != 0) {
							flowerArr.sortOn("ranking", Array.NUMERIC);
							hundredFlowerRankView.changeData(flowerArr);
						}
					} else if (data is m_ranking_role_rece_flowers_yesterday_rank_toc) {
						var yestodayFlowerVo:m_ranking_role_rece_flowers_yesterday_rank_toc=data as m_ranking_role_rece_flowers_yesterday_rank_toc;
						if (yestodayFlowerVo == null)
							return;
						flowerArr=yestodayFlowerVo.role_rece_flowers;
						if (flowerArr.length != 0) {
							flowerArr.sortOn("ranking", Array.NUMERIC);
							yestodayFlowerRankView.changeData(flowerArr);
						}
					} else if (data is m_ranking_role_rece_flowers_today_rank_toc) {
						var todayflowerVo:m_ranking_role_rece_flowers_today_rank_toc=data as m_ranking_role_rece_flowers_today_rank_toc;
						if (todayflowerVo == null) {
							todayFlowerRankView.setNull();
							return;
						}
						flowerArr=todayflowerVo.role_rece_flowers;
						if (flowerArr.length != 0) {
							flowerArr.sortOn("ranking", Array.NUMERIC);
							todayFlowerRankView.changeData(flowerArr);
						}
					} else if (data is m_ranking_role_rece_flowers_last_week_rank_toc) { //上周鲜花排行榜
						var lastflowerVo:m_ranking_role_rece_flowers_last_week_rank_toc=data as m_ranking_role_rece_flowers_last_week_rank_toc;
						if (lastflowerVo == null) {
							lastWeekFlowerRankView.setNull();
							return;
						}
						flowerArr=lastflowerVo.role_rece_flowers;
						flowerArr.sortOn("ranking", Array.NUMERIC);
						if (flowerArr.length != 0) {
							lastWeekFlowerRankView.changeData(flowerArr);
						}
					} else {
						var playerVo5:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo5 == null)
							return;
						if (playerVo5.is_self == false) {
							if (playerVo5.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo5.role_all_ranks, playerVo5.role_name, playerVo5.level, playerVo5.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}
					break;
				case 8: //送花排行榜
					if (data is m_ranking_role_give_flowers_rank_toc) {
						var giveFlowerVo:m_ranking_role_give_flowers_rank_toc=data as m_ranking_role_give_flowers_rank_toc;
						if (giveFlowerVo == null)
							return;
						giveFlowerArr=giveFlowerVo.role_give_flowers;
						if (giveFlowerArr.length != 0) {
							giveFlowerArr.sortOn("ranking", Array.NUMERIC);
							giveFlowerRankView.changeData(giveFlowerArr);
						}
					} else if (data is m_ranking_role_give_flowers_yesterday_rank_toc) {
						var yestodayGiveFlowerVo:m_ranking_role_give_flowers_yesterday_rank_toc=data as m_ranking_role_give_flowers_yesterday_rank_toc;
						if (yestodayGiveFlowerVo == null)
							return;
						giveFlowerArr=yestodayGiveFlowerVo.role_give_flowers;
						if (giveFlowerArr.length != 0) {
							giveFlowerArr.sortOn("ranking", Array.NUMERIC);
							yestodayGiveFlowerRankView.changeData(giveFlowerArr);
						}
					} else if (data is m_ranking_role_give_flowers_today_rank_toc) {
						var todayGiveflowerVo:m_ranking_role_give_flowers_today_rank_toc=data as m_ranking_role_give_flowers_today_rank_toc;
						if (todayGiveflowerVo == null) {
							todayGiveFlowerRankView.setNull();
							return;
						}
						giveFlowerArr=todayGiveflowerVo.role_give_flowers;
						if (giveFlowerArr.length != 0) {
							giveFlowerArr.sortOn("ranking", Array.NUMERIC);
							todayGiveFlowerRankView.changeData(giveFlowerArr);
						}
					} else if (data is m_ranking_role_give_flowers_last_week_rank_toc) { //上周送花榜
						var lastWeekGiveflowerVo:m_ranking_role_give_flowers_last_week_rank_toc=data as m_ranking_role_give_flowers_last_week_rank_toc;
						if (lastWeekGiveflowerVo == null) {
							lastWeekGiveFlowerRankView.setNull();
							return;
						}
						giveFlowerArr=lastWeekGiveflowerVo.role_give_flowers;
						if (giveFlowerArr.length != 0) {
							giveFlowerArr.sortOn("ranking", Array.NUMERIC);
							lastWeekGiveFlowerRankView.changeData(giveFlowerArr);
						}
					} else {
						var playerVo6:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo6 == null)
							return;
						if (playerVo6.is_self == false) {
							if (playerVo6.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo6.role_all_ranks, playerVo6.role_name, playerVo6.level, playerVo6.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}
					break;
				case 9: //宠物排行榜


					selectIndex=petTabNavigation.selectedIndex;
					if (data is m_ranking_pet_join_rank_toc) {
						var petJoinVo:m_ranking_pet_join_rank_toc=data as m_ranking_pet_join_rank_toc;
						if (petJoinVo == null)
							return;
						if (petJoinVo.succ) {
							if (petTabNavigation.selectedIndex == 0) {
								RankModule.getInstance().requestLevelRankData(petId);
								selectIndex=0;
							}
						} else {
							Tips.getInstance().addTipsMsg(petJoinVo.reason);
						}
					} else if (data is m_ranking_role_pet_rank_toc) {
						if (petTabNavigation.selectedIndex == 0) {
							var petVo:m_ranking_role_pet_rank_toc=data as m_ranking_role_pet_rank_toc;
							if (petVo == null)
								return;
							petArr=petVo.pets;
							if (petArr.length != 0) {
								petArr.sortOn("ranking", Array.NUMERIC);
								petTotalRankView.changeData(petArr);
							}
						}
					} else if (data is m_ranking_role_all_rank_toc) {
						var playerVo9:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo9 == null)
							return;
						if (playerVo9.is_self == false) {
							if (playerVo9.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo9.role_all_ranks, playerVo9.role_name, playerVo9.level, playerVo9.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}

					break;
				// 大明英雄榜
				case 10:
					selectIndex = heroFbTab.selectedIndex;
					if (data is m_ranking_hero_fb_rank_toc) {
						if (heroFbTab.selectedIndex == 0) {
							var heroFBVo:m_ranking_hero_fb_rank_toc = data as m_ranking_hero_fb_rank_toc;
							if (!heroFBVo)
								return;
							heroFBArr = heroFBVo.hero_fb_ranks;
							if (heroFBArr.length != 0) {
								for (var ri:int=0; ri < heroFBArr.length; ri ++)
									p_hero_fb_rank(heroFBArr[ri]).ranking = ri + 1;
								heroFBRankView.changeData(heroFBArr);
							}
						}
					} else if (data is m_ranking_role_all_rank_toc) {
						var playerVo10:m_ranking_role_all_rank_toc=data as m_ranking_role_all_rank_toc;
						if (playerVo10 == null)
							return;
						if (playerVo10.is_self == false) {
							if (playerVo10.role_all_ranks.length != 0) {
								WindowManager.getInstance().popUpWindow(PlayerRankView.getInstance());
								PlayerRankView.getInstance().changeData(playerVo10.role_all_ranks, playerVo10.role_name, playerVo10.level, playerVo10.family_name);
								return;
							}
						} else {
							clear();
							myselfRank();
							RankModule.getInstance().requestPlayerRankData(GlobalObjectManager.getInstance().user.base.role_id);
							selectBtnIndex=6;
						}
					}
					break;
			}
		}

		//为了防止玩家狂点
		private var iii:int;

		private function casheData():void {
			//  trace("============================================================================================="+iii);
			switch (selectBtnIndex) {
				case 1:
					levelIndex=levelTabNavigation.selectedIndex;
					if (levelTabNavigation.selectedIndex == 0) {
						if (levelArr.length != 0) {
							soldierRankView.changeData(levelArr);
						}
					} else if (levelTabNavigation.selectedIndex == 1) {
						if (levelArr.length != 0) {
							shooterRankView.changeData(levelArr);
						}
					} else if (levelTabNavigation.selectedIndex == 2) {
						if (levelArr.length != 0) {
							travelerRankView.changeData(levelArr);
						}
					} else if (levelTabNavigation.selectedIndex == 3) {
						if (levelArr.length != 0) {
							doctorRankView.changeData(levelArr);
						}
					}
					break;
				case 2:
					if (familyTabNavigation.selectedIndex == 0) {
						if (familyArr.length != 0) {
							familyFlourishView.changeData(familyArr);
						}
					} else {
						if (familyArr.length != 0) {
							graceRankView.changeData(familyArr);
						}
					}
					break;
				case 3:
					selectIndex=equipTabNavigation.selectedIndex;
					if (equipTabNavigation.selectedIndex == 0) {
						totalRankView.changeData(equipArr);
					} else if (equipTabNavigation.selectedIndex == 1) {
						refineRankView.changeData(equipArr);
					} else if (equipTabNavigation.selectedIndex == 2) {
						insertRankView.changeData(equipArr);
					}
					break;
				case 4:
					evilIndex=EvilTabNavgation.selectedIndex;
					if (EvilTabNavgation.selectedIndex == 0) { //世界恶人榜
						if (evilArr.length != 0) {
							worldEvilView.changeData(evilArr);
						}
					} else { //国家恶人榜
						if (evilArr.length != 0) {
							stateEvilView.changeData(evilArr);
						}
					}
					break;
				case 5:
					heroIndex=heroTabNavigation.selectedIndex;
					if (heroTabNavigation.selectedIndex == 0) {
						if (heroArr.length != 0) {
							totalHeroRankView.changeData(heroArr);
						}
					} else if (heroTabNavigation.selectedIndex == 1) {
						if (heroArr.length != 0) {
							yestodayHeroRankView.changeData(heroArr);
						}
					} else if (heroTabNavigation.selectedIndex == 2) {
						if (heroArr.length != 0) {
							todayHeroRankView.changeData(heroArr);
						}
					}
					break;
				case 6:
					if (myselfArr.length != 0) {
						var arr:Array=[];
						myselfArr.sortOn("ranking", Array.NUMERIC);
						for (var i:int=0; i < myselfArr.length; i++) {
							var obj:Object={};
							obj.number=i + 1;
							obj.key_name=myselfArr[i].key_name;
							obj.key_value=myselfArr[i].key_value;
							obj.rank_name=myselfArr[i].rank_name;
							obj.ranking=myselfArr[i].ranking;
							arr.push(obj);
						}
						if (myselfArr.length + 1 < 11) {
							myGrid.pageCount=myselfArr.length + 1;
						} else {
							myGrid.pageCount=11;
						}
						myGrid.dataProvider=arr;
						myGrid.invalidateDisplayList();
					}
					break;
				case 7:
					flowerIndex=flowerTabNavigation.selectedIndex;
					if (flowerTabNavigation.selectedIndex == 0) { //今日
						if (flowerArr.length != 0) {
							hundredFlowerRankView.changeData(flowerArr);
						}
					} else if (flowerTabNavigation.selectedIndex == 1) { //昨日
						if (flowerArr.length != 0) {
							yestodayFlowerRankView.changeData(flowerArr);
						}
					} else if (flowerTabNavigation.selectedIndex == 2) {
						if (flowerArr.length != 0) {
							lastWeekFlowerRankView.changeData(flowerArr);
						}
					} else if (flowerTabNavigation.selectedIndex == 3) { //百花谱
						if (flowerArr.length != 0) {
							todayFlowerRankView.changeData(flowerArr);
						}
					}
					break;
				case 8:
					giveFlowerIndex=giveFlowerTabNavigation.selectedIndex;
					if (giveFlowerTabNavigation.selectedIndex == 0) {
						if (giveFlowerArr.length != 0) {
							todayGiveFlowerRankView.changeData(giveFlowerArr);
						}
					} else if (giveFlowerTabNavigation.selectedIndex == 1) {
						if (giveFlowerArr.length != 0) {
							yestodayGiveFlowerRankView.changeData(giveFlowerArr);
						}
					} else if (giveFlowerTabNavigation.selectedIndex == 2) {
						if (giveFlowerArr.length != 0) {
							lastWeekGiveFlowerRankView.changeData(giveFlowerArr);
						}
					} else if (giveFlowerTabNavigation.selectedIndex == 3) { //送谱
						if (giveFlowerArr.length != 0) {
							giveFlowerRankView.changeData(giveFlowerArr);
						}
					}
					break;
				case 9:
					petIndex=petTabNavigation.selectedIndex;
					if (petTabNavigation.selectedIndex == 0) {
						if (petArr.length != 0) {
							petTotalRankView.changeData(petArr);
						}
					}
					break;
				case 10:
					heroFBIndex = heroFbTab.selectedIndex;
					if (heroFbTab.selectedIndex == 0) {
						if (heroFBArr.length != 0) {
							heroFBRankView.changeData(heroFBArr);
						}
					}
			}
		}

	}
}