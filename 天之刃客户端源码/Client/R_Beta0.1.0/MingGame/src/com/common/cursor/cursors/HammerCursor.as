package com.common.cursor.cursors {
	import com.common.GlobalObjectManager;
	import com.common.cursor.BaseCursor;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.utils.MoneyTransformUtil;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	import modules.broadcast.views.Tips;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.EquipVO;

	import proto.common.p_role;

	public class HammerCursor extends BaseCursor {
		public function HammerCursor() {
			super();
			setMouse("Mouse_cuiZi");
		}

		override public function normalHandler():void {
			CursorManager.getInstance().enabledCursor=false;
			mc.gotoAndStop(0);
		}

		override public function stop():void {
			mc.gotoAndStop(0);
			clickTarget=null;
		}

		private var clickTarget:DisplayObject;

		override public function downHandler(event:MouseEvent):void {
			mc.gotoAndStop(9);
			clickTarget=event.target as DisplayObject;
			var clickUILayer:Boolean=LayerManager.uiLayer.contains(clickTarget);
			var clickWLayer:Boolean=LayerManager.windowLayer.contains(clickTarget);
			if (clickTarget && (clickUILayer || clickWLayer)) {
				var target:DragItem=clickTarget as DragItem;
				if (target) {
					var equipVO:EquipVO=target.data as EquipVO;
				}
				if (equipVO) {
					var targetName:String=target.getItemName();
					if (targetName == DragConstant.PACKAGE_ITEM || targetName == DragConstant.EQUIP_ITEM || targetName == DragConstant.STOVE_ITEM) {
						var user:p_role=GlobalObjectManager.getInstance().user;
						if (equipVO.current_endurance == equipVO.endurance) {
							Tips.getInstance().addTipsMsg("【" + equipVO.name + "】不需要修理！！");
						} else {
							var needMoney:Number=equipVO.getFixPrice();
							if (user.attr.silver > needMoney || user.attr.silver_bind > needMoney) {
								PackageModule.getInstance().fixEquip(target.data.oid);
							} else {
								var money:String=MoneyTransformUtil.silverToOtherString(needMoney);
								Tips.getInstance().addTipsMsg("修理【" + equipVO.name + "】需要" + money + "，你的银子不足！");
							}
						}
					} else {
						hide();
					}
				} else {
					hide();
				}
			} else {
				hide();
			}
		}

		private function hide():void {
			CursorManager.getInstance().hideCursor(CursorName.HAMMER);
			CursorManager.getInstance().enabledCursor=true;
			clickTarget=null;
		}

		override public function upHandler(event:MouseEvent):void {
			mc.gotoAndStop(1);
		}
	}
}