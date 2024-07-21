package modules.smallMap.view {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.TabBarSkin;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import modules.scene.SceneDataManager;
	import modules.smallMap.view.events.WorldEvent;
	import modules.smallMap.view.items.CountryMap;
	import modules.smallMap.view.items.CurrentCityView;
	import modules.smallMap.view.items.WorldMapView;

	public class SmallSceneView extends BasePanel {
		public static var isJump:Boolean;
		private var tabBar:TabBar;
		private var content:Sprite;
		public var currentCity:CurrentCityView; //当前地图
		private var countryMap:CountryMap; //国家地图
		private var worldMapView:WorldMapView; //世界地图
		private var jumpBtn:Button;

		public function SmallSceneView() {
			super();
			initView();
		}

		public function initView():void {
			this.width=748;
			this.height=453;
			
			addTitleBG(448);
			addImageTitle("title_map");
			   
			tabBar=new TabBar();
			tabBar.hPadding = 2;
			tabBar.x=30;
			tabBar.addItem('世界地图', 75, 21);
			tabBar.addItem('国家地图', 75, 21);
			tabBar.addItem('当前地图', 75, 21);
			tabBar.selectIndex=2;
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onTabChanged);
			addChild(tabBar);
			
			content = new Sprite();
			content.x = 8;
			content.y = 19;
			addChild(content);
			
			jumpBtn=ComponentUtil.createButton("传送", 413, -1, 75, 24, this);
			jumpBtn.icon = Style.getBitmap(GameConfig.T1_VIEWUI,"fly");
			jumpBtn.iconTop=-2;
			jumpBtn.textBold = true;
			Style.setYellowButtonStyle(jumpBtn);
			jumpBtn.addEventListener(MouseEvent.CLICK, onClickJump);
			var stage:Stage=LayerManager.stage;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onCanelTransfer);
		}
		
		private function getButtonSkin():Skin{
			return Style.getInstance().selectedSkin;
		}
		
		//点击按钮的切换
		private function onTabChanged(e:TabNavigationEvent):void {
			if (e.index == 0) {
				if (worldMapView == null) {
					worldMapView=new WorldMapView;
					worldMapView.addEventListener(WorldEvent.COUNTRY_EVENT, onClickWorld);
				}
				removeOtherAndAdd(worldMapView);
			} else if (e.index == 1) {
				if (countryMap == null) {
					countryMap=new CountryMap;
				}
				removeOtherAndAdd(countryMap);
				countryMap.changeCountry(SceneDataManager.inWhichArea);
			} else if (e.index == 2) {
				if (currentCity == null) {
					currentCity=new CurrentCityView;
				}
				removeOtherAndAdd(currentCity);
			}
		}

		private function onClickWorld(e:WorldEvent):void {
			tabBar.selectIndex=1;
			if (countryMap) {
				countryMap.changeCountry(int(e.country_id));
			}
		}

		private function onCanelTransfer(e:MouseEvent=null):void {
			if ((stage == null || (stage && this.getBounds(stage).contains(stage.mouseX, stage.mouseY) == false))
				&& CursorManager.getInstance().currentCursor == CursorName.TRANSMISSION_1) {
				resetTransferBtn(false);
			}
		}

		//清除其他界面，并添加这个界面
		private function removeOtherAndAdd(s:Sprite):void {
			while (content.numChildren > 0) {
				content.removeChildAt(0);
			}
			content.addChild(s);
		}

		public function seleteIndex(value:int):void {
			if (this.tabBar)
				this.tabBar.selectIndex=value;
		}

		public function onChangeMap():void {
			if (currentCity == null) {
				currentCity=new CurrentCityView;
			}
			currentCity.reset();
		}

		private function onClickJump(e:MouseEvent):void {
			resetTransferBtn(true);
		}

		public function resetTransferBtn(value:Boolean):void {
			if (value) {
				isJump = true;
				CursorManager.getInstance().setCursor(CursorName.TRANSMISSION_1);
				CursorManager.getInstance().enabledCursor=false;
				jumpBtn.enabled = false;
			} else {
				isJump = false;
				CursorManager.getInstance().enabledCursor=true;
				CursorManager.getInstance().clearAllCursor();
				jumpBtn.enabled = true;
			}
		}

		public function clearNpcCircle():void {

		}

	}
}