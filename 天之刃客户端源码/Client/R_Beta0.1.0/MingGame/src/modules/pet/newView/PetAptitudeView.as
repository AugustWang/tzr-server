package modules.pet.newView
{
	import com.common.FilterCommon;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.ProgressBar;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetDataManager;
	import modules.pet.PetModule;
	import modules.pet.config.PetConfig;
	import modules.pet.newView.items.PetGoodsItem;
	import modules.pet.newView.items.PetList;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_refresh_aptitude_tos;
	
	public class PetAptitudeView extends Sprite
	{
		private var d1:int=12300118;
		private var d2:int=12300119;
		private var d3:int=12300120;
		private var xiLingDanItemVo1:BaseItemVO; //初级
		private var xiLingDanItemVo2:BaseItemVO;
		private var xiLingDanItemVo3:BaseItemVO; //高级
		private var goodsTypeId:int;
		
		private var petList:PetList;
		private var waigongBar:ProgressBar;
		private var neigongBar:ProgressBar;
		private var waifangBar:ProgressBar;
		private var neifangBar:ProgressBar;
		private var zhongjiBar:ProgressBar;
		private var shengmingBar:ProgressBar; 
		private var maxAptitudeInput:TextInput;
		
		private var moneyInput:TextInput;
		private var needNameInput:TextInput;
		
		private var aptitudeDataGrid:DataGrid;
		private var hasInit:Boolean = false;
		private var pet:p_pet;
		
		public function PetAptitudeView()
		{
			addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
		}
		
		private function addToStageHandler(event:Event):void {
			initView();
			onPetListUpdate();
			update();
		}
		
		private function initView():void{	
			if (hasInit) {
				return;
			}
			hasInit=true;
			petList=new PetList();
			petList.x=15;
			petList.y=8;
			addChild(petList);
			
			var startY:Number = 10;
			var startX:Number = petList.width+petList.x+3;
			var landing:Number = 25;
			
			var nameTextFormat:TextFormat=new TextFormat("Tahoma", 12, 0xfffd4b);	
			ComponentUtil.createTextField("外功资质：", startX, startY, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("内功资质：", startX, startY + landing * 1, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("外防资质：", startX, startY + landing * 2, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("内防资质：", startX, startY + landing * 3, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("重击资质：", startX, startY + landing * 4, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			ComponentUtil.createTextField("生命资质：", startX, startY + landing * 5, nameTextFormat, 70, 25, this).filters=Style.textBlackFilter;
			
			startX+=62;
			waigongBar=createBar(startX, startY + 3, 130, 14, this);
			neigongBar=createBar(startX, startY + landing * 1 + 3, 130, 14, this);
			waifangBar=createBar(startX, startY + landing * 2 + 3, 130, 14, this);
			neifangBar=createBar(startX, startY + landing * 3 + 3, 130, 14, this);
			zhongjiBar=createBar(startX, startY + landing * 4 + 3, 130, 14, this);
			shengmingBar=createBar(startX, startY + landing * 5 + 3, 130, 12, this);
			
			startX -= 62;
			
			maxAptitudeInput = createTextInput("资质最高：",startX,shengmingBar.y+shengmingBar.height+10,0xAFE1EC);
			
			moneyInput=createTextInput("费   用：", startX + 20, 232);
			moneyInput.text = "50文";
			needNameInput=createTextInput("需   要：", startX + 20, moneyInput.y + 30);
			
			var studySkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			var studyButton:UIComponent=ComponentUtil.createUIComponent(startX + 62, needNameInput.y + 30, 84, 78, studySkin);
			studyButton.useHandCursor=studyButton.buttonMode=true;
			studyButton.addEventListener(MouseEvent.CLICK, aptitudeHandler);
			addChild(studyButton);
			var studyNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_xl");
			studyNameBitmap.x=studyButton.width - studyNameBitmap.width >> 1;
			studyNameBitmap.y=studyButton.height - studyNameBitmap.height >> 1;
			studyButton.addChild(studyNameBitmap)
			
			var helpSkin:ButtonSkin=Style.getButtonSkin("petHelp_1skin", "petHelp_2skin", "petHelp_3skin", "", GameConfig.PET_UI);
			var helpButton:UIComponent=ComponentUtil.createUIComponent(studyButton.x + 105, studyButton.y + 50, 29, 31, helpSkin);
			helpButton.useHandCursor=helpButton.buttonMode=true;
			helpButton.addEventListener(MouseEvent.CLICK, aptitudeHelpHandler);
			addChild(helpButton);
			
			var arr:Array=new Array();
			xiLingDanItemVo1=ItemLocator.getInstance().getObject(d1);
			xiLingDanItemVo2=ItemLocator.getInstance().getObject(d2);
			xiLingDanItemVo3=ItemLocator.getInstance().getObject(d3);
			xiLingDanItemVo1.num=PackManager.getInstance().getGoodsNumByTypeId(d1);
			xiLingDanItemVo2.num=PackManager.getInstance().getGoodsNumByTypeId(d2);
			xiLingDanItemVo3.num=PackManager.getInstance().getGoodsNumByTypeId(d3);
			arr.push(xiLingDanItemVo1);
			arr.push(xiLingDanItemVo2);
			arr.push(xiLingDanItemVo3);
			
			aptitudeDataGrid=new DataGrid();
			aptitudeDataGrid.list.listSkin = Style.getBorderListSkin();
			aptitudeDataGrid.list.autoJustSize = true;
			Style.setBorderSkin(aptitudeDataGrid);
			aptitudeDataGrid.x=startX + 204;
			aptitudeDataGrid.y=petList.y;
			aptitudeDataGrid.itemHeight=46;
			aptitudeDataGrid.itemRenderer=PetGoodsItem;
			aptitudeDataGrid.width=petList.width;
			aptitudeDataGrid.height=petList.height;
			aptitudeDataGrid.addColumn("洗灵丹", aptitudeDataGrid.width);
			aptitudeDataGrid.dataProvider = arr;
			addChild(aptitudeDataGrid);
			
			Dispatch.register(ModuleCommand.PET_CURRENT_INFO_CHANGE, update);
			Dispatch.register(ModuleCommand.PET_INFO_UPDATE,onPetInfoUpdate);
			Dispatch.register(ModuleCommand.PET_LIST_CHANGED,onPetListUpdate);
		}
		
		private function onPetListUpdate():void{
			if(stage && petList){
				petList.update();
			}
		}
		
		private function onPetInfoUpdate(vo:p_pet):void{
			if(stage && pet && pet.pet_id == vo.pet_id){
				update();
			}
		}
		
		public function update():void {
		   if(PetDataManager.currentPetInfo && stage){
			   pet = PetDataManager.currentPetInfo;
				var maxAptitude:int=PetConfig.getMaxAptitude(pet.type_id);
				var carryLevel:int=PetConfig.getPetTakeLevel(pet.type_id);
				var useDrugName:String = "";
				if (carryLevel == 5 || carryLevel == 25) {
					useDrugName="【初级洗灵丹】";
					goodsTypeId = d1;
				} else if (carryLevel == 50) {
					useDrugName="【中级洗灵丹】";
					goodsTypeId = d2;
				} else {
					useDrugName="【高级洗灵丹】";
					goodsTypeId = d3;
				}
				maxAptitudeInput.text=maxAptitude.toString();
				needNameInput.text=useDrugName;
				var maxZZ:int=PetConfig.getMaxAptitude(pet.type_id);
			
				var ziZhiColor:String=pet.phy_attack_aptitude >= maxZZ ? "#00ff00" : "#ECE8BB";
				waigongBar.value = pet.phy_attack_aptitude/maxZZ;
				waigongBar.htmlText=HtmlUtil.font(String(pet.phy_attack_aptitude),ziZhiColor);
				ziZhiColor=pet.magic_attack_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
				neigongBar.value = pet.magic_attack_aptitude/maxZZ;
				neigongBar.htmlText=HtmlUtil.font(String(pet.magic_attack_aptitude),ziZhiColor);
				ziZhiColor=pet.phy_defence_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
				waifangBar.value = pet.phy_defence_aptitude/maxZZ;
				waifangBar.htmlText=HtmlUtil.font(String(pet.phy_defence_aptitude),ziZhiColor);
				ziZhiColor=pet.magic_defence_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
				neifangBar.value = pet.magic_defence_aptitude/maxZZ;
				neifangBar.htmlText=HtmlUtil.font(String(pet.magic_defence_aptitude),ziZhiColor);
				ziZhiColor=pet.max_hp_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
				shengmingBar.value = pet.max_hp_aptitude/maxZZ;
				shengmingBar.htmlText=HtmlUtil.font(String(pet.max_hp_aptitude),ziZhiColor);
				ziZhiColor=pet.double_attack_aptitude >= maxZZ ? "00ff00" : "ECE8BB";
				zhongjiBar.value = pet.double_attack_aptitude/maxZZ;
				zhongjiBar.htmlText=HtmlUtil.font(String(pet.double_attack_aptitude),ziZhiColor);
				changeSelectGoods();
		   }
		}
		
		private function changeSelectGoods():void{
			for each(var item:BaseItemVO in aptitudeDataGrid.list.dataProvider){
				if(item.typeId == goodsTypeId){
					aptitudeDataGrid.list.selectedItem = item;
					break;
				}
			}
		}
		
		private function aptitudeHandler(event:MouseEvent):void{
			var item:p_pet_id_name=petList.selectedtem as p_pet_id_name;
			if (item == null) {
				Tips.getInstance().addTipsMsg("请先选择需要洗灵的宠物");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == item.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "洗灵", exeCallBack, null, "召回宠物");
				return;
			}
			var itemUse:BaseItemVO=aptitudeDataGrid.list.selectedItem as BaseItemVO;
			if (itemUse == null) {
				Tips.getInstance().addTipsMsg("请先选择洗灵丹");
				return;
			}
			var itemNum:int=PackManager.getInstance().getGoodsNumByTypeId(itemUse.typeId);
			if (itemNum <= 0) {
				Tips.getInstance().addTipsMsg("选择的洗灵丹数量不足");
				updateUseItemNum();
				return;
			}
			var vo:m_pet_refresh_aptitude_tos=new m_pet_refresh_aptitude_tos;
			vo.pet_id=item.pet_id;
			vo.item_type=itemUse.typeId;
			PetModule.getInstance().send(vo);
		}
		
		private function aptitudeHelpHandler(event:MouseEvent):void{
			
		}
		
		private function exeCallBack():void {
			if (PetInfoView.callBackAbled == false) {
				Tips.getInstance().addTipsMsg("5秒后才能召回宠物");
				return;
			}
			var vo:m_pet_call_back_tos=new m_pet_call_back_tos;
			vo.pet_id=PetDataManager.thePet.pet_id;
			PetModule.getInstance().send(vo);
			PetInfoView.setSummonAbledFalse(); //限制按钮时间
			PetInfoView.setCallBackAbledFalse();
		}
		
		public function updateUseItemNum(e:Event=null):void {
			xiLingDanItemVo1.num=PackManager.getInstance().getGoodsNumByTypeId(d1);
			xiLingDanItemVo2.num=PackManager.getInstance().getGoodsNumByTypeId(d2);
			xiLingDanItemVo3.num=PackManager.getInstance().getGoodsNumByTypeId(d3);
			aptitudeDataGrid.list.invalidateList();
		}
		
		private function createTextInput(proName:String, startX:int, startY:int,color:uint=0xfffd4b):TextInput {
			var title:TextField=ComponentUtil.createTextField(proName, startX, startY, Style.themeTextFormat, NaN, 20, this);
			title.textColor=color;
			title.filters=FilterCommon.FONT_BLACK_FILTERS;
			title.width=title.textWidth + 4;
			var textInput:TextInput=ComponentUtil.createTextInput(startX + title.width + 5, startY, 100, 25, this);
			textInput.textField.textColor=0xffb14b;
			textInput.enabled=false;
			textInput.leftPadding=8;
			return textInput;
		}
		
		private function createBar(x:int, y:int, w:int, h:int, $parent:DisplayObjectContainer):ProgressBar {
			var expBar:ProgressBar=new ProgressBar();
			expBar.bgSkin=Style.getSkin("expBarBg", GameConfig.T1_UI, new Rectangle(5, 5, 108, 4));
			expBar.bar=Style.getBitmap(GameConfig.T1_UI, "expBar");
			expBar.padding=3;
			expBar.x=x;
			expBar.y=y;
			expBar.width=w;
			expBar.height=h;
			expBar.value=0.5;
			expBar.htmlText="50%";
			$parent.addChild(expBar);
			return expBar
		}
	}
}