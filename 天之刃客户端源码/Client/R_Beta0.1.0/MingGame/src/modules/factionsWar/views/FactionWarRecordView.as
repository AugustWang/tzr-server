package modules.factionsWar.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.ming.managers.ToolTipManager;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.factionsWar.FactionWarDataManager;
	import modules.factionsWar.views.items.FactionRecordItem;
	
	public class FactionWarRecordView extends BasePanel
	{
		private var grid:DataGrid;
		private var factionMoney:TextField;
		
		public function FactionWarRecordView(key:String=null)
		{
			super(key);
			title="国战记录";
			initView();
		}
		
		private function initView():void
		{
			this.width=540;
			this.height=320;
		
			grid=new DataGrid();
			Style.setBorderSkin(grid);
			grid.x=10;
			grid.y=2;
			grid.width=520;
			grid.height=250;
			grid.itemHeight=21;
			grid.addColumn("时间 ", 130);
			grid.addColumn("记录", 390);
			grid.itemRenderer=FactionRecordItem;
			addChild(grid);
			
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "right");
			factionMoney=ComponentUtil.createTextField("当前国库银0锭0两0文", 2, 254, tf, 516, 22, this);
			factionMoney.textColor = 0x00ff00;
			factionMoney.mouseEnabled=true;
			factionMoney.addEventListener(MouseEvent.MOUSE_OVER, showFactionMoneyToolTip);
			factionMoney.addEventListener(MouseEvent.MOUSE_OUT, hideFactionMoneyToolTip);
		}
		
		private function showFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show("国库最大容量120锭，每天固定获得税收20锭");
		}
		
		private function hideFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		
		public function update(arr:Array):void
		{
			arr.sortOn("tick", Array.DESCENDING | Array.NUMERIC);
			grid.dataProvider=arr;
			factionMoney.text="当前国库银子：" + MoneyTransformUtil.silverToOtherString(FactionWarDataManager.factionMoney);
		}
	}
}