package modules.letter.view.detail
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.educate.EducateModule;
	import modules.gm.GMModule;
	import modules.letter.LetterModule;
	import modules.letter.LetterType;
	import modules.letter.LetterVOs;
	import modules.letter.messageBody.DelLetterData;
	import modules.letter.messageBody.GetAccessoryData;
	import modules.letter.messageBody.LetterDetailData;
	import modules.letter.view.LetterItemRenderer;
	import modules.mypackage.managers.PackManager;
	
	import proto.common.p_goods;
	import proto.line.m_gm_score_tos;
	import proto.line.p_letter_info;
	import proto.line.p_letter_simple_info;
	
	/**
	 * 信件详情面版
	 * @author
	 * 
	 */	
	public class LetterDetail extends BaseLetterDetail
	{
		private var tipTxt:TextField;
		private var timeTxt:TextField;
		private var preTxt:TextField;//上一页
		private var nextTxt:TextField;//下一页
		private var textformate:TextFormat = new TextFormat(null,12,0xffcc00,null,null,true);
		private var _data:p_letter_info;
		public var simpleParam:p_letter_simple_info;
		private var verySatisfyBtn:Button;//非常满意
		private var satisfyBtn:Button;//满意
		private var unSatisfyBtn:Button;//不满意
		private var delBtn:Button;
		private var replyBtn:Button;
		public static const VERYSATISFY:int = 1;//非常满意
		public static const SATISFY:int = 2;//满意
		public static const UNSATISFY:int = 3;//不满意
		public function LetterDetail()
		{
			super("");
			
			addImageTitle("title_letterDetail");
			//addContentBG(4);
			
			//附件
			accessory = new AccessoryView(AccessoryView.LETTER_DETAIL);
			addChild(accessory);
			accessory.setClickFun(clickHandler,"getAttachBtn");//领取
			
			//上一页，下一页
			preTxt = ComponentUtil.createTextField("",228,290,textformate,45,18,this);
			preTxt.htmlText = "<a href = 'event:pre'>上一封</a>";
			preTxt.name = "preTxt";
			preTxt.mouseEnabled = true;
			preTxt.addEventListener(TextEvent.LINK,pageHandler);
			preTxt.addEventListener(MouseEvent.MOUSE_OVER,onOverChangeColorHandler);
			nextTxt = ComponentUtil.createTextField("",preTxt.x + preTxt.width,preTxt.y,textformate,45,18,this);
			nextTxt.htmlText = "<a href = 'event:next'>下一封</a>";
			nextTxt.name = "nextTxt";
			nextTxt.mouseEnabled = true;
			nextTxt.addEventListener(TextEvent.LINK,pageHandler);
			nextTxt.addEventListener(MouseEvent.MOUSE_OVER,onOverChangeColorHandler);
			tipTxt = ComponentUtil.createTextField("如收到欺诈信息，欢迎举报。",this.contentBackUI.x,this.contentBackUI.y + this.contentBackUI.height + 10,null/*new TextFormat("Tahoma",12,0xffcc00)*/,170,30,this);
			tipTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			tipTxt.htmlText = "<font color='#ffcc00'>如收到欺诈信息，欢迎<font color='#00ff00'><u><a href='event:tipTxt'>举报</a></u>。</font></font>"
			tipTxt.mouseEnabled = true;
			tipTxt.addEventListener(TextEvent.LINK,onTextLinkHandler);
			timeTxt = ComponentUtil.createTextField("",this.type_txt.x + this.type_txt.width,this.type_txt.y,new TextFormat("Tahoma",12,0xffcc00),180,30,this);
			timeTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			timeTxt.mouseEnabled = false;
			
			
			//评分的几个按钮
			verySatisfyBtn = ComponentUtil.createButton("非常满意",this.contentBackUI.x,this.contentBackUI.y + this.contentBackUI.height +5,60,25,this);
			verySatisfyBtn.name = "verySatisfyBtn";
			verySatisfyBtn.addEventListener(MouseEvent.CLICK,onRatingBtnHandler);
			
			satisfyBtn = ComponentUtil.createButton("满意",this.verySatisfyBtn.x + verySatisfyBtn.width,this.contentBackUI.y + this.contentBackUI.height +5,60,25,this);
			satisfyBtn.name = "satisfyBtn";
			satisfyBtn.addEventListener(MouseEvent.CLICK,onRatingBtnHandler);
			
			unSatisfyBtn = ComponentUtil.createButton("不满意",this.satisfyBtn.x + satisfyBtn.width,this.contentBackUI.y + this.contentBackUI.height +5,60,25,this);
			unSatisfyBtn.name = "unSatisfyBtn";
			unSatisfyBtn.addEventListener(MouseEvent.CLICK,onRatingBtnHandler);
			verySatisfyBtn.visible = false;
			satisfyBtn.visible = false;
			unSatisfyBtn.visible = false;
			
			
			//删除和回复两个按钮
			delBtn = ComponentUtil.createButton("删除",unSatisfyBtn.x + unSatisfyBtn.width,unSatisfyBtn.y,60,25,this);
			delBtn.addEventListener(MouseEvent.CLICK,delHandler);
			replyBtn = ComponentUtil.createButton("回复",delBtn.x + delBtn.width,delBtn.y,60,25,this);
			replyBtn.addEventListener(MouseEvent.CLICK,backHandler);
		}
		
		private function onTextLinkHandler(evt:TextEvent):void{
			if(evt.text == "tipTxt"){
				GMModule.getInstance().openLetterWin();
			}
		}
		/**
		 *上一页或下一页颜色的改变 
		 * @param evt
		 * 
		 */		
		private function onOverChangeColorHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "preTxt"){
				preTxt.textColor = 0x00ff00;
				preTxt.addEventListener(MouseEvent.MOUSE_OUT,onOutChangeColorHandler);
			}else if(evt.currentTarget.name == "nextTxt"){
				nextTxt.textColor = 0x00ff00;
				nextTxt.addEventListener(MouseEvent.MOUSE_OUT,onOutChangeColorHandler);
			}
			
		}
		
		private function onOutChangeColorHandler(evt:MouseEvent):void{
			if(evt.currentTarget.name == "preTxt"){
				preTxt.textColor = 0xffcc00;
			}else if(evt.currentTarget.name == "nextTxt"){
				nextTxt.textColor = 0xffcc00;
			}
		}
		/**
		 *如果发送者，那么需要隐藏领取按钮 
		 * 
		 */		
		public function visibleGetAttachBtn(vo:p_letter_info):void{
			if(accessory){
				if(vo.sender == GlobalObjectManager.getInstance().user.base.role_name){
					accessory.getAttachBtn.visible = false;
				}else{
					accessory.getAttachBtn.visible = true;
				}
			}
		}
		/**
		 *获取itemRender的引用 
		 */		
		private var _nextLetterItemRender:LetterItemRenderer;
		public function set nextLetterItemRender(value:LetterItemRenderer ):void{
			this._nextLetterItemRender = value;
		}
		public function get nextLetterItemRender():LetterItemRenderer{
			return this._nextLetterItemRender;
		}
		
		/**
		 *点击评价按钮 
		 * @param evt
		 * 
		 */		
		private function onRatingBtnHandler(evt:MouseEvent):void{
			var index:int;
			if(evt.currentTarget.name == "verySatisfyBtn"){
				index = 1;
			}else if(evt.currentTarget.name == "satisfyBtn"){
				index = 2;
			}else if(evt.currentTarget.name == "unSatisfyBtn"){
				index = 3;
			}
			
			var gmVo:m_gm_score_tos = new m_gm_score_tos();
			gmVo.id = this._data.id;
			gmVo.fraction = index;
			
			LetterModule.getInstance().sendGmScore(gmVo);
			
			
			verySatisfyBtn.visible = false;
			satisfyBtn.visible = false;
			unSatisfyBtn.visible = false;
		}
		
		/**
		 *点击领取按钮
		 * @param evt
		 * 
		 */		
		private function clickHandler(evt:MouseEvent):void{
			if(LetterVOs.isSelfSend(_data)){//判断是否是自己已发出去的
				return;
			}
			var goods:p_goods = accessory.getDetailData();
			if(goods != null){
				var full:Boolean = PackManager.getInstance().isBagFull();
				//  trace(full+"bag is full?----------------**********************");
				if(!full){
					var body:GetAccessoryData = new GetAccessoryData();
					body.getAccessory(goods, 0,0, this);
				}else{
					Alert.show("背包空间不足，无法提取附件","",null,null,"确定","取消",null,false);
				}
			}else{
				return;
			}
		}
		
		/**
		 *文本上一页，下一页的点击事件 
		 * @param evt
		 * 
		 */		
		private function pageHandler(evt:TextEvent):void{
			var txt:String = evt.text;
			if(txt == "pre"){
				preHandler();
			}else{
				nextHandler();
			}
		}
		
		//上一页
		private function preHandler(evt:MouseEvent=null):void{
			if(LetterModule.getInstance().panel){
				LetterModule.getInstance().panel.messageBody.getPriDetail(this);
			}
		}
		
		//下一页
		private function nextHandler(evt:MouseEvent=null):void{
			if(LetterModule.getInstance().panel){
				LetterModule.getInstance().panel.messageBody.getNextDetail(this);
			}
		}
		/**
		 *是否要隐藏上一页和下一页 
		 * @param index
		 * 
		 */		
		public function preAndNextPage(vo:LetterVOs,index:int):void{
			var data_array:Array = vo.getTypeLetters(index);
			if(data_array.length <=1){
				preTxt.visible = false;
				nextTxt.visible = false;
			}else{
				preTxt.visible = true;
				nextTxt.visible = true;
			}
		}
		
		/**
		 *单封信件的信息 
		 * @param value
		 * 
		 */		
		public function set param(value:p_letter_info):void{
			this._data = value;
			
			this.invalidateDisplayList();
		}
		
		public function get param():p_letter_info{
			return this._data;
		}
		
		/**
		 *获取附件的信息 
		 * @return 
		 * 
		 */		
		public function getAccessory():p_goods{
			return accessory.getAccessory();
		}
		
		
		override public function lockAccessory():void{
			accessory.mouseEnabled = false;
			accessory.mouseChildren = false;
		}
		
		override public function unlockAccessory(bool:Boolean):void{
			accessory.mouseEnabled = true;
			accessory.mouseChildren = true;
			
			accessory.unlock(bool);
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w, h);
			
			if(_data != null)
				render();
		}
		
		//删除信件
		private function delHandler(evt:MouseEvent):void{
			if(getAccessory()){
				if(this._data.sender != GlobalObjectManager.getInstance().user.base.role_name){
					Alert.show("您有附件未提取，确定要删除吗？","提示",suerDelHandler);
				}else{
					suerDelHandler();
				}
			}else{
				suerDelHandler();
			}
		}
		
		private function suerDelHandler():void{
			var body:DelLetterData = new DelLetterData();
			if(simpleParam != null){
				body.delLetter([simpleParam], this);
			}else{
				var p:p_letter_simple_info = LetterVOs.getSimple(param);
				body.delLetter([p],this);
			}
		}
		/**
		 * 回复特定人 
		 * @param evt
		 * 
		 */		
		private function backHandler(evt:MouseEvent):void{
			if(evt.currentTarget.label == "回复"){
				WindowManager.getInstance().removeAllWindow();
				if(this._data.sender == "GM"){
					GMModule.getInstance().openLetterWin();
				}else{
					LetterModule.getInstance().openLetter(_data.sender);
				}
			}else{//”Label =返回“
				WindowManager.getInstance().removeWindow(this);
			}

		}
		
		/**
		 *信件的所有内容：收件人，类型，时间，内容 
		 * 
		 */
		private function render():void{
			
			if(simpleParam){
				if(simpleParam.is_have_goods){
					accessory.visible = true;
				}else{
					accessory.visible = false;
				}
			}
			
			//如果是GM信件，判断该信件是否已经回复过
			if(this._data.sender == "GM" && this._data.state!=LetterType.REPLY){
				verySatisfyBtn.visible = true;
				satisfyBtn.visible = true;
				unSatisfyBtn.visible = true;
				replyBtn.enabled = true;
			}else{
				verySatisfyBtn.visible = false;
				satisfyBtn.visible = false;
				unSatisfyBtn.visible = false;
			}
			
			var selfSend:Boolean = LetterVOs.isSelfSend(_data);
			if(this._data.type == 1){//（门派）
				sender_txt.htmlText = "<font color= '#ffcc00'>"+this._data.sender+"</font>";
				sender_desc_txt.htmlText = "<font color='#AFE1EC'>发件人：</font>";
				replyBtn.enabled = true;
				replyBtn.label = "回复";
			}else if(this._data.type == 2){//系统信件
				sender_txt.htmlText = "<font color= '#ffcc00'>系统</font>";
				sender_desc_txt.htmlText = "<font color='#AFE1EC'>发件人：</font>";
				replyBtn.label = "返回";
				
			}else if(this._data.type == 4){//GM信件
				sender_txt.htmlText = "<font color= '#ffcc00'>GM</font>";
				sender_desc_txt.htmlText = "<font color='#AFE1EC'>发件人：</font>";
				replyBtn.label = "返回";
			}else if(selfSend){//自己发的
				sender_txt.htmlText = "<font color= '#ffcc00'>" + _data.receiver + "</font>";
				sender_desc_txt.htmlText = "<font color='#AFE1EC'>收件人：</font>";
				replyBtn.label = "返回";
				
			}else{//私人信件
				sender_txt.htmlText = "<font color= '#ffcc00'>" + _data.sender + "</font>";
				sender_desc_txt.htmlText = "<font color='#AFE1EC'>发件人：</font>";
				replyBtn.enabled = true;
				replyBtn.label = "回复";
			}
				
			type_txt.htmlText = "<font color= '#ff0000' size='12'>" + LetterVOs.getTitle(_data) + "</font>";
			timeTxt.htmlText = "<font color='#AFE1EC' size='12'>时间：</font>"+LetterItemRenderer.parseDate(_data.send_time);
			
			content.htmlText = "<font color='#ffffff'>"+_data.letter_content+"</font>";
			content.editable = false;
			content.addEventListener(TextEvent.LINK,onLinkClickHandler);
			
			accessory.setData(_data.goods_list,selfSend);//给附件框赋值
		}
		
		private function onLinkClickHandler(evt:TextEvent):void{
			if(evt.text == "teacher"){
				EducateModule.getInstance().openCStudentPanel();//推荐徒弟
			}else if(evt.text.indexOf("N|") != -1){
				var results:Array = evt.text.split("|");
				PathUtil.findNPC(results[1]);	
			}
		}
	}
}