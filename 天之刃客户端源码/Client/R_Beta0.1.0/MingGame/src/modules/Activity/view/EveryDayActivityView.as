package modules.Activity.view {
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.List;
	import com.ming.ui.containers.VScrollCanvas;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.activityManager.ActAwardLocator;
	import modules.Activity.view.itemRender.ActGoodsItem;
	import modules.Activity.view.itemRender.EveryDayItem;
	
	import proto.common.p_activity_info;

	/**
	 *
	 * @author日常任务
	 *
	 */
	public class EveryDayActivityView extends UIComponent {
		public static const FB:String="FB";
		public static const ACTIVITY:String="ACTIVITY"
		protected var datagrid:DataGrid;

		protected var descTxt:TextField;
		protected var rewardTxt:TextField;
		protected var rDownbg:Sprite;

		protected var expTxt:TextField;
		protected var silTxt:TextField;
		protected var itemTxt:TextField; //道具
		protected var activeTxt:TextField; //活跃度
		protected var items:Array;
		protected var starArr:Array;
		private var downContent:VScrollCanvas;
		private var type:String="";

		public function EveryDayActivityView($type:String="FB") {
			type = $type;
			super();
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}

		private function addToStageHandler(event:Event):void {
			init();
			removeEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}

		private function init():void {
			starArr=[];
			items=[];

			var bgBorder:UIComponent=ComponentUtil.createUIComponent(8, 8, 460, 330);
			bgBorder.mouseEnabled=bgBorder.mouseChildren=false;
			Style.setBorderSkin(bgBorder);
			addChild(bgBorder);
			
			var rightBorder:UIComponent=ComponentUtil.createUIComponent(bgBorder.x+bgBorder.width+4,8,162,330);
			Style.setBorderSkin(rightBorder);
			addChild(rightBorder);

			var bgsprit:Sprite=new Sprite(); //Style.getBlackSprite(434,335,2);
			bgsprit.x=8;
			bgsprit.y=8;
			addChild(bgsprit);

			datagrid=new DataGrid();
			datagrid.x=0;
			datagrid.y=0;
			datagrid.height=326;
			datagrid.width=460;
			datagrid.itemHeight=25;
			datagrid.pageCount=12;
			if(type == FB){
				datagrid.itemRenderer=EveryDayItem;
				datagrid.addColumn("副本名称", 120);
				datagrid.addColumn("奖励", 110);
				datagrid.addColumn("等级", 50);
				datagrid.addColumn("副本进度", 70);
				datagrid.addColumn("操作", 100);
			}else{
				datagrid.itemRenderer=EveryDayItem;
				datagrid.addColumn("活动名称", 120);
				datagrid.addColumn("奖励", 110);
				datagrid.addColumn("进入等级", 50);
				datagrid.addColumn("活动时间", 70);
				datagrid.addColumn("操作", 100);
			}
			datagrid.verticalScrollPolicy=ScrollPolicy.ON;
			datagrid.list.addEventListener(ItemEvent.ITEM_CLICK, onclick);
			datagrid.validateNow();
			bgsprit.addChild(datagrid);

			var upHeader:HeaderBar=new HeaderBar();
			upHeader.width=161;
			if(type == FB){
				upHeader.addColumn("副本说明", 160);
			}else{
				upHeader.addColumn("活动说明", 160);
			}
			rightBorder.addChild(upHeader);

			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xffff00, null, null, null, null, null, null, null, null, null, 5);
			descTxt=ComponentUtil.createTextField("", 10, 25, tf, 150, 117);
			descTxt.wordWrap=descTxt.multiline=true;
			descTxt.selectable=true;
			descTxt.mouseEnabled=true;
			rightBorder.addChild(descTxt);
		}

		public function setEveryDayData(everydayArr:Array):void {

			if (!everydayArr || everydayArr.length == 0)
				return;
			datagrid.dataProvider=everydayArr;
			datagrid.list.selectedIndex=0;
			datagrid.list.validateNow();
			onclick(null);
		}

		private function onclick(evt:ItemEvent):void {
			var info:p_activity_info=datagrid.list.selectedItem as p_activity_info;
			var voxml:Object;
			if (info && !voxml)
				voxml=ActAwardLocator.getInstance().getTodayObjById(info.id);

			descTxt.htmlText=voxml.desc;
			var arr:Array=voxml.rewards;

			createRewardItem(voxml);
//			rewardTxt.text = voxml.desc;
		}

		private function createRewardItem(obj:Object):void {
			var arr:Array;
			var line:int;

			while (starArr.length > 0) {
				var disobj:Sprite=starArr.pop() as Sprite;
				if (disobj) {
					downContent.removeChild(disobj);
					disobj=null;
				}
			}
			while (items.length > 0) {
				var gooditem:ActGoodsItem=items.pop() as ActGoodsItem;
				if (gooditem) {
					downContent.removeChild(gooditem);
					gooditem=null;
				}
			}

			if (false) {
				arr=obj.rewards;

				if (obj.exp_stars == 0 && obj.silver_stars != 0 && obj.item_stars == 0) { //只有银子
					expTxt.visible=false;
					itemTxt.visible=false;
					silTxt.visible=true;
					activeTxt.visible=false;
					silTxt.y=0;
					if (obj.active_points != 0) {
						activeTxt.visible=true;
						activeTxt.x=silTxt.x;
						activeTxt.y=silTxt.y + silTxt.height - 5;
						activeTxt.htmlText="活跃度：+" + obj.active_points;
					}
					line=2;
				} else if (obj.exp_stars == 0 && obj.silver_stars == 0 && obj.item_stars != 0) { //只有道具
					expTxt.visible=false;
					itemTxt.visible=true;
					silTxt.visible=false;
					activeTxt.visible=false;
					itemTxt.y=0;
					if (obj.active_points != 0) {
						activeTxt.visible=true;
						activeTxt.x=itemTxt.x;
						activeTxt.y=itemTxt.y + silTxt.height - 5;
						activeTxt.htmlText="活跃度：+" + obj.active_points;
					}
					line=2;
				} else if (obj.exp_stars != 0 && obj.silver_stars == 0 && obj.item_stars == 0) { //只有经验
					expTxt.visible=true;
					silTxt.visible=false;
					itemTxt.visible=false;
					activeTxt.visible=false;
					expTxt.y=0;
					if (obj.active_points != 0) {
						activeTxt.visible=true;
						activeTxt.x=expTxt.x;
						activeTxt.y=expTxt.y + expTxt.height - 5;
						activeTxt.htmlText="活跃度：+" + obj.active_points;
					}
					line=2;
				} else if (obj.exp_stars == 0 && obj.silver_stars != 0 && obj.item_stars != 0) { //有银子也有道具
					expTxt.visible=false;
					silTxt.visible=true;
					itemTxt.visible=true;
					activeTxt.visible=false;
					silTxt.y=0;
					itemTxt.y=silTxt.y + silTxt.height - 5;
					if (obj.active_points != 0) {
						activeTxt.visible=true;
						activeTxt.x=itemTxt.x;
						activeTxt.y=itemTxt.y + itemTxt.height - 5;
						activeTxt.htmlText="活跃度：+" + obj.active_points;
					}
					line=3;
				} else if (obj.exp_stars != 0 && obj.silver_stars == 0 && obj.item_stars != 0) { //有经验、道具，没有银子
					expTxt.visible=true;
					silTxt.visible=false;
					itemTxt.visible=true;
					activeTxt.visible=false;
					expTxt.y=0;
					itemTxt.y=expTxt.y + expTxt.height - 5;
					if (obj.active_points != 0) {
						activeTxt.visible=true;
						activeTxt.x=itemTxt.x;
						activeTxt.y=itemTxt.y + itemTxt.height - 5;
						activeTxt.htmlText="活跃度：+" + obj.active_points;
					}
					line=3;
				} else if (obj.exp_stars != 0 && obj.silver_stars != 0 && obj.item_stars == 0) { //有经验、银子，没道具
					expTxt.visible=true;
					silTxt.visible=true;
					itemTxt.visible=false;
					activeTxt.visible=false;
					expTxt.y=0;
					silTxt.y=expTxt.y + expTxt.height - 5;
					if (obj.active_points != 0) {
						activeTxt.visible=true;
						activeTxt.x=silTxt.x;
						activeTxt.y=silTxt.y + silTxt.height - 5;
						activeTxt.htmlText="活跃度：+" + obj.active_points;
					}
					line=3;
				}

				for (var i:int=0; i < obj.exp_stars; i++) {
					var expStar:Sprite=Style.getViewBg("xing_05");
					downContent.addChild(expStar);
					expStar.x=expTxt.x + expTxt.textWidth + (i * 15);
					expStar.y=expTxt.y + 3;
					starArr.push(expStar);
				}

				for (var j:int=0; j < obj.silver_stars; j++) {
					var silStar:Sprite=Style.getViewBg("xing_05");
					downContent.addChild(silStar);
					silStar.x=silTxt.x + silTxt.textWidth + (j * 15);
					silStar.y=silTxt.y + 3;
					starArr.push(silStar);
				}

				for (var k:int=0; k < obj.item_stars; k++) { //道具
					var itemStar:Sprite=Style.getViewBg("xing_05");
					downContent.addChild(itemStar);
					itemStar.x=itemTxt.x + itemTxt.textWidth + (k * 15);
					itemStar.y=itemTxt.y + 3;
					starArr.push(itemStar);
				}

				for (var m:int=0; m < arr.length; m++) {
					if (arr[m] == null || arr[m] == "") {
					} else {
						var item:ActGoodsItem=new ActGoodsItem(arr[m], 1);
						item.x=8 + 40 * (m % 3);
						item.y=2 + line * 20 + 39 * Math.floor(m / 3);
						downContent.addChild(item);

						items.push(item);
					}
				}
			}
		}


	}
}