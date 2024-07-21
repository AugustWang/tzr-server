package modules.greenHand.view
{
	
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.greenHand.GreenHandModule;
	
	import mx.utils.StringUtil;
	
	public class GensWindow extends BasePanel
	{
		public function GensWindow(key:String=null)
		{
			super("GensWindow");
			this.addEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
		}
		
		private function onAddToStageHandler(evt:Event):void{
			if(input){
				input.setFocus();
			}
		}
		
		private var descTxt:TextField;
		private var input:TextInput;
		private var sureBtn:Button;
		override protected function init():void{
			this.width = 385;
			this.height = 155;
			
			var bg:UIComponent=new UIComponent();
			bg.x=5;
			bg.height=121;
			bg.width=375;
			addChild(bg);
			Style.setNewBorderBgSkin(bg);
			
			this.x = (1002 - this.width)/2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height)/2;
			
			this.title = "门派卡兑换礼包";
			
			descTxt = ComponentUtil.createTextField("                 使用门派卡激活码，可以领取一个神秘大礼包!",20,5,null,350,40,this);
			descTxt.wordWrap = true;
			descTxt.multiline = true;
			descTxt.textColor = 0xffcc00;
			
			var activeTxt:TextField = ComponentUtil.createTextField("请输入激活码：",descTxt.x + 70,descTxt.y + descTxt.height,null,120,26,this);
			activeTxt.textColor = 0xff0000;
				
			input = new TextInput();
			this.addChild(input);
			input.x = activeTxt.x + activeTxt.textWidth + 5;
			input.y = activeTxt.y;
			
			sureBtn = ComponentUtil.createButton("确定",this.width/3,input.y + input.height+20,65,25,this);
			sureBtn.addEventListener(MouseEvent.CLICK,onClickHandler);
			var cancelBtn:Button = ComponentUtil.createButton("取消",sureBtn.x + sureBtn.width + 5,sureBtn.y,65,25,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,onClickHandler);
		}
		
		private function onClickHandler(evt:MouseEvent):void{
			if(Button(evt.currentTarget).label == "确定"){
				var rep:RegExp = /^[A-Za-z0-9]+$/g;
				var code:String = StringUtil.trim(input.text);
				if(rep.test(code)){
					GreenHandModule.getInstance().requestActivationCode(code);
					Button(evt.currentTarget).enabled = false;
				}else{
					Tips.getInstance().addTipsMsg("激活码不正确，请重新输入！");
				}
				input.text = "";
			}else{
				if(input.text.length !=0){
					input.text = "";
				}
				WindowManager.getInstance().removeWindow(this);
			}
		}
		
		public function dataFromService(data:Object):void{
			sureBtn.enabled = true;
		}
	}
}