package modules.friend.views
{
	import com.common.Constant;
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.events.ComponentEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.TextInput;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.KeyWord;
	import modules.friend.FriendsModule;
	
	import proto.common.p_role_ext;

	public class FriendsHead extends Sprite
	{
		private var icon:Image;
		private var rolename:TextField;
		private var signText:TextField;
		private var signInput:TextInput;
		
		private var isNull:Boolean;
		public function FriendsHead()
		{
			super();
			init();
		}
		
		private function init():void
		{	
			mouseEnabled = false;
			var boxBg:Sprite = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			boxBg.x = 8;
			boxBg.mouseChildren = false;
			boxBg.buttonMode = boxBg.useHandCursor = true;
			boxBg.addEventListener(MouseEvent.CLICK,onOpenRoleWindow);
			addChild(boxBg);
			
			var head:int = GlobalObjectManager.getInstance().user.base.head;
			icon = new Image();
			icon.width = icon.height = 34;
			icon.source = GameConstant.getHeadImage(head);
			boxBg.addChild(icon);
			
			var tf:TextFormat = Constant.TEXTFORMAT_DEFAULT;
			rolename = ComponentUtil.createTextField(GlobalObjectManager.getInstance().user.base.role_name,52,0,tf,125);
			rolename.filters = FilterCommon.FONT_BLACK_FILTERS;
			addChild(rolename);
			
			signText = ComponentUtil.createTextField("",52,18,tf,148,18,this);
			signText.mouseEnabled = true;
			var currentSign:String = GlobalObjectManager.getInstance().user.ext.signature;
			isNull = false;
			if(currentSign == ""){
				isNull = true;				
				currentSign = "共铸我们的天之刃！"
			}
//			TextUtil.fitText(signText,currentSign,150);
			signText.htmlText = currentSign;
			signText.maxChars = 150;
			signText.borderColor = 0xffffff;
			signText.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverHandler);
			signText.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutHandler);
			signText.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
		}
		
		private function onOpenRoleWindow(event:MouseEvent):void{
			FriendsModule.getInstance().openFriendsSettings();
		}
		
		private function onMouseOverHandler(evt:MouseEvent):void{
			signText.border = true;
			//ToolTipManager.getInstance().show(signText.text);
			ToolTipManager.getInstance().show("点击编辑个性签名");
		}
		
		private function onMouseOutHandler(evt:MouseEvent):void{
			signText.border = false;
			ToolTipManager.getInstance().hide();
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			if(signInput == null){
				signInput = new TextInput();
				signInput.maxChars = 25;
				signInput.width = 148;
				signInput.height = 22;
				signInput.y = 18;
				signInput.x = 52;
				signInput.addEventListener(ComponentEvent.ENTER,onEnter);
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageDownHandler);
			if(isNull){
				signInput.text = "";
			}else{
				signInput.text = signText.text;
			}
			addChild(signInput);
			signInput.setFocus();
		}
		
		private function onStageDownHandler(event:MouseEvent):void{
			var target:DisplayObject = event.target as DisplayObject;
			if(!signInput.contains(target)){
				onEnter(null);
			}
		}
		
		private function removeSignTextInput():void{
			if(signInput.parent){
				signInput.parent.removeChild(signInput);
			}
		}
		
		private function onEnter(event:ComponentEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,onStageDownHandler);
			var sign:String = signText.text;
			var newsign:String;
			if(KeyWord.instance().hasUnRegisterString(StringUtil.trim(signInput.text))){
				newsign = KeyWord.instance().replace(StringUtil.trim(signInput.text));
			}else{
				newsign = StringUtil.trim(signInput.text);
			}
			if(GlobalObjectManager.getInstance().user.ext.signature != newsign){
				signInput.text = "";
				var ext:p_role_ext = new p_role_ext();
				ext.role_id = GlobalObjectManager.getInstance().user.base.role_id;
				if(newsign == ""){
					newsign = "共铸我们的天之刃！";
				}
				ext.signature = newsign;
				ext.birthday = GlobalObjectManager.getInstance().user.ext.birthday;
				ext.constellation = GlobalObjectManager.getInstance().user.ext.constellation;
				ext.province = GlobalObjectManager.getInstance().user.ext.province;
				ext.city = GlobalObjectManager.getInstance().user.ext.city;
				ext.sex = GlobalObjectManager.getInstance().user.ext.sex;
				
				//=======以下属性现在不需要=====
				ext.country = 0;
				ext.blog = "";
				ext.family_last_op_time = 0;
				ext.last_login_time = 0;
				ext.last_offline_time = 0;
				ext.role_name = "";
				FriendsModule.getInstance().modifyInfo(ext);
			}
			removeSignTextInput();
		}
		
		public function updateMyInfo():void{
			var currentSign:String = GlobalObjectManager.getInstance().user.ext.signature;
			isNull = false;
			if(currentSign == ""){
				isNull = true;				
				currentSign = "共铸我们的天之刃！";
			}
//			TextUtil.fitText(signText,currentSign,150);
			signText.htmlText = currentSign;
			signText.maxChars = 150;
			signText.borderColor = 0x490000;
		}
	}
}