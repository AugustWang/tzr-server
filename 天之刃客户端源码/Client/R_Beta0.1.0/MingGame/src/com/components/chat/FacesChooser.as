package com.components.chat
{
	import com.components.chat.events.ChatEvent;
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import modules.broadcast.views.Tips;
	import modules.chat.ChatModule;

	/**
	 * 表情选择器
	 */ 
	public class FacesChooser extends Sprite
	{
		public static const FACE_ICON_SIZE:Number = 24;
		private var bg:Bitmap;
		private var btn_faces:Bitmap;
		private var _width:Number;
		private var _height:Number;
		private var face_Chooser:Sprite;
		public function FacesChooser()
		{
			mouseChildren = false;
			buttonMode = useHandCursor = true;
			bg = Style.getBitmap(GameConfig.T1_UI,"send_1skin");
			addChild(bg);
			
			btn_faces =  Style.getBitmap(GameConfig.T1_VIEWUI,"face");
			btn_faces.x = bg.width - btn_faces.width >> 1;
			btn_faces.y = bg.height - btn_faces.height >> 1;
			addChild(btn_faces);
			
			addEventListener(MouseEvent.CLICK,showFacesBox);
			addEventListener(Event.REMOVED_FROM_STAGE,onRemove);
			addEventListener(MouseEvent.MOUSE_OVER,onRollOver);
			addEventListener(MouseEvent.MOUSE_OUT,onRollOut);
		}
		
		public function clearSkin():void{
			bg.visible = false;
		}
		
		private function onRollOver(event:MouseEvent):void{
			ToolTipManager.getInstance().show("选择表情",100);
		}
		
		private function onRollOut(event:MouseEvent):void{
			ToolTipManager.getInstance().hide();
		}
		
		override public function set width(value:Number) : void{
			_width = value;
			btn_faces.width = _width;
		}
		
		override public function get width() : Number{
			return _width;
		}
		
		override public function set height(value:Number) : void{
			_height = value;
			btn_faces.height = _height;
		}
		
		override public function get height() : Number{
			return _height;
		}
		
		private function createFacesBox():Boolean{
			if (ResourcePool.hasResource(GameConfig.FACES_URL)) {
				face_Chooser = new Sprite();
				face_Chooser.addEventListener(Event.ADDED_TO_STAGE,onAddToStage);
				face_Chooser.addEventListener(Event.REMOVED_FROM_STAGE,onRemoveToStage);
				var g:Graphics = face_Chooser.graphics;
				g.lineStyle(1,0xffffff);
				g.beginFill(0x000000,0.6);
				g.drawRoundRect(0,0,150,150,10,10);
				g.endFill();
				var array:Array = [];
				for(var i:int=0;i<36;i++){
					var face:Face = new Face();
					face.buttonMode=true;
					var row:int = i / 6;
					var column:int = i % 6;
					face.x = column*FACE_ICON_SIZE + 3;
					face.y = row*FACE_ICON_SIZE + 3 ;
					face.height = face.width = FACE_ICON_SIZE;
					face.source = i+1;
					face.addEventListener(MouseEvent.MOUSE_DOWN,itemClickHandler);	
					face.stop();
					face_Chooser.addChild(face);
				}
				return true;
			} else {
				ChatModule.getInstance().loadFaceResouce(showFacesBox);
				return false;
			}
		}
		
		private function onAddToStage(event:Event):void{
			for(var i:int=0;i<36;i++){
				var face:Face = face_Chooser.getChildAt(i) as Face;
				if(face){
					face.play();
				}
			}
		}
		
		private function onRemoveToStage(event:Event):void{
			for(var i:int=0;i<36;i++){
				var face:Face = face_Chooser.getChildAt(i) as Face;
				if(face){
					face.stop();
				}
			}
		}
		
		private function itemClickHandler(event:MouseEvent):void{
			var face:Face = event.currentTarget as Face;
			if(face == null)
				return;
			var evt:ChatEvent = new ChatEvent(ChatEvent.SELECTED_FACE,face.faceID);
			dispatchEvent(evt);
			onRemove(null);
			event.stopImmediatePropagation();
		}
		
		private function showFacesBox(event:MouseEvent=null):void{
			if(face_Chooser == null){
				if (createFacesBox()) {
					stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
					stage.addChild(face_Chooser);
				}
			}else{
				if(!stage.contains(face_Chooser)){
					stage.addChild(face_Chooser);
					stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
				}else{
					stage.removeChild(face_Chooser);
				}				
			}
			if(face_Chooser){
				var point:Point = this.localToGlobal(new Point(0, -150));
				face_Chooser.x = point.x;
				face_Chooser.y = point.y;
			}
		}
		
		private function onStageMouseDown(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
			if(event.target == btn_faces)return;
			stage.removeChild(face_Chooser);
		}
		
		private function onRemove(event:Event):void{
			if(face_Chooser && face_Chooser.parent){
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown);
				stage.removeChild(face_Chooser);
			}
		}
	}
}