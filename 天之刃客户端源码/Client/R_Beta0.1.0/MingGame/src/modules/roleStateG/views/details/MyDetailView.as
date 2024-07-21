package modules.roleStateG.views.details {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.gs.TweenLite;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.ToggleButton;
	
	import flash.display.Sprite;
	
	import modules.broadcast.views.Tips;
	import modules.equiponekey.EquipOneKeyModule;
	import modules.equiponekey.views.RoleChangeClothingView;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionModule;
	import modules.playerGuide.GuideConstant;
	import modules.playerGuide.PlayerGuideModule;
	import modules.roleStateG.views.EquipItem;
	
	import proto.line.m_title_get_role_titles_toc;

	/**
	 * 角色详细信息视图
	 * @author yechengcong
	 *
	 */
	public class MyDetailView extends BasePanel {
		private var equip:RoleMyEquipView;
		private var info:RoleMyInfoView;
		private var mount:RoleMyMountView;
		private var clothing:RoleChangeClothingView;

		private var equip_btn:ToggleButton;
		private var info_btn:ToggleButton;
		private var mount_btn:ToggleButton;
		private var currentSelect:int=0;
		private var nav:TabNavigation;

		private var currentView:Sprite;

		public function MyDetailView() {
			super("");
		}

		override protected function init():void {
			x=120;
			y=80;
			
			width=488;
			height=434;
			
			addTitleBG();
			addContentBG(8,10,18);
			addImageTitle("title_role");
			
			equip=new RoleMyEquipView;
			info=new RoleMyInfoView;
			mount=new RoleMyMountView;
			nav=new TabNavigation();
			nav.addItem("属性",equip, 76, 21);
			nav.addItem("荣誉",info, 76, 21);
			nav.addItem("坐骑",mount, 76, 21);
			//tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChanged);
			nav.x=8;
			nav.y=0;
			nav.tabBarPaddingLeft = 16;
			nav.validateNow();
			addChild(nav);
			this.addEventListener(CloseEvent.CLOSE, onClose);
		}

		public function update():void {
			if (this.parent) {
				info.update();
				equip.update();
				mount.update();
			}
		}

		public function updateMount():void {
			if (this.parent) {
				mount.update();
			}
		}

		public function updatePrestige():void {
			if (this.parent && info) {
				info.updatePrestige();
			}
		}

		public function updateMyTitles(vo:m_title_get_role_titles_toc):void {
			info.updateMyTitles(vo);
		}

		public function updatePKPointTime(minite:int):void {
			info.upDatePKTime(minite);
		}

		public function set seletedIndex(value:int):void {
			if (currentView && contains(currentView)) {
				removeChild(currentView);
			}
			if (value == 0) {
				if (contains(equip) == false) {
					equip.alpha=0;
					this.addChild(equip);
					TweenLite.to(equip, 1, {alpha: 1});
				}
				currentView=equip;
			} else if (value == 1) {
				if (contains(info) == false) {
					info.alpha=0;
					this.addChild(info);
					TweenLite.to(info, 1, {alpha: 1});
				}
				currentView=info;
			} else if (value == 3) {
				if (contains(mount) == false) {
					mount.alpha=0;
					this.addChild(mount);
					TweenLite.to(mount, 1, {alpha: 1});
				}
				currentView=mount;
			} else {
				if (clothing == null) {
					clothing=EquipOneKeyModule.getInstance().getClothingView();
					clothing.y=42;
				}
				if (contains(clothing) == false) {
					clothing.alpha=0;
					this.addChild(clothing);
					TweenLite.to(clothing, 1, {alpha: 1});
				}
				currentView=clothing;
			}
			//nav.selectIndex=value;
		}

		private var currentIndex:int;

		private function onChanged(event:TabNavigationEvent):void {
			if (event.index == 2) {
				if (GlobalObjectManager.getInstance().user.attr.level < 20) {
			//		Tips.getInstance().addTipsMsg("一键换装功能需要等级达到20级才能开启！");
			//		nav.selectIndex=currentIndex;
					return;
				}
			}
			currentIndex=event.index;
			seletedIndex=event.index;
		}

		public function getEquipItem(index:int):EquipItem {
			return equip.getEquipItemByName(index);
		}

		public function showPopertyBorder():void {
			info.showPropertyBorder();
		}

		public function onClose(e:CloseEvent):void {
			WindowManager.getInstance().removeWindow(this);
			Dispatch.dispatch(GuideConstant.CLOSE_MY_DETAIL_VIEW);
		}
	}
}