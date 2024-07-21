package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.managers.Dispatch;
	import com.ming.ui.controls.*;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mission.*;
	import modules.mission.vo.MissionBaseIndex;
	
	import proto.line.m_mission_do_auto_tos;
	import proto.line.p_mission_auto;
	import proto.line.p_mission_info;

	public class AutoMissionView extends Sprite {
		private var _AutoMissionList:DataGrid;
		private var _chooseTipsTxt:TextField;
		private var _tipsText:TextField;
		private var _data:Array;
		private var _costTotal:int;
		private var _startBtn:Button;
		private var _costTotalText:TextField;
		private var _tipsView:Sprite;
		private var _hasLoopTimer:Boolean=false;
		private var _waitDoNum:int=0;

		//等待提交的列表
		private var _doList:Dictionary;
		private var _missionID2AutoID:Dictionary;

		public function AutoMissionView() {
			super();

			this._doList=new Dictionary();
			this._missionID2AutoID=new Dictionary();
			initView();
		}

		public function get listData():Array {
			return this._data;
		}

		public function set listData(_value:Array):void {
			this.costTotal=0;
			this._waitDoNum=0;

			this._data=new Array();
			var itemNum:int=0;
			var waitDoNum:int=0;
			var doingNum:int=0;
			for each (var pauto:p_mission_auto in _value) {
				if (pauto.status == MissionConstant.AUTO_STATUS_WAIT_DO) {
					waitDoNum++;
				} else if (pauto.status == MissionConstant.AUTO_STATUS_DOING) {
					doingNum++;
				}

				this._data.push(pauto);
				itemNum++;
			}

			if (doingNum > 0) {
				this.registerTimer();
			}

			if (waitDoNum) {
				this._tipsView.visible=true;
//				this._tipsView.y=(itemNum + 1) * 26;
			} else {
				this._tipsView.visible=false;
			}
			this._AutoMissionList.list.dataProvider=this._data;
		}

		private function initView():void {

			//背景
			var backUI:UIComponent=new UIComponent();
			this.addChild(backUI); //2
			Style.setBorderSkin(backUI);
			backUI.width=530;
			backUI.height=340;
			

			_AutoMissionList = new DataGrid();
			_AutoMissionList.x=2;
			_AutoMissionList.y=2;
			_AutoMissionList.itemHeight = 25;
			_AutoMissionList.itemRenderer=AutoMissionItemRenderer;
			_AutoMissionList.width=backUI.width-4;
			_AutoMissionList.height= backUI.height - 30;
			_AutoMissionList.pageCount = 12;
			_AutoMissionList.addColumn("任务类型", 180);
			_AutoMissionList.addColumn("循环次数", 108);
			_AutoMissionList.addColumn("时间（分钟）", 108);
			_AutoMissionList.addColumn("消耗（元宝)", 120);
			this.addChild(_AutoMissionList);


			this._startBtn=new Button;
			this._startBtn.label='开始';
			this._startBtn.width=80;
			this._startBtn.height=25;
			this._startBtn.x=518 - this._startBtn.width - 3;
			this._startBtn.y = 347;
			this._startBtn.addEventListener(MouseEvent.CLICK, this.onStartClick);

			this.addChild(this._startBtn);

			var tf:TextFormat=new TextFormat("Tahoma", 12, 0x00ff00, false);
			_tipsText=ComponentUtil.createTextField("", 10, _startBtn.y, tf, 200, 30, this);

			_tipsText.text='注：委托任务不会消耗精力值';
			_tipsText.mouseEnabled=false;
			_tipsText.filters=[Style.BLACK_FILTER];

			_costTotalText=ComponentUtil.createTextField("", _tipsText.x + _tipsText.textWidth + 10, this._startBtn.y, tf, 100, 30, this);

			_costTotalText.mouseEnabled=false;
			_costTotalText.filters=[Style.BLACK_FILTER];

			this._tipsView=new Sprite();
			this._tipsView.x=10;
			this._tipsView.y=this._AutoMissionList.y + this._AutoMissionList.height;
			this.addChild(this._tipsView);
			
			tf.color = 0xffff00;
			_chooseTipsTxt=ComponentUtil.createTextField("请选择你要委托完成的任务", 2, 0, tf,200, 20, this._tipsView);
			_chooseTipsTxt.filters=[Style.BLACK_FILTER];
			_chooseTipsTxt.mouseEnabled=false;
			this._tipsView.visible == false;

		}

		/**
		 * 发起自动任务请求
		 */
		private function onStartClick(event:MouseEvent):void {
			var doArr:Array=[];
			var needGold:int=0;
			for each (var itemRender:AutoMissionItemRenderer in this._doList) {
				if (itemRender.getCheckBoxEnable() == false) {
					continue;
				}
				var vo:m_mission_do_auto_tos=new m_mission_do_auto_tos();
				var pautoVO:p_mission_auto=(itemRender.data as p_mission_auto);
				itemRender.setCheckBoxEnable(false);
				vo.id=pautoVO.id;
				doArr.push(vo);
				needGold+=pautoVO.need_gold;
			}
			var roleGold:int=GlobalObjectManager.getInstance().user.attr.gold + GlobalObjectManager.getInstance().user.attr.gold_bind;
			if (roleGold < needGold) {
				var tips:String='<font color="#ffff00">本次委托需要元宝：' + needGold + '，你的背包中没有足够的元宝。</font>';
				BroadcastSelf.getInstance().appendMsg(tips);
				Tips.getInstance().addTipsMsg(tips);
				return;
			}
			if (doArr.length > 0) {
				BroadcastSelf.getInstance().appendMsg('<font color="#ffff00">本次任务委托消耗' + needGold + '元宝</font>');
				Dispatch.dispatch(ModuleCommand.MISSION_AUTO_DO, doArr);
			}
		}

		/**
		 * 更新自动任务列表里准备或已经在做的任务的数据
		 */

		private function registerTimer():void {
			if (!this._hasLoopTimer) {
				LoopManager.addToSecond(MissionConstant.AUTO_TIMER_KEY, this.updateAutoTimer);
				this._hasLoopTimer=true;
			}
		}

		private function unRegisterTimer():void {
			if (this._hasLoopTimer) {
				LoopManager.removeFromSceond(MissionConstant.AUTO_TIMER_KEY);
				this._hasLoopTimer=false;
			}
		}

		public function updateDo(pautoVO:p_mission_auto):void {
			var itemRender:AutoMissionItemRenderer=this._doList[pautoVO.id];
			if (itemRender) {
				itemRender.data=pautoVO;
			}
		}

		/**
		 * 更新自动任务时间
		 */
		private function updateAutoTimer():void {
			var doingNum:int=0;
			for each (var itemRender:AutoMissionItemRenderer in this._doList) {
				var pautoVO:p_mission_auto=(itemRender.data as p_mission_auto);
				if (pautoVO.status != MissionConstant.AUTO_STATUS_DOING) {
					continue;
				}
				doingNum++;
				itemRender.updateTime();
			}
			if (doingNum == 0) {
				this.unRegisterTimer();
			}
		}

		/**
		 * 加入到自动任务的列表
		 */
		public function addDo(itemRender:AutoMissionItemRenderer):void {
			var pautoVO:p_mission_auto=(itemRender.data as p_mission_auto);
			this._costTotalText.visible=true;
			var oldPautoVO:p_mission_auto=this._doList[pautoVO.id] as p_mission_auto;

			if (!this._doList[pautoVO.id]) {
				this.costTotal=this._costTotal + pautoVO.need_gold;
			}

			this._doList[pautoVO.id]=itemRender;
			var missionBaseInfoArr:Array=MissionDataManager.getInstance().getBase(pautoVO.mission_id);
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var missionBigGroup:int=missionBaseInfoArr[MissionBaseIndex.BIG_GROUP];
			missionBigGroup=parseInt(roleFaction + (missionBigGroup.toString().substr(1, missionBigGroup.toString().length)));

			if (missionBigGroup > 0) {
				this._missionID2AutoID['g_' + missionBigGroup]=pautoVO.id;
			} else {
				this._missionID2AutoID['ng_' + pautoVO.mission_id]=pautoVO.id;
			}
			if (pautoVO.status == MissionConstant.AUTO_STATUS_DOING) {
				this.registerTimer();
			}

			if (itemRender.getCheckBoxEnable() == true) {
				this._waitDoNum++;
			} else {
				this._waitDoNum--;
			}

			if (this._waitDoNum > 0) {
				this._startBtn.enabled=true;
			} else {
				this._waitDoNum=0;
				this._startBtn.enabled=false;
			}
		}

		/**
		 * fuck！！先放这里
		 */
		public function doingAuto(missionID:int, missionBigGroup:int):Boolean {
			var pautoID:int;
			if (missionBigGroup > 0) {
				pautoID=this._missionID2AutoID['g_' + missionBigGroup];
			} else {
				pautoID=this._missionID2AutoID['ng_' + missionID];
			}
			if (pautoID) {
				var itemRender:AutoMissionItemRenderer=this._doList[pautoID];
				if (!itemRender) {
					return false;
				}
				var pautoVO:p_mission_auto=itemRender.data as p_mission_auto;
				if (pautoVO.status == MissionConstant.AUTO_STATUS_DOING) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}

		private function set costTotal(value:int):void {
			this._costTotal=value;
			if (this._costTotal <= 0) {
				this._costTotal=0;
				this._costTotalText.visible=false;
			} else {
				this._costTotalText.text='消耗元宝：' + this._costTotal;
			}
		}

		/**
		 * 移除自动任务的列表
		 */
		public function removeFromDo(itemRender:AutoMissionItemRenderer):void {
			var pautoVO:p_mission_auto=(itemRender.data as p_mission_auto);
			this.costTotal=this._costTotal - pautoVO.need_gold;

			var missionBaseInfoArr:Array=MissionDataManager.getInstance().getBase(pautoVO.mission_id);
			var missionBigGroup:int=missionBaseInfoArr[MissionBaseIndex.BIG_GROUP];
			if (missionBigGroup > 0) {
				delete this._missionID2AutoID['g_' + missionBigGroup];
			} else {
				delete this._missionID2AutoID['ng_' + pautoVO.mission_id];
			}

			if (this._costTotal == 0) {
				this._startBtn.enabled=false;
			}
			delete this._doList[pautoVO.id];
		}
	}
}