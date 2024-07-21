package modules.letter.messageBody
{
	import modules.letter.LetterModule;
	import modules.letter.view.LetterItemRenderer;
	import modules.letter.view.LetterPanel;
	import modules.letter.view.detail.LetterDetail;
	
	import proto.common.p_goods;
	import proto.line.m_letter_accept_goods_toc;
	import proto.line.m_letter_accept_goods_tos;
	import proto.line.p_letter_simple_info;

	public class GetAccessoryData
	{
		private var _view:LetterDetail;
		public function GetAccessoryData()
		{
			super();
		}
		public function getAccessoryBack(view:LetterPanel, message:Object):void{
			var vo:m_letter_accept_goods_toc = message as m_letter_accept_goods_toc;
			if(vo.succ == false){
				_view.unlockAccessory(false);
				return;
			}
			var goods:p_goods = vo.goods_take[0] as p_goods;
			LetterModule.getInstance().sendToPackage(goods);
			
			_view.unlockAccessory(true);
			
			changeState(view);
			
			view = null;
		}
		
		private function changeState(view:LetterPanel):void{
			var render:LetterItemRenderer =view.currentItemRender/*view.getCurrentOpenLetterRender()*/ ;
			
			if(render != null){
				var data:p_letter_simple_info = render.data as p_letter_simple_info;
				
				data.is_have_goods = false;
				render.data = data;
			}
		}
		/**
		 *领取附件向服务端发送请求 
		 * @param good
		 * @param pacId
		 * @param position
		 * @param letter
		 * 
		 */		
		public function getAccessory(good:p_goods, pacId:int, position:int, letter:LetterDetail):void{
			if(letter == null || letter.param == null)
				return;
			good.bagid = pacId;
			good.bagposition = position;
			
			var vo:m_letter_accept_goods_tos = new m_letter_accept_goods_tos();
			vo.letter_id = letter.param.id;
			vo.table = letter.param.table;
//			vo.accept_goods = [good];
			
			LetterModule.getInstance().sendGetAccessory(vo,this);
			
			letter.lockAccessory();
			
			_view = letter;
		}
	}
}