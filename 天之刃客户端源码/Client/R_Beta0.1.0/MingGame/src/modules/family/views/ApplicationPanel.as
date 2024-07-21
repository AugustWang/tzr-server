package modules.family.views
{
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.family.FamilyItemEvent;
	import modules.family.FamilyModule;
	import modules.family.views.items.ApplicationItem;
	
	import proto.common.p_family_request;

	/**
	 * 申请加入门派面板 
	 * @author Administrator
	 * 
	 */	
	public class ApplicationPanel extends BasePanel
	{
		private var list:DataGrid;
		private var allRefuseBtn:Button;
		private var closeBtn:Button;
		private var applications:Array;
		public function ApplicationPanel(key:String=null)
		{
			super(key);
			initView();
		}
		
		private function initView():void{
			title = "查看申请列表";
			
			width = 408;
			height = 320;
			
			var backBg:Sprite = Style.getBlackSprite(390,250);
			backBg.x = 10;
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			list = new DataGrid();
			list.itemRenderer = ApplicationItem;
			list.x = 2;
			list.y = 2;
			list.width = 386;
			list.height = 247;
			list.addColumn("玩家",100);
			list.addColumn("等级",100);
			list.addColumn("操作",190);
			list.itemHeight = 25;
			list.pageCount = 9;
			list.verticalScrollPolicy = ScrollPolicy.ON;
			list.list.addEventListener(FamilyItemEvent.REMOVE_ITEM,onRemoveItem);
			backBg.addChild(list);
			
			allRefuseBtn = ComponentUtil.createButton("全部拒绝",85,255,80,25,this);
			allRefuseBtn.addEventListener(MouseEvent.CLICK,onRefuseHandler);
			
			closeBtn = ComponentUtil.createButton("关闭",240,255,60,25,this);
			closeBtn.addEventListener(MouseEvent.CLICK,onCloseHandler);
			
		}
		
		public function setApplications(applications:Array):void{
			this.applications = applications;
			this.list.dataProvider = applications;
		}
		
		private function onRemoveItem(event:FamilyItemEvent):void{
			var del:p_family_request = event.data as p_family_request;
			for(var i:int=0;i<applications.length;i++){
				var p:p_family_request = applications[i];
				if(del.role_id == p.role_id){
					break;
				}
			}
			applications.splice(i,1);
			this.list.dataProvider = applications;
		}
		
		private function onRefuseHandler(event:MouseEvent):void{
			for each(var p:p_family_request in applications){
				FamilyModule.getInstance().refuseJoinFamily(p.role_id);
			}
			applications.splice(0,applications.length);
			this.list.dataProvider = applications;
		}
		
		private function onCloseHandler(event:MouseEvent):void{
			closeWindow();
		}
	}
}