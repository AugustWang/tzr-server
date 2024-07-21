package modules.mission.views {
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.mission.MissionConstant;
	import modules.mission.MissionDataManager;
	import modules.mission.MissionModule;
	import modules.mission.vo.MissionPropRewardVO;
	import modules.mission.vo.MissionRewardVO;
	import modules.mission.vo.MissionVO;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;
	
	import proto.line.m_mission_cancel_tos;
	import proto.line.m_mission_do_tos;
	import proto.line.p_mission_listener;

	public class MissionDetailView extends Sprite implements IDataRenderer{
		private var _descText:TextField;
		private var _targetText:TextField;
		private var _rewardAttrText:TextField;
		private var _rewardPropContainer:Sprite;
		private var _cancelBtn:Button;
		
		private var _descTitle:Bitmap;
		private var _targetTitle:Bitmap;
		private var _rewardTitle:Bitmap;
		
		public function MissionDetailView() {
			init();
		}

		private function init():void {
			var tf:TextFormat = new TextFormat();
			tf.size = 20;
			tf.bold = true;
			
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),3,7,this)
			this._descTitle = ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"mission_desc"),20,10,this);
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),3,117,this)
			this._targetTitle = ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"mission_target"),20,120,this);
			ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"cloudBg"),3,210,this)
			_rewardTitle = ComponentUtil.createBitmap(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"mission_reward"),20,213,this);
			
			tf.size = 10;
			this._descText = ComponentUtil.createTextField("", 10, this._descTitle.height+this._descTitle.y, null, 275, 85, this, wrapperHandler);
			
			//createLine(316,95);
			this._targetText = ComponentUtil.createTextField("", 15, this._targetTitle.height+this._targetTitle.y, null, 275, 85, this, wrapperHandler);
			//createLine(316,165);
			this._rewardAttrText = ComponentUtil.createTextField("", 10, this._rewardTitle.height+this._rewardTitle.y, null, 275, 85, this, wrapperHandler);
			this._rewardPropContainer = new Sprite();
			this._rewardPropContainer.x = 10;
			this._rewardPropContainer.y = _rewardAttrText.y + _rewardAttrText.textHeight + 25;
			addChild(this._rewardPropContainer);
			this._cancelBtn = ComponentUtil.createButton('取消任务', 195, 348, 100, 25, this);
			this._cancelBtn.visible = false;
			this._cancelBtn.addEventListener(MouseEvent.CLICK, this.onCancelMission);
			
			this._targetText.addEventListener(TextEvent.LINK, this.onClickTargetLink);
			
		}
		
		/**
		 * 点击任务目标时
		 */
		private function onClickTargetLink(event:TextEvent):void{
			MissionModule.getInstance().onMissionLink(event.text);
		}
		
		private function onCancelMission(e:MouseEvent):void{
			var cancelVO:m_mission_cancel_tos = new m_mission_cancel_tos();
			cancelVO.id = this._data.id;
			Dispatch.dispatch(ModuleCommand.MISSION_CANCEL, cancelVO);
		}
		
		private function createLine(w:Number,y:int):void{
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.x = 3;
			line.y = y;
			line.width = w;
			addChild(line);
		}
		private function wrapperHandler(text:TextField):void{
			text.wordWrap = true;
			text.multiline = true;
			text.autoSize = TextFieldAutoSize.LEFT;
			text.mouseEnabled = true;
		}
		
		private function initMissionDetial():void{
			clear();
			if(_data){
				var desc:String = _data.desc;
				desc.replace(GameConfig.S_REG_EXP, GameConfig.SUO_JIN_STR);
				desc.replace(GameConfig.N_REG_EXP, GameConfig.N_STR);
				if(this._data.maxDotimes > 1){
					desc = desc+'\n<font color="#ffff00">【今天第'+(this._data.commitTimes+1)+'次接任务】</font>';
				}
				
				_descText.htmlText = desc ;
				
				var targetString:String = _data.target.replace(MissionConstant.TARGET_S_REG_EXP, '');
				_targetText.htmlText = targetString.replace(MissionConstant.TRANS_GO_REG_EXP, '');
				
				for each(var propReward:MissionPropRewardVO in _data.rewardData.prop_reward){
					var item:MissionPropRewardItem = new MissionPropRewardItem();
					item.data = propReward;
					_rewardPropContainer.addChild(item);
				}
				
				var rewardAttrStr:String = '';
				rewardAttrStr += MissionDataManager.getInstance().wrapperInt('经验', _data.rewardData.exp, '  ');
				rewardAttrStr += MissionDataManager.getInstance().wrapperSilver('银子', _data.rewardData.silver, '  ');
				rewardAttrStr += MissionDataManager.getInstance().wrapperSilver('绑定银子', _data.rewardData.silver_bind, '  ');
				rewardAttrStr += MissionDataManager.getInstance().wrapperInt('声望值', _data.rewardData.prestige, '  ');
				
				switch(this._data.rewardData.attr_reward_formula){
					case MissionRewardVO.ATTR_REWARD_FORMULA_WU_XING:
						rewardAttrStr += '获得五行属性\n';
						break;
				}
				
				switch(this._data.rewardData.prop_reward_formula){
					case MissionRewardVO.PROP_REWARD_FORMULA_CHOOSE_ONE:
						if(_data.rewardData.prop_reward.length > 1){
							rewardAttrStr += '\n完成任务后选择一项奖励：\n';
						}
						break;
					case MissionRewardVO.PROP_REWARD_FORMULA_RANDOM:
						rewardAttrStr += '\n完成任务后随机获得：\n';
						break;
				}
				
				_rewardAttrText.htmlText = rewardAttrStr;
				_rewardPropContainer.y = _rewardAttrText.y + _rewardAttrText.textHeight + 25;
				LayoutUtil.layoutHorizontal(_rewardPropContainer,5);
				if(_data.currentModelStatus != MissionConstant.FIRST_STATUS){
					this._cancelBtn.visible = true;
				}else{
					this._cancelBtn.visible = false;
				}
			}
		}
		
		private function clear():void{
			_descText.htmlText = "";
			_targetText.htmlText = "";
			_rewardAttrText.htmlText = "";
			while(_rewardPropContainer.numChildren > 0){
				_rewardPropContainer.removeChildAt(0);
			}
		}
		
		private var _data:MissionVO;
		public function set data(value:Object):void{
			_data = value as MissionVO;
			initMissionDetial();
		}
		
		public function get data():Object{
			return _data;
		}
	}
}