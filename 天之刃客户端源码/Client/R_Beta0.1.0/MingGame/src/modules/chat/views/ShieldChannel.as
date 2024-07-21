package modules.chat.views
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.chat.ChatType;
	
	public class ShieldChannel extends Sprite
	{
		public var shieldHandler:Function;
		private var btn_shield:Button;
		private var vBox:Sprite;
		
		private var obj:Object;
		
		public function ShieldChannel()
		{
			super();
			btn_shield = createButtton("屏蔽",60,0,0, "屏蔽", false);
			btn_shield.addEventListener(MouseEvent.CLICK,onShieldChannel);
			addChild(btn_shield);
			
			obj = {};
			obj[ChatType.WORLD_CHANNEL] = false;
			obj[ChatType.FAMILY_CHANNEL] = false;
			obj[ChatType.COUNTRY_CHANNEL] = false;
			obj[ChatType.PRIVATE_CHANNEL] = false;
		}
		
		private function onShieldChannel(event:MouseEvent):void{
			if(vBox == null){
				createChannels();
			}else{
			   vBox.visible = !vBox.visible;
			}
			if(vBox.visible){
				stage.addEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			}
		}
		
		private function onStageMouseUp(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_UP,onStageMouseUp);
			if(event.target == btn_shield)return;
			vBox.visible = false;
		}
		
		private function createChannels():void{
			vBox = new Sprite();
			vBox.addChild(createButtton("世界",60,0,0,ChatType.WORLD_CHANNEL));
			vBox.addChild(createButtton("门派",60,0,22,ChatType.FAMILY_CHANNEL));
			vBox.addChild(createButtton("国家",60,0,44,ChatType.COUNTRY_CHANNEL));
			vBox.addChild(createButtton("私聊",60,0,66,ChatType.PRIVATE_CHANNEL));
			vBox.y = 22;
			addChild(vBox)
		}
			
		private function createButtton(label:String,w:Number,xValue:int,yValue:int, name:String,addListener:Boolean = true):Button{
			var createButton:Button = new Button();
			createButton.label = label;
			createButton.width = w;
			createButton.x = xValue;
			createButton.y = yValue;
			createButton.name = name;
			if(addListener)
				createButton.addEventListener(MouseEvent.CLICK, onClick);
			return createButton;
		}
		
		private function onClick(evt:Event):void
		{
			var btn:Button = evt.target as Button;
			obj[btn.name] = !obj[btn.name];
			
			if(obj[btn.name] == true)
			{
				btn.label = btn.label + "(蔽)";
			}
			else
			{
				btn.label = btn.label.substr(0, btn.label.length - 3);
			}
			
			if(shieldHandler != null)
			{
				shieldHandler.apply(null, [obj[btn.name], btn.name]);
			}
		}
		
	}
}