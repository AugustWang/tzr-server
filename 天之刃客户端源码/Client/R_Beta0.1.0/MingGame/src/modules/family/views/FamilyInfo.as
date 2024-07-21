package modules.family.views
{
	import com.common.Constant;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.family.FamilyConstants;
	
	import proto.common.p_family_info;
	
	public class FamilyInfo extends UIComponent
	{
		private var tfFamilyName:TextField;
		private var tfFamilyHeader:TextField;
		private var tfFamilyGrade:TextField;
		private var tfFamilyProsperity:TextField;
		private var tfFamilyFunding:TextField;
		private var tfFamilyNumber:TextField;
		private var tfCreator:TextField;
		
		public function FamilyInfo()
		{
			super();
			
			var lb:TextField = ComponentUtil.buildTextField("门派名称:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,60,25,this);
			lb.y = 5;
			lb.x = 10;
			tfFamilyName = ComponentUtil.buildTextField("",null,NaN,25,this);
			tfFamilyName.selectable = true;
			tfFamilyName.x = 63;
			tfFamilyName.y = 5;
			
			lb = ComponentUtil.buildTextField("创始人:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,60,25,this);
			lb.y = 5;
			lb.x = 143;
			tfCreator = ComponentUtil.buildTextField("",null,90,25,this);
			tfCreator.selectable = true;
			tfCreator.x = 185;
			tfCreator.y = 5;		 
			
			lb = ComponentUtil.buildTextField("门派掌门:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,60,25,this);
			lb.y = 5;
			lb.x = 285;
			tfFamilyHeader = ComponentUtil.buildTextField("",null,90,25,this);
			tfFamilyHeader.selectable = true;
			tfFamilyHeader.x = 340;
			tfFamilyHeader.y = 5;
			
			createTipBg(0,40,140,25,prosperityTipHandler);
			var prosperityBg:UIComponent = ComponentUtil.createUIComponent(0,40,140,25);
			lb = ComponentUtil.buildTextField("门派繁荣度:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,70,25,this);
			lb.y = 40;
			lb.x = 10;
			tfFamilyProsperity = ComponentUtil.buildTextField("",null,70,25,this);
			tfFamilyProsperity.x = 76;
			tfFamilyProsperity.y = 40;
			
			
			createTipBg(123,40,140,25,moneyTipHandler);
			lb = ComponentUtil.buildTextField("门派资金:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,70,25,this);
			lb.y = 40;
			lb.x = 123;
			tfFamilyFunding = ComponentUtil.buildTextField("",null,90,25,this);
			tfFamilyFunding.x = 175;
			tfFamilyFunding.y = 40;
			
			createTipBg(263,40,70,25,levelTipHandler)
			lb = ComponentUtil.buildTextField("门派等级:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,60,25,this);
			lb.y = 40;
			lb.x = 263;
			tfFamilyGrade = ComponentUtil.buildTextField("",null,40,25,this);
			tfFamilyGrade.y = 40;
			tfFamilyGrade.x = 316;

			createTipBg(333,40,115,25,numTipHandler);
			lb = ComponentUtil.buildTextField("门派人数:",Constant.TEXTFORMAT_COLOR_GRAYYELLOW,60,25,this);
			lb.y = 40;
			lb.x = 348;
			tfFamilyNumber = ComponentUtil.buildTextField("",null,55,25,this);
			tfFamilyNumber.y = 40;
			tfFamilyNumber.x = 400;
			
		}
		
		public function setFamilyInfo(info:p_family_info):void{
			tfFamilyName.text = info.family_name;
			tfCreator.text = info.create_role_name;
			tfFamilyHeader.text = info.owner_role_name;
			tfFamilyGrade.text = info.level.toString();
			tfFamilyProsperity.text = info.active_points.toString();
			var money:String = info.money.toString();
			if(info.money > 0){
				money = MoneyTransformUtil.silverToOtherString(info.money);
			}
			tfFamilyFunding.text = money;
			var totalCount:int = FamilyConstants.counts[info.level];
			tfFamilyNumber.text = info.cur_members+"/"+totalCount;
		}
		
		private function createTipBg(x:int,y:int,w:int,h:int,overHandler:Function):void{
			var s:Sprite = new Sprite();
			s.x = x;
			s.y = y;
			with(s.graphics){
				beginFill(0x0,0);
				drawRect(0,0,w,h);
				endFill();
			}
			s.addEventListener(MouseEvent.ROLL_OVER,overHandler);
			s.addEventListener(MouseEvent.ROLL_OUT	,outHandler);
			addChild(s);
		}
		
		private function outHandler(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		private function prosperityTipHandler(event:MouseEvent):void{
			var level:int = int(tfFamilyGrade.text);
			var prosperity:int = FamilyConstants.KEEP_COST[level][1];
			var tip:String = "当前门派等级"+level+"级，每天维护的门派繁荣度需"+prosperity+"点。";
			if(level < FamilyConstants.counts.length - 1){
				prosperity = FamilyConstants.LEVELUP_CONDITION[level+1][1];
				tip += "\n升级到"+(level+1)+"级，需要"+prosperity+"点门派繁荣度。";
			}
			ToolTipManager.getInstance().show(tip,0);
		}
		
		private function moneyTipHandler(event:MouseEvent):void{
			var level:int = int(tfFamilyGrade.text);
			var moeny:int = FamilyConstants.KEEP_COST[level][0];
			var tip:String = "当前门派等级"+level+"级，每天维护的门派资金需"+MoneyTransformUtil.silverToOtherString(moeny);
			if(level < FamilyConstants.counts.length - 1){
				var needMoney:Number = FamilyConstants.LEVELUP_CONDITION[level+1][0];
				tip += "\n升级到"+(level+1)+"级，需要门派资金"+MoneyTransformUtil.silverToOtherString(needMoney)+"。";
			}
			ToolTipManager.getInstance().show(tip,0);
		}
		
		private function levelTipHandler(event:MouseEvent):void{
			var level:int = int(tfFamilyGrade.text);
			if(level == FamilyConstants.counts.length - 1){
				ToolTipManager.getInstance().show("门派已达到最高等级",0);
			}else{
				ToolTipManager.getInstance().show("前往门派地图中打败"+(level+1)+"级升级Boss，\n并且门派资金、门派繁荣度同时足够，可升级到"+(level+1)+"级门派。",0);
			}
			
			
		}
		
		private function numTipHandler(event:MouseEvent):void{
			var level:int = int(tfFamilyGrade.text);
			if(level == FamilyConstants.counts.length - 1){
				ToolTipManager.getInstance().show("门派已达到最高等级",0);
			}else{
				var nextCount:int = FamilyConstants.counts[level+1];
				ToolTipManager.getInstance().show("下一级可招收"+nextCount+"人",0);
			}
		}
	}
}