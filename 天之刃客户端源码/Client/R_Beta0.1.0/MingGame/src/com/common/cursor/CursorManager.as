package com.common.cursor {
	import com.scene.sceneManager.LoopManager;

	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;

	public class CursorManager extends EventDispatcher {
		private var lib:Dictionary;
		private var cursors:Dictionary;
		private var currentName:String;
		private var cursorLayer:Stage;
		private var cursor:BaseCursor;
		private var queue:Array;
		public var enabledCursor:Boolean=true; //禁止使用鼠标管理器
		public static var handlerEnabled:Boolean; //是否禁止其它操作

		public function CursorManager() {
			lib=new Dictionary();
			cursors=new Dictionary();
			queue=[];
		}

		public static function init(c:Stage):void {
			getInstance().cursorLayer=c;
		}

		private static var instance:CursorManager;

		public static function getInstance():CursorManager {
			if (instance == null) {
				instance=new CursorManager();
			}
			return instance;
		}

		public function registerCursor(name:String, cursorClass:Class):void {
			lib[name]=cursorClass;
		}

		public function getCursor(name:String):BaseCursor {
			var cursor:BaseCursor=cursors[name];
			if (cursor == null) {
				var cursorClass:Class=lib[name];
				cursor=new cursorClass();
				cursors[name]=cursor;
			}
			return cursor;
		}

		public function disposeCursor(name:String):void {
			delete cursors[name];
		}

		public function setCursor(name:String, param:Object=null):void {
			if (!enabledCursor)
				return;
			if (currentName != name) {
				if (currentName != "") {
					queue.push(currentName);
					removeCurrentCursor();
				}
				currentName=name;
				cursor=getCursor(name);
				cursor.x=cursorLayer.mouseX;
				cursor.y=cursorLayer.mouseY;
				cursor.normalHandler();
				cursorLayer.addChild(cursor);
				hideSystemCursor();
				addActionListener();
			}
			if (cursor) {
				cursor.data=param;
			}
		}

		public function get currentCursor():String {
			return currentName;
		}

		public function getCursorInstance():BaseCursor {
			return cursor;
		}

		private function addActionListener():void {
			LoopManager.addToFrame(this, syncMouse);
//			cursorLayer.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			cursorLayer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			cursorLayer.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function removeActionListener():void {
			LoopManager.removeFromFrame(this);
//			cursorLayer.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			cursorLayer.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			cursorLayer.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		private function syncMouse():void {
			if (cursor) {
				cursor.x=cursorLayer.mouseX;
				cursor.y=cursorLayer.mouseY;
			}
		}

		private function onMouseMove(event:MouseEvent):void {
			if (cursor) {
				cursor.x=cursorLayer.mouseX;
				cursor.y=cursorLayer.mouseY;
			}
		}

		private function onMouseDown(event:MouseEvent):void {
			if (cursor) {
				cursor.downHandler(event);
			}
		}

		private function onMouseUp(event:MouseEvent):void {
			if (cursor) {
				cursor.upHandler(event);
			}
		}

		private function removeCurrentCursor():void {
			if (cursor && cursor.parent) {
				cursor.parent.removeChild(cursor);
				cursor.stop();
			}
			cursor=null;
			removeActionListener();
			showSystemCursor();
		}

		public function hideCursor(name:String):void {
			if (!enabledCursor)
				return;
			var c:BaseCursor=cursors[name];
			if (c && c.parent) {
				c.parent.removeChild(c);
				c.stop();
				removeActionListener();
				showSystemCursor();
				currentName="";
				cursor=null;
				var newCursorName:String=queue.pop();
				if (newCursorName && newCursorName != "") {
					setCursor(newCursorName);
				}
			} else {
				var index:int=queue.indexOf(name);
				if (index != -1) {
					queue.splice(index, 1);
				}
			}
		}

		public function clearAllCursor():void {
			if (!enabledCursor)
				return;
			currentName="";
			if (cursor && cursor.parent) {
				cursor.parent.removeChild(cursor);
				cursor.stop();
			}
			cursor=null;
			removeActionListener();
			showSystemCursor();
			queue=[];
		}

		public static function hideSystemCursor():void {
			Mouse.hide();
		}

		public static function showSystemCursor():void {
			Mouse.show();
		}
	}
}