package modules.training.views
{
	import com.components.BasePanel;
	import com.components.HeaderBar;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.JSUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.training.TrainConstant;
	import modules.training.TrainModule;
	
	import proto.line.m_trainingcamp_state_toc;
	
	
	public class TrainignUI extends BasePanel //DragUIComponent
	{
		private var _trainingTF:TextField;
		private var txtFormat:TextFormat;
		
		private var _trainingCost:TextField; //消耗训练点数
		private var _trainingGet:TextField;  //获得经验
		private var _trainingProgress:TextField;  // 进程（分钟）
		private var _trainingToLevel:TextField;           //达到等级
		private var _trainingStopBtn:Button;     //停止训练
		
		private var costPointTF:TextField;
		private var getExpTF:TextField;
		private var progressTF:TextField;
		private var toLevelTF:TextField;
		
		private var getExpPre:TextField;
		
		private var tipTf:TextField;
		
		//本次训练使用了训练点数：xx，剩余xx点，同时获得了经验xxxx，你确定要停止训练了吗？
		private var alertStr:String = "";
		private var usedPoint:int ;
		private var ttPoint:int;
		private var restPoint:int;
		private var getExp:int;
		
		private var rowOneY:Number = 32;
		private var rowTowY:Number = 60;
		
		private var scale_const:Number; 
		
//		private var progressBg:Sprite;
		private var progressBar:Sprite; 
		private var bim:Bitmap;
		private var fillBtn:Button;
		private var timer:Timer;
		 
		
		public function TrainignUI()
		{
			super();
			this.width = 372;
			this.height = 153;
			title = "闭关修炼中";
			initUI();
		}
		
		private function initUI():void
		{
			var trainBg:UIComponent;
			trainBg = new UIComponent();
			Style.setBorderSkin(trainBg);
			trainBg.x = 7;
			trainBg.y = 31;
			//			_selfBg.y = 2;
			trainBg.width = 357;//359;
			trainBg.height = 55;//223;
			addChild(trainBg);
			
			
			var headerbar:HeaderBar = new HeaderBar();
			headerbar.addColumn(TrainConstant.TRAING_COST,96);
			headerbar.addColumn(TrainConstant.TRAING_GET_EXP,78);
			headerbar.addColumn(TrainConstant.TRAING_PROGRESS,82);
			headerbar.addColumn(TrainConstant.TRAING_TO_LEVEL,78);
			headerbar.x = 10;
			headerbar.y = 32;
			headerbar.width = 349;
			addChild(headerbar);
			
			
			txtFormat = new TextFormat("Tahoma",12,0x000000);
			
			
			var progressBg:UIComponent = new UIComponent();//GameUtils.getEmbedScaleBitmap("shopBarBg",3,3,432,19,Global.UIdm);
			Style.setBorder1Skin(progressBg);
			progressBg.x =8;
			progressBg.y = 6;
			progressBg.width = 355;//358;
			progressBg.height = 24;
			addChild(progressBg);
			
			scale_const = 350/275;
			bim = new Bitmap();
			bim.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI, "train_bar");
			bim.x = 11;
			bim.y = 8.8;
			bim.width = 354;
			bim.height = 18;
			bim.scaleX = 0;//scale_const;
			addChild(bim);
			
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xece8bb,null,null,null,null,null,"center");
			
			costPointTF = ComponentUtil.createTextField("0点",18,rowTowY,tf,95,22,this);
			getExpTF = ComponentUtil.createTextField("0",113,rowTowY,tf,76,22,this);
			progressTF = ComponentUtil.createTextField("0",190,rowTowY,tf,80,22,this);
			toLevelTF = ComponentUtil.createTextField("0",276,rowTowY,tf,76,22,this);
			
			
			getExpPre = ComponentUtil.createTextField("获得经验：",130,8,tf,100,22,this);
			var myFilters:Array = new Array();
			var myGlowFilter:GlowFilter = new GlowFilter(0x000000, 1, 2, 2, 10, 1, false, false);
			myFilters.push(myGlowFilter);
			getExpPre.filters = myFilters;
			
//			surebtn = ComponentUtil.createButton("确定",52,93,60,22,this,Style.setRedBtnStyle); // new Button();
			
			tipTf = ComponentUtil.createTextField("",15,90,null,250,22,this);
			tipTf.htmlText = TrainConstant.TRAIN_TIP;
			//小提示：下线后，经验增长不受影响。
			
			fillBtn = ComponentUtil.createButton("充值",218,88,66,25,this,null,addFillListen);
			fillBtn.textColor = 0xffff00;
			//			Style.setDeepRedBtnStyle(fillBtn);
			Style.setRedButtonStyle(fillBtn);
			timer = new Timer(400);
			timer.addEventListener(TimerEvent.TIMER,onflash);
			timer.start();
			
			
			_trainingStopBtn = ComponentUtil.createButton(TrainConstant.TRAINING_STOP,289,88,70,22,this);
			
			_trainingStopBtn.addEventListener(MouseEvent.ROLL_OVER, ontips);
			_trainingStopBtn.addEventListener(MouseEvent.ROLL_OUT, hideTip);
			_trainingStopBtn.addEventListener(MouseEvent.CLICK, onStopTrain);
			
		}
		
		//原始尺寸：长275  宽14
		//示意图 ： 长354  宽18
		
		public function setProgress(value:Number):void
		{
			//bim.scaleX = value;
			getExpPre.text = "获得经验："+ String(int(value * 100)) + "%";
			bim.scaleX = scale_const * value;
		}
		
		private function ontips(e:MouseEvent):void
		{
			
			ToolTipManager.getInstance().show(TrainConstant.STOP_TOOLTIP);
		}
		private function hideTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		//本次训练使用了训练点数：xx，剩余xx点，同时获得了经验xxxx，你确定要停止训练了吗？
		private function onStopTrain(e:MouseEvent):void
		{
			alertStr = "本次训练使用了训练点数：<font color='#ffff00'>"+ usedPoint +
				"</font>，返还<font color='#ffff00'>"+restPoint+
				"</font>点，同时获得了经验<font color='#ffff00'>"+getExp+"</font>，你确定要停止训练了吗？";
			Alert.show(alertStr,"提示：",stopTrain,null,"确定","取消",null);
		}
		private function stopTrain():void
		{
			TrainModule.getInstance().stopTrain();
			_trainingStopBtn.enabled = false;
		}
		
		public function initData(vo:m_trainingcamp_state_toc):void
		{
			usedPoint = vo.training_point;
			if(vo.time_expire!=0)
			{
				var add1:int = 0;
				if(vo.time_expire%10 ==0)
				{
					add1 = 1;
				}else{
					add1 =0;
				}
				ttPoint = int( vo.time_total * vo.training_point/(Math.ceil(vo.time_expire/10 + add1)*10));//vo.time_expire);
				restPoint = ttPoint - vo.training_point;
				getExp = vo.exp_get;
				
			}else{
				
				getExp = vo.exp_get;
				usedPoint = 0;
				ttPoint = restPoint = int(vo.time_total * TrainConstant.costP_hour()/60);
				
			}
			
			//			costPointTF.text = vo.training_point +"点";
			getExpTF.text = String(vo.exp_get);
			progressTF.text = vo.time_expire + "/" + vo.time_total;
			toLevelTF.text = String(vo.level_up);
			costPointTF.text = usedPoint +"点";
			
			
		}
		
		private function onflash(e:TimerEvent):void
		{
			var count:int = timer.currentCount;
			if(count%2==0)
			{
				fillBtn.textColor = 0xFFFF00;
			}else{
				
				fillBtn.textColor = 0xFF9600;  //FFFF00
			}
		}
		
		private function addFillListen(btn:Button):void
		{
			btn.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			btn.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			btn.addEventListener(MouseEvent.CLICK,onFillHandler);
		}
		
		private function onMouseOver(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().show("充值比例 1：10");
		}
		private function onMouseOut(evt:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		private function onFillHandler(evt:MouseEvent):void
		{
			JSUtil.openPaySite();
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			if(timer)
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,onflash);
				timer = null;
			}
		}
	}
}