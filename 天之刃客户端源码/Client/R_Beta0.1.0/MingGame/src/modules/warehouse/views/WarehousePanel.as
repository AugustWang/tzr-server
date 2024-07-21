package modules.warehouse.views
{
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.managers.Dispatch;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import modules.ModuleCommand;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	import modules.vip.VipDataManager;
	import modules.vip.VipModule;
	import modules.warehouse.WarehouseActionType;
	import modules.warehouse.WarehouseModule;
	
	import proto.common.p_goods;
	
	public class WarehousePanel extends BasePanel
	{
		private var wareTile:WareTile;
		
		private var tabbar :TabBar;
		
		private var preIndex:int ;
		
		private var clean_up_btn:Button;
		
		public function WarehousePanel()
		{
			super();
			this.width = 277;
			this.height = 330;
			addImageTitle("title_warehouse");
			initView();
		}
		
		private function initView():void
		{
			addContentBG(28,5,24);
			
			wareTile = new WareTile();
			wareTile.x = 11;
			wareTile.y = 31;
			addChild(wareTile);
			
			clean_up_btn = new Button();
			clean_up_btn.width = 65;
			clean_up_btn.height = 25;
			clean_up_btn.label = "整理";
			clean_up_btn.x = 202;//204;
			clean_up_btn.y = 262;//268;
			clean_up_btn.addEventListener(MouseEvent.CLICK,onCleanHandler);
			addChild(clean_up_btn);
			
//			initTabBar();
			
		}
		private function onCleanHandler(e:MouseEvent):void
		{
//			var flower:Flower = new Flower();
//			flower.setTimeOut(3000)
//			LayerManager.addToLayer(flower);
			WarehouseModule.getInstance().clearUp();
		}
		
		public function setGoodsData(goods:Array):void
		{
			if(!goods)
			{
				return;
			}
			var i:int;
			for(i=0;i<42;i++)
			{
				wareTile.updateGoods(i+1,null);
			}
			
			for(i = 0; i<goods.length ; i++)
			{
				var depotGood:p_goods = goods[i] as p_goods;
				
				var bsItemVo:BaseItemVO = PackageModule.getInstance().getBaseItemVO(depotGood);
				
				wareTile.updateGoods(depotGood.bagposition,bsItemVo);
			}
			
		}
		
		//单个格子物品改变（一般是增加）， 如果是清空  p_good.id = 0;
		public function updateGoods(pos:int, bsItemVo:BaseItemVO):void  //p_good:p_goods
		{
//			var bsItemVo:BaseItemVO = PackageModel.getInstance().getBaseItemVO(p_good);
			
			wareTile.updateGoods(pos, bsItemVo);
			//wareTile.updateGoods(p_good.bagposition, bsItemVo);
		}
		
		public function onOpenPanel():void
		{
			if (tabbar) {
				preIndex = 0;
				tabbar.selectIndex = 0;
			}
		}
		
		public function initTabBar(depotNum:int):void
		{
			if(!tabbar)
			{
				tabbar = new TabBar();
				tabbar.x = 10;
				addChild(tabbar);
				tabbar.addItem(WarehouseActionType.btn_num_To_cn(1),45,25);
			
				for(var i:int=1; i< depotNum+1; i++)
				{
					if(i>3)
						break;
					tabbar.addItem(WarehouseActionType.btn_num_To_cn(i+1),45,25);
				}		
				tabbar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChange);	
				
				preIndex = 0;
				tabbar.selectIndex = 0;
			}
		}
		
		public function addTabBar(depotId:int):void
		{
			
			if(depotId<4)
			{
				tabbar.addItem(WarehouseActionType.btn_num_To_cn(depotId+1),45,30);
				
			}
			
			tabbar.validateNow();
			selectIndex(preIndex+1);
		}
		
		public function selectIndex(index:int):void
		{
			var alertId:String;
			if (WarehouseModule.getInstance().isVipOpen && (index+1) > VipModule.getInstance().getRemoteDepotNum()) {
				Dispatch.dispatch(ModuleCommand.VIP_REMOTE_DEPOT);
				tabbar.selectIndex = preIndex;
				return;
			}
			
			WarehouseModule.getInstance().requestDepotGoods(index + 1);
			preIndex = tabbar.selectIndex = index;
		}
		
		private function onChange(evt:TabNavigationEvent):void
		{			
			if(evt.index == WarehouseModule.getInstance().depotNum && !WarehouseModule.getInstance().isVipOpen)
			{
				if (VipDataManager.getInstance().isDepotDredgeFree()) {
					openNewDepot();
					return;
				}
				var depotId:int = WarehouseModule.getInstance().depotNum + 1;
				var str:String = WarehouseActionType.newDepotMoney(depotId);
				Alert.show(str,"开通仓库提示：",openNewDepot,noHandler)
				
			}else{
				selectIndex(evt.index);
			}
		}
		
		private function openNewDepot():void
		{
			WarehouseModule.getInstance().depotDredge(WarehouseModule.getInstance().depotNum);// +1
		}
		
		private function noHandler():void
		{
			tabbar.selectIndex = preIndex;
		}
		public function setPreIndex():void
		{
			tabbar.selectIndex = preIndex;
			preIndex  = preIndex - 1;
			if (preIndex < 0) preIndex = 0;
		}
		
	}
}


