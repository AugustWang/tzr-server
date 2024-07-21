package modules.friend.views.friendsetting
{
	import com.components.alert.Alert;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TextArea;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * 消息设置
	 * @author
	 * 
	 */	
	public class TabMessageSetting extends Sprite
	{
		private var mess_tip_txt:TextField;
		private var online_checkBox:CheckBox;
		private var auto_checkBox:CheckBox;
		private var auto_reply_txt:TextField;
		private var reply_checkBox:CheckBox;
		private var addBtn:Button;
		private var modifyBtn:Button;
		private var delBtn:Button;
		private var list:List;
		private var defaultArr:Array = ["你好，我现在有事一会再联系","工作中,请勿打扰","我去吃饭了，一会再联系"];
		private var arr:Array = [];
		private var titleFormate:TextFormat = new TextFormat("Tahoma",14,0xffffff);
		
		private var old_online_bool:Boolean;//记录当前的状态
		private var old_auto_out_bool:Boolean;
		private var old_reply_bool:Boolean;
		private var old_arr:Array;
		public function TabMessageSetting()
		{
			super();
			var backUI:UIComponent = new UIComponent();
			this.addChild(backUI);
			Style.setBorderSkin(backUI);
			backUI.width = 440;
			backUI.height = 283;
			backUI.mouseChildren = backUI.mouseEnabled = false;
			init();
		}
		/**
		 *1.消息提示 
		 * 2.自动回复
		 */		
		private function init():void{
			for(var i:int =0;i<defaultArr.length;i++){
				arr.push(i+1+"  "+defaultArr[i]);
			}
			mess_tip_txt = ComponentUtil.createTextField("1.消息提示",10,this.y+5,titleFormate,100,30,this);
			mess_tip_txt.mouseEnabled = false;
			online_checkBox = ComponentUtil.createCheckBox("好友上线提醒",mess_tip_txt.x + 10,mess_tip_txt.y+mess_tip_txt.height-5,this);
			online_checkBox.selected = true;
			online_checkBox.addEventListener(MouseEvent.CLICK,function onlineHandler(evt:MouseEvent):void{
				FriendSettingConstants.friend_onlie_bool = online_checkBox.selected;
			} );
			auto_checkBox = ComponentUtil.createCheckBox("自动弹出信息",online_checkBox.x,online_checkBox.y+online_checkBox.height,this);
			auto_checkBox.addEventListener(MouseEvent.CLICK,function autoOutMessHandler(evt:MouseEvent):void{
				FriendSettingConstants.auto_outMess_bool = auto_checkBox.selected;
				old_auto_out_bool = !auto_checkBox.selected;
			});
			
			auto_reply_txt = ComponentUtil.createTextField("2.自动回复",mess_tip_txt.x,auto_checkBox.y+ auto_checkBox.height + 10,titleFormate,100,30,this);
			reply_checkBox = ComponentUtil.createCheckBox("离开、忙碌、请勿打扰时自动回复（50字以内）",auto_reply_txt.x + 10,auto_reply_txt.y + auto_reply_txt.height-5,this);
			reply_checkBox.selected = true;
			reply_checkBox.addEventListener(MouseEvent.CLICK,function replyHandler(evt:MouseEvent):void{
				FriendSettingConstants.auto_reply_bool = reply_checkBox.selected;
			});
			var contentUI:UIComponent = new UIComponent();
			this.addChild(contentUI);
			Style.setRectBorder(contentUI);
			contentUI.width = 300;
			contentUI.height = 140;
			contentUI.x = reply_checkBox.x;
			contentUI.y = reply_checkBox.y + reply_checkBox.height+5;
			contentUI.mouseChildren = contentUI.mouseEnabled = false;
			
			list = new List();
			this.addChild(list);
			list.width = 300;
			list.height = 140;
			list.x = contentUI.x;
			list.y = contentUI.y;
			list.verticalScrollPolicy = ScrollPolicy.ON;
			list.dataProvider = arr;
			list.selectedItem = arr[0];
			FriendSettingConstants.reply_content = arr[0];
			
			addBtn = ComponentUtil.createButton("添加",contentUI.x + contentUI.width + 5,contentUI.y,70,25,this);
			addBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			modifyBtn = ComponentUtil.createButton("修改",addBtn.x,addBtn.y + addBtn.height + 5,70,25,this);
			modifyBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			delBtn = ComponentUtil.createButton("删除",addBtn.x ,modifyBtn.y + modifyBtn.height + 5,70,25,this);
			delBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			if(evt.currentTarget.label == "添加"){
				addFun();
			}else if(evt.currentTarget.label == "修改"){
				if(list.selectedItem){
					modifyFun();
				}else{
					Alert.show("请选择你要修改的回复项","提示",null,null,"确定","取消",null,false);
				}
			}else if(evt.currentTarget.label == "删除"){
				if(list.selectedItem){
					delFun();
				}else{
					Alert.show("请选择你要删除的回复项","提示",null,null,"确定","取消",null,false);
				}
			}
		}
		
		//添加的操作
		private var addPanel:Panel;
		private var addTxt:TextArea;
		private function addFun():void{
			addPanel = new Panel();
			this.addChild(addPanel);
			addPanel.addEventListener(CloseEvent.CLOSE,closeHandler);
			addPanel.title = "添加自动回复";
			addPanel.titleAlign = 2;
			addPanel.width = 350;
			addPanel.height = 210;
			addPanel.x = (this.width - addPanel.width)/2;
			addPanel.y = (this.height - addPanel.height)/4;
			var txt:TextField = ComponentUtil.createTextField("回复内容（50字以内）",20,0,null,120,30,addPanel);
			txt.mouseEnabled = false;
			addTxt = new TextArea();
			addTxt.name = "addTxt";
			addTxt.addEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
			addPanel.addChild(addTxt);
			addTxt.width = 310;
			addTxt.height = 120;
			addTxt.x = (addPanel.width - addTxt.width)/2;
			addTxt.y = (addPanel.height - addTxt.height)/4;
			addTxt.textField.maxChars = 50;
			Style.setBorderSkin(addTxt);
			var sureBtn:Button = ComponentUtil.createButton("确定",addTxt.width/3,addTxt.y + addTxt.height+5,60,25,addPanel);
			sureBtn.addEventListener(MouseEvent.CLICK,sureHandler);
			var cancelBtn:Button = ComponentUtil.createButton("取消",sureBtn.x + sureBtn.width + 10,sureBtn.y,60,25,addPanel);
			cancelBtn.addEventListener(MouseEvent.CLICK,closeHandler);
		}
		
		private function onAddToStageHandler(evt:Event):void{
			if(evt.currentTarget.name == "addTxt"){
				if(addTxt){
					addTxt.setFocus();
				}
			}
		}
		
		private function closeHandler(evt:Event):void{
			if(addPanel && this.contains(addPanel)){
				this.removeChild(addPanel);
			}
			addPanel = null;
		}
		
		private function sureHandler(evt:MouseEvent):void{
			if(addTxt.text.length!=0){
				defaultArr.push(addTxt.text);
			}
			arr = [];
			arrUtil(addPanel);
		}
		
		//删除
		private function delFun():void{
			var index:int = list.selectedIndex;
			defaultArr.splice(index,1);
			arr = [];
			for(var n:int=0;n<defaultArr.length;n++){
				arr.push(n+1+"  "+defaultArr[n]);
			}
			list.dataProvider = arr;
		}
		
		//修改
		private var modifyPanel:Panel;
		private var modifyTxt:TextArea;
		private function modifyFun():void{
			modifyPanel = new Panel();
			this.addChild(modifyPanel);
			modifyPanel.addEventListener(CloseEvent.CLOSE,modifyCloseHandler);
			modifyPanel.title = "修改自动回复";
			modifyPanel.titleAlign = 2;
			modifyPanel.width = 350;
			modifyPanel.height = 210;
			modifyPanel.x = (this.width - modifyPanel.width)/2;
			modifyPanel.y = (this.height - modifyPanel.height)/4;
			var txt:TextField = ComponentUtil.createTextField("回复内容（50字以内）",20,0,null,120,30,modifyPanel);
			txt.mouseEnabled = false;
			modifyTxt = new TextArea();
			modifyTxt.name = "modifyTxt";
			modifyPanel.addChild(modifyTxt);
			modifyTxt.text = defaultArr[list.selectedIndex];
			modifyTxt.validateNow();
			modifyTxt.width = 310;
			modifyTxt.height = 120;
			modifyTxt.x = (modifyPanel.width - modifyTxt.width)/2;
			modifyTxt.y = (modifyPanel.height - modifyTxt.height)/4;
			modifyTxt.textField.maxChars = 50;
			modifyTxt.textField.alwaysShowSelection = true;
			modifyTxt.textField.setSelection(0,modifyTxt.text.length);
			Style.setBorderSkin(modifyTxt);
			var sureBtn:Button = ComponentUtil.createButton("确定",modifyTxt.width/3,modifyTxt.y + modifyTxt.height+5,60,25,modifyPanel);
			sureBtn.addEventListener(MouseEvent.CLICK,modifysureHandler);
			sureBtn.name = "modify";
			var cancelBtn:Button = ComponentUtil.createButton("取消",sureBtn.x + sureBtn.width + 10,sureBtn.y,60,25,modifyPanel);
			cancelBtn.addEventListener(MouseEvent.CLICK,modifyCloseHandler);
		}
		
		private function modifyCloseHandler(evt:Event):void{
			if(modifyPanel && this.contains(modifyPanel)){
				this.removeChild(modifyPanel);
			}
			modifyPanel = null;
		}
		
		private function modifysureHandler(evt:MouseEvent):void{
			if(modifyTxt.text.length!=0){
				defaultArr[list.selectedIndex] = modifyTxt.text;
			}
			arrUtil(modifyPanel);
		}
		
		private function arrUtil(view:Panel):void{
			arr = [];
			for(var n:int=0;n<defaultArr.length;n++){
				arr.push(n+1+"  "+defaultArr[n]);
			}
			if(this.contains(view)){
				this.removeChild(view);
			}
			list.dataProvider = arr;
		}
		/**
		 *取消后执行 
		 * @return 
		 * 
		 */		
		public function messageSettingCancel():void{
		}
	}
}