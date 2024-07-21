package modules.tourist.views {
	import com.common.FilterCommon;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.tourist.TouristModule;

	public class TouristRegPanel extends BasePanel{
		
		private static const MIN_CHAR_LEN:int=6;
		private static const MAX_CHAR_LEN:int=20;
		
		private var emailReg:RegExp = /^.+@.+\..{2,3}$/;
		private var nameReg:RegExp = /^[A-Za-z0-9]+$/;
		
		private var nameInput:TextInput;
		private var passInput:TextInput;
		private var emailInput:TextInput;
		private var sendBtn:Button;
		private var nameTipTF:TextField;
		private var emailTipTF:TextField;
		private var passTipTF:TextField;
		private var repassInput:TextInput;
		private var repassTipTF:TextField;
		
		public function TouristRegPanel() {
			initView();
		}
		
		private function initView():void{
			title="注册";
			addContentBG(8,8,0);
			width=360;
			height=300;
			var startX:int=90;
			var startY:int=30;
			var landing:int=22;
			nameInput = createTextInput("账号：",startX,startY);
			nameInput.addEventListener(FocusEvent.FOCUS_OUT,onNameInputFocusOut);
			nameTipTF = ComponentUtil.createTextField("",nameInput.x+nameInput.width+10,nameInput.y+1,null,100,24,this);
			
			passInput = createTextInput("密码：",startX,startY+landing);
			passInput.addEventListener(FocusEvent.FOCUS_OUT,onPassInputFocusOut);
			passTipTF = ComponentUtil.createTextField("",passInput.x+passInput.width+10,passInput.y+1,null,100,24,this);
			repassInput = createTextInput("重新输入密码：",startX,startY+landing*2);
			repassInput.addEventListener(FocusEvent.FOCUS_OUT,onRePassInputFocusOut);
			repassTipTF = ComponentUtil.createTextField("",repassInput.x+repassInput.width+10,repassInput.y+1,null,100,24,this);
			emailInput = createTextInput("邮箱：",startX,startY+landing*3);
			emailInput.addEventListener(FocusEvent.FOCUS_OUT,onEmailInputFocusOut);
			emailTipTF = ComponentUtil.createTextField("",emailInput.x+emailInput.width+10,emailInput.y+1,null,100,24,this);
			sendBtn = ComponentUtil.createButton("注册",60,startY+landing*3,75,24,this);
			sendBtn.addEventListener(MouseEvent.CLICK,onSendBtnClickHandler);
		}
		
		private function onNameInputFocusOut(event:FocusEvent):void{
			if(checkName()){
				TouristModule.getInstance().verifyUserName(nameInput.text);
			}
		}
		
		private function onEmailInputFocusOut(event:FocusEvent):void{
			if(checkEmail()){
				TouristModule.getInstance().verifyEmail(emailInput.text);
			}
		}
		
		private function onPassInputFocusOut(event:FocusEvent):void{
			checkPass();
		}
		
		private function onRePassInputFocusOut(event:FocusEvent):void{
			isSamePass();
		}
		
		private function onSendBtnClickHandler(event:MouseEvent):void{
			if(checkName() && checkEmail() && checkPass()){
				TouristModule.getInstance().reg(escape(nameInput.text),escape(passInput.text),escape(emailInput.text));
			}
		}
		
		private function checkEmail():Boolean{
			if (emailInput.text.match(emailReg)){
				emailTipTF.htmlText = HtmlUtil.font("正在验证...","#FF00FF");
				return true;
			}else{
				emailTipTF.htmlText = HtmlUtil.font("请检查您的电子邮箱格式","#FF0000");
				return false;
			}
			return true;
		}
		
		private function checkName():Boolean{
			if(nameInput.text.length == 0){
				nameTipTF.htmlText = HtmlUtil.font("请填入用户名称","#FF0000");
			}
			if(nameInput.text.length < MIN_CHAR_LEN || nameInput.text.length > MAX_CHAR_LEN){
				nameTipTF.htmlText = HtmlUtil.font("用户名请用字母或数字，字数6到20之间","#FF0000");
				return false;
			}
			if(nameInput.text.match(nameReg)){
				nameTipTF.htmlText = HtmlUtil.font("正在验证...","#FF00FF");
				return true;
			}else{
				nameTipTF.htmlText = HtmlUtil.font("用户名请用字母或数字，字数6到20之间","#FF0000");
				return false;
			}
			return true;
		}
		
		private function checkPass():Boolean{
			if(passInput.text.length < MIN_CHAR_LEN || passInput.text.length > MAX_CHAR_LEN){
				passTipTF.htmlText = HtmlUtil.font("密码长度不对，请输入6-20位长度的密码","#FF0000");
				return false;
			}
			if(passInput.text.match(nameReg)){
				passTipTF.htmlText = HtmlUtil.font("正确","#00FF00");
				return true;
			}else{
				passTipTF.htmlText = HtmlUtil.font("请用字母或数字，字数6到20之间","#FF0000");
				return false;
			}
			return true;
		}
		
		private function isSamePass():Boolean{
			if(repassInput.text == passInput.text){
				repassTipTF.htmlText =  HtmlUtil.font("正确","#00FF00");
			}else{
				repassTipTF.htmlText = HtmlUtil.font("两次密码不一致","#ff000");
				return false;
			}
			return false;
		}
		
		private function createTextInput(proName:String, startX:int, startY:int):TextInput {
			var title:TextField=ComponentUtil.createTextField(proName, startX, startY, Style.themeTextFormat, NaN, 20, this);
			title.textColor=0xfffd4b;
			title.filters=FilterCommon.FONT_BLACK_FILTERS;
			title.width=title.textWidth + 4;
			var textInput:TextInput=ComponentUtil.createTextInput(startX + title.width + 5, startY, 80, 25, this);
			textInput.textField.textColor=0xffb14b;
			textInput.leftPadding=8;
			return textInput;
		}
		
		public function reset():void{
			
		}
		
		public function verifyEmailCallBack(state:int):void{
			switch(state){
				case TouristModule.VERIFY_SUCC:
					emailTipTF.htmlText = HtmlUtil.font("正确","#00ff00");
					break;
				case TouristModule.VERIFY_ERROR:
					emailTipTF.htmlText = HtmlUtil.font("Email已存在","#ff0000");
					break;
				case TouristModule.VERIFY_ERROR_PARAM:
					break;
				case TouristModule.VERIFY_ERROR_REG:
					break;
				case TouristModule.VERIFT_PAUSE:
					break;
			}
		}
		
		public function verifyUserNmaeCallBack(state:int):void{
			switch(state){
				case TouristModule.VERIFY_SUCC:
					emailTipTF.htmlText = HtmlUtil.font("正确","#00ff00");
					break;
				case TouristModule.VERIFY_ERROR:
					emailTipTF.htmlText = HtmlUtil.font("用户名已存在","#ff0000");
					break;
				case TouristModule.VERIFY_ERROR_PARAM:
					break;
				case TouristModule.VERIFY_ERROR_REG:
					break;
				case TouristModule.VERIFT_PAUSE:
					break;
			}
		}
		
		public function regCallBack(state:int):void{
			switch(state){
				case TouristModule.REG_SUCC:
					break;
				case TouristModule.ERROR_PARAM:
					Tips.getInstance().addTipsMsg("注册失败,请检查信息是否正确");
					break;
				case TouristModule.ERROR_USERNAME:
					Tips.getInstance().addTipsMsg("注册失败,用户名错误");
					break;
				case TouristModule.ERROR_EMAIL:
					Tips.getInstance().addTipsMsg("注册失败,Email错误");
					break;
				case TouristModule.ERROR_TIME_OUT:
					Tips.getInstance().addTipsMsg("注册失败,验证超时");
					break;
				case TouristModule.ERROR_REG:
					Tips.getInstance().addTipsMsg("注册失败,验证失败");
					break;
				case TouristModule.ERROR_PAUSE:
					Tips.getInstance().addTipsMsg("注册失败,暂停注册");
					break;
				case TouristModule.ERROR:
					Tips.getInstance().addTipsMsg("注册失败,错误代号00");
					break;
			}
		}
	}
}