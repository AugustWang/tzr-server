package modules.mount.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.WindowManager;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;

	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;

	import proto.line.m_equip_mount_changecolor_toc;

	public class MountUpgradePanel2 extends BasePanel {

		private var pointX:int=0;
		private var pointY:int=0;

		public function MountUpgradePanel2() {
			super();
			//title="坐骑提速";
			initUI();
		}

		private var tabNavigation:TabNavigation;
		public var mountUpdateView:MountUpgradeView;
		public var mountUpdateFaceView:MountUpdateFaceView;

		private function initUI():void {
			this.width=490;
			this.height=434;
			addTitleBG();
			addContentBG(8,8,0);
			addImageTitle("title_mountUpgrade");
			if (mountUpdateView == null) {
				mountUpdateView=new MountUpgradeView();
			}
			addChild(mountUpdateView);
		}

		private function onChangeTabHandler(Evt:TabNavigationEvent):void {

		}

		override public function open():void {
			super.open()
			WindowManager.getInstance().centerWindow(this);
//			if (pointX == 0 && pointY == 0) {
//				pointX=(GlobalObjectManager.GAME_WIDTH * 0.5 - 275 - this.width * 0.5) >> 0;
//				pointY=(GlobalObjectManager.GAME_HEIGHT * 0.5 - 210 - this.height * 0.5) >> 0;
//			}
//			this.x=pointX;
//			this.y=pointY;
		}

		override public function closeWindow(save:Boolean=false):void {
			super.closeWindow(save);
			mountUpdateView.destoryData();
		}

		//当购买提速牌之后的更新
		public function update():void {
			mountUpdateView.messagePanel.updataBTN(true);
			mountUpdateView.updatePanel.updateUI();
		}

		public function updateBack(vo:m_equip_mount_changecolor_toc):void {
			mountUpdateView.messagePanel.updataBTN(true);
			if (vo.mount.id != 0) {
				var baseItemVO:BaseItemVO=PackageModule.getInstance().getBaseItemVO(vo.mount);
				mountUpdateView.update(baseItemVO);
				//改变下背包里马的数据
				PackManager.getInstance().updateGoods(baseItemVO.bagid, baseItemVO.position, baseItemVO);
			} else {
				//后台数据已经返回，可以点击了
				mountUpdateView.messagePanel.canClick();
			}
		}

	}
}