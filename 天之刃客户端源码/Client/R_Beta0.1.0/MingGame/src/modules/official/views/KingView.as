package modules.official.views
{
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.chat.ChatModule;
	import modules.official.KingModule;
	
	public class KingView extends DragUIComponent
	{
		private var numStep:NumericStepper;
		private var numTxf:TextField;
		private var nameTxf:TextField;
		private var bantimes:TextField;
		private var btnOk:Button;
		private var btnCancel:Button;
		private var roleName:String;
		private var roleID:int;
		public function KingView()
		{
			super();
			initView();
			initEventListener();
			
		}
		
		private function initView():void
		{
			nameTxf = ComponentUtil.createTextField("",8,6,new TextFormat("Tahoma",20,0xffffff),175,23,this);
			bantimes = ComponentUtil.createTextField("",8,31,new TextFormat("Tahoma",20,0xffffff),175,23,this);
			numTxf = ComponentUtil.createTextField("", 45, 8, null, 160, 20, this);
			width = 223;
			height = 109;
			Style.setRectBorder(this);	
			nameTxf.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
			nameTxf.htmlText = HtmlUtil.font(HtmlUtil.bold("禁言"),"0XFFFFFF");
			numTxf.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
			
			
			bantimes.filters = [new GlowFilter(0x000000, 1, 2, 2, 20)];
			bantimes.htmlText = HtmlUtil.font(HtmlUtil.bold("分钟"),"0XFFFFFF");
			numStep = new NumericStepper();
			numStep.x = 45;
			numStep.y = 33;
			numStep.textFiled.restrict = "0-9";
			numStep.textFiled.maxChars=4;
			numStep.maxnum = 120;
			numStep.minnum = 1;
			numStep.stepSize = 1;
			numStep.textFiled.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
			numStep.value = 30;
			numStep.width = 160;
			addChild(numStep);
			btnOk = ComponentUtil.createButton("确定" ,8,75,52,25,this)
			Style.setRedBtnStyle(btnOk);
			btnCancel = ComponentUtil.createButton("取消" ,160,75,52,25,this)
			Style.setRedBtnStyle(btnCancel);	
		}
		
		private static var instance:KingView;
		
		public static function getInstance():KingView{
			if (instance == null) {
				instance=new KingView();
		    }
			return instance;
		}	
		
		private function upView():void{
			numTxf.htmlText = "<font color='#F6F5CD'>"+this.roleName+"</font>";
			numStep.value = 1;
			
		}	
		
		public function showView():void{
			WindowManager.getInstance().popUpWindow(this, WindowManager.UNREMOVE);
			this.x = ChatModule.getInstance().chat.x+ChatModule.getInstance().chat.width+10;
			this.y = ChatModule.getInstance().chat.y+10;
			this.numStep.textFiled.setFocus();
			this.numStep.textFiled.textField.setSelection(0,this.numStep.textFiled.textField.text.length);
		}
		
		public function setData(roleID:int,roleName:String):void
		{
			this.roleID = roleID;
			this.roleName = roleName;
			upView();
			
		}
		
		private function initEventListener():void
		{
			btnOk.addEventListener(MouseEvent.CLICK,onOkClick);
			btnCancel.addEventListener(MouseEvent.CLICK,onCancel);
		}
		
		private function onOkClick(event:Event):void{
			
			kingban();
		}

		private function onCancel(event:Event):void{
			closeView();
		}
		
		private function kingban():void
		{
			KingModule.getInstance().kingBan(this.roleID,this.roleName,this.numStep.value);
			closeView();
		}
		
		public function closeView():void{
			if(!this.parent){
				return;
			}else{
				this.parent.removeChild(this);
				WindowManager.getInstance().removeWindow(this);	
			}
		}
	}
}