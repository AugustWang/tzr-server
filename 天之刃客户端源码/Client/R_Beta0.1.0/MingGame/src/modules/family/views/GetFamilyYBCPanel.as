package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyYBCModule;
	
	public class GetFamilyYBCPanel extends BasePanel
	{
		private var text:TextField;
		private var tip:TextField;
		private var memberList:List;
		private var invite:Button;
		private var sendBtn:Button;
		private var cancelBtn:Button;
		public function GetFamilyYBCPanel()
		{
			super();
		}
		
		override protected function init():void{
			this.title = "领取镖车";
			
			width = 265
			height =345;
			
			var bg:UIComponent=new UIComponent();
			bg.x=9;
			bg.width=this.width - 18;
			bg.height=310;
			Style.setBorderSkin(bg);
			addChild(bg);
			this.addChild(bg);
			
			var css:StyleSheet = new StyleSheet( );
			css.parseCSS("a {color: #ffff00;text-decoration: underline;} a:hover {text-decoration: underline; color: #ff7700;}");
			
			var tf:TextFormat = Style.textFormat;
			tf.leading = 3;
			text = ComponentUtil.createTextField("",12,10,tf,232,110,bg);
			text.wordWrap = true;
			text.multiline = true;
			
			tip = ComponentUtil.createTextField("",12,222,tf,232,60,bg);
			tip.mouseEnabled = true;
			tip.wordWrap = true;
			tip.multiline = true;
			tip.addEventListener(TextEvent.LINK,onLinkText);
			tip.styleSheet = css;
			
			memberList = new List();
			Style.setBorder1Skin(memberList);
			memberList.bgAlpha = 0.6;
			memberList.bgColor = 0x000000;
			memberList.labelField = "roleName";
			memberList.x = 14;
			memberList.y = 100;
			memberList.width = 227;
			memberList.height = 120;
			memberList.itemHeight = 20;
			bg.addChild(memberList);
			sendBtn = ComponentUtil.createButton("确定领取",80,278,80,26,this);
			sendBtn.addEventListener(MouseEvent.CLICK,onOKHandler);
			cancelBtn = ComponentUtil.createButton("取消领取",170,278,80,26,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCancelHandler);
			
			invite = ComponentUtil.createButton("邀请帮众",171,72,70,26,this);
			invite.addEventListener(MouseEvent.CLICK,onInviteHandler);
		}
		
		private var type:int;
		
		private var numOfMembers:int = 1;
		public function setYBCType(type:int):void{
			this.type = type;
			var html:String = "      门派镖车分为普通镖车和厚实镖车，厚实镖车的血量是普通镖车的10倍，更有保障完成任务，完成任务获得奖励相同";
			var color:String = type == FamilyConstants.YBC_TYPE_NORMAL ? "#ffffff" : "#4ea8ff";
			html += "\n当前选择的是："+HtmlUtil.font((type == FamilyConstants.YBC_TYPE_NORMAL ? "普通镖车" : "厚实镖车"),color);
			html += HtmlUtil.font("\n镖队成员(" + this.numOfMembers + ")：","#3be450");
			text.htmlText = html;
			tip.htmlText = "";
			if(GlobalObjectManager.getInstance().user.attr.role_id == FamilyYBCModule.getInstance().ybcCreator){
				invite.visible = true;
				sendBtn.visible = true;
				cancelBtn.label = "取消领取";
				html = HtmlUtil.font("注意：附近的帮众才能加入镖队，你已经召集好帮众了吗？","#cde643");
				html += "\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='event:collect'>"+HtmlUtil.font("召集门派成员一起拉镖","#3be450")+"</a> ";
			}else{
				html = HtmlUtil.font("注意：请保护好镖车，镖车被劫血为零则任务失败，无法获得奖励，不退回押金；主动退出镖队不退回押金","#cde643");
				invite.visible = false;
				sendBtn.visible = false;
				cancelBtn.label = "退出队伍";
			}
			tip.htmlText = html;
		}
		
		
		public function setMembers(members:Array):void{
			memberList.dataProvider = members;
			numOfMembers = members ? members.length : 1;
			setYBCType(this.type);
		}
		
		private function onLinkText(event:TextEvent):void{
			FamilyYBCModule.getInstance().openCollectPanel();
		}
		
		private function onOKHandler(event:MouseEvent):void{
			FamilyYBCModule.getInstance().surePublishYBC();
			closeWindow();
		}
		
		private function onCancelHandler(event:MouseEvent):void{
			Alert.show("你确定要放弃此次拉镖活动？","提示",yesHandler);
			function yesHandler():void{
				FamilyYBCModule.getInstance().giveUpYBC();
			}
		}
		
		private function onInviteHandler(event:MouseEvent):void{
			FamilyYBCModule.getInstance().inviteMember();
		}
	}
}