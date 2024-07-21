package modules.goal.views
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.goal.GoalDataManager;
	import modules.goal.GoalResource;
	import modules.goal.vo.GoalItemVO;
	import modules.goal.vo.GoalVO;
	
	public class GoalItem extends Sprite
	{
		private var skin:ButtonSkin
		private var goalName:TextField;
		private var stateTxt:TextField;
		public function GoalItem()
		{
			super();
			
			buttonMode = useHandCursor = true;
			
			skin = new ButtonSkin();
			skin.skin = GoalResource.getBitmapData("goalItem_skin");
			skin.overSkin = GoalResource.getBitmapData("goalItem_overskin");
			skin.downSkin = GoalResource.getBitmapData("goalItem_downskin");
			skin.selectedSkin = GoalResource.getBitmapData("goalItem_downskin");
			skin.setSize(71,72);
			addChild(skin);
			
			var tf:TextFormat = Style.textFormat;
			tf.align = "center";
			goalName = ComponentUtil.createTextField("",3,80,tf,65,72,this);
			goalName.wordWrap = true;
			goalName.multiline = true;
			
			stateTxt = ComponentUtil.createTextField("",0,75,tf,71,20,this);
		}
		
		private var _goalItemVo:GoalItemVO;
		public function set goalItemVo(vo:GoalItemVO):void{
			_goalItemVo = vo;
			update();
		}
		
		public function update():void{
			goalName.text = _goalItemVo.name;
			goalName.height = goalName.textHeight + 5;
			goalName.y = 72 - goalName.height >> 1;
			
			if(_goalItemVo.status == 0){
				stateTxt.htmlText = HtmlUtil.font("未开启","#ff0000");
			}else if(_goalItemVo.status == 1){
				stateTxt.htmlText = HtmlUtil.font("进行中","#00ff00");
			}else if(_goalItemVo.status == 2){
				stateTxt.htmlText = HtmlUtil.font("可领奖","#ffff00");
			}else if(_goalItemVo.status == 3){
				stateTxt.htmlText = HtmlUtil.font("已完成","#ffff00");
			}
//			if(_goalItemVo.status == 3 && _goalItemVo.parent.active > GoalDataManager.getInstance().day){
//				addEventListener(MouseEvent.ROLL_OVER,onRollOver);
//				addEventListener(MouseEvent.ROLL_OUT,onRollOut);
//			}else{
//				removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
//				removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
//			}
		}
		
//		private function onRollOver(event:MouseEvent):void{
//			ToolTipManager.getInstance().show("当前进行的是第"+GoalDataManager.getInstance().day+"天目标，到第"+_goalItemVo.parent.active+"天即可领取奖励",0);
//			
//		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		public function get goalItemVo():GoalItemVO{
			return _goalItemVo;
		}
		
		private var _selected:Boolean;
		public function set selected(value:Boolean):void{
			_selected = value;
			skin.selected = _selected;
		}
		
		public function get selected():Boolean{
			return _selected;
		}
	}
}