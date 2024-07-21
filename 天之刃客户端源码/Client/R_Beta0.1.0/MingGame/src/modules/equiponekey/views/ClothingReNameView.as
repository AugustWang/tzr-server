package modules.equiponekey.views
{
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.KeyWord;
	import modules.equiponekey.views.items.ClothingItemVO;
	
	public class ClothingReNameView extends DragUIComponent
	{
		private var clothingItemVO:ClothingItemVO;
		private var call:Function;
		private var nameTxt:TextInput;
		public function ClothingReNameView()
		{
			super();
			init();			
		}
		
		private static var instance:ClothingReNameView;
		public static function getInstance():ClothingReNameView{
			if(instance == null){
				instance = new ClothingReNameView();
			}
			return instance;
		}
		
		private function init():void
		{
			this.width = 250;
			this.height = 120;
			
			showCloseButton = true;
			
			var txt:TextField = ComponentUtil.createTextField("为本套装命名？",15,20,null,NaN,NaN,this);
			txt.textColor = 0x3DEA42;
			
			nameTxt = new TextInput();
			nameTxt.width = 210;
			nameTxt.height = 22;
			nameTxt.restrict = "[0-9a-zA-Z][\u4E00-\u9FA5]";
			nameTxt.maxChars = 7;
			nameTxt.x = 18;
			nameTxt.y = 50;
			nameTxt.addEventListener(ComponentEvent.ENTER,onEnterHandler);
			addChild(nameTxt);
			
			var okBtn:Button = ComponentUtil.createButton("确定",33,80,65,26,this,wrapperButton);
			okBtn.addEventListener(MouseEvent.CLICK, onClick);
			
			var cancelBtn:Button = ComponentUtil.createButton("取消",152,80,65,26,this,wrapperButton);
			cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
		}
		
		public function show(call:Function,param:ClothingItemVO,x:Number=NaN,y:Number=NaN):void{
			this.call = call;
			this.clothingItemVO = param;
			WindowManager.getInstance().popUpWindow(this,WindowManager.UNREMOVE);
			if(isNaN(x) && isNaN(y)){
				WindowManager.getInstance().centerWindow(this);
			}	
			nameTxt.setFocus();
		}
		
		public function closeWindow():void{
			WindowManager.getInstance().removeWindow(this);
			instance.dispose();
			instance = null;
		}
		
		override protected function onCloseHandler(event:MouseEvent):void{
			closeWindow();
		}
		
		private function onEnterHandler(evt:ComponentEvent):void{
			reName();
		}
		
		private function onClick(evt:MouseEvent):void{
			reName();
		}
		
		private function onCancel(evt:MouseEvent):void{
			closeWindow();
		}
		
		private function reName():void{
			var text:String = nameTxt.text;
			if(text.length < 1){
				Alert.show("套装名称不能少于1个字符!","温馨提示",null,null,"确定","",null,false);
				return;
			}
			if(KeyWord.instance().hasUnRegisterString(text)){
				var str:String = KeyWord.instance().takeUnRegisterString(text);	
				Alert.show(str,"温馨提示",null,null,"确定","",null,false);
				return;
			}
			nameTxt.text = "";
			if(call != null){
				call.apply(null,[clothingItemVO,text]);
			}
			onCancel(null);
		}
	}
}