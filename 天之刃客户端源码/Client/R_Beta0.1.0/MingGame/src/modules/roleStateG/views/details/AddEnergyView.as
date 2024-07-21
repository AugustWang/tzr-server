package modules.roleStateG.views.details
{
	import com.common.GlobalObjectManager;
	import com.components.components.DragUIComponent;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.common.p_role;
	import proto.common.p_role_fight;
	
	public class AddEnergyView extends DragUIComponent
	{
		public static var EVENT_ON_ADD_ENERGY:String = "EVENT_ON_ADD_ENERGY";
		
		private var _title:TextField;
		private var _result:TextField;
		private var _info:TextField;
		private var _goldInput:NumericStepper;
		private var _btn:Button;
		
		public function AddEnergyView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{		
			this.width = 353;
			this.height = 110;
			Style.setRectBorder(this);
			this.showCloseButton = true;
			
			var tf:TextFormat = new TextFormat("Tahoma", 14, 0xF6F5CD);
			
			_title = ComponentUtil.createTextField("您累积剩余精力值4000点，可补充精力值4000点", 8, 4, tf, 400, 25, this);
			ComponentUtil.createTextField("花费", 8, 30, Style.textFormat, 67, 25, this);
			_result = ComponentUtil.createTextField("元宝，补充100点精力值", 127, 30, Style.textFormat, 200, 20, this);
			_info = ComponentUtil.createTextField("今天已补充精力值4000点，剩余4000点", 8, 53, Style.textFormat, 300, 20, this);
			_info.textColor = 0xFF0000;
			_info.visible = false;
			
			var notice:TextField = ComponentUtil.createTextField("", 8, 53, Style.textFormat, 300, 40, this);
			notice.multiline = true;
			notice.htmlText = "提示：可补充精力值来源于角色每天的剩余精力值点\n         剩余精力值最高累积10000点";
			
			_btn = ComponentUtil.createButton("补充", 273, 80, 55, 22, this);
			Style.setRedBtnStyle(_btn);
			_btn.addEventListener(MouseEvent.CLICK, onAddEnergy);
			
			_goldInput = new NumericStepper;
			_goldInput.x = 43;
			_goldInput.y = 30;
			_goldInput.maxnum = 10000;
			_goldInput.minnum = 0;
			_goldInput.stepSize = 1;
			_goldInput.textFiled.textField.defaultTextFormat = Style.textFormat;
			_goldInput.value = 1;
			_goldInput.width = 78;
			addChild(_goldInput);
			_goldInput.addEventListener(Event.CHANGE, onNumChange);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 222;
			line.height = 2;
			line.x = 3;
			line.y = 27;
			addChild(line);
			
			addEventListener(WindowEvent.OPEN, onWinOpen);
		}
		
		private function onAddEnergy(e:Event):void
		{
			this.dispatchEvent(new ParamEvent(EVENT_ON_ADD_ENERGY, _goldInput.value, true));
			// 关闭界面
			WindowManager.getInstance().removeWindow(this);
		}
		
		private function onNumChange(e:Event):void
		{
			var fightVO:p_role_fight = GlobalObjectManager.getInstance().user.fight;
				
			if (fightVO.energy_remain <= 0) {
				_btn.enabled = false;
				_goldInput.value = 0;
			} else {
				_btn.enabled = true;
				if (_goldInput.value * 100 > fightVO.energy_remain)
					_goldInput.value = Math.ceil(fightVO.energy_remain/100);
				
				if (_goldInput.value == 0 && fightVO.energy_remain > 0)
					_goldInput.value = 1;
			}
			
			if (fightVO.energy_remain < 100 * _goldInput.value) {
				_result.text = "元宝，补充" + fightVO.energy_remain + "点精力值";
			} else {
				_result.text = "元宝，补充" + (_goldInput.value*100) + "点精力值";
			}
		}
		
		private function onWinOpen(evt:WindowEvent):void
		{
			setData();
		}
		
		public function setData():void
		{			
			var fightVO:p_role_fight = GlobalObjectManager.getInstance().user.fight;
			_title.text = "您累积剩余精力值" + fightVO.energy_remain + "点，可补充精力值" + fightVO.energy_remain + "点";
				
			if (fightVO.energy_remain <= 0) {
				_btn.enabled = false;
				_goldInput.value = 0;
			} else {
				_btn.enabled = true;
				_goldInput.value = 1;
			}
			
			if (fightVO.energy_remain < 100 * _goldInput.value)
				_result.text = "元宝，补充" + fightVO.energy_remain + "点精力值";
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			WindowManager.getInstance().removeWindow(this);
		}
	}
}