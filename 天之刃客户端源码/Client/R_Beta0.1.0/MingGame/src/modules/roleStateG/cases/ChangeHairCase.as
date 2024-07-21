package modules.roleStateG.cases
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.managers.WindowManager;
	
	import flash.events.Event;
	
	import modules.broadcast.views.Tips;
	import modules.roleStateG.RoleStateModule;
	import modules.roleStateG.views.changeHair.ChangeHairView;
	import modules.roleStateG.views.changeHair.HairView;
	import modules.roleStateG.views.changeHair.HeadView;
	
	import proto.line.m_role2_hair_toc;
	import proto.line.m_role2_hair_tos;
	import proto.line.m_role2_head_toc;
	import proto.line.m_role2_head_tos;
	
	public class ChangeHairCase
	{
		private var view:ChangeHairView;
		
		public function ChangeHairCase()
		{
		}
		
		public function show():void
		{
			if (view == null)
			{
				view=new ChangeHairView();
				view.addEventListener(HairView.CHANGE_HAIR_EVENT, toChangeHair);
				view.addEventListener(HeadView.CHANGE_FACE_EVENT, toChangeFace);
				view.addEventListener(WindowEvent.OPEN,onWindowOpen);
				view.addEventListener("closeWindow", toCloseWindow);
			}
			WindowManager.getInstance().popUpWindow(view);
			WindowManager.getInstance().centerWindow(view);
		}
		
		private function toCloseWindow(e:Event):void
		{
			if (view != null && view.parent != null)
			{
				view.parent.removeChild(view);
			}
		}
		
		private function onWindowOpen(e:WindowEvent):void{
			view.reset();
		}
		
		private function toChangeHair(e:ParamEvent):void
		{
			RoleStateModule.getInstance().changeHairRequest(e.data as m_role2_hair_tos);
		}
		
		public function onChangeHair(vo:m_role2_hair_toc):void
		{
			if (vo.succ)
			{
				var msg:String;
				if (GlobalObjectManager.getInstance().user.base.sex == 1) {
					msg = "恭喜你成功更换发型，变得更有型了";
				} else {
					msg = "恭喜你成功更换发型，变得更漂亮了";
				}
				Tips.getInstance().addTipsMsg(msg);
				view.reduceHairCardNum();
			}
			else
			{
				Alert.show(vo.reason, "提示", null, null, "确定", "", null, false);
			}
		}
		
		private function toChangeFace(e:ParamEvent):void
		{
			RoleStateModule.getInstance().changeFaceRequest(e.data as m_role2_head_tos);
		}
		
		public function onChangeFace(vo:m_role2_head_toc):void
		{
			if (vo.succ)
			{
				var msg:String;
				if (GlobalObjectManager.getInstance().user.base.sex == 1) {
					msg = "恭喜你成功更换头像，变得更帅了";
				} else {
					msg = "恭喜你成功更换头像，变得更有气质了";
				}
				Tips.getInstance().addTipsMsg(msg);
				view.reduceHeadCardNum();
			}
			else
			{
				Alert.show(vo.reason, "提示", null, null, "确定", "", null, false);
			}
		}
	}
}

