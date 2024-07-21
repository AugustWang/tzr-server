package modules.pet.view
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class PetNumberSteper extends UIComponent
	{
		public static const EVENT_ADD_PROPRETYS:String="EVENT_ADD_PROPRETYS";
		private var txt:TextField;
		private var steper:NumericStepper;
		private var confirm:Button;
		private var closeBtn:UIComponent;
		private var handler:Function;
		private var type:int;
		
		public function PetNumberSteper()
		{
			this.width=152;
			this.height=55;
			Style.setRectBorder(this);
			txt=ComponentUtil.createTextField("", 6, 6, null, 120, 22, this);
			steper=new NumericStepper;
			steper.x=8;
			steper.y=27;
			steper.minnum=1;
			addChild(steper);
			confirm=ComponentUtil.createButton("确定", 84, 27, 60, 24, this);
			confirm.addEventListener(MouseEvent.CLICK, onClick);
			closeBtn=new UIComponent;
			closeBtn.buttonMode=true
			closeBtn.bgSkin=Style.getButtonSkin("close_1skin", "close_2skin", "close_3skin", null, GameConfig.T1_UI)
			closeBtn.x=125;
			closeBtn.y=4;
			addChild(closeBtn);
			closeBtn.addEventListener(MouseEvent.CLICK, onClickClose);
			this.visible=false;
		}
		
		public function reset(px:Number, py:Number, max:int, type:int, func:Function):void
		{
			this.x=px;
			this.y=py;
			steper.maxnum=max;
			steper.value=max;
			this.visible=true;
			handler=func;
			this.type=type;
			switch (type)
			{
				case 1:
					txt.text="请输入增加的力量点";
					break;
				case 2:
					txt.text="请输入增加的智力点";
					break;
				case 3:
					txt.text="请输入增加的敏捷点";
					break;
				case 4:
					txt.text="请输入增加的精神点";
					break;
				case 5:
					txt.text="请输入增加的体质点";
					break;
				default:
					txt.text="请输入增加的属性点";
					break;
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			handler.apply(null, [this.type,true,steper.value]);
			this.visible=false;
		}
		
		private function onClickClose(e:MouseEvent):void
		{
			this.visible=false;
		}
	}
}