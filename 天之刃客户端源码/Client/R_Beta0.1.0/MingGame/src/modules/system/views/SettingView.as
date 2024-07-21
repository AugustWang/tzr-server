package modules.system.views
{
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	
	import modules.system.SystemConfig;
	
	public class SettingView extends Sprite implements ISetting
	{
		private var qualityView:QualityView;
		private var soundView:SoundView;
		public function SettingView()
		{
			super();
			var leftBorder:UIComponent = ComponentUtil.createUIComponent(0,0,274,330);;
			Style.setBorderSkin(leftBorder);
			addChild(leftBorder);
			
			qualityView = new QualityView();
			qualityView.x = 5;
			qualityView.y = 3;
			leftBorder.addChild(qualityView);

			
			var rightBorder:UIComponent = ComponentUtil.createUIComponent(275,0,263,330);;
			Style.setBorderSkin(rightBorder);
			addChild(rightBorder);
			
			soundView = new SoundView();
			soundView.x = 3;
			soundView.y = 3;
			rightBorder.addChild(soundView);
		}
		
		private function createBorder(w:Number,h:Number,x:int,y:int):UIComponent{
			var border:UIComponent = ComponentUtil.createUIComponent(x,y,w,h);
			Style.setBorderSkin(border);
			border.mouseEnabled = false;
			addChild(border);
			return border;
		}
		
		public function backMusicBoxChange():void{
			if(soundView.backSoundCk.selected != SystemConfig.openBackSound){
				soundView.backSoundCk.selected = SystemConfig.openBackSound;
			}
		}
		
		public function init():void{
			soundView.init();
			qualityView.init();
		}
		
		public function save():void{
			qualityView.save();
			soundView.save();
		}
		
		public function reset():void{
			SystemConfig.resetSetting();
			qualityView.init();
			soundView.init();
		}
	}
}