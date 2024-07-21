package modules.finery.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import modules.finery.FineryModule;
	import modules.finery.StoveConstant;
	import modules.finery.views.bind.BindView;
	import modules.finery.views.box.BoxView;
	import modules.finery.views.compose.ComposeView;
	import modules.finery.views.disassembly.DisassemblyView;
	import modules.finery.views.exalt.ExaltView;
	import modules.finery.views.insert.InsertView;
	import modules.finery.views.item.StoneBox;
	import modules.finery.views.punch.PunchView;
	import modules.finery.views.recast.RecastView;
	import modules.finery.views.refine.RefineView;
	import modules.finery.views.strength.StrengthView;
	import modules.finery.views.upgrade.UpgradeView;

	public class StovePanel extends BasePanel {
		public static var currentIndex:String;
		private var tabNavigation:TabNavigation;
		public var boxView:BoxView;
		public var exaltView:ExaltView;
		public var punchView:PunchView;
		public var insertView:InsertView;
		public var disassemblyView:DisassemblyView;
		public var bindView:BindView;
		public var strengthView:StrengthView;
		public var composeView:ComposeView;
		public var refineView:RefineView;
		public var upgradeView:UpgradeView;
		public var recastView:RecastView;
		public var retakeBtn:Button;

		public static const TABNAME_ARRAY:Object={BOX: "天工开物", EQUIP_EXALT: "精炼", EQUIP_PUNCH: "开孔", STONE_INLAY: "镶嵌",
				STONE_SPLIT: "拆卸", EQUIP_BIND: "绑定", EQUIP_REINFORCE: "强化", MATERIAL_COMPOSE: "合成", REFINE_FUNCTION: "炼制", UPGRADE:"升级",RECAST:"重铸"};

		public function StovePanel() {
		}

		override protected function init():void {
			this.width=602;
			this.height=475;
			this.x=(GlobalObjectManager.GAME_WIDTH - this.width) / 6;
			this.y=(GlobalObjectManager.GAME_HEIGHT - this.height) / 2;
			addImageTitle("title_stove");
			addTitleBG(448);
			addContentBG(5,5,24);

//			if (StoveConstant.boxIsOpen) {
//				boxView=new BoxView();
//			}
			exaltView=new ExaltView();
			punchView=new PunchView();
			insertView=new InsertView();
			disassemblyView=new DisassemblyView();
			bindView=new BindView();
			strengthView=new StrengthView();
			composeView=new ComposeView();
//			refineView=new RefineView();
//			upgradeView=new UpgradeView();
			recastView = new RecastView();

			currentIndex=TABNAME_ARRAY.BOX;
			//头部导航条
			tabNavigation=new TabNavigation();
			tabNavigation.removeTabContainerSkin();
			this.addChild(tabNavigation);
			tabNavigation.width = 590;
			tabNavigation.height = 422;
			tabNavigation.x=8;
//			if (StoveConstant.boxIsOpen) {
//				tabNavigation.addItem(TABNAME_ARRAY.BOX, boxView, 55,25);
//			}
//			tabNavigation.addItem(TABNAME_ARRAY.UPGRADE, upgradeView, 55,25);
//			tabNavigation.addItem(TABNAME_ARRAY.REFINE_FUNCTION, refineView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.EQUIP_REINFORCE, strengthView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.EQUIP_BIND, bindView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.EQUIP_EXALT, exaltView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.RECAST, recastView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.EQUIP_PUNCH, punchView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.STONE_INLAY, insertView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.STONE_SPLIT, disassemblyView, 55,25);
			tabNavigation.addItem(TABNAME_ARRAY.MATERIAL_COMPOSE, composeView, 55,25);
			
			tabNavigation.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChangeHandler);
			retakeBtn=ComponentUtil.createButton("取回物品", 510, 2, 60, 24, this);
			retakeBtn.setToolTip("点击按钮，取回存放在旧天工炉中的物品并放会背包中。");
			retakeBtn.visible=false;
			retakeBtn.enabled=false;
		}
		
		public function set selectIndex(value:int):void{
			tabNavigation.selectedIndex = value;
		}

		private function onChangeHandler(event:TabNavigationEvent):void {
			var selectItem:*=tabNavigation.tabContainer.getDisplayObject(tabNavigation.selectedIndex);
			if (selectItem is BoxView) {
				currentIndex=TABNAME_ARRAY.BOX;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is ExaltView) {
				currentIndex=TABNAME_ARRAY.EQUIP_EXALT;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is PunchView) {
				currentIndex=TABNAME_ARRAY.EQUIP_PUNCH;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is InsertView) {
				currentIndex=TABNAME_ARRAY.STONE_INLAY;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is DisassemblyView) {
				currentIndex=TABNAME_ARRAY.STONE_SPLIT;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is BindView) {
				currentIndex=TABNAME_ARRAY.EQUIP_BIND;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is StrengthView) {
				currentIndex=TABNAME_ARRAY.EQUIP_REINFORCE;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is ComposeView) {
				currentIndex=TABNAME_ARRAY.MATERIAL_COMPOSE;
				selectItem.initUI();
				selectItem.reset();
			} else if (selectItem is RefineView) {
				currentIndex=TABNAME_ARRAY.REFINE_FUNCTION;
				selectItem.initUI();
				selectItem.reset();
			}else if (selectItem is UpgradeView){
				currentIndex=TABNAME_ARRAY.UPGRADE;
				selectItem.initUI();
				selectItem.reset();
			}else if(selectItem is RecastView){
				currentIndex=TABNAME_ARRAY.RECAST;
				selectItem.initUI();
				selectItem.reset();
			}
		}

		public function updateMaterial():void {
			if(parent){
				switch (currentIndex) {
					case TABNAME_ARRAY.BOX:
						boxView.update();
						break;
					case TABNAME_ARRAY.EQUIP_EXALT:
						exaltView.update();
						break; //精炼
					case TABNAME_ARRAY.EQUIP_PUNCH:
						punchView.update();
						break; //开孔
					case TABNAME_ARRAY.STONE_INLAY:
						insertView.update();
						break; //镶嵌
					case TABNAME_ARRAY.STONE_SPLIT:
						disassemblyView.update()
						break; //手拆御
					case TABNAME_ARRAY.EQUIP_BIND:
						bindView.update();
						break; //绑定
					case TABNAME_ARRAY.EQUIP_REINFORCE:
						strengthView.update();
						break; //强化
					case TABNAME_ARRAY.MATERIAL_COMPOSE:
						composeView.update();
						break; //材料合成
					case TABNAME_ARRAY.REFINE_FUNCTION:
						refineView.update();
						break; //炼制功能
					case TABNAME_ARRAY.UPGRADE:
						upgradeView.update();
						break;
					case TABNAME_ARRAY.RECAST:
						recastView.update();
						break;
				}
			}
		}

		public function reset():void {
			switch (currentIndex) {
				case TABNAME_ARRAY.BOX:
					boxView.reset();
					break;
				case TABNAME_ARRAY.EQUIP_EXALT:
					exaltView.reset();
					break;
				case TABNAME_ARRAY.EQUIP_PUNCH:
					punchView.reset();
					break; //开孔
				case TABNAME_ARRAY.STONE_INLAY:
					insertView.reset();
					break; //镶嵌
				case TABNAME_ARRAY.STONE_SPLIT:
					disassemblyView.reset()
					break; //手拆御
				case TABNAME_ARRAY.EQUIP_BIND:
					bindView.reset();
					break; //绑定
				case TABNAME_ARRAY.EQUIP_REINFORCE:
					strengthView.reset();
					break; //强化
				case TABNAME_ARRAY.MATERIAL_COMPOSE:
					composeView.reset();
					break; //材料合成
				case TABNAME_ARRAY.REFINE_FUNCTION:
					refineView.reset();
					break; //炼制功能
				case TABNAME_ARRAY.UPGRADE:
					upgradeView.reset();
					break;
				case TABNAME_ARRAY.RECAST:
					recastView.reset();
					break;
			}
		}

		/**
		 * 设置取回按钮是否可见
		 * @param visible
		 *
		 */
		public function setRetakeBtnVisible(visible:Boolean):void {
			retakeBtn.enabled=visible;
			retakeBtn.visible=visible;
		}

		public function checkBoxState():void {
			if (tabNavigation == null) {
				return;
			}
			if (boxView) {
				if (!StoveConstant.boxIsOpen) {
					//移除box
					var index:int=tabNavigation.tabContainer.getDisplayObjectIndex(boxView);
					if (index != -1) {
						tabNavigation.tabContainer.removeItemByIndex(index);
						tabNavigation.tabBar.removeItemByIndex(index);
						boxView.unload();
						boxView=null;
					}
					if (currentIndex == TABNAME_ARRAY.BOX) {
						tabNavigation.tabBar.validateNow();
						tabNavigation.tabContainer.validateNow();
						tabNavigation.selectedIndex=1;
						tabNavigation.validateNow();
						tabNavigation.selectedIndex=0;
					}else if(tabNavigation.selectedIndex > index){
						tabNavigation.selectedIndex-=1;
					}
					return;
				}
				//检测是否为免费
				boxView.checkState();
			} else {
				if (StoveConstant.boxIsOpen) {
					//创建box
					boxView=new BoxView();
					tabNavigation.addItem(TABNAME_ARRAY.BOX, boxView, 60, 25, 0);
					tabNavigation.validateNow();
					tabNavigation.selectedIndex += 1;
				}
			}
		}
	}
}