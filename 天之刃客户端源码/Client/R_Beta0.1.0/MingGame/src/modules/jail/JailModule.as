package modules.jail {
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.MoneyTransformUtil;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.jail.views.JailDonateView;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	
	import proto.line.m_jail_donate_toc;
	import proto.line.m_jail_donate_tos;
	import proto.line.m_jail_out_force_toc;
	import proto.line.m_jail_out_force_tos;
	import proto.line.m_jail_out_toc;
	import proto.line.m_jail_out_tos;

	public class JailModule extends BaseModule {
		public function JailModule() {
		}

		private static var instance:JailModule;

		public static function getInstance():JailModule {
			if (!instance) {
				instance=new JailModule();
			}

			return instance;
		}

		override protected function initListeners():void {
			// 服务端消息
			this.addSocketListener(SocketCommand.JAIL_OUT, doJailOutToc);
			this.addSocketListener(SocketCommand.JAIL_DONATE, doJailDonateToc);
			this.addSocketListener(SocketCommand.JAIL_OUT_FORCE, doJailOutForceToc);

			// 模块消息
			this.addMessageListener(NPCActionType.NA_25, doJailOutTos);
			this.addMessageListener(NPCActionType.NA_26, doJailOutForceTos);
			this.addMessageListener(NPCActionType.NA_27, doJailDonate);

		}

		/**
		 * 出狱_toc
		 */

		private function doJailOutToc(vo:m_jail_out_toc):void {
			if (vo.succ) {
				BroadcastSelf.logger("成功出狱，望你浪子回头");
				return;
			}

			BroadcastSelf.logger(vo.reason);
		}

		/**
		 * 出狱_tos
		 */

		private function doJailOutTos(link:NpcLinkVO=null):void {
			var pkPoints:int=GlobalObjectManager.getInstance().user.base.pk_points;
			if (pkPoints >= 18) {
				BroadcastSelf.logger("你的PK值<font color=\"#FF0000\">" + pkPoints + "</font>点≥18点，罪孽深重，不能重返江湖");
				return;
			}

			var vo:m_jail_out_tos=new m_jail_out_tos;
			sendSocketMessage(vo);
		}

		/**
		 * 强行出狱_toc
		 */

		private function doJailOutForceToc(vo:m_jail_out_force_toc):void {
			if (vo.succ) {
				var silver:int=GlobalObjectManager.getInstance().user.attr.silver;
				var silver_bind:int=GlobalObjectManager.getInstance().user.attr.silver_bind;
				GlobalObjectManager.getInstance().user.attr.silver=vo.silver;
				GlobalObjectManager.getInstance().user.attr.silver_bind=vo.silver_bind;

				// 更新背包
				dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);

				var msg:String="成功出狱，花掉";
				if (silver - vo.silver > 0) {
					msg=msg + "不绑定银子" + MoneyTransformUtil.silverToOtherString(silver - vo.silver);
				}

				if (silver_bind - vo.silver_bind > 0) {
					msg=msg + "绑定银子" + MoneyTransformUtil.silverToOtherString(silver_bind - vo.silver_bind);
				}


				BroadcastSelf.logger(msg);
			}

			BroadcastSelf.logger(vo.reason);
		}

		/**
		 * 强行出狱_tos
		 */

		private function doJailOutForceTos(link:NpcLinkVO=null):void {
			// PK值小于18强行出狱不扣银子
			var pkPoints:int=GlobalObjectManager.getInstance().user.base.pk_points;
			if (pkPoints < 18) {
				doJailOutTos();
				return;
			}

			Alert.show("花费<font color=\"#FF0000\">1</font>锭银子，但是你的PK值不会有任何改变。你确定要强行出狱吗？", "捐献保释金", doJailOutForceTos2);

			function doJailOutForceTos2():void {
				var silver:int=GlobalObjectManager.getInstance().user.attr.silver;
				var silverBind:int=GlobalObjectManager.getInstance().user.attr.silver_bind;

				if (silver + silverBind < 10000) {
					BroadcastSelf.logger("银子不足1锭，无法强行出狱");
					return;
				}

				var vo:m_jail_out_force_tos=new m_jail_out_force_tos;
				sendSocketMessage(vo);
			}
		}

		/**
		 * 捐献监狱建设费_toc
		 */

		private function doJailDonateToc(vo:m_jail_donate_toc):void {
			if (vo.succ) {
				var pkPoitns:int=GlobalObjectManager.getInstance().user.base.pk_points;

				GlobalObjectManager.getInstance().user.attr.gold=vo.gold;
				GlobalObjectManager.getInstance().user.attr.gold_bind=vo.gold_bind;
				GlobalObjectManager.getInstance().user.base.pk_points=vo.pk_points;

				// 更新属性面板
				dispatch(ModuleCommand.ROLE_PKPOINT_CHANGE);
				// 更新背包
				dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);

				BroadcastSelf.logger("成功捐献" + (pkPoitns - vo.pk_points) + "元宝，PK值下降" + (pkPoitns - vo.pk_points) + "点");
				return;
			}

			BroadcastSelf.logger(vo.reason);
		}

		/**
		 * 捐献监狱建设费_tos
		 */

		private var jailDonateView:JailDonateView;

		private function doJailDonate(link:NpcLinkVO=null):void {
			if (jailDonateView == null) {
				jailDonateView=new JailDonateView("捐献监狱建设费");
			}

			WindowManager.getInstance().popUpWindow(jailDonateView);
		}

		public function doJailDonate2(goldInput:int):void {
			if (GlobalObjectManager.getInstance().user.base.pk_points == 0) {
				BroadcastSelf.logger("你的PK为0 ，不需要捐献元宝");
				return;
			}

			var gold:int=GlobalObjectManager.getInstance().user.attr.gold;
			var goldBind:int=GlobalObjectManager.getInstance().user.attr.gold_bind;
			if (gold + goldBind < goldInput) {
				BroadcastSelf.logger("不足" + goldInput + "元宝，捐献失败");
				return;
			}

			var vo:m_jail_donate_tos=new m_jail_donate_tos;
			vo.gold=goldInput;
			sendSocketMessage(vo);
		}

	}
}