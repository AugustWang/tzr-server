package modules.family.views
{	
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.events.ComponentEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.style.StyleManager;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.KeyWord;
	import modules.family.FamilyConstants;
	import modules.family.FamilyModule;

	public class CreateFamilyPanel extends DragUIComponent
	{
		private var titleField:TextField;
		private var needMoney:TextField;
		private var familyName:TextField;
		private var familyInput:TextInput;
		private var btn_ok:Button;
		private var btn_cancel:Button;
		private var checkJoin:CheckBox;
		public function CreateFamilyPanel()
		{
			super();
			init();
		}
		
		private function init():void{
			width = 280;
			height = 154;
			
			var tf:TextFormat = StyleManager.textFormat;
			tf.bold = true;
			tf.color = 0x3DEA42;
			tf.size = 14;
			titleField = ComponentUtil.createTextField("创建门派",110,10,tf,200,NaN,this);
			titleField.mouseEnabled = false;
			
			var tf1:TextFormat = StyleManager.textFormat;
			tf1.color = 0x3DEA42;
			needMoney = ComponentUtil.createTextField("",30,32,tf1,200,NaN,this);
			needMoney.htmlText = "需要：50不绑定元宝";
			needMoney.mouseEnabled = false;
			
			familyName = ComponentUtil.createTextField("门派名称：",30,60,tf1,200,NaN,this);
			familyName.mouseEnabled = false;
			
			familyInput = new TextInput();
			familyInput.addEventListener(ComponentEvent.ENTER,onEnter);
			familyInput.restrict = "[0-9a-zA-Z][\u4E00-\u9FA5]";
			familyInput.maxChars = 7;
			familyInput.width = 130;
			familyInput.x = 105;
			familyInput.y = 60;
			addChild(familyInput);
			
			if(!checkJoin){
				checkJoin = new CheckBox();
				checkJoin.space = 2;
				checkJoin.text = "邀请好友/队友/同门加入门派";
				checkJoin.x = familyName.x;
				checkJoin.y = 90;
				checkJoin.textFormat = new TextFormat("Tahoma",12,0xfaf106);
				checkJoin.width = 120;
				checkJoin.selected = true;
				addChild(checkJoin);
			}	
		//	checkJoin.addEventListener(Event.CHANGE,onSelected);	
			btn_ok = ComponentUtil.createButton("确定",30,120,60,25,this,wrapperButton);
			btn_ok.addEventListener(MouseEvent.CLICK,onOKhandler);
			
			btn_cancel = ComponentUtil.createButton("取消",190,120,60,25,this,wrapperButton);
			btn_cancel.addEventListener(MouseEvent.CLICK,onCancelhandler);
			
			addEventListener(Event.ADDED_TO_STAGE,onAddedToState);
		}
	
			
		private function onAddedToState(event:Event):void{
			familyInput.setFocus();
		}
		
		private function onEnter(event:ComponentEvent):void{
			onOKhandler();
		}
		
		private function onOKhandler(event:MouseEvent=null):void{
			var text:String = familyInput.text;
			if(StringUtil.trim(text).length < 2){
				Alert.show("门派名称至少为2个字符!","温馨提示",null,null,"确定","",null,false);
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
				Alert.show("新名称不能包含如下字符："+HtmlUtil.font(" "+matchResult+" ","#ff00ff")+"!","温馨提示",null,null,"确定","",null,false);
				return;
			}
			FamilyModule.getInstance().createFamily(text,checkJoin.selected);
			onCancelhandler();
		}
		
		private function onCancelhandler(event:MouseEvent=null):void{
			WindowManager.getInstance().closeDialog(this);
		}
	}
}