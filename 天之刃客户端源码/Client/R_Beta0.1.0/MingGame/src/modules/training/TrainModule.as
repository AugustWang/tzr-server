package modules.training
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.WindowEvent;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.net.SocketCommand;
	import com.scene.GameScene;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.scene.SceneDataManager;
	import modules.training.views.TrainPanel;
	import modules.training.views.TrainYBUI;
	import modules.training.views.TrainignUI;
	
	import proto.line.m_trainingcamp_exchange_toc;
	import proto.line.m_trainingcamp_exchange_tos;
	import proto.line.m_trainingcamp_remain_point_toc;
	import proto.line.m_trainingcamp_remain_point_tos;
	import proto.line.m_trainingcamp_start_toc;
	import proto.line.m_trainingcamp_start_tos;
	import proto.line.m_trainingcamp_state_toc;
	import proto.line.m_trainingcamp_state_tos;
	import proto.line.m_trainingcamp_stop_toc;
	import proto.line.m_trainingcamp_stop_tos;
	
	public class TrainModule extends BaseModule
	{
		private static var _instance:TrainModule;
		
		private var _trainPointUI:TrainYBUI;
		private var _trainingUI:TrainignUI;
		private var _trainPanel:TrainPanel;
		
		public var isTrainning:Boolean=false;
		
		public function TrainModule()
		{
		}
		
		public static function getInstance():TrainModule
		{
			if (_instance == null)
				_instance=new TrainModule();
			
			return _instance;
		}
		
		override protected function initListeners():void
		{
			addSocketListener(SocketCommand.TRAININGCAMP_REMAIN_POINT, remainPointReturn);
			addSocketListener(SocketCommand.TRAININGCAMP_EXCHANGE, exchangeReturn);
			addSocketListener(SocketCommand.TRAININGCAMP_STATE, trainingStateReturn);
			addSocketListener(SocketCommand.TRAININGCAMP_START, startTrainReturn);
			addSocketListener(SocketCommand.TRAININGCAMP_STOP, stopTrainReturn);
			
			addMessageListener(ModuleCommand.TRAINING_STATE, trainingState);
			addMessageListener(ModuleCommand.ENTER_GAME, onEnter);
			addMessageListener(NPCActionType.NA_39, onOpenTrainPanel);
			addMessageListener(ModuleCommand.OPEN_TRAIN, initTrainning);
		}
		
		private function onOpenTrainPanel(vo:NpcLinkVO=null):void
		{
			initTrainning();
		}
		
		private function onEnter():void
		{
			if( GlobalObjectManager.getInstance().user.base.status == TrainConstant.STATUS)
			{
				isTrainning=true;
				this.dispatch(ModuleCommand.TRAINING_START);
				trainingState();
				upDateStateOnTimer();
			}
		}
		
		
		
		private function initTrainning():void
		{
			if(GlobalObjectManager.getInstance().user.attr.level < 20)
			{
				//等级不满20就，暂时不能使用训练营
				BroadcastSelf.logger("<font color='#ff0000'>等级不满20级，暂时不能使用训练营。</font>");
				return;
			}
			
			if(GameScene.getInstance().hero.pvo.state == TrainConstant.STATUS)
				isTrainning=true;
			else
				isTrainning = false;
			
			if (isTrainning)
			{
				if (!_trainingUI)
				{
					_trainingUI=new TrainignUI();
					_trainingUI.x = 300;
					_trainingUI.y = 100;
					_trainingUI.addEventListener(CloseEvent.CLOSE, onCloseTrainingUI);
				}
				WindowManager.getInstance().popUpWindow(_trainingUI);
				trainingState();
			}
			else
			{
				if (!_trainPanel)
				{
					_trainPanel=new TrainPanel();
					_trainPanel.x=300;
					_trainPanel.y=100;
					_trainPanel.addEventListener(WindowEvent.CLOSEED, closeTrainPanel);
				}
				WindowManager.getInstance().popUpWindow(_trainPanel);
				this.sendSocketMessage(new m_trainingcamp_remain_point_tos);
			}
		}
		
		private function remainPointReturn(vo:m_trainingcamp_remain_point_toc):void
		{
			if (!_trainPanel)
				return ;
			if (vo.succ)
			{
				_trainPanel.initData(vo.training_point);
			}
			else
			{
				Alert.show(vo.reason, "提示：", null, null, "确定", null, null, false);
			}
		}
		
		
		
		
		private var addPoint:int; //增加的训练点数
		
		public function exchangePoint(point:int):void
		{
			var vo:m_trainingcamp_exchange_tos=new m_trainingcamp_exchange_tos();
			vo.training_point=point;
			addPoint=point;
			this.sendSocketMessage(vo);
		}
		
		private function exchangeReturn(vo:m_trainingcamp_exchange_toc):void
		{
			if (!vo.succ)
			{
				Alert.show(vo.reason, "提示：", null, null, "确定", null, null, false);
				
			}
			else
			{ 
				GlobalObjectManager.getInstance().user.attr.gold = vo.gold;
				GlobalObjectManager.getInstance().user.attr.gold_bind = vo.gold_bind;
				this.dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
				if (_trainPanel)
				{
					_trainPanel.addPoint(addPoint);
				}
			}
		}
		
		private var timer:Timer;
		private function upDateStateOnTimer():void
		{
			if(!timer)
			{
				timer = new Timer(60000);
				timer.addEventListener(TimerEvent.TIMER, onRequestState);
				timer.start();
			}
		}
		
		private function onRequestState(e:TimerEvent):void
		{
			trainingState();
		}
		private function stopTimer():void
		{
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, onRequestState);
				timer = null;
			}
		}
		
		
		public function trainingState():void
		{
			var vo:m_trainingcamp_state_tos=new m_trainingcamp_state_tos();
			
			sendSocketMessage(vo);
		}
		
		private function trainingStateReturn(vo:m_trainingcamp_state_toc):void
		{
			var progressScalex:Number=vo.time_expire / vo.time_total;
			this.dispatch(ModuleCommand.TRAINING_PROGRESS, progressScalex);
			if (_trainingUI)
			{
				_trainingUI.initData(vo);
				_trainingUI.setProgress(progressScalex);
			}
		}
		
		
		public function startTrain(hours:int):void
		{
			var vo:m_trainingcamp_start_tos=new m_trainingcamp_start_tos();
			vo.time=hours;
			
			this.sendSocketMessage(vo);
		}
		
		private function startTrainReturn(vo:m_trainingcamp_start_toc):void
		{
			if (vo.succ)
			{
				isTrainning=true;
				GlobalObjectManager.getInstance().user.base.status = TrainConstant.STATUS;
				
				if (_trainPanel)
				{
					closeTrainPanel();
				}
				//本次训练由于经验储满，将会在多少时间后停止
				if(vo.last_time>0)
				{
					var last_time:String = "<font color='#ff0000'>提示：本次训练由于经验储满，将会在";
					if(vo.last_time>= 60)
					{
						last_time += String(int(vo.last_time/60))+"小时";
						if(vo.last_time%60 >0)
						{
							last_time += String(int(vo.last_time%60))+"分钟";
						}
					}
					else{
						
						last_time +=String(int(vo.last_time%60))+"分钟";
					}
					
					last_time += "后停止。</font>";
					
					BroadcastSelf.logger(last_time);	
				}
				this.dispatch(ModuleCommand.TRAINING_START);
				this.dispatch(ModuleCommand.TRAINING_PROGRESS, 0);
				upDateStateOnTimer();
			}else{
				BroadcastSelf.logger(vo.reason);
			}
		}
		
		public function stopTrain():void
		{
			this.sendSocketMessage(new m_trainingcamp_stop_tos);
		}
		
		private function stopTrainReturn(vo:m_trainingcamp_stop_toc):void
		{
			if(!vo.succ)
			{
				BroadcastSelf.logger("停止训练失败，"+"原因："+vo.reason);
				return;
			}
			stopTimer();
			GlobalObjectManager.getInstance().user.base.status = 0;
			isTrainning=false;
			
			BroadcastSelf.logger("训练结束\n获得训练经验：" + vo.exp_get + "\n扣除训练点数："+vo.training_point);
			if(_trainingUI)
			{
				onCloseTrainingUI();
				_trainingUI = null;
			}
			this.dispatch(ModuleCommand.TRAINING_END);
		}
		
		
		public function closeTrainPanel(e:Event=null):void
		{
			if(_trainPanel==null)
				return;
			if (WindowManager.getInstance().isPopUp(_trainPanel))
			{
				WindowManager.getInstance().removeWindow(_trainPanel);
			}
			if (_trainPanel) {
				_trainPanel.dispose();
				_trainPanel=null;
			}
		}
		
		private function onCloseTrainingUI(e:CloseEvent = null):void
		{
			if (WindowManager.getInstance().isPopUp(_trainingUI))
			{
				WindowManager.getInstance().removeWindow(_trainingUI);
			}
		}
	}
}



