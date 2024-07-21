package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.HeaderBar;
	import com.components.alert.Alert;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.family.views.items.FamilySkillItem;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	
	
	public class FamilySkillLearnPanel extends BasePanel
	{
		public static const LEARN_FMLSKILL:String = "LEARN_FMLSKILL";
		public static const PERSONAL_FORGET_FMLSKILL:String = "PERSONAL_FORGET_FMLSKILL"
		
		private var moneyText:TextField;
		private var headerBar:HeaderBar;
		private var canvas:Canvas;
		private var selectItem:FamilySkillItem
		public function FamilySkillLearnPanel()
		{
		}
		
		public function initView():void{
			this.title = "学习门派技能";
			this.width = 566;
			this.height = 389;
			
			var bgT:UIComponent = new UIComponent();
			this.addChild(bgT);
			Style.setBorder1Skin(bgT);
			bgT.width = 542;
			bgT.height = 24;
			bgT.x = 12;
			bgT.y = 3;
			
			var bgM:UIComponent = new UIComponent();
			this.addChild(bgM);
			Style.setBorder1Skin(bgM);
			bgM.width = 542;
			bgM.height = 285;
			bgM.x = 12;
			bgM.y = 29;
			
			var bgB:UIComponent = new UIComponent();
			this.addChild(bgB);
			Style.setBorder1Skin(bgB);
			bgB.width = 542;
			bgB.height = 30;
			bgB.x = 12;
			bgB.y = 316;
			
			moneyText = new TextField();
			moneyText.height = 25;
			moneyText.width = 500;
			moneyText.x = 15;
			moneyText.y = 5;
			moneyText.htmlText = "<font color='#B7DDE6'>个人门派贡献点：</font><font color='#EDF6E3'>" + GlobalObjectManager.getInstance().user.attr.family_contribute+"</font>";
			addChild(moneyText);
			
			headerBar = new HeaderBar();
			headerBar.width = 539;
			headerBar.x = 13;
			headerBar.y = 30;
			headerBar.addColumn("门派技能",204);
			headerBar.addColumn("学习技能条件",330);
			addChild(headerBar);
			
			var learnBtn:Button = ComponentUtil.createButton("学习技能",359,317,70,26,this);
			learnBtn.addEventListener(MouseEvent.CLICK,onLearnBtnClick);
			var forgetBtn:Button = ComponentUtil.createButton("遗忘技能",459,317,70,26,this);
			forgetBtn.addEventListener(MouseEvent.CLICK,onForgetBtnClick);
			
			canvas = new Canvas();
			canvas.width = 540;
			canvas.height = 260;
			canvas.x = 13;
			canvas.y = 55;
			
			var array:Array = SkillDataManager.getCategory(SkillConstant.CATEGORY_FAMILY);
			for( var i:int = 0; i < array.length; i++ ){
				var item:FamilySkillItem = new FamilySkillItem();
				item.initView(FamilySkillItem.LEARN,"skillBorderBitmap",525,65);
				item.addEventListener(FamilySkillItem.CLICK_EVENT,onItemClick);
				item.addEventListener(MouseEvent.ROLL_OVER,onItemRollOverHandler);
				item.addEventListener(MouseEvent.ROLL_OUT,onItemRollOutHandler);
				item.data = array[i];
				canvas.addChild(item);
			}
			
			LayoutUtil.layoutGrid(canvas, 1, 0, 8);
			addChild(canvas);
			canvas.getChildAt(0).y = 5
		}
		
		public function updata():void{
			if(moneyText)moneyText.htmlText = "<font color='#B7DDE6'>个人门派贡献点：</font><font color='#EDF6E3'>" + GlobalObjectManager.getInstance().user.attr.family_contribute+"</font>";
			if(canvas){
				var array:Array = SkillDataManager.getCategory(SkillConstant.CATEGORY_FAMILY);
				for( var i:int = 0; i < array.length; i++ ){
					var item:FamilySkillItem = canvas.getChildAt(i) as FamilySkillItem;
					item.data = array[i];
				}
			}
		}
		
		private function onLearnBtnClick(event:MouseEvent):void{
			if( selectItem ){
				if( selectItem.data.level >= selectItem.data.max_level ){
					Tips.getInstance().addTipsMsg("该技能已经升至顶级！");
					return;
				}
				if( selectItem.data.fml_level == 0 ){
					Tips.getInstance().addTipsMsg("该技能未研究！");
					return;
				}
				var s:String = selectItem.learnTip;
				Alert.show(s,"学习门派技能",learnYesHandler);
			}else{
				Tips.getInstance().addTipsMsg("没有选中技能");
			}
		}
		
		private function learnYesHandler():void{
			var e:DataEvent = new DataEvent(LEARN_FMLSKILL);
			e.data = selectItem.data.sid;
			dispatchEvent(e);
		}
		
		private function onForgetBtnClick(event:MouseEvent):void{
			if( selectItem ){
				if( selectItem.data.level == 0 ){
					Tips.getInstance().addTipsMsg("该技能未学习！");
					return;
				}
				var s:String = selectItem.personalTip;
				Alert.show(s,"遗忘门派技能",forgetYesHandler);
			}else{
				Tips.getInstance().addTipsMsg("没有选中技能");
			}
		}
		
		private function forgetYesHandler():void{
			var e:DataEvent = new DataEvent(PERSONAL_FORGET_FMLSKILL);
			e.data = selectItem.data.sid;
			dispatchEvent(e);
		}
		
		private function onItemRollOverHandler(evt:MouseEvent):void{
			FamilySkillItem(evt.currentTarget).overBg.visible = true;
		}
		private function onItemRollOutHandler(evt:MouseEvent):void{
			FamilySkillItem(evt.currentTarget).overBg.visible = false;
		}
		
		private function onItemClick(event:Event):void{
			if( selectItem != null ){
				selectItem.selected = false;
				selectItem.scaleBitmap.visible = false;
			}
			selectItem = event.target as FamilySkillItem;
			selectItem.selected = true;
			selectItem.scaleBitmap.visible = true;
			selectItem.overBg.visible = false;
		}
	}
}