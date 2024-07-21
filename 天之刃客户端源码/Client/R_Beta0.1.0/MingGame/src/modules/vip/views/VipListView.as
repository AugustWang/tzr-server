package modules.vip.views
{
	import com.components.DataGrid;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import proto.line.m_vip_list_toc;
	
	public class VipListView extends UIComponent
	{	
		private var _dg:DataGrid;
		
		public function VipListView()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			x = 4;
			y = 4;
			width = 535;
			height = 401;
			Style.setBorderSkin(this);
			_dg = new DataGrid;
			_dg.x = 2;
			_dg.y = 2;
			_dg.width = 531;
			_dg.height = 397;
			_dg.itemHeight = 27;
			_dg.itemRenderer = VipListRender;
			_dg.pageCount = 14;
			_dg.verticalScrollPolicy = ScrollPolicy.AUTO;
			addChild(_dg);
			
			_dg.addColumn("头像", 63);
			_dg.addColumn("名称", 106);
			_dg.addColumn("等级", 62);
			_dg.addColumn("门派", 122);
			_dg.addColumn("操作", 172);
		}
		
		public function setData(list:Array):void
		{
			_dg.dataProvider = list;
		}
	}
}