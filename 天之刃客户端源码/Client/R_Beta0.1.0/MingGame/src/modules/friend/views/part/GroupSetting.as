package modules.friend.views.part
{
	import com.common.GlobalObjectManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.events.Event;
	
	import modules.friend.GroupManager;
	import modules.friend.views.vo.GroupSettingVO;
	
	public class GroupSetting extends UIComponent
	{
		public static const ACPTMSG:String = "1";
		public static const ACPTTIPMSG:String = "2";
		public static const STOPMSG:String = "3";
		
		private var acptMsg:CheckBox;
		private var acptTipMsg:CheckBox;
		private var stopMsg:CheckBox;
		private var _groupId:String;
		private var type:int;
		public function GroupSetting()
		{
			super();
			width = 135;
			height = 95;
			acptTipMsg = ComponentUtil.createCheckBox("接受并提示消息",10,0,this);
			acptMsg = ComponentUtil.createCheckBox("接受不提示消息",10,0,this);
			stopMsg = ComponentUtil.createCheckBox("完全阻止群内消息",10,0,this);
			LayoutUtil.layoutVectical(this,5,10);
					
			acptMsg.addEventListener(Event.CHANGE,onAcptChange);
			acptTipMsg.addEventListener(Event.CHANGE,onAcptTipChange);
			stopMsg.addEventListener(Event.CHANGE,onStopMsgChange);
			
			Style.setRectBorder(this);
		}
		
		private function onAcptChange(eveny:Event):void{
			acptMsg.setSelected(true);
			acptTipMsg.setSelected(false);
			stopMsg.setSelected(false);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			GroupManager.setGroupSetting(_groupId,false,true,false);
			writeLocal();
		}
		
		private function onAcptTipChange(eveny:Event):void{
			acptMsg.setSelected(false);
			acptTipMsg.setSelected(true);
			stopMsg.setSelected(false);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			GroupManager.setGroupSetting(_groupId,true,false,false);
			writeLocal();
		}
		
		private function onStopMsgChange(eveny:Event):void{
			acptMsg.setSelected(false);
			acptTipMsg.setSelected(false);
			stopMsg.setSelected(true);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			GroupManager.setGroupSetting(_groupId,false,false,true);
			writeLocal();
		}
		
		private function writeLocal():void{
			var userId:int = GlobalObjectManager.getInstance().user.attr.role_id;
			var key:String = userId +"_"+ "GS"+"_"+type;
			var value:String = (acptTipMsg.selected ? 1 : 0)+"_"+(acptMsg.selected ? 1 : 0)+"_"+(stopMsg.selected ? 1 : 0);
			GlobalObjectManager.getInstance().addObject(key,value,true);
		}
		
		public function setGroup(id:String,type:int):void{
			this._groupId = id;
			this.type = type;
			var groupSetting:GroupSettingVO = GroupManager.getGroupSetting(_groupId,type);
			if(groupSetting){
				acptMsg.setSelected(groupSetting.acptMsg);
				acptTipMsg.setSelected(groupSetting.acptTipMsg);
				stopMsg.setSelected(groupSetting.stopMsg);
			}
		}
	}
}