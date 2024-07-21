package modules.Activity.view.itemRender
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	public class ActGoodsItem extends UIComponent
	{
		private var image:Image;
		private var num:int;
		private var txt:TextField
		public var prop_id:int;
		private const sz:int=-1;
		private const bsz:int=-2;
		private const yb:int=-3;
		private const byb:int=-4;
		
		public function ActGoodsItem(prop_id:int,mount:int)
		{
			super();
			this.prop_id=prop_id;
			var xc:BaseItemVO;
			var b:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,'packItemBg');
			this.addChild(b);
			width = b.width;
			height = b.height;
			try{
				xc=ItemLocator.getInstance().getObject(prop_id);
			}catch(e:Error){}
			
			if(xc){
				image=new Image
				image.x = image.y =4 ;
				image.source=xc.path
				this.addChild(image);
				image.addEventListener(MouseEvent.MOUSE_OVER,mouseOverFunc)
				image.addEventListener(MouseEvent.MOUSE_OUT,mouseOutFunc)
			}
			
			if(txt!=null)
			{
				txt.text = "";
				removeChild(txt);
				txt = null;
			}
			num = mount;
			if(!txt && num>1)
			{
				var tf:TextFormat = StyleManager.textFormat;
				tf.size = 11;
				txt= ComponentUtil.createTextField(num+"",0,18,tf,33,NaN,this);
				txt.filters = [new GlowFilter(0x000000,1,2,2,4,1,false,false)];
				txt.selectable = false;		
				txt.autoSize = "right";	
			}
			
		}
		private function mouseOutFunc(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		private function mouseOverFunc(e:MouseEvent):void
		{
			if(prop_id>0){
				var vo:BaseItemVO=ItemLocator.getInstance().getObject(prop_id);
				if(vo){
					var str:String=vo.name+'\n'
					ToolTipManager.getInstance().show(vo,100,e.stageX,e.stageY,"goodsToolTip")
				}
			}
			
		}
		
//		public function set num():void
//		{
//			
//		}
			
		override public function dispose():void
		{
			super.dispose()
			
			if(image)
			{
				image.dispose();
				if(image.hasEventListener(MouseEvent.MOUSE_OVER))
				{
					image.removeEventListener(MouseEvent.MOUSE_OVER,mouseOverFunc)
					image.removeEventListener(MouseEvent.MOUSE_OUT,mouseOutFunc)
				}
				image=null;
			}
		}
		
	}
}