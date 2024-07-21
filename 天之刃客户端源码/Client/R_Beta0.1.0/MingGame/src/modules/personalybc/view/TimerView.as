package modules.personalybc.view {
	import com.common.GlobalObjectManager;
	
	import com.components.alert.Alert;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.BroadcastModule;
	import modules.personalybc.PersonalYbcModule;
	import modules.system.SystemConfig;
	
	import proto.line.m_personybc_auto_toc;
	import proto.line.m_personybc_auto_tos;
	import proto.line.m_personybc_info_toc;
	import proto.line.m_personybc_info_tos;
	import proto.line.p_personybc_info;

	public class TimerView extends Sprite {

		private var bgView:UIComponent;
		private var txtView:TextField;
		private var autoTxt:TextField;
		private var _startTime:int;
		private var _timeLimit:int;
		private var _tips:String='';

		private var _notice:Object;
		private const CHECK_TIME:int=20; //检查是否需要通知的误差时间
		private const NOTICE_START_MIN_1:int=900; //15分钟广播
		private const NOTICE_START_MIN_2:int=300; //5分钟广播
		private var autoStr:String="<a href=\"event:auto\"><font color='#00FF00'><u>自动拉镖</u></font></a>";
		private var canelAutoStr:String="<a href=\"event:canel\"><font color='#00FF00'><u>取消自动拉镖</u></font></a>";
		private var isAuto:Boolean;
		private var isNation:Boolean; //是否国运期间

		public function TimerView() {
			var textFormat:TextFormat=new TextFormat();

			textFormat.color="0xFFF673";
			textFormat.size=12;
			textFormat.align="left";

			bgView=new UIComponent;
			bgView.width=100;
			bgView.height=45; //60自动拉镖的高度;
			Style.setMenuItemBg(bgView); //背景
			txtView=ComponentUtil.createTextField("", 3, 4, textFormat, 100, 40, this);
			txtView.multiline=true;
			txtView.wordWrap=true;
			this.addChild(bgView);
			this.addChild(txtView);
			this.addEventListener(MouseEvent.MOUSE_OVER, this._mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, this._mouseOut);
			this._tips='请在规定时间内将镖车护送到蓝玉将军附近。';

			_notice=new Object();
			_notice['15min']=0;
			_notice['5min']=0;
			_notice['stop']=0;
			_notice['start']=0;

			var tf2:TextFormat=new TextFormat(null, 12, 0x00ff00, null, null, null, null, null, "right");
			autoTxt=ComponentUtil.createTextField("", 3, 34, tf2, 92, 20, this);
			autoTxt.mouseEnabled=true;
			autoTxt.htmlText=autoStr;
			autoTxt.addEventListener(TextEvent.LINK, onClickAuto);
			autoTxt.visible=false; //屏蔽自动拉镖
		}
		
		private var heightValue:int=40;
		
		override public function get height():Number
		{
			// TODO Auto Generated method stub
			return heightValue;
		}
		
		

		public function rmove():void {
			this.unload();
		}

		public function unload():void {
			txtView=null;
			bgView=null;
			if (this.parent != null){
				BroadcastModule.getInstance().countdownView.removeChildren(this.parent);
			}
		}

		private var _colorBool:Boolean=false;
		private var _stoped:Boolean=false;


		private function _mouseOut(_e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}

		private function _mouseOver(_e:MouseEvent):void {
			ToolTipManager.getInstance().show(this._tips);
		}

		public function update():void {

			if (!PersonalYbcModule.getInstance().view.info_toc)
				return;
			var _vo:p_personybc_info=PersonalYbcModule.getInstance().view.info_toc.info;

			var _timeStr:String='';
			//{'remain':_remainTime, 'str':_strFix+str}
			var _ybcStart:int=_vo.start_time;
			var _ybcEnd:int=_vo.start_time + _vo.time_limit;
			var _now:int=SystemConfig.serverTime;
			var _withFaction:Boolean=false;
			var _withYbc:Boolean=false;
			var _ybcStr:String='尚未接镖';
			var _factionStr:String='非国运时间';

			if (_ybcStart > 0) {
				var _ybcTimeData:Object=formatTimeStr(_vo.start_time, _vo.time_limit, '护镖时间：', _now);

				if (_ybcTimeData.remain <= 0) {
					this._tips='护镖已经超时，请前往蓝玉将军处报告。';
					_ybcStr='<font color="#ff0000">护镖已超时</font>';
				} else {
					_ybcStr=_ybcTimeData.str;
				}
				_withYbc=true;
				if (autoTxt.htmlText == "") {
					autoTxt.htmlText=autoStr;
				}
			} else {
				autoTxt.htmlText="";
			}

			var _factionStart:int=_vo.faction_start_time;
			var _factionEnd:int=_vo.faction_time_limit + _vo.faction_start_time;

			if (_factionStart <= _now + 5 && _factionEnd >= _now) {
				var _factionTimeData:Object=formatTimeStr(_vo.faction_start_time, _vo.faction_time_limit, '国运时间：', _now);
				if (!_timeStr) {
					this._tips='国运期间拉镖获得200%的经验奖励，获得的银子奖励15%为不绑定银子。';
					_factionStr=_factionTimeData.str;
				} else {
					_factionStr=_factionTimeData.str;
				}
				_withFaction=true;
				isNation=true;
			} else {
				isNation=false;
			}

			_timeStr=_factionStr + '<br />' + _ybcStr;

			if (!_withFaction && !_withYbc) {
				PersonalYbcModule.getInstance().removeTimerView();
			}
			this.txtView.htmlText=_timeStr;
		}

		public function formatTimeStr(_startTime:int, _timeLimit:int, _strFix:String, _now:int):Object {
			var _remainTime:int=_startTime + _timeLimit - _now;
			_remainTime=Math.max(0, _remainTime);
			var str:String='';
			var h:int=_remainTime / 3600;
			var m:int=_remainTime / 60;
			var s:int=_remainTime % 60;
			if (h >= 10) {
				str+=h + ':';
			} else if (h > 0) {
				str+='0' + h + ':';
			}

			if (m >= 10) {
				str+=m + ':';
			} else {
				str+='0' + m + ':';
			}

			if (s >= 10) {
				str+=s;
			} else {
				str+='0' + s;
			}

			return {'remain': _remainTime, 'str': _strFix + str};
		}


		private function _notifyMsg(_type:String, _now:int):void {

			if (!_notice) {
				_notice=new Object();
			}
			if (_notice[_type] != 0 && (_now - _notice[_type]) <= CHECK_TIME + 10) {
				return;
			}

			_notice[_type]=_now;
			var _msg:String='';

		}

		private function onClickAuto(e:TextEvent):void {
			if (e.text == "auto") {
				if (isAuto == false) {
					var info:m_personybc_info_toc=PersonalYbcModule.getInstance().view.info_toc;
					if (info.info.need_notice_when_auto == true) {
						Alert.show("国运时间自动拉镖需花费" + info.info.auto_pay_gold + "元宝，是否同意？", "自动拉镖", yesHandler, null, "同意", "取消");
					} else {
						yesHandler();
					}
				}
			} else if (e.text == "canel") {
				if (isAuto == true) {
					var vo:m_personybc_auto_tos=new m_personybc_auto_tos;
					vo.type=false;
					Connection.getInstance().sendMessage(vo);
				}
			}
		}

		private function yesHandler():void {
			var vo:m_personybc_auto_tos=new m_personybc_auto_tos;
			vo.type=true;
			Connection.getInstance().sendMessage(vo);
		}

		public function updateAuto(vo:m_personybc_auto_toc):void {
			if (vo.succ == true) {
				isAuto=!isAuto;
				if (isAuto == true) {
					autoTxt.htmlText=canelAutoStr;
					PathUtil.findNpcAndOpen(1 + "" + GlobalObjectManager.getInstance().user.base.faction_id + 105101);
				} else {
					autoTxt.htmlText=autoStr;
				}
				var s:m_personybc_info_tos=new m_personybc_info_tos;
				s.type=PersonalYbcModule.getInstance().view.type;
				Connection.getInstance().sendMessage(s);
			}
		}
	}
}