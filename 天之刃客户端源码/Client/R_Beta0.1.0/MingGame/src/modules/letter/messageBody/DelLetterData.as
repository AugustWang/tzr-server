package modules.letter.messageBody
{
	import modules.broadcast.views.Tips;
	import modules.letter.LetterModule;
	import modules.letter.LetterVOs;
	import modules.letter.view.LetterPanel;
	import modules.letter.view.detail.LetterDetail;
	
	import proto.line.m_letter_delete_toc;
	import proto.line.m_letter_delete_tos;
	import proto.line.p_letter_delete;
	import proto.line.p_letter_simple_info;

	public class DelLetterData
	{
		private var _letters:Array;
		private var _view:LetterDetail;
		public function DelLetterData()
		{
			super();
		}
		
		public function getDelBack(view:LetterPanel, message:Object):void{
			var vo:m_letter_delete_toc = message as m_letter_delete_toc;
			if(vo == null)return;
			if(vo.succ == false)
			{
				if(vo.no_del != null && vo.no_del.length >0)
				{
					var realDel:Array = getRealDel(vo.no_del, _letters);
					view.delLetters(realDel);
				}
				_letters = null;
				return;
			}
			
			Tips.getInstance().addTipsMsg("信件删除成功");
			view.delLetters(_letters);
			_letters = null;
			
			/*信件详情中的删除操作*/
			if(_view != null && _view.parent != null)
			{
				_view.closeWindow();
			}
			
			_view = null;
		
		}
		
		/**
		 *  
		 * @param letters
		 * @param view
		 */		
		public function delLetter(letters:Array, view:LetterDetail = null):void{
			this._view = view;
			if(letters != null && letters.length > 0){
				_letters = letters;
				var arr:Array = [];
				for each(var simpleVo:p_letter_simple_info in letters){
					var delVo:p_letter_delete = new p_letter_delete();
					delVo.letter_id = simpleVo.id;
					delVo.table = simpleVo.table;
					delVo.is_self_send = LetterVOs.isSelfSend(simpleVo);
					arr.push(delVo);
				}
				var vo:m_letter_delete_tos = new m_letter_delete_tos();
				vo.letters = arr;
				
				LetterModule.getInstance().sendDelLetter(vo,this);
			}
		}
		
		private function callback(item:*, index:int, array:Array):p_letter_delete{
			var result:p_letter_delete = new p_letter_delete();
			
			if(item != null){
				result.is_self_send = LetterVOs.isSelfSend(item);
				result.letter_id = item.id;
				return result;
			}
			
			return null;
		}
		
		private function getRealDel(noDel:Array, items:Array):Array
		{
			var result:Array = new Array();
			
			for each (var letter:p_letter_simple_info in items)
			{
				var realDel:Boolean = true;
				for(var i:int = 0; i< noDel.length; i++)
				{
					if(letter.id == noDel[i]){
						realDel = false;
						break;
					}
				}
				
				if(realDel)
					result.push(letter);
			}
			
			return result;
		}
	}
}