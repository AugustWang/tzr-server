package modules.bigExpresion.view
{
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.bigExpresion.BigExpresionDataManager;
	import modules.bigExpresion.BigExpresionModule;
	
	public class BigExpressionNormalView extends Sprite
	{
		private var arr:Array;
		
		public function BigExpressionNormalView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			//表情背景
			var bitmap:Bitmap = Style.getBitmap(GameConfig.BIG_EXPRESION_UI,"biaoqing");
			this.addChild(bitmap);
			
			//处理显示框
			var sprite:Sprite = new Sprite();
			sprite.x = 11;
			sprite.y = 7;
			this.addChild(sprite);
			sprite.buttonMode = true;
			sprite.useHandCursor = true;
			
			var overBg:Bitmap;
			var uiBg:UIComponent;
			arr = new Array;
			for each (var obj:Object in BigExpresionDataManager.getInstance().arr) {
				if (obj.type == 0) {
					overBg = Style.getBitmap(GameConfig.BIG_EXPRESION_UI,"kuang_over");
					overBg.visible = false;
					uiBg = new UIComponent();
					uiBg.addChild(overBg);
					uiBg.width = overBg.width;
					uiBg.height = overBg.height;
					uiBg.name = obj.id + "";
					uiBg.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
					uiBg.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
					uiBg.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
					sprite.addChild(uiBg);
					arr.push(overBg);
				}
			}
			LayoutUtil.layoutGrid(sprite, 4, 6, 6);
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void
		{
			var msg:String = UIComponent(evt.currentTarget).name;
			BigExpresionModule.getInstance().requestSendExpression(msg);
		}
		
		private function onRollOverHandler(evt:MouseEvent):void
		{
			var name:int = int(UIComponent(evt.currentTarget).name);
			Bitmap(arr[name]).visible = true;
			var msg:String = BigExpresionModule.tip_arr[name].name + "鼠标左键点击发送";
			ToolTipManager.getInstance().show(msg, 50);
		}
		
		private function onRollOutHandler(evt:MouseEvent):void
		{
			var name:int = int(UIComponent(evt.currentTarget).name)
			Bitmap(arr[name]).visible = false;	
			ToolTipManager.getInstance().hide();
		}
	}
}