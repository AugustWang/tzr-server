package modules.family.views.fmlDepotViews {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.core.UIComponent;

	import flash.events.MouseEvent;

	import modules.family.FamilyConstants;
	import modules.family.FamilyDepotModule;
	import modules.family.FamilyLocator;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	import modules.warehouse.WarehouseActionType;

	import proto.common.p_family_member_info;
	import proto.common.p_goods;

	public class FMLdepotPanel extends BasePanel {

		private var wareTile:FMLdepotTile;

		private var tabbar:TabBar;
		private var barWidth:int=43

		private var preIndex:int;

		private var clean_up_btn:Button;

		public function FMLdepotPanel() {
			super();
			title="门派仓库";
			this.width=277;
			this.height=326;
			initView();
		}

		private function initView():void {
			//			var nameSprite:Sprite = Style.getViewBg("ckName");
			//			nameSprite.x = 123;
			//			nameSprite.mouseEnabled = false;
			//			nameSprite.y = 6;
			//			addChildToSuper(nameSprite);
			//			title = "   仓库";

			var bgUi:UIComponent=new UIComponent();
			bgUi.x=6.5;
			bgUi.y=30;
			bgUi.width=263;
			bgUi.height=233;
			Style.setBorderSkin(bgUi);
			addChild(bgUi);

			wareTile=new FMLdepotTile();
			wareTile.x=11.5;
			wareTile.y=39;
			addChild(wareTile);

			clean_up_btn=new Button();
			clean_up_btn.width=65;
			clean_up_btn.height=25;
			clean_up_btn.label="整理";
			clean_up_btn.x=202; //204;
			clean_up_btn.y=262; //268;
			clean_up_btn.addEventListener(MouseEvent.CLICK, onCleanHandler);
			addChild(clean_up_btn);

			//			initTabBar();

		}

		private function onCleanHandler(e:MouseEvent):void {
			FamilyDepotModule.getInstance().clearUp();
		}

		public function setGoodsData(goods:Array):void {
			if (!goods) {
				return;
			}
			var i:int;

			wareTile.disposeItems(); //42

			for (i=0; i < goods.length; i++) {
				var depotGood:p_goods=goods[i] as p_goods;

				var bsItemVo:BaseItemVO=PackageModule.getInstance().getBaseItemVO(depotGood);

				wareTile.updateGoods(depotGood.id, bsItemVo);
			}

		}

		//单个格子物品改变（一般是增加）， 如果是清空  p_good.id = 0;
		public function updateGoods(goosId:int, bsItemVo:BaseItemVO):void //p_good:p_goods
		{
			if (wareTile) {
				wareTile.updateGoods(goosId, bsItemVo);
			}
		}


		public function initTabBar(depotNum:int):void {
			if (!tabbar) {
				tabbar=new TabBar();
				tabbar.x=10;
				tabbar.y=3;
				addChild(tabbar);
				tabbar.addItem(WarehouseActionType.btn_num_To_cn(1), barWidth, 26);
			}

			for (var i:int=1; i < depotNum + 1; i++) {
				if (i > 5)
					break;
				tabbar.addItem(WarehouseActionType.btn_num_To_cn(i + 1), barWidth, 26);
			}

			preIndex=0;
			tabbar.selectIndex=0;

			tabbar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChange);
		}

		public function addTabBar(depotId:int):void {

			if (depotId < 6) {
				tabbar.addItem(WarehouseActionType.btn_num_To_cn(depotId + 1), barWidth, 26);

			}

			tabbar.validateNow();
			tabbar.selectIndex=preIndex + 1;
			tabbar.selectIndex=preIndex;
		}

		//提示：帮众每天只能从门派仓库取3次物品！

		private function onChange(evt:TabNavigationEvent):void {
			if (evt.index == FamilyDepotModule.getInstance().depotNum) {
				//  trace("  准备开通另外的仓库  "+ WarehouseModel.getInstance().depotNum);
				//				WarehouseModel.getInstance().depotDredge(evt.index+1);
				var m_id:int=GlobalObjectManager.getInstance().user.attr.role_id;
				var ceo:p_family_member_info=FamilyLocator.getInstance().getMemberById(m_id);
				var depotId:int;
				var str:String;
				if (ceo.title == "长老" || ceo.title == "掌门") {
					depotId=FamilyDepotModule.getInstance().depotNum + 1;
					str=FamilyConstants.newDepotMoney(depotId);
					/*开通第X个仓库需要消耗门派资金XX锭XX两XX文，你确定开通吗？ 确定  取消*/

					//"需要掌门或者长老开通该仓库之后才能使用！"
					Alert.show(str, "提示", openNewDepot, noHandler)

				} else {

					//需要掌门或者长老开通该仓库之后才能使用！
//					Tips.getInstance().addTipsMsg("需要掌门或者长老开通该仓库之后才能使用！");
					Alert.show("需要掌门或者长老开通该仓库之后才能使用！", "提示", null, null, "确定", "", null, false)
				}



			} else {

				FamilyDepotModule.getInstance().requestDepotGoods(evt.index); //evt.index + 1   bag_id_1 + index  = curId;
				preIndex=tabbar.selectIndex;

			}
		}

		private function openNewDepot():void {
			preIndex=FamilyDepotModule.getInstance().depotNum;
			FamilyDepotModule.getInstance().newDepot(); //FamilyDepotModel.getInstance().depotNum// +1
		}

		private function noHandler():void {
			tabbar.selectIndex=preIndex;
		}

		public function setPreIndex():void {
			preIndex=preIndex - 1;
			tabbar.selectIndex=preIndex;
		}

		override public function closeWindow(save:Boolean=false):void {
			FamilyDepotModule.getInstance().closeFMLdepotPanel();
			super.closeWindow();
		}
	}
}