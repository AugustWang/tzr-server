package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.PetItemRender;
	
	public class PetTotalRankView extends Sprite
	{
		private var petGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function PetTotalRankView()
		{
			petGrid = new DataGrid();
			petGrid.width = 435;
			petGrid.height = 305;
			petGrid.mouseEnabled = false;
			petGrid.itemHeight = 25;
			petGrid.addColumn("排 名",50);
			petGrid.addColumn("宠物ID",70);
			petGrid.addColumn("主人",100);
			petGrid.addColumn("国家",50);
			petGrid.addColumn("宠物类型",100);
			petGrid.addColumn("评分",48);
			petGrid.list.setOverItemSkin(skin);
			petGrid.list.setSelectItemSkin(skin);
			this.addChild(petGrid);
		}
		
		public function changeData(petArr:Array):void{
			
			if(petArr.length+1<11){
				petGrid.pageCount = petArr.length + 1;
			}else {
				petGrid.pageCount = 11;
			}
			petGrid.dataProvider = petArr;
			petGrid.itemRenderer = PetItemRender;
			petGrid.invalidateDisplayList(); 
		}
	}
}