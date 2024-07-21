package modules.Activity.view
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.TileList;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.Activity.ActivityModule;
	import modules.Activity.view.itemRender.MyEquipItemRender;
	
	import proto.common.p_goods;
	
	public class EquipListView extends BasePanel
	{
		private var currentActivityKey:int;
		private var tileList:TileList;
		private var descTxt:TextField;
		private var canvas:Canvas;
		public static var preEquiup:MyEquipItemRender;
		public function EquipListView()
		{
			super("EquipListView");
			this.width = 282;
			this.height = 385;
			this.x = (1000 - this.width)/2;
			this.y = (GlobalObjectManager.GAME_HEIGHT - this.height)/2;
		}
		
		override protected function init():void{
			this.title = "装备列表";
			this.titleAlign = 2;
			descTxt = ComponentUtil.createTextField("",10,10,null,400,23,this);
			
			var backUI:UIComponent = new UIComponent();
			this.addChild(backUI);
			backUI.x = 10;
			backUI.y = descTxt.y + descTxt.height;
			backUI.width = 262;
			backUI.height = 290;
			Style.setBorderSkin(backUI);
			
			canvas = new Canvas();
			this.addChild(canvas);
			canvas.width = 260;
			canvas.height = 285;
			canvas.x = 10;
			canvas.y = backUI.y + 3;
			canvas.verticalScrollPolicy = ScrollPolicy.ON;
			
			tileList = new TileList();
			canvas.addChild(tileList);
			tileList.itemWidth = 36;
			tileList.itemHeight = 36;
			tileList.hPadding = 5;
			tileList.vPadding = 4;
			tileList.columnCount = 6;
			tileList.x = 5;
			tileList.y = 3;
			tileList.itemRender = MyEquipItemRender;
			
			var commitBtn:Button = ComponentUtil.createButton("提交",110,backUI.height + 32,65,25,this);
			commitBtn.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			var equipOid:int = MyEquipItemRender.currentEquipId;
			if(equipOid != -1){
				ActivityModule.getInstance().reqestEquipActivityData(currentActivityKey,equipOid);
				WindowManager.getInstance().removeWindow(this);
				MyEquipItemRender.currentEquipId = -1;
			}else{
				Tips.getInstance().addTipsMsg("请选择你要参与活动的装备再提交");
//				Alert.show("请选择你要参与排行的装备再提交","提示",null,null,"确定","取消",null,false);
			}
		}
		
		//获取身上和背包里的所有装备
		private function getEquipData():Array{
			var wearArr:Array = GlobalObjectManager.getInstance().user.attr.equips.concat();
			var equipArr:Array = [];
			if(wearArr.length != 0){
				for each(var p:p_goods in wearArr){
					var vo:EquipVO = ItemConstant.wrapperItemVO(p) as EquipVO;
					if(!(vo.putWhere == 11 || vo.putWhere == 12 || vo.putWhere == 10))
						equipArr.push(vo);
				}
			}
			for(var i:int =1;i<=3;i++){
				var bagArr:Array = PackManager.getInstance().getItemsByPackId(i);
				if(bagArr && bagArr.length != 0){
					for each(var itemGoods:BaseItemVO in bagArr){
						if(itemGoods is EquipVO ){
							var vo2:EquipVO = itemGoods as EquipVO;
							if(!(vo2.putWhere == 11 || vo2.putWhere == 12 || vo2.putWhere == 10))
								equipArr.push(itemGoods);
						}
					}
				}
			}
			return equipArr;
		}
		
		public function updateTileListData(activity_key:int):void{
			currentActivityKey = activity_key;
			var currentArr:Array = getEquipData();
			tileList.dataProvider = currentArr;
			var length:int = currentArr.length;
			tileList.height = (length/6 + 1) * 42;
			canvas.updateSize();
			descTxt.text = "请选择你要参与活动的单件装备，点击提交：";

		}
		
		override protected function closeHandler(event:CloseEvent=null):void{
			super.closeHandler();
			MyEquipItemRender.currentEquipId = -1;
		}
	}
}