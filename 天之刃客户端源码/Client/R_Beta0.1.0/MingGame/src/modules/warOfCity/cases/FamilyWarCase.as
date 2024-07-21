package modules.warOfCity.cases
{
	import com.common.GlobalObjectManager;
	import com.engine.core.controls.system.modelProxy.IMessage;
	import com.engine.core.controls.system.modelProxy.MessageConstant;
	import com.engine.core.controls.system.modelProxy.Model;
	
	import com.engine.core.controls.system.service.ServiceVO;
	import com.events.UIEvent;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import modules.UIManager;
	import modules.WindowManager;
	import modules.broadcast.views.BroadcastView;
	import com.components.alert.Alert;
	import com.components.alert.Prompt;
	import com.events.WindowEvent;
	import modules.scene.SceneDataManager;
	import modules.warOfCity.WarOfCityMap_M;
	import modules.warOfCity.WarOfCityMap_S;
	import modules.warOfCity.view.WarCityDetailView;
	import modules.warOfCity.view.WarCityFamilyScore;
	import modules.warOfCity.view.WarCityItem;
	import modules.warOfCity.view.WarCityScoreView;
	import modules.warOfCity.view.WarCitySignView;
	
	import proto.line.m_warofcity_agree_enter_toc;
	import proto.line.m_warofcity_agree_enter_tos;
	import proto.line.m_warofcity_apply_toc;
	import proto.line.m_warofcity_apply_tos;
	import proto.line.m_warofcity_break_toc;
	import proto.line.m_warofcity_collect_toc;
	import proto.line.m_warofcity_end_toc;
	import proto.line.m_warofcity_get_mark_toc;
	import proto.line.m_warofcity_get_mark_tos;
	import proto.line.m_warofcity_hold_succ_toc;
	import proto.line.m_warofcity_hold_toc;
	import proto.line.m_warofcity_hold_tos;
	import proto.line.m_warofcity_holding_toc;
	import proto.line.m_warofcity_panel_manage_toc;
	import proto.line.m_warofcity_panel_manage_tos;
	import proto.line.m_warofcity_panel_toc;
	import proto.line.m_warofcity_panel_tos;
	import proto.line.m_warofking_end_toc;
	
	public class FamilyWarCase
	{
		private var _model:Model;
		private var _view:WarCitySignView;
		private var _detailView:WarCityDetailView;
		private var _scoreView:WarCityScoreView;
		private var _timer:Timer;
		
		public function FamilyWarCase(model:Model)
		{
			_model=model;
		}
		
		private function initView():void
		{
			if (_view == null)
			{
				_view=new WarCitySignView;
				_view.addEventListener(WindowEvent.OPEN, toRequestSignDetail);
				_view.addEventListener(WarCityItem.EVENT_SIGN_UP, toSignUp);
			}
		}
		
		private function initDetailView():void
		{
			if (_detailView == null)
			{
				_detailView=new WarCityDetailView;
				_detailView.addEventListener(WindowEvent.OPEN, toRequestOccupy);
			}
		}
		
		private function initScoreView():void
		{
			if (_scoreView == null)
			{
				_scoreView=new WarCityScoreView;
				_scoreView.x=GlobalObjectManager.GAME_HEIGHT;
				_scoreView.y=2;
			}
			
		}
		
		public function toOpenSignView():void
		{
			initView();
			WindowManager.getInstance().popUpWindow(_view);
			WindowManager.getInstance().centerWindow(_view);
		}
		
		private function toRequestSignDetail(e:WindowEvent):void
		{
			var vo:m_warofcity_panel_tos=new m_warofcity_panel_tos;
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_PANEL, vo);
			//			_model.send(m);
		}
		
		public function onRequestSignDetail(vo:m_warofcity_panel_toc):void
		{
			_view.update(vo);
		}
		
		private function toSignUp(e:UIEvent):void
		{
			var vo:m_warofcity_apply_tos=new m_warofcity_apply_tos;
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_AGREE_ENTER, vo);
			_model.send(m);
		}
		
		public function onSignUp(vo:m_warofcity_apply_toc):void
		{
			if (vo.succ)
			{
				BroadcastView.getInstance().addBroadcastMsg("成功报名参加城市争夺战");
			}
			else
			{
				Alert.show(vo.reason, null, null, null, "确定", "", null, false);
				//报名失败
			}
		}
		
		public function onCollect(vo:m_warofcity_collect_toc):void
		{
			Prompt.show("是否参加城市争夺战？", "征集令", yesHandler, noHandler, "同意", "拒绝");
		}
		
		private function yesHandler():void
		{
			var vo:m_warofcity_agree_enter_tos=new m_warofcity_agree_enter_tos;
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_AGREE_ENTER, vo);
			_model.send(m);
		}
		
		public function onAgreeCollect(vo:m_warofcity_agree_enter_toc):void
		{
			if (vo.succ == false)
			{
				BroadcastView.getInstance().addBroadcastMsg(vo.reason);
			}
		}
		
		private function noHandler():void
		{
			
		}
		
		public function toEnterCityMap():void
		{
			//			var vo:m_warofcity_enter_tos=new m_warofcity_enter_tos;
			//			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			//			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_PANEL_MANAGE, vo);
			//			_model.send(m);
		}
		
		public function toOpenOccupyView():void
		{
			initDetailView();
			WindowManager.getInstance().popUpWindow(_detailView);
			WindowManager.getInstance().centerWindow(_detailView);
		}
		
		public function toRequestOccupy(e:WindowEvent):void
		{
			var vo:m_warofcity_panel_manage_tos=new m_warofcity_panel_manage_tos;
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_PANEL_MANAGE, vo);
			//			_model.send(m);
		}
		
		public function onRequestOccupy(vo:m_warofcity_panel_manage_toc):void
		{
			_detailView.update(vo);
		}
		
		public function onEnterMap():void
		{
			//			initScoreView();
			//			if (_scoreView.parent == null)
			//			{
			//				LayerManager.uiLayer.addChild(_scoreView);
			//			}
			if (SceneDataManager.isRobCityMap == true)
			{
				initScoreView();
				if (_scoreView.parent == null)
				{
					LayerManager.uiLayer.addChild(_scoreView);
				}
			}
			else
			{
				if (_scoreView != null && _scoreView.parent != null)
				{
					_scoreView.parent.removeChild(_scoreView);
				}
			}
		}
		
		public function onStartFight():void
		{
			if (_timer == null)
			{
				_timer=new Timer(1000);
				_timer.addEventListener(TimerEvent.TIMER, toGetMarks);
				_timer.start();
			}
			
		}
		
		public function toHold():void
		{
			var vo:m_warofcity_hold_tos=new m_warofcity_hold_tos;
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_HOLD, vo);
			_model.send(m);
		}
		
		public function onHold(vo:m_warofcity_hold_toc):void
		{
			if (vo.succ == true)
			{
				BroadcastView.getInstance().addBroadcastMsg("图腾正在被" + vo.family_name + "成员占领！");
				var getter:Vector.<int>=new Vector.<int>;
				getter.push(ModelConstant.SCENE_MODEL);
				var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_MODEL, MessageConstant.CALL, getter, null);
				m.data=vo;
				m.name=WarOfCityMap_M.ROB_CITY_HOLD_SEAT;
				_model.send(m);
			}
			else
			{
				BroadcastView.getInstance().addBroadcastMsg(vo.reason);
			}
		}
		
		public function onHolding(vo:m_warofcity_holding_toc):void
		{
			var getter:Vector.<int>=new Vector.<int>;
			getter.push(ModelConstant.SCENE_MODEL);
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_MODEL, MessageConstant.CALL, getter, null);
			m.data=vo;
			m.name=WarOfCityMap_M.ROB_CITY_HOLDING;
			//			_model.send(m);
		}
		
		public function onHoldBreak(vo:m_warofcity_break_toc):void
		{
			var getter:Vector.<int>=new Vector.<int>;
			getter.push(ModelConstant.SCENE_MODEL);
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_MODEL, MessageConstant.CALL, getter, null);
			m.data=vo;
			m.name=WarOfCityMap_M.ROB_CITY_BREAK;
			//			_model.send(m);
		}
		
		public function onHoldSucc(vo:m_warofcity_hold_succ_toc):void
		{
			BroadcastView.getInstance().addBroadcastMsg("图腾被" + vo.family_name + "门派的" + vo.role_name + "占领");
		}
		
		public function onEnd(vo:m_warofking_end_toc):void
		{
			if (vo.family_id == GlobalObjectManager.getInstance().user.base.family_id)
			{
				BroadcastView.getInstance().addBroadcastMsg("你的门派获胜了！");
			}
			else
			{
				BroadcastView.getInstance().addBroadcastMsg("城市争夺战结束！");
			}
			var getter:Vector.<int>=new Vector.<int>;
			getter.push(ModelConstant.SCENE_MODEL);
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_MODEL, MessageConstant.CALL, getter, null);
			m.data=vo;
			m.name=WarOfCityMap_M.ROB_CITY_END;
			_model.send(m);
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, toGetMarks);
			_timer=null;
		}
		
		private function toGetMarks(e:TimerEvent):void
		{
			var vo:m_warofcity_get_mark_tos=new m_warofcity_get_mark_tos;
			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_SERVER, MessageConstant.CALL, null, null);
			m.data=new ServiceVO(WarOfCityMap_S.WAROFCITY, WarOfCityMap_S.WAROFCITY_GET_MARK, vo);
			_model.send(m);
		}
		
		public function onGetMarks(vo:m_warofcity_get_mark_toc):void
		{
			
		}
		
		public function onMapCHange():void
		{
			
		}
		
		
		public function toHoldPillar():void
		{
			
		}
		
	}
}