package modules.jail.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.jail.JailModule;
	
	public class JailDonateView extends BasePanel
	{
		private var goldInput:TextInput;
		private var resultTxt:TextField;
		private var sureBtn:Button;
		private var cancelBtn:Button;
		
		public function JailDonateView(key:String=null)
		{
			super(key);
			initView();
		}
		
		private function initView():void
		{			
			this.title = "捐献建设费";
			this.titleAlign = 2;
			this.width = 350;
			this.height = 140;
			this.x = (GlobalObjectManager.GAME_WIDTH - this.width) / 2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			
			var dataTxt:String = "     捐献监狱建设费用，可以减轻你的PK点。请输入你要捐献的数额。";
			var dataTxt2:String = "     捐献";
			var dataTxt3:String = "元宝，洗清pk值<font color=\"#FF0000\"> 0 </font>点。";
			
			var txtField:TextField = ComponentUtil.createTextField(dataTxt, 15, 10, null, 320, 50, this);
			var txtField2:TextField = ComponentUtil.createTextField(dataTxt2, 15, 40, null, 70, 20, this);
			resultTxt = ComponentUtil.createTextField("", 127, 40, null, 200, 20, this);
			txtField.multiline = true;
			txtField.wordWrap = true;
			resultTxt.htmlText = dataTxt3;
			
			goldInput = new TextInput;
			goldInput.x = 65;
			goldInput.y = 40;
			goldInput.height = 21;
			goldInput.width = 60;
			goldInput.restrict = "0-9";
			goldInput.mouseEnabled = true;
			goldInput.textField.selectable = true;
			goldInput.maxChars = 8;
			goldInput.addEventListener(Event.CHANGE, onNumChange);
			addChild(goldInput);
			
			sureBtn = ComponentUtil.createButton("确定", 100, 70, 60, 20, this);
			sureBtn.addEventListener(MouseEvent.CLICK, sureJailDonate);
			sureBtn.enabled = false;
			cancelBtn = ComponentUtil.createButton("取消", 185, 70, 60, 20, this);
			cancelBtn.addEventListener(MouseEvent.CLICK, cancelJailDonate);
		}
		
		private function onNumChange(e:Event):void
		{
			if (goldInput.text == "" || int(goldInput.text) <= 0) {
				resultTxt.htmlText = "元宝，洗清pk值<font color=\"#FF0000\"> 0 </font>点。";
				sureBtn.enabled = false;
			} else {
				resultTxt.htmlText = "元宝，洗清pk值<font color=\"#FF0000\"> " + int(goldInput.text) + " </font>点。";
				sureBtn.enabled = true;
			}
		}
		
		private function sureJailDonate(e:MouseEvent):void
		{
			var gold:int = int(goldInput.text);
			if (gold <= 0) {
				BroadcastSelf.logger("捐献失败，捐献元宝为空");
			} else {
				JailModule.getInstance().doJailDonate2(gold);
			}
			
			goldInput.text = "";
			sureBtn.enabled = false;
			resultTxt.htmlText = "元宝，洗清pk值<font color=\"#FF0000\"> 0 </font>点。";
			this.closeWindow();
		}
		
		private function cancelJailDonate(e:Event):void
		{
			goldInput.text = "";
			sureBtn.enabled = false;
			resultTxt.htmlText = "元宝，洗清pk值<font color=\"#FF0000\"> 0 </font>点。";
			this.closeWindow();
		}
		
		override public function closeWindow(save:Boolean=false):void
		{
			super.closeWindow(save);
			goldInput.text = "";
			sureBtn.enabled = false;
			resultTxt.htmlText = "元宝，洗清pk值<font color=\"#FF0000\"> 0 </font>点。";
		}
	}
}