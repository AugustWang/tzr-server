package modules.warOfCity.view
{
	import com.ming.ui.controls.core.UIComponent;
	
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.utils.ComponentUtil;
	
	import proto.line.m_warofcity_panel_toc;
	
	public class WarCitySignView extends BasePanel
	{
		private var grid:DataGrid;
		
		public function WarCitySignView()
		{
			super();
			title="报名城市争夺赛";
			width=500;
			height=210;
		}
		
		override protected function init():void
		{
			var backBg:UIComponent=ComponentUtil.createUIComponent(4, 0, 490, 180);
			Style.setBorderSkin(backBg);
			backBg.mouseEnabled=false;
			addChild(backBg);
			grid=new DataGrid;
			grid.x=7;
			grid.y=3;
			grid.width=490;
			grid.height=200;
			grid.addColumn("地图列表", 108);
			grid.addColumn("占领门派", 108);
			grid.addColumn("报名费用", 80);
			grid.addColumn("门派等级要求", 100);
			grid.addColumn("申请报名", 108);
			grid.itemRenderer=WarCityItem;
			grid.pageCount=7;
			grid.itemHeight=24;
			addChild(grid);
		}
		
		public function update(vo:m_warofcity_panel_toc):void
		{
			grid.dataProvider=vo.cities;
		}
	}
}