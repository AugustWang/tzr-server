package modules.Activity.view.itemRender
{
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.Activity.ActivityConstants;
	import modules.common.utils.ComponentUtil;
	
	import proto.common.p_actpoint_info;
	
	public class ActivityListItem extends UIComponent
	{
		private var activityName:TextField;
		private var progressTxt:TextField;
		
		public function ActivityListItem()
		{
			super();
			this.width = 174;
			this.height = 25;
			
			initView();
		}
		private function initView():void
		{
			var tf:TextFormat = new TextFormat("Tahoma",12,0xACDC91);
			activityName = ComponentUtil.createTextField("",2,2,tf,99,22,this);
			
			progressTxt = ComponentUtil.createTextField("",135,2,tf,40,22,this);
		}
		
		
		override public function set data(value:Object):void{
			super.data = value;
			var act:p_actpoint_info = value as p_actpoint_info;
			var index:int = transIdToIndex(act.id);
			activityName.text = ActivityConstants.ACTION_NAMES[index].name;   // id  从0 开始。
			progressTxt.htmlText = "<font color='#ffff00'>"+act.cur_ap + "</font>/" + act.max_ap;
		}
		
		private function transIdToIndex(id:int):int
		{
//			//id:1001  - 1008
			var idx:int = int(id - 1001) ;
			return idx;
		}
	}
}

