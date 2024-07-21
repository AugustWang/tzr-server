package com.scene.sceneUnit {
	import com.scene.sceneUnit.baseUnit.MutualThing;
	import com.scene.sceneUnit.baseUnit.things.ThingsEvent;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	import com.scene.sceneUtils.SceneUnitType;
	
	import modules.trap.TrapModule;
	
	import proto.common.p_map_trap;

	public class Trap extends MutualThing {
		private var _pvo:p_map_trap;

		public function Trap() {
			sceneType=SceneUnitType.TRAP_TYPE;
			super();
		}

		public function reset(vo:p_map_trap):void {
			id=vo.trap_id;
			_pvo=vo;
			init(TrapModule.getInstance().createSkin(vo.trap_type));
			if(vo.trap_type == 2){
				_thing.play(ThingFrameFrequency.EFFECT,true);
			}
		}

		override protected function onLoadComplete(event:ThingsEvent):void {
//			super.onLoadComplete(event);
//			if (_nameTxt != null && _thing != null) {
//				_nameTxt.y=-_thing.height - 5;
//			}
		}

		public function createChildren():void {
//			if (_nameTxt == null) {
//				_nameTxt=new TextField;
//				_nameTxt.selectable=false;
//				_nameTxt.mouseEnabled=false;
//				_nameTxt.autoSize=TextFieldAutoSize.CENTER;
//				_nameTxt.text=name;
//				_nameTxt.filters=[new GlowFilter(0xfff799, 1, 2, 2, 200)]
//				_nameTxt.x=-_nameTxt.width / 2;
//				if (_thing.isLoaderComplete()) {
//					_nameTxt.y=-_thing.height - 5
//				} else {
//					_nameTxt.y=-75;
//				}
//				_nameTxt.text=_name;
//				addChild(_nameTxt);
//			}
		}

		public function get pvo():p_map_trap {
			return _pvo;
		}

		override public function mouseOver():void {
			//super.mouseOver();
//			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
//				CursorManager.getInstance().setCursor(CursorName.COLLECT);
//			}
		}

		override public function mouseOut():void {
			//super.mouseOut();
//			if (SceneModule.isFollowFoot == false && SceneModule.isLookInfo == false) {
//				CursorManager.getInstance().clearAllCursor();
//			}
		}

		override public function mouseDown():void {
//			MyRoleControler.getInstance().onClickUnit(this);
		}
	}
}