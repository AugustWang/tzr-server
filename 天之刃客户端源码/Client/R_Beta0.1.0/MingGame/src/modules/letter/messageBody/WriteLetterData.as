package modules.letter.messageBody
{
	import com.common.GlobalObjectManager;
	
	import modules.broadcast.views.Tips;
	import modules.letter.LetterModule;
	import modules.letter.view.LetterPanel;
	import modules.letter.view.detail.LetterWrite;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_letter_p2p_send_tos;
	import proto.line.m_letter_send_toc;

	public class WriteLetterData
	{
		private var view:LetterWrite;
		private var accessory:BaseItemVO;
		public function WriteLetterData()
		{
			super();
		}
		
		public function getDataFromService(view:LetterPanel, message:Object):void
		{
			var vo:m_letter_send_toc = message as m_letter_send_toc;
			if(vo == null)return;
			if(vo.succ){
				if(vo.letter.sender == GlobalObjectManager.getInstance().user.base.role_name){
					Tips.getInstance().addTipsMsg("信件发送成功");
				}
				if(this.view != null)
				{
					this.view.reset();
					this.view.closeWindow();
				}
				if(view != null)
					view.addLetter(vo.letter);
				
				if(accessory != null)
					PackManager.getInstance().updateGoods(accessory.bagid, accessory.position, null);
				
				accessory = null;
				this.view = null;
			}else{
				Tips.getInstance().addTipsMsg(vo.reason);
			}
		}
		
		public function writeLetter(vo:m_letter_p2p_send_tos, view:LetterWrite, item:BaseItemVO):void
		{
			this.view = view;
			this.accessory = item;
			LetterModule.getInstance().sendLetter(vo,this);
		}
	}
}