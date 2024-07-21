package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.GraceItemRender;
	
	public class GraceRankView extends Sprite
	{
		private var graceGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function GraceRankView()
		{
			graceGrid = new DataGrid();
			this.addChild(graceGrid);
			graceGrid.width = 435;
			graceGrid.height = 305;
			graceGrid.mouseEnabled = false;
			graceGrid.itemHeight = 25;
			graceGrid.addColumn("本周排名",70);
			graceGrid.addColumn("门派名",90);
			graceGrid.addColumn("本周门派战功",96);
			graceGrid.addColumn("上周排名",70);
			graceGrid.addColumn("上周门派战功",113);
			graceGrid.list.setOverItemSkin(skin);
			graceGrid.list.setSelectItemSkin(skin);
		}
		
		public function changeData(graceArr:Array):void{
			if(graceArr.length+1<11){
				graceGrid.pageCount = graceArr.length + 1;
			}else {
				graceGrid.pageCount = 11;
			}
			graceGrid.dataProvider = graceArr;
			graceGrid.itemRenderer = GraceItemRender;
			graceGrid.invalidateDisplayList();
		}
	}
}