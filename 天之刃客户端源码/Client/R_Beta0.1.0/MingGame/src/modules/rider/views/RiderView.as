package modules.rider.views
{
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.core.UIComponent;
	
	/**
	 *坐骑视图 
	 * @author yechengcong
	 * 
	 */	
	public class RiderView extends UIComponent
	{
		
//		[Embed("assets/skin.swf",symbol="WindowBg")]
//		private var bg:Class;
		
		public function RiderView()
		{
			setupUI();
		}
		
		private var _riderPlane:Panel;
		private function setupUI():void
		{
			_riderPlane = new Panel();
			_riderPlane.width = 300;
			_riderPlane.height= 350;
			_riderPlane.title = "坐骑";
//			_riderPlane.bgSkin = new Skin(bg);
			
			addChild(_riderPlane);
		}
		
		public function get riderPlane():Panel
		{
			return _riderPlane;
		}
	}
}