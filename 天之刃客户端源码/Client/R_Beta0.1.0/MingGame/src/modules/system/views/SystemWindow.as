package modules.system.views
{
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	
	import modules.system.SystemConfig;
	import modules.system.SystemModule;
	
	public class SystemWindow extends BasePanel
	{
		private var nav:TabNavigation;
		private var settingView:SettingView;
		public var gamesettingView:OnHookSettingView;
		private var reset:Button;
		private var startFlight:Button;
		private var saveConfig:Button;
		public function SystemWindow()
		{
			super("SystemWindow");
		}
		
		override protected function init():void{
			width = 565;
			height = 440;
			 
			addTitleBG(446);
			addImageTitle("title_setting");
			addContentBG(32,8,24);
			
			nav = new TabNavigation();
			nav.x = 13;
			nav.tabBarPaddingLeft = 5;
			nav.width = 541;
			nav.height = 310;
			settingView = new SettingView();
			gamesettingView = new OnHookSettingView();
			gamesettingView.y = settingView.y = 6;
			
			nav.addItem("系统设置",settingView,65,25);
			nav.addItem("自动打怪",gamesettingView,65,25);
			nav.addItem("快捷键列表",new ShortcutList(),75,25);
			nav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onChanged);
			addChild(nav);
			
			reset = ComponentUtil.createButton("恢复默认值",10,370,105,26,this,Style.setDeepRedBtnStyle);
			reset.addEventListener(MouseEvent.CLICK,resetSetting);
			startFlight = ComponentUtil.createButton("开启挂机",390,370,70,26,this,Style.setDeepRedBtnStyle);
			startFlight.addEventListener(MouseEvent.CLICK,onStartFlight);
			saveConfig = ComponentUtil.createButton("保存配置",475,370,70,26,this,Style.setDeepRedBtnStyle);
			saveConfig.addEventListener(MouseEvent.CLICK,onSaveConfig);
			addEventListener(WindowEvent.OPEN,onOpen);
		}
		
		public function selectIndex(value:int):void{
			nav.selectedIndex = value;	
		}
	
		public function skillReset():void{
			gamesettingView.skillReset();
		}
		
		private function onSaveConfig(e:MouseEvent):void{
			if(nav.selectedIndex == 0){
				settingView.save();
			}else{
				gamesettingView.save();
			}
			SystemModule.showSuccessMsg = true;
			SystemConfig.save();
		}
		
		private function resetSetting(event:MouseEvent):void{
			if(nav.selectedIndex == 0){
				settingView.reset();
			}else{
				gamesettingView.reset();
			}
		}
		
		private function onChanged(event:TabNavigationEvent):void{
			if(event.index == 0){
				startFlight.visible = false;
				saveConfig.visible = true;
				reset.visible = true;
			}else if(event.index == 1){
				startFlight.visible = true;	
				saveConfig.visible = true;
				reset.visible = true;
			}else{
				startFlight.visible = false;	
				saveConfig.visible = false;
				reset.visible = false;
			}
		}
		
		public function backMusicBoxChange():void{
			if(settingView){
				settingView.backMusicBoxChange();
			}
		}
		
		public function teamCheckBoxChange():void{
			if(settingView){
				gamesettingView.teamCheckBoxChange();
			}
		}
		
		public function changeHitMonster():void{
			if(gamesettingView){
				gamesettingView.changeHitMonster();
			}
		}
		
		private function onOpen(event:WindowEvent):void{
			settingView.init();
			gamesettingView.init();
		}
		
		public function updateQualityView():void
		{
			settingView.init();
		}
		
		private function onStartFlight(event:MouseEvent):void{
			gamesettingView.save();
			SystemConfig.save();
			SystemModule.getInstance().startFlight();
			closeWindow();
		}
	}
}