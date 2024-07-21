package modules.roleStateG.cases
{
	import com.managers.WindowManager;
	import modules.roleStateG.views.details.OtherDetailView;
	import proto.line.m_role2_getroleattr_toc;
	
	public class RoleOtherDetailCase
	{
		private var view:OtherDetailView;
		
		public function RoleOtherDetailCase()
		{
		}
		
		private function initView():void
		{
			if (view == null)
			{
				view=new OtherDetailView;
			}
		}
		
		public function show(vo:m_role2_getroleattr_toc):void
		{
			initView();
			view.update(vo);
			view.centerOpen();
		}
		
	}
}