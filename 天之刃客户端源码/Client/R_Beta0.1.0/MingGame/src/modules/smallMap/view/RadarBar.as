package modules.smallMap.view
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.WorldManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.scene.SceneDataManager;
	
	public class RadarBar extends Sprite
	{
		private var textField:TextField;
		private var btn:UIComponent;
		public var radarView:RadarView;
		public function RadarBar()
		{
			super();
			var tf:TextFormat = Style.textFormat;
			tf.align = "center";
			tf.color = 0xffffff;
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"smapTopLeft"));
			textField = ComponentUtil.createTextField("",13,0,tf,120,NaN,this);
			textField.filters = [new GlowFilter(0x000000,1,2,2,3,3)];
			btn = new UIComponent();
			btn.x = 158;
			btn.y = 5;
			btn.width = btn.height = 17;
			btn.setToolTip("隐藏/显示小地图");
			btn.bgSkin = Style.getButtonSkin("hideSMap_1skin","hideSMap_2skin","hideSMap_3skin","",GameConfig.T1_UI);
			btn.addEventListener(MouseEvent.CLICK,showHideSmallMap);
			addChild(btn);
		}
		
		
		private function showHideSmallMap(event:MouseEvent):void{
			if(radarView){
				radarView.visible = !radarView.visible;
			}	
		}
		
		public function changeMap():void{
			textField.text=WorldManager.getMapName(SceneDataManager.mapID);
		}
		
	}
}