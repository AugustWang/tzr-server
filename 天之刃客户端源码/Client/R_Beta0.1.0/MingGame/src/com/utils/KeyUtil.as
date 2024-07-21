package com.utils {
	import com.common.InputKey;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.Dictionary;

	/**
	 * @author Administrator
	 *
	 */
	public class KeyUtil {

		public static const KEY_DOWN:String = "keyDown";

		private var stage:Stage;
		private var keys:Array;
		private static var instance:KeyUtil;
		private var downMap:Dictionary;
		private var listeners:Vector.<Function>;

		public var enabled:Boolean = true;

		public function KeyUtil() {
			keys = new Array();
			listeners = new Vector.<Function>();
			downMap = new Dictionary();
			stage = LayerManager.stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(Event.DEACTIVATE, onFocusOutHandler);
		}

		public static function getInstance():KeyUtil {
			if (instance == null) {
				instance = new KeyUtil();
			}
			return instance;
		}

		private function onMouseDown(event:MouseEvent):void {
			var text:TextField = event.target as TextField;
			if (text && text.type == TextFieldType.INPUT) {
				IME.enabled = true;
			} else {
				IME.enabled = false;
				if(text == null && event.target is InteractiveObject){
					stage.focus = event.target as InteractiveObject;
				}
			}
		}

		private function onFocusOutHandler(event:Event):void {
			keys.length = 0;
		}

		public function onKeyDown(event:KeyboardEvent):void {
			if (enabled == false)
				return;
			addSytemKey(event);
		}

		public function onKeyUp(event:KeyboardEvent):void {
			if (enabled == false || WindowManager.getInstance().isMode)
				return;
			addSytemKey(event);
			execute(event);
		}

		private function execute(event:KeyboardEvent):void {
			var text:TextField = event.target as TextField;
			if (text && text.type == TextFieldType.INPUT) {
				IME.enabled = true;
				return;
			} else {
				IME.enabled = false;
			}
			if (InputKey.isValidCode(event.keyCode)) {
				if (keys.indexOf(event.keyCode) == -1) {
					keys.push(event.keyCode);
				}
				keys.sort();
				var handler:Function = downMap[keys.toString()];
				if (handler != null) {
					handler();
				} else {
					for each (handler in listeners) {
						handler(event);
					}
				}
				keys.splice(keys.indexOf(event.keyCode), 1);
			}
		}

		private function addSytemKey(event:KeyboardEvent):void {
			var shiftkeyIndex:int = keys.indexOf(InputKey.SHIFT);
			if (shiftkeyIndex == -1 && event.shiftKey) {
				keys.push(InputKey.SHIFT);
			} else if (shiftkeyIndex != -1 && !event.shiftKey) {
				keys.splice(shiftkeyIndex, 1);
			}

			var ctrkeyIndex:int = keys.indexOf(InputKey.CONTROL);
			if (ctrkeyIndex == -1 && event.ctrlKey) {
				keys.push(InputKey.CONTROL);
			} else if (ctrkeyIndex != -1 && !event.ctrlKey) {
				keys.splice(ctrkeyIndex, 1);
			}

			var altkeyIndex:int = keys.indexOf(InputKey.ALT);
			if (altkeyIndex == -1 && event.altKey) {
				keys.push(InputKey.ALT);
			} else if (altkeyIndex != -1 && !event.altKey) {
				keys.splice(altkeyIndex, 1);
			}
		}

		public function isSystemKey(keyCode:int):Boolean {
			return keyCode == InputKey.CONTROL || keyCode == InputKey.SHIFT || keyCode == InputKey.ALT;
		}

		public function checkKeyCodes(keyCodes:Array):Boolean {
			if (keyCodes.length != keys.length)
				return false;
			for each (var keyCode:int in keyCodes) {
				if (keys.indexOf(keyCode) == -1) {
					return false;
				}
			}
			return true;
		}

		public function isKeyDown(keyCode:int):Boolean {
			return keys.indexOf(keyCode) != -1;
		}

		public function addKeyHandler(handler:Function, codes:Array = null):void {
			if (codes) {
				codes.sort();
				downMap[codes.toString()] = handler;
			} else {
				listeners.push(handler);
			}
		}

		public function removeKeyHandler(handler:Function):void {
			delete downMap[handler];
			var index:int = listeners.indexOf(handler);
			if (index != -1) {
				listeners.splice(index, 1);
			}
		}
	}
}