package modules.trading.views
{
	import com.components.BasePanel;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.trading.TradingModule;
	import modules.trading.tradingManager.TradingManager;
	
	public class IntroduceWindow extends BasePanel
	{
		/*
		
		完成商贸可获得不绑定银子。每天最多可参加3次。               
		参加条件：                                                   
		（1）30级以上；
		（2）已加入门派；
		商贸流程：
		（1）在京城夏原吉处领取商票；
		（2）打开NPC商店购买物品；
		（3）到野外黑市商人处售卖物品并重新购入（太平村、西凉、边城各有一黑市商人）；
		（4）回夏原吉处售空物品；
		（5）交还商票得到收益。
		在1次商贸过程中，不限制买卖商品的次数，若商票余额超过商票价值上限，无法继续购买商品，
		但可卖出商品和交还银票。商贸过程中死亡，将100%丢失商票，本次商贸失败。
		 * */
		//不绑定
		private static const pre_descStr:String = "完成商贸可获得银子，每天可参加3次，" +
			"周日可用门派贡献换取【商贸宝典】，交票时" +
			"使用可获得双倍收益。<font color='#3be450'>(当前为第";
		private static const desc_str:String = "次领取商票)</font>\n" +
			"<font color='#ffff00'>参加条件：</font>\n" +
			"（1）30级以上；\n" +
			"（2）已加入门派；\n" +
			"（3）活跃度≥6以上获得不绑定银子；\n" +
			"（4）活跃度不足，获得绑定银子。"+
			"可以通过参加拉镖、门派活动、守边、刺探、国战等各种活动提升活跃度。\n"+
			"<font color='#ffff00'>商贸流程：</font>\n" +
			"（1）在京城<a href='event:f_npcid=10100104'><u><font color='#00ff00'>夏原吉</font></u></a>" +
			"处领商票并买入商品；\n" +
			"（2）到<a href='event:f_npcid=10102103'><u><font color='#00ff00'>平江</font></u></a>、" +
			"<a href='event:f_npcid=10105102'><u><font color='#00ff00'>边城</font></u></a>" +
			"黑市商人处买卖商品；\n" +
			"（3）回<a href='event:f_npcid=10100104'><u><font color='#00ff00'>夏原吉</font></u></a>" +
			"处售空商品并交还商票。\n" +
			"<font color='#3be450'>商票余额超过其价值上限，" +
			"无法再购买商品，但可卖出商品、交还商票。" +
			"商贸时死亡将丢失商票，本次商贸失败。</font>";
		
		private var desc:TextField;
		
		public function IntroduceWindow()
		{
			super();
			this.width = 282;
			this.height = 386;
			this.mouseEnabled=true;
			this.mouseChildren=true;
			this.title = "商贸介绍";
			
			var uibg:UIComponent = ComponentUtil.createUIComponent(11,2,260,346);
			Style.setBorder1Skin(uibg);
			addChild(uibg);
			
			initView();
			
			addEventListener(Event.ADDED_TO_STAGE, onAdd);
		}
		
		private function initView():void
		{
			var tf:TextFormat = new TextFormat("Tahoma",12,0xF6F5CD);
			tf.leading = 5;
			desc = ComponentUtil.createTextField("",15,6,tf,252,339,this);//257
			desc.multiline = desc.wordWrap = true;
			
			desc.mouseEnabled = true;
			desc.selectable = false;
			desc.htmlText = pre_descStr +
				TradingModule.getInstance().times+  desc_str;
			
			desc.addEventListener(TextEvent.LINK,onLink);
			
		}
		private function onLink(e:TextEvent):void
		{
			TradingManager.getInstance().goToScenceByName(e);
		}
		
		private function onAdd(e:Event):void
		{
			desc.htmlText = pre_descStr +
				TradingModule.getInstance().times+  desc_str;
		}
		
		
		override public function dispose():void{
			
			super.dispose();
			desc.text = "";
			desc = null;
			removeEventListener(Event.ADDED_TO_STAGE, onAdd);
		}
		
	}
}