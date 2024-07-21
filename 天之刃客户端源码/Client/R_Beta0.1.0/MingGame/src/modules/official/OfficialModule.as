package modules.official {
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.net.SocketCommand;
	import com.utils.HtmlUtil;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.official.views.ContributePanel;
	import modules.official.views.KingMujuanPanel;
	import modules.official.views.OfficiaView;
	import modules.official.views.OfficialEquipView;
	import modules.official.views.OfficialListView;
	import modules.official.views.TabOfficiaView;
	import modules.roleStateG.PlayerConstant;
	
	import proto.line.*;

	public class OfficialModule extends BaseModule {
		private static var _instance:OfficialModule;
		private var officePanel:OfficialListView;
		private var officiaView:OfficiaView;
		private var tabofficialView:TabOfficiaView;

		public function OfficialModule() {

		}

		public static function getInstance():OfficialModule {
			if (_instance == null)
				_instance=new OfficialModule();
			return _instance;
		}

		override protected function initListeners():void {
			addMessageListener(NPCActionType.NA_50, openOfficePanel);
//			addMessageListener(NPCActionType.NA_50, openContributePanel);
			addMessageListener(NPCActionType.NA_55, openOfficeEquipPanel);
			addMessageListener(ModuleCommand.OPEN_CONTRIBUTE_PANEL, openContributePanel);

			addSocketListener(SocketCommand.OFFICE_APPOINT, setAppoint);
			addSocketListener(SocketCommand.OFFICE_DISAPPOINT, setDisappoint);
			addSocketListener(SocketCommand.OFFICE_AGREE_APPOINT, setAgreeAppoint);
			addSocketListener(SocketCommand.OFFICE_REFUSE_APPOINT, setRefuseAppoint);
			addSocketListener(SocketCommand.OFFICE_CANCEL_APPOINT, setCancelAppoint);
			addSocketListener(SocketCommand.OFFICE_LAUNCH_COLLECTION, setLaunchCollection);
			addSocketListener(SocketCommand.OFFICE_DONATE, setDonate);
			addSocketListener(SocketCommand.OFFICE_PANEL, setOfficialInfo);
			addSocketListener(SocketCommand.OFFICE_SET_NOTICE, setNotice);
			addSocketListener(SocketCommand.OFFICE_EQUIP_PANEL, setOfficialEquipInfo);
			addSocketListener(SocketCommand.OFFICE_TAKE_EQUIP, setTakeEquip);
			addSocketListener(SocketCommand.ROLE2_QUERY_FACTION_ONLINE_RANK,setFactionRank);
		}

		/*********************************界面视图逻辑********************************************/
		/**
		 *  打开官职管理面板
		 */
		private var sourceLoader:SourceLoader;

		public function openOfficePanel(vo:NpcLinkVO):void {
			getOfficialInfo();
			if (officePanel == null) {
				sourceLoader=new SourceLoader();
				var url:String=GameConfig.ROOT_URL + "com/assets/office/office.swf";
				var msg:String="加载官职系统资源...";
				sourceLoader.loadSource(url, msg, createOfficePanel);
			} else {
				createOfficePanel();
			}
		}

		private function createOfficePanel():void {
			if (officePanel == null) {
				officePanel=new OfficialListView();
				officePanel.initView(sourceLoader);
				sourceLoader=null;
			}
			WindowManager.getInstance().popUpWindow(officePanel, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(officePanel);
		}

		/**
		 * 打开领取官职装备面板
		 */
		private var officeEquipPanel:OfficialEquipView;
		private var office_equip:Array;

		public function openOfficeEquipPanel(link:NpcLinkVO=null):void {
			getOfficialEquipInfo();
			if (officeEquipPanel == null) {
				officeEquipPanel=new OfficialEquipView();
				officeEquipPanel.closeFunc=closeHandler;
			}
			WindowManager.getInstance().popUpWindow(officeEquipPanel, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(officeEquipPanel);
			function closeHandler():void {
				officeEquipPanel.dispose();
				officeEquipPanel=null;
			}
		}
		/**
		 * 打开国王募捐面板
		 */
		private var launchPanel:KingMujuanPanel;

		private function openLaunchPanel():void {
			if (launchPanel == null) {
				launchPanel=new KingMujuanPanel();
				launchPanel.closeFunc=closeHandler;
			}
			WindowManager.getInstance().popUpWindow(launchPanel, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(launchPanel);
			function closeHandler():void {
				launchPanel.dispose();
				launchPanel=null;
			}
		}
		/**
		 * 打开捐款面板
		 */
		private var contributePanel:ContributePanel;

		public function openContributePanel(vo:NpcLinkVO=null):void {
			if (contributePanel == null) {
				contributePanel=new ContributePanel();
				contributePanel.closeFunc=closeHandler;
			}
			WindowManager.getInstance().popUpWindow(contributePanel, WindowManager.UNREMOVE);
			WindowManager.getInstance().centerWindow(contributePanel);
			function closeHandler():void {
				contributePanel.dispose();
				contributePanel=null;
			}
		}

		public function getOfficialView():OfficiaView {
			if (officiaView == null) {
				officiaView=new OfficiaView();
			}
			return officiaView;
		}

		public function getTabOfficialView():TabOfficiaView {
			if (tabofficialView == null) {
				tabofficialView=new TabOfficiaView();
			}
			return tabofficialView;
		}

		public function getFactionRank():void{
			var vo:m_role2_query_faction_online_rank_tos = new m_role2_query_faction_online_rank_tos();
			vo.op_type = 1;
			sendSocketMessage(vo);
		}
		/*********************************消息发送逻辑********************************************/
		/**
		 * 获取官职信息
		 */
		public function getOfficialInfo():void {
			sendSocketMessage(new m_office_panel_tos());
		}

		/**
		 * 获取官职装备信息
		 */
		public function getOfficialEquipInfo():void {
			sendSocketMessage(new m_office_equip_panel_tos());
		}

		/**
		 * 任命官员
		 */
		public function appoint(roleName:String, officeId:int):void {
			var vo:m_office_appoint_tos=new m_office_appoint_tos();
			vo.role_name=roleName;
			vo.office_id=officeId;
			sendSocketMessage(vo);
		}

		/**
		 * 解除官员任命
		 */
		public function disappoint(officeId:int, roleName:String):void {
			var posName:String=HtmlUtil.font(OfficialConstants.OFFICE_NAMES[officeId], "#40DEF9");
			Alert.show("你确定要解除" + HtmlUtil.font(roleName, "#00FF00") + "的" + posName + "职位吗?", "温馨提示", yesHandler);
			function yesHandler():void {
				var vo:m_office_disappoint_tos=new m_office_disappoint_tos();
				vo.office_id=officeId;
				sendSocketMessage(vo);
			}
		}

		/**
		 * 同意国王的任命
		 */
		public function agreeAppoint():void {
			sendSocketMessage(new m_office_agree_appoint_tos());
		}

		/**
		 * 拒绝国王的任命
		 */
		public function refuseAppoint():void {
			sendSocketMessage(new m_office_refuse_appoint_tos());
		}

		/**
		 * 撤销任命
		 */
		public function cancelAppoint(officeId:int):void {
			var vo:m_office_cancel_appoint_tos=new m_office_cancel_appoint_tos();
			vo.office_id=officeId;
			sendSocketMessage(vo);
		}

		/**
		 * 发送募捐
		 */
		public function launchCollection():void {
			sendSocketMessage(new m_office_launch_collection_tos());
		}

		/**
		 * 捐款
		 */
		public function donate(money:Number, type:int=1):void {
			var vo:m_office_donate_tos=new m_office_donate_tos();
			vo.money=money;
			vo.donate_type=type;
			sendSocketMessage(vo);
		}

		/**
		 * 设置官职信息
		 */
		public function setOfficeInfo(officeId:int, officeName:String):void {
			GlobalObjectManager.getInstance().user.attr.office_id=officeId;
			GlobalObjectManager.getInstance().user.attr.office_name=officeName;
			//dispatch(ModuleCommand.OFFICE_CHANGED);
		}

		/**
		 * 更新国王公告
		 */
		public function updateNotice(content:String):void {
			newContent=content;
			var vo:m_office_set_notice_tos=new m_office_set_notice_tos();
			vo.notice_content=content;
			sendSocketMessage(vo);
		}

		public function takeEquip(id:int, num:int):void {
			var vo:m_office_take_equip_tos=new m_office_take_equip_tos;
			vo.take_office_id=id;
			vo.take_num=num;
			sendSocketMessage(vo);
		}

		/*********************************消息接受并处理逻辑********************************************/

		/**
		 * 任命官员 (返回)
		 */
		public function setAppoint(vo:m_office_appoint_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					Tips.getInstance().addTipsMsg("任命通知已成功发送!");
					if (officePanel) {
						officePanel.ordainAndCancel(vo.office_id, vo.role_name);
					}
				} else {
					var nactionId:int=GlobalObjectManager.getInstance().user.base.faction_id;
					var nationName:String=GameConstant.getNation(nactionId);
					Alert.show("恭喜您被" + nationName + "王 " + vo.role_name + " 任命为" + nationName + "的" + vo.office_name, "消息提示", agreeAppoint, refuseAppoint, "接受", "拒绝");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 解除官员任命(返回)
		 */
		public function setDisappoint(vo:m_office_disappoint_toc):void {
			if (vo.succ) {
				if (vo.return_self) {
					Tips.getInstance().addTipsMsg(vo.office_name + "职位已被解除!");
					if (officePanel) {
						officePanel.disappoint(vo.office_id);
					}
				} else {
					setOfficeInfo(0, "");
					Tips.getInstance().addTipsMsg("你的" + vo.office_name + "职务已经被解除！");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 同意国王的任命 (返回)
		 */
		public function setAgreeAppoint(vo:m_office_agree_appoint_toc):void {
			if (vo.succ) {
				if (!vo.return_self) {
					if (officePanel) {
						officePanel.ordain(OfficialConstants.getOfficeIdByName(vo.office_name), vo.role_name);
					}
					Tips.getInstance().addTipsMsg(vo.role_name + "接受您的" + vo.office_name + "任命，为国所用!");
				} else {
					var officeId:int=OfficialConstants.getOfficeIdByName(vo.office_name);
					setOfficeInfo(officeId, vo.office_name);
					Tips.getInstance().addTipsMsg("恭喜你成功当选" + vo.office_name + "职位!");
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 拒绝国王的任命 (返回)
		 */
		public function setRefuseAppoint(vo:m_office_refuse_appoint_toc):void {
			if (vo.succ) {
				if (!vo.return_self) {
					Tips.getInstance().addTipsMsg(vo.role_name + "拒绝您的" + vo.office_name + "任命，请另寻贤明!");
					if (officePanel) {
						officePanel.cancelAppoint(OfficialConstants.getOfficeIdByName(vo.office_name));
					}
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 撤销任命 (返回)
		 */
		public function setCancelAppoint(vo:m_office_cancel_appoint_toc):void {
			if (vo.succ) {
				if (officePanel) {
					officePanel.cancelAppoint(vo.office_id);
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 发送募捐 (返回)
		 */
		public function setLaunchCollection(vo:m_office_launch_collection_toc):void {
			if (vo.succ) {
				openLaunchPanel();
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 * 捐款 (返回)
		 */
		public function setDonate(vo:m_office_donate_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("向国库捐赠银子成功！");
				if (contributePanel) {
					contributePanel.closeWindow();
				}
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}

		/**
		 *  获取官职信息(返回)
		 */
		public function setOfficialInfo(vo:m_office_panel_toc):void {
			OfficialDataManager.getInstance().faction = vo.faction_info;
		}

		/**
		 *  获取官职装备信息(返回)
		 */
		public function setOfficialEquipInfo(vo:m_office_equip_panel_toc):void {
			office_equip=vo.office_equip;
			if (officeEquipPanel) {
				officeEquipPanel.initData(office_equip);
			}
		}

		private function setTakeEquip(vo:m_office_take_equip_toc):void {
			if (vo.succ) {
				Tips.getInstance().addTipsMsg("成功领取了官职装备");
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		private var newContent:String;
		private function setNotice(vo:m_office_set_notice_toc):void {
			if (vo.succ) {
				OfficialDataManager.getInstance().updateNotice(newContent);
			} else {
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		public function setFactionRank(vo:m_role2_query_faction_online_rank_toc):void{
			if(vo.succ){
				if(vo.op_type == 1){
					OfficialDataManager.getInstance().setFactonRank(vo.online_rank);
				}
			}
		}
	}
}