package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.EquipItemRender;
	
	public class InsertRankView extends Sprite
	{
		private var insertGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function InsertRankView()
		{
			insertGrid = new DataGrid();
			insertGrid.width = 435;
			insertGrid.height = 305;
			insertGrid.mouseEnabled = false;
			insertGrid.itemHeight = 25;
			insertGrid.addColumn("排 名",50);
			insertGrid.addColumn("装备名",150);
			insertGrid.addColumn("玩家名",100);
			insertGrid.addColumn("国 家",58);
			insertGrid.addColumn("镶嵌系数",81);
			insertGrid.list.setOverItemSkin(skin);
			insertGrid.list.setSelectItemSkin(skin);
			this.addChild(insertGrid);
		}
		
		public function changeData(insertArr:Array):void{
			if(insertArr.length+1<11){
				insertGrid.pageCount = insertArr.length + 1;
			}else {
				insertGrid.pageCount = 11;
			}
			insertGrid.dataProvider = insertArr;
			insertGrid.itemRenderer = EquipItemRender;
			insertGrid.invalidateDisplayList();
		}
	}
}