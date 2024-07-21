package modules.roleStateG.views.items
{
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	import modules.buff.BuffModule;
	import modules.system.SystemConfig;
	
	import proto.common.p_actor_buf;
	
	public class BuffItem extends UIComponent
	{
		private var _data:p_actor_buf;
		private var _buffId:int;
		private var _buffType:int;
		private var _endTime:int;
		public var remainTime:int;
		private var rollFlag:Boolean;
		public var imageUrl:String;
		public var tooltipDec:String;
		public var callback:Function;
		
		public function get buff():p_actor_buf{
			if(_data != null){
				return _data as p_actor_buf;
			}
			return new p_actor_buf;
		}
		
		public function BuffItem(vo:p_actor_buf,showNumFlag:Boolean=false)
		{
			_data = vo;
			_buffId = vo.buff_id;
			_buffType = vo.buff_type;
			_endTime = vo.end_time;
			remainTime = vo.remain_time; 
			_showNumFlag = showNumFlag;
			imageUrl = BuffModule.createImageUrl(vo.buff_id);
			tooltipDec = BuffModule.createTooltip(vo.buff_id,vo.value);
			setupUI();
			this.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
			this.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
		}
		
		public function updata(vo:p_actor_buf):void{
			_data = vo;
			_endTime = vo.end_time;
		}
		
		private function onRollOver(event:MouseEvent):void{
			rollFlag = true;
			addEventListener(MouseEvent.ROLL_OUT,onRollOut);
			createToolTip();
		}
		
		private function createToolTip():void{
			createHtml();
		}
		
		private function createHtml():void{
			var p:Point = new Point(x+20,y);
			p = parent.localToGlobal(p);
			
			ToolTipManager.getInstance().show(tooltipUpdata(),0,p.x,p.y);
		}
		
		private function tooltipUpdata():String{
			var s:String = ''
			if(_showNumFlag){
				s =  tooltipDec + '<font color="#FFFFFF">剩余时间:'+timeFormat(remainTime) + '</font>';
			}else{
				s =  tooltipDec
			}
			return s;
		}
		
		public function timeFormat(time:Number):String{
			//time = time*0.001
			var s:String = '';
			var seconds:String =  (int(time%60)).toString(); 
			var minutes:String = (int(time/60%60)).toString(); 
			var hours:String = (int(time/60/60)).toString(); 
			if(int(seconds) <   10){seconds =   "0"   +   seconds;} 
			if(int(minutes) <   10){ minutes =   "0"   +   minutes;} 
			if(int(hours)<   10) {hours =   "0"   +   hours;}
			if(int(hours) > 0) s = s + hours + '小时';
			if(int(minutes) > 0) s = s + minutes + '分钟'
			return  s = s + seconds + '秒';
		}
		
		private function onRollOut(event:MouseEvent):void{
			rollFlag = false;
			removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
			ToolTipManager.getInstance().hide();
		}
		
		private var _buffIcon:Image;
		private var _numTF:TextField;
		private var _showNumFlag:Boolean;
		private var _timer:Timer;
		private function setupUI():void
		{
			if(remainTime != 0)
			{
				_timer = new Timer(1000);
				_timer.addEventListener(TimerEvent.TIMER,onTimerHandler);
				_timer.start();
			}
			_buffIcon = new Image();
			_buffIcon.x = 0;
			_buffIcon.y = 0;
			_buffIcon.width = 20;
			_buffIcon.height = 20;
			if(imageUrl == BuffIconBox.BUFF_PATH){
				//_buffIcon.source = ResUrlManager.instance.getResUrl("buff","default_buff");
			}else{
				_buffIcon.source = imageUrl;
			}
			addChild(_buffIcon);
		}
		
		private function onTimerHandler(evt:TimerEvent):void
		{
			remainTime = _endTime - SystemConfig.serverTime;
			if(_showNumFlag)
			{
				//_numTF.text = remainTime.toString();
				if(rollFlag){
					var p:Point = new Point(x+20,y);
					if( parent != null )p = parent.localToGlobal(p);
					
					ToolTipManager.getInstance().show(tooltipUpdata(),0,p.x,p.y);
				}
			}
			if(remainTime <= 0 && this.parent)
			{
				if( callback != null )callback(_data.buff_id);
				if( parent != null )parent.removeChild(this);
				this.dispose();
			}
		}
		
		private function getTextFormat():TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.size = 12;
			textFormat.color = 0x0000FF;
			textFormat.bold = true;
			textFormat.align = TextFormatAlign.CENTER;
			textFormat.letterSpacing = 0;
			return textFormat;
		}
		
		override public function dispose():void
		{
			
			if(_buffIcon)
			{
				removeChild(_buffIcon);
				//_buffIcon.dispose();
			}
			
			if(_numTF)
			{
				removeChild(_numTF);
				_numTF = null;
			}
			
			if(_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER,onTimerHandler);
			}
			super.dispose();
		}
		
		public function get buffId():int
		{
			return _buffId;
		}
		
		public function get buffEndTime():int
		{
			return _endTime;
		}
	}
}