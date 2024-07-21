package modules.duplicate.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.MessageIconManager;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.duplicate.views.items.DuplicateLeaderItem;
	
	public class DuplicateListView extends BasePanel
	{

		private var closeButton:Button;
		private var _dataProvier:Array;
		private var titleText:TextField;
		private var dataGrid:DataGrid;
		public function DuplicateListView()
		{
			super();
			initView();
		}
		
		private function initView():void{
			title = "师徒副本队长提示";
			width = 398 + 36;
			height = 301;
			
//			panelSkin = Style.getInstance().panelSkinNoBg;
//			var npcBg:Sprite = Style.getViewBg("npc_bg");
//			npcBg.x = 1;
//			npcBg.width= this.width - 2;
//			npcBg.height=263;
//			addChild(npcBg);
			
			dataGrid = new DataGrid();
			dataGrid.itemRenderer = DuplicateLeaderItem;
			dataGrid.x = 22;
			dataGrid.y = 77;
			dataGrid.width = this.width - 2 - 40;
			dataGrid.height = 156;
			dataGrid.addColumn("序号",31);
			dataGrid.addColumn("玩家",104);
			dataGrid.addColumn("令牌",80);
			dataGrid.addColumn("使用位置",52);
			dataGrid.addColumn("令牌状态",52);
			dataGrid.addColumn("队长指挥",52);
			dataGrid.itemHeight = 22;
			dataGrid.pageCount = 7;
			dataGrid.verticalScrollPolicy = ScrollPolicy.OFF;
			//dataGrid.addEventListener(ItemEvent.ITEM_CLICK,onItemClick);
			addChild(dataGrid);
			
			titleText = ComponentUtil.createTextField("",22,8,null,this.width - 2 -40,69,this);
			titleText.multiline =true;
			titleText.wordWrap = true;
			titleText.htmlText = "说明：\n \t\t队长拥有队员手中的令牌信息，并且只有队长才能看到地图上" +
				"道具使用坐标。队长指挥队员依次按【一】、【二】、【三】" +
				"……的顺序召唤并击败怪物，即可率领队伍走向最终胜利！"
			

			closeButton = ComponentUtil.createButton("关闭",width - 60 >> 1 ,234,60,25,this);
			closeButton.addEventListener(MouseEvent.CLICK,onCloseHandler);
			showCloseButton = false;
			showHelpButton = false;
		}
		
		private function onItemClick(event:ItemEvent):void{
			
		}
		public function set dataProvider(value:Array):void{
			_dataProvier = value;
			dataGrid.dataProvider = _dataProvier;
		}
		
		private function onCloseHandler(event:MouseEvent):void{
			this.closeWindow();
		}
		override public function closeWindow(save:Boolean=false):void{
			super.closeWindow(save);
			BroadcastSelf.logger("<font color='#FF0000'>打开背包，双击“队长令牌”打开师徒副本帮助界面</font>");
			Tips.getInstance().addTipsMsg("打开背包，双击“队长令牌”打开师徒副本帮助界面");
			//ICON重构			MessageIconManager.startFlickTeamLeaderIcon();
		}
	}
}