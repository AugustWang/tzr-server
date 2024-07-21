package modules.friend.views.friendsetting
{
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.friend.FriendsModule;
	
	public class FriendSetting extends Sprite
	{	
		private var baseInfo:TabBaseInfo;
		private var msgsetting:TabMessageSetting;
		private var roleCheck:TabRoleCheck;
		public function FriendSetting()
		{
//			init();
		}
		
		public function init():void{
			if(baseInfo){
				baseInfo.backUI();
				baseInfo = null;
			}if(msgsetting){
				msgsetting = null;
			}if(roleCheck){
				roleCheck = null;
			}
			baseInfo = new TabBaseInfo();
			baseInfo.y = 3;
//			msgsetting = new TabMessageSetting();
//			roleCheck = new TabRoleCheck();
			
			var tabNavigation:TabNavigation = new TabNavigation(); 
			tabNavigation.tabContainer.bgSkin = Style.getPanelContentBg();
			tabNavigation.height = 349;
			tabNavigation.width = 461;
			tabNavigation.addItem("基本资料",baseInfo,70,25);
//			tabNavigation.addItem("消息设置",msgsetting,64,26);
//			tabNavigation.addItem("身份验证",roleCheck,64,26);	
			addChild(tabNavigation);
			
			var sureBtn:Button = ComponentUtil.createButton("确定",280,305,65,25,this);
			sureBtn.addEventListener(MouseEvent.CLICK,sureHandler);
			var cancelBtn:Button = ComponentUtil.createButton("取消",sureBtn.x + sureBtn.width+10,sureBtn.y,65,25,this);
			cancelBtn.addEventListener(MouseEvent.CLICK,cancelHandler);
		}
		
		private function sureHandler(evt:MouseEvent):void{
			FriendsModule.getInstance().modifyInfo(baseInfo.clickSure());
//			GreenHandModel.getInstance().openGreenHandWindow();
//			FriendsModel.getInstance().requestRecommendData(200,100);
//			TeamModule.getInstance().recommedTeam(100,100);
		}
		private function cancelHandler(evt:MouseEvent):void{
			baseInfo.clickCancel();
		}
	}
}