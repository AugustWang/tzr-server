package modules.accumulateExp
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.MessageIconManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class AccumulateExpView extends BasePanel
	{
		private var canvas:Canvas;
		// NPCID 拼凑规则 1 + FactionID + npc_id
		private var accNpcList:Array = new Array(
			{"id": 1, "title":"个人拉镖", "npc_name":"京城-张将军", "npc_id":"100102"},
			{"id": 2, "title":"门派拉镖", "npc_name":"京城-史可法", "npc_id":"100128"},
			{"id": 3, "title":"守卫国土", "npc_name":"京城-沐英", "npc_id":"105100"},
			{"id": 4, "title":"刺探军情", "npc_name":"京城-冯胜", "npc_id":"100105"}
		);
		public function AccumulateExpView(key:String=null)
		{
			super(key);
		}
		
		private var topBg:Sprite;
		private var titleTipBg:UIComponent;
		private var textTipTitle:TextField;
		private var textTipDesc:TextField;
		
		private var bottomBg:Sprite;
		private var titleTipBg2:UIComponent;
		private var textTip2:TextField;
		
		private var y_begin:int = 4;
		
		public static const CHILD_WIDTH:int = 497;
		
		override protected function init():void
		{
			 this.width = 520;
			 this.height = 260;
			 this.title = "累积经验上线提醒";
			 update();
		}
		
		private function onTextLink(e:TextEvent):void
		{
			PathUtil.findNpcAndOpen(e.text);
		}
		
		public function update():void
		{
			this.removeAllChildren();
			//如果有累积经验可以直接领取
			if (AccumulateExpModule.getInstace().hasExpToGet()) {
				// 上部温馨提示的容器面板
				topBg = Style.getBlackSprite(CHILD_WIDTH, 52, 2);
				topBg.x = 10;
				topBg.y = 4;
				this.addChild(topBg);
				
				titleTipBg = ComponentUtil.createUIComponent(0, 0, CHILD_WIDTH, 25);
				Style.setBorder1Skin(titleTipBg);
				topBg.addChild(titleTipBg);
				
				var tft:TextFormat = new TextFormat('Tahoma',12,0xFFFF00);
				textTipTitle = ComponentUtil.createTextField("温馨提示", 10, y_begin, tft);
				titleTipBg.addChild(textTipTitle);
				
				// 温馨提示详细描述
				textTipDesc = ComponentUtil.createTextField("", 10, 27, tft, 490);
				textTipDesc.htmlText = "你有大量额外经验奖励尚未领取，可找NPC" + "<u><font color='#00FF00'><a href='event:1" + GlobalObjectManager.getInstance().user.base.faction_id +
					"100134'>京城-高明</a></font></u>领取。";
				textTipDesc.mouseEnabled = true;
				textTipDesc.addEventListener(TextEvent.LINK, onTextLink);
				topBg.addChild(textTipDesc);
			}
			
			if (AccumulateExpModule.getInstace().hasExpToGet()) {
				bottomBg = Style.getBlackSprite(CHILD_WIDTH, 160, 2);
				bottomBg.x = 10;
				bottomBg.y = 60;
			} else {
				bottomBg = Style.getBlackSprite(CHILD_WIDTH, 222, 2);
				bottomBg.x = 10;
				bottomBg.y = 2;
			}
			
			this.addChild(bottomBg);
			
			// 有些任务只要完成一次就可以领取奖励了
			if (AccumulateExpModule.getInstace().hasAcc()) {
				titleTipBg2 = ComponentUtil.createUIComponent(0, 0, CHILD_WIDTH, 25);
				Style.setBorder1Skin(titleTipBg2);
				bottomBg.addChild(titleTipBg2);
				
				var tff:TextFormat = new TextFormat('Tahoma',12,0xFFFF00);
				textTip2 = ComponentUtil.createTextField("", 10, 2, tff, 490, 25);
				textTip2.htmlText = "推荐任务（完成任务后可到" +
					"<u><font color='#00FF00'><a href='event:1"+ GlobalObjectManager.getInstance().user.base.faction_id +
					"100134'>京城-高明</a></font></u>处领取丰厚额外的累积经验）";
				textTip2.addEventListener(TextEvent.LINK, onTextLink);
				textTip2.mouseEnabled = true;
				titleTipBg2.addChild(textTip2);
				
				var yy:int = 25;
				// 依次显示每个累积经验任务
				for each (var accNPC:Object in accNpcList) {
					// 只显示完成任务后可以领取的
					if (AccumulateExpModule.getInstace().hasExpByID(accNPC.id)) {
						
						var text:TextField = ComponentUtil.createTextField(accNPC.title, 10, yy);
						bottomBg.addChild(text);
						
						var tf:TextFormat = new TextFormat('Tahoma',12,0x00ff00,null,null,true);
						tf.underline = true;
						var textNpc:TextField = ComponentUtil.createTextField("", 300, yy, tf);
						textNpc.mouseEnabled = true;
						textNpc.htmlText = "<a href='event:1" + GlobalObjectManager.getInstance().user.base.faction_id + accNPC.npc_id + "'>" + accNPC.npc_name + "</a>";
						textNpc.addEventListener(TextEvent.LINK, onTextLink);
						yy = yy+26;
						bottomBg.addChild(textNpc);
					}
				}
			}
			
		}
		
		private function removeIcon(e:TimerEvent):void
		{
//ICON重构			MessageIconManager.removeAccumulateItem();
		}
		
		override protected function closeHandler(event:CloseEvent=null):void
		{
			super.closeHandler(event);
			var timer:Timer = new Timer(300 * 1000, 1);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, removeIcon);
			//ICON重构			MessageIconManager.showAccumulateItem();
		}
	}
}