package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyYBCModule;
	
	public class JoinFamilyYBCPanel extends BasePanel
	{
		private var text:TextField;
		private var application:Button;
		public function JoinFamilyYBCPanel()
		{
			super();
		}
		
		override protected function init():void{
			this.title = "门派拉镖通知";
			
			width = 265
			height =345;
			
			var bg:Sprite = new Sprite();
			bg.x=7;
			this.addChild(bg);
			
			var css:StyleSheet = new StyleSheet( );
			css.parseCSS("a {color: #ffff00;text-decoration: underline;} a:hover {text-decoration: underline; color: #ff7700;}");
			
			var tf:TextFormat = Style.textFormat;
			tf.leading = 5;
			text = ComponentUtil.createTextField("",12,10,tf,230,260,bg);
			text.wordWrap = true;
			text.multiline = true;
			text.styleSheet = css;
			text.mouseEnabled = true;
			text.addEventListener(TextEvent.LINK,onTextLink);
			
			application = ComponentUtil.createButton("申请加入镖队",150,282,100,26,this);
			application.addEventListener(MouseEvent.CLICK,onMouseClick);
		}
		
		private var type:int;
		public function setYBCType(type:int):void{
			this.type = type;
			var html:String = "     你所在门派已发布门派拉镖任务，完成可获得大量经验。";
			html += "\n     参与门派拉镖需要不绑定银子作为押金：";
			var money:String = FamilyYBCModule.getInstance().getYBCMoney(FamilyConstants.YBC_TYPE_NORMAL);
			html += "\n     普通镖车："+HtmlUtil.font(money,"#ffff00");
			money = FamilyYBCModule.getInstance().getYBCMoney(FamilyConstants.YBC_TYPE_HIGH);
			html += "\n     厚实镖车："+HtmlUtil.font(money,"#ffff00");
			var color:String = type == FamilyConstants.YBC_TYPE_NORMAL ? "#ffffff" : "#4ea8ff";
			html += "\n     门派当前选择的是："+HtmlUtil.font((type == FamilyConstants.YBC_TYPE_NORMAL ? "普通镖车" : "厚实镖车"),color);
			html += "\n     押金足够且军仓储副使史可法附近可加入镖队。";
			if(GlobalObjectManager.getInstance().user.attr.silver < FamilyYBCModule.getInstance().getMoney(type)){
				html += HtmlUtil.font("（当前押镖押金不够）","#f53f3c");
			}
			html += "\n\n\n                                   <a href='event:goto'>立即寻路前往</a>";
			html += "\n                   <a href='event:convection'>传送前往（消耗传送卷x1）</a>";
			text.htmlText = html;
		}
		
		private function onTextLink(event:TextEvent):void{
			if(event.text == "goto"){
				goto();
			}else{
				carry();
			}
		}
		
		/**
		 * 自动寻路到“史可法”
		 */		
		public function goto():void{
			var faction:int = GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String = "1"+faction+"100128";
			PathUtil.findNPC(npcId);
		}
		/**
		 * 传送到 “史可法”
		 */		
		public function carry():void{
			var faction:int = GlobalObjectManager.getInstance().user.base.faction_id;
			var npcId:String = "1"+faction+"100128";
			PathUtil.carryNPC(npcId,false,"已经在拉镖活动范围内了，不需要传送。");
		}
		
		private function onMouseClick(event:MouseEvent):void{
			FamilyYBCModule.getInstance().agreePublishYBC();
		}
	}
}