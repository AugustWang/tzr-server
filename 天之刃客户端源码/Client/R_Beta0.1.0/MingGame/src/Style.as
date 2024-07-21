package {
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.managers.MusicManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.AccordionSkin;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.CheckBoxSkin;
	import com.ming.ui.skins.ListSkin;
	import com.ming.ui.skins.NumericStepperSkin;
	import com.ming.ui.skins.PanelSkin;
	import com.ming.ui.skins.ScrollBarSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.SliderSkin;
	import com.ming.ui.skins.TabBarSkin;
	import com.ming.ui.skins.TabNavigationSkin;
	import com.ming.ui.skins.ToolTipSkin;
	import com.ming.ui.style.BitmapDataPool;
	import com.ming.ui.style.IStyle;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * 所有样式在此定义
	 */
	public class Style implements IStyle {
		private var loader:Loader;
		private static var pool:BitmapDataPool;

		private static var instance:Style;

		public static function getInstance():Style {
			if (instance == null) {
				instance = new Style();
			}
			return instance;
		}
		
		public static const BLACK_FILTER:GlowFilter=new GlowFilter(0x000000, 1, 2, 2, 5);
		public static const YELLOW_FILTER:GlowFilter=new GlowFilter(0xFFFF00, 1, 4, 4, 5);
		
		public static function get textFormat():TextFormat {
			return new TextFormat("Tahoma", 12, 0xF6F5CD);
		}

		public static function get themeTextFormat():TextFormat {
			return new TextFormat("Tahoma", 12, 0xAFE1EC);
		}
		
		public static function get centerTextFormat():TextFormat {
			return new TextFormat("Tahoma", 12, 0xAFE1EC,null,null,null,null,null,TextFormatAlign.CENTER);
		}
		
		public static function get rightTextFormat():TextFormat{
			return new TextFormat("Tahoma", 12, 0xAFE1EC,null,null,null,null,null,TextFormatAlign.RIGHT);
		}

		public static function get textBlackFilter():Array {
			var filtersArr:Array = new Array();
			filtersArr.push(new GlowFilter(0x000000, 1, 3, 3));
			return filtersArr;
		}

		/**
		 * 启动样式管理，并且启动位图缓存池(位图缓存池默认只管理默认样式)
		 *
		 */
		public function startInit():void {
			StyleManager.getInstance().setUpStyle(this);
			pool = BitmapDataPool.getInstance();
			ToolTipSkin.bgSkin = tipSkin;
			ToolTipSkin.tf = textFormat;
		}

		/**
		 * 通过名称和url获取对应Class
		 */
		public static function getClass(url:String, name:String):Class {
			return ResourcePool.getClass(url, name);
		}

		/**
		 *  通过名称和url获取对应元件或者sprite
		 * @param url
		 * @param name
		 * @return
		 *
		 */
		public static function getSprite(url:String, name:String):Sprite {
			var clazz:Class = getClass(url, name);
			try{
				var bg:MovieClip
				if (clazz) {
					bg = new clazz();
					bg.stop();
				}
				return bg;
			}catch(error:Error){
				var bitmapdata:BitmapData = new clazz(0,0);
				var s:Sprite = new Sprite();
				s.graphics.beginBitmapFill(bitmapdata);
				s.graphics.drawRect(0,0,bitmapdata.width,bitmapdata.height);
				s.graphics.endFill();
				return s;
			}
			return null;
		}

		/**
		 * 通过名称获取视图对象
		 *
		 */
		public static function getViewBg(name:String):Sprite {
			return getSprite(GameConfig.T1_VIEWUI, name);
		}

		/**
		 * 指定名称和URL获取位图数据
		 */
		public static function getUIBitmapData(url:String, name:String):BitmapData {
			if (name == null || url == null)
				return null;
			var bitmapdata:BitmapData = pool.getBitmapData(name, url);
			if (bitmapdata == null) {
				var clazz:Class = getClass(url, name);
				if (clazz) {
					bitmapdata = new clazz(0, 0);
					pool.addBitmapData(name, url, bitmapdata);
				}
			}
			return bitmapdata;
		}
		/**
		 * 获取位图 
		 * @param url
		 * @param name
		 * @return 
		 * 
		 */		
        public static function getBitmap(url:String,name:String):Bitmap{
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = getUIBitmapData(url,name);
			return bitmap;
		}
		
		public static function getSpriteBitmap(url:String,name:String):Sprite{
			var sprite:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = getUIBitmapData(url,name);
			sprite.addChild(bitmap);
			return sprite;
		}
		/**
		 * 供外部调用创建按钮皮肤的方法
		 * @param normal
		 * @param over
		 * @param down
		 * @param disable
		 * @param rect
		 * @param url
		 *
		 */
		public static function getButtonSkin(normal:String, over:String, down:String, disable:String, url:String, rect:Rectangle = null):ButtonSkin {
			var buttonSkin:ButtonSkin = new ButtonSkin();
			buttonSkin.skin = getUIBitmapData(url, normal);
			buttonSkin.overSkin = getUIBitmapData(url, over);
			buttonSkin.downSkin = getUIBitmapData(url, down);
			buttonSkin.disableSkin = getUIBitmapData(url, disable);
			buttonSkin.rect = rect;
			return buttonSkin;
		}

		/**
		 * 供外部使用获取普通皮肤的方法
		 * @param name
		 * @param url
		 * @param rect
		 * @return
		 *
		 */
		public static function getSkin(name:String, url:String, rect:Rectangle = null):Skin {
			var skin:Skin = new Skin(getUIBitmapData(url, name), rect);
			return skin;
		}

		/**
		 * 处理默认样式的方法
		 */
		private function createButtonSkin(normal:String, over:String, down:String, disable:String, rect:Rectangle = null,url:String=""):ButtonSkin {
			if(url == ""){
				url = GameConfig.T1_UI;
			}
			var buttonSkin:ButtonSkin = new ButtonSkin();
			buttonSkin.skin = getUIBitmapData(url, normal);
			buttonSkin.overSkin = getUIBitmapData(url, over);
			buttonSkin.downSkin = getUIBitmapData(url, down);
			buttonSkin.disableSkin = getUIBitmapData(url, disable);
			buttonSkin.rect = rect;
			return buttonSkin;
		}

		/**
		 * 处理默认样式的方法
		 */
		private function createSkin(name:String, rect:Rectangle = null,url:String=""):Skin {
			if(url == ""){
				url = GameConfig.T1_UI;
			}
			var skin:Skin = new Skin(getUIBitmapData(url, name), rect);
			return skin;
		}

		public function get textFormat():TextFormat {
			return new TextFormat("Tahoma", 12, 0xF6F5CD);
		}
		
		public function get buttonSkin():Skin {
			var buttonSkin:ButtonSkin = createButtonSkin("defaultBtn_1skin", "defaultBtn_2skin", "defaultBtn_3skin", "defaultBtn_4skin", new Rectangle(16, 7, 39, 11),GameConfig.T1_UI)
			buttonSkin.color = 0xA0ECEF;
			buttonSkin.overColor = 0x58F1FF;
			buttonSkin.downColor = 0xffff00;
			buttonSkin.selectedColor = 0xffff00;
			buttonSkin.topPadding = -3;
			buttonSkin.soundFunc = playButtonSound;
			return buttonSkin;
		}

		public function get selectedSkin():Skin {
			var selectedSkin:ButtonSkin = buttonSkin as ButtonSkin;
			selectedSkin.selectedSkin = getUIBitmapData(GameConfig.T1_UI, "defaultBtn_3skin");
			return selectedSkin;
		}

		public function get checkBoxSkin():CheckBoxSkin {
			var boxSkin:CheckBoxSkin = new CheckBoxSkin();
			var selected:Skin = createButtonSkin("checkbox_selectedSkin", "checkbox_selectedSkin", "checkbox_selectedSkin", "");
			var unselect:Skin = createButtonSkin("checkbox_skin", "checkbox_overSkin", "checkbox_overSkin", "");
			boxSkin.selectedSkin = selected;
			boxSkin.unSelectedSkin = unselect;
			return boxSkin;
		}

		public function get npcCloseBtnSkin():Skin {
			return createButtonSkin("npc_close", "npc_closeOver", "npc_closeDown", '');
		}

		public function get radioButtonSkin():CheckBoxSkin {
			var boxSkin:CheckBoxSkin = new CheckBoxSkin();
			var selected:Skin = createSkin("radio_selectedSkin");
			var unselect:Skin = createSkin("radio_skin");
			boxSkin.selectedSkin = selected;
			boxSkin.unSelectedSkin = unselect;
			return boxSkin;
		}
		
		public function get scrollBarSkin():ScrollBarSkin {
			var scrollBar:ScrollBarSkin = new ScrollBarSkin();
			scrollBar.width = 15;
			scrollBar.buttonWidth = 13;
			scrollBar.buttonHeight = 15;
			scrollBar.traceBarWidth = 13;
			scrollBar.thumbBarWidth = 13;
			scrollBar.downSkin = createButtonSkin("dDownArrow_1skin", "dDownArrow_2skin", "dDownArrow_3skin","", null,GameConfig.T1_UI);
			scrollBar.upSkin = createButtonSkin("dUpArrow_1skin", "dUpArrow_2skin", "dUpArrow_3skin","", null,GameConfig.T1_UI);
			scrollBar.thumbSkin = createButtonSkin("dThumb_1skin", "dThumb_2skin", "dThumb_3skin", "", new Rectangle(3, 4, 5, 21),GameConfig.T1_UI);
			scrollBar.trackSkin = createSkin("traceBar",new Rectangle(3, 3, 7, 163),GameConfig.T1_UI);
			return scrollBar;
		}

		public function get textScrollSkin():ScrollBarSkin {
			return scrollBarSkin;
		}

		public function get tabBarSkin():TabBarSkin {
			var tabSkin:TabBarSkin = new TabBarSkin();
			tabSkin.tabBtnFunc = getTabButtonSkin;
			tabSkin.soundFunc = playTabBarSound;
			return tabSkin;
		}

		public function getTabButtonSkin():ButtonSkin {
			var tabBtnSkin:ButtonSkin = createButtonSkin("tabBar_1skin", "tabBar_2skin","tabBar_3skin","", new Rectangle(6, 9, 66, 8),GameConfig.T1_UI);
			tabBtnSkin.selectedSkin = getUIBitmapData(GameConfig.T1_UI, "tabBar_3skin");
			tabBtnSkin.selectedColor = 0xfffd4b;
			tabBtnSkin.color = 0x70dfe1;
			return tabBtnSkin;
		}

		public function get comboBoxSkin():Skin {
			return createButtonSkin("combox_1skin", "combox_2skin", "combox_3skin", null, new Rectangle(6, 4, 54, 15),GameConfig.T1_UI);
		}

		public function get sliderSkin():SliderSkin {
			var sliderSkin:SliderSkin = new SliderSkin();
			sliderSkin.backSkin = createSkin("sliderBack", new Rectangle(3, 3, 183, 7),GameConfig.T1_UI);
			sliderSkin.handlerSkin = createButtonSkin("handler_1skin","","","",null,GameConfig.T1_UI);
			return sliderSkin;
		}

		public function get listSkin():ListSkin {
			var listSkin:ListSkin = new ListSkin();
			listSkin.overSkin = createSkin("listItemOver",new Rectangle(4,4,154,10),GameConfig.T1_UI);
			listSkin.selectedSkin = createSkin("listItemOver",new Rectangle(4,4,154,10),GameConfig.T1_UI);
			listSkin.borderSkin = createSkin("listBg",new Rectangle(10,10,120,104),GameConfig.T1_UI);
			return listSkin;
		}
		
		public static function getBorderListSkin():ListSkin{
			var listSkin:ListSkin = new ListSkin();
			listSkin.overSkin = null;
			listSkin.selectedSkin = getInstance().createSkin("itemBorderBG",new Rectangle(8,8,147,14),GameConfig.T1_UI);
			return listSkin;
		}

		public function get textInputSkin():Skin {
			return createSkin("textSkin", new Rectangle(10, 4, 119, 16),GameConfig.T1_UI);
		}

		public function get textAreaSkin():Skin {
			return createSkin("textSkin", new Rectangle(10, 4, 119, 16),GameConfig.T1_UI);
		}

		public function get panelSkin():PanelSkin {
			var panelSkin:PanelSkin = new PanelSkin();
			panelSkin.panelBgSkin = createSkin("panelBgSkin", new Rectangle(130, 60, 184, 321),GameConfig.T1_UI);
			var closeSkin:ButtonSkin = createButtonSkin("close_1skin", "close_2skin", "close_3skin","",null,GameConfig.T1_UI);
			panelSkin.closeSkin = closeSkin;
//			var helpSkin:ButtonSkin = createButtonSkin("pro_skin","pro_overSkin","pro_down",null);
//			panelSkin.helpSkin = helpSkin;
			return panelSkin;
		}
		
		public function get tabNavigationSkin():TabNavigationSkin {
			var tabNavigationSkin:TabNavigationSkin = new TabNavigationSkin();
			tabNavigationSkin.tabBar = tabBarSkin;
			//tabNavigationSkin.tabContainer = getSkin("tabUpBg", GameConfig.T1_UI, new Rectangle(10, 10, 246, 102));
			return tabNavigationSkin;
		}		

		public function get listItemSkin():Skin {
			//var skin:Skin = new Skin(getSource("listItemSkin"),new Rectangle(1,1,150,20));
			return null;
		}

		public function get numericStepperSkin():NumericStepperSkin {
			var numSkin:NumericStepperSkin = new NumericStepperSkin();
			var upSkin:ButtonSkin = createButtonSkin("numericStepper_Up", "numericStepper_1Up", "numericStepper_2Up", "");
			numSkin.upSkin = upSkin;
			var downSkin:ButtonSkin = createButtonSkin("numericStepper_Down", "numericStepper_1Down", "numericStepper_2Down", "");
			numSkin.downSkin = downSkin;
			var skin:Skin = textInputSkin;
			numSkin.bgSkin = skin;
			return numSkin;
		}

		public function get tipSkin():Skin {
			return createSkin("ToolTip_Skin", new Rectangle(10, 10, 145, 158));
		}

		public function get accordionSkin():AccordionSkin{
			var skin:AccordionSkin = new AccordionSkin();
			skin.branchFunc = getAccordionButonSkin;
			skin.leafFunc = getAccordionButonSkin;
			return skin;
		}
		
		public function getAccordionButonSkin():Skin{
			return selectedSkin;
		}
		
		public static function getTabBar1Skin():TabBarSkin {
			var tabSkin:TabBarSkin = new TabBarSkin();
			tabSkin.tabBtnFunc = getTabBarButton1Skin;
			tabSkin.soundFunc = playTabBarSound;
			return tabSkin;
		}
		
		public static function getTabBarButton1Skin():ButtonSkin{
			var tabBtnSkin:ButtonSkin = getInstance().createButtonSkin("tabBar1_1skin", "tabBar1_2skin","tabBar1_3skin","",null,GameConfig.T1_UI);
			tabBtnSkin.selectedSkin = getUIBitmapData(GameConfig.T1_UI, "tabBar1_3skin");
			return tabBtnSkin;	
		}
		
		public static function getShieldCheckBox():CheckBoxSkin {
			var boxSkin:CheckBoxSkin = new CheckBoxSkin();
			var selected:Skin = getButtonSkin("checkbox_cha", "checkbox_cha", "checkbox_cha", "checkbox_cha", GameConfig.T1_UI);
			var unselect:Skin = getButtonSkin("checkbox_skin", "checkbox_overSkin", "checkbox_overSkin", "", GameConfig.T1_UI);
			boxSkin.selectedSkin = selected;
			boxSkin.unSelectedSkin = unselect;
			return boxSkin;
		}
		
		public static function getLeftTabBarSkin():TabBarSkin {
			var tabSkin:TabBarSkin = new TabBarSkin();
			tabSkin.tabBtnFunc = getLeftTabButtonSkin;
			tabSkin.soundFunc = playTabBarSound;
			return tabSkin;
		}
		
		public static function getLeftTabButtonSkin():ButtonSkin{
			var tabBtnSkin:ButtonSkin = getInstance().createButtonSkin("lTabBar_1skin", "lTabBar_2skin","lTabBar_3skin","",null,GameConfig.T1_UI);
			tabBtnSkin.selectedSkin = getUIBitmapData(GameConfig.T1_UI, "lTabBar_2skin");
			return tabBtnSkin;	
		}
		
		public static function get alphaScrollBarSkin():ScrollBarSkin {
			var scrollBar:ScrollBarSkin = new ScrollBarSkin();
			scrollBar.width = 17;
			scrollBar.buttonWidth = 17;
			scrollBar.buttonHeight = 14;
			scrollBar.traceBarWidth = 17;
			scrollBar.thumbBarWidth = 16;
			scrollBar.downSkin = getInstance().createButtonSkin("downArrow_1skin", "downArrow_2skin", "downArrow_3skin","", null,GameConfig.T1_UI);
			scrollBar.upSkin = getInstance().createButtonSkin("upArrow_1skin", "upArrow_2skin", "upArrow_3skin","", null,GameConfig.T1_UI);
			scrollBar.thumbSkin = getInstance().createButtonSkin("thumb_1skin", "thumb_2skin", "thumb_3skin", "", new Rectangle(4, 10, 8, 76),GameConfig.T1_UI);
			scrollBar.trackSkin = null;
			return scrollBar;
		}
		
		public static function setDefault1BtnStyle(btn:Button):void{
			var buttonSkin:ButtonSkin = getInstance().createButtonSkin("defaultBtn1_1skin", "defaultBtn1_2skin", "defaultBtn1_3skin", "", new Rectangle(4, 4, 31, 15),GameConfig.T1_UI)
			buttonSkin.color = 0xF6F5CD;
			buttonSkin.overColor = 0x58F1FF;
			buttonSkin.downColor = 0xffff00;
			buttonSkin.selectedColor = 0xffff00;
			buttonSkin.soundFunc = playButtonSound;
			btn.bgSkin = buttonSkin;
		}
		
		public static function setRedBtnStyle(btn:Button):void {
			btn.textColor = 0xffcc00;
			btn.bgSkin = getInstance().buttonSkin;
		}

		public static function setListBgSkin(ui:UIComponent):void{
			ui.bgSkin = getInstance().createSkin("listBg",new Rectangle(10,10,120,104),GameConfig.T1_UI);
		}
		
		public static function setChatSendBtnStyle(btn:Button):void {
			btn.textColor = 0xffcc00;
			btn.bgSkin = getButtonSkin("send_1skin", "send_2skin", "send_3skin", "", GameConfig.T1_UI, new Rectangle(5, 5, 18, 17));
		}

		public static function setLoudSpeakBtnStyle(btn:UIComponent):void {
			btn.bgSkin = getInstance().createSkin("sound_on",null,GameConfig.T1_VIEWUI);
		}

		public static function setHideBtnStyle(btn:Button):void {
			btn.bgSkin = getButtonSkin("DtabSkin", "Dtab_selectedSkin", "Dtab_selectedSkin", null, GameConfig.T1_UI, new Rectangle(4, 4, 23, 14));
		}

		//箭头左
		public static function setScrollEnableStyle(btn:UIComponent):void {
			btn.bgSkin = getButtonSkin("leftHide", "leftOverHide", "leftDownHide", null, GameConfig.T1_UI);
		}

		public static function setaddBtnStyle(btn:Button):void {
			btn.bgSkin = getButtonSkin("add_1skin", "add_2skin", "add_3skin", null, GameConfig.T1_UI);
		}

		public static function setreduceBtnStyle(btn:Button):void {
			btn.bgSkin = getButtonSkin("reduce_1skin", "reduce_2skin", "reduce_3skin", null, GameConfig.T1_UI);
		}

		public static function setSortBtnStyle(btn:UIComponent):void {
			btn.bgSkin = getButtonSkin("item", "d_skin", "d_downSkin", null, GameConfig.T1_UI, new Rectangle(20, 5, 48, 10));
		}

		public static function setDeepRedBtnStyle(btn:Button):void {
			var deepRedSkin:ButtonSkin = getInstance().buttonSkin as ButtonSkin;
			deepRedSkin.soundFunc = playButtonSound;
			btn.bgSkin = deepRedSkin;
		}

		public static function setRedButtonStyle(btn:Button):void {
			var buttonSkin:ButtonSkin = getButtonSkin("red_ButtonSkin", "red_ButtonSkin", "red_ButtonSkin", "red_ButtonSkin", GameConfig.T1_UI, new Rectangle(30, 12, 6, 1))
			buttonSkin.soundFunc = playButtonSound;
			btn.bgSkin = buttonSkin;
		}

		public static function setYellowButtonStyle(btn:Button):void {
			var buttonSkin:ButtonSkin = getButtonSkin("yellowBtn_1skin", "defaultBtn_2skin", "defaultBtn_3skin", "defaultBtn_4skin",GameConfig.T1_UI,new Rectangle(16, 7, 39, 11))
			buttonSkin.soundFunc = playButtonSound;
			buttonSkin.topPadding = -3;
			btn.bgSkin = buttonSkin;
		}
		
		public static function setTitleBarSkin(ui:UIComponent):void{
			ui.bgSkin = Style.getSkin("titleBar",GameConfig.T1_VIEWUI,new Rectangle(15,10,138,2));//	
		}
		
		public static function setBorderSkin(ui:UIComponent):void {
			ui.bgSkin = getSkin("contentBg", GameConfig.T1_VIEWUI, new Rectangle(10, 10, 152, 202));
		}
		
		public static function getPanelContentBg():Skin{
			var contentBg:Skin = getSkin("panelContentBg",GameConfig.T1_VIEWUI,new Rectangle(10,10,286,270));
			return contentBg;
		}
		
		public static function setPopUpSkin(ui:UIComponent):void{
			ui.bgSkin = Style.getSkin("popUpBg",GameConfig.T1_VIEWUI,new Rectangle(4,4,199,153));
		}
		
		public static function setItemBgSkin(ui:UIComponent):void{
			ui.bgSkin = Style.getSkin("itemBg",GameConfig.T1_VIEWUI,new Rectangle(15,15,186,61));
		}
		
		public static function setNewBorderBgSkin(ui:UIComponent):void {
			ui.bgSkin = getSkin("borderBg", GameConfig.T1_UI, new Rectangle(5, 5, 164, 70));
		}

		public static function setBorder1Skin(ui:UIComponent):void {
			ui.bgSkin = getSkin("jinengBg", GameConfig.T1_VIEWUI, new Rectangle(10, 5, 418, 15));
		}
		
		public static function setBoldBorder(ui:UIComponent):void {
			ui.bgSkin = getSkin("boldborder", GameConfig.T1_VIEWUI, new Rectangle(10, 10, 45, 47));
		}
		
		public static function setRoundBorder(ui:UIComponent):void {
			ui.bgSkin = getInstance().tipSkin;
		}

		public static function setRectBorder(ui:UIComponent):void {
			ui.bgSkin = getInstance().tipSkin;
		}

		public function get tipPanelSkin():PanelSkin {
			var panelSkin:PanelSkin = new PanelSkin();
			panelSkin.panelBgSkin = createSkin("tipBgSkin", new Rectangle(30, 20, 118, 30));
			var closeSkin:ButtonSkin = createButtonSkin("close_1skin", "close_2skin", "close_3skin", null,null,GameConfig.T1_UI);
			panelSkin.closeSkin = closeSkin;
			return panelSkin;
		}

		public function get alertSkin():PanelSkin {
			var panelSkin:PanelSkin = new PanelSkin();
			panelSkin.panelBgSkin = createSkin("alertBgSkin", new Rectangle(50, 50, 230, 108),GameConfig.T1_UI);
			var closeSkin:ButtonSkin = createButtonSkin("close_1skin", "close_2skin", "close_3skin", null,null,GameConfig.T1_UI);
			panelSkin.closeSkin = closeSkin;
			return panelSkin;
		}

		public static function setMenuItemSkin(ui:Button):void {
			var buttonSkin:ButtonSkin = getInstance().createButtonSkin("menuItem_1skin", "menuItem_2skin", "menuItem_2skin", "", new Rectangle(6, 6, 86, 16),GameConfig.T1_UI);
			buttonSkin.overColor = 0xffff00;
			buttonSkin.color = 0xffcc00;
			ui.bgSkin = buttonSkin;
			ui.textColor = 0xffcc00;
		}

		public static function setMenuItemBg(ui:UIComponent):void {
			ui.bgSkin = getInstance().createSkin("menuBarBg", new Rectangle(30, 30, 57, 105),GameConfig.T1_UI);
		}
		
		public static function getChatTabBarSkin():TabBarSkin{
			var tabSkin:TabBarSkin = new TabBarSkin();
			tabSkin.tabBtnFunc = getChatButtonSkin;
			tabSkin.soundFunc = playTabBarSound;
			return tabSkin;
		}
		
		public static function getChatButtonSkin():ButtonSkin{
			var buttonSkin:ButtonSkin = getButtonSkin("chatTabBtn","","","",GameConfig.T1_UI,new Rectangle(6,6,10,5));
			buttonSkin.color = 0xF6F5CD;
			buttonSkin.overColor = 0x58F1FF;
			buttonSkin.downColor = 0xffff00;
			buttonSkin.selectedColor = 0xffff00;
			return buttonSkin;
		}
		
		public static function getTaskFollowTabBarSkin():TabBarSkin{
			var tabSkin:TabBarSkin = new TabBarSkin();
			tabSkin.tabBtnFunc = getAlphaButtonSkin;
			tabSkin.soundFunc = playTabBarSound;
			return tabSkin;
		}
		
		public static function getAlphaButtonSkin():ButtonSkin{
			var bitmapData:BitmapData = pool.getBitmapData("alphaSkin",GameConfig.T1_UI);
			if(bitmapData == null){
				bitmapData = new BitmapData(20,20,true,0);
				pool.addBitmapData("alphaSkin",GameConfig.T1_UI,bitmapData);
			}
			var buttonSkin:ButtonSkin = new ButtonSkin();
			buttonSkin.overSkin = bitmapData;
			buttonSkin.skin = bitmapData;
			buttonSkin.downSkin = bitmapData;
			buttonSkin.selectedSkin = bitmapData;
			buttonSkin.color = 0xF6F5CD;
			buttonSkin.overColor = 0x58F1FF;
			buttonSkin.downColor = 0xffff00;
			buttonSkin.selectedColor = 0xffff00;
			return buttonSkin;
		}
		
		public static function getBlackSprite(w:Number, h:Number, round:Number = 6, alpha:Number = 0.5, color:uint = 0x000000):Sprite {
			var s:Sprite = new Sprite();
			with (s.graphics) {
				beginFill(color, alpha);
				drawRoundRect(0, 0, w, h, round, round);
				endFill();
			}
			s.mouseEnabled = false;
			return s;
		}

		public static function playTabBarSound():void {
			MusicManager.playSound(MusicManager.TABBAR);
		}

		public static function playButtonSound():void {
			MusicManager.playSound(MusicManager.BUTTON);
		}
	}
}