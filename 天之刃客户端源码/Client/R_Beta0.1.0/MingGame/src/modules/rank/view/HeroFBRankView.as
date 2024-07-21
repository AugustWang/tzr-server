package modules.rank.view
{
	import com.components.DataGrid;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import modules.rank.view.items.HeroFBItemRender;
	import modules.rank.view.items.PetItemRender;
	
	public class HeroFBRankView extends Sprite
	{
		private var heroFBGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function HeroFBRankView()
		{
			heroFBGrid = new DataGrid();
			heroFBGrid.width = 435;
			heroFBGrid.height = 305;
			heroFBGrid.mouseEnabled = false;
			heroFBGrid.itemHeight = 25;
			heroFBGrid.addColumn("排 名",50);
			heroFBGrid.addColumn("玩家名",100);
			heroFBGrid.addColumn("国家",50);
			heroFBGrid.addColumn("关数",90);
			heroFBGrid.addColumn("得分",128);
			heroFBGrid.list.setOverItemSkin(skin);
			heroFBGrid.list.setSelectItemSkin(skin);
			this.addChild(heroFBGrid);
		}
		
		public function changeData(heroFbArr:Array):void{
			if(heroFbArr.length+1<11){
				heroFBGrid.pageCount = heroFbArr.length + 1;
			}else {
				heroFBGrid.pageCount = 11;
			}
			heroFBGrid.dataProvider = heroFbArr;
			heroFBGrid.itemRenderer = HeroFBItemRender;
			heroFBGrid.invalidateDisplayList(); 
		}
	}
}