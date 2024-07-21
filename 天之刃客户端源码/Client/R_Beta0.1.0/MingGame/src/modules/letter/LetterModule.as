package modules.letter {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;

	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.letter.messageBody.DelLetterData;
	import modules.letter.messageBody.GetAccessoryData;
	import modules.letter.messageBody.LetterDetailData;
	import modules.letter.messageBody.WriteLetterData;
	import modules.letter.view.LetterPanel;

	import proto.common.p_goods;
	import proto.line.m_gm_score_toc;
	import proto.line.m_gm_score_tos;
	import proto.line.m_letter_accept_goods_tos;
	import proto.line.m_letter_delete_tos;
	import proto.line.m_letter_family_send_tos;
	import proto.line.m_letter_get_toc;
	import proto.line.m_letter_get_tos;
	import proto.line.m_letter_open_tos;
	import proto.line.m_letter_p2p_send_tos;
	import proto.line.m_letter_send_toc;
	import proto.line.m_letter_state_change_toc;
	import proto.line.m_letter_state_change_tos;
	import proto.line.p_letter_simple_info;

	public class LetterModule extends BaseModule {
		private static var _instance:LetterModule;
		public var panel:LetterPanel;
		private var detailBody:LetterDetailData;

		public function LetterModule(sigleton:SigletonPress) {
		}

		public static function getInstance():LetterModule {
			if (_instance == null) {
				_instance=new LetterModule(new SigletonPress);
			}
			return _instance;
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.OPEN_LETTER_LIST, openLetterList);
			addMessageListener(ModuleCommand.OPEN_WRITE_LETTER, openLetter);
			addMessageListener(ModuleCommand.ENTER_GAME, isNewLetter);

			addSocketListener(SocketCommand.LETTER_GET, allLetterBack);
			addSocketListener(SocketCommand.LETTER_SEND, sendLetterBack);
			addSocketListener(SocketCommand.GM_SCORE, gmScoreBack);
			addSocketListener(SocketCommand.LETTER_STATE_CHANGE, letterStateChangeBack);
			addSocketListener(SocketCommand.LETTER_DELETE, letterDelBack);
			addSocketListener(SocketCommand.LETTER_ACCEPT_GOODS, getAccessoryBack);
			addSocketListener(SocketCommand.LETTER_OPEN, letterOpenBack);
			addSocketListener(SocketCommand.LETTER_P2P_SEND, sendLetterBack);
			addSocketListener(SocketCommand.LETTER_FAMILY_SEND, familyLetterBack);
		}

		/**
		 *收到请求打开信息界面
		 *
		 */
		private function openLetterList():void {
			openPanel();
		}

		/**
		 *特定人发信息定义的接口
		 * @param receiver
		 *
		 */
		public function openLetter(receiver:String):void {
			initPanel();
			panel.writeLetter(receiver);
		}

		public function writeLetter(receiver:String, content:String="", isFamilyLetter:Boolean=false):void {
			initPanel();
			panel.writeLetter(receiver, content, isFamilyLetter);
		}

		/**
		 *
		 * 请求所有的信件
		 */
		private function getLetter():void {
			var vo:m_letter_get_tos=new m_letter_get_tos();
			this.sendSocketMessage(vo);
		}

		/**
		 *初始化信件面本版
		 *
		 */
		private function initPanel():void {
			if (panel == null) {
				panel=new LetterPanel();
				panel.initView();
				panel.x=300;
				panel.y=90;
				panel.addEventListener(CloseEvent.CLOSE, onClose);
			}
		}

		/**
		 *获取所有信件
		 * @param data
		 *
		 */
		private function allLetterBack(data:Object=null):void {
			initPanel();
			var isUnread:Boolean=false;
			var vo:m_letter_get_toc=data as m_letter_get_toc;
			if (vo == null)
				return;
			panel.appendData(vo);
			for (var i:int=0; i < vo.letters.length; i++) {
				if (p_letter_simple_info(vo.letters[i]).state == LetterType.UNOPEN && p_letter_simple_info(vo.letters[i]).sender != GlobalObjectManager.getInstance().user.base.role_name) {
					isUnread=true;
					break;
				}
			}
			if (isUnread) {
				Dispatch.dispatch(ModuleCommand.FLASH_SOMETHING, "letter")
			}
		}
		/**
		 *打开
		 */
		private var isOpen:Boolean=false; //当前这个letterPanel是否打开着

		private function openPanel():void {
			isOpen=true;
			initPanel();
			panel.open();
		}

		/**
		 *关闭
		 * @param evt
		 *
		 */
		private function onClose(evt:CloseEvent):void {
			isOpen=false;
			initPanel();
			panel.closeWindow();
		}

		/**
		 *请求打开信件
		 *
		 */
		public function sendOpenLetter(vo:m_letter_open_tos):void {
			this.sendSocketMessage(vo);
		}

		/**
		 *请求打开信件返回
		 * @param data
		 *
		 */
		public function letterOpenBack(data:Object):void {
			if (panel && panel.messageBody) {
				panel.messageBody.getLetterDetail(panel, data);
			}
		}

		//登录向服务器请求看是否有新的新件(在小地图里调用)
		public function isNewLetter():void {
			getLetter();
		}

		public function getView():LetterPanel {
			initPanel();
			return panel;
		}

		/**
		 *删除信件发送请求
		 * @param vo
		 *
		 */
		private var delLetterBody:DelLetterData;

		public function sendDelLetter(vo:m_letter_delete_tos, delLetterBody:DelLetterData):void {
			this.delLetterBody=delLetterBody;
			this.sendSocketMessage(vo);
		}

		/**
		 *删除信件返回
		 *
		 */
		public function letterDelBack(data:Object):void {
			if (panel && delLetterBody) {
				delLetterBody.getDelBack(panel, data);
			}
		}

		/**
		 *发送信件
		 * @param vo
		 *
		 */
		private var temp:WriteLetterData;

		public function sendLetter(vo:m_letter_p2p_send_tos, writeLetterBody:WriteLetterData):void {
			temp=writeLetterBody;
			this.sendSocketMessage(vo);
		}

		/**
		 *
		 *发送信件返回
		 *
		 */
		public function sendLetterBack(message:Object):void {
			if (!isOpen) {
				Dispatch.dispatch(ModuleCommand.FLASH_SOMETHING, "letter");
			} else {
				Dispatch.dispatch(ModuleCommand.STOP_FLASH_SOMETHING, "letter");
			}
			if (temp) {
				temp.getDataFromService(panel, message);
			} else {
				temp=new WriteLetterData();
				temp.getDataFromService(panel, message);
			}
		}

		/**
		 * GM评分返回
		 * @param data
		 *
		 */
		public function gmScoreBack(data:Object):void {
			var gmVo:m_gm_score_toc=data as m_gm_score_toc;
			if (gmVo == null)
				return;
			if (gmVo.succ && panel) {
				panel.messageBody.gmBackFromService(gmVo);
			} else {
				Tips.getInstance().addTipsMsg(gmVo.reason);
			}
		}

		/**
		 *请求GM评分
		 * @param vo
		 *
		 */
		public function sendGmScore(vo:m_gm_score_tos):void {
			this.sendSocketMessage(vo);
		}

		/**
		 *请求信件状态改变
		 * @param vo
		 *
		 */
		public function sendLetterStateChange(vo:m_letter_state_change_tos):void {
			this.sendSocketMessage(vo);
		}

		/**
		 *信件状态改变返回
		 * @param data
		 *
		 */
		public function letterStateChangeBack(data:Object):void {
			var changeVo:m_letter_state_change_toc=data as m_letter_state_change_toc;
			if (changeVo == null)
				return;
			if (changeVo.succ && panel) {
				panel.messageBody.changeBackFromService(changeVo);
			} else {
				Tips.getInstance().addTipsMsg(changeVo.reason);
			}
		}

		/**
		 *通知背包领取附件
		 * @param vo
		 *
		 */
		public function sendToPackage(vo:p_goods):void {
			this.dispatch(ModuleCommand.LETTER_GET_ACCESSORY, vo);
		}
		/**
		 *领取附件向服务端发送请求
		 *
		 */
		private var getAccessoryBody:GetAccessoryData;

		public function sendGetAccessory(vo:m_letter_accept_goods_tos, getAccessoryBody:GetAccessoryData):void {
			this.getAccessoryBody=getAccessoryBody;
			this.sendSocketMessage(vo);
		}

		/**
		 *领取附件服务端返回
		 * @param data
		 *
		 */

		public function getAccessoryBack(data:Object):void {
			if (panel && getAccessoryBody) {
				getAccessoryBody.getAccessoryBack(panel, data);
			}
		}

		/**
		 *发送门派信件
		 * @param vo
		 *
		 */
		public function sendFamilyLetter(vo:m_letter_family_send_tos):void {
			this.sendSocketMessage(vo);
		}

		/**
		 *门派信件返回
		 * @param data
		 *
		 */
		public function familyLetterBack(data:Object):void {
			var vo:m_letter_send_toc=data as m_letter_send_toc;
			if (vo == null)
				return;
			if (vo.succ) {
				if (GlobalObjectManager.getInstance().user.base.role_name == vo.letter.sender) {
					Tips.getInstance().addTipsMsg("信件发送成功");
				}
				this.panel.addLetter(vo.letter);
			} else {
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}

		/**
		 *
		 * @param data
		 * @param packageId
		 * @param packagePosition
		 *
		 */
		public function getLetterAccessory(data:Object, packageId:int, packagePosition:int):void {
			var body:GetAccessoryData=new GetAccessoryData();
			body.getAccessory(panel.getLetterDetail().getAccessory(), packageId, packagePosition, panel.getLetterDetail());
		}

		/**
		 *清空写信面板附件的框
		 *
		 */
		public function disposeWriteAttach():void {
			if (panel) {
				panel.letterWrite.disposeAccessory();
			}
		}

	}
}

class SigletonPress {
}