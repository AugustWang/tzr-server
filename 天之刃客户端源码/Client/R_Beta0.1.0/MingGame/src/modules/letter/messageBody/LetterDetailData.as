package modules.letter.messageBody
{
	import com.ming.core.IDataRenderer;
	
	import modules.letter.LetterModule;
	import modules.letter.LetterType;
	import modules.letter.LetterVOs;
	import modules.letter.view.LetterItemRenderer;
	import modules.letter.view.LetterPanel;
	import modules.letter.view.detail.LetterDetail;
	
	import proto.line.m_gm_score_toc;
	import proto.line.m_letter_open_toc;
	import proto.line.m_letter_open_tos;
	import proto.line.m_letter_state_change_toc;
	import proto.line.m_letter_state_change_tos;
	import proto.line.p_letter_info;
	import proto.line.p_letter_simple_info;

	public class LetterDetailData
	{
		private var _view:LetterDetail;
		private var _item:IDataRenderer;
		private var letterInfo:p_letter_info;
		private var letterSimpleInfo:p_letter_simple_info;
		private var letterItemRender:IDataRenderer;
		public function LetterDetailData()
		{
			super();
		}
		/**
		 *服务端返回的信件内容的信息 
		 * @param view
		 * @param message
		 * 
		 */		
		public function getLetterDetail(view:LetterPanel, message:Object):void{
			var vo:m_letter_open_toc = message as m_letter_open_toc;
			if(vo == null)return;
			if(vo.succ == false)
				return;
			
			_view.param = vo.result;
			_view.visibleGetAttachBtn(vo.result);
			letterInfo = vo.result;//记录信件内容
			
			if(_item != null){
				var temp:p_letter_simple_info = _item.data as p_letter_simple_info;
				letterSimpleInfo = temp;
				if(temp != null && temp.state == LetterType.UNOPEN){
					temp.state = LetterType.OPEN;
					_item.data = temp;
				}
				_view.simpleParam = temp;
			}
			
			_item = null;
			_view = null;
		}
		/**
		 *直接点击打开信件调用的接口 
		 * @param item
		 * @param view
		 * 
		 */		
		public function getDetail(item:IDataRenderer, view:LetterDetail):void{
			var temp:p_letter_simple_info = item.data as p_letter_simple_info;
			_view = view;
			_item = item;
			letterItemRender = item;
			send(temp);
		}
		
		/**
		 *请求打开信件 
		 * @param temp
		 * 
		 */		
		private function send(temp:p_letter_simple_info):void{
			var vo:m_letter_open_tos = new m_letter_open_tos();
			vo.letter_id = temp.id;
			vo.table = temp.table;
			vo.is_self_send = LetterVOs.isSelfSend(temp);
			LetterModule.getInstance().sendOpenLetter(vo);
		}
		/**
		 *上一页的处理 
		 * @param view
		 * 
		 */		
		public function getPriDetail(view:LetterDetail):void{
			this._view = view;
			var temp:p_letter_simple_info = LetterModule.getInstance().getView().getLetter(true);
			if(temp == null)return;
			var item:LetterItemRenderer = view.nextLetterItemRender; 
			this._item = item;
			
			send(temp);
		}
		/**
		 *下一页的处理 
		 * @param view
		 * 
		 */		
		public function getNextDetail(view:LetterDetail):void{
			this._view = view;
			var temp:p_letter_simple_info = LetterModule.getInstance().getView().getLetter(false);
			if(temp == null)return;
			var item:LetterItemRenderer = view.nextLetterItemRender;
			this._item = item;
			
			send(temp);
		}
		/**
		 *GM评分服务端的返回 
		 * @param gmVo
		 * 
		 */		
		public function gmBackFromService(gmVo:m_gm_score_toc):void{
			if(gmVo.succ){
				var changeVo:m_letter_state_change_tos = new m_letter_state_change_tos();
				changeVo.letter_id = letterInfo.id;
				changeVo.state = 4;
				changeVo.is_self_send = false;
				
				LetterModule.getInstance().sendLetterStateChange(changeVo);
				
			}
		}
		/**
		 *信件状态改变，服务端的返回 
		 * @param changeVo
		 * 
		 */		
		public function changeBackFromService(changeVo:m_letter_state_change_toc):void{
			if(changeVo.succ){
				letterInfo.state = LetterType.REPLY;
				letterSimpleInfo.state = LetterType.REPLY;
				letterItemRender.data = letterSimpleInfo;
			}
		}
	}
}