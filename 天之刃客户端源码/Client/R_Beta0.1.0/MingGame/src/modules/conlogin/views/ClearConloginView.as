package modules.conlogin.views
{
	import com.common.Captcha;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.conlogin.ConloginModule;
	
	public class ClearConloginView extends BasePanel
	{
		private var _captcha:Captcha;
		private var _input:TextInput;
		private var _confirm:Button;
		
		public function ClearConloginView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			this.width = 400;
			this.height = 147;
			this.x = (GlobalObjectManager.GAME_WIDTH - this.width) / 2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			this.title = "提示";
			this.titleAlign = 2;
			this.addEventListener(WindowEvent.OPEN, openHandler);
			
			var bg:Sprite = Style.getBlackSprite(382, 108);
			bg.x = 10;
			addChild(bg);
			
			var glow:GlowFilter = new GlowFilter(0x000000,1,2,2);
			
			var str:String = "<font color='#ff0000'>危险操作！</font>清零后本次奖励不可领。你确定要把连续登录变为一天吗？";
			var tf:TextField = ComponentUtil.createTextField("", 15, 10, null, 400, 40, this);
			tf.filters = [glow];
			tf.htmlText = str;
			
			ComponentUtil.createTextField("请输入验证码：", 68, 40, null, 100, 20, this).filters = [glow];			
			_input = ComponentUtil.createTextInput(158, 40, 70, 20, this);
			_input.addEventListener(Event.CHANGE, inputChangeHandler);
			_input.restrict = "0-9";
			_input.maxChars = 5;
			
			_confirm = ComponentUtil.createButton("确定", 126, 80, 60, 20, this);
			_confirm.addEventListener(MouseEvent.CLICK, confirmHandler);
			var cancel:Button = ComponentUtil.createButton("取消", 216, 80, 60, 20, this);
			cancel.addEventListener(MouseEvent.CLICK, cancelHandler);
			
			_captcha = new Captcha();
			_captcha.x = 238;
			_captcha.y = 37;
			addChild(_captcha);
		}
		
		private function openHandler(e:Event):void
		{
			_confirm.enabled = false;
		}
		
		private function inputChangeHandler(e:Event):void
		{
			_confirm.enabled = false;
			if (_input.text == _captcha.captcha)
				_confirm.enabled = true;
		}
		
		private function confirmHandler(e:Event):void
		{
			ConloginModule.getInstance().clearConloginDaysRequest();
		}
		
		private function cancelHandler(e:Event):void
		{
			WindowManager.getInstance().removeWindow(this);
		}
	}
}