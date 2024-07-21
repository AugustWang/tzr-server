package modules.broadcast.views
{
	import com.components.menuItems.MenuBar;
	import com.components.menuItems.MenuItemData;
	import com.ming.events.ItemEvent;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.tile.Pt;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import modules.broadcast.BroadCastConstant;
	import modules.broadcast.BroadcastModule;
	
	
	public class KillAttackMenu
	{
		
		public static const SEND_TO_EVENT:String="SEND_TO_EVENT";
		public static const WALK_TO_EVENT:String = "WALK_TO_EVENT";
		
		private var menu:MenuBar;
		
		private var _args:Array;
		private var runVo:MacroPathVo;
		
		public function KillAttackMenu()
		{
			initView();
		}
		
		private function initView():void
		{
			menu=new MenuBar();
			menu.itemWidth=80;
			menu.itemHeight = 26;
			menu.labelField="label";
			menu.addEventListener(ItemEvent.ITEM_CLICK, clickHandler);
			
			var menus:Vector.<MenuItemData> = new Vector.<MenuItemData>();
			var sendToItem:MenuItemData = new MenuItemData();
			sendToItem.label="传送到遇袭地";
			sendToItem.toolTip = BroadCastConstant.SEND_TO_TOOLTIP;
			menus.push(sendToItem);
			
			var walkToItem:MenuItemData = new MenuItemData();
			sendToItem.label="寻路到遇袭地";
			sendToItem.toolTip = BroadCastConstant.WALK_TO_TOOLTIP;
			menus.push(walkToItem);
			
			menu.dataProvider=menus;
		}
		
		private function clickHandler(event:ItemEvent):void{
			if(event.selectIndex == 0){
				BroadcastModule.getInstance().sendToScene([runVo,1]);  
			}else{
				BroadcastModule.getInstance().sendToScene([runVo,2]);  
			}	
		}
		
		private var ispop:Boolean;
		public function popup(px:int,py:int,arg:Array=null):void
		{
			if(ispop)
			{
				return;
			}
			menu.show(px, py);
			ispop = true;
			_args = arg;
			if(arg){
				var pt:Pt = new Pt(arg[1],0,arg[2]);
				if(!runVo)
					runVo = new MacroPathVo(arg[0],pt);
				
			}
		}
		
	}
}

