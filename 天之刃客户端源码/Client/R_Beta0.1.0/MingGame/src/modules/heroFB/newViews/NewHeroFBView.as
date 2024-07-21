package modules.heroFB.newViews {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.LayerManager;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.utils.ScaleShape;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.help.InfoView;
	import modules.heroFB.HeroFBDataManager;
	import modules.heroFB.HeroFBModule;
	import modules.heroFB.newViews.items.HeroFBBarrierItem;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.common.p_role_hero_fb_info;

	public class NewHeroFBView extends Sprite {
		private var rewardBtn:ToggleButton;
		private var panel:BasePanel;
		private var source:SourceLoader;
		private var bg:Bitmap;
		private var panelBg:UIComponent;
		private var mapBg:Image;
		private var fbTitle:TextField;
		private var enterCount:TextField;
		private var lastChapBtn:Button;
		private var nextChapBtn:Button;
		private var closeBtn:Button;
		private var barrier:Sprite;
		private var progressBarrier:int;
		private var progressChapter:int;
		private var buyBtn:Button;

		public function NewHeroFBView(s:SourceLoader) {
			super();
			source=s;
			initView();
		}

		private function initView():void {
			var bgData:BitmapData=source.getBitmapData("hero_fb_bg");
			bg=new Bitmap(bgData);
			bg.width=GlobalObjectManager.GAME_WIDTH;
			bg.height=GlobalObjectManager.GAME_HEIGHT;
			addChild(bg);
			
			panel=new BasePanel();
			panel.width = 590;
			panel.height = 430;
			panel.addEventListener(CloseEvent.CLOSE,closeHandler)
			addChild(panel);
			
			var contentBg:ScaleShape = new ScaleShape(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"panelContentBg"));
			contentBg.setScale9Grid(new Rectangle(10,10,177,139));
			contentBg.width = 570;
			contentBg.height = 368;
			contentBg.x=10;
			contentBg.y=13;
			panel.addChild(contentBg);

			panelBg=ComponentUtil.createUIComponent(0, 15, 430, 318);
			Style.setBorderSkin(panelBg);
			panelBg.x = (panel.width-panelBg.width)>>1;
			panelBg.y = 28;
			panel.addChild(panelBg);

			mapBg=new Image();
			mapBg.x=mapBg.y=10;
			panelBg.addChild(mapBg);

			barrier=new Sprite();
			barrier.x=32;
			barrier.y=70;
			panelBg.addChild(barrier);

//			closeBtn=new UIComponent();
//			closeBtn.addEventListener(MouseEvent.CLICK, closeBtnClickHandler);
//			closeBtn.width=11;
//			closeBtn.height=12;
//			closeBtn.x=532;
//			closeBtn.y=10;
//			closeBtn.bgAlpha=1;
//			closeBtn.bgColor=0xff00ff;
//			closeBtn.bgSkin=Style.getButtonSkin("close_1skin", "close_2skin", "close_3skin", "", GameConfig.T1_UI);
//			closeBtn.buttonMode=true;
//			closeBtn.useHandCursor=true;
//			panelBg.addChild(closeBtn);

			rewardBtn=new ToggleButton;
			rewardBtn=createToggleBtn(225, 120, 89, 97, "lingjiang", "lingjiang_over", "lingjiang", "lingjiang_down");
			rewardBtn.visible=false;
			panelBg.addChild(rewardBtn);
			rewardBtn.addEventListener(MouseEvent.CLICK, clickRewardBtnHandler);

			fbTitle=ComponentUtil.createTextField("", 0, -20, Style.centerTextFormat, 590, 100, panel);
			fbTitle.filters = Style.textBlackFilter;

			enterCount=ComponentUtil.createTextField("", 0, panelBg.height+panelBg.y+4, Style.rightTextFormat, panel.width - 160, 25, panel);
			enterCount.filters=Style.textBlackFilter;
			enterCount.mouseEnabled=true;
			
			buyBtn = ComponentUtil.createButton("购买",panel.width - 145,panelBg.height+panelBg.y+4,65,25,panel);
			Style.setYellowButtonStyle(buyBtn);
			buyBtn.addEventListener(MouseEvent.CLICK,onClickBuyHandler);
			
			closeBtn = ComponentUtil.createButton("退出",buyBtn.x+buyBtn.width+5,buyBtn.y,65,25,panel);
			closeBtn.addEventListener(MouseEvent.CLICK,onCloseClickHandler);

			lastChapBtn=ComponentUtil.createButton("", -59, (panelBg.height - 59) >> 1, 59, 59, panelBg);
			lastChapBtn.addEventListener(MouseEvent.CLICK, onLastChapBtnClickHandler);
			lastChapBtn.bgSkin = Style.getButtonSkin("leftBtn_1","leftBtn_2","leftBtn_3","leftBtn_3",GameConfig.HERO_FB);
			nextChapBtn=ComponentUtil.createButton("", panelBg.width, (panelBg.height - 59) >> 1, 59, 59, panelBg);
			nextChapBtn.addEventListener(MouseEvent.CLICK, onNextChapBtnClickHandler);
			nextChapBtn.bgSkin = Style.getButtonSkin("rightBtn_1","rightBtn_2","rightBtn_3","leftBtn_3",GameConfig.HERO_FB);

			stageResizeHandler();
		}

		/**
		 * 隐藏奖励按钮
		 */

		public function hideeRewardBtn():void {
			rewardBtn.visible=false;
		}

		/**
		 * 点击领取奖励
		 */

		private function clickRewardBtnHandler(e:Event):void {
			HeroFBModule.getInstance().getRewardRequest(currentChapter);
		}

		/**
		 * 隐藏掉落物tooltip
		 */

		private function hideDropGoodsTip(e:Event):void {
			ToolTipManager.getInstance().hide();
		}

		/**
		 * 显示掉落物tooltip
		 */

		private function showDropGoodsTip(e:Event):void {
			var target:GoodsImage=e.target as GoodsImage;
			ToolTipManager.getInstance().show(BaseItemVO(target.data), 0, 0, 0, "targetToolTip");
		}

		/**
		 * 自适应
		 */
		public function stageResizeHandler():void {
			bg.width=GlobalObjectManager.GAME_WIDTH;
			bg.height=GlobalObjectManager.GAME_HEIGHT;

			panel.x=(GlobalObjectManager.GAME_WIDTH - panel.width) / 2 - 20;
			panel.y=(GlobalObjectManager.GAME_HEIGHT - 40 - panel.height) >> 1;
//			
//			_desc.x = (GlobalObjectManager.GAME_WIDTH - _desc.width) / 2;
//			_desc.y = _panel.y + _panel.height + 5;
		}

		/**
		 * 数据
		 */
		private var info:p_role_hero_fb_info;

		public function setData(vo:p_role_hero_fb_info):void {
			HeroFBDataManager.getInstance().getHeroFBMapIdList();
			info=vo;
			progressBarrier=vo.progress;
			progressChapter=vo.progress / 100;
			HeroFBDataManager.getInstance().setBarriers(vo.fb_record);
			if (currentBarrier <= 0) {
				var max:int=HeroFBDataManager.getInstance().getChapterNum();
				if (progressChapter >= max)
					progressChapter=max;
				currentChapter=progressChapter;
			} else {
				currentChapter=currentChapter;
			}
			setEnterTime(vo.today_count, vo.max_enter_times);
		}

		private var _currentChapter:int;

		public function set currentChapter(chapId:int):void {
			//移除上一章的信息

			var chapInfo:XML=HeroFBDataManager.getInstance().getChapterInfo(chapId);
			var barrierAry:Array=String(chapInfo.@barrier).split("#");
			//重组按钮
			while (barrier.numChildren > 0) {
				barrier.removeChildAt(0);
			}
			for (var i:int=0; i < barrierAry.length; i++) {
				var item:HeroFBBarrierItem=new HeroFBBarrierItem();
				item.initView();
				item.data=HeroFBDataManager.getInstance().getBarrierInfo(barrierAry[i]);
				item.enable=getBarrierEnable(chapId, barrierAry[i]);
				barrier.addChild(item);
			}
			LayoutUtil.layoutGrid(barrier, 5, 5, 30);
			updateBarrierBtn(barrierAry);
			//样式变化
			if (currentChapter == chapId) {
				return;
			}
			//mapBg.source=GameConfig.ROOT_URL + chapInfo.@mapUrl;
			fbTitle.htmlText=HtmlUtil.font(chapInfo.@name, "#fffd4b", 14);
			// 本章是否有奖励
			if (info.rewards.indexOf(chapId) >= 0) {
				rewardBtn.visible=true;
				panelBg.addChild(rewardBtn);
				rewardBtn.x = panelBg.x + 225;
				rewardBtn.y = panelBg.y + 120;
			} else {
				rewardBtn.visible=false;
			}

			if (chapId == 1) {
				lastChapBtn.visible=false;
			} else {
				lastChapBtn.visible=true;
			}
			if (chapId == HeroFBDataManager.getInstance().getChapterNum()) {
				nextChapBtn.visible=false;
			} else {
				nextChapBtn.visible=true;
			}
			_currentChapter=chapId;
		}

		private var _currentBarrier:int;
		public function set currentBarrier(barrId:int):void {
		}

		public function get currentBarrier():int {
			return _currentBarrier;
		}

		public function get currentChapter():int {
			return _currentChapter;
		}

		public function getBarrierEnable(chapId:int, barrId:int):Boolean {
			if (chapId <= progressChapter) {
				if (barrId <= progressBarrier) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}

		public function updateBarrierBtn(array:Array):void {

		}

		private function closeBtnClickHandler(event:MouseEvent):void {
			HeroFBModule.getInstance().closeHeroFBPanel();
		}

		/**
		 * 关闭处理
		 */
		public function closeHandler(event:CloseEvent=null):void {
			HeroFBModule.getInstance().closeHeroFBPanel();
		}

		private function onLastChapBtnClickHandler(event:MouseEvent):void {
			currentChapter=currentChapter - 1;
		}

		private function onNextChapBtnClickHandler(event:MouseEvent):void {
			currentChapter=currentChapter + 1;
		}

		/**
		 * 更新参加次数
		 */
		public function setEnterTime(todayCount:int, maxTimes:int):void {
			enterCount.htmlText=HtmlUtil.font("剩余挑战次数：", "#8FE1E0",14)+HtmlUtil.font(todayCount + "/" + maxTimes,"#F3EF53",14);
		}

		private function onClickBuyHandler(event:MouseEvent=null):void {
			HeroFBModule.getInstance().requestBuyEnterTime();
		}
		
		private function onCloseClickHandler(event:MouseEvent=null):void{
			closeHandler();
		}

		private function createToggleBtn(x:int, y:int, width:int, height:int, normal:String, over:String, disable:String, down:String=null, select:String=null):ToggleButton {
			var btn:ToggleButton=new ToggleButton;
			btn.x=x;
			btn.y=y;
			btn.width=width;
			btn.height=height;

			var skin:ButtonSkin=new ButtonSkin;
			skin.skin=source.getBitmapData(normal);
			skin.overSkin=source.getBitmapData(over);
			skin.disableSkin=source.getBitmapData(disable);
			if (down)
				skin.downSkin=source.getBitmapData(down);
			if (select)
				skin.selectedSkin=source.getBitmapData(select);

			btn.bgSkin=skin;

			return btn;
		}
	}
}