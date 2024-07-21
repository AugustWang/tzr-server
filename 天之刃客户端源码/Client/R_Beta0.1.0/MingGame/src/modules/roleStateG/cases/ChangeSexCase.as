package modules.roleStateG.cases
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.globals.GameParameters;
	import com.managers.WindowManager;
	import com.utils.JSUtil;
	
	import flash.events.TextEvent;
	
	import modules.roleStateG.RoleStateModule;
	import modules.roleStateG.views.changeSex.ChangeSexView;
	
	import proto.line.m_role2_sex_toc;

	public class ChangeSexCase
	{
		private var view:ChangeSexView;
		public function ChangeSexCase()
		{
			
		}
		
		public function show():void
		{
			if(!view)
			{
				view = new ChangeSexView();
				view.requesFun = RoleStateModule.getInstance().changeSexRequest;
			}
			
			if(!WindowManager.getInstance().isPopUp(view))
				WindowManager.getInstance().popUpWindow(view);
			WindowManager.getInstance().centerWindow(view);
		}
		
		
		private var alertKey:String;
		public function changeSexResult(vo:m_role2_sex_toc):void
		{
			if(vo.succ)
			{
				GlobalObjectManager.getInstance().user.base.sex = vo.sex;
				Alert.show(ChangeSexView.succ,"提示",null,null,"确定","",null,false);
			}else{
				alertKey = Alert.show("<font color='#F6F5CD'>"+vo.reason+"</font>","提示",null,null,"确定","",null,false,true,null,linkHandler);
			}
		}
	
		private function linkHandler(e:TextEvent):void
		{
			if(alertKey!="") {
				Alert.removeAlert(alertKey);
			}
			JSUtil.openPaySite();
		}
		
	}
}


