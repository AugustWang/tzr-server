package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.EvilItemRender;
	
	public class StateEvilView extends Sprite
	{
		private var stateGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function StateEvilView()
		{
			stateGrid = new DataGrid();
			stateGrid.width = 435;
			stateGrid.height = 305;
			stateGrid.mouseEnabled = false;
			stateGrid.itemHeight = 25;
			stateGrid.addColumn("排 名",50);
			stateGrid.addColumn("玩家名",94);
			stateGrid.addColumn("宗 族",94);
			stateGrid.addColumn("PK值",94);
			stateGrid.addColumn("称 号",107);
			stateGrid.list.setOverItemSkin(skin);
			stateGrid.list.setSelectItemSkin(skin);
			this.addChild(stateGrid);
		}
		
		public function changeData(stateArr:Array):void{
			if(stateArr.length+1<11){
				stateGrid.pageCount = stateArr.length + 1;
			}else {
				stateGrid.pageCount = 11;
			}
			stateGrid.dataProvider = stateArr;
			stateGrid.itemRenderer = EvilItemRender;
			stateGrid.invalidateDisplayList();
		}
	}
}