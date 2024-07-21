package com.scene.sceneKit {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;

	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import modules.factionsWar.FactionWarDataManager;
	import modules.scene.SceneDataManager;

	public class ReliveView extends BasePanel {
		private var town:Button;
		private var here:Button;
		private var hereFull:Button;
		private var handler:Function;
		private var restTime:int=120;
		public var _cost:int;
		public var succReLiveCost:String;

		public function ReliveView(key:String=null) {
			super(key);
			initView();
		}


		public function initView():void {
			this.title="请选择复活方式";
			this.showCloseButton=false;
			this.showHelpButton=false;
			this.width=300;
			this.height=200;

			var bg:UIComponent=new UIComponent();
			bg.x=5;
			bg.width=290;
			bg.height=166;
			Style.setNewBorderBgSkin(bg);
			addChild(bg);

//			ComponentUtil.createTextField("请选择复活方式：", 10, 10, null, 120, 22, this);
			town=ComponentUtil.createButton("回城复活（免费）", 30, 20, 232, 26, this);
			here=ComponentUtil.createButton("原地复活（倒计时120秒）", 30, 65, 232, 26, this);
			hereFull=ComponentUtil.createButton("原地健康复活", 30, 110, 232, 26, this);
			town.setToolTip("回城复活，生命力和内力值全满");
			here.setToolTip("在原地复活，恢复20%生命值和内力值，需要等待120秒");
			town.addEventListener(MouseEvent.CLICK, onTown);
			here.addEventListener(MouseEvent.CLICK, onHere);
			hereFull.addEventListener(MouseEvent.CLICK, onHereFull);
		}

		private function delayButton():void {
			town.enabled=true;
			hereFull.enabled=true;
			if (SceneDataManager.isRobKingMap == true || SceneDataManager.isBaoZangMap == true || ((SceneDataManager.isCapital || SceneDataManager.isPingJiang) && FactionWarDataManager.phase == 2)) {
				hereFull.enabled=false;
			}
		}

		public function setup(func:Function, money:int):void {
			handler=func;
			_cost=money;
			hereFull.setToolTip("立即在原地复活，生命值和内力值全满，需要花费" + MoneyTransformUtil.silverToOtherString(_cost));
		}

		public function set cost(value:int):void {
			_cost=value;
			hereFull.setToolTip("立即在原地复活，生命值和内力值全满，需要花费" + MoneyTransformUtil.silverToOtherString(_cost));
		}

		public function startTime():void {
			restTime=119;
			here.label="原地复活（倒计时119秒）";
			here.enabled=false;
			town.enabled=false;
			// 大明宝藏以及国战期间不能点原地复活、以及王座争霸战
			if (SceneDataManager.isRobKingMap == true || SceneDataManager.isBaoZangMap == true || ((SceneDataManager.isCapital || SceneDataManager.isPingJiang) && FactionWarDataManager.phase == 2)) {
				hereFull.enabled=false;
			}
			if (SceneDataManager.isBaoZangMap == true) {
				town.label="安全复活（免费）";
			} else {
				town.label="回城复活（免费）";
			}
			LoopManager.setTimeout(delayButton, 2000);
			LoopManager.addToSecond(this, onTimer);
		}

		public function remove():void {
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
		}

		private function onTimer():void {
			restTime--;
			if (restTime >= 0) {
				here.label="原地复活（倒计时" + restTime + "秒）";
			} else {
				here.enabled=true;
				here.label="原地复活（免费）";
			}
		}

		private function onTown(e:MouseEvent):void {
			handler.apply(null, [3]);
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
			LoopManager.removeFromSceond(this);
		}

		private function onHere(e:MouseEvent):void {
			handler.apply(null, [2]);
			if (this.parent != null) {
				this.parent.removeChild(this);
			}
			LoopManager.removeFromSceond(this);
		}

		private function onHereFull(e:MouseEvent):void {
			var allMoney:int=GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().user.attr.silver_bind;
			var hasMoney:Boolean=allMoney >= _cost ? true : false;
			if (hasMoney == true) {
				handler.apply(null, [1]);
				LoopManager.removeFromSceond(this);
				succReLiveCost=MoneyTransformUtil.silverToOtherString(_cost);
				if (this.parent != null) {
					this.parent.removeChild(this);
				}
			} else {
				Alert.show("银子不足，原地健康复活需" + MoneyTransformUtil.silverToOtherString(_cost), "银子不足", null, null, "确定", "", null, false);
			}
		}
	}
}