package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.EvilItemRender;
	
	public class WorldEvilView extends Sprite
	{
		private var worldGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function WorldEvilView()
		{
			worldGrid = new DataGrid();
			this.addChild(worldGrid);
			worldGrid.width = 435;
			worldGrid.height = 305;
			worldGrid.mouseEnabled = false;
			worldGrid.itemHeight = 25;
			worldGrid.addColumn("排 名",50);
			worldGrid.addColumn("玩家名",94);
			worldGrid.addColumn("国 家",94);
			worldGrid.addColumn("PK值",94);
			worldGrid.addColumn("称 号",107);
			worldGrid.list.setOverItemSkin(skin);
			worldGrid.list.setSelectItemSkin(skin);
		}
		
		public function changeData(worldArr:Array):void{
			if(worldArr.length+1<11){
				worldGrid.pageCount = worldArr.length + 1;
			}else {
				worldGrid.pageCount = 11;
			}
			
			worldGrid.dataProvider = worldArr;
			worldGrid.itemRenderer = EvilItemRender;
			worldGrid.invalidateDisplayList();
		}
	}
}