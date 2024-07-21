package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.FlowerItemRender;
	
	public class HundredFlowerRankView extends Sprite
	{
		private var levelGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function HundredFlowerRankView()
		{
			super();
			levelGrid = new DataGrid();
			this.addChild(levelGrid);
			levelGrid.width = 435;
			levelGrid.height = 305//295;
			levelGrid.mouseEnabled = false;
			levelGrid.addColumn("排 名",50);
			levelGrid.addColumn("玩 家",92);
			levelGrid.addColumn("魅力值",60);
			levelGrid.addColumn("宗 族",92);
			levelGrid.addColumn("国 家",50);
			levelGrid.addColumn("称 号",95);
			levelGrid.itemHeight = 25;
			levelGrid.itemRenderer = FlowerItemRender;
			levelGrid.list.setOverItemSkin(skin);
			levelGrid.list.setSelectItemSkin(skin);
		}
		
		public function changeData(hundredFlowerArr:Array):void{
			
			if(hundredFlowerArr.length+1<11){
				levelGrid.pageCount = hundredFlowerArr.length + 1;
			}else {
				levelGrid.pageCount = 11;
			}
			levelGrid.dataProvider = hundredFlowerArr;
			levelGrid.invalidateDisplayList();
		}
	}
}