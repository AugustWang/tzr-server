package modules.Activity.view.itemRender {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.vo.AwardVo;
	import modules.ModuleCommand;

	public class AwardBaseItemRender extends UIComponent {
		private var txtTask1:TextField;
		private var txtTask2:TextField;
		private var rewardTxt:TextField;
		private var jichuTxt:TextField;
		private var imgArr:Array; //=[];
		private var bgComplete:Image;
		private var txtBuy:Button;
		private var actTaskID:int;
		private var actAddTxt:TextField;

		public function AwardBaseItemRender() {
			super();
			initView();
		}

		private function initView():void {
			this.width = 444;
			this.height = 72;
			Style.setBorderSkin(this)
			
			var txtTask1TF:TextFormat = new TextFormat("Tahoma", 14,0xfffd4b);
			txtTask1 = ComponentUtil.createTextField( "", 16, 4, txtTask1TF, 150, 22, this ); /*个人拉镖*/
			txtTask1.multiline = txtTask1.wordWrap = true;
			txtTask1.filters = Style.textBlackFilter;
			
			var txtTask2TF:TextFormat = new TextFormat("Tahoma", 12,0x23dc45);
			txtTask2TF.align = TextFormatAlign.CENTER;
			txtTask2 = ComponentUtil.createTextField( "", 0, 44, txtTask2TF, 444, 22, this ); /*个人拉镖，完成3次个人拉镖*/
			txtTask2.multiline = txtTask2.wordWrap = true;
			txtTask2.mouseEnabled = true;
			txtTask2.addEventListener(TextEvent.LINK, onLinkHandler);
			
			var jichuTxtTF:TextFormat = new TextFormat("Tahoma", 14,0xfffd4b);
			jichuTxt = ComponentUtil.createTextField( "基础奖励", 370, 20, jichuTxtTF, 72, 22, this ); /*基础奖励*/
			jichuTxt.multiline = jichuTxt.wordWrap = true;
			
			var rewardTxtTF:TextFormat = new TextFormat("Tahoma", 12,0x23dc45);
			rewardTxtTF.align = TextFormatAlign.CENTER;
			rewardTxt = ComponentUtil.createTextField( "", 350, 36, rewardTxtTF, 92, 22, this ); /*个人经验*/
			rewardTxt.multiline = rewardTxt.wordWrap = true;

			txtBuy = ComponentUtil.createButton("快速完成",183,15,78,24,this);
			txtBuy.addEventListener( MouseEvent.CLICK, function( e:MouseEvent ):void {
					onBuyBtnClick();
				});

			bgComplete = new Image();
			bgComplete.source = GameConfig.ROOT_URL + "com/assets/backGroundImages/complete.png";
			bgComplete.x = 184;
			bgComplete.y = 5;
			this.addChild( bgComplete );
			bgComplete.visible = false;
			
			var iconBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			iconBg.x=25;
			iconBg.y=25;
			addChild(iconBg);

			this.validateNow();
		}
		
		protected function onLinkHandler(evt:TextEvent):void
		{
			// TODO Auto-generated method stub
			var vo:AwardVo = super.data as AwardVo;
			var npcId:int;
			if(GlobalObjectManager.getInstance().user.base.faction_id == 1){
				npcId = vo.npcId + 1000000;
			}
			if(GlobalObjectManager.getInstance().user.base.faction_id == 2){
				npcId = vo.npcId + 2000000;
			}
			if(GlobalObjectManager.getInstance().user.base.faction_id == 3){
				npcId = vo.npcId + 3000000;
			}
			if (evt.text == "goto") {
				//				ID = this.name;
				ActivityModule.getInstance().goto(npcId);
			} else if (evt.text == "sendto") {
//				ActivityModule.getInstance().sendtoNpc(this.voxml.npc_id[fation]);
				ActivityModule.getInstance().sendtoNpc(npcId);
			}
		}
		
		override public function set data( value:Object ):void {

			super.data = value;
			var vo:AwardVo = value as AwardVo;

			actTaskID = vo.id;
			txtTask1.text = vo.taskName;
			var html:String = HtmlUtil.font(vo.taskCondition,"#23dc45");
			txtTask2.htmlText = html;

			rewardTxt.htmlText = HtmlUtil.font(getExp( vo.expAdd, vo.expMult ) + " 经验","#23dc45");
			
			if(vo.npcId == 0){
				//actAddTxt.visible=false;
			}else{
				txtTask2.htmlText = html + "<font color='#3be450'><a href ='event:goto'><u> 前往</u></a> " +
					" <a href ='event:sendto'><u>传送 </u></a></font>";
			}
			
			if ( vo.isMatch ) {
				bgComplete.visible = true;
				txtBuy.visible = false;
			} else {
				bgComplete.visible = false;
				if ( vo.isRewarded ) {
					txtBuy.visible = false;
				} else {
					txtBuy.visible = true;
					txtBuy.mouseEnabled = true;
				}
			}

			this.validateNow();
		}
		
		private var line:Bitmap;
		private function drawLine():void {
			line = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 393;
			line.y = 48;
			addChild(line);
		}

		private function getExp( add:int, mult:int ):int {
			var exp:int = 0;
			var lv:int = GlobalObjectManager.getInstance().user.attr.level;
			exp = add + lv * mult;
			return exp;
		}

		private function onBuyBtnClick():void {
			Alert.show( "使用3个不绑定元宝可立即获取勋章，请确认是否获取！", "提示", onConfirmBuyClick, null, "确定", "取消" );
		}

		private function onConfirmBuyClick():void {
			var m_gold:int = GlobalObjectManager.getInstance().user.attr.gold;
			if ( m_gold >= 3 ) {
				if ( actTaskID > 0 ) {
					ActivityModule.getInstance().requestBuyBenefit( actTaskID );
				}
			} else {
				Alert.show( "<font color='#F6F5CD'>您的不绑定元宝不足，无法获取勋章！" + "<font color='#00ff00'><a href='event:chongZhi'><u>立即充值</u></a></font></font>",
					"提示", null, null, "确定", "", null, false, true, null, linkPay );
			}

		}

		private function linkPay( e:TextEvent ):void {
			Dispatch.dispatch(ModuleCommand.OPEN_PAY_HANDLER);	
		}

		override public function dispose():void {
			super.dispose();
			while ( this.numChildren > 0 ) {
				var displayobj:DisplayObject = this.getChildAt( 0 );
				removeChild( displayobj );
				displayobj = null;
			}

		}
	}
}


