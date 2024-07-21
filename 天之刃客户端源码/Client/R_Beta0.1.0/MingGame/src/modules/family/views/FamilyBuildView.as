package modules.family.views
{
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyModule;
	
	import proto.common.p_family_info;

	public class FamilyBuildView extends Sprite
	{
		private var tfFamilyName:TextField;
		private var tfFamilyGrade:TextField;
		private var tfFamilyProsperity:TextField;
		private var tfFamilyFunding:TextField;
		
		private var  cur_memberCount:TextField;
		private var  cur_fzzCount:TextField;
		private var  cur_expadd:TextField;
		private var  cur_callBossLv:TextField;
		
		private var  memberCount:TextField;
		private var  fzzCount:TextField;
		private var  expadd:TextField;
		private var  callBossLv:TextField;
		
		private var needProsperity:TextField;
		private var needMoney:TextField;
		
		private var gradeUpBtn:Button;
		public function FamilyBuildView()
		{
			initView();
		}
		
		public function initView():void
		{
			var infoBG:UIComponent = ComponentUtil.createUIComponent(5,5,455,308);
			Style.setBorderSkin(infoBG);
			addChild(infoBG);
			
			tfFamilyName = createInputField("门派名称:",15,10);
			tfFamilyGrade = createInputField("等级:",190,10);
			tfFamilyFunding = createInputField("门派资金:",300,10);
			tfFamilyProsperity = createInputField("门派繁荣度:",15,35);
			
			var cutTitle:TextField = ComponentUtil.createTextField("当前等级",10,65,null,100,20,this);
			cutTitle.textColor = 0x00ff00;
			cutTitle.filters = FilterCommon.FONT_BLACK_FILTERS;
			cur_memberCount = createInputField("成员数:",15,90);
			cur_fzzCount = createInputField("副门主数量:",190,90);
			cur_expadd = createInputField("经验加成:",300,90);
			cur_callBossLv = createInputField("可召唤Boss等级:",15,115);
			
			cutTitle = ComponentUtil.createTextField("下一等级",10,145,null,100,20,this);
			cutTitle.textColor = 0x00ff00;
			cutTitle.filters = FilterCommon.FONT_BLACK_FILTERS;
			memberCount = createInputField("成员数:",15,170);
			fzzCount = createInputField("副门主数量:",190,170);
			expadd = createInputField("经验加成:",300,170);
			callBossLv = createInputField("可召唤Boss等级:",15,195);
			
			cutTitle = ComponentUtil.createTextField("升级条件",10,225,null,100,20,this);
			cutTitle.textColor = 0x00ff00;
			cutTitle.filters = FilterCommon.FONT_BLACK_FILTERS;
			needProsperity = createInputField("需要门派繁荣度:",15,250);
			needMoney = createInputField("需要门派繁资金:",15,275);
			
			contributeBtn = ComponentUtil.createButton("捐献",285,270,65,25,this)
			contributeBtn.addEventListener(MouseEvent.CLICK,contributeHandler);
			
			gradeUpBtn = ComponentUtil.createButton("升级",355,270,65,25,this);
			gradeUpBtn.addEventListener(MouseEvent.CLICK,gradeUpHandler);
			
		}
		
		private function createInputField(proName:String,startX:int,startY:int):TextField{
			var title:TextField = ComponentUtil.createTextField(proName,startX,startY,Style.themeTextFormat,NaN,20,this);
			title.width = title.textWidth+4;
			var valueText:TextField = ComponentUtil.createTextField("",startX+title.width+5,startY,null,100,20,this)
			return valueText;
		}
		
		private var info:p_family_info;
		private var contributeBtn:Button;
		public function setFamilyInfo(info:p_family_info):void{
			this.info = info;
			tfFamilyName.text = info.family_name;
			tfFamilyGrade.text = info.level.toString();
			tfFamilyFunding.text = info.money.toString();
			tfFamilyProsperity.text = info.active_points.toString();
				
			cur_memberCount.text = FamilyConstants.counts[info.level];
			cur_fzzCount.text = FamilyConstants.FZZ_COUNTS[info.level];
			cur_expadd.text = "0";
			if(info.level == 0){
				cur_callBossLv.text = "不可召唤";
			}else{
				cur_callBossLv.text = FamilyConstants.CALL_BOSS_LEVEL[info.level];
			}

			if(info.level < 6){	
				memberCount.text = FamilyConstants.counts[info.level+1];
				fzzCount.text = FamilyConstants.FZZ_COUNTS[info.level+1];
				expadd.text = "0";
				callBossLv.text = FamilyConstants.CALL_BOSS_LEVEL[info.level+1];
				var conditons:Array = FamilyConstants.LEVELUP_CONDITION[info.level+1];
				needProsperity.text = conditons[1];
				needMoney.text = MoneyTransformUtil.silverToOtherString(conditons[0]);
				gradeUpBtn.visible = true;
			}else{
				memberCount.text = FamilyConstants.counts[info.level];
				fzzCount.text = FamilyConstants.FZZ_COUNTS[info.level];
				expadd.text = "0";
				callBossLv.text = FamilyConstants.CALL_BOSS_LEVEL[info.level];
				needProsperity.text = "";
				needMoney.text = "";
				gradeUpBtn.visible = false;	
			}
		}
		
		public function updateFamilyInfo():void{
			setFamilyInfo(info);
		}
		
		private function contributeHandler(event:MouseEvent):void{
			var contributePanel:FamilyContributePanel = new FamilyContributePanel();
			WindowManager.getInstance().popUpWindow(contributePanel);
			WindowManager.getInstance().centerWindow(contributePanel);
		}
		
		private function gradeUpHandler(event:MouseEvent):void{
			FamilyModule.getInstance().familyLevelUp();
		}
	}
}