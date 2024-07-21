package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.EquipItemRender;
	
	public class RefineRankView extends Sprite
	{
		private var refineGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function RefineRankView()
		{
			refineGrid = new DataGrid();
			refineGrid.width = 435;
			refineGrid.height = 305;
			refineGrid.mouseEnabled = false;
			refineGrid.itemHeight = 25;
			refineGrid.addColumn("排 名",50);
			refineGrid.addColumn("装备名",150);
			refineGrid.addColumn("玩家名",100);
			refineGrid.addColumn("国 家",58);
			refineGrid.addColumn("强化系数",81);
			refineGrid.list.setOverItemSkin(skin);
			refineGrid.list.setSelectItemSkin(skin);
			this.addChild(refineGrid);
		}
		
		public function changeData(refineArr:Array):void{
			if(refineArr.length+1<11){
				refineGrid.pageCount = refineArr.length + 1;
			}else {
				refineGrid.pageCount = 11;
			}
			refineGrid.dataProvider = refineArr;
			refineGrid.itemRenderer = EquipItemRender;
			refineGrid.invalidateDisplayList();
		}
	}
}