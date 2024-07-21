package modules.roleStateG.views.details {
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabBar;
	import com.ming.ui.controls.TabNavigation;

	import proto.line.m_role2_getroleattr_toc;

	public class OtherDetailView extends BasePanel {
		private var nav:TabNavigation;
		private var equip:RoleOtherEquipView;
		private var info:RoleOtherInfoView;
		private var currentSelect:int=0;
		private var tabBar:TabBar;

		public function OtherDetailView() {
			super("PlayerInfoView");
		}

		override protected function init():void {
			x=120;
			y=80;

			width=488;
			height=434;

			addTitleBG();
			addContentBG(8, 10, 18);
			addImageTitle("title_role");

			equip=new RoleOtherEquipView;
			info=new RoleOtherInfoView;
			nav=new TabNavigation();
			nav.addItem("属性", equip, 76, 21);
			nav.addItem("荣誉", info, 76, 21);
			//tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onChanged);
			nav.x=8;
			nav.y=0;
			nav.tabBarPaddingLeft=16;
			nav.validateNow();
			addChild(nav);
			this.addEventListener(CloseEvent.CLOSE, onClose);
		}

		public function onClose(e:CloseEvent):void {
			WindowManager.getInstance().removeWindow(this);
		}

		public function update(vo:m_role2_getroleattr_toc):void {
			equip.update(vo);
			info.update(vo);
		}


		private function onChanged(event:TabNavigationEvent):void {
			seletedIndex=event.index;
		}

		public function set seletedIndex(value:int):void {
			if (value == 0) {
				if (contains(info)) {
					this.removeChild(info);
				}
				if (contains(equip) == false) {
					this.addChild(equip);
				}
			} else if (value == 1) {
				if (contains(equip)) {
					this.removeChild(equip);
				}
				if (contains(info) == false) {
					this.addChild(info);
				}
			}
			tabBar.selectIndex=value;
		}

		private function addEquipmentBox():void {
			if (equip == null) {
				equip=new RoleOtherEquipView();
				equip.x=0;
				equip.y=0;
			}
			addChild(equip);
		}

		private function removeEquipmentBox():void {
			if (equip && contains(equip)) {
				removeChild(equip);
			}
		}

		private function addRoleBaseInfo():void {
			if (info == null) {
				info=new RoleOtherInfoView
			}
			//			info.setPlayerInfo(roleInfo, role_ext);
			addChild(info);
		}

		private function removeRoleBaseInfo():void {
			if (info && contains(info)) {
				removeChild(info);
			}
		}

		public function setRoleEquips(roleEquips:Array):void {
			//equip.setRoleEquips(roleEquips);	
		}
	}
}