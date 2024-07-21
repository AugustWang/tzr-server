package com.components {
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.LayerManager;
	import com.ming.managers.ToolTipManager;
	import com.scene.sceneUnit.baseUnit.things.thing.Thing;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	import modules.stat.StatModule;

	public class MessageIcon extends Sprite {
		public var hasClick:Boolean = false;
		public var createTime:Number;
		public var getModuleId:int;
		public var actionType:String;
		public var tip:String="";
		public var callBack:Function;
		private var icon:Sprite;
		private var thing:Thing;

		public function MessageIcon(iconName:String) {
			createTime=getTimer();
			getModuleId=0;
			mouseChildren=false;
			buttonMode=useHandCursor=true;
			icon=Style.getViewBg(iconName);
			if(icon){
				addChild(icon);
				with (graphics) {
					clear();
					beginFill(0, 0);
					drawRect(0, 0, icon.width, icon.height);
					endFill();
				}
			}
			addEventListener(MouseEvent.CLICK, onItemClick);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}


		override public function get height():Number {
			return icon.height;
		}

		override public function get width():Number {
			return icon.width;
		}

		private function onRemovedFromStage(event:Event):void {
			stopFlick();
		}

		public function setFilters():void {
			//this.filters = [new GlowFilter(0xffff00,1,6,6,4)];
		}

		public function startFlick():void {
			if (thing == null) {
				thing=new Thing();
				thing.x=thing.y=-5;
				thing.load(GameConfig.OTHER_PATH + "border.swf");
			}
			addChild(thing);
			thing.play(8, true);
		}

		public function stopFlick():void {
			if (thing) {
				thing.stop();
				if (thing.parent) {
					thing.parent.removeChild(thing);
				}
			}
		}

		private function onItemClick(event:MouseEvent):void {
			hasClick = true;
			if (getModuleId != 0) {
				StatModule.getInstance().addButtonHandler(getModuleId);
			}
			if (callBack != null) {
				callBack.apply(null, null);
			} else {
				Dispatch.dispatch(actionType);
			}
		}

		private function onRollOver(event:MouseEvent):void {
			if (tip != "") {
				ToolTipManager.getInstance().show(tip);
			}
		}

		private function onRollOut(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		public function show():void {
			LayerManager.uiLayer.addIcon(this);
		}

		public function hide():void {
			LayerManager.uiLayer.removeIcon(this);
		}
	}
}