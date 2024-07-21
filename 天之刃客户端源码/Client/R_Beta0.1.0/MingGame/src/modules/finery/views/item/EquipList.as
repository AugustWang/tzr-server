package modules.finery.views.item {
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.TileList;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import modules.finery.StoveEquipFilter;
	import modules.finery.views.bind.BindView;
	import modules.finery.views.disassembly.DisassemblyView;
	import modules.finery.views.exalt.ExaltView;
	import modules.finery.views.insert.InsertView;
	import modules.finery.views.punch.PunchView;
	import modules.finery.views.recast.RecastView;
	import modules.finery.views.strength.StrengthView;
	import modules.finery.views.upgrade.UpgradeView;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;

	public class EquipList extends Canvas {
		public var selectColor:int;
		public var selectPutWhere:int;
		protected var type:String;
		protected var tileList:TileList;
		protected var tipTF:TextField;

		public function EquipList(type:String) {
			this.type=type;
			init();
		}

		protected function init():void {
			width=260;
			height=162;
			y=4;
			x=6;
			verticalScrollPolicy=ScrollPolicy.AUTO;

			tileList=new TileList();
			this.addChild(tileList);
			tileList.itemWidth=120;
			tileList.itemHeight=49;
			tileList.columnCount=2;
			tileList.hPadding=2;
			tileList.vPadding=1;
			tileList.y=3;
			tileList.itemRender=EquipItemRender;
			var tipTFFormat:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.
				CENTER);
			tipTF=ComponentUtil.createTextField("", 78, 8, tipTFFormat, 200, 26, this);
			tipTF.filters=Style.textBlackFilter;
			tipTF.x=(this.width - tipTF.width) * 0.5;
			tipTF.y=(this.height - tipTF.height) * 0.5;
		}

		public function checkSelet(id:int=-1):void {
			for (var i:int=0; i < tileList.numChildren; i++) {
				var item:EquipItemRender=tileList.getChildAt(i) as EquipItemRender;
				if (item) {
					item.select(false);
					if (item.data.oid == id) {
						item.select(true);
					}
				}
			}
		}

		protected function getAllEquipData():Array {
			var array:Array=[];
			switch (type) {
				case PunchView.NAME:
					array=StoveEquipFilter.punch();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可开孔的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case InsertView.NAME:
					array=StoveEquipFilter.inset();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可镶嵌的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case DisassemblyView.NAME:
					array=StoveEquipFilter.disassembly();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可拆卸的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case BindView.NAME:
					array=StoveEquipFilter.punch();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可绑定的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case StrengthView.NAME:
					array=StoveEquipFilter.punch();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可强化的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case ExaltView.NAME:
					array=StoveEquipFilter.punch();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可精炼的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case UpgradeView.NAME:
					array=StoveEquipFilter.punch();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可升级的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
				case RecastView.NAME:
					array=StoveEquipFilter.punch();
					if(array.length == 0){
						tipTF.htmlText=HtmlUtil.font("背包中没有可重铸的装备","#00ff00");
					}else{
						tipTF.htmlText="";
					}
					break;
			}
			return array;
		}

		private function getEquipsByColorAndType(color:int=-1,putWhere:int=-1):Array {
			var array:Array=[];
			var equips:Array=getAllEquipData();
			var l:int=equips.length;
			var equip:EquipVO
			for (var i:int=0; i < l; i++) {
				equip=equips[i] as EquipVO;
				if (equip) {
					if(putWhere == -1 && color == -1){
						array.push(equip);
					}else if(putWhere == -1 && equip.color == color){
						array.push(equip);
					}if(putWhere == equip.putWhere && color == -1){
						array.push(equip);
					}else if(equip.color == color && equip.putWhere == putWhere){
						array.push(equip);
					}
				}
			}
			return array;
		}

		public function update(color:int=-1,equipPutWhere:int=-1):void {
			selectColor = color;
			selectPutWhere = equipPutWhere;
			var currentArr:Array=getEquipsByColorAndType(color,equipPutWhere);
			tileList.dataProvider=currentArr;
			var length:int=currentArr.length;
			tileList.height=(length / 2 + 1) * 51;
			tileList.validateNow();
			this.updateSize();
		}
	}
}