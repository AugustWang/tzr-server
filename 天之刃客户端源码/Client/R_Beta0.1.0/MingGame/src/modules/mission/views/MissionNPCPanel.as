package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.gs.TweenMax;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mission.MissionConstant;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionModule;
	import modules.mission.vo.MissionPropRewardVO;
	import modules.mission.vo.MissionRewardVO;
	import modules.mission.vo.MissionVO;
	import modules.npc.NPCConstant;
	import modules.npc.NPCDataManager;
	import modules.npc.views.NPCLinkItem;
	import modules.npc.vo.NpcLinkVO;
	import modules.playerGuide.GuideConstant;
	import modules.playerGuide.PlayerGuideModule;
	import modules.scene.SceneDataManager;
	
	import proto.line.m_mission_do_tos;

	public class MissionNPCPanel extends BasePanel {
		public function MissionNPCPanel(key:String=null) {
			super();
			initView();
		}


		private var _canvas:Canvas;
		private var _propRewardContainer:Sprite;
		private var _rewardText:TextField;
		private var _rewardTitleText:TextField;
		
		private var _contentText:TextField;
		private var _button:Button;
		private var _vo:MissionVO;
		private var _npcID:int;
		private var _npcName:String;
		private var _line:Bitmap;
		private var _dialoguesContainer:Sprite;

		private var _dialoguesType:int=0;

		private var _do_int_list_1:Array;
		private var _do_int_list_2:Array;
		private var _doTimesText:TextField;

		static private const BUTTON_TYPE_NEXT_DIALOGUE:int=1;
		static private const BUTTON_TYPE_ACCEPT:int=2;
		static private const BUTTON_TYPE_DO:int=3;
		static private const BUTTON_TYPE_FINISH:int=4;
		
		static private const REWAWRD_TITLE:String = '<font color="#ffff00">任务奖励：</font>';
		
		private function initView():void {
			this.width=293;
			this.height=401;
			this.y = 90;
			addContentBG(30);
			
			var bitmap:Skin = Style.getSkin("packTileBg",GameConfig.T1_VIEWUI,new Rectangle(60,60,172,177));
			bitmap.setSize(273,316);
			bitmap.x = 11;
			bitmap.y = 10;
			addChild(bitmap);

			var tf:TextFormat=new TextFormat();
			tf.leading=4;
			tf.color=0xffffff;

			this._canvas=new Canvas();
			this._canvas.x=13;
			this._canvas.y=15;
			this._canvas.width=267;
			this._canvas.height=308;
			this._canvas.horizontalScrollPolicy=ScrollPolicy.OFF;
			this._canvas.verticalScrollPolicy=ScrollPolicy.AUTO;

			this.addChild(this._canvas);
			
			this._contentText=ComponentUtil.createTextField('',12, 10, tf, 240, 70, this._canvas);
			this._contentText.filters=[Style.BLACK_FILTER];
			this._contentText.multiline=true;
			this._contentText.wordWrap=true;
			
			this._dialoguesContainer=new Sprite();
			this._dialoguesContainer.x= 12;
			this._dialoguesContainer.y = 3;//会动态变化
			this._canvas.addChild(this._dialoguesContainer); 
			
			this._line=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			_line.width = 280;
			_line.x = 0;
			this._canvas.addChild(_line);

			this._propRewardContainer=new Sprite();
			this._propRewardContainer.x = 12;
			this._propRewardContainer.y = 3;//会动态变化
			this._canvas.addChild(this._propRewardContainer);

			this._rewardTitleText=ComponentUtil.createTextField('', 12, 0, tf, 230, 20, this._canvas);
			this._rewardTitleText.htmlText = MissionNPCPanel.REWAWRD_TITLE;
			this._rewardTitleText.filters=[Style.BLACK_FILTER];
			this._rewardTitleText.wordWrap = true;
			this._rewardTitleText.multiline = true;
			
			this._rewardText=ComponentUtil.createTextField('', 12, 0, tf, 230, 80, this._canvas);
			this._rewardText.filters=[Style.BLACK_FILTER];

			this._button=ComponentUtil.createButton("", this.width - 95, this.height - 70, 80, 25, this);
			this._button.addEventListener(MouseEvent.CLICK, this.onButtonClick);
			tf.align = TextAlign.RIGHT;
			this._doTimesText = ComponentUtil.createTextField('', 
				this.width - 135, 
				this._button.y - 25, 
				tf, 100, 20, this);
			this._doTimesText.filters = [Style.BLACK_FILTER];
		}

		private var _dialoguesItemType:int=0;

		/**
		 * 改变面板各种状态数据
		 */
		private function changePannelStatus():void {
			switch (this._dialoguesType) {
				case MissionConstant.NPC_DIALOGUES_TYPE_QUESTION:
				case MissionConstant.NPC_DIALOGUES_TYPE_CHOOSE_NPC:
					this.clearDialoguesContainer();
					break;

				default:
					break;
			}

			var dialogues:*=this._vo.npcDialogues[this._npcID][this._dialogueIndex];
			var dialoguesType:int=MissionConstant.NPC_DIALOGUES_TYPE_NORMAL;
			if (dialogues is Array) {
				dialoguesType=dialogues[MissionConstant.NPC_DIALOGUES_TYPE_INDEX];
				this._dialoguesType=dialoguesType;
			}

			if (this._dialogueIndex == this._dialoguesLen) {
				this.doMission();
				return;
			}
			
			this._do_int_list_1=null;
			this._do_int_list_2=null;

			//判断下是否是特殊类型的对话数据
			var content:String='';
			switch (dialoguesType) {
				case MissionConstant.NPC_DIALOGUES_TYPE_QUESTION:
					var answer:int=dialogues[MissionConstant.NPC_DIALOGUES_ANSWER_INDEX];
					var questions:Array=dialogues[MissionConstant.NPC_DIALOGUES_QUESTIONS_INDEX];
					this.renderQuestions(answer, questions);
					content=dialogues[MissionConstant.NPC_DIALOGUES_CONTENT_INDEX];
					this._button.visible = false;;
					this._dialoguesItemType;
					break;

				case MissionConstant.NPC_DIALOGUES_TYPE_CHOOSE_NPC:
					var npcs:Array=dialogues[MissionConstant.NPC_DIALOGUES_CHOOSE_NPC_LIST_INDEX];
					this.renderChooseNPCS(npcs);
					this._button.visible = false;;
					content=dialogues[MissionConstant.NPC_DIALOGUES_CONTENT_INDEX];
					break;
				
				default:
					content=dialogues;
					this._button.enabled=true;
					break;
			}

			var type:int;
			if (this._dialogueIndex + 1 == this._dialoguesLen) {
				if (this._vo.currentStatus == MissionConstant.STATUS_ACCEPT) {
					type=MissionNPCPanel.BUTTON_TYPE_ACCEPT;
					this._button.label='接受任务';
					//this.title=this._vo.name;
				} else if (this._vo.currentStatus == MissionConstant.STATUS_NEXT) {
					type=MissionNPCPanel.BUTTON_TYPE_DO;
					this._button.label='继续';
					//this.title=this._vo.name;
				} else {
					type=MissionNPCPanel.BUTTON_TYPE_FINISH;
					this._button.label='完成任务';
					//this.title=this._vo.name;
				}
			} else {
				this._button.label='继续对话';
				type=MissionNPCPanel.BUTTON_TYPE_NEXT_DIALOGUE;
			}
			//this.title=this._vo.name + '（' + (this._dialogueIndex + 1) + '/' + this._dialoguesLen + '）';
			
			content = content.replace(GameConfig.S_REG_EXP, GameConfig.SUO_JIN_STR);
			content = content.replace(GameConfig.N_REG_EXP, GameConfig.N_STR);
			
			this._contentText.htmlText=this._npcName+'：'+GameConfig.N_STR+GameConfig.SUO_JIN_STR+content;
			this._contentText.height = this._contentText.textHeight+20;
			this._dialogueIndex++;
			this._button.data=type;
			this.updateObjectPos();
			
			/**
			 * 处理不同模型差异
			 */
			switch(this._vo.model){
				case MissionConstant.MODEL_6:
					if(this._vo.currentModelStatus == 1){
						this._button.visible = false;
					}
					break;
				case MissionConstant.MODEL_12:
					if(this._vo.currentModelStatus == 1){
						this._button.visible = false;
					}
					break;
			}
			
		}

		/**
		 * 当前面板触发的NPCID
		 */
		public function set npcID(id:int):void {
			var npcObj:Object=NPCDataManager.getInstance().getNpcInfo(id);
			this._npcName = npcObj.name;
			this._npcID=id;
		}

		/**
		 * 设置任务VO
		 */
		public function set vo(missionVO:MissionVO):void {
			this._vo=missionVO;
		}

		/**
		 * 对话索引-当前值
		 */
		private var _dialogueIndex:int=0;
		private var _dialoguesLen:int=0;

		/**
		 * 道具奖励被点击时
		 */
		private var _selectedPropReward:MissionPropRewardVO;

		/**
		 * 当道具被点击时
		 */
		private function onPropRewardItemClick(e:MouseEvent):void {
			if (!this.needSelectProp()) {
				return;
			}
			var propRewardItem:MissionPropRewardItem=(e.target as MissionPropRewardItem);
			this._selectedPropReward=propRewardItem.data as MissionPropRewardVO;
			var propRewardContainerNumChildren:int=this._propRewardContainer.numChildren;
			for (var _childrenIndex:int=0; _childrenIndex < propRewardContainerNumChildren; _childrenIndex++) {
				var item:DisplayObject=_propRewardContainer.getChildAt(_childrenIndex);
				item.filters=[];
			}
			propRewardItem.filters=[Style.YELLOW_FILTER];
		}

		/**
		 * 决断是否需要选择奖励
		 */
		private function needSelectProp():Boolean {
			
			if(!this._vo.rewardData.prop_reward || this._vo.rewardData.prop_reward.length == 0){
				return false;
			}
			var propLength:int = this._vo.rewardData.prop_reward.length;
			
			var configNeedChoose:Boolean = false;
			if(MissionRewardVO.PROP_REWARD_FORMULA_CHOOSE_ONE == this._vo.rewardData.prop_reward_formula){
				configNeedChoose = true;
			}
			
			var currentModelStatus:int = this._vo.currentModelStatus;
			var maxModelStatus:int = this._vo.maxModelStatus;
			
			switch(this._vo.model){
				case MissionConstant.MODEL_9:
					if(this._vo.succTimes+1 == this._vo.maxDotimes){
						if(this._vo.currentModelStatus == MissionConstant.SHOU_BIAN_STATUS_SUCC){
							return configNeedChoose;	
						}
					}
					break;
				
				default:
					if(maxModelStatus == currentModelStatus){
						if(propLength > 1){
							return configNeedChoose;
						}else{
							this._selectedPropReward=this._vo.rewardData.prop_reward[0];
							return false;
						}
					}		
					break;
			}
			return false;
		}

		/**
		 * 底部按钮点击时触发
		 */
		private function onButtonClick(e:MouseEvent):void {
			this.changePannelStatus();
		}

		override protected function closeHandler(event:CloseEvent = null):void {
			var roleLevel:int = GlobalObjectManager.getInstance().user.attr.level;
			if( roleLevel<=15 ){
				//15级以下的自动接受任务
				changePannelStatus();
			}else{
				closeWindow();	
			}
			
		}

		/**
		 * 打开窗口
		 */
		override public function open():void {
			this.visible = true;
			if(MissionModule.getInstance().checkDoingAuto(this._vo.id) == true){
				return;
			}
			this.clear();
			this.renderInit();
			this.render();
			if (!WindowManager.getInstance().isPopUp(this)) {
				y = (GlobalObjectManager.GAME_HEIGHT - height >> 1)-30;
				x = (GlobalObjectManager.GAME_WIDTH >> 1) - width - 30;
				WindowManager.getInstance().openDistanceWindow(this);
			}
			Dispatch.dispatch(GuideConstant.OPEN_NPC_PANEL);
		}

		/**
		 * 关闭窗口时调用
		 */
		private function close():void {
			this.clear();
			this.closeWindow();
		}

		override public function closeWindow( save:Boolean=false ):void {
			super.closeWindow( save );
			Dispatch.dispatch( GuideConstant.CLOSE_NPC_PANEL );
		}

		/**
		 * 清理界面
		 */
		private function clear():void {
			_contentText.htmlText="";
			while (_propRewardContainer.numChildren > 0) {
				var item:DisplayObject=_propRewardContainer.removeChildAt(0);
				item.removeEventListener(MouseEvent.CLICK, onPropRewardItemClick);
			}

			for each(var border:Sprite in this._tipsBorderObj){
				if(border){
					border.visible = false;
				}
			}
			
			this._dialogueIndex=0;
			this._dialoguesLen=0;
			this._button.data=null;
			this._selectedPropReward=null;
			this._line.visible=false;
			this._propRewardContainer.visible=false;
			this._button.visible=false;
		}

		/**
		 * 渲染开始时 还原被clear()隐藏掉的一些界面元素
		 */
		private function renderInit():void {
			this._line.visible=true;
			this._propRewardContainer.visible=true;
			this._button.visible=true;
		}

		/**
		 * 界面渲染
		 */
		public function render():void {
			if (!this._npcID || !this._vo) {
				return;
			}

			this._dialoguesLen=this._vo.npcDialogues[this._npcID].length;

			var _rewardHTML:String='<font color="#ffffff">';
			_rewardHTML+=MissionDataManager.getInstance().wrapperSilver('银子', this._vo.rewardData.silver);
			_rewardHTML+=MissionDataManager.getInstance().wrapperSilver('绑定银子', this._vo.rewardData.silver_bind);
			_rewardHTML+=MissionDataManager.getInstance().wrapperInt('经验', this._vo.rewardData.exp);
			_rewardHTML+=MissionDataManager.getInstance().wrapperInt('声望值', this._vo.rewardData.prestige);

			switch (this._vo.rewardData.attr_reward_formula) {
				case MissionRewardVO.ATTR_REWARD_FORMULA_WU_XING:
					_rewardHTML+='获得五行属性\n';
					break;
			}

			_rewardHTML+='</font>';
			this._rewardText.htmlText=_rewardHTML;


			if (this._vo.rewardData.prop_reward && this._vo.rewardData.prop_reward.length > 0) {
				this._propRewardContainer.visible = true;
				for each (var propRewardVO:MissionPropRewardVO in this._vo.rewardData.prop_reward) {
					var missionPropRewardItem:MissionPropRewardItem=new MissionPropRewardItem();
					missionPropRewardItem.data=propRewardVO;
					missionPropRewardItem.addEventListener(MouseEvent.CLICK, this.onPropRewardItemClick);
					this._propRewardContainer.addChild(missionPropRewardItem);
				}
				LayoutUtil.layoutHorizontal(this._propRewardContainer, 5);
			}else{
				this._propRewardContainer.visible = false;
			}
			
			if(this.needSelectProp() == true){
				this._rewardTitleText.htmlText= MissionNPCPanel.REWAWRD_TITLE+'<font color="#ffffff">（选择一项奖励）</font>';
			}else{
				this._rewardTitleText.htmlText= MissionNPCPanel.REWAWRD_TITLE;
			}
			
			this.changePannelStatus();
			
			if(this._vo.maxDotimes > 1 && this._vo.currentModelStatus == MissionConstant.FIRST_STATUS) {
				this._doTimesText.htmlText = '<font color="#ffffff">第 '+(this._vo.commitTimes+1)+' 次领取任务</font>';
			}else{
				this._doTimesText.htmlText = '';
			}
		}

		/**
		 * 重新设置一些对象的坐标
		 */
		private function updateObjectPos():void {
			
			if (this._dialoguesContainer.visible == true) {
				this._dialoguesContainer.y = this._contentText.y + this._contentText.textHeight + 10;
				this._line.y = this._dialoguesContainer.y + this._dialoguesContainer.height + 10;
			}else{
				this._line.y = this._contentText.y + this._contentText.textHeight + 10;
			} 
			
			this._rewardTitleText.y = this._line.y + 5;
			
			if(this._propRewardContainer.visible == true){
				this._propRewardContainer.y=this._rewardTitleText.y + this._rewardTitleText.textHeight + 7;
				this._rewardText.y=this._propRewardContainer.y + this._propRewardContainer.height + 3;
			}else{
				this._rewardText.y=this._rewardTitleText.y + this._rewardTitleText.textHeight + 3;
			}
		}

		/**
		 * 渲染回答问题的链接
		 */
		private function renderQuestions(answerIndex:int, questions:Array):void {
			this.clearDialoguesContainer();
			var questionsLen:int=questions.length;
			var startY:int=0;
			for (var i:int=0; i < questionsLen; i++) {
				var itemAction:NPCLinkItem=new NPCLinkItem();
				itemAction.addEventListener(MouseEvent.CLICK, onDialoguesItemClick);
				itemAction.data=(i == answerIndex); //如果是答案则把值设置为true
				itemAction.iconStyle=NPCConstant.LINK_ICON_STYLE_MISSION_ANSWER;
				itemAction.label= '<font color="#4cf6ff"><u>'+questions[i]+'</u></font>';
				itemAction.y=startY;
				this._dialoguesContainer.addChild(itemAction);
				startY=startY + itemAction.height;
			}
			
			//this.createTipsBorder('choose', '请选择一个答案', this._dialoguesContainer, 5);
		}

		private function renderChooseNPCS(npcList:Array):void {
			this.clearDialoguesContainer();
			var npcListLen:int=npcList.length;
			var startY:int=0;
			var chooseList:Array = this._vo.pinfo_int_list_1;
			
			var roleFaction:int = GlobalObjectManager.getInstance().user.base.faction_id;
			
			for each (var npc:Array in npcList) {
				var itemAction:NPCLinkItem=new NPCLinkItem();
				itemAction.addEventListener(MouseEvent.CLICK, onDialoguesItemClick);
				var npcID:int = npc[0];
				var npcFaction:int = parseInt(npcID.toString().substr(1, 1)) - 1;
				
				itemAction.data={'npcID':npcID, 'doTimes':chooseList[npcFaction]}; //npc id
				itemAction.iconStyle=NPCConstant.LINK_ICON_STYLE_ACTION;
				
				var label:String = npc[1]+'（'+chooseList[npcFaction]+'）';
				if(chooseList[npcFaction] >= Math.floor(this._vo.maxDotimes/2)) {
					label = '<font color="#CCCCCC"><u>'+label+'</u></font>';		
				}else{
					label = '<u>'+label+'</u>';		
				}
				
				itemAction.label=label;
				itemAction.y=startY;
				this._dialoguesContainer.addChild(itemAction);
				startY=startY + itemAction.height;
			}
			
			this.createTipsBorder('choose', '请选择一个NPC', this._dialoguesContainer, 5);
		}

		private function onDialoguesItemClick(event:MouseEvent):void {
			var item:NPCLinkItem=event.currentTarget as NPCLinkItem;

			switch (this._dialoguesType) {
				case MissionConstant.NPC_DIALOGUES_TYPE_QUESTION:
					var isAnswer:Boolean=item.data as Boolean;

					this._dialoguesContainer.removeChild(item);
					item.removeEventListener(MouseEvent.CLICK, onDialoguesItemClick);
					if (isAnswer == false) {
						Tips.getInstance().addTipsMsg("手快点错了吧！再仔细瞧瞧。");
						return;
					}

					break;

				case MissionConstant.NPC_DIALOGUES_TYPE_CHOOSE_NPC:
					if (!this._do_int_list_1) {
						this._do_int_list_1=[];
					}
					var chooseObj:Object = item.data;
					if(chooseObj.doTimes >= Math.floor(this._vo.maxDotimes/2)){
						Tips.getInstance().addTipsMsg("请选择另一个国家。");
						return;
					}
					this._do_int_list_1.push(chooseObj.npcID);
					break;

				default:
					break;
			}

			this.changePannelStatus();
		}

		private function clearDialoguesContainer():void {
			while (this._dialoguesContainer.numChildren > 0) {
				var item:DisplayObject=this._dialoguesContainer.removeChildAt(0);
				item.removeEventListener(MouseEvent.CLICK, onDialoguesItemClick);
			}
		}

		/**
		 * 发起做任务请求
		 */
		private function doMission():void {

			if (this.needSelectProp() && this._selectedPropReward == null) {
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">请选择一项奖励</font>');
				this.createTipsBorder('chooseProp', '请选择一项奖励', this._propRewardContainer);
				return;
			}
			
			var doVO:m_mission_do_tos=new m_mission_do_tos();
			doVO.id=this._vo.id;
			if (this._selectedPropReward) {
				doVO.prop_choose=[this._selectedPropReward.prop_id];
			}
			doVO.npc_id=this._npcID;

			if (this._do_int_list_1) {
				doVO.int_list_1=this._do_int_list_1;
			}

			if (this._do_int_list_2) {
				doVO.int_list_2=this._do_int_list_2;
			}


			//不同模型的特殊处理
			switch (this._vo.model) {
				default:
					break;
			}

			Dispatch.dispatch(ModuleCommand.MISSION_DO, doVO);
			this.close();
		}
		
		/**
		 * 创建一个闪烁的高亮框 提醒玩家做某些事情
		 */
		
		private var _tipsBorderObj:Object=new Object();
		private function createTipsBorder(name:String, tips:String, target:DisplayObjectContainer, delay:int = 2):void{
			var border:Sprite = (this._tipsBorderObj[name] as Sprite);
			if(border){
				//单次刷新只显示一次啦 要不很烦了
				return;
			}else{
				border = this._tipsBorderObj[name] = ComponentUtil.drawHightLightBorder(this._canvas.width - 10, target.height+6, 5, 2, 0xffff00);
				border.x=target.x - 5;
				border.y=target.y - 3;
				this._canvas.addChild(border);
				
				var tf:TextFormat = new TextFormat();
				tf.size=20;
				tf.color=0x39ff0b;
				tf.align=TextAlign.CENTER;
				var text:TextField=ComponentUtil.createTextField(tips, 10, 10, tf, border.width - 20, border.height, border);
				text.filters = [Style.BLACK_FILTER];
			}
			
			TweenMax.to(border, delay, {alpha: 0});
		}
		
		/**
		 * 清除绘制出来的框框
		 */
		private function clearTipsBorder(name:String):void{
			var border:Sprite = (this._tipsBorderObj[name] as Sprite);
			if(border){
				this._canvas.removeChild(border);
				this._tipsBorderObj[name] = null;
			}
		}
	}
}