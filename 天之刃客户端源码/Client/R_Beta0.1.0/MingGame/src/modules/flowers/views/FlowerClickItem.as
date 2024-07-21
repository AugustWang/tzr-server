package modules.flowers.views
{
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	
	public class FlowerClickItem extends DragUIComponent
	{
		private var _nameTf:TextField; 
		
		private var _sendBtn:Button;
		private var _cancelBtn:Button;
		
		public function FlowerClickItem()
		{
			super();
			this.width = 182;//215;
			this.height = 107;//155;
			//			this.allowDrag = false;
			
			Style.setRectBorder(this);
			this.showCloseButton = true;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 176;
			line.height = 2;
			line.x = 3;
			line.y = 28;
			addChild(line);
			
			init();
		}
		
		private function init():void
		{
			var tf:TextFormat = new TextFormat("Tahoma",15,0xffffff);
			
			_nameTf = ComponentUtil.createTextField("",8,6,tf,175,23,this);
			
			_sendBtn = ComponentUtil.createButton("赠送",14,52, 60,22, this);
			_sendBtn.addEventListener(MouseEvent.CLICK,onSendFlower);
			
			_cancelBtn = ComponentUtil.createButton("取消",80,52, 60,22, this);
			_cancelBtn.addEventListener(MouseEvent.CLICK, onCancel);
		}
		
		//model 里先保存 vo.id 使用成功后背包里清除该物品。
		public function setData(vo:Object):void  // goods Vo 
		{
			if(vo)
			{
				//vo.num , 
				var color:String = ItemConstant.COLOR_VALUES[vo.color];
				_nameTf.htmlText = HtmlUtil.font(vo.name,color,15);
			}
		}
		
		private function onSendFlower(e:MouseEvent):void
		{
			//model. openInputToWho(); //300 148
		}
		
		private function onCancel(e:MouseEvent):void
		{
			this.parent.removeChild(this);
			dispose();
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		override public function dispose():void
		{
			super.dispose();
			if(_sendBtn&&_sendBtn.hasEventListener(MouseEvent.CLICK))
			{
				_sendBtn.removeEventListener(MouseEvent.CLICK,onSendFlower);
				_cancelBtn.removeEventListener(MouseEvent.CLICK, onCancel);
			}
			while(numChildren>0)
			{
				var obj:DisplayObject = getChildAt(0) as DisplayObject;
				
				removeChild(obj);
				obj = null;
			}
		}
		
		
	}
}


