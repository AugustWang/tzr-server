package modules.Activity.view
{
	import com.common.FilterCommon;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import modules.Activity.ActivityModule;
	import modules.Activity.activityManager.BossGroupManager;
	import modules.Activity.view.itemRender.BossGroupItem;
	import modules.Activity.vo.BossDropThingVO;
	import modules.Activity.vo.BossGroupVO;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsToolTip;
	import modules.mypackage.vo.BaseItemVO;

	public class BossGroupPanel extends UIComponent
	{
		public static const BASE_DIR:String = "com/assets/bossgroup/"
		private var dataGrid:DataGrid;
		private var rightContainer:UIComponent;
		private var bossImage:Image;
		private var descText:TextField;
		private var dropThingsText:TextField;
		private var goodsTip:GoodsToolTip;
		private var hasInit:Boolean = false;
		public function BossGroupPanel()
		{
			
		}
		
		public function init():void{
			if(hasInit){
				return;
			}
			hasInit = true;
			width = 655;
			height = 450;
			//addContentBG(5,5);
			
			dataGrid = new DataGrid();
			dataGrid.list.itemSkinLeft = 10;
			dataGrid.list.itemSkinRight = 10;
			Style.setBorderSkin(dataGrid);
			dataGrid.x = 10;
			dataGrid.y = 9;
			dataGrid.height = 343;
			dataGrid.width = 400;
			dataGrid.itemRenderer = BossGroupItem;
			dataGrid.itemHeight = 24;
			dataGrid.addColumn("Boss名称",120);
			dataGrid.addColumn("等级",43);
			dataGrid.addColumn("状态",72);
			dataGrid.addColumn("所在地图",78);
			dataGrid.addColumn("操作",82);
			dataGrid.pageCount = 14;
			dataGrid.list.addEventListener(ItemEvent.ITEM_CHANGE,itemChangeHandler);
			addChild(dataGrid);
			
			rightContainer = new UIComponent();
			rightContainer.width = 216;
			rightContainer.height = 343;
			Style.setBorderSkin(rightContainer);
			rightContainer.x = dataGrid.x + dataGrid.width+5;
			rightContainer.y = dataGrid.y;
			addChild(rightContainer);
			
			var headerBar:HeaderBar = new HeaderBar();
			headerBar.width = 215;
			headerBar.addColumn("特     性",222);
			rightContainer.addChild(headerBar);
			
			bossImage = new Image();
			bossImage.x = 20;
			bossImage.y = 200;
			bossImage.cache = false;
			rightContainer.addChild(bossImage);
			
			descText = ComponentUtil.createTextField("",10,34,null,206,115,rightContainer);
			descText.textColor = 0xffffff;
			descText.wordWrap = true;
			descText.multiline = true;
			descText.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			dropThingsText = ComponentUtil.createTextField("",descText.x,descText.y+descText.height+15,null,206,200,rightContainer);
			dropThingsText.textColor = 0xffffff;
			dropThingsText.wordWrap = true;
			dropThingsText.multiline = true;
			dropThingsText.filters = FilterCommon.FONT_BLACK_FILTERS;
			dropThingsText.mouseEnabled = true;
			dropThingsText.addEventListener(TextEvent.LINK,dropThingLinkHandler);
			
			addEventListener(Event.ADDED_TO_STAGE,openWindowHandler);
			addEventListener(Event.REMOVED_FROM_STAGE,closeWindowHandler);
			BossGroupManager.getInstance().addEventListener(BossGroupManager.BOSSGROUP_UPDATE,updateBossGroup);
			BossGroupManager.getInstance().addEventListener(BossGroupManager.INIT_COMPLETE,bossGroupInitComplete);
			BossGroupManager.getInstance().startInit();
		}
		
		private function updateBossGroup(event:ParamEvent):void{
			dataGrid.dataProvider = BossGroupManager.getInstance().bossList;
			dataGrid.list.selectedIndex = 0;
		}
		
		private function bossGroupInitComplete(event:ParamEvent):void{
			BossGroupManager.getInstance().removeEventListener(BossGroupManager.INIT_COMPLETE,bossGroupInitComplete);
			ActivityModule.getInstance().requestBossGroups();
			if(this.stage){
				BossGroupManager.getInstance().startTimer();
			}
		}
		
		private function openWindowHandler(event:Event):void{
			BossGroupManager.getInstance().startTimer();
		}
		
		private function closeWindowHandler(event:Event):void{
			BossGroupManager.getInstance().stopTimer();
		}
		
		private function dropThingLinkHandler(event:TextEvent):void{
			var typeId:int = int(event.text);
			var baseItemVO:BaseItemVO = ItemLocator.getInstance().getObject(typeId);
			if(baseItemVO){
				if(goodsTip == null){
					goodsTip = new GoodsToolTip();
				}
				goodsTip.data = baseItemVO;
				goodsTip.x = this.mouseX;
				goodsTip.y = this.mouseY;
				addChild(goodsTip);
				stage.addEventListener(MouseEvent.MOUSE_DOWN,hideGoodsTipHandler);
			}
		}
		
		private function hideGoodsTipHandler(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,hideGoodsTipHandler);
			if(goodsTip && goodsTip.parent){
				removeChild(goodsTip);
			}
		}
		
		private function itemChangeHandler(event:ItemEvent):void{
			var bossGroupVO:BossGroupVO = event.selectItem as  BossGroupVO;
			if(bossGroupVO){
				descText.text = bossGroupVO.name+"："+bossGroupVO.desc;
				var dropThingHtml:String = "";
				for each(var dropThing:BossDropThingVO in bossGroupVO.dropThings){
					dropThingHtml += dropThing.toString();
				}
				dropThingsText.htmlText = dropThingHtml;
				//bossImage.source = GameConfig.ROOT_URL+BASE_DIR+bossGroupVO.id+".png";
			}
		}
		
	}
}