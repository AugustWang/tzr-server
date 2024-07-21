package modules.pet.newView
{
	import com.common.FilterCommon;
	import com.common.FlashObjectManager;
	import com.common.effect.FlickerEffect;
	import com.common.effect.GlowTween;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.CheckBox;
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
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
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
	import modules.vip.VipDataManager;
	
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.line.m_pet_add_understanding_tos;
	import proto.line.m_pet_call_back_tos;
	import proto.line.m_pet_refresh_aptitude_tos;
	
	public class PetSavvyView extends Sprite
	{
		private static const succs:Array=[100, 85, 83, 30, 73, 63, 25, 52, 40, 20, 38, 25, 15, 13, 12, 0];
		private static const failBack:Array=[0, 0, 0, 0, 4, 4, 4, 7, 7, 7, 10, 10, 10, 10, 10, ""];
		private var ziZhiPro:Array=["0", "50", "100", "150", "250", "350", "450", "600", "750", "900", "1050", "1200", "1400", "1600", "1800", "2000", ""];
		
		private var f1:int=12300121; //初中高3中提悟符的item_id
		private var f2:int=12300122;
		private var f3:int=12300123;
		private var wxbaohu:int=12300124; //悟性保护符TYPEID
		private var tiWuFuItemVo1:BaseItemVO; //初级
		private var tiWuFuItemVo2:BaseItemVO;
		private var tiWuFuItemVo3:BaseItemVO; //高级
		
		private var petList:PetList;
		
		private var curwuxing:TextField;
		private var maxWuxing:TextField;
		private var failWuxingBack:TextField;
		private var sucessRate:TextField;
		private var curAddzizhi:TextField;
		private var nextAddzizhi:TextField;
		private var useTiwufu:CheckBox; 
		private var moneyInput:TextField;
		private var needNameInput:TextField;
		
		private var savvyDataGrid:DataGrid;
		private var hasInit:Boolean = false;
		private var pet:p_pet;
		private var timeOut:int;
		private var goodsTypeId:int;
		public function PetSavvyView()
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
			var startX:Number = petList.width+petList.x+20;
			var landing:Number = 25;
			
			var bigTF:TextFormat = Style.themeTextFormat;
			bigTF.color= 0xffffff;
			bigTF.bold = true;
			bigTF.font = "Arail";
			bigTF.size = 38;
			bigTF.align = "center";
			curwuxing = ComponentUtil.createTextField("",startX,startY,bigTF,150,50,this);
			
			startY += 50;
			maxWuxing = createTextField("悟性最高为：",startX,startY,0x00ff00);
			maxWuxing.text = "15"
			failWuxingBack = createTextField("失败悟性调回：",startX,startY+20,0x00ff00);
			sucessRate = createTextField("成功率：",startX,startY+40,0x00ff00);
			sucessRate.mouseEnabled = true;
			sucessRate.addEventListener(TextEvent.LINK, succLinkHandler);
			
			curAddzizhi = createTextField("当前增加资质：",startX,sucessRate.y+50,0x00ff00);
			nextAddzizhi = createTextField("下级增加资质：",startX,curAddzizhi.y+20,0x00ff00);
			
			var greenTF:TextFormat = Style.themeTextFormat;
			greenTF.color = 0x00ff00;
			useTiwufu = new CheckBox();
			useTiwufu.text = "使用提悟保护符";
			useTiwufu.textFormat = greenTF;
			useTiwufu.x = startX;
			useTiwufu.y = nextAddzizhi.y+40;
			addChild(useTiwufu);
			
			moneyInput=createTextField("费   用：", startX, useTiwufu.y+24);
			moneyInput.text = "10两";
			needNameInput=createTextField("需   要：", startX, moneyInput.y + 22);
			
			var studySkin:ButtonSkin=Style.getButtonSkin("petBtn_1skin", "petBtn_2skin", "petBtn_3skin", "", GameConfig.PET_UI);
			var studyButton:UIComponent=ComponentUtil.createUIComponent(startX + 32, needNameInput.y + 30, 84, 78, studySkin);
			studyButton.useHandCursor=studyButton.buttonMode=true;
			studyButton.addEventListener(MouseEvent.CLICK, savvyHandler);
			addChild(studyButton);
			var studyNameBitmap:Bitmap=Style.getBitmap(GameConfig.PET_UI, "name_tw");
			studyNameBitmap.x=studyButton.width - studyNameBitmap.width >> 1;
			studyNameBitmap.y=studyButton.height - studyNameBitmap.height >> 1;
			studyButton.addChild(studyNameBitmap)
			
			var helpSkin:ButtonSkin=Style.getButtonSkin("petHelp_1skin", "petHelp_2skin", "petHelp_3skin", "", GameConfig.PET_UI);
			var helpButton:UIComponent=ComponentUtil.createUIComponent(studyButton.x + 105, studyButton.y + 50, 29, 31, helpSkin);
			helpButton.useHandCursor=helpButton.buttonMode=true;
			helpButton.addEventListener(MouseEvent.CLICK, savvyHelpHandler);
			addChild(helpButton);
			
			var arr:Array=new Array();
			tiWuFuItemVo1=ItemLocator.getInstance().getObject(f1);
			tiWuFuItemVo2=ItemLocator.getInstance().getObject(f2);
			tiWuFuItemVo3=ItemLocator.getInstance().getObject(f3);
			tiWuFuItemVo1.num=PackManager.getInstance().getGoodsNumByTypeId(f1);
			tiWuFuItemVo2.num=PackManager.getInstance().getGoodsNumByTypeId(f2);
			tiWuFuItemVo3.num=PackManager.getInstance().getGoodsNumByTypeId(f3);
			arr.push(tiWuFuItemVo1);
			arr.push(tiWuFuItemVo2);
			arr.push(tiWuFuItemVo3);
			
			savvyDataGrid=new DataGrid();
			savvyDataGrid.list.listSkin = Style.getBorderListSkin();
			savvyDataGrid.list.autoJustSize = true;
			Style.setBorderSkin(savvyDataGrid);
			savvyDataGrid.x=startX + 180;
			savvyDataGrid.y=petList.y;
			savvyDataGrid.itemHeight=46;
			savvyDataGrid.itemRenderer=PetGoodsItem;
			savvyDataGrid.width=petList.width;
			savvyDataGrid.height=petList.height;
			savvyDataGrid.addColumn("提悟符", savvyDataGrid.width);
			savvyDataGrid.dataProvider = arr;
			addChild(savvyDataGrid);
			
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
		
		private function succLinkHandler(e:Event):void {
			Dispatch.dispatch(ModuleCommand.VIP_PANEL);
		}

		public function update():void {
			if(PetDataManager.currentPetInfo && stage){
				pet = PetDataManager.currentPetInfo;	
				if(pet.understanding < 15){
					curwuxing.text = pet.understanding.toString();
					curwuxing.textColor = 0xffffff;
					failWuxingBack.text = failBack[pet.understanding].toString();
					sucessRate.htmlText =  succs[pet.understanding] + "%"+VipDataManager.getInstance().getPetUnderstandingRateAdd();
					curAddzizhi.text = ziZhiPro[pet.understanding].toString();
					nextAddzizhi.text = ziZhiPro[pet.understanding+1].toString();
					var usefuName:String = "";
					if (pet.understanding >= 0 && pet.understanding < 4) {
						usefuName="【初级提悟符】";
						goodsTypeId = f1;
					} else if (pet.understanding == 4) {
						usefuName="【初级提悟符】";
						goodsTypeId = f1;
					} else if (pet.understanding >= 5 && pet.understanding < 7) {
						usefuName="【中级提悟符】";
						goodsTypeId = f2;
					} else if (pet.understanding == 7) {
						usefuName="【中级提悟符】";
						goodsTypeId = f2;
					} else if (pet.understanding >= 8 && pet.understanding < 10) {
						usefuName="【中级提悟符】";
						goodsTypeId = f2;
					} else if (pet.understanding == 10) {
						usefuName="【高级提悟符】";
						goodsTypeId = f3;
					} else if (pet.understanding >= 11 && pet.understanding < 15) {
						usefuName="【高级提悟符】";
						goodsTypeId = f3;
					} 
					needNameInput.text=usefuName;
					changeSelectGoods();
				}else{
					curwuxing.text = pet.understanding.toString();
					curwuxing.textColor = 0xffff00;
					failWuxingBack.text = pet.understanding.toString();
					sucessRate.text =  "已达到最高等级";
					curAddzizhi.text = ziZhiPro[pet.understanding].toString();
					nextAddzizhi.text = ziZhiPro[pet.understanding].toString();
					needNameInput.text="已达到最高等级";
				}
			}
		}
		
		private function changeSelectGoods():void{
			for each(var item:BaseItemVO in savvyDataGrid.list.dataProvider){
				if(item.typeId == goodsTypeId){
					savvyDataGrid.list.selectedItem = item;
					break;
				}
			}
		}
		
		private function savvyHandler(event:MouseEvent):void{
			var item:p_pet_id_name=petList.selectedtem as p_pet_id_name;
			if (item == null) {
				Tips.getInstance().addTipsMsg("请先选择需要洗灵的宠物");
				return;
			}
			if(pet && pet.pet_id == item.pet_id && pet.understanding == 15){
				Tips.getInstance().addTipsMsg("该宠物悟性已经是最高级别了。");
				return;
			}
			if (PetDataManager.isBattle == true && PetDataManager.thePet && PetDataManager.thePet.pet_id == item.pet_id) {
				Alert.show("本操作需要召回宠物，是否立刻召回？", "提悟", exeCallBack, null, "召回宠物");
				return;
			}
			var itemUse:BaseItemVO=savvyDataGrid.list.selectedItem as BaseItemVO;
			if (itemUse == null) {
				Tips.getInstance().addTipsMsg("请先选择提悟符");
				return;
			}
			if(itemUse.typeId < goodsTypeId && goodsTypeId != 0){
				Tips.getInstance().addTipsMsg("请选择"+needNameInput.text+"或者更高级的提悟符");
				return;
			}
			var itemNum:int=PackManager.getInstance().getGoodsNumByTypeId(itemUse.typeId);
			if (itemNum <= 0) {
				Tips.getInstance().addTipsMsg("选择的提悟符数量不足");
				updateUseItemNum();
				return;
			}
			if(useTiwufu.selected && PackManager.getInstance().getGoodsVOByType(wxbaohu) == null){
				Tips.getInstance().addTipsMsg("提悟保护符数量不足");
				updateUseItemNum();
				return;
			}
			var vo:m_pet_add_understanding_tos=new m_pet_add_understanding_tos;
			vo.pet_id=item.pet_id;
			vo.item_type=itemUse.typeId;
			vo.use_protect=useTiwufu.selected;
			PetModule.getInstance().send(vo);
			startGlow();
		}
		
		private var glowEffect:GlowTween;
		public function startGlow():void {
			if (glowEffect == null) {
				glowEffect=new GlowTween();
			}
			clearTimeout(timeOut);
			stopGlow();
			glowEffect.startGlow(curwuxing,1,0xffff00);
			timeOut = setTimeout(stopGlow,2000);

		}
		
		public function stopGlow():void {
			if (glowEffect) {
				glowEffect.stopGlow()
			}
		}
		
		private function savvyHelpHandler(event:MouseEvent):void{
			
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
			tiWuFuItemVo1.num=PackManager.getInstance().getGoodsNumByTypeId(f1);
			tiWuFuItemVo2.num=PackManager.getInstance().getGoodsNumByTypeId(f2);
			tiWuFuItemVo3.num=PackManager.getInstance().getGoodsNumByTypeId(f3);
			savvyDataGrid.list.invalidateList();
		}
		
		private function createTextField(proName:String, startX:int, startY:int,color:uint=0xfffd4b):TextField {
			var title:TextField=ComponentUtil.createTextField(proName, startX, startY, Style.themeTextFormat, NaN, 20, this);
			title.textColor=color;
			title.filters=FilterCommon.FONT_BLACK_FILTERS;
			title.width=title.textWidth;
			var textInput:TextField=ComponentUtil.createTextField("",startX + title.width,startY,null, 130, 20, this);
			textInput.textColor=0xffb14b;
			return textInput;
		}
	}
}