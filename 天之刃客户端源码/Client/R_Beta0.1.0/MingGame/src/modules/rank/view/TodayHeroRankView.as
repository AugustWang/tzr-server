package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.HeroItemRender;
	
	public class TodayHeroRankView extends Sprite
	{
		private var heroGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function TodayHeroRankView()
		{
			heroGrid = new DataGrid();
			this.addChild(heroGrid);
			heroGrid.width = 435;
			heroGrid.height = 305;
			heroGrid.mouseEnabled = false;
			heroGrid.addColumn("排 名",50);
			heroGrid.addColumn("玩家名",85);
			heroGrid.addColumn("宗 族",85);
			heroGrid.addColumn("等 级",50);
			heroGrid.addColumn("战功值",66);
			heroGrid.addColumn("称 号",102);
			heroGrid.itemHeight = 25; 
			heroGrid.itemRenderer = HeroItemRender;
			heroGrid.list.setOverItemSkin(skin);
			heroGrid.list.setSelectItemSkin(skin);
		}
		
		public function setNull():void{
			heroGrid.dataProvider = [];
			heroGrid.invalidateDisplayList();
		}
		
		public function changeData(todayHeroArr:Array):void{
			
			if(todayHeroArr.length+1<11){
				heroGrid.pageCount = todayHeroArr.length + 1;
			}else {
				heroGrid.pageCount = 11;
			}
			heroGrid.dataProvider = todayHeroArr;
			heroGrid.invalidateDisplayList();
		}
	}
}