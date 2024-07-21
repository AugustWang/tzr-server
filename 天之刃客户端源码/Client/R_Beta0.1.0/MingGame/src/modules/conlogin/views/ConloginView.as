package modules.conlogin.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.conlogin.ConloginModule;
	import modules.vip.VipModule;
	
	import proto.common.p_conlogin_reward;
	import proto.line.m_conlogin_fetch_toc;
	import proto.line.m_conlogin_info_toc;
	import proto.line.m_conlogin_notshow_tos;
	
	/**
	 * 连续登录奖励面板 
	 */	
	public class ConloginView extends BasePanel
	{
		private var leftBlackBg:Sprite;
		private var rightBlackBg:Sprite;
		
		private var leftPlacard:VScrollText;
		private var loginInfo:TextField;
		private var itemsCanvas:Canvas;
		private var autoShowText:TextField;
		public function ConloginView()
		{
			super();
		}
		
		override protected function init():void{
			title = "连续登录奖励";
			width = 585;
			height = 382;
			
			leftBlackBg = Style.getBlackSprite(200,340,6);
			leftBlackBg.x = 11;
			leftBlackBg.y = 1;
			addChild(leftBlackBg);
			
			rightBlackBg = Style.getBlackSprite(360,340,6);
			rightBlackBg.x = 213;
			rightBlackBg.y = 1;
			addChild(rightBlackBg);
			
			var leftTopBar:UIComponent = ComponentUtil.createUIComponent(1,2,198,20);
			Style.setBorder1Skin(leftTopBar);
			leftBlackBg.addChild(leftTopBar);
			
			var greentf:TextFormat = Style.textFormat;
			greentf.bold = true;
			greentf.size = 13;
			greentf.color = 0xffff00;
			greentf.align = "center";
			ComponentUtil.createTextField("公告",0,0,greentf,leftTopBar.width,leftTopBar.height,leftTopBar);
			
			var placardtf:TextFormat = Style.textFormat;
			placardtf.leading = 3;
			placardtf.leftMargin = 4;
			placardtf.letterSpacing = 2;
			leftPlacard = new VScrollText();
			leftPlacard.direction = ScrollDirection.RIGHT;
			leftPlacard.verticalScrollPolicy = ScrollPolicy.AUTO;
			leftPlacard.x = 1;
			leftPlacard.y = 23;
			leftPlacard.width = 198;
			leftPlacard.height = 316;
			leftPlacard.textField.defaultTextFormat = placardtf;
			leftPlacard.selectable = true;
			leftBlackBg.addChild(leftPlacard);
			
			var tf:TextFormat = Style.textFormat;
			tf.bold = true;
			tf.size = 13;
			tf.color = 0xCDE643;
			tf.leading = 8;
			loginInfo = ComponentUtil.createTextField("",18,12,tf,344,50,rightBlackBg);
			loginInfo.multiline = true;
			loginInfo.wordWrap = true;
			loginInfo.selectable = true;
			loginInfo.mouseEnabled = true;
			loginInfo.mouseWheelEnabled = false;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y = 80;
			line.width = 355;
			rightBlackBg.addChild(line);
			
			itemsCanvas = new Canvas();
			itemsCanvas.y = 86;
			itemsCanvas.x = 10;
			itemsCanvas.width = 348;
			itemsCanvas.height = 227;
			rightBlackBg.addChild(itemsCanvas);
			
			var redTf:TextFormat = Style.textFormat;
			redTf.bold = true;
			redTf.color = 0x3BE450;
			redTf.underline = true;
			
			autoShowText = ComponentUtil.createTextField("", 200, 318, redTf, 140, 25, rightBlackBg);
			autoShowText.htmlText = "<a href='event:conlogin_not_show'>今天不再显示本界面</a>";
			autoShowText.mouseEnabled = true;
			autoShowText.addEventListener(TextEvent.LINK, onAutoShowClicked);
			
			var clearConloginDays:TextField = ComponentUtil.createTextField("", 30, 318, redTf, 140, 25, rightBlackBg);
			clearConloginDays.htmlText = "<a href='event:clearConloginDays'>连续登陆天数清零</a>";
			clearConloginDays.mouseEnabled = true;
			clearConloginDays.addEventListener(TextEvent.LINK, onAutoShowClicked);
		}
		
		private function onAutoShowClicked(event:TextEvent):void{
			if (event.text == "conlogin_not_show") {
				this.closeWindow(true);
				ConloginModule.getInstance().sendNotShowRequest(new m_conlogin_notshow_tos);
			}
			if (event.text == "clearConloginDays") 
				ConloginModule.getInstance().popClearConloginView();
		}
		
		public function updateReward(vo:m_conlogin_fetch_toc):void{
			var childs:Array = this.itemsCanvas.getAllChildren();
			for each(var child:ConloginRewardList in childs) {
				if (child.id == vo.id) {
					if (child.update(vo)) {
						this.itemsCanvas.removeChild(child);
						child.dispose();
						child = null;
					}
				}
			}
			childs = this.itemsCanvas.getAllChildren();
			if (childs.length > 0) {
				var i:int = 0;
				for each(var child2:ConloginRewardList in childs) {
					child2.y = i*(child2.height + 2);
					i++;
				}
				itemsCanvas.updateSize();
			} else {
				ConloginModule.getInstance().requestInfo();
			}
			
		}
		
		private function _sortRewardFunc(a:Object, b:Object):Number {
			if ( a.flag > b.flag ) {
				return 1;
			} else {
				return -1;
			}
		}
		
		private function sortReward(rewards:Array):Array {
			var i:int = 0;
			var rewardArr:Array = new Array;
			for each(var reward:p_conlogin_reward in rewards) {
				if ( (reward.need_payed && !GlobalObjectManager.getInstance().user.attr.is_payed) || 
					(reward.gold > GlobalObjectManager.getInstance().user.attr.gold && reward.gold > GlobalObjectManager.getInstance().user.attr.gold_bind) || 
					(reward.silver > GlobalObjectManager.getInstance().user.attr.silver && reward.silver > GlobalObjectManager.getInstance().user.attr.silver_bind)
					|| (reward.need_vip_level > VipModule.getInstance().getRoleVipLevel())
					|| (reward.min_level > GlobalObjectManager.getInstance().user.attr.level) ){
					rewardArr[i] = {'flag':1, 'value':reward};
				} else {
					rewardArr[i] = {'flag':0, 'value':reward};
				}
				i++;
			}
			rewardArr.sort(_sortRewardFunc);
			i=0;
			var rewardSort:Array = new Array;
			for each (var reward2:Object in rewardArr) {
				rewardSort[i] = reward2.value;
				i++;
			}
			return rewardSort;
		}
		
		public function update(data:m_conlogin_info_toc):void{
			leftPlacard.htmlText = data.notice;
			if (data.next_day > 0) {
				loginInfo.htmlText = "你已连续登录"+HtmlUtil.font(data.day.toString(),"#f53f3c")+"天，在第" + HtmlUtil.font(data.next_day.toString(),"#f53f3c") + "天即可领取以下奖励。天数越多奖励越多，特定天数有大奖。";
			} else {
				loginInfo.htmlText = "你已连续登录"+HtmlUtil.font(data.day.toString(),"#f53f3c")+"天，可以领取以下奖励。天数越多奖励越多，特定天数有大奖。";
			}
			var childs:Array = this.itemsCanvas.getAllChildren();
			this.itemsCanvas.removeAllChildren();
			for each (var child:ConloginRewardList in childs) {
				child.dispose();
			}
			var rewards:Array = this.sortReward(data.rewards);
			
			var i:int = 0;
			for each(var reward:p_conlogin_reward in rewards) {
				var rewardItem:ConloginRewardList = new ConloginRewardList(reward.id, data.next_day, data.next_day - data.day);
				rewardItem.data = reward;
				rewardItem.y = i*(rewardItem.height + 2);
				itemsCanvas.addChild(rewardItem);
				i++;
			}
			itemsCanvas.updateSize();
		}
		
		
		/**
		 * 通过外部数据初始化界面 
		 */		
		public function initView(data:m_conlogin_info_toc):void{
			leftPlacard.htmlText = data.notice;
			if (data.next_day > 0) {
				loginInfo.htmlText = "你已连续登录"+HtmlUtil.font(data.day.toString(),"#f53f3c")+"天，在第" + HtmlUtil.font(data.next_day.toString(),"#f53f3c") + "天即可领取以下奖励。天数越多奖励越多，特定天数有大奖。";
			} else {
				loginInfo.htmlText = "你已连续登录"+HtmlUtil.font(data.day.toString(),"#f53f3c")+"天，可以领取以下奖励。天数越多奖励越多，特定天数有大奖。";
			}
			var rewards:Array = this.sortReward(data.rewards);
			var i:int = 0;
			for each(var reward:p_conlogin_reward in rewards) {
				var rewardItem:ConloginRewardList = new ConloginRewardList(reward.id, data.next_day, data.next_day - data.day);
				rewardItem.data = reward;
				rewardItem.y = i*(rewardItem.height + 2);
				itemsCanvas.addChild(rewardItem);
				i++;
			}
			itemsCanvas.updateSize();
		}
	}
}