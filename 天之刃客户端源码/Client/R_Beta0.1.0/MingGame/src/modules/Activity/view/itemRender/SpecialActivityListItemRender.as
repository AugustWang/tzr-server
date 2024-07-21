package modules.Activity.view.itemRender {
	import com.common.GlobalObjectManager;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import modules.Activity.view.SpecialActivityView;
	import modules.Activity.ActivityModule;
	import modules.Activity.ActivityConstants;
	
	import proto.line.m_special_activity_detail_tos;
	
	public class SpecialActivityListItemRender extends UIComponent {
		private var btnSpecialActivity:ToggleButton;
		private static var btnCurSpecialActivity:ToggleButton;
		private var txtActivityList:TextField;
		public function SpecialActivityListItemRender() {
			super();
			initView();
		}
		
		private function initView():void {
			btnSpecialActivity=ComponentUtil.createToggleButton("", 0, 0, 95, 27, this);
			btnSpecialActivity.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			this.validateNow();
		}     
		
		override public function set data(value:Object):void {
			
			super.data=value;
			var vo:int=value as int;
			btnSpecialActivity.label= ActivityConstants.SPECIAL_ACTIVITY_KEY_LIST[vo];
			btnSpecialActivity.data = vo;
			//是否存在详细信息选择  
			if(!SpecialActivityView.curSpecialActivityKey){
				SpecialActivityView.curSpecialActivityKey=vo;
				btnCurSpecialActivity = btnSpecialActivity;
				btnCurSpecialActivity.selected=true;
			}
			else if(SpecialActivityView.curSpecialActivityKey==vo){
				if(btnCurSpecialActivity)
					btnCurSpecialActivity.selected=false;
				btnCurSpecialActivity = btnSpecialActivity;
				btnCurSpecialActivity.selected=true;
			}
			this.validateNow();
		}
		
		private function onMouseClickHandler(e:MouseEvent):void{
			if (btnCurSpecialActivity != ToggleButton(e.currentTarget)) {
				if(btnCurSpecialActivity)
					btnCurSpecialActivity.selected=false;
				btnCurSpecialActivity=ToggleButton(e.currentTarget);
				btnCurSpecialActivity.selected=true;
				var key:int=btnCurSpecialActivity.data as int;
				ActivityModule.getInstance().requestGetSpclActDetail(key);
			}			
		}
		
		override public function dispose():void {
			super.dispose();
			while (this.numChildren > 0) {
				var displayobj:DisplayObject=this.getChildAt(0);
				removeChild(displayobj);
				displayobj=null;
			}
			
		}
	}
}


