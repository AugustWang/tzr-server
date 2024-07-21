package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.LevelItemRender;
	
	public class SoldierRankView extends Sprite
	{
		private var levelGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function SoldierRankView()
		{
			super();
			levelGrid = new DataGrid();
			this.addChild(levelGrid);
			levelGrid.width = 435;
			levelGrid.height = 305//295;
			levelGrid.mouseEnabled = false;
			levelGrid.addColumn("排 名",50);
			levelGrid.addColumn("玩 家",92);
			levelGrid.addColumn("国 家",50);
			levelGrid.addColumn("宗 族",92);
			levelGrid.addColumn("等 级",50);
			levelGrid.addColumn("称 号",105);
			levelGrid.itemHeight = 25;
			levelGrid.itemRenderer = LevelItemRender;
			levelGrid.list.setOverItemSkin(skin);
			levelGrid.list.setSelectItemSkin(skin);
		}
		
		public function changeData(soldierArr:Array):void{
			
			if(soldierArr.length+1<11){
				levelGrid.pageCount = soldierArr.length + 1;
			}else {
				levelGrid.pageCount = 11;
			}
			levelGrid.dataProvider = soldierArr;
			levelGrid.invalidateDisplayList();
		}
	}
}