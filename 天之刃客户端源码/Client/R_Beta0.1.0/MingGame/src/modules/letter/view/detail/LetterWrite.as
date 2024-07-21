package modules.letter.view.detail
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import modules.broadcast.KeyWord;
	import modules.broadcast.views.Tips;
	import modules.letter.LetterModule;
	import modules.letter.messageBody.WriteLetterData;
	import modules.letter.view.FamilySelectView;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_letter_family_send_tos;
	import proto.line.m_letter_p2p_send_tos;
	import proto.line.p_letter_goods;
	
	public class LetterWrite extends BaseLetterDetail
	{
		private var sendBtn:Button;
		private var cancelBtn:Button;
		private var tipTxt:TextField;
		public var name_txtInput:TextInput;
		public var money_txt:TextField;
		
		public function LetterWrite(){
			super("LetterWrite",360, 120);
			
			addImageTitle("title_write");
			//addContentBG(4);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
			initView();
			initType();
		}
		
		/**
		 *保证光标 
		 * @param evt
		 * 
		 */		
		private function onAddToStageHandler(evt:Event):void{
			if(name_txtInput && name_txtInput.text.length == 0){
				name_txtInput.setFocus();
			}else{
				content.setFocus();
			}
		}
		
		public function setReceiver(name:String):void{
			if(name != null){
				name_txtInput.text = name;
				this.addEventListener(Event.ADDED_TO_STAGE,onAddToStageHandler);
			}
		}
		
		public function setContent(textContent:String):void{
			content.text = textContent;
		}
		
		public function reset():void{
			name_txtInput.text = "";
			type_txt.text = "";
			content.text = "";
			
			accessory.returnData();
			accessory.reset();
		}
		
		private function initType():void{
			
			//收信人的背景
			this.contentBackUI.height = 275;
			this.contentBackUI.y = 40;
			
			sender_desc_txt.htmlText = "<font color='#AFE1EC'>收件人：</font>";
			sender_desc_txt.filters = FilterCommon.FONT_BLACK_FILTERS;
			sender_desc_txt.y = 13;
			name_txtInput = new TextInput();
			this.addChild(name_txtInput);
			name_txtInput.x = sender_desc_txt.x + sender_desc_txt.textWidth + 5;
			name_txtInput.y = sender_desc_txt.y;
//			name_txtInput.maxChars = 7;
			name_txtInput.width = 243;
			name_txtInput.height = 25;
			name_txtInput.setFocus();
			
			//内容的背景
			content.height = 225;
			content.y = contentBackUI.y +1;
			tipTxt = ComponentUtil.createTextField("温馨提示：文明聊天，开心游戏",content.x,this.contentBackUI.y + contentBackUI.height + 5,new TextFormat("Tahoma",12,0xffcc00),180,30,this);
			tipTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			cancelBtn = ComponentUtil.createButton("取消",tipTxt.x + tipTxt.width,tipTxt.y,60,25,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,onCancelClickHandler)
			sendBtn = ComponentUtil.createButton("发送",cancelBtn.x + cancelBtn.width + 5,cancelBtn.y,60,25,this);
			sendBtn.addEventListener(MouseEvent.CLICK,writeHandler);
			
			money_txt = ComponentUtil.createTextField("",this.contentBackUI.x + this.contentBackUI.width/2,this.contentBackUI.y + this.contentBackUI.height - 20,null,160,30,this);
			
			this.removeChild(sender_txt);
			this.removeChild(type_desc_txt);
			this.removeChild(lineUI);
		}
		
		private function onCancelClickHandler(evt:MouseEvent):void{
			accessory.returnData();
			money_txt.text = "";
			WindowManager.getInstance().removeWindow(this);
		}
		private function initView():void{
			accessory = new AccessoryView(AccessoryView.LETTER_WRITE);
			addChild(accessory);
			accessory.setClickFun(clickHandler,"addAttachBtn");
		}
		
		public function disposeAccessory():void{
			accessory.reset();
		}
		
		private function clickHandler(evt:MouseEvent):void{
			PackManager.getInstance().popUpWindow(PackManager.PACK_1,this.x + this.width, this.y,false); 
		}
		/**
		 *发送信件到服务端 
		 * 
		 */		
		private function sendToService():void{
			if(this.name_txtInput.enabled == true){
				var vo:m_letter_p2p_send_tos = new m_letter_p2p_send_tos();
				vo.receiver = name_txtInput.text;
				
				vo.text = KeyWord.instance().replace(content.text);
				
				var temp:BaseItemVO = accessory.getData();
				if(temp != null)
				{
					var good:p_letter_goods = new p_letter_goods;
					good.goods_id = temp.oid;
					good.num = temp.num;
					vo.goods_list = [good];
				}
				
				var write:WriteLetterData = new WriteLetterData();
				write.writeLetter(vo, this, temp);
			}else{
				var familiyLetterVo:m_letter_family_send_tos = new m_letter_family_send_tos();
				familiyLetterVo.range = FamilySelectView.range;
				familiyLetterVo.text = name_txtInput.text;
				
				familiyLetterVo.text = KeyWord.instance().replace(content.text);
				
				LetterModule.getInstance().sendFamilyLetter(familiyLetterVo);
				this.closeWindow();
			}
		}
		
		private var time:int = 0;
		private function writeHandler(evt:Event):void{
			if(getTimer() - time > 500){
				if(check()){
					if(KeyWord.instance().hasUnRegisterString(content.text)){
						var string:String=KeyWord.instance().takeUnRegisterString(content.text)
						Alert.show("信件内容"+string +"是否继续发送信件，继续发送信件非法字符将被屏蔽。","提示",function okHandler():void{
							sendToService();
						});
					}else{
						sendToService();
					}
				}
				time = getTimer();
			}
		}
		
		private function check():Boolean{
			if(name_txtInput.text == "" ||name_txtInput.text == null)
			{
				Alert.show("请填写收件人后再发送！","提示",null,null,"确定","取消",null,false);
				return false;
			}
			if(name_txtInput.text.length < 2)
			{
				Alert.show("收件人名字少于两个字符！", "提示",null,null,"确定","取消",null,false);
				return false;
			}
			if(content.text == "" ||content.text == null)
			{
				
				Alert.show("请填写内容后再发送！", "提示",null,null,"确定","取消",null,false);
				return false;
			}
			if(content.text.length< 2)
			{
				Alert.show("信件内容过短！", "提示",null,null,"确定","取消",null,false);
				return false;
			}
			if(name_txtInput.text == GlobalObjectManager.getInstance().user.base.role_name)
			{
				Alert.show("不能给自己发信！", "提示",null,null,"确定","取消",null,false);
				return false;
			}
			if(accessory.getData()!=null && accessory.getData().bind){
				Alert.show("该物品绑定，不能发送！","提示",null,null,"确定","取消",null,false);
				return false;
			}
			
			return true;
		}
		
		
		override protected function closeHandler(event:CloseEvent=null):void{
			super.closeHandler(event);
			
			accessory.returnData();
			money_txt.text = "";
		}
	}
}