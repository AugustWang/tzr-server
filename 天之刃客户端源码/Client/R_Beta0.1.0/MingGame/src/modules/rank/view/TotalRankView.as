package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.EquipItemRender;
	
	public class TotalRankView extends Sprite
	{
		private var tatolGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function TotalRankView()
		{
			tatolGrid = new DataGrid();
			tatolGrid.width = 435;
			tatolGrid.height = 305;
			tatolGrid.mouseEnabled = false;
			tatolGrid.itemHeight = 25;
			tatolGrid.addColumn("排 名",50);
			tatolGrid.addColumn("装备名",150);
			tatolGrid.addColumn("玩家名",100);
			tatolGrid.addColumn("国 家",58);
			tatolGrid.addColumn("装备评分",81);
			tatolGrid.itemRenderer = EquipItemRender;
			tatolGrid.list.setOverItemSkin(skin);
			tatolGrid.list.setSelectItemSkin(skin);
			this.addChild(tatolGrid);
		}
		public function changeData(totalArr:Array):void{
			if(totalArr.length+1<11){
				tatolGrid.pageCount = totalArr.length + 1;
			}else {
				tatolGrid.pageCount = 11;
			}
			tatolGrid.dataProvider = totalArr;
			tatolGrid.invalidateDisplayList();
		}
	}
}