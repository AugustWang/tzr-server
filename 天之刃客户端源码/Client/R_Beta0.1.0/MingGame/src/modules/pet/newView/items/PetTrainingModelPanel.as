package modules.pet.newView.items {
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.pet.PetDataManager;
	
	import proto.line.m_pet_training_request_tos;

	public class PetTrainingModelPanel extends BasePanel {
		private var models:Array=["", "正常模式", "加强模式", "VIP1 模式", "VIP2 模式", "VIP3 模式"]
		private var modelTF:TextField;
		private var RBGroup:RadioButtonGroup;
		private var normalRB:RadioButton;
		private var strongRB:RadioButton;
		private var vip1RB:RadioButton;
		private var vip2RB:RadioButton;
		private var vip3RB:RadioButton;

		public function PetTrainingModelPanel() {
			initView();
		}

		private function initView():void {
			width=310;
			height=274;
			addImageTitle("title_changePetTrainingModel");
			addContentBG(8, 8, 8);
			modelTF=ComponentUtil.createTextField("", 20, 15, null, 200, 25, this);
			modelTF.filters=Style.textBlackFilter;
			RBGroup=new RadioButtonGroup();
			RBGroup.direction=RadioButtonGroup.VERTICAL;
			RBGroup.space=0;
			RBGroup.x=60;
			RBGroup.y=50;
			normalRB=createRadioButton("正常模式（100%经验）", ItemConstant.COLOR_VALUES2[1]);
			RBGroup.addItem(normalRB);
			strongRB=createRadioButton("加强模式（120%经验 2金币）", ItemConstant.COLOR_VALUES2[2]);
			RBGroup.addItem(strongRB);
			vip1RB=createRadioButton("VIP1 模式（150%经验 5金币）", ItemConstant.COLOR_VALUES2[3]);
			RBGroup.addItem(vip1RB);
			vip2RB=createRadioButton("VIP2 模式（180%经验 8金币）", ItemConstant.COLOR_VALUES2[4]);
			RBGroup.addItem(vip2RB);
			vip3RB=createRadioButton("VIP3 模式（200%经验 10金币）", ItemConstant.COLOR_VALUES2[5]);
			RBGroup.addItem(vip3RB);
			addChild(RBGroup);

			var yesBtn:Button=ComponentUtil.createButton("确定", (this.width - 60) >> 1, 186, 70, 24, this);
			yesBtn.addEventListener(MouseEvent.CLICK, onYesBtnClick);
		}

		private function createRadioButton(label:String, color:uint, $x:int=0, $y:int=0):RadioButton {
			var tf:TextFormat=new TextFormat("Tahoma", 12, color);
			var rb:RadioButton=new RadioButton(label);
			rb.textFilter=Style.textBlackFilter;
			rb.textFormat=tf;
			rb.x=$x;
			rb.y=$y;
			addChild(rb);
			return rb;
		}
		
		private var _model:int;
		public function update(model:int):void {
			_model =model;
			modelTF.htmlText=HtmlUtil.font("当前训练模式", "#fffd4b") + HtmlUtil.font(models[model], ItemConstant.COLOR_VALUES[model]);
			normalRB.enable=true;
			strongRB.enable=true;
			vip1RB.enable=true;
			vip2RB.enable=true;
			vip3RB.enable=true;
			if (model > 1) {
				normalRB.enable=false;
			}
			if (model > 2) {
				strongRB.enable=false;
			}
			if (model > 3) {
				vip1RB.enable=false;
			}
			if (model > 4) {
				vip2RB.enable=false;
			}
			RBGroup.selectedIndex = model - 1;
		}

		private function onYesBtnClick(event:MouseEvent):void {
			if(RBGroup.selectedIndex >= _model){
				var vo:m_pet_training_request_tos = new m_pet_training_request_tos();
				vo.op_type = 7;
				vo.pet_id = PetDataManager.currentPetInfo.pet_id;
				vo.training_mode = RBGroup.selectedIndex + 1;
				Connection.getInstance().sendMessage(vo);
				WindowManager.getInstance().removeWindow(this);
			}else{
				Tips.getInstance().addTipsMsg("请选择比当前模式强大的模式");
			}
		}
	}
}