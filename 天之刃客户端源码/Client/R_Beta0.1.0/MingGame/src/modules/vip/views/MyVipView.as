package modules.vip.views
{
	import com.common.FilterCommon;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.ModuleCommand;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopModule;
	import modules.system.SystemConfig;
	import modules.vip.VipDataManager;
	import modules.vip.VipModule;
	
	import proto.common.p_role_vip;
	
	public class MyVipView extends Sprite
	{
		public static const VIP_COUNT:int = 3;
		private var _head:HeadItem;
		private var _levelTxt:TextField;
		private var _vipDescTxt:TextField;
		private var _carryCountTxt:TextField;
		private var _infoTxt:TextField;
		private var _titleTxt:TextInput;
		private var _tab:TabBar;
		private var _rechargeBtn:Button;
		private var _cardBtnAry:Array;
		private var _level:int;
		private var _rechargeView:VipRechargeView;
		
		public function MyVipView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			_head = new HeadItem;
			_head.x = 10;
			_head.y = 10;
			addChild(_head);
			
			_rechargeBtn = ComponentUtil.createButton("", 420, 13, 75, 26, this);
			_rechargeBtn.addEventListener(MouseEvent.CLICK, rechargeBtnHandler);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y = 75;
			line.x = 30;
			line.width = 515;
			addChild(line);
			
			var txtBg:UIComponent = ComponentUtil.createUIComponent(4, 151, 534, 252);
			Style.setBorderSkin(txtBg);
			addChild(txtBg);
			
			
			var tf:TextFormat = new TextFormat;
			tf.color = 0xE4DDAB;
			tf.leading = 5;
			_levelTxt = ComponentUtil.createTextField("", 160, 10, tf, 250, 25, this);
			_vipDescTxt = ComponentUtil.createTextField("", 56, 30, tf, 350, 40, this);
			_vipDescTxt.textColor = 0xffffff;
			_vipDescTxt.multiline = true;
			
			_carryCountTxt = ComponentUtil.createTextField("", 56, 50, tf, 250, 40, this);
			_carryCountTxt.textColor = 0xffffff;
			
			_infoTxt = ComponentUtil.createTextField("", 10, 40, tf, 480, 217, txtBg);
			_infoTxt.selectable = true;
			_infoTxt.multiline = true;
			_infoTxt.wordWrap = true;
			_infoTxt.mouseEnabled = true;
			_infoTxt.addEventListener(TextEvent.LINK, textLinkHandler);
			
			tf.align = TextAlign.CENTER;
			tf.bold = true;
			tf.align = TextAlign.LEFT;
			_titleTxt = ComponentUtil.createTextInput(7,7,520,25,txtBg);
			_titleTxt.textField.defaultTextFormat = tf;
			_titleTxt.enabled = false;
		}
		
		public function setIndex(index:int):void
		{
			if (_cardBtnAry) {
				vipBtnSelect(index);
			}
			if (_tab) {
				setTabIndex(index);
			}
		}
		
		public function reset():void
		{
			_head.reset();
			var vipInfo:p_role_vip = VipModule.vipInfo;
			if (!vipInfo || vipInfo.role_id == 0) {
				resetNoVip();
			} else {
				resetVip(vipInfo);
			}
		}
		
		private function resetNoVip():void
		{
			_levelTxt.htmlText = "<font color='#EF0037'>你还不是VIP会员</font>";
			_vipDescTxt.htmlText = "成为VIP即可享受无与伦比的畅快体验！";
			if (!_cardBtnAry) {
				_cardBtnAry = new Array;
				var bx:int = 50;
				for (var i:int=VIP_COUNT-1; i >=0 ; i--) {
					var btn:ToggleButton = createVipCardBtn(i);
					btn.x = bx;
					addChild(btn);
					_cardBtnAry.push(btn);
					bx += 160;
				}
			}
			for (var j:int=0; j < VIP_COUNT; j ++) {
				ToggleButton(_cardBtnAry[j]).visible = true;
			}
			vipBtnSelect(2);
		}
		
		private function createVipCardBtn(index:int):ToggleButton
		{
			var btn:ToggleButton = new ToggleButton;
			var skin:ButtonSkin = new ButtonSkin;
			skin.skin = Style.getUIBitmapData(GameConfig.VIP_UI,"vip_1skin");
			skin.overSkin = Style.getUIBitmapData(GameConfig.VIP_UI,"vip_2skin");
			skin.selectedSkin = Style.getUIBitmapData(GameConfig.VIP_UI,"vip_3skin");
			btn.y = 80;
			btn.width = 132;
			btn.height = 70;
			btn.name = index.toString();
			btn.bgSkin = skin;
			btn.addEventListener(MouseEvent.CLICK, vipBtnClickHandler);
			
			var card:Object = VipDataManager.getInstance().vipCard[index];
			var item:BaseItemVO = ItemLocator.getInstance().getObject(card.typeid);
			var image:GoodsImage = new GoodsImage;
			image.setImageContent(item, item.maxico);
			image.x = 5;
			image.y = 5;
			image.mouseEnabled = false;
			btn.addChild(image);
			
			var tf:TextFormat = new TextFormat;
			tf.bold = true;
			tf.color = ItemConstant.COLOR_VALUES2[item.color];
			var name:TextField = ComponentUtil.createTextField(item.name, 69, 2, tf, 100, 25, btn);
			name.filters = FilterCommon.FONT_BLACK_FILTERS;
			ComponentUtil.createTextField(card.gold + "元宝", 69, 18, null, 80, 25, btn).filters=FilterCommon.FONT_BLACK_FILTERS;
			ComponentUtil.createTextField("VIP" + (index + 1), 69, 34, null, 50, 25, btn).filters=FilterCommon.FONT_BLACK_FILTERS;
			
			return btn;
		}
		
		private function vipBtnClickHandler(evt:Event):void
		{
			var btn:ToggleButton = ToggleButton(evt.currentTarget);
			vipBtnSelect(int(btn.name));
		}
		
		private function vipBtnSelect(index:int):void
		{
			for (var i:int=0; i < VIP_COUNT; i ++) {
				var toggleBtn:ToggleButton = ToggleButton(_cardBtnAry[i]);
				if (toggleBtn.name == index.toString()) {
					toggleBtn.selected = true;
				} else {
					toggleBtn.selected = false;
				}
			}
			_level = VipDataManager.getInstance().getNewVipLevel(index);
			var tf:TextFormat = new TextFormat;
			tf.color = 0xE4DDAB;
			tf.leading = 5;
			_infoTxt.htmlText = "";
			_infoTxt.defaultTextFormat = tf;
			_infoTxt.htmlText = VipDataManager.getInstance().getVipLevelComDesc(_level);
			_titleTxt.text = "VIP" + _level + "可享受以下特权：";
			_rechargeBtn.label = "成为VIP" + _level;
		}
		
		private function resetVip(vipInfo:p_role_vip):void
		{
			if (_cardBtnAry) {
				for (var j:int=0; j < VIP_COUNT; j ++) {
					ToggleButton(_cardBtnAry[j]).visible = false;
				}
			}
			
			var now:int = SystemConfig.serverTime;
			var remainTime:int = vipInfo.end_time - now;
			var remainStr:String = "";
			if(remainTime >= 0){
				if (remainTime <= 3600) {
					remainStr = "<font color='#EF0037'>剩余时间：不足1小时</font>    请<a href='event:openRechargeView'><font color=\"#EF0037\"><u>续期</u></font></a>"				
				}
				else if (remainTime <= 24*3600) {
					remainStr = "<font color='#EF0037'>剩余时间：" + Math.round(remainTime/3600) + "小时</font>    请<a href='event:openRechargeView'><font color=\"#EF0037\"><u>续期</u></font></a>"
				}
				else if (remainTime <= 10*24*3600) {
					remainStr = "<font color='#EF0037'>剩余时间：" + Math.round(remainTime/(24*3600)) + "天</font>    请<a href='event:openRechargeView'><font color=\"#EF0037\"><u>续期</u></font></a>"
				}
			}else{
				remainStr = "您的VIP已过期，请 <a href='event:openRechargeView'><font color=\"#EF0037\"><u>续期</u></font></a>";
			}
			
			_vipDescTxt.htmlText = "<font color='#F8CA00'>VIP有效期至：</font><font color='#E4DDAB'>" + DateFormatUtil.secToDateCn(vipInfo.end_time) + 
				"</font>    " + remainStr; 
			updateCarryCount();
			if (!_tab) {
				_tab = new TabBar;
				_tab.x = 350;
				_tab.y = 128;
				for (var i:int=1; i <= 3; i ++) {
					_tab.addItem("VIP" + i, 60, 25);
				}
				addChild(_tab);
				_tab.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, tabChange);
				_tab.selectIndex = vipInfo.vip_level - 1;
			}
		}
		
		public function updateCarryCount():void{
			if(VipModule.getInstance().getVipInfo().vip_level < 3){
				var _freeTransTimes:int=VipModule.getInstance().getMissionTransferTimes();
				_carryCountTxt.text = "今天剩余传送数量："+ ( _freeTransTimes);
			}else{
				_carryCountTxt.text = "";
			}
		}
		
		private function setTabIndex(index:int):void
		{
			_tab.selectIndex = index;
			var tf:TextFormat = new TextFormat;
			tf.color = 0xE4DDAB;
			tf.leading = 5;
			_level = index + 1;
			_titleTxt.text = "VIP" + _level + "可享受以下特权：";
			_infoTxt.htmlText = "";
			_infoTxt.defaultTextFormat = tf;
			_infoTxt.htmlText = VipDataManager.getInstance().getVipLevelSpecDesc(_level);
			var vipLevel:int = VipModule.vipInfo.vip_level;
			_rechargeBtn.visible = true;
			if (vipLevel >= 3) {
				_levelTxt.htmlText = "你当前是<font color='#F8CA00'>VIP" + vipLevel + "</font>，已是天之刃最尊贵VIP";
				_rechargeBtn.visible = false;
				return;
			}
			if (_level <= vipLevel) {
				_level = vipLevel + 1;
			}
			_levelTxt.htmlText = "你当前是<font color='#F8CA00'>VIP" + vipLevel + "</font>，花费<font color='#F8CA00'>" + 
				VipDataManager.getInstance().getUpLevelGold(_level) + 
				"</font>元宝可升级为<font color='#F8CA00'>VIP" + _level + "</font>";	
			_rechargeBtn.label = "成为VIP" + _level;
		}
		
		private function tabChange(evt:TabNavigationEvent):void
		{
			setTabIndex(evt.index);
		}
		
		private function rechargeBtnHandler(evt:Event):void
		{
			VipModule.getInstance().upVipLevel(_level);
		}
		
		private function textLinkHandler(evt:TextEvent):void
		{
			var argAry:Array = new Array;
			argAry = evt.text.split("#");
			if (argAry[0] == "getMultiExp") {
				Alert.show("      <font color='#FF3C39'>VIP</font>每天可领取<font color='#CDE643'>1</font>个小时的<font color='#CDE643'>1.5</font>倍经验，可与经验符叠加，你确定要现在领取吗？", "提示", getMultiExp, null);
				
				function getMultiExp():void
				{
					VipModule.getInstance().getMultiExpTos();	
				}
			}
			if (argAry[0] == "openPetShop") {
				ShopModule.getInstance().openPetShop();
			}
			if (argAry[0] == "petTraining") {
				Dispatch.dispatch(ModuleCommand.OPEN_PET_FEED);
			}
			if (argAry[0] == "openShop") {
				ShopModule.getInstance().openOnSaleShop();
			}
			if (argAry[0] == "petSavvy")
				Dispatch.dispatch(ModuleCommand.OPEN_PET_SAVVY);
			if (argAry[0] == "conloginReward") {
				VipModule.getInstance().openExamineView();
			}
			if (argAry[0] == "fixAllEquip") {
				PackageModule.getInstance().fixEquip(0, false);
			}
			if (argAry[0] == "openBuyPanel" && this.stage) {
				ShopModule.getInstance().requestShopItem(argAry[1], argAry[2], new Point(stage.mouseX-178, stage.mouseY-90));
			}
			if (argAry[0] == "openRechargeView") {
				popupRechargeView();
			}
		}
		
		private function popupRechargeView():void
		{
			if (!_rechargeView) {
				_rechargeView = new VipRechargeView;
			}
			WindowManager.getInstance().popUpWindow(_rechargeView);
			WindowManager.getInstance().centerWindow(_rechargeView);
		}
	}
}