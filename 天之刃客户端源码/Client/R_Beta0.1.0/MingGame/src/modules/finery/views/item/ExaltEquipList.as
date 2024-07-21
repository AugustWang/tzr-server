package modules.finery.views.item
{
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.TileList;
	import com.utils.ComponentUtil;
	
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.finery.StoveEquipFilter;

	public class ExaltEquipList extends EquipList
	{
		public var selectOid:int = 0;
		public function ExaltEquipList(type:String="")
		{
			super(type);
			init();
			this.height = 141;
		}
		
		override protected function init():void {
			width=268;
			height=184;
			this.x = 2;
			this.y = 2;
			verticalScrollPolicy=ScrollPolicy.ON;
			
			tileList=new TileList();
			this.addChild(tileList);
			tileList.itemWidth=120;
			tileList.itemHeight=49;
			tileList.columnCount=2;
			tileList.hPadding=2;
			tileList.vPadding=1;
			tileList.y = 2;
			tileList.x = 3;
			tileList.itemRender=ExaltEquipItemRender;
			var tipTFFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			tipTF=ComponentUtil.createTextField("", 78, 8, tipTFFormat, 200, 26, this);
			tipTF.filters=Style.textBlackFilter;
			tipTF.x=(this.width - tipTF.width) * 0.5;
			tipTF.y=(this.height - tipTF.height) * 0.5;
		}
		
		public function checkSelets(ids:Array):void {
			for (var i:int=0; i < tileList.numChildren; i++) {
				var item:ExaltEquipItemRender=tileList.getChildAt(i) as ExaltEquipItemRender;
				if (item) {
					item.select(false);
					var index:int = ids.indexOf(item.data.oid);
					if(index != -1 ){
						item.select(true);
						ids.splice(index,1);
					}
				}
			}
		}
		
		override protected function getAllEquipData():Array{
			var result:Array = StoveEquipFilter.extal(selectOid);
			return result;
		}
	}
}