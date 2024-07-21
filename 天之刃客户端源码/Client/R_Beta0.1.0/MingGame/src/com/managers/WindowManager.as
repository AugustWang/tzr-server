package com.managers
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.ming.core.IDisposable;
	import com.ming.events.CloseEvent;
	import com.ming.ui.containers.Panel;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneUtils.ScenePtMath;
	import com.scene.tile.Pt;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.scene.SceneDataManager;

	/**o
	 * UI组件管理器
	 */ 
	public class WindowManager extends EventDispatcher
	{
		//弹出窗口的模式 
		public static const REMOVE:String = "remove"; //删除之前已经弹出的窗口
		public static const UNREMOVE:String = "unRemove"; //不需要移除
		
		private var modeWindows:Dictionary;
		private var windows:Dictionary;
		private var distances:Dictionary;
		private var windowContainer:DisplayObjectContainer;
		private var timeOut:uint;
		public var isMode:Boolean;
		public function WindowManager(target:IEventDispatcher=null)
		{
			super(target);
			if(instance != null){
				throw new Error("WindowManager只能被实例化一次");
			}
			windows = new Dictionary();
			modeWindows = new Dictionary();
		}
		
		private static var instance:WindowManager;
		public static function getInstance():WindowManager{
			if(instance == null){
				instance = new WindowManager();
			}
			return instance;
		}
		
		/**
		 * 注册窗口父容器
		 */ 
		public function registerWindowContainer(c:DisplayObjectContainer):void{
			windowContainer = c;
		}
		/**
		 * 打开对话框 
		 * @param window
		 * 
		 */		
		public function closeDialog(window:DisplayObject):void {
			var model:Boolean=modeWindows[window] != null;
			if (model) {
				var sprite:Sprite=modeWindows[window];
				sprite.graphics.clear();
				sprite.removeChildAt(0);
				LayerManager.alertLayer.removeChild(sprite);
				delete modeWindows[window];
				var hasMode:Boolean = false;
				for each(var w:Object in modeWindows){
					hasMode = true
				}
				isMode = hasMode;
			} else {
				window.removeEventListener(MouseEvent.MOUSE_DOWN, bringToFrontHandler);
				windowContainer.removeChild(window);
			}
		}
		/**
		 * 关闭对话框 
		 * @param window
		 * @param mode
		 * 
		 */		
		public function openDialog(window:DisplayObject, mode:Boolean=true):void {
			if (mode) {
				var sprite:Sprite=new Sprite();
				sprite.graphics.beginFill(0x000000, .4);
				sprite.graphics.drawRect(0, 0, GlobalObjectManager.GAME_WIDTH, GlobalObjectManager.GAME_HEIGHT);
				sprite.graphics.endFill();
				sprite.addChild(window);
				modeWindows[window]=sprite;
				LayerManager.alertLayer.addChild(sprite);
				isMode = true;
			} else {
				window.addEventListener(MouseEvent.MOUSE_DOWN, bringToFrontHandler);
				windowContainer.addChild(window);
			}
		}
		
		/**
		 * 弹出窗口，并关闭其它所有窗口
		 * 如果该窗口已经弹出，就关闭(并会根据判断距离目标点一定距离或者跳转场景就自动关闭)
		 */		
		public function openDistanceWindow(window:DisplayObject):void{
			var initMapId:int = SceneDataManager.mapData.map_id;
			var macroVO:MacroPathVo = SceneDataManager.getMyPostion();
			var pt:Pt = macroVO ? macroVO.pt : null;
			if(distances == null){
				distances = new Dictionary();
			}
			distances[window] = {initMapId:initMapId,pt:pt};
			popUpWindow(window,UNREMOVE);
			timeOut = setTimeout(checkDistance,500);
		}
		
		private function checkDistance():void{
			var currentMapId:int = SceneDataManager.mapData.map_id;
			var macroVO:MacroPathVo = SceneDataManager.getMyPostion();
			var currentPt:Pt = macroVO ? macroVO.pt : null;
			var hasWindows:Boolean = false;
			for(var window:Object in distances){
				hasWindows = true;
				var obj:Object = distances[window];
				if(obj.initMapId != currentMapId || currentPt == null || ScenePtMath.checkDistance(currentPt,obj.pt) > 12){
					if(window is BasePanel){
						BasePanel(window).closeWindow();
					}
					removeWindow(window as DisplayObject);
				}
			}
			if(hasWindows){
				timeOut = setTimeout(checkDistance,500);
			}else{
				clearTimeout(timeOut);
			}
		}
		/**
		 * 弹出窗口，并关闭其它所有窗口
		 * 如果该窗口已经弹出，就关闭
		 */ 
		public function popUpWindow(window:DisplayObject,mode:String = REMOVE):void{
			if(window){
				var exist:Boolean = windows[window];
				if(exist && mode == REMOVE){
					removeWindow(window);
				}else if(exist){
					bringToFront(window);
				}else if(!exist){
					MusicManager.playSound(MusicManager.WINDOWOPEN);
					windows[window] = true;
					windowContainer.addChild(window);
					addListener(window);
					window.dispatchEvent(new WindowEvent(WindowEvent.OPEN));
				}
			}
		}
		
		/**
		 * 关闭所有窗口
		 */
		public function removeAllWindow():void{
			for(var window:Object in windows){
				removeWindow(window as DisplayObject);
			}
		}
		/**
		 * 删除顶级窗口 
		 */		
		public function removeTopWindow():void{
			var size:int = windowContainer.numChildren - 1;
			while(size >= 0){
				var window:DisplayObject = windowContainer.getChildAt(size);
				if(isPopUp(window)){
					window.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
					break;
				}
				size--;
			}
		}
		
		/**
		 * 居中窗口
		 */ 
		public function centerWindow(w:DisplayObject):void{
			if(w){
				w.x = int((GlobalObjectManager.GAME_WIDTH - w.width)/2);
				w.y = int((GlobalObjectManager.GAME_HEIGHT - w.height)/2);
			}
		}
		/**
		 * 关闭指定的窗口
		 */ 
		public function removeWindow(window:DisplayObject):void{
			if(window){
				//MusicManager.playSound(MusicManager.WINDOWOPEN);
				delete windows[window];
				if(distances){
					delete distances[window];
				}
				if(window && windowContainer.contains(window)){
					windowContainer.removeChild(window);
				}
				removeListener(window);
				window.dispatchEvent(new WindowEvent(WindowEvent.CLOSEED));
			}
		}
		
		/**
		 * 关闭并卸载指定的窗口
		 */ 
		public function unLoadWindow(window:DisplayObject):void{
			if(window){
				removeWindow(window);
				if(window is IDisposable){
					IDisposable(window).dispose();
				}
			}
		}
		
		/**
		 * 是否还有窗口打开 
		 */		
		public function hasWindow():Boolean{
			for each(var flag:Object in windows){
				return true;
			}
			return false;
		}
		
		/**
		 * 判断窗口是否弹出的方法
		 */ 
		public function isPopUp(window:DisplayObject):Boolean{
			return windows[window];
		}
		
		private function addListener(window:DisplayObject):void{
			window.addEventListener(MouseEvent.MOUSE_DOWN,bringToFrontHandler);
		}
		private function removeListener(window:DisplayObject):void{
			window.removeEventListener(MouseEvent.MOUSE_DOWN,bringToFrontHandler);
		}
		
		private function bringToFrontHandler(event:MouseEvent):void{
			bringToFront(event.currentTarget as DisplayObject);
		}
		
		/**
		 * 窗口置前
		 */ 
		public function bringToFront(w:DisplayObject):void{
			if(windowContainer.getChildAt(windowContainer.numChildren - 1) != w)
			windowContainer.setChildIndex(w,windowContainer.numChildren-1);
		}
		
		public function get container():Sprite{
			return windowContainer as Sprite;
		}
	}
}