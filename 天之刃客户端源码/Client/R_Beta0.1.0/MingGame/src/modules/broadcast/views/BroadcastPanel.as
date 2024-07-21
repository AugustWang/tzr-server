package modules.broadcast.views
{
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	public class BroadcastPanel extends BasePanel
	{
		private var _messages:Array;
		private var scrollText:VScrollText;
		public function BroadcastPanel()
		{
			super();
			addEventListener(WindowEvent.OPEN,onOpenHandler);
		}
		
		override protected function init():void{
			title = "系统消息";
			this.width = 280;
			this.height = 330;
			
			var textBG:UIComponent =  ComponentUtil.createUIComponent(8,0,width - 16,height - 54,Style.getPanelContentBg());
			addChild(textBG);
			
			scrollText = new VScrollText();
			scrollText.textField.textColor = 0xffffff;
			scrollText.direction = ScrollDirection.RIGHT;
			scrollText.verticalScrollPolicy = ScrollPolicy.AUTO;
			scrollText.x = 4;
			scrollText.y = 4;
			scrollText.width = textBG.width - 4;
			scrollText.height = textBG.height - 12;
			textBG.addChild(scrollText);
		}
		
		public function set messages(values:Array):void{
			_messages = values;	
			_isUpdate = true;
		}
		
		private function onOpenHandler(event:WindowEvent):void{
			if(_isUpdate){
				update()
			}	
		}
		
		private var _isUpdate:Boolean = false;
		public function update():void{
			if(parent){
				if(_messages.length > 100){
					_messages.splice(0,10);
				}
				scrollText.htmlText = _messages.join("\n");
				scrollText.validateNow();
				if(scrollText.vscrollBar){
					scrollText.vScrollPosition = scrollText.vscrollBar.maxScrollPosition;
				}
			}else{
				_isUpdate = true;
			}
		}
	}
}