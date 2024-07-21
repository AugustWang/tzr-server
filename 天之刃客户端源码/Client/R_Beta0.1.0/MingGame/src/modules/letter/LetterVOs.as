package modules.letter
{
	import com.common.GlobalObjectManager;
	
	import modules.broadcast.views.Tips;
	import modules.letter.view.LetterItemRenderer;
	import modules.letter.view.LetterPage;
	import modules.letter.view.LetterPanel;
	
	import proto.line.m_letter_get_toc;
	import proto.line.p_letter_info;
	import proto.line.p_letter_simple_info;
	
	public class LetterVOs
	{
		public static var ALL:int = 0;
		public static var SYSTEM:int = 1;
		public static var PRIVATE:int = 2;
		public static var SEND:int = 3;
		public static var RECEIVE:int = 4;
		
		private var allLetters:Array = [];
		private var sysLetters:Array = [];
		private var priLetters:Array = [];
		private var sendLetters:Array = [];
		private var recLetters:Array = [];
		
		/**
		 * 标志当前是哪次请求 
		 */		
		private var currentMark:int;
		public function LetterVOs(){}
		
		/**
		 * 首次获取信件列表时服务端分批发下来的数据处理函数，用于整合所有数据，区分不同批次数据
		 * 清除数据等操作。 
		 * @param vo
		 * 
		 */		
		public function appendData(vo:m_letter_get_toc):void{
			if(vo == null)
				return;
			
			if(vo.request_mark > currentMark){
				clear();
				currentMark = vo.request_mark;
			}
			/*是不是过期发送的数据*/
			if(vo.request_mark < currentMark)
				return;
			if(vo != null && vo.letters != null)
			{
				for each(var letter:p_letter_simple_info in vo.letters)
				{
					allLetters.push(letter);
					addTypeLetter(letter);
				}
			}
		}
		
		/**
		 *每收到一封信就把它添加到所有信件跟他实际类型信件（私人，系统...） 
		 * @param vo
		 * 
		 */		
		public function addLetter(vo:p_letter_simple_info):void{
			if(vo == null)
				return;
			
			allLetters.push(vo);
			addTypeLetter(vo);
		}
		/**
		 *删除信件
		 *  
		 * @param letters
		 * 
		 */		
		public function delData(letters:Array):void{
			if(letters != null){
				for each(var letter:p_letter_simple_info in letters){
					delLetter(letter, allLetters);
					delTypeLetter(letter);
				}
			}
		}
		
		private function addTypeLetter(letter:p_letter_simple_info):void{
			if(letter.type == LetterType.SYSTEM)
				sysLetters.push(letter);
			else if(letter.type == LetterType.PRIVATE)
				priLetters.push(letter);
			
			if(isSelfSend(letter)){
				sendLetters.push(letter);
			}else{
				recLetters.push(letter);
			}
		}
		private function delTypeLetter(letter:p_letter_simple_info):void{
			
			if(letter.type == LetterType.SYSTEM){
				delLetter(letter, sysLetters);
			}else if(letter.type == LetterType.PRIVATE){
				delLetter(letter, priLetters);
			}
			
			if(isSelfSend(letter)){
				delLetter(letter, sendLetters);
			}else{
				delLetter(letter, recLetters);}
		}
		
		private function delLetter(letter:p_letter_simple_info, array:Array):Boolean{
			for(var i:int = 0; i< array.length; i++){
				if(array[i].id == letter.id && array[i].sender == letter.sender){
					array.splice(i,1);
					return true;
				}
			}
			
			return false;
		}
		
		private var curr_arr:Array = [];
		public function getTypeLetters(type:int):Array{
			switch(type){
				case ALL:
					allLetters.sortOn("send_time",Array.DESCENDING | Array.NUMERIC);
					if(allLetters.length > 100){
						curr_arr = allLetters.slice(0,100);
						return curr_arr;
					}else{
						return allLetters;
					}
					break;
				case SYSTEM:
					sysLetters.sortOn("send_time",Array.DESCENDING | Array.NUMERIC);
					if(sysLetters.length > 100){
						curr_arr = sysLetters.slice(0,100);
						return curr_arr;
					}else{
						return sysLetters;
					}
					break;
				case PRIVATE:
					priLetters.sortOn("send_time",Array.DESCENDING | Array.NUMERIC);
					if(priLetters.length > 100){
						curr_arr = priLetters.slice(0,100);
						return curr_arr;
					}else{
						return priLetters;
					}
					break;
				case SEND:
					sendLetters.sortOn("send_time",Array.DESCENDING | Array.NUMERIC);
					if(sendLetters.length > 100){
						curr_arr = sendLetters.slice(0,100);
						return curr_arr;
					}else{
						return sendLetters;
					}
					break;
				case RECEIVE:
					recLetters.sortOn("send_time",Array.DESCENDING | Array.NUMERIC);
					if(recLetters.length > 100){
						curr_arr = recLetters.slice(0,100);
						return curr_arr;
					}else{
						return recLetters;
					}
					break;
			}
			
			return null;
			
		}
		/**
		 * 
		 * @param index
		 * @param pre:为真时：说明点击的是上一页，为假时说明点击的是下一页
		 * @param current
		 * @return 
		 * 
		 */		
		public function getLetter(index:int, pre:Boolean, current:p_letter_simple_info,arr:Array,$parent:LetterPanel,$letterPage:LetterPage):p_letter_simple_info{
			var array:Array = arr;
			if(array != null){
				var length:int = array.length;
				if(length <= 1 && LetterPage.currentPageNumber == LetterPage.totalPage){
					Tips.getInstance().addTipsMsg("你当前只有一封信件");
					return null;
				}
				for(var i:int = 0; i < length; i++){
					var item:p_letter_simple_info = array[i] as p_letter_simple_info;
					if(current.id == item.id){
						if(pre){
							if(i >= 1){
								return array[i-1] as p_letter_simple_info;
							}else{
								if(LetterPage.currentPageNumber>1){//说明不是第一页(这步操作会跳到前一页)
									$parent.afterPreOrNextSeal($parent.lettersList,LetterPage.dic[LetterPage.currentPageNumber - 1]);
									LetterPage.content_arr = LetterPage.dic[LetterPage.currentPageNumber - 1];
									$parent.currentItemRender = $parent.lettersList.list.getChildAt(9) as LetterItemRenderer;
									$parent.messageBody.getDetail($parent.currentItemRender,$parent.letterDetail);
									$letterPage.dealTxt(LetterPage.currentPageNumber - 1,"old");
									$letterPage.dealLinkState(LetterPage.currentPageNumber - 2);
									LetterPage.currentIndex = LetterPage.currentPageNumber - 1;
								}else{//说明是第一页
									Tips.getInstance().addTipsMsg("已经是第一封了");
								}
								return null;
							}
						}else{
							if(i <= length - 2){
								return array[i+1] as p_letter_simple_info;
							}else{
								if(LetterPage.currentPageNumber < LetterPage.totalPage){//不是最后一页(这步操作会跳到下一页)
									$parent.afterPreOrNextSeal($parent.lettersList,LetterPage.dic[LetterPage.currentPageNumber + 1]);
									LetterPage.content_arr = LetterPage.dic[LetterPage.currentPageNumber + 1];
									$parent.currentItemRender = $parent.lettersList.list.getChildAt(0) as LetterItemRenderer;
									$parent.messageBody.getDetail($parent.currentItemRender,$parent.letterDetail);
									$letterPage.dealTxt(LetterPage.currentPageNumber-1,"old");
									$letterPage.dealLinkState(LetterPage.currentPageNumber);
									LetterPage.currentIndex = LetterPage.currentPageNumber - 1;
								}else{//已经查最后一页
									Tips.getInstance().addTipsMsg("已经是最后一封");
								}
								return null;
							}
						}
					}
				}
			}
			
			return null;
		}
		
		private function clear():void{
			allLetters.length = 0;
			sysLetters.length = 0;
			priLetters.length = 0;
			sendLetters.length = 0;
			recLetters.length = 0;
		}
		/**
		 *信件是不是自己发的 
		 * @param letter
		 * @return 
		 * 
		 */		
		public static function isSelfSend(letter:*):Boolean{
			var currentRoleName:String = GlobalObjectManager.getInstance().user.base.role_name;
			if(letter is p_letter_simple_info)
				if(letter.sender == currentRoleName)
					return true;
			if(letter is p_letter_info)
				if(letter.sender == currentRoleName)
					return true;
			if(letter is Object)
				if(letter.sender == currentRoleName)
					return true;
			return false;
		}
		
		public static function getTitle(letter:*,str:String = "unopen"):String{
			var result:String;
			if(letter is p_letter_simple_info)
			{
				var temp:p_letter_simple_info = letter as p_letter_simple_info;
				var selfSend:Boolean = isSelfSend(letter);
				if(str != "unopen"){
					if(selfSend){
						result = "<font color='#ffffff'>您发给<font color='#00ff00'>[" + temp.receiver + "]</font>的信件</font>";
					}else if(temp.type == 2||temp.type == 4){
						result = "<font color='#ffffff'>"+temp.title+"</font>"//"系统发给您的信件";
					}else{
						result = "<font color='#ffffff'><font color='#00ff00'>[" + temp.sender + "]</font>" + "发给您的信件</font>";
					}
				}else{
					if(selfSend){
						result = "您发给<font color='#00ff00'>[" + temp.receiver + "]</font>的信件";
					}else if(temp.type == 2||temp.type == 4){
						result = temp.title//"系统发给您的信件";
					}else{
						result = "<font color='#00ff00'>[" + temp.sender + "]</font>" + "发给您的信件";
					}
				}
				
				return result;
			}
			if(letter is p_letter_info)
			{
				var temp2:p_letter_info = letter as p_letter_info;
				selfSend = isSelfSend(letter);
				/*if(selfSend)
				result = "您发送给<font color='#ff0000'>" + temp2.receiver + "</font>的信件";
				else if(isSysSend(letter))
				result = "系统发送给您的信件";
				else{*/
				if(temp2.type == 0 || temp2.type == 3){
					result = "私人信件";
				}else if(temp2.type == 1){
					result = "门派信件";
				}else if(temp2.type == 2){
					result = "系统信件";
				}else if(temp2.type == 4){
					result = "GM信件";
				}
				//				}
				
				return result;
			}
			
			return result;
		}
		
		public static function getSimple(letter:p_letter_info):p_letter_simple_info
		{
			if(letter == null)
				return null;
			
			var result:p_letter_simple_info = new p_letter_simple_info();
			result.id = letter.id;
			result.sender = letter.sender;
			result.receiver = letter.receiver;
			result.state = letter.state;
			result.type = letter.type;
			result.table = letter.table;
			
			return result;
		}
		
		/*public static function isSysSend(letter:*):Boolean
		{
		return letter.sender == null;
		}*/
	}
}