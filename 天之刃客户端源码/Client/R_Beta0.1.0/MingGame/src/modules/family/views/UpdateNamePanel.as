package modules.family.views
{
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.KeyWord;
	import modules.family.FamilyConstants;
	import modules.family.FamilyModule;
	
	public class UpdateNamePanel extends BasePanel
	{
		private var newName:TextField;
		private var newNameInput:TextInput;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		public var roleId:int;
		public var titleName:String;
		public function UpdateNamePanel(key:String=null)
		{
			super(key);
			this.width = 220;
			this.height = 120;
			this.title = "修改昵称";
			this.titleAlign = 2;
			
			newName = ComponentUtil.createTextField("新称号：",20,20,null,200,25,this);
			newName.textColor = 0x3DEA42;
			newName.mouseEnabled = false;
			
			newNameInput = new TextInput();
			newNameInput.addEventListener(ComponentEvent.ENTER,onEnter);
			newNameInput.restrict = "[0-9a-zA-Z][\u4E00-\u9FA5]";
			newNameInput.maxChars = 7;
			newNameInput.width = 100;
			newNameInput.x = 80;
			newNameInput.y = 20;
			addChild(newNameInput);
			
			btn_ok = ComponentUtil.createButton("确定",30,50,60,25,this);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",140,50,60,25,this);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToState);
			
		}
		
		private function onAddedToState(event:Event):void{
			newNameInput.setFocus();
		}
		
		private function onEnter():void{
			onOKhandler();
		}
		
		private var vip:String = "vip";
		private function onOKhandler(event:MouseEvent=null):void{
			var text:String = StringUtil.trim(newNameInput.text);
			if(text.toLowerCase().indexOf(vip) != -1){
				Alert.show("新称号不能包含如下字符：<font color='#ff00ff'>VIP</font>","温馨提示",null,null,"确定","",null,false);
				return;
			}
			if(StringUtil.trim(text).length < 2){
				Alert.show("新名称至少为2个字符!","温馨提示",null,null,"确定","",null,false);
				return;
			}
			if(KeyWord.instance().hasUnRegisterString(text)){
				var str:String = KeyWord.instance().takeUnRegisterString(text);	
				Alert.show(str,"温馨提示",null,null,"确定","",null,false);
				return;
			}
			FamilyConstants.FILTER_WORDS.lastIndex = 0;
			var result:* = FamilyConstants.FILTER_WORDS.exec(text);
			var matchResult:String = result ? result[0] : null;
			if(matchResult){
				Alert.show("新称号不能包含如下字符："+HtmlUtil.font(" "+matchResult+" ","#ff00ff")+"","温馨提示",null,null,"确定","",null,false);
				return;
			}
			if(text != titleName){
				FamilyModule.getInstance().updateTitle(roleId,text);
			}
			closeWindow();
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			closeWindow();
		}
	}
}