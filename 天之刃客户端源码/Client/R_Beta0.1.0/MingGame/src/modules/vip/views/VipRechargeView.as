package modules.vip.views
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	import modules.vip.VipDataManager;
	import modules.vip.VipModule;
	
	public class VipRechargeView extends BasePanel
	{
		public function VipRechargeView(key:String=null)
		{
			super(key);
			initView();
		}
		
		private function initView():void
		{
			this.title = "VIP续费";
			this.width = 310;
			this.height = 365;
			
			var bg:UIComponent = ComponentUtil.createUIComponent(10, 0, 290, 320);
			Style.setBorderSkin(bg);
			addChild(bg);
			
			var vy:int = 0;
			for (var i:int=0; i < 3; i ++) {
				var v:Sprite = createVipSprite(i);
				v.y = vy;
				bg.addChild(v);
				
				vy += 75;
			}
		}
		
		private function createVipSprite(index:int):Sprite
		{
			var s:Sprite = new Sprite;
			var card:Object = VipDataManager.getInstance().vipCard[index];
			var item:BaseItemVO = ItemLocator.getInstance().getObject(card.typeid);
			var image:Image = new Image;
			image.source = item.maxico;
			image.x = 11;
			image.y = 8;
			s.addChild(image);
			
			var tf:TextFormat = new TextFormat;
			tf.bold = true;
			tf.color = ItemConstant.COLOR_VALUES2[item.color];
			var name:TextField = ComponentUtil.createTextField(item.name, 85, 12, tf, 100, 25, s);
			ComponentUtil.createTextField(card.gold + "元宝", 85, 30, null, 80, 25, s);
			ComponentUtil.createTextField("VIP" + (index + 1), 85, 46, null, 50, 25, s);
			
			var btn:Button = ComponentUtil.createButton("购买并使用", 205, 44, 75, 26, s);
			btn.name = index.toString();
			btn.addEventListener(MouseEvent.CLICK, btnClickHandler);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y = 75;
			line.width = 290;
			s.addChild(line);
			
			return s;
		}
		
		private function btnClickHandler(evt:Event):void
		{
			var target:Button = Button(evt.currentTarget);
			VipModule.getInstance().vipActiveTos(int(target.name)+1);
		}
	}
}