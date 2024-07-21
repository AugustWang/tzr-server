package modules.collect.views {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.WindowManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneUnit.baseUnit.things.resource.SourceManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import modules.collect.CollectModule;
	import modules.scene.SceneDataManager;


	public class CollectBar extends UIComponent {
		private var bg:Bitmap;
		private var bar:Bitmap;
		private var _currentCount:int;
		private var _count:int;
		private var _time:Timer
		private var title:TextField;
		public var barTitle:String="采集中...";

		public function CollectBar() {
		}

		public function initView():void {
			bg=Style.getBitmap(GameConfig.T1_VIEWUI,'collect_bar_bg');
			bar=Style.getBitmap(GameConfig.T1_VIEWUI,'collect_bar');
			bar.x=17;
			bar.y=20;

			addChild(bg);
			addChild(bar);

			title=ComponentUtil.createTextField(barTitle, 69, 1, new TextFormat("宋体", 12, 0xFFFFFF), 270, 90, this);
			title.filters=[new GlowFilter(0x000000, 1, 2, 2, 200)]


		}

		
		public function updata($time:int,typeid:int = 0):void {
			if (SceneDataManager.mapData.map_id == 10500) {
				barTitle="挖宝中...";
			} else {
				barTitle="采集中...";
			}
			if(CollectModule.catchTypeIds.indexOf(typeid) != -1){
				barTitle="捕捉中...";
				//加载第一个技能特效
				SourceManager.getInstance().loadFristSkillEffect();
			}
			bar.scaleX=0;
			_currentCount=0;
			_count=$time;
			//_time.reset();
			//_time.start();
			LoopManager.addToSecond(this, timerHandler);
			onTimerUpdata();
			//TweenMax.to(bar,$time,{scaleX:1,ease: Linear.easeNone,onComplete: onTimerComplete,onUpdate:onTimerUpdata});
			//ease: Linear.easeNone, onUpdate: onMoving, onComplete: moveNextTile
		}

		private function timerHandler():void {
			_currentCount++;
			bar.scaleX=Math.min(_currentCount, _count) / (_count + 1);
			onTimerUpdata();
			if (_currentCount > _count + 3)
				remove(true);
		}

		public function onTimerUpdata():void {
			title.text=barTitle + int(bar.scaleX * 100) + "%";
			title.x=(162 - title.textWidth) / 2;
		}

		public function remove(complete:Boolean):void {
			if (complete) {
				bar.scaleX=1;
				onTimerUpdata();
			}
			LoopManager.removeFromSceond(this);
			setTimeout(removeDelay, 300);
		}

		private function removeDelay():void {
			try {
				WindowManager.getInstance().removeWindow(this);
			} catch (e:Error) {

			}
		}
	}
}