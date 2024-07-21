package modules.family.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.ming.events.PageEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.PageBar;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyModule;
	import modules.family.views.items.FamilyInfoItem;
	
	import proto.line.p_family_summary;
	
	public class AllFamilyPanel extends BasePanel
	{
		private var tip:TextField;
		private var nations:Array;
		private var familyDataGrid:DataGrid;
		private var pageBar:PageBar;
		private var requests:Array;
		public function AllFamilyPanel()
		{
			super();
			this.title = "全部门派";
			width = 470;
			height = 350;
			var backBg:Sprite = Style.getBlackSprite(446,278);
			backBg.x = 12;
			backBg.y = 2;
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			familyDataGrid = new DataGrid();
			familyDataGrid.itemRenderer = FamilyInfoItem;
			familyDataGrid.x = 2;
			familyDataGrid.width = 442;
			familyDataGrid.height = 272;
			familyDataGrid.addColumn("掌门",110);
			familyDataGrid.addColumn("门派名",120);
			familyDataGrid.addColumn("门派繁荣度",110);
			familyDataGrid.addColumn("成员数",102);
			familyDataGrid.itemHeight = 25;
			familyDataGrid.pageCount = 10;
			familyDataGrid.verticalScrollPolicy = ScrollPolicy.OFF;
			backBg.addChild(familyDataGrid);

			pageBar = new PageBar();
			pageBar.y = 288;
			pageBar.x = 50;
			pageBar.size = 5;
			pageBar.addEventListener(PageEvent.CHANGED,onPageChanged);
			addChild(pageBar);
			
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}
				
		private function addToStageHandler(event:Event):void{
			getFamilyPanel();	
		}
		
		public function getFamilyPanel():void{
			addDataLoading();
			FamilyModule.getInstance().getFamilyList(1,9,"",0,2);
		}
		
		private function getFamilyList(pageNumber:int):void{
			addDataLoading();
			FamilyModule.getInstance().getFamilyList(pageNumber,9,"",0,2);
		}
		
		public function setFamilyPanel(familys:Array,requesteds:Array,totalCount:int):void{
			requests = requesteds;
			setFamilyList(familys,totalCount);
		}
		
		
		public function setFamilyList(list:Array,totalPageCount:int):void{
			removeDataLoading();
			pageBar.totalPageCount = totalPageCount;
			pageBar.x = (453 - pageBar.width)/2;
			list.sort(sortHandler);
			familyDataGrid.dataProvider = list;
		}
						
		private function onPageChanged(event:PageEvent):void{
			FamilyModule.getInstance().getFamilyList(event.pageNumber,9,"",0,2);
		}
		
		private function sortHandler(info1:p_family_summary,info2:p_family_summary):int{
			var value1:int = info1.active_points;
			if(info1.cur_members == FamilyConstants.counts[info1.level]){
				value1 = 0;
			}
			var value2:int = info2.active_points;
			if(info2.cur_members == FamilyConstants.counts[info2.level]){
				value2 = 0;
			}
			var result:int = compare(value1,value2);
			if(result == 0){
				return compare(info1.cur_members,info2.cur_members);
			}
			return result;
		}
		
		private function compare(value1:int,value2:int):int{
			if(value1 > value2){
				return -1;
			}else if(value1 < value2){
				return 1;
			}else{
				return 0;
			}
		}
	}
}