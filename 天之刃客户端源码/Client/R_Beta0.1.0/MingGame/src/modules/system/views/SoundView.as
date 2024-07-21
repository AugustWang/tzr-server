package modules.system.views
{
	import com.common.FilterCommon;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.ming.managers.SoundManager;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.Slider;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.system.SystemConfig;
	import modules.system.SystemModule;
	
	public class SoundView extends Sprite
	{
		private var qualitys:Array ;
		private var qualitySlider:Slider;
		private var backSoundslider:Slider;
		private var flightSoundslider:Slider;
		public var backSoundCk:CheckBox; //背景音效
		private var flightSoundCk:CheckBox; //战斗音效
		private var chkFormat:TextFormat;

		public function SoundView()
		{
			chkFormat = Style.textFormat;
			chkFormat.color = 0xa0ecef;
			qualitys = [StageQuality.LOW,StageQuality.MEDIUM,StageQuality.HIGH,StageQuality.BEST];
			
			var boldtf:TextFormat = Style.textFormat;
			boldtf.bold = true;
			boldtf.color = 0xffff00;
			var title:TextField = ComponentUtil.createTextField("声音设置",8,20,boldtf,NaN,NaN,this);
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			backSoundCk = ComponentUtil.createCheckBox("开启背景音乐",26,40,this);
			backSoundCk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			
			backSoundCk.addEventListener(Event.CHANGE,onChangeBackSound);
			backSoundslider = createSlider(30,65,0,100,1);
			backSoundslider.addEventListener(Event.CHANGE,soundVolumnChanged)
			var bg1:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"slider1");
			bg1.x = 25;
			bg1.y = 82;
			addChildAt(bg1,0);

			flightSoundCk = ComponentUtil.createCheckBox("开启游戏音效",26,110,this);
			flightSoundCk.textFilter = FilterCommon.FONT_BLACK_FILTERS;
			
			flightSoundCk.addEventListener(Event.CHANGE,onChangeFlightSound);
			flightSoundslider = createSlider(30,135,0,100,1);
			flightSoundslider.addEventListener(Event.CHANGE,onFlightVolumnChanged);
			var bg2:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"slider1");
			bg2.x = 25;
			bg2.y = 152;
			addChildAt(bg2,0);
			
			title = ComponentUtil.createTextField("画面设置",8,180,boldtf,NaN,NaN,this);
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			qualitySlider = createSlider(30,205,0,135,45);;
			qualitySlider.addEventListener(Event.CHANGE,qualityChangeFunc)
			addChild(qualitySlider);
			var bg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"slider2");
			bg.x = 25;
			bg.y = 222;
			addChildAt(bg,0);
		}
		
		private function onChangeBackSound(event:Event):void{
			SystemConfig.openBackSound = backSoundCk.selected;
			SystemModule.getInstance().changeBackMusic();
		}
		
		private function soundVolumnChanged(event:Event):void
		{
			SoundManager.getInstance().sceneVolume=backSoundslider.value/100;
			SystemConfig.sceneVolume = backSoundslider.value;
		}
		
		private function onChangeFlightSound(e:Event):void
		{
			if(flightSoundCk.selected){
				SoundManager.getInstance().soundVolume = SystemConfig.gameVolume/100;
			}else{
				SoundManager.getInstance().soundVolume = 0;
			}
			SystemConfig.openGameSound = flightSoundCk.selected;
		}
		
		private function onFlightVolumnChanged(event:Event):void
		{
			SoundManager.getInstance().soundVolume=flightSoundslider.value/100;
			SystemConfig.gameVolume = flightSoundslider.value;
		}
		
		private function qualityChangeFunc(e:Event):void
		{
			var index:int=int(qualitySlider.value/45)
			LayerManager.stage.quality=qualitys[index];
			SystemConfig.imageQuality = index;
		}
		
		public function init():void{
			backSoundCk.selected = SystemConfig.openBackSound;
			backSoundslider.value = SystemConfig.sceneVolume;
			flightSoundCk.selected = SystemConfig.openGameSound;
			flightSoundslider.value = SystemConfig.gameVolume;
			qualitySlider.value = SystemConfig.imageQuality*45;
		}
		
		private function createSlider(xValue:Number,yValue:Number,min:Number,max:Number,snapInterval:Number):Slider{
			var slider:Slider = new Slider();
			slider.x = xValue;
			slider.y = yValue;
			slider.minimum = min;
			slider.maximum = max;
			slider.width = 187;
			slider.height = 15;
			slider.backSize = 13;
			slider.handlerSize = 24;
			slider.showFill = true;
			slider.fillSize = 11;
			slider.fillSkin = Style.getSkin("sliderFill",GameConfig.T1_UI,new Rectangle(2,2,183,7));
			slider.tickInterval = snapInterval;
			addChild(slider);
			return slider;
		}

		public function save():void{
			SystemConfig.openBackSound = backSoundCk.selected;
			SystemConfig.sceneVolume = backSoundslider.value;
			SystemConfig.openGameSound = flightSoundCk.selected;
			SystemConfig.gameVolume = flightSoundslider.value;
			SystemConfig.imageQuality = qualitySlider.value/45;
		}
	}
}