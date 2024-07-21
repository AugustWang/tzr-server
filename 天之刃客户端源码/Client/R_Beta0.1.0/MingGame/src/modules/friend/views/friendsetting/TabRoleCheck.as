package modules.friend.views.friendsetting
{
	import com.ming.ui.controls.RadioButton;
	import com.ming.ui.controls.RadioButtonGroup;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;

	/**
	 * 身份验证
	 * @author
	 * 
	 */	
	public class TabRoleCheck extends Sprite
	{
		public function TabRoleCheck()
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
		
		private var allowAnyOne:RadioButton;
		private var needAllow:RadioButton;
		private var refuseAnyOne:RadioButton;
		private function init():void{
			var textFormate:TextFormat = new TextFormat("Tahoma",12,0xfffffff);
			allowAnyOne = new RadioButton("允许任何人把我列为好友");
			allowAnyOne.selected = true;
			allowAnyOne.textFormat = textFormate;
			allowAnyOne.width = 20;
			allowAnyOne.height = 20;
			needAllow = new RadioButton("需要身份验证才可以把我列为好友");
			needAllow.textFormat = textFormate;
			needAllow.width = 20;
			needAllow.height = 20;
			refuseAnyOne = new RadioButton("不允许任何人把我列为好友");
			refuseAnyOne.textFormat = textFormate;
			refuseAnyOne.width = 20;
			refuseAnyOne.height = 20;
			
			var radioBtnGroup:RadioButtonGroup = new RadioButtonGroup();
			radioBtnGroup.addEventListener(RadioButtonGroup.SELECTED_CHANGE,onChangeHandler);
			this.addChild(radioBtnGroup);
			radioBtnGroup.direction = RadioButtonGroup.VERTICAL;
			radioBtnGroup.x = 20;
			radioBtnGroup.y = 20;
			radioBtnGroup.width = 150;
			radioBtnGroup.height = 100;
			radioBtnGroup.addItem(allowAnyOne);
			radioBtnGroup.addItem(needAllow);
			radioBtnGroup.addItem(refuseAnyOne);
		}
		
		private function onChangeHandler(evt:Event):void{
			FriendSettingConstants.allow_anyone_bool = allowAnyOne.selected;
			FriendSettingConstants.need_allow_bool = needAllow.selected;
			FriendSettingConstants.refuse_anyone_bool = refuseAnyOne.selected;
			//  trace(allowAnyOne.selected + "--------"+needAllow.selected+"---------"+refuseAnyOne.selected);
		}
	}
}