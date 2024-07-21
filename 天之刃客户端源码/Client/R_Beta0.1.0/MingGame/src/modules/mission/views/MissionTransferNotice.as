package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.mission.MissionModule;
	import modules.vip.VipModule;
	
	
	public class MissionTransferNotice extends BasePanel
	{
		private var _noticeTxt:TextField;
		private var _cb:CheckBox;
		private var _linkArgs:String;
		
		public function MissionTransferNotice(key:String=null)
		{
			super(key);
			initView();
		}
		
		private function initView():void
		{
			this.title = "小提示";
			this.titleAlign = 2;
			panelSkin = Style.getInstance().alertSkin;
			showCloseButton = false;
			this.width = 300;
			this.height = 150;
			this.x = (1002 - this.width) / 2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			
			_noticeTxt = ComponentUtil.createTextField("", 15, 7, null, 275, 60, this);
			_noticeTxt.multiline = true;
			_noticeTxt.wordWrap = true;
			addChild(_noticeTxt);
			
			_cb = ComponentUtil.createCheckBox("今日不再提示", 183, 38, this);
			addChild(_cb);
			
			var _sureBtn:Button = ComponentUtil.createButton("传送", 50, 70, 66, 25);
			addChild(_sureBtn);
			_sureBtn.addEventListener(MouseEvent.CLICK, sureHandle);
			
			var _cancelBtn:Button = ComponentUtil.createButton("取消", 183, 70, 66, 25);
			addChild(_cancelBtn);
			_cancelBtn.addEventListener(MouseEvent.CLICK, closeHandle);
		}
		
		/**
		 * 通过VIP的方式进行传送 
		 * @param e
		 * 
		 */		
		private function sureHandle(e:Event):void
		{	
			// 是否选中了不再提示
			if (_cb.selected) {
				VipModule.getInstance().stopNoticTos(1);
			}
			_cb.selected = false;
			MissionModule.getInstance().carryToPath(this._linkArgs,true);
			
			this.closeWindow();
		}
		
		private function closeHandle(e:Event):void
		{
			this.closeWindow();
		}
		
		public function setNoticeTxt(_remainTime:int, _totalTimes:int, linkArgs:String):void
		{
			if (_remainTime > 0) {
				_noticeTxt.text = "您是《天之刃》VIP会员，每天可以免费使用传送" + _totalTimes + "次。已经使用次数： " + (_totalTimes - _remainTime) + "/" + _totalTimes;
			} else {
				_noticeTxt.text = "您是《天之刃》VIP会员，每天可以免费使用传送" + _totalTimes + "次。已经使用次数： " + (_totalTimes - _remainTime) + "/" + _totalTimes + "，消耗【传送卷】× 1";
			}
			this._linkArgs = linkArgs;
			
		}
	}
}