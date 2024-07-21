package com.scene.sceneUnit {
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.scene.sceneUtils.SceneUnitType;
	
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	import modules.collect.CollectModule;
	import modules.scene.SceneModule;
	import modules.scene.cases.MyRoleControler;
	
	import proto.common.p_map_collect;

	public class Collection extends MutualThing {
		private var _pvo:p_map_collect;
		private var _nameTxt:TextField;
		private var _name:String;

		public function Collection() {
			sceneType=SceneUnitType.COLLECT_TYPE;
			super();
		}

		public function reset(vo:p_map_collect):void {
			id=vo.id;
			_pvo=vo;
			_name=vo.name;
			init(CollectModule.getInstance().createSkin(vo.typeid));
			var l:int = SourceManager.getInstance().getResource(_thing.path).getLight(AvatarConstant.ACTION_DEFULT);
			if(l > 1){
				_thing.play(10,true);
			}
			createChildren();
		}

		override protected function onLoadComplete(event:ThingsEvent):void {
			super.onLoadComplete(event);
			if (_nameTxt != null && _thing != null) {
				_nameTxt.y=-_thing.height - 5;
			}
			var l:int = SourceManager.getInstance().getResource(_thing.path).getLight(AvatarConstant.ACTION_DEFULT);
			if(l > 1){
				_thing.play(10,true);
			}
		}

		public function createChildren():void {
			if (_nameTxt == null) {
				_nameTxt=new TextField;
				_nameTxt.selectable=false;
				_nameTxt.mouseEnabled=false;
				_nameTxt.autoSize=TextFieldAutoSize.CENTER;
				_nameTxt.text=name;
				_nameTxt.filters=[new GlowFilter(0xfff799, 1, 2, 2, 200)]
				_nameTxt.x=-_nameTxt.width / 2;
				if (_thing.isLoaderComplete()) {
					_nameTxt.y=-_thing.height - 5
				} else {
					_nameTxt.y=-75;
				}
				_nameTxt.text=_name;
				addChild(_nameTxt);
			}
//			if(_lighting == null){
//				_lighting=new Thing();
//				_lighting.load(createURL('guang'));
//				_lighting.play(ThingFrameFrequency.COLLECT);
//				_lighting.mouseChildren = false;
//				_lighting.mouseEnabled = false;
//				addChild(_lighting);
//			}
		}

		public function get pvo():p_map_collect {
			return _pvo;
		}

		override public function mouseOver():void {
			super.mouseOver();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().setCursor(CursorName.PICK);
			}
		}

		override public function mouseOut():void {
			super.mouseOut();
			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
				CursorManager.getInstance().clearAllCursor();
			}
		}

		override public function mouseDown():void {
			MyRoleControler.getInstance().onClickUnit(this);
		}
	}
}