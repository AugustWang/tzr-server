package modules.rank.view
{
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.events.WindowEvent;
	import com.managers.WindowManager;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import modules.pet.PetDataManager;
	import modules.rank.RankModule;
	
	import proto.common.p_pet_id_name;
	
	public class PetListView extends BasePanel
	{
		private var list:List;
		private var box:ComboBox;
		public var selectedPetId:int; //正在看的那只
		private var confirmBtn:Button;
		private static var petListView:PetListView = new PetListView();
		private var currentRankId:int;
		
		public function PetListView()
		{
			super("petList");
			title="宠物列表";
			this.width=250;
			this.height=262;
		}
		
		override protected function init():void
		{
			var bg:UIComponent=ComponentUtil.createUIComponent(8,4,234,190);
			Style.setBorderSkin(bg);
			this.addChild(bg);
			var tf:TextFormat=new TextFormat(null, null, 0x3ce451);
			var tfw:TextFormat=new TextFormat(null, null, 0xffffff);
			ComponentUtil.createTextField("选择一只宠物，点确定提交", 24, 18, tfw, 300, 60, this);
			ComponentUtil.createTextField("我的宠物列表：", 24, 40, tf, 160, 22, this);
			list=new List;
			list.labelField="name";
			list.width=100;
			list.height=110;
			list.x=24;
			list.y=60;
			list.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			addChild(list);
			confirmBtn=ComponentUtil.createButton("确定", 100, 193, 60, 25, this);
			var canelBtn:Button=ComponentUtil.createButton("取消", 170, 193, 60, 25, this);
			confirmBtn.addEventListener(MouseEvent.CLICK, onClickUse);
			canelBtn.addEventListener(MouseEvent.CLICK, onCanel);
			this.addEventListener(WindowEvent.OPEN,onOpenPanel);
		}
		
		private function onOpenPanel(e:WindowEvent):void {
			updateList(PetDataManager.petList);
		}
		
		public static function getInstance():PetListView{
			return petListView;
		}
		
		
		public function updateList(pets:Array):void
		{
			list.dataProvider=pets;
		}
		
		
		private function onClickUse(e:MouseEvent):void
		{
			var item:p_pet_id_name=list.selectedItem as p_pet_id_name;
			if (item == null)
			{
				Alert.show("请先选择宠物", "提示", null, null, "确定", "", null, false);
				return ;
			}
			RankModule.getInstance().reqestPetRankData(currentRankId,selectedPetId);
			WindowManager.getInstance().removeWindow(this); 
		
		}
		
		public function joinRank(rankId:int):void{
			makeListSelect();
			currentRankId = rankId;
		}
		
		private function onItemClick(e:ItemEvent):void
		{
			var ipname:p_pet_id_name=e.selectItem as p_pet_id_name;
			selectedPetId=ipname.pet_id;
		}
		
		private function makeListSelect():void
		{
			selectedPetId = 0;
			list.selectedIndex = -1;
			list.selectedItem = null;
		}
		
		
		private function onCanel(e:MouseEvent):void
		{
			closeWindow();
		}
	}
}