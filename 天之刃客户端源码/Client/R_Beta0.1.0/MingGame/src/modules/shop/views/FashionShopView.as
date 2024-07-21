package modules.shop.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.GameScene;
	import com.scene.sceneUnit.baseUnit.things.avatar.Avatar;
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class FashionShopView extends Sprite implements IShopSellView
	{
		private var shopTileView:ShopTileView;
		private var fashionBg:UIComponent;
		private var avatar:Avatar;
		private var resumeBtn:Button;
		private var buyBtn:Button;
		private var placard:TextField;
		public function FashionShopView()
		{
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			initView();
		}
		
		private function initView():void{
			shopTileView = new ShopTileView();
			shopTileView.HPADDING = 1;
			shopTileView.y = 2;
			shopTileView.columns = 2;
			addChild(shopTileView);
			
			fashionBg = new UIComponent();
			fashionBg.y = 6;
			fashionBg.x = 430;
			fashionBg.width = 216;
			fashionBg.height = 352
			Style.setBorderSkin(fashionBg);
			addChild(fashionBg);
			
			var bodyContainer:Image = new Image();
			bodyContainer.x = 30;
			bodyContainer.y = 10;
			bodyContainer.mouseChildren = bodyContainer.mouseEnabled = false;
			bodyContainer.source = GameConfig.getBackImage("equipRoleBg");
			addChild(bodyContainer);
			
			fashionBg.addChild(bodyContainer);
			
			avatar = new Avatar()
			avatar.y = 154;
			avatar.x = 110;
			fashionBg.addChild(avatar);
			
			resumeBtn = ComponentUtil.createButton("还原",30,180,75,25,fashionBg);
			buyBtn = ComponentUtil.createButton("搭配购买",115,180,75,25,fashionBg);
			
			resumeBtn.addEventListener(MouseEvent.CLICK,resumeHandler);
			buyBtn.addEventListener(MouseEvent.CLICK,buyHandler);
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.x
			line.y = resumeBtn.y + resumeBtn.height + 10;
			line.width = fashionBg.width - 10;
			fashionBg.addChild(line);
			
			var tf:TextFormat = Style.themeTextFormat;
			tf.leading = 5;
			placard = ComponentUtil.createTextField("",15,line.y+10,tf,fashionBg.width-30,100,fashionBg);
			placard.wordWrap = true;
			placard.multiline = true;
			placard.htmlText = "限时抢购栏将会不定时刷新限量物品供玩家抢购，抢购的物品从"+HtmlUtil.font("5折免费","#ffff00")+"都有哦！请"+HtmlUtil.font("密切留意","#ffff00")+"商城最新限时抢购物品，你将会有想不到的意外收获！";
			
			addEventListener(Event.REMOVED_FROM_STAGE,removedFromStage);
		}
		
		private function removedFromStage(event:Event):void{
			avatar.stop();
		}
		
		private function resumeHandler(event:MouseEvent):void{
			
		}
		
		private function buyHandler(event:MouseEvent):void{
			
		}
		
		public function set dataProvider(values:Array):void{
			if(shopTileView){
				shopTileView.dataProvider = values;
				avatar.initSkin(GameScene.getInstance().hero.pvo.skin);
				avatar.play(AvatarConstant.ACTION_STAND,AvatarConstant.DIR_DOWN,8,true);
			}
		}
		
		public function set pageCount(value:int):void{
			if(shopTileView){
				shopTileView.pageCount = value;
			}
		}
	}
}