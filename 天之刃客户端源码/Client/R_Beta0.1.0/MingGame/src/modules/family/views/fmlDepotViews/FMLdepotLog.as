package modules.family.views.fmlDepotViews
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.events.PageEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.PageBar;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import modules.family.FamilyDepotModule;

//	import proto.line.m_fmldepot_list_log_toc;
	
	public class FMLdepotLog extends BasePanel
	{
		private var tabbar:TabBar;
		private var list:List;
		private var letterPage:PageBar;
		
		private var type:int;
		private var page:int;
		private var size:int;
		public function FMLdepotLog()
		{
			super();
			this.title = "仓库使用记录";
			this.width = 480;
			this.height = 356;
			initView();
		}
		
		private function initView():void
		{
			
			tabbar = new TabBar();
			tabbar.x = 12;
			tabbar.y = 3;
			tabbar.addItem("存入记录",78,25);
			tabbar.addItem("取出记录",78,25);
			addChild(tabbar);
			tabbar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED,onSelectedChange);
			
			var boder:UIComponent = ComponentUtil.createUIComponent(8,28,464,290);
			Style.setBorderSkin(boder);
			addChild(boder);
			
			var listBg:Sprite = Style.getBlackSprite(456,246,5);
			listBg.x = 12;
			listBg.y = 30;
			addChild(listBg);
			
			
			for(var i:int=1;i<10;i++){
				var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
				line.x = 13;
				line.y = 28+ i*25;
				line.width = 450;
				addChild(line);
			}
			
			list = new List();
			list.x = 12;
			list.y = 28;
			list.bgSkin = null;
			list.itemHeight = 25;
			list.height = 252;
			list.width = 452;
			list.verticalScrollPolicy = ScrollPolicy.OFF;
			list.itemRenderer = DepotLogItemRd;
			addChild(list);
			
			var pageBg:Sprite = Style.getBlackSprite(456,26,5);
			pageBg.x = 12;
			pageBg.y = 283;
			addChild(pageBg);
			
			letterPage = new PageBar();
			this.addChild(letterPage);
			letterPage.x = 50;
			letterPage.y = 285;
//			letterPage.width = 220;
			letterPage.addEventListener(PageEvent.CHANGED,onLetterPageHandler);
			
			
		}
		
		private function onSelectedChange(evt:TabNavigationEvent):void
		{
			if(type == evt.index+1)
				return;
			page = 1;
			type = evt.index + 1 ;
			addDataLoading();
			FamilyDepotModule.getInstance().getDepotLog(type,page);
		}
		
		
		public function set PageSize(totalLogs:int):void
		{
			size = Math.ceil(totalLogs/10) ;
			letterPage.totalPageCount = size;
		}
		public function setLogData(arr:Array):void
		{
			removeDataLoading();
			if(!arr ||arr.length<=0)
			{
				list.dataProvider = [];
				return;
			}
			
			list.dataProvider= arr;
			
				
//			p_fmldepot_log
		}
		
		private function onLetterPageHandler(evt:PageEvent):void{
//			dealChangePage(lettersList,LetterPage.content_arr);
			page = evt.pageNumber ;
			addDataLoading();
			FamilyDepotModule.getInstance().getDepotLog(type,page);
		}
		
	}
}