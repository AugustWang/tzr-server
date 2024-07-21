package modules.pet.newView.items {
	import com.common.GameColors;
	import com.common.GlobalObjectManager;
	import com.common.InputKey;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.connection.Connection;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	import com.utils.KeyUtil;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.mypackage.managers.PackManager;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.shop.ShopConstant;
	
	import proto.common.p_pet_id_name;
	import proto.line.m_pet_add_bag_tos;
	import proto.line.m_pet_info_tos;
	
	public class PetList extends UIComponent {
		private var headBg:Bitmap;
		private var titleTF:TextField;
		private var list:List;
		public function PetList() {
			initView();
		}
		
		private function initView():void{
			width = 172;
			height = 364;
			
			Style.setBorderSkin(this);
			
			headBg=Style.getBitmap(GameConfig.T1_VIEWUI,"titleBar");
			headBg.width=this.width - 1;
			headBg.height=19;
			addChild(headBg);
			
			var titleFormat:TextFormat = new TextFormat("Tahoma", 12, 0xFFFFFF);
			titleFormat.align = TextFormatAlign.CENTER;
			titleTF = ComponentUtil.createTextField("",0,2, titleFormat, headBg.width, 20, this);
			titleTF.filters = Style.textBlackFilter;
			titleTF.text = "宠物列表(0/5)";
			titleTF.mouseEnabled = true;
			titleTF.addEventListener(TextEvent.LINK,onClickAddPet);
			titleTF.addEventListener(MouseEvent.ROLL_OVER,showAddPetTip);
			titleTF.addEventListener(MouseEvent.ROLL_OUT,hideToolTip);
			
			list = new List();
			list.listSkin = Style.getBorderListSkin();
			list.autoJustSize = true;
			list.x = 2;
			list.y = 21;
			list.width = this.width - 4;
			list.height = this.height - 24;
			list.itemHeight = 46;
			//list.verticalScrollPolicy = "on";
			list.itemRenderer = PetListItemRander;
			addChild(list);
			list.addEventListener(ItemEvent.ITEM_CHANGE, onItemClick);
		}
		
		public function get selectedtem():p_pet_id_name{
			return list.selectedItem as p_pet_id_name;	
		}
		
		public function update():void{
			list.dataProvider = PetDataManager.petList;
			if(list.selectedIndex < 0 && PetDataManager.petList && PetDataManager.petList.length > 0){
				list.selectedIndex = 0;
			}
			if(PetDataManager.bagContent < 5){
				titleTF.htmlText = "宠物列表("+PetDataManager.petList.length+"/"+PetDataManager.bagContent+")  "+HtmlUtil.font(HtmlUtil.link("扩展宠物栏","",true),"#00ff00");
			}else{
				titleTF.htmlText = "宠物列表("+PetDataManager.petList.length+"/"+PetDataManager.bagContent+")";
			}
			if(!PetDataManager.currentPetInfo){
				
			}else{
				if(!list.selectedItem || list.selectedItem.pet_id != PetDataManager.currentPetInfo.pet_id){
					for(var i:int=0; i<PetDataManager.petList.length; i++){
						if(PetDataManager.petList[i].pet_id == PetDataManager.currentPetInfo.pet_id){
							list.selectedIndex = i;
							return;
						}
					}
				}
			}
		}
		
		public function onItemClick(event:ItemEvent):void{
			var petNameVO:p_pet_id_name=event.selectItem as p_pet_id_name;
			if(!PetDataManager.currentPetInfo || petNameVO.pet_id != PetDataManager.currentPetInfo.pet_id){
				var vo:m_pet_info_tos=new m_pet_info_tos;
				vo.pet_id=petNameVO.pet_id;
				vo.role_id=GlobalObjectManager.getInstance().user.base.role_id;
				PetModule.getInstance().send(vo);
			}
			
			if (KeyUtil.getInstance().isKeyDown(InputKey.CONTROL)) {
				var color:String=GameColors.getHtmlColorByIndex(petNameVO.color);
				var str:String="<a href='event:pet_info:" + petNameVO.pet_id + "'><u><font color='" + color + "'>[" + petNameVO.name + "]</font></u></a>";
				ChatModule.getInstance().showPet(str);
			}
		}
		
		private function showAddPetTip(e:MouseEvent):void {
			ToolTipManager.getInstance().show("使用宠物笼可扩展宠物背包，您的宠物背包最多可扩展到5格", 0);
		}
		
		private function onClickAddPet(e:TextEvent):void {
			var tool:Array=PackManager.getInstance().getGoodsByType(12300131);
			if (tool.length > 0) {
				Alert.show("是否确定使用1个【宠物笼】，扩展1格宠物背包？", "扩展宠物栏", yesAddPet);
			} else {
				Alert.show("背包中没有【宠物笼】，是否购买？？", "扩展宠物栏", yesBuyTool);
			}
		}
		
		private function hideToolTip(e:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}
		
		private function yesBuyTool():void {
			Dispatch.dispatch(ModuleCommand.SHOP_OPEN_PET_SHOP, ShopConstant.PEI_CHONG_WU_YANG_CHENG);
		}
		
		private function yesAddPet():void {
			Connection.getInstance().sendMessage(new m_pet_add_bag_tos());
		}
	}
}