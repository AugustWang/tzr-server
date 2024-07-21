package modules.countrytreasure.views
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.countrytreasure.CountryTreasureModule;
	
	import proto.line.m_country_treasure_points_toc;
	
	public class CountryPointsView extends Sprite
	{
		private var bg:Image;
		private var txt:TextField;
		private var list:List;
		private var quitBtn:Button;
		
		public function CountryPointsView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			this.x = GlobalObjectManager.GAME_WIDTH - 178;
			this.y = 158;
			
			bg = new Image;
			bg.source = GameConfig.ROOT_URL + "com/ui/robKing/robKingResult.png";
			addChild(bg);
			
			txt = new TextField;
			txt.selectable = false;
			txt.textColor = 0xffffff;
			txt.text = "宝藏积分";
			txt.x = 70;
			txt.y = 7;
			addChild(txt);
			
			list = new List;
			list.bgSkin = null;
			list.itemRenderer = CountryPointsItem;
			list.x = 24;
			list.y = 40;
			list.width = 140;
			list.height = 120;
			list.mouseEnabled = false;
			list.mouseChildren = false;
			addChild(list);
			
			var noticeTxt:TextField = ComponentUtil.createTextField("积分越高，获得经验越多", 25, 110, null, 150, 20, this);
			noticeTxt.textColor = 0x00FF00;
			
			quitBtn = new Button;
			quitBtn.x = 46;
			quitBtn.y = 140;
			quitBtn.label = "离开副本";
//			quitBtn.bgSkin = Style.getButtonSkin("fbBtnUp", "fbBtnOver", "fbBtnDisable", null, GameConfig.T1_UI);
			addChild(quitBtn);
			quitBtn.addEventListener(MouseEvent.CLICK, quitFbHandler);
		}
		
		private function quitFbHandler(e:Event):void
		{
			Alert.show("确定要离开大明宝藏副本？", "提示", yesHandler);
			
			function yesHandler():void{
				CountryTreasureModule.getInstance().doQuitCountryTreasureTos();
			}
		}
		
		public function update(vo:m_country_treasure_points_toc):void
		{
			vo.points.sortOn("points", Array.DESCENDING|Array.NUMERIC);
			list.dataProvider = vo.points;
		}
		
		public function onStageResize():void
		{
			this.x = GlobalObjectManager.GAME_WIDTH - 178;
		}
	}
}