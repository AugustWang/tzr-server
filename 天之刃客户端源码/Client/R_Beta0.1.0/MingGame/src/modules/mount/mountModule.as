package modules.mount {
	import com.common.GlobalObjectManager;
	import com.components.MessageIcon;
	import com.managers.LayerManager;
	import com.net.SocketCommand;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mount.views.MountOverDateView;
	import modules.mount.views.MountUpgradePanel2;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.npc.NPCActionType;
	import modules.system.SystemConfig;
	
	import proto.common.p_goods;
	import proto.line.m_equip_mount_changecolor_toc;

	public class mountModule extends BaseModule {
		//private var upGradePanel:MountUpgradePanel;

		private var upGradePanel:MountUpgradePanel2;
		//坐骑过期面板
		private var tipView:MountOverDateView;
		
		public function mountModule() {
		}

		private static var instance:mountModule;

		public static function getInstance():mountModule {
			if (instance == null) {
				instance=new mountModule();
			}
			return instance;
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.EQUIP_MOUNT_CHANGECOLOR, mountChangeColor);
			
			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
			
			addMessageListener(NPCActionType.NA_78, openMountUpGradePanel);
			addMessageListener(ModuleCommand.MOUNT_UPGRADE_CLEAN, upGradeClean);
			addMessageListener(ModuleCommand.MOUNT_TOKEN_CHANHE, tokenChange);
		}
		
		private var _icon:MessageIcon;
		private var _data:p_goods;
		private function onEnterGame():void
		{
			var length:int=GlobalObjectManager.getInstance().user.attr.equips.length;
			for (var i:int=0; i < length; i++) {
				if (GlobalObjectManager.getInstance().user.attr.equips[i].loadposition == 15) {
					//当前正在使用的坐骑
					var currentMount:p_goods=GlobalObjectManager.getInstance().user.attr.equips[i];
					//坐骑过期
					if(SystemConfig.serverTime >= currentMount.end_time && currentMount.end_time != 0)
					{
						//如果他正在骑马中，先让它下马
						if( GlobalObjectManager.getInstance().isMount ){
							var mountID:int = GlobalObjectManager.getInstance().getMountID();
							PackageModule.getInstance().mountDown( mountID );
						}
						
						_data = currentMount;
						_icon = new MessageIcon("lixianjingyan");
						_icon.callBack = iconClickHandler;
						_icon.x = (GlobalObjectManager.GAME_WIDTH - _icon.width) / 2;
						_icon.y = (GlobalObjectManager.GAME_HEIGHT - _icon.height) / 2;
						LayerManager.uiLayer.addChild(_icon);
						_icon.startFlick();
					}
				}
			}
		}
		
		private function iconClickHandler():void
		{
			// 移除叹号
			if (_icon && _icon.parent)
				_icon.parent.removeChild(_icon);
			
			openTipView(_data);
		}

		private function tokenChange():void {
			if (upGradePanel)
				upGradePanel.update();
		}

		private function upGradeClean():void {
			//if(upGradePanel)upGradePanel.clean();
		}

		private function mountChangeColor(vo:m_equip_mount_changecolor_toc):void {
			if (vo.succ) {
				if (upGradePanel)
					upGradePanel.updateBack(vo);
				var s:String="消耗【坐骑提速牌】×1，坐骑颜色成功提升为<font color='" + ItemConstant.COLOR_VALUES[vo.color] +
					"'>" + ItemConstant.COLOR_NAMES[vo.color] + "</font>。";
				BroadcastSelf.logger(s);
				Tips.getInstance().addTipsMsg(s);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		//坐骑过期面板
		public function openTipView(mountData:p_goods):void {
			if(tipView == null)
			{
				tipView = new MountOverDateView();
			}
			tipView.openWin(mountData);
		}

		public function openMountUpGradePanel(value:Object=null):void {
//			if (upGradePanel == null) {
//				upGradePanel = new MountUpgradePanel()
//					
//				var up2:MountUpgradePanel2 = new MountUpgradePanel2();
//				up2.open();
//			}
//			upGradePanel.open();

			if (upGradePanel == null) {
				upGradePanel=new MountUpgradePanel2();
			} else {
				upGradePanel.mountUpdateView.resetData();
			}
			upGradePanel.open();
		}
	}
}