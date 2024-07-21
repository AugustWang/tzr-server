package com.common.cursor.cursors
{
	import com.common.cursor.BaseCursor;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.DragItem;
	import com.globals.GameConfig;
	
	import flash.events.MouseEvent;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	public class EnduranceCursor extends BaseCursor
	{
		public function EnduranceCursor()
		{
			super();
			setMouse("Mouse_selectTarget");
		}
		
		override public function normalHandler():void{
			mc.gotoAndStop(0);
			CursorManager.getInstance().enabledCursor = false;
		}
		
		override public function downHandler(event:MouseEvent):void{
			var target:DragItem = event.target as DragItem;
			if(target && target.data is EquipVO){
				var targetName:String = target.getItemName();
				if(targetName == DragConstant.PACKAGE_ITEM || targetName == DragConstant.EQUIP_ITEM || targetName == DragConstant.STOVE_ITEM){
					var useGoods:BaseItemVO = data as BaseItemVO;
					PackageModule.getInstance().useItem(useGoods.oid,1,target.data.oid);
				}else{
					BroadcastSelf.logger("请点击需要增强属性的装备!");
				}
			}else{
				BroadcastSelf.logger("请点击需要增强属性的装备!");
			}	
			CursorManager.getInstance().enabledCursor = true;
			CursorManager.getInstance().hideCursor(CursorName.ENDURANCE);
		}
	}
}