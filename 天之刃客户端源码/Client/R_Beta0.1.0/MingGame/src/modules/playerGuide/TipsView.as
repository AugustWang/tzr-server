package modules.playerGuide
{
	import com.common.effect.ArrowEffect;
	import com.globals.GameConfig;
	import com.ming.utils.ScaleBitmap;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import modules.navigation.NavigationModule;
	
	public class TipsView extends Sprite
	{
		public static const POSITION_CHANGED:String = "POSITION_CHANGED";
		public static const LEFT:String='left'
		public static const RIGHT:String='right';
		public static const TOP:String='top'
		public static const BOTTOM:String='bottom';
		public static const NONE:String='none';
		
		public var taskId:int;
		public var targetId:int;
		public var status:int;
		private var arrow:ArrowEffect;
		private var textFiled:TextField
		private var scaleBitmap:ScaleBitmap;
		private var str:String = "";
		
		public function TipsView()
		{	
			
			mouseEnabled = mouseChildren = false;
			
			scaleBitmap = new ScaleBitmap(Style.getUIBitmapData(GameConfig.T1_UI,"tipBorder"));
			scaleBitmap.setScale9Grid(new Rectangle(10,10,98,10)); 
			addChild(scaleBitmap);
			
			textFiled=ComponentUtil.createTextField("",5,5,null,150,60,this);
			textFiled.multiline=true;
			textFiled.wordWrap=true;
			
			arrow = new ArrowEffect();
			arrow.mouseChildren = arrow.mouseEnabled = false;
			addChild(arrow);
		}
		
		
		public function show(str:String,align:String='top'):void{
			this.str = str;
			status = taskId = -1;
			NavigationModule.getInstance().isShow = false;
			textFiled.htmlText = "  "+str;
			textFiled.height = textFiled.textHeight + 5;
			var w:Number = textFiled.width+10;
			var h:Number = textFiled.height+10;
			textFiled.x = (w - textFiled.textWidth) / 2;
			scaleBitmap.setSize(w,h);
			arrow.stop();
			switch(align)
			{
				case LEFT:
					arrow.direction = ArrowEffect.LEFT;
					arrow.y = (h - arrow.height)/2+10;
					arrow.x = -arrow.width-25;
					break;
				case RIGHT:
					arrow.direction = ArrowEffect.RIGHT;
					arrow.y = (h - arrow.height)/2+10;
					arrow.x = w;
					break;
				case TOP:
					arrow.direction = ArrowEffect.TOP;
					arrow.y = -arrow.height;
					arrow.x = (w - arrow.width)/2 - 8;
					break;
				case BOTTOM:
					arrow.direction = ArrowEffect.BOTTOM;
					arrow.y = h+10;
					arrow.x = (w - arrow.width)/2 - 8;
					break;
				case NONE:
					break;	
			}
			arrow.start();
		}
		
		public function remove():void{
			status = taskId = -1;
			if(arrow){
				arrow.stop();
			}
			if(parent){
				parent.removeChild(this);
			}
		}
	}
}