package modules.pet.view {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.events.WindowEvent;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.mypackage.vo.GeneralVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.line.m_pet_add_life_toc;
	import proto.line.m_pet_add_life_tos;
	import proto.line.m_pet_info_tos;

	public class PetLifeView extends BasePanel {
		private static const yao1:int=12300105;
		private static const yao2:int=12300106;
		private static const yao3:int=12300107;
		private var list:List;
		private var liftTxt:TextField;
		private var box:ComboBox;
		public var selectedPetId:int; //正在看的那只
		private var addType:int; //药的类型
		private var useItem:PetSkillItem;
		private var confirmBtn:Button;

		public function PetLifeView() {
			super("petLife");
			title="延长宠物寿命";
			this.width=287;
			this.height=366;
		}

		override protected function init():void {
			var ui:UIComponent=ComponentUtil.createUIComponent(7,4,272,302);
			Style.setBorderSkin(ui);
			addChild(ui);
			var tf:TextFormat=new TextFormat(null, null, 0x3ce451);
			var tfw:TextFormat=new TextFormat(null, null, 0xffffff);
			ComponentUtil.createTextField("使用【延寿丹】可延长宠物寿命。", 24, 18, tfw, 300, 60, this);
			ComponentUtil.createTextField("请选择你需要延寿的宠物", 24, 40, tf, 160, 22, this);
			liftTxt=ComponentUtil.createTextField("当前寿命：", 24, 62, tfw, 120, 22, this);
			list=new List;
			list.labelField="name";
			list.width=100;
			list.height=120;
			list.x=162;
			list.y=42;
			list.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			addChild(list);
			ComponentUtil.createTextField("请将延寿丹拖到下框中：", 24, 192, tfw, 160, 22, this);
			useItem=new PetSkillItem;
			useItem.x=26;
			useItem.y=214;
			addChild(useItem);
			confirmBtn=ComponentUtil.createButton("确定", 142, 304, 60, 24, this);
			var canelBtn:Button=ComponentUtil.createButton("取消", 210, 304, 60, 24, this);
			confirmBtn.addEventListener(MouseEvent.CLICK, onClickUse);
			canelBtn.addEventListener(MouseEvent.CLICK, onCanel);
			var petStoreBtn:Button=ComponentUtil.createButton("宠物商店", 114, 228, 60, 24, this);
			petStoreBtn.addEventListener(MouseEvent.CLICK, toPetStore);
			this.addEventListener(WindowEvent.OPEN,onOpenPanel);
		}
		
		private function onOpenPanel(e:WindowEvent):void {
			updateList(PetDataManager.petList);
		}
		public function updateList(pets:Array):void {
			list.dataProvider=pets;
		}

		public function updateLife(vo:m_pet_add_life_toc):void {
			makeListSelect();
			liftTxt.htmlText=HtmlUtil.font("当前寿命：", "#FFFFFF") + HtmlUtil.font(vo.life + "", "#ECE8BB");
		}

		private function onClickUse(e:MouseEvent):void {
			var item:p_pet_id_name=list.selectedItem as p_pet_id_name;
			if (item == null) {
				Alert.show("请先选择宠物", "提示", null, null, "确定", "", null, false);
				return;
			}
			if (useItem.data == null) {
				Alert.show("请将延寿丹拖到下框中", "提示", null, null, "确定", "", null, false);
				return;
			}
			if (useItem.data is GeneralVO == false) {
				Alert.show("道具必须为延寿丹", "提示", null, null, "确定", "", null, false);
				return;
			}
			var typeId:int=(useItem.data as GeneralVO).typeId;
			if (typeId != yao1 && typeId != yao2 && typeId != yao3) {
				Alert.show("道具必须为延寿丹", "提示", null, null, "确定", "", null, false);
				return;
			}
			var vo:m_pet_add_life_tos=new m_pet_add_life_tos;
			vo.pet_id=selectedPetId;
			vo.add_type=typeId;
			Connection.getInstance().sendMessage(vo);
		}

		public function updateCurrentLife(vo:p_pet):void {
			var item:p_pet_id_name=list.selectedItem as p_pet_id_name;
			if (item != null && item.pet_id == vo.pet_id) {
				liftTxt.htmlText=HtmlUtil.font("当前寿命：", "#FFFFFF") + HtmlUtil.font(vo.life + "", "#ECE8BB");
			}
		}

		private function onItemClick(e:ItemEvent):void {

			var ipname:p_pet_id_name=e.selectItem as p_pet_id_name;
			selectedPetId=ipname.pet_id;
			var vo:m_pet_info_tos=new m_pet_info_tos;
			vo.pet_id=selectedPetId;
			vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
			Connection.getInstance().sendMessage(vo);
		}

		public function updateUseItemItemNum():void {
			useItem.updateNum();
		}

		private function makeListSelect():void {
			if (selectedPetId == 0) {
				list.selectedIndex=0;
			} else {
				var arr:Array=PetDataManager.petList;
				for (var i:int=0; i < arr.length; i++) {
					var p:p_pet_id_name=arr[i];
					if (p.pet_id == selectedPetId) {
						list.selectedIndex=i;
						break;
					}
				}
			}
		}

		private function toPetStore(e:MouseEvent):void {
			Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP);
		}

		private function onCanel(e:MouseEvent):void {
			closeWindow();
			useItem.data=null;
		}
	}
}