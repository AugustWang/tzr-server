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
	import modules.broadcast.views.BroadcastSelf;
	import modules.vip.VipModule;
	
	public class BigExpressionVIPView extends Sprite
	{
		private var arr:Array;
		
		public function BigExpressionVIPView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			//表情背景
			var bitmap:Bitmap = Style.getBitmap(GameConfig.BIG_EXPRESION_UI,"biaoQingVip");
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
				if (obj.type == 1) {
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
			if (VipModule.getInstance().isVip()) {
				var msg:String = UIComponent(evt.currentTarget).name;
				BigExpresionModule.getInstance().requestSendExpression(msg);
			} else if (VipModule.getInstance().isVipExpire()) {
				BroadcastSelf.logger("你的VIP已过期，<a href='event:openVip'><font color=\"#00FF00\"><u>续期</u></font></a>后才能使用VIP大表情");
			} else {
				BroadcastSelf.logger("你还不是VIP，<a href='event:openVip'><font color=\"#00FF00\"><u>成为VIP</u></font></a>才能使用VIP大表情");
			}
		}
		
		private function onRollOverHandler(evt:MouseEvent):void
		{
			var name:int = int(UIComponent(evt.currentTarget).name) - 20;
			Bitmap(arr[name]).visible = true;
			
			var tooltipName:int = int(UIComponent(evt.currentTarget).name);
			var msg:String = BigExpresionModule.tip_arr[tooltipName].name + "鼠标左键点击发送";
			ToolTipManager.getInstance().show(msg, 50);
		}
		
		private function onRollOutHandler(evt:MouseEvent):void
		{
			var name:int = int(UIComponent(evt.currentTarget).name) - 20;
			Bitmap(arr[name]).visible = false;	
			ToolTipManager.getInstance().hide();
		}
	}
}