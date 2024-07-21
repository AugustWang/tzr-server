package com.scene.sceneUnit {
	import com.globals.GameConfig;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.sceneKit.RoleNameItem;
	import com.scene.sceneUnit.baseUnit.UnMutualElement;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;

	public class MapTransfer extends UnMutualElement {
		private var _vo:MapTransferVo;
		private var nameTxt:RoleNameItem;

		public function MapTransfer(vo:MapTransferVo) {
			super();
			_vo=vo;
			var p:Point=TileUitls.getIsoIndexMidVertex(new Pt(_vo.tx, 0, _vo.ty))
			this.x=p.x;
			this.y=p.y;
			init(GameConfig.EFFECT_SCENE + 'gata.swf');
		}

		override public function init(skinURL:String):void {
			super.init(skinURL);
			_thing.play(10, true);
			nameTxt=new RoleNameItem();
			addChild(nameTxt);
		}

		override protected function onLoadComplete(event:ThingsEvent):void {
			super.onLoadComplete(event);
			nameTxt.y=-int(event.data) - 20;
		}
	}
}