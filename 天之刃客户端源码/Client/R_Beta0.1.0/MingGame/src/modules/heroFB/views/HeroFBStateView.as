package modules.heroFB.views
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.heroFB.HeroFBDataManager;
	import modules.heroFB.HeroFBModule;
	
	import proto.common.p_hero_fb_barrier;
	import proto.common.p_role_hero_fb_info;
	import proto.line.m_hero_fb_state_toc;
	
	public class HeroFBStateView extends Sprite
	{
		private var _state:TextField;
		private var _timeUsed:TextField;
		private var _selfBest:TextField;
		private var _giveUpBtn:Button;	
		private var _timeInt:int;
		private var _bestTime:int = 0;
		private var _pass:Boolean = false;
		private var _nextBarrierBtn:Button;
		private var _nextBarrierSprite:Sprite;
		
		public function HeroFBStateView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			this.x = GlobalObjectManager.GAME_WIDTH - 210;
			this.y = (GlobalObjectManager.GAME_HEIGHT - GlobalObjectManager.GAME_HEIGHT) / 2 + 190;
			
			var bg:Sprite = Style.getBlackSprite(210, 83);
			addChild(bg);
			
			_timeUsed = ComponentUtil.createTextField("当前已用时间：10'10''10", 10, 2, null, 150, 20, bg);
			_selfBest = ComponentUtil.createTextField("个人最佳成绩：无", 10, 19, null, 150, 20, bg);
			
			var repeatBtn:Button = ComponentUtil.createButton("重复本关", 4, 53, 66, 25, bg);
			
			_nextBarrierSprite = new Sprite;
			_nextBarrierSprite.x = 74;
			_nextBarrierSprite.y = 53;
			bg.addChild(_nextBarrierSprite);
			_nextBarrierBtn = ComponentUtil.createButton("进入下关", 0, 0, 66, 25, _nextBarrierSprite);
			_giveUpBtn = ComponentUtil.createButton("结束挑战", 144, 53, 66, 25, bg);
			repeatBtn.addEventListener(MouseEvent.CLICK, repeatBtnClickHandler);
			_nextBarrierBtn.addEventListener(MouseEvent.CLICK, nextBtnClickHandler);
			_giveUpBtn.addEventListener(MouseEvent.CLICK, giveUpHandler);		
		}
		
		/**
		 * @doc 挑战下一关
		 */
		
		private function nextBtnClickHandler(evt:Event):void
		{
			if (!_pass) {
				Alert.show("当前副本尚未完成，确定要挑战下一关吗？", "提示", yesHandler);
			} else {
				yesHandler();
			}
			
			function yesHandler():void
			{
				HeroFBModule.getInstance().enterNextBarrier();
			}
		}
		
		/**
		 * @doc 重复本关挑战
		 */
		
		private function repeatBtnClickHandler(evt:Event):void
		{			
			if (!_pass) {
				Alert.show("当前副本尚未完成，确定要重新挑战本关吗？", "提示", yesHandler);
			} else {
				yesHandler();
			}
			
			function yesHandler():void
			{
				HeroFBModule.getInstance().repeatBarrier();
			}
		}
		
		public function initData(fbInfo:p_role_hero_fb_info, barrierId:int):void
		{
			_timeInt = 0;
			LoopManager.addToTimer(this, onTimer);
			
			_selfBest.text = "个人最佳成绩：无";
			var recordAry:Array = fbInfo.fb_record;
			for (var i:int=0; i < recordAry.length; i ++) {
				var record:p_hero_fb_barrier = recordAry[i] as p_hero_fb_barrier;
				if (record.barrier_id == barrierId) {
					if (record.time_used > 0) {
						_bestTime = record.time_used;
						_selfBest.text = "个人最佳成绩：" + HeroFBModule.getInstance().formatTime(_bestTime);
						break;
					}
				}
			}
			
			_nextBarrierBtn.enabled = true;
			if (fbInfo.progress <= barrierId) {
				_nextBarrierBtn.enabled = false;
				_nextBarrierSprite.addEventListener(MouseEvent.ROLL_OVER, showNextBarrierBtnTip);
				_nextBarrierSprite.addEventListener(MouseEvent.ROLL_OUT, hideNextBarrierBtnTip);
			}
		}
		
		private function showNextBarrierBtnTip(evt:Event):void
		{
			ToolTipManager.getInstance().show("你尚未击败过当前关卡，无法进行下一关", 0);
		}
		
		private function hideNextBarrierBtnTip(evt:Event):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function setData(vo:m_hero_fb_state_toc):void
		{
			_timeInt = vo.time_used;
			_pass = false;
			_timeUsed.text = "本关所用时间：" + HeroFBModule.getInstance().formatTime(vo.time_used);
			_giveUpBtn.label = "结束挑战";
			if (vo.remain_monsters == 0) {
				_pass = true;
				LoopManager.removeFromTimer(this);
				_giveUpBtn.label = "返回入口";
				
				if (vo.time_used < _bestTime || _bestTime == 0) {
					_selfBest.text = "个人最佳成绩：" + HeroFBModule.getInstance().formatTime(vo.time_used);
				}
				
				_nextBarrierBtn.enabled = true;
				_nextBarrierSprite.removeEventListener(MouseEvent.ROLL_OVER, showNextBarrierBtnTip);
				_nextBarrierSprite.removeEventListener(MouseEvent.ROLL_OUT, hideNextBarrierBtnTip);
			}
		}
		
		public function onStageResize():void
		{
			this.x = GlobalObjectManager.GAME_WIDTH - 210;
			this.y = (GlobalObjectManager.GAME_HEIGHT - GlobalObjectManager.GAME_HEIGHT) / 2 + 190;
		}
		
		private function onTimer():void
		{
			_timeInt += 60;
			_timeUsed.text = "本关所用时间：" + HeroFBModule.getInstance().formatTime(_timeInt);
		}
		
		private function giveUpHandler(e:Event):void
		{
			var str:String = "";
			if (_pass) {
				var barrier:int = HeroFBModule.getInstance().getCurrentBarrier();
				//var boss:MonsterType = HeroFBDataManager.getInstance().getBossVoByBarrierId(barrier);
				str += "点击“确定”可以返回副本入口";
			}
			else str += "尚未完成本关挑战，你确定要放弃挑战吗？"
			Alert.show(str, "提示", yesHandler);
			
			function yesHandler():void
			{
				HeroFBModule.getInstance().heroFBQuit(0);
			}
		}
	}
}