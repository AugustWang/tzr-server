package modules.smallMap.view.items {
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneData.MacroPathVo;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	
	import modules.scene.SceneDataManager;
	import modules.smallMap.view.events.WorldEvent;

	/**
	 * 加载世界地图
	 * @author
	 *
	 */
	public class WorldMapView extends UIComponent {
		private var mapBG:UIComponent;
		private var content:DisplayObject;
		private var loader:Loader;
		private var loaded:Boolean=false;

		public function WorldMapView() {
			super();
			mapBG = new UIComponent();
			Style.setBorderSkin(mapBG);
			mapBG.width = 732;
			mapBG.height = 386;
			addChild(mapBG);
			if (loaded == false) {
				loaded=true;
				loader=new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
				loader.load(new URLRequest(GameConfig.ROOT_URL + 'com/maps/world.swf'));
			}
		}

		private function onCompleteHandler(evt:Event):void {
			var loadInfo:LoaderInfo=evt.currentTarget as LoaderInfo;
			loadInfo.removeEventListener(Event.COMPLETE, onCompleteHandler);
			content=loader.content;
			content.x = mapBG.width - content.width >> 1;
			content.y = mapBG.height - content.height >> 1;
			content.addEventListener('countryEvent', countryEventFunc);
			mapBG.addChild(content);
		}

		public function seleteCountry():void {
			if (content) {
				for (var i:int=0; i < 5; i++) {
					content['c_' + i].filters=[];
				}
				var startvo:MacroPathVo=new MacroPathVo(SceneDataManager.mapData.map_id, SceneDataManager.getMyPostion().pt);
				var country_id:String=startvo.mapid.toString().substr(0, 2);
				var map_id:String=startvo.mapid.toString();
				if (map_id == '10200') {
					content['c_4'].filters=[new GlowFilter(0xffff00, 1, 10, 10)];
					return;
				}
				switch (country_id) {
					case '10':
						content['c_0'].filters=[new GlowFilter(0xffff00, 1, 10, 10)];
						break;
					case '11':
						content['c_1'].filters=[new GlowFilter(0xffff00, 1, 10, 10)];
						break;
					case '12':
						content['c_2'].filters=[new GlowFilter(0xffff00, 1, 10, 10)];
						break;
					case '13':
						content['c_3'].filters=[new GlowFilter(0xffff00, 1, 10, 10)];
						break;
//					case '14':
//						content['c_4']).filters=[new GlowFilter(0xffff00,1,10,10)];
//						break;

				}

			}

		}
		private function countryEventFunc(e:Event):void {
			var str:String=Object(e.target).clickItem;
			var evt:WorldEvent=new WorldEvent(WorldEvent.COUNTRY_EVENT);
			evt.country_id=str;
			this.dispatchEvent(evt);
		}
	}
}