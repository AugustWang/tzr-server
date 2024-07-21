package modules.system.views
{
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.system.SystemModule;
	
	import proto.line.m_system_fcm_toc;

	public class Anti_PopUpWindow extends BasePanel
	{
		private var content:TextField;
		private var tianxieBtn:Button;
		private var weichengnianBtn:Button;
		private var onlineTime:int;
		
		public function Anti_PopUpWindow()
		{
			initUI();
		}
		
		public function setOnlineTime(onlineTime:int):void {
			this.onlineTime = onlineTime;
			content.htmlText = "账号已纳入防沉迷系统，是否需要进行身份信息填写。你已持续在线：" 
				+ timeFormat(this.onlineTime)
				+ "，" + timeFormat(3600 * 3 - this.onlineTime)  + 
				" 后将被强制下线";
		}
		
		private function initUI():void{
			this.title = "防沉迷系统";
			this.showCloseButton = false;
			this.showHelpButton = false;
			this.width = 328;
			this.height = 216;
			this.titleAlign=2;
			addContentBG(36);
			
			content = ComponentUtil.createTextField("",30,20,new TextFormat("宋体",14,0xFFFF00),270,90,this);
			content.htmlText = "账号已纳入防沉迷系统，是否需要进行身份信息填写。你已持续在线：" 
				+ timeFormat(this.onlineTime)
				+ "，" + timeFormat(3600 * 3 - this.onlineTime)  + 
				" 后将被强制下线";
			content.multiline=true;
			content.wordWrap=true;
			
			tianxieBtn = new Button();
			tianxieBtn.label = "填写";
			tianxieBtn.addEventListener(MouseEvent.CLICK,tianxieBtnClickHandler);
			tianxieBtn.x = 10;
			tianxieBtn.y = 142;
			addChild(tianxieBtn);
			weichengnianBtn = new Button();
			weichengnianBtn.label = "我未成年";
			weichengnianBtn.addEventListener(MouseEvent.CLICK,weichengnianBtnClickHandler);
			weichengnianBtn.x = 216;
			weichengnianBtn.y = 142;
			addChild(weichengnianBtn);
		}
		
		//毫秒数转天/小时/分钟
		public function timeFormat(time:Number):String{
			var minutes:String = (int(time/60%60)).toString(); 
			var hours:String = (int(time/60/60)).toString(); 
			if(int(hours) == 0)return minutes + '分钟';
			if(int(hours) != 0 && int(minutes)== 0)return hours + '小时';
			return hours + '小时' + minutes + '分钟';
		}
		
		private function createBorder(w:Number,h:Number,x:int,y:int):UIComponent{
			var border:UIComponent = new UIComponent();
			Style.setBorderSkin(border);
			border.x=x;
			border.y=y;
			border.width = w;
			border.height = h;
			border.mouseChildren=false;
			border.mouseEnabled=false;
			addChild(border);
			return border;
		}
		
		private function tianxieBtnClickHandler(event:MouseEvent):void{
			var vo:m_system_fcm_toc = new m_system_fcm_toc();
			vo.info = "";
			vo.total_time = 0;
			vo.remain_time = 0;
			SystemModule.getInstance().openFCMWindow(vo);
			close();
		}
		
		private function weichengnianBtnClickHandler(event:MouseEvent):void{
			close();
			Alert.show("你的账号未经防沉迷认证！","认证信息",null,null,"关闭","",null,false);
		}
		
		private function close():void{
			if(this.parent != null){
				WindowManager.getInstance().closeDialog(this);
			}
		}
	}
}