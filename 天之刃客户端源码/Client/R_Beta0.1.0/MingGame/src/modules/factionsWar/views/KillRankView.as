package modules.factionsWar.views
{
	import com.components.BasePanel;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class KillRankView extends BasePanel
	{
		//资源出口
		private var _loader:SourceLoader;
		//我的击杀数
		private var _myKill:TextField;
		//目前点击按钮
		private var currentBTN:Button;
		public function KillRankView(loader:SourceLoader)
		{
			super();
			this._loader = loader;
			initUI();
		}
		
		private function initUI():void
		{
			this.width = 710;
			this.height = 450;
			//背景
			var bg:BitmapData = this._loader.getBitmapData("m2_sc_bg01");
			var bg_skin:Skin = new Skin();
			bg_skin.width = 710;
			bg_skin.height = 470;
			bg_skin.skinBitmapData = bg;
			this.bgSkin = bg_skin;
			//杀人榜title
			var name:Bitmap = new Bitmap(this._loader.getBitmapData("title"));
			name.x = 330;
			name.y = -15;
			this.addChild(name);
			//左边的list背景
			var list_bg:Bitmap = new Bitmap(this._loader.getBitmapData("m2_sc_bg3"));
			var list:Sprite = new Sprite();
			list.addChild(list_bg);
			list.x = 9;
			list.y = 28;
			this.addChild(list);
			//按钮皮肤
			var buttonSkin:ButtonSkin = new ButtonSkin();
			buttonSkin.skin = this._loader.getBitmapData("qh_shop_3");
			buttonSkin.overSkin = this._loader.getBitmapData("qh_shop_1");
			buttonSkin.selectedSkin = this._loader.getBitmapData("qh_shop_2");
			//本国击杀榜
			var homeKill:Button = new Button();
			homeKill.bgSkin = buttonSkin;
			homeKill.x = 4;
			homeKill.y = 5;
			homeKill.width = 95;
			homeKill.height = 25;
			homeKill.label = "本国击杀榜";
			list.addChild(homeKill);
			homeKill.addEventListener(MouseEvent.CLICK,onClickHandle);
			
			//按钮皮肤
			var buttonSkin2:ButtonSkin = new ButtonSkin();
			buttonSkin2.skin = this._loader.getBitmapData("qh_shop_3");
			buttonSkin2.overSkin = this._loader.getBitmapData("qh_shop_1");
			buttonSkin2.selectedSkin = this._loader.getBitmapData("qh_shop_2");
			//敌国击杀榜
			var enemyKill:Button = new Button();
			enemyKill.bgSkin = buttonSkin2;
			enemyKill.x = homeKill.x;
			enemyKill.y = homeKill.y + homeKill.height + 2;
			enemyKill.width = homeKill.width;
			enemyKill.height = homeKill.height;
			enemyKill.label = "敌国击杀榜";
			list.addChild(enemyKill);
			enemyKill.addEventListener(MouseEvent.CLICK,onClickHandle);
			
			//按钮皮肤
			var buttonSkin3:ButtonSkin = new ButtonSkin();
			buttonSkin3.skin = this._loader.getBitmapData("qh_shop_3");
			buttonSkin3.overSkin = this._loader.getBitmapData("qh_shop_1");
			buttonSkin3.selectedSkin = this._loader.getBitmapData("qh_shop_2");
			//总击杀榜
			var allKill:Button = new Button();
			allKill.bgSkin = buttonSkin3;
			allKill.x = enemyKill.x;
			allKill.y = enemyKill.y + enemyKill.height + 2;
			allKill.width = enemyKill.width;
			allKill.height = enemyKill.height;
			allKill.label = "总击杀榜";
			list.addChild(allKill);
			allKill.addEventListener(MouseEvent.CLICK,onClickHandle);
			//我的击杀数的text
			var myKillText:TextField = new TextField();
			myKillText.text = "我的击杀数";
			myKillText.height = 20;
			myKillText.x = 18;
			myKillText.y = list.height + list.y - 90;
			list.addChild(myKillText);
			//我的击杀数
			_myKill = new TextField();
			_myKill.x = 40;
			_myKill.y = myKillText.y + myKillText.height;
			_myKill.text = "56";
			list.addChild(_myKill);
			//右边的datagrid背景
			var datagrid:Bitmap = new Bitmap(this._loader.getBitmapData("m2_sc_bg2"));
			datagrid.x = 113;
			datagrid.y = 28;
			this.addChild(datagrid);
		}
		
		protected function onClickHandle(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var clickBTN:Button = event.currentTarget as Button;
			if(currentBTN && currentBTN != clickBTN){
				(currentBTN.bgSkin as ButtonSkin).selected = false;
				currentBTN = clickBTN;
				(currentBTN.bgSkin as ButtonSkin).selected = true;
			}else{
				currentBTN = clickBTN;
				(currentBTN.bgSkin as ButtonSkin).selected = true;
			}
		}
		
		public function openWindow():void{
			if(WindowManager.getInstance().isPopUp(this) != true){
				WindowManager.getInstance().popUpWindow(this);
				WindowManager.getInstance().centerWindow(this);
			}
		}
	}
}