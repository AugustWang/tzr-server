package modules.broadcast.views
{
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	
	import modules.chat.ChatModule;
	import modules.system.Anti_addiction;
	import modules.system.SystemModule;
	
	import proto.line.m_system_fcm_toc;
	
	public class PopupLabaWindow extends BasePanel
	{
		private var labaList:LabaList;
		public function PopupLabaWindow()
		{
			super();
			this.width = 280;
			this.height = 330;
			title = "喇叭记录";
			initUI();
		}
		
		private function initUI():void
		{
			var textBG:UIComponent =  ComponentUtil.createUIComponent(8,0,width - 16,height - 54,Style.getPanelContentBg());
			addChild(textBG);
			
			labaList = new LabaList();
			labaList.x = labaList.y = 2;
			labaList.width = textBG.width - 4;
			labaList.height = textBG.height - 12;
			textBG.addChild(labaList);
		}
		
		public function appendTxt(msg:String,role:Object):void
		{
			labaList.pushMessage(msg,role);
		}
		
		
		public function setDatas(arr:Array,roles:Array):void
		{
			if(!arr)
			{
				return;
			}
			
			for(var i:int=0;i<arr.length;i++)
			{
				labaList.pushMessage(arr[i],roles[i]);
			}
			
		}
		
	}
}