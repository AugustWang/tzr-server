package modules.finery.views.item {
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.TileList;
	
	import flash.utils.Dictionary;
	
	import modules.finery.MaterialID;
	import modules.finery.StoveConstant;
	import modules.finery.views.compose.ComposeView;
	import modules.finery.views.refine.RefineView;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.mypackage.vo.GeneralVO;
	import modules.mypackage.vo.StoneVO;
	
	public class MaterialList extends Canvas {
		private var type:String;
		private var tileList:TileList;
		
		
		public function MaterialList(type:String) {
			this.type=type;
			init();
		}
		
		private function init():void {
			x=2; 
			y=2;
			width=260;
			height=355;
			verticalScrollPolicy=ScrollPolicy.AUTO;
			
			tileList=new TileList();
			this.addChild(tileList);
			tileList.itemWidth=120;
			tileList.itemHeight=49;
			tileList.columnCount=2;
			tileList.hPadding=2;
			tileList.vPadding=1;
			tileList.y=3;
			tileList.x=3;
			tileList.itemRender=MaterialItemRender;
		}
		
		public function checkSelet(ids:Array):void{
			for(var i:int=0; i < tileList.numChildren; i++){
				var item:MaterialItemRender = tileList.getChildAt(i) as MaterialItemRender;
				if(item){
					item.select(false);
					var index:int = ids.indexOf(item.data.oid);
					if(index != -1){
						item.select(true);
						ids.splice(index,1);
					}
				}
			}
		}
		
		private function getAllData():Array {
			var result:Array = [];
			var item:BaseItemVO;
			var packItems:Array = PackManager.getInstance().packItems;
			if( type == ComposeView.NAME ){
				for each (item in packItems) {
					if (item && MaterialID.getInstance().matchID_arr.indexOf(item.typeId.toString())!=-1) {
						result.push(item);
					}
				}
			}else if(type == RefineView.NAME){
				for each (item in packItems) {
					if (item) {
						if(item is EquipVO){
							if(StoveConstant.specialEquipArr.indexOf(EquipVO(item).typeId) == -1){
								result.push(item);
							}
						}else{
							result.push(item);
						}
					}
				}
			}
			return result;
		}
		
		public function material():Array{
			var result:Array = [];
			var all:Array = getAllData();
			for(var i:int=0; i < all.length; i++){
				if(all[i] is GeneralVO){
					result.push(all[i]);
				}
			}
			return result;
		}
		
		public function stone():Array{
			var result:Array = [];
			var all:Array = getAllData();
			for(var i:int=0; i < all.length; i++){
				if(all[i] is StoneVO){
					result.push(all[i]);
				}
			}
			return result;
		}
		
		public function equip():Array{
			var result:Array = [];
			var all:Array = getAllData();
			for(var i:int=0; i < all.length; i++){
				if(all[i] is EquipVO){
					result.push(all[i]);
				}
			}
			return result;
		}
		
		public function update(value:String = "ALL"):void {
			var currentArr:Array;
			switch(value){
				case "ALL":currentArr = getAllData();break;
				case "MATERIAL":currentArr = material();break;
				case "STONE":currentArr = stone();break;
				case "EQUIP":currentArr = equip();break;
			}
			tileList.dataProvider=currentArr;
			var length:int=currentArr.length;
			tileList.height=(length / 2 + 1) * 51;
			tileList.validateNow();
			this.updateSize();
		}
	}
}