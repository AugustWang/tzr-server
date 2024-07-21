package modules.heroFB.views
{
	import com.common.Constant;
	import com.common.GlobalObjectManager;
	import com.common.effect.ArrowEffect;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.ming.events.CloseEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.skins.ButtonSkin;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.sampler.getInvocationCount;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.broadcast.views.Tips;
	import modules.heroFB.HeroFBDataManager;
	import modules.heroFB.HeroFBModule;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.smallMap.view.items.CurrentCityView;
	
	import proto.common.p_role_hero_fb_info;
	
	public class HeroFBView extends Sprite
	{
		private var _source:SourceLoader;
		private var _bg:Bitmap;
		private var _panel:Sprite;
		private var _desc:Sprite;
		private var _mapBg:Image;
		private var _currentChapter:int;
		private var _nextChapTxt:TextField;
		private var _lastChapTxt:TextField;
		private var _nextChapBtn:ToggleButton;
		private var _lastChapBtn:ToggleButton;
		private var _attackBtn:ToggleButton;
		private var _reportBtn:ToggleButton;
		private var _currentBarrier:int;
		private var _heroFBInfo:p_role_hero_fb_info;
		private var _fbDesc:TextField;
		private var _dropDesc:TextField;
		private var _bossHeadIcon:Image;
		private var _dropImage:GoodsImage;
		private var _todayCount:TextField;
		private var _title:TextField;
		private var _rewardBtn:ToggleButton;
		private var _arrow:ArrowEffect;
		
		public function HeroFBView(s:SourceLoader)
		{
			super();
			
			_source = s;
			initView();
		}
		
		private function initView():void
		{
			var bgData:BitmapData = _source.getBitmapData("hero_fb_bg");
			_bg = new Bitmap(bgData);
			_bg.width = GlobalObjectManager.GAME_WIDTH;
			_bg.height = GlobalObjectManager.GAME_HEIGHT;
			addChild(_bg);
			
			_panel = _source.getMovieClip("hero_fb_panel");
			_panel.x = (GlobalObjectManager.GAME_WIDTH - _panel.width) / 2 - 20;
			addChild(_panel);
			
			_mapBg = new Image;
			_mapBg.x = 75;
			_mapBg.y = 8;
			_panel.addChild(_mapBg);
			
			var tf:TextFormat = new TextFormat;
			tf.size = 17;
			tf.bold = true;
			tf.align = TextAlign.CENTER;
			
			_title = ComponentUtil.createTextField("", 13, 77, tf, 20, 219, _panel);
			_title.filters = [new GlowFilter(0xFFFFFF)];
			_title.wordWrap = true;
			
			_desc = _source.getMovieClip("hero_fb_desc");
			_desc.x = (GlobalObjectManager.GAME_WIDTH - _desc.width) / 2;
			addChild(_desc);
			
			_panel.y = (GlobalObjectManager.GAME_HEIGHT - 40 - (_panel.height + _desc.height + 5)) / 2;
			_desc.y = _panel.y + _panel.height + 5;
			
			// 关卡描述
			_fbDesc = ComponentUtil.createTextField("", 80, 10, null, 250, 50, _desc);
			_fbDesc.selectable = true;
			_fbDesc.wordWrap = true;
			_fbDesc.multiline = true;
			// 掉落描述
			_dropDesc = ComponentUtil.createTextField("", 135, 82, null, 200, 40, _desc);
			_dropDesc.wordWrap = true;
			_dropDesc.multiline = true;
			// 军令
			_todayCount = ComponentUtil.createTextField("", 339, 10, null, 150, 20, _desc);
			_todayCount.addEventListener(TextEvent.LINK, clickBuyHandler);
			_todayCount.mouseEnabled = true;
			ComponentUtil.createTextField("本关获得：", 80, 65, null, 100, 20, _desc);
			
			// 奖励按钮
			_rewardBtn = new ToggleButton;
			_rewardBtn = createToggleBtn(225, 120, 89, 97, "lingjiang", "lingjiang_over", "lingjiang", "lingjiang_down");
			_rewardBtn.visible = false;
			_mapBg.addChild(_rewardBtn);
			_rewardBtn.addEventListener(MouseEvent.CLICK, clickRewardBtnHandler);
			
			_lastChapBtn = createToggleBtn(155, 290, 113, 40, "last_chapter_btn", "last_chapter_btn", "last_chapter_btn");
			_mapBg.addChild(_lastChapBtn);
			_lastChapBtn.addEventListener(MouseEvent.CLICK, lastChapHandler);
			
			_lastChapTxt = ComponentUtil.createTextField("", 17, 9, tf, 90, 25, _lastChapBtn);
			_lastChapTxt.filters = [new GlowFilter(0xFFFFFF)];
			
			_nextChapBtn = createToggleBtn(289, 290, 113, 40, "next_chapter_btn", "next_chapter_btn", "next_chapter_btn");
			_mapBg.addChild(_nextChapBtn);
			_nextChapBtn.addEventListener(MouseEvent.CLICK, nextChapHandler);
			
			_nextChapTxt = ComponentUtil.createTextField("", 0, 9, tf, 90, 25, _nextChapBtn);
			_nextChapTxt.filters = [new GlowFilter(0xFFFFFF)];
			
			var s:Sprite = new Sprite;
			s.x = 331;
			s.y = 38;
			_desc.addChild(s);
			_attackBtn = createToggleBtn(0, 0, 69, 32, "gongji", "gongji_over", "gongji_disable");
			s.addChild(_attackBtn);
			_attackBtn.addEventListener(MouseEvent.CLICK, attackHandler);
			s.addEventListener(MouseEvent.ROLL_OVER, showAttackTip);
			s.addEventListener(MouseEvent.ROLL_OUT, hideAttackTip);
			
			_reportBtn = createToggleBtn(401, 38, 69, 32, "zhanbao", "zhanbao_over", "zhanbao_disable");
			_desc.addChild(_reportBtn);
			_reportBtn.addEventListener(MouseEvent.CLICK, clickReportHandler);
			
			_bossHeadIcon = new Image;
			_bossHeadIcon.x = 14;
			_bossHeadIcon.y = 17;
			_desc.addChild(_bossHeadIcon);
			
			_dropImage = new GoodsImage;
			_dropImage.x = 91;
			_dropImage.y = 84;
			_dropImage.filters = [Style.YELLOW_FILTER];
			_desc.addChild(_dropImage);
			_dropImage.addEventListener(MouseEvent.ROLL_OVER, showDropGoodsTip);
			_dropImage.addEventListener(MouseEvent.ROLL_OUT, hideDropGoodsTip);
			
			var quitBtn:ToggleButton = createToggleBtn(347, 90, 112, 32, "back", "back_over", "back_over");
			_desc.addChild(quitBtn);
			quitBtn.addEventListener(MouseEvent.CLICK, quitBtnHandler);
		}
		
		public function closeHandler():void
		{
			if (_arrow && _arrow.parent) {
				_arrow.stop();
				_arrow.parent.removeChild(_arrow);
			}
		}
		
		private function clickBuyHandler(e:Event):void
		{
			HeroFBModule.getInstance().requestBuyEnterTime();
		}
		
		private function showAttackTip(e:Event):void
		{
			if (!_attackBtn.enabled)
				ToolTipManager.getInstance().show("请先击败前面的关卡，才能攻击本关", 0);
		}
		
		private function hideAttackTip(e:Event):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		/**
		 * 自适应
		 */
		
		public function stageResizeHandler():void
		{
			_bg.width = GlobalObjectManager.GAME_WIDTH;
			_bg.height = GlobalObjectManager.GAME_HEIGHT;
			
			_panel.x = (GlobalObjectManager.GAME_WIDTH - _panel.width) / 2 - 20;
			_panel.y = (GlobalObjectManager.GAME_HEIGHT - 40 - (_panel.height + _desc.height + 5)) / 2;
			
			_desc.x = (GlobalObjectManager.GAME_WIDTH - _desc.width) / 2;
			_desc.y = _panel.y + _panel.height + 5;
		}
		
		/**
		 * 隐藏奖励按钮
		 */
		
		public function hideeRewardBtn():void
		{
			_rewardBtn.visible = false;
		}
		
		/**
		 * 点击领取奖励
		 */
		
		private function clickRewardBtnHandler(e:Event):void
		{
			HeroFBModule.getInstance().getRewardRequest(currentChapter);
		}
		
		/**
		 * 隐藏掉落物tooltip
		 */
		
		private function hideDropGoodsTip(e:Event):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		/**
		 * 显示掉落物tooltip
		 */
		
		private function showDropGoodsTip(e:Event):void
		{
			var target:GoodsImage = e.target as GoodsImage;
			ToolTipManager.getInstance().show(BaseItemVO(target.data), 0, 0, 0, "targetToolTip");
		}
		
		/**
		 * 点击战报
		 */
		
		private function clickReportHandler(e:Event):void
		{
			HeroFBModule.getInstance().requestReportInfo(currentBarrier);
		}
		
		/**
		 * 返回地图
		 */
		
		private function quitBtnHandler(e:Event):void
		{
			HeroFBModule.getInstance().closeHeroFBPanel();
		}
		
		public function setEnterTime(todayCount:int, maxTimes:int):void
		{
			var buyLink:String = "<font color='#39E352'><u><a href='event:buyEnterTime'>购买</a></u></font>";
			_todayCount.htmlText = "挑战次数：" + todayCount + "/" + maxTimes + " " + buyLink;
		}
		
		public function setData(vo:p_role_hero_fb_info):void
		{
			HeroFBDataManager.getInstance().getHeroFBMapIdList();
			_heroFBInfo = vo;
			
			if (currentBarrier <= 0) {
				var pc:int = vo.progress / 10;
				var max:int = HeroFBDataManager.getInstance().getChapterNum();
				if (pc >= max) pc = max;
				currentChapter = pc;
			} else {
				currentChapter = currentChapter;
			}
			
			var buyLink:String = "<font color='#39E352'><u><a href='event:buyEnterTime'>购买</a></u></font>";
			_todayCount.htmlText = "挑战次数：" + vo.today_count + "/" + vo.max_enter_times + " " + buyLink;
		}
		
		/**
		 * 单击挑战
		 */
		
		private function attackHandler(e:Event):void
		{
			if (_arrow && _arrow.parent) {
				_arrow.stop();
				_arrow.parent.removeChild(_arrow);
			}
			HeroFBModule.getInstance().heroFBEnter(_currentBarrier);
		}
		
		/**
		 * 单击下一关
		 */
		
		private function nextChapHandler(e:Event):void
		{
			var ProgressChap:int = _heroFBInfo.progress / 10;
			if (ProgressChap < currentChapter + 1) {
				var str:String = "需要打完第" + currentChapter + "章，才能开通第" + (currentChapter+1) + "章，请英雄继续努力！";
				Alert.show(str, "提示", null, null, "确定", null, null, false);
			}
			else currentChapter = currentChapter + 1;
		}
		
		/**
		 * 单击上一关
		 */
		
		private function lastChapHandler(e:Event):void
		{
			currentChapter = currentChapter - 1;	
		}
		
		/**
		 * 设置当前章节
		 */
		
		public function set currentChapter(chapId:int):void
		{		
			// 移除上一章节的城市按钮
			if (currentChapter > 0) {
				var oldChapId:int = currentChapter;
				var oldChapInfo:XML = HeroFBDataManager.getInstance().getChapterInfo(oldChapId);
				var oldBarrierAry:Array = String(oldChapInfo.@barrier).split("#");
				for (var j:int=0; j < oldBarrierAry.length; j ++) {
					var b:ToggleButton = _mapBg.getChildByName(oldBarrierAry[j]) as ToggleButton;
					if (b)
						_mapBg.removeChild(b);
				}
			}
			// 地图中的城市按钮
			var chapInfo:XML = HeroFBDataManager.getInstance().getChapterInfo(chapId);			
			var barrierAry:Array = String(chapInfo.@barrier).split("#");
			var tf:TextFormat = new TextFormat;
			tf.size = 17;
			tf.bold = true;
			for (var i:int=0; i < barrierAry.length; i ++) {
				var barrierInfo:XML = HeroFBDataManager.getInstance().getBarrierInfo(barrierAry[i]);
				var posAry:Array = String(barrierInfo.@btnPos).split("#");
				var btn:ToggleButton;
				if (int(barrierInfo.@id) < _heroFBInfo.progress) {
					btn = createToggleBtn(posAry[0], posAry[1], 67, 65, "qizi", "qizi_over", "qizi", null, "qizi_over");
				} else if (int(barrierInfo.@id) > _heroFBInfo.progress) {
					break;
				}else {
					btn = createToggleBtn(posAry[0], posAry[1], 67, 65, "cheng", "cheng_over", "cheng_disable", null, "cheng_over");
				}
				if ((int(barrierInfo.@id) == 11 && _heroFBInfo.progress == 11) ||
					(int(barrierInfo.@id == 12) && _heroFBInfo.progress == 12)) {
					if (_arrow && _arrow.parent) {
						_arrow.stop();
						_arrow.parent.removeChild(_arrow);
					}
					_arrow = new ArrowEffect("dianji", ArrowEffect.TOP);
					_arrow.x = 14;
					_arrow.y = -63;
					btn.addChild(_arrow);
					_arrow.start();
				}
				btn.name = barrierInfo.@id;
				btn.addEventListener(MouseEvent.CLICK, barrierHandler);
				_mapBg.addChild(btn);
				// boss名称
				var txt:TextField = ComponentUtil.createTextField(barrierInfo.@barrierStr, 50, 53, tf, 120, 20, btn);	
				txt.filters = [new GlowFilter(0xFFFFFF)];
			}
			// 默认选择一关
			if (currentBarrier <= 0 || currentChapter != chapId) {
				var progressChap:int = int(_heroFBInfo.progress/10);
				if (chapId == progressChap && _heroFBInfo.progress % 10 != 1)
					currentBarrier = _heroFBInfo.progress - 1;
				else
					currentBarrier = chapId * 10 + 1;
			}	
			else
				currentBarrier = currentBarrier;
			// 本章是否有奖励
			if (_heroFBInfo.rewards.indexOf(chapId) >= 0) {
				_rewardBtn.visible = true;
				_mapBg.addChild(_rewardBtn);
			}
			else
				_rewardBtn.visible = false;
			// 当前章节没变动的话不用处理
			if (currentChapter == chapId)
				return;
			// 地图背景
			_mapBg.source = GameConfig.ROOT_URL + chapInfo.@mapUrl;
			// 标题
			_title.text = chapInfo.@name;
			// 第一章上一章按钮不可见，最后一章下一关按钮不可见
			if (chapId == 1)
				_lastChapBtn.visible = false;
			else
				_lastChapBtn.visible = true;
			
			if (chapId == HeroFBDataManager.getInstance().getChapterNum())
				_nextChapBtn.visible = false;
			else
				_nextChapBtn.visible = true;
			
			_lastChapTxt.text = chapInfo.@lastChap;
			_nextChapTxt.text = chapInfo.@nextChap;
			
			_currentChapter = chapId;
		}
		
		/**
		 * 单击城市按钮
		 */
		
		private static var lastClick:int;
		private static const doubleClickWait:int = 300;
		
		private function barrierHandler(e:Event):void
		{	
			var target:ToggleButton = e.currentTarget as ToggleButton;		
			currentBarrier = int(target.name);
			
			if ((currentBarrier == 11 && _heroFBInfo.progress == 11) ||
				(currentBarrier == 12 && _heroFBInfo.progress == 12)) {
				if (_arrow && _arrow.parent) {
					_arrow.stop();
					_arrow.parent.removeChild(_arrow);
				}
				_arrow = new ArrowEffect("dianji2");
				_arrow.x = 78;
				_arrow.y = 15;
				_attackBtn.addChild(_arrow);
				_arrow.start();
			}
			
			var time:int = getTimer();
			if ((time-lastClick) < doubleClickWait) {
				if (_arrow && _arrow.parent) {
					_arrow.stop();
					_arrow.parent.removeChild(_arrow);
				}
				HeroFBModule.getInstance().heroFBEnter(_currentBarrier);
				lastClick = 0;
			}
			lastClick = time;
		}
		
		/**
		 * 设置当前关卡
		 */
		
		public function set currentBarrier(id:int):void
		{		
			if (id <= 10) id = 11;
			// 清掉上一个的选中状态
			var btn:ToggleButton = _mapBg.getChildByName(currentBarrier.toString()) as ToggleButton;
			if (btn)
				btn.selected = false;
			
			var target:ToggleButton = _mapBg.getChildByName(id.toString()) as ToggleButton;
			if (target)
				target.selected = true;
			// 当前关卡没有没必要处理以下东西
			if (currentBarrier == id)
				return;
			// 未开通的关卡攻击及战报按钮不可点
			_attackBtn.enabled = true;
			_reportBtn.enabled = true;
			if (id > _heroFBInfo.progress) {
				_attackBtn.enabled = false;
				_reportBtn.enabled = false;
			}
			// boss头像
			var monsterVo:MonsterType = HeroFBDataManager.getInstance().getBossVoByBarrierId(id);
			_bossHeadIcon.source = GameConfig.ROOT_URL + "com/ui/npc/" + monsterVo.skinid + ".png";
			// 掉落图标
			var dropVo:BaseItemVO = HeroFBDataManager.getInstance().getDropItemVo(id);
			if (!dropVo)
				_dropImage.visible = false;
			else {
				_dropImage.setImageContent(dropVo, dropVo.path);
				_dropImage.data = dropVo;
				_dropImage.visible = true;
			}
			// 关卡描述
			_fbDesc.htmlText = HeroFBDataManager.getInstance().getBarrierDesc(id);
			// 掉落描述
			_dropDesc.htmlText = HeroFBDataManager.getInstance().getBarrierDropDesc(id);
			
			_currentBarrier = id;
		}
		
		/**
		 * 获取当前关卡
		 */
		
		public function get currentBarrier():int
		{
			return _currentBarrier;
		}
		
		/**
		 * 获取当前章节
		 */
		
		public function get currentChapter():int
		{
			return _currentChapter;
		}
		
		/**
		 * 创建togglebutton 
		 */
		
		private function createToggleBtn(x:int, y:int, width:int, height:int, normal:String, over:String, disable:String, down:String=null, select:String=null):ToggleButton
		{
			var btn:ToggleButton = new ToggleButton;
			btn.x = x;
			btn.y = y;
			btn.width = width;
			btn.height = height;
			
			var skin:ButtonSkin = new ButtonSkin;
			skin.skin = _source.getBitmapData(normal);
			skin.overSkin = _source.getBitmapData(over);
			skin.disableSkin = _source.getBitmapData(disable);
			if (down)
				skin.downSkin = _source.getBitmapData(down);
			if (select)
				skin.selectedSkin = _source.getBitmapData(select);
			
			btn.bgSkin = skin;
			
			return btn;
		}
	}
}