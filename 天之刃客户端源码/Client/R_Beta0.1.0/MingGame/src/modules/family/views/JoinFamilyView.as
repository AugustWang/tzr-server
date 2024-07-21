package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.LoadingSprite;
	import com.managers.Dispatch;
	import com.ming.events.PageEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.PageBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.StringUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyItemEvent;
	import modules.family.FamilyModule;
	import modules.family.views.items.JoinFamilyItem;

	public class JoinFamilyView extends LoadingSprite
	{
		private var tip:TextField;
		private var familyInput:TextInput;
		private var familyCEO:TextInput;
		private var nations:Array;
		private var familyDataGrid:DataGrid;
		private var pageBar:PageBar;
		private var requests:Array;
		public function JoinFamilyView()
		{	
			var backBg:UIComponent = ComponentUtil.createUIComponent(2,1,460,254);
			Style.setBorderSkin(backBg);
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			familyDataGrid = new DataGrid();
			familyDataGrid.itemRenderer = JoinFamilyItem;
			familyDataGrid.x = 2;
			familyDataGrid.y = 1;
			familyDataGrid.width = 456;
			familyDataGrid.height = 252;
			familyDataGrid.addColumn("掌门",100);
			familyDataGrid.addColumn("门派名",120);
			familyDataGrid.addColumn("门派繁荣度",80);
			familyDataGrid.addColumn("成员数",50);
			familyDataGrid.addColumn("操作",99);
			familyDataGrid.itemHeight = 25;
			familyDataGrid.pageCount = 9;
			familyDataGrid.verticalScrollPolicy = ScrollPolicy.OFF;
			familyDataGrid.list.addEventListener(FamilyItemEvent.SHOW_TOOLTIP,showFamilyTip);
			backBg.addChild(familyDataGrid);
			
			var backBg1:UIComponent = ComponentUtil.createUIComponent(2,275,460,36);
			Style.setBorderSkin(backBg1);
			backBg1.mouseEnabled = false;
			addChild(backBg1);
			
			pageBar = new PageBar();
			pageBar.y = 254;
			pageBar.x = 50;
			pageBar.size = 5;
			pageBar.addEventListener(PageEvent.CHANGED,onPageChanged);
			addChild(pageBar);
			ComponentUtil.createTextField("门派：",15,8,Style.textFormat,40,25,backBg1,textWrapper);
			ComponentUtil.createTextField("掌门：",180,8,Style.textFormat,40,25,backBg1,textWrapper);
			
			familyInput = new TextInput();
			familyInput.width = 125;
			familyInput.x = 55;
			familyInput.y = 8;
			familyInput.addEventListener(Event.CHANGE,onFamilyChanged);
			backBg1.addChild(familyInput)
			
			familyCEO = new TextInput();
			familyCEO.width = 125;
			familyCEO.x = 217;
			familyCEO.y = 8;
			familyCEO.addEventListener(Event.CHANGE,onFamilyCEOChanged);
			backBg1.addChild(familyCEO)
			
			var seachBtn:Button = ComponentUtil.createButton("搜索",358,6,74,25,backBg1);
			seachBtn.addEventListener(MouseEvent.CLICK,onSearchHandler);
			addEventListener(Event.ADDED_TO_STAGE,addToStageHandler);
		}
		
		private function addToStageHandler(event:Event):void{
			getFamilyPanel();	
		}
		
		public function getFamilyPanel():void{
			addDataLoading();
			FamilyModule.getInstance().getFamilyPanel();
		}
		
		private function getFamilyList(pageNumber:int):void{
			addDataLoading();
			FamilyModule.getInstance().getFamilyList(pageNumber);
		}
		
		public function setFamilyPanel(familys:Array,requesteds:Array,totalCount:int):void{
			requests = requesteds;
			setFamilyList(familys,totalCount);
		}
		
		public function setRequests(requesteds:Array):void{
			requests = requesteds;
		}
		
		private function textWrapper(text:TextField):void{
			text.mouseEnabled = false;
		}
		
		private var searchContent:String;
		private var searchType:int;
		private function onSearchHandler(event:MouseEvent):void{
			var familyName:String = StringUtil.trim(familyInput.text);
			var ceoName:String = StringUtil.trim(familyCEO.text);
			if(familyName != "" && ceoName == ""){
				searchType = 1;
				searchContent = familyName;
			}else if(familyName == "" && ceoName != ""){
				searchType = 2;
				searchContent = ceoName;
			}else{
				searchType = 0;
				searchContent = "";
			}
			FamilyModule.getInstance().getFamilyList(1,9,searchContent,searchType);
		}
		
		public function setFamilyList(list:Array,totalPageCount:int):void{
			removeDataLoading();
			pageBar.totalPageCount = totalPageCount;
			pageBar.x = (440 - pageBar.width)/2;
			list.sortOn("cur_members",Array.NUMERIC);
			familyDataGrid.dataProvider = list;
			if(GlobalObjectManager.getInstance().user.attr.level < 10 && list.length == 0){
				addDefaultText();
			}else{
				removeText();
			}
		}
		
		private var funcTip:JoinFamilyToolTip;
		private function showFamilyTip(event:FamilyItemEvent):void{
			event.stopImmediatePropagation();
//			if(funcTip == null){
//				funcTip = new JoinFamilyToolTip();
//			}
//			var info:p_family_summary = event.data as p_family_summary;
//			funcTip.show(info);
		}
		
		public function requestJoinFamily(familyId:int):void{
			Dispatch.dispatch(JoinFamilyItem.JOINED_FAMILY,familyId);
		}

		
		private function onPageChanged(event:PageEvent):void{
			FamilyModule.getInstance().getFamilyList(event.pageNumber,9,searchContent,searchType);
		}
		
		private function onFamilyChanged(event:Event):void{
			var familyName:String = StringUtil.trim(familyInput.text);
			if(familyName != ""){
				familyCEO.text = "";
			}
		}
		
		private function onFamilyCEOChanged(event:Event):void{
			var ceoName:String = StringUtil.trim(familyCEO.text);
			if(ceoName != ""){
				familyInput.text = "";
			}
		}
		
		public function addDefaultText():void{
			if(tip == null){
				var tf:TextFormat = Style.textFormat;
				tf.align = "center";
				tip = ComponentUtil.createTextField("",0,130,tf,438);
				tip.textColor = 0xffff00;
			}
			tip.text = "你等级不满10级，无法加入门派，继续努力吧！20级就可以创建门派了。";
			addChild(tip);
		}
		
		private function removeText():void{
			if(tip && tip.parent){
				tip.parent.removeChild(tip);
				tip = null;
			}
		}
	}
}