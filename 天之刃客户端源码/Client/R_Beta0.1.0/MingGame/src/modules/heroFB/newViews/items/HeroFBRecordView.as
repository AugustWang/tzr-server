package modules.heroFB.newViews.items {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.heroFB.HeroFBDataManager;
	import modules.heroFB.HeroFBModule;
	import modules.heroFB.newViews.items.StarItem;
	import modules.rank.RankModule;
	
	import proto.common.p_hero_fb_barrier;
	import proto.line.m_hero_fb_report_toc;

	public class HeroFBRecordView extends BasePanel {
		private var _title:TextField;
		private var firstName:TextField;
		private var firstPoint:TextField;
		private var firstStar:StarItem;
		private var repeatBtn:Button;
		private var nextBtn:Button;
		private var backToMenuBtn:Button;
		private var descTF:TextField;
		private var pointTF:TextField;
		private var starTF:TextField;
		private var star:StarItem;
		private var annalImg:Bitmap;

		public function HeroFBRecordView() {
			super();
			initView();
		}

		private function initView():void {
			this.width=334;
			this.height=302;
			addContentBG(8, 8, 0);
			this.x=(GlobalObjectManager.GAME_WIDTH - this.width) / 2;
			this.y=(GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			title="第99关";

			firstName=ComponentUtil.createTextField("本关霸主：我是流氓我怕谁", 18, 8, null, 200, 25, this);
			firstPoint=ComponentUtil.createTextField("得    分：89000000", 18, 24, null, 350, 20, this);
			var xinTF:TextField=ComponentUtil.createTextField("星    级：", 18, 40, null, 100, 25, this);
			firstStar=new StarItem();
			firstStar.x=xinTF.x + 65;
			firstStar.y=xinTF.y - 12;
			addChild(firstStar);

			var bg:UIComponent=ComponentUtil.createUIComponent(15, 58, 304, 160);
			Style.setBorderSkin(bg);
			addChild(bg);

			descTF=ComponentUtil.createTextField("", 24, 32, null, 380, 250, bg);
			pointTF=ComponentUtil.createTextField("", 24, 74, null, 280, 200, bg);
			starTF=ComponentUtil.createTextField("", 24, 105, null, 280, 30, bg);
			star=new StarItem();
			star.x=starTF.x + 60;
			star.y=starTF.y - 12;
			bg.addChild(star);

			annalImg=Style.getBitmap(GameConfig.HERO_FB, "xinjilu");
			annalImg.y=50;
			annalImg.x=205;
			annalImg.visible=true;
			addChild(annalImg);

			repeatBtn=ComponentUtil.createButton("重复本关", 32, 222, 70, 25, this);
			repeatBtn.addEventListener(MouseEvent.CLICK, onRepeateBtnClickHandler);
			nextBtn=ComponentUtil.createButton("进入下关", 132, 222, 70, 25, this);
			nextBtn.addEventListener(MouseEvent.CLICK, onNextBtnClickHandler);
			backToMenuBtn=ComponentUtil.createButton("返回界面", 236, 222, 70, 25, this);
			backToMenuBtn.addEventListener(MouseEvent.CLICK, onBackToMenuBtnClickHandler);
		}

		public function setData(vo:m_hero_fb_report_toc):void {
			var barrierInfo:XML=HeroFBDataManager.getInstance().getBarrierInfo(vo.barrier_id);
			title=barrierInfo.@barrierStr;
			firstName.htmlText=HtmlUtil.font("本关霸主：", "#89EFF4") + HtmlUtil.font(String(vo.first_record.role_name), "#FFFF00");
			firstPoint.htmlText=HtmlUtil.font("得分：", "#89EFF4") + HtmlUtil.font(String(vo.first_record.score), "#FFFF00");
			firstStar.update(vo.first_record.star_level, 5);
			annalImg.visible=false;
			if (vo.state == 0) {
				descTF.htmlText=HtmlUtil.fontBr("挑战失败！", "#fffd4b", 16) + HtmlUtil.fontBr("请继续加油哦！", "#fffd4b", 16);
				nextBtn.visible=false;
				pointTF.htmlText="";
				starTF.htmlText="";
				star.visible=false;
			} else if (vo.state == 1) {
				descTF.htmlText=HtmlUtil.fontBr("恭喜过关！", "#fffd4b", 16);
				nextBtn.visible=true;
				pointTF.htmlText=HtmlUtil.font(HtmlUtil.font("本次得分：", "#89EFF4", 14) + vo.fb_record.score, "#FFFF00", 14);
				starTF.htmlText=HtmlUtil.font("星级评分：", "#89EFF4", 14);
				star.update(vo.fb_record.star_level, 5);
				star.visible=true;
			} else {
				descTF.htmlText=HtmlUtil.fontBr("打破记录！", "#fffd4b", 16);
				nextBtn.visible=true;
				pointTF.htmlText=HtmlUtil.font(HtmlUtil.font("本次得分：", "#89EFF4", 14) + vo.fb_record.score, "#FFFF00", 14);
				starTF.htmlText=HtmlUtil.font("星级评分：", "#89EFF4", 14);
				star.update(vo.fb_record.star_level, 5);
				star.visible=true;
				annalImg.visible=true;
			}
			var oldInfo:p_hero_fb_barrier=HeroFBDataManager.getInstance().getBarrierStateById(vo.barrier_id);
			var info:p_hero_fb_barrier=new p_hero_fb_barrier();
			info.barrier_id=vo.barrier_id;
			info.score=vo.fb_record.score;
			info.star_level=vo.fb_record.star_level;
			info.time_used=vo.fb_record.time_used;
			if (oldInfo) {
				if (oldInfo.score <= vo.fb_record.score) {
					HeroFBDataManager.getInstance().setBarrierState(info);
				}
			} else {
				HeroFBDataManager.getInstance().setBarrierState(info);
			}
		}

		private function onRepeateBtnClickHandler():void {
			HeroFBModule.getInstance().repeatBarrier();
			close();
		}

		private function onNextBtnClickHandler(event:MouseEvent):void {
			HeroFBModule.getInstance().enterNextBarrier();
			close();
		}

		private function onBackToMenuBtnClickHandler(event:MouseEvent):void {
			HeroFBModule.getInstance().heroFBQuit(0);
			close();
		}

		public function close():void {
			if (this.isPopUp) {
				WindowManager.getInstance().removeWindow(this);
			}
		}
	}
}