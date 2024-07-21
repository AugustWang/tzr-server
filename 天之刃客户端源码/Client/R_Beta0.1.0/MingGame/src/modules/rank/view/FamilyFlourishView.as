package modules.rank.view
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.skins.Skin;
	
	import flash.display.Sprite;
	
	import com.components.DataGrid;
	import modules.rank.view.items.FamilyItemRender;
	
	public class FamilyFlourishView extends Sprite
	{
		private var familyGrid:DataGrid;
		private var skin:Skin = new Skin();
		public function FamilyFlourishView()
		{
			familyGrid = new DataGrid();
			this.addChild(familyGrid);
			familyGrid.width = 435;
			familyGrid.height = 305;
			familyGrid.mouseEnabled = false;
			familyGrid.itemHeight = 25;
			familyGrid.addColumn("排 名",50);
			familyGrid.addColumn("门派名",90);
			familyGrid.addColumn("门派等级",70);
			familyGrid.addColumn("掌门",90);
			familyGrid.addColumn("门派繁荣度",70);
			familyGrid.addColumn("国家",68);
			familyGrid.itemRenderer = FamilyItemRender;
			familyGrid.list.setOverItemSkin(skin);
			familyGrid.list.setSelectItemSkin(skin);
		}
		
		public function changeData(familyFlourIshArr:Array):void{
			
			if(familyFlourIshArr.length+1<11){
				familyGrid.pageCount = familyFlourIshArr.length + 1;
			}else {
				familyGrid.pageCount = 11;
			}
			familyGrid.dataProvider = familyFlourIshArr;
			familyGrid.invalidateDisplayList();
		}
	}
}