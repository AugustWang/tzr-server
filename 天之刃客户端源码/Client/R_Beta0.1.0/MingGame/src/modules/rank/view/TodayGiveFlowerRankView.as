package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.FlowerItemRender;
	import modules.rank.view.items.GiveFlowerItemRender;
	
	public class TodayGiveFlowerRankView extends Sprite
	{
		private var levelGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function TodayGiveFlowerRankView()
		{
			super();
			levelGrid = new DataGrid();
			this.addChild(levelGrid);
			levelGrid.width = 435;
			levelGrid.height = 305//295;
			levelGrid.mouseEnabled = false;
			levelGrid.addColumn("排 名",50);
			levelGrid.addColumn("玩 家",92);
			levelGrid.addColumn("送花得分",60);
			levelGrid.addColumn("宗 族",92);
			levelGrid.addColumn("国 家",50);
			levelGrid.addColumn("称 号",95);
			levelGrid.itemHeight = 25;
			levelGrid.itemRenderer = GiveFlowerItemRender;
			levelGrid.list.setOverItemSkin(skin);
			levelGrid.list.setSelectItemSkin(skin);
		}
		
		public function setNull():void{
			levelGrid.dataProvider = [];
			levelGrid.invalidateDisplayList();
		}
		
		public function changeData(todayGiveArr:Array):void{
			
			if(todayGiveArr.length+1<11){
				levelGrid.pageCount = todayGiveArr.length + 1;
			}else {
				levelGrid.pageCount = 11;
			}
			levelGrid.dataProvider = todayGiveArr;
			levelGrid.invalidateDisplayList();
		}
	}
}