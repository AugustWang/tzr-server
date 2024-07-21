package modules.finery.views.item
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.TileList;
	
	import modules.mypackage.vo.BaseItemVO;
	
	
	public class MaterialShopList extends Canvas
	{
		private var tileList:TileList;
		public function MaterialShopList()
		{
			super();
		}
		
		public function initUI(materials:Array):void{
			this.width = 260;
			this.height = 135;
			this.x = 6;
			this.y = 4;
			this.verticalScrollPolicy = ScrollPolicy.AUTO;
			
			tileList = new TileList();
			this.addChild(tileList);
			tileList.itemWidth = 120;
			tileList.itemHeight = 49;
			tileList.columnCount = 2;
			tileList.hPadding = 2;
			tileList.vPadding = 1;
			tileList.y = 2;
			tileList.x = 3;
			tileList.itemRender = MaterialShopItemRender;
			tileList.dataProvider = materials;
		}
		
		public function checkSelet(ids:Array,binds:Array):void{
			for(var i:int=0; i < tileList.numChildren; i++){
				var item:MaterialShopItemRender = tileList.getChildAt(i) as MaterialShopItemRender;
				if(item){
					item.select(false);
					if(hasIn(ids,binds,item.data as BaseItemVO)){
						item.select(true);
					}
				}
			}
		}
		
		public function hasIn(ids:Array,binds:Array,itemVO:BaseItemVO):Boolean{
			for(var i:int=0;i<ids.length;i++){
				if(ids[i] == itemVO.typeId && itemVO.bind == binds[i]){
					ids.splice(i,1);
					binds.splice(i,1);
					return true;
				}
			}
			return false;
		}
		
		public function update(value:Array):void{
			tileList.dataProvider = value;
			tileList.height=(value.length / 2 + 1) * 51;
			tileList.validateNow();
			this.updateSize();
		}
	}
}