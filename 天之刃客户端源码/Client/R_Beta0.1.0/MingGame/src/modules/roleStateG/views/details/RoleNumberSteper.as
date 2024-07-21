package modules.roleStateG.views.details
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class RoleNumberSteper extends UIComponent
	{
		public static const EVENT_ADD_PROPRETYS:String="EVENT_ADD_PROPRETYS";
		private var txt:TextField;
		private var steper:NumericStepper;
		private var confirm:Button;
		private var closeBtn:UIComponent;
		private var handler:Function;
		private var type:int;
		private var add:Boolean;
		
		public function RoleNumberSteper()
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
			closeBtn.bgSkin=Style.getButtonSkin("close_skin","close_overSkin","close_downSkin",null, GameConfig.T1_UI)
			closeBtn.x=125;
			closeBtn.y=4;
			addChild(closeBtn);
			closeBtn.addEventListener(MouseEvent.CLICK, onClickClose);
			this.visible=false;
		}
		
		public function reset(px:Number, py:Number, max:int, type:int,add:Boolean, func:Function):void
		{
			this.x=px;
			this.y=py;
			steper.maxnum=max;
			steper.value=max;
			this.visible=true;
			handler=func;
			this.type=type;
			this.add=add;
			switch(type){
				case 1:
					
					txt.text=add?"请输入增加的力量点":"请输入减少的力量点";
					break;
				case 2:
					txt.text=add?"请输入增加的智力点":"请输入减少的智力点";
					break;
				case 3:
					txt.text=add?"请输入增加的敏捷点":"请输入减少的敏捷点";
					break;
				case 4:
					txt.text=add?"请输入增加的精神点":"请输入减少的精神点";
					break;
				case 5:
					txt.text=add?"请输入增加的体质点":"请输入减少的体质点";
					break;
				default:
					txt.text=add?"请输入增加的属性点":"请输入减少的属性点";
					break;
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			handler.apply(null, [steper.value, this.type,this.add]);
			this.visible=false;
		}
		
		private function onClickClose(e:MouseEvent):void
		{
			this.visible=false;
		}
	}
}