package modules.sceneWarFb.view {
	import com.components.DataGrid;
	import com.ming.events.ItemEvent;

	import flash.display.Sprite;

	public class PoyanghuTeamInfo extends Sprite {
		private var grid:DataGrid;

		public function PoyanghuTeamInfo() {
			super();
			init();
		}

		public function init():void {
			grid=new DataGrid;
			grid.itemRenderer=PoyanghuNoTeamItem;
			grid.bgColor=0x0;
			grid.bgAlpha=0.5;
			grid.width=305;
			grid.height=244;
			grid.addColumn("玩家名字", 120);
			grid.addColumn("等级", 60);
			grid.addColumn("操作", 120);
			grid.pageCount=9;
			grid.itemHeight=24;
			grid.list.itemDoubleClickEnabled=true;
			addChild(grid);
		}

		public function update(arr:Array):void {
			grid.dataProvider=arr;
		}
	}
}