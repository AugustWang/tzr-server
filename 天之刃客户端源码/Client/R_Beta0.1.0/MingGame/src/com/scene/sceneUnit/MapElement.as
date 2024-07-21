package com.scene.sceneUnit {
	import com.globals.GameConfig;
	import com.scene.WorldManager;
	import com.scene.sceneData.EnterPoint;
	import com.scene.sceneData.MapElementVo;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneUnit.baseUnit.UnMutualElement;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;

	import flash.geom.Point;

	public class MapElement extends UnMutualElement {
		private var _vo:MapElementVo;
		private var nameTxt:RoleNameItem;
		private var mapName:String;

		public function MapElement(vo:MapElementVo) {
			super();
			_vo=vo;
			var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(_vo.tx, 0, _vo.ty))
			this.x=p.x;
			this.y=p.y;
			var thingURL:String;
			switch (vo.itemType) {
				case EnterPoint.BLACKGROUND_ITEM:
					//txt.text="背景素材";
					if (vo.avatarId == "左" || vo.avatarId == "左上" || vo.avatarId == "左下" || vo.avatarId == "右" || vo.avatarId == "右上" || vo.avatarId == "右下") {
						_thing=new Thing;
						nameTxt=new RoleNameItem();
						var url:String=GameConfig.EFFECT_SCENE + "roadSign/";
						switch (vo.avatarId) {
							case "左":
								url+="signpost_l.swf";
								break;
							case "左上":
								url+="signpost_lu.swf";
								break;
							case "左下":
								url+="signpost_ld.swf";
								break;
							case "右":
								url+="signpost_r.swf";
								break;
							case "右上":
								url+="signpost_ru.swf";
								break;
							case "右下":
								url+="signpost_rd.swf";
								break;
						}
						thingURL=url;
						if (vo.id == 0) { //开封地图里面跳到本国京城
							mapName="边城";
						} else if (vo.id == 1) {
							mapName="太平村";
						} else {
							mapName="往" + WorldManager.getMapName(vo.id);
						}
					}
					break;
				case EnterPoint.PLAYGROUND_ITEM:
					break;
				case EnterPoint.LIVE_POINT:
					break;
				case EnterPoint.BOGEY:
					//txt.text="怪物点";
					break;
				case EnterPoint.NPC:
					//txt.text="NPC点";
					break;
			}
			if (thingURL != null && mapName != null) {
				init(thingURL);
			}
		}

		override protected function onLoadComplete(e:ThingsEvent):void {
			super.onLoadComplete(e);
			nameTxt.y=-int(e.data) - 20;
		}

		override public function init(skinURL:String):void {
			super.init(skinURL);
			_thing.gotoAndStop(0);
			nameTxt=new RoleNameItem(mapName);
			nameTxt.y=-_thing.height - 20;
			addChild(nameTxt);
		}
	}
}