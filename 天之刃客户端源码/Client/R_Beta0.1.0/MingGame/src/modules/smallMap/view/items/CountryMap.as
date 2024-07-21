package modules.smallMap.view.items {
	import com.common.FilterCommon;
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.components.DataLoading;
	import com.globals.GameConfig;
	import com.loaders.queueloader.QueueEvent;
	import com.loaders.queueloader.QueueLoader;
	import com.managers.Dispatch;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.WorldManager;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.RunVo;
	import com.scene.tile.Pt;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.ModuleCommand;
	import modules.scene.SceneDataManager;
	import modules.smallMap.SmallMapModule;
	import modules.smallMap.view.SmallSceneView;
	
	import proto.line.m_map_transfer_tos;


	/**
	 * 加载国家地图和中立地图
	 * @author
	 *
	 */
	public class CountryMap extends UIComponent {
		private var seleteabled:Boolean;
		private var mapBG:UIComponent;
		private var domestic:DisplayObject;
		private var neutrality:DisplayObject;
		private var mapNametxt:TextInput;
		private var loading:DataLoading;
		private var loaded:Boolean=false;
		private var countryArea:int; //10中立，11云州。。

		public function CountryMap() {
			super();
			mapBG = new UIComponent();
			Style.setBorderSkin(mapBG);
			mapBG.width = 732;
			mapBG.height = 386;
			addChild(mapBG);
			
			if (loaded == false) {
				loaded=true;
				loading=new DataLoading();
				loading.x=230;
				loading.y=124;
				addChild(loading);
				var queue:QueueLoader=new QueueLoader();
				queue.addEventListener(QueueEvent.ITEM_COMPLETE, onItemCompleteHandler);
				queue.addEventListener(QueueEvent.QUEUE_COMPLETE, onAllCompleteHandler);
				queue.add(GameConfig.ROOT_URL + 'com/maps/neutrality.swf');
				queue.add(GameConfig.ROOT_URL + 'com/maps/country.swf');
				queue.load();
			}

			var text:TextField = ComponentUtil.createTextField("点击场景名称可自动寻路前往", 480, -19, null, 190, 22, this);
			text.filters = FilterCommon.FONT_BLACK_FILTERS;
			mapNametxt=ComponentUtil.createTextInput(260, -21, 135, 24, this);
			mapNametxt.mouseEnabled=mapNametxt.mouseChildren=false;
			addChild(mapNametxt);
			seleteabled=true;


		}

		private function onAllCompleteHandler(evt:QueueEvent):void {
			if (loading && loading.parent) {
				loading.parent.removeChild(loading);
			}
			var id:String=SceneDataManager.mapID.toString().substr(1, 1);
			changeCountry(int(id));
		}

		public function onItemCompleteHandler(evt:QueueEvent):void {
			if (evt.loadItem.url == GameConfig.ROOT_URL + 'com/maps/country.swf') {
				domestic=Loader(evt.data).content;
				domestic.y=4;
				domestic.x = 24;
				domestic.width=720;
				domestic.height=377;
				domestic.addEventListener('countryEvent', onClickDomesticCity);
			} else if (evt.loadItem.url == GameConfig.ROOT_URL + 'com/maps/neutrality.swf') {
				neutrality=Loader(evt.data).content;
				neutrality.y=4;
				neutrality.x = 24;
				neutrality.width=560;
				neutrality.height=315;
				neutrality.addEventListener('NEUTRALITY_EVENT', onClickNeutralityCity);
			}
		}

		//点了中立区
		private function onClickNeutralityCity(e:Event):void {
			if (seleteabled) {
				var str:String=Object(e.target).clickItem;
				if (str == "10200" || str == "10201" || str == "10203" || str == "10204" || str == "10202" || str == "10205") {
					var city:CityVo=WorldManager.getCityVo(int(str));
					if (int(str) == SceneDataManager.mapID) {
						return;
					}
					if (city) {
						if (SmallSceneView.isJump == true) {
							var vo:m_map_transfer_tos=new m_map_transfer_tos;
							vo.mapid=int(str);
							vo.tx=city.livePoints[0].pt.x;
							vo.ty=city.livePoints[0].pt.z;
							Dispatch.dispatch(ModuleCommand.REQUEST_JUMP_POS, vo);
							return;
						}
						var runvo:RunVo=new RunVo();
						runvo.mapid=int(str);
						runvo.pt=new Pt(); //city.livePoints[0].pt;
						Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, runvo);
					}
				} else {
					SmallMapModule.getInstance().resetTransferBtn(false);
				}
			}
			SmallSceneView.isJump=false;
			CursorManager.getInstance().enabledCursor=true;
			CursorManager.getInstance().clearAllCursor();
		}

		private function onClickDomesticCity(e:Event):void {
			if (countryArea != SceneDataManager.inWhichArea) {
				Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, "无法寻路到别国，请通过边城-边防大将军跳转.");
				return; //当前人所在区域和所选区域不同
			}
			var str:String=Object(e.target).clickItem;
			if (str) {
				str="1" + countryArea + str;
			}
			var city:CityVo=WorldManager.getCityVo(int(str));
			if (SmallSceneView.isJump == true && SceneDataManager.isInHomeCountry == true) {
				if (int(str) == SceneDataManager.mapID) {
					return;
				}
				var vo:m_map_transfer_tos=new m_map_transfer_tos;
				vo.mapid=int(str);
				vo.tx=city.livePoints[0].pt.x;
				vo.ty=city.livePoints[0].pt.z;
				Dispatch.dispatch(ModuleCommand.REQUEST_JUMP_POS, vo);
				SmallSceneView.isJump=false;
				CursorManager.getInstance().enabledCursor=true;
				CursorManager.getInstance().clearAllCursor();
				return;
			} else {
				var runvo:RunVo=new RunVo();
				runvo.mapid=int(str);
				runvo.pt=new Pt(); //city.livePoints[0].pt;
				Dispatch.dispatch(ModuleCommand.ROLE_MOVE_TO, runvo);
			}
		}

		//跳转地图
		public function changeCountry(country_id:int):void {
			countryArea=country_id;
			var str:String='<p align="center"><FONT COLOR="#FFFFFF">' + GameConstant.getNation(countryArea) + '</FONT></p>';
			mapNametxt.textField.htmlText=str;
			flashCurrentCity();
			if (countryArea == 0) {
				if (SceneDataManager.mapData && SceneDataManager.mapData.isSub == false) {
					if (neutrality) {
						neutrality.x = mapBG.width - neutrality.width >> 1;
						neutrality.y = mapBG.height - neutrality.height >> 1;
						mapBG.addChild(this.neutrality);
					}
					if (domestic && this.contains(domestic)) {
						mapBG.removeChild(domestic);
					}
				}
			} else {
				if (domestic) {
					domestic.x = mapBG.width - domestic.width >> 1;
					domestic.y = mapBG.height - domestic.height >> 1;
					mapBG.addChild(this.domestic);
				}
				if (neutrality && this.contains(neutrality)) {
					mapBG.removeChild(neutrality);
				}
			}
		}


		//让那一个城市发光
		private function flashCurrentCity():void {
			var container:DisplayObjectContainer;
			if (countryArea == 0 && SceneDataManager.isInNeutrality == true) {
				if (neutrality) {
					container=neutrality as DisplayObjectContainer;
				}
			} else if (countryArea != 0 && SceneDataManager.isInNeutrality == false) {
				if (domestic) {
					container=domestic as DisplayObjectContainer;
				}
			} else {
				return;
			}
			if (container == null) {
				return;
			}
			var len:int=container.numChildren - 1;
			while (len > 0) {
				var item:SimpleButton=container.getChildAt(len) as SimpleButton;
				if (item) {
					item.filters=[];
				}
				len--;
			}
			var city:SimpleButton;
			if (countryArea == 0) { //中立区
				city=container.getChildByName("b_" + SceneDataManager.mapID) as SimpleButton;
				if (city) {
					city.filters=[new GlowFilter(0xffff00, 1, 10, 10)];
				}
			} else { //所在国家
				if (countryArea == GlobalObjectManager.getInstance().user.base.faction_id) { //当时是国内地图
					var str:String=SceneDataManager.mapID.toString().substr(2, 3);
					city=container.getChildByName("m_" + str) as SimpleButton;
				}
			}
		}

	}
}