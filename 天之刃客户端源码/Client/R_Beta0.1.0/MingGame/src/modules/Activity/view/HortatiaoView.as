package modules.Activity.view {
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityModule;
	
	import proto.line.m_accumulate_exp_view_toc;
	import proto.line.m_conlogin_info_toc;

	public class HortatiaoView extends UIComponent {
		//累积经验的view
		public var accumulateView:AccumulateExpView;
		//连续登录的view
		public var continueLoginView:ContinueLoginView;
		
		private var rightBlackBg:UIComponent;
		
		private var leftBlackBg:UIComponent;

		public function HortatiaoView() {
			super();
			initUI();
		}

		private function initUI():void {
			leftBlackBg = ComponentUtil.createUIComponent(8,8,267,343);
			Style.setBorderSkin(leftBlackBg);
			addChild(leftBlackBg);
			
			rightBlackBg=ComponentUtil.createUIComponent(leftBlackBg.width + leftBlackBg.x+6,8,354,343);
			Style.setBorderSkin(rightBlackBg);
			addChild(rightBlackBg);
			
			accumulateView=new AccumulateExpView();
			accumulateView.x = 2;
			accumulateView.y = 23;
			accumulateView.y=4;
			leftBlackBg.addChild(accumulateView);

			continueLoginView=new ContinueLoginView();
			continueLoginView.x=2;
			continueLoginView.y=5;
			rightBlackBg.addChild(continueLoginView);
		}

		override public function set data(vo:Object):void {
			if (vo == null) {
				accumulateView.data=null;
			} else {
				if (vo is m_conlogin_info_toc) {
					continueLoginView.data=vo as m_conlogin_info_toc;
				} else {
					var dataVO:m_accumulate_exp_view_toc = vo as m_accumulate_exp_view_toc;
					accumulateView.data=dataVO;
				}
			}
		}
	}
}
import com.common.FilterCommon;
import com.common.GlobalObjectManager;
import com.globals.GameConfig;
import com.ming.ui.containers.Canvas;
import com.ming.ui.controls.Button;
import com.ming.ui.controls.core.UIComponent;
import com.ming.ui.skins.Skin;
import com.utils.ComponentUtil;
import com.utils.HtmlUtil;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import modules.Activity.ActivityModule;
import modules.Activity.view.ConloginRewardList;
import modules.broadcast.views.Tips;
import modules.conlogin.ConloginModule;
import modules.vip.VipModule;

import proto.common.p_conlogin_reward;
import proto.line.m_accumulate_exp_get_tos;
import proto.line.m_accumulate_exp_refresh_tos;
import proto.line.m_accumulate_exp_view_toc;
import proto.line.m_conlogin_fetch_toc;
import proto.line.m_conlogin_info_toc;
import proto.line.m_conlogin_notshow_tos;

class AccumulateExpView extends Sprite {
	//累计总经验
	private var allAccExp:TextField;
	//可领经验
	private var pullDownAccExp:TextField;
	//可提升到的经验
	private var upgradeAccExp:TextField;
	//元宝提升按钮
	private var upgradeBTN:Button;
	//数据
	private var content:m_accumulate_exp_view_toc;
	//获取经验按钮
	private var pullDownBTN:Button
	//你没有累积经验可领取
	private var placard:TextField;
	//主窗口
	private var parentSprite:Sprite;

	public function AccumulateExpView() {
		super();
		initUI();
	}

	private function initUI():void {
		this.y=3;		
		parentSprite = new Sprite();
		addChild(parentSprite);

		var greentf:TextFormat=Style.textFormat;
		greentf.size=14;
		greentf.color=0xffffff;
		greentf.align="center";
		var title:TextField = ComponentUtil.createTextField("累积经验", 0, 8, greentf, 267,20,this);
		title.filters = FilterCommon.FONT_BLACK_FILTERS;
		
		greentf.leading = 5;
		greentf.size = 12;
		greentf.align = "left";
		var content:String="<pre> 1.最多获得3天的累积经验</pre><br>" +
			"<pre> 2.可累积经验的日常任务：个人拉镖、门派拉镖、守卫国土和刺探军情</pre><br>" + "<pre> 3.可领取的经验可使用元宝提升</pre>"
		var prompt:TextField = ComponentUtil.createTextField("累积总经验：0",10,30,greentf,240,NaN,this);
		prompt.autoSize=TextFieldAutoSize.LEFT;
		prompt.wordWrap=true;
		prompt.multiline=true;
		prompt.htmlText=content;

		var tiao:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
		tiao.x=10;
		tiao.y=120;
		tiao.width=245;
		addChild(tiao);

		allAccExp = ComponentUtil.createTextField("累积总经验：0",60,141,null,150,NaN,parentSprite);
		pullDownAccExp = ComponentUtil.createTextField("可领经验：0",60,161,null,150,NaN,parentSprite);
		upgradeAccExp = ComponentUtil.createTextField("可提升经验至：0",60,181,null,150,NaN,parentSprite);

		upgradeBTN=ComponentUtil.createButton("0元宝提升",98,205,70,25,parentSprite);
		upgradeBTN.addEventListener(MouseEvent.CLICK, onUpdateExp);

		pullDownBTN=ComponentUtil.createButton("领取经验",98,235,70,25,parentSprite);
		pullDownBTN.addEventListener(MouseEvent.CLICK, onGetExp);
		
		var centerTF:TextFormat = Style.textFormat;
		centerTF.align = "center";
		centerTF.color = 0xffffff;
		placard = ComponentUtil.createTextField("你没有累积经验可领取",56,190,centerTF,150,NaN,this);
		placard.visible = false;
	}

	private function onTextLink(e:TextEvent):void {
		VipModule.getInstance().onOpenVipPannel();
	}

	private function onGetExp(e:MouseEvent):void {
		if (content != null && content.cangetexp > 0) {
			var vo:m_accumulate_exp_get_tos=new m_accumulate_exp_get_tos();
			ActivityModule.getInstance().sendGetExp(vo);
		} else {
			Tips.getInstance().addTipsMsg(msg);
		}
	}

	private function onUpdateExp(e:MouseEvent):void {
		if (content != null && content.gold > 0) { //m_accumulate_exp_refresh_tos
			var vo:m_accumulate_exp_refresh_tos=new m_accumulate_exp_refresh_tos();
			ActivityModule.getInstance().sendUpdateExp(vo);
		}
	}


	private function getColor(flag:int):String {
		var color:String;
		switch (flag) {
			case 0:
				color="#ffffff";
				break;
			case 1:
				color="#00CC99";
				break;
			case 2:
				color="#40DEF9";
				break;
			case 3:
				color="#fe00e9";
				break;
			case 4:
				color="#FF9000";
				break;
		}
		return color;
	}

	private function initData():void {
		if(content.cangetexp == 0 || content.succ == false)
		{
			if(content.reason == "" || content.reason == null){
				placard.htmlText="<font color='#FFFFFF'>你没有累积经验可领取</font>";
			}else{
				placard.htmlText="<font color='#FFFFFF'>"+content.reason+"</font>";
			}
			placard.visible = true;
			parentSprite.visible = false;
			
		}else{
			placard.visible = false;
			parentSprite.visible = true;
			
			allAccExp.htmlText="<font color='" + getColor(4) + "'>总经验：" + content.allexp.toString() + "</font>";
			pullDownAccExp.htmlText="<font color='" + getColor(content.flag) + "'>可领取经验：" + content.cangetexp.
				toString() + "</font>";
			
			if (content.flag == 4) {
				upgradeAccExp.visible = false;
			} else {
				upgradeAccExp.htmlText="<font color='" + getColor(content.flag + 1) + "'>可提升经验至：" + content.
					nextexp.toString() + "</font>";
			}
			
			
			upgradeBTN.label=content.gold + " 元宝提升";
			
			if (content.flag == 4) {
				upgradeBTN.enabled=false;
			}
			
			if (content.cangetexp == 0) {
				upgradeBTN.enabled=false;
				pullDownBTN.enabled=false;
			}
		}
	}

	private var msg:String="你未满足获取累积经验的条件.";

	public function set data(vo:Object):void {
		if (vo != null) {
			content=vo as m_accumulate_exp_view_toc;
			initData();
		}
	}

}



class ContinueLoginView extends Sprite {

	private var title:TextField;
	//连续登录信息
	private var loginInfo:TextField;
	//存放奖励的物品面板
	private var itemsCanvas:Canvas;
	//今日是否还要提示
	private var autoShowText:TextField;

	public function ContinueLoginView() {
		initUI();
	}

	private function initUI():void {
				
		var titlTF:TextFormat = new TextFormat("Tahoma", 14, 0xFFFFFF);
		titlTF.align = TextFormatAlign.CENTER;
		
		title = ComponentUtil.createTextField("连续登陆",0,5,titlTF,354,20,this);
		title.filters = FilterCommon.FONT_BLACK_FILTERS;
		
		var loginTF:TextFormat = new TextFormat("Tahoma", 14, 0xFFFFFF);
		loginTF.align = TextFormatAlign.CENTER;
		loginTF.leading = 5;
		
		loginInfo=ComponentUtil.createTextField("",10,30,loginTF,334,100,this);
		loginInfo.multiline=true;
		loginInfo.wordWrap=true;
		loginInfo.selectable=true;
		loginInfo.mouseEnabled=true;
		loginInfo.mouseWheelEnabled=false;
		
		itemsCanvas=new Canvas();
		itemsCanvas.width = 341;
		itemsCanvas.horizontalScrollPolicy = "off";
		itemsCanvas.verticalScrollPolicy = "on";
		itemsCanvas.y=100;
		itemsCanvas.x=4;
		itemsCanvas.height=202;
		addChild(itemsCanvas);

		var redTf:TextFormat=Style.textFormat;
		redTf.color=0x3BE450;
		redTf.underline=true;

		autoShowText=ComponentUtil.createTextField("", 200, 305, redTf, 140, 25, this);
		autoShowText.filters = FilterCommon.FONT_BLACK_FILTERS;
		autoShowText.htmlText="<a href='event:conlogin_not_show'>今天不再显示本界面</a>";
		autoShowText.mouseEnabled=true;
		autoShowText.addEventListener(TextEvent.LINK, onAutoShowClicked);

		clearConloginDays=ComponentUtil.createTextField("", 40, 305, redTf, 140, 25, this);
		clearConloginDays.filters = FilterCommon.FONT_BLACK_FILTERS;
		clearConloginDays.htmlText="<a href='event:clearConloginDays'>连续登陆天数清零</a>";
		clearConloginDays.mouseEnabled=true;
		clearConloginDays.addEventListener(TextEvent.LINK, onAutoShowClicked);
	}

	private function onAutoShowClicked(event:TextEvent):void {
		if (event.text == "conlogin_not_show") {
			ActivityModule.getInstance().sendNotShowRequest(new m_conlogin_notshow_tos);
		}
		if (event.text == "clearConloginDays")
			ActivityModule.getInstance().popClearConloginView();
	}

	private var clearConloginDays:TextField;

	public function set data(vo:m_conlogin_info_toc):void {
		initData(vo);
	}

	private function initData(vo:m_conlogin_info_toc):void {
		if (vo.next_day > 0) {
			loginInfo.htmlText="你已连续登录" + HtmlUtil.font(vo.day.toString(), "#ffff00") +
				"天，在第" + HtmlUtil.font(vo.next_day.toString(), "#ffff00") + "天即可领取以下奖励。天数越多奖励越多，特定天数有大奖。";
		} else {
			loginInfo.htmlText="你已连续登录" + HtmlUtil.font(vo.day.toString(), "#ffff00") +
				"天，可以领取以下奖励。天数越多奖励越多，特定天数有大奖。";
		}
		var childs:Array=this.itemsCanvas.getAllChildren();
		this.itemsCanvas.removeAllChildren();
		for each (var child:ConloginRewardList in childs) {
			child.dispose();
		}
		var rewards:Array=this.sortReward(vo.rewards);

		var i:int=0;
		for each (var reward:p_conlogin_reward in rewards) {
			var rewardItem:ConloginRewardList=new ConloginRewardList(reward.id, vo.next_day, vo.next_day -
				vo.day);
			rewardItem.data=reward;
			rewardItem.y=i * (rewardItem.height + 2);
			itemsCanvas.addChild(rewardItem);
			i++;
		}
		itemsCanvas.updateSize();
	}

	private function _sortRewardFunc(a:Object, b:Object):Number {
		if (a.flag > b.flag) {
			return 1;
		} else {
			return -1;
		}
	}

	public function updateReward(vo:m_conlogin_fetch_toc):void {
		var childs:Array=this.itemsCanvas.getAllChildren();
		for each (var child:ConloginRewardList in childs) {
			if (child.id == vo.id) {
				if (child.update(vo)) {
					this.itemsCanvas.removeChild(child);
					child.dispose();
					child=null;
				}
			}
		}
		childs=this.itemsCanvas.getAllChildren();
		if (childs.length > 0) {
			var i:int=0;
			for each (var child2:ConloginRewardList in childs) {
				child2.y=i * (child2.height + 2);
				i++;
			}
			itemsCanvas.updateSize();
		} else {
			ConloginModule.getInstance().requestInfo();
		}

	}

	private function sortReward(rewards:Array):Array {
		var i:int=0;
		var rewardArr:Array=new Array;
		for each (var reward:p_conlogin_reward in rewards) {
			if ((reward.need_payed && !GlobalObjectManager.getInstance().user.attr.is_payed) || (reward.
				gold > GlobalObjectManager.getInstance().user.attr.gold && reward.gold > GlobalObjectManager.
				getInstance().user.attr.gold_bind) || (reward.silver > GlobalObjectManager.getInstance().
				user.attr.silver && reward.silver > GlobalObjectManager.getInstance().user.attr.silver_bind) ||
				(reward.need_vip_level > VipModule.getInstance().getRoleVipLevel()) || (reward.min_level >
				GlobalObjectManager.getInstance().user.attr.level)) {
				rewardArr[i]={'flag': 1, 'value': reward};
			} else {
				rewardArr[i]={'flag': 0, 'value': reward};
			}
			i++;
		}
		rewardArr.sort(_sortRewardFunc);
		i=0;
		var rewardSort:Array=new Array;
		for each (var reward2:Object in rewardArr) {
			rewardSort[i]=reward2.value;
			i++;
		}
		return rewardSort;
	}
}
