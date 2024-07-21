package modules.forgeshop.views
{
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.forgeshop.CostManager;
	import modules.forgeshop.ForgeshopModule;
	import modules.forgeshop.views.items.MaterialItemRender;
	import modules.forgeshop.views.items.UpdateEquipItem;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_equip_bind_attr;
	import proto.line.m_equip_build_upgrade_tos;
	import proto.line.p_equip_build_goods;
	
	public class EquipUpgradeCanvas extends UIComponent
	{
		public var materialGrid:DataGrid;
		private var updateHeader:HeaderBar;
		private var update_txt:TextField;
		public var updateItem:UpdateEquipItem;
		private var tipTxt:TextField;
		
		//保留属性
		private var checkBox:CheckBox;
		private var propertyNeedTxt:TextField;//消耗数量
		private var propertyHasTxt:TextField;//当前数量
		
		//保留强化
		private var str_checkBox:CheckBox;
		private var strNeedTxt:TextField;
		private var strHasTxt:TextField;
		
		//保留五行
		private var five_checkBox:CheckBox;
		private var fiveNeedTxt:TextField;
		private var fiveHasTxt:TextField;
		private var baseArray:Array = [];
		
		//保留绑定属性
		private var bind_checkBox:CheckBox;
		private var bindNeedTxt:TextField;
		private var bindHasTxt:TextField;
		
		public function EquipUpgradeCanvas()
		{
			super();
			init();
		}
		private function init():void{
			update_txt = ComponentUtil.createTextField("升级到的装备",-260,240,new TextFormat("Tahoma",12,0xffcc00),100,30,this);
			updateItem = new UpdateEquipItem();
			updateItem.x = update_txt.x + update_txt.textWidth + 3;
			updateItem.y = update_txt.y - 3;
			this.addChild(updateItem);
			
			tipTxt = ComponentUtil.createTextField("角色当前等级无法装备",update_txt.x + update_txt.textWidth + updateItem.width + 5,update_txt.y,null,130,30,this);
			tipTxt.visible = false;
			tipTxt.textColor = 0xff0000;
			tipTxt.filters = [new GlowFilter(0,1,2,2)];
			
			var titleTextField:TextField = ComponentUtil.createTextField("      装备升级的时候一些特殊属性会出现损耗，你可以使用特殊材料保留这些属性。",2,3,new TextFormat("Tahoma",12,0xffcc00),260,50,this);
			titleTextField.wordWrap = true;
			
			//基础材料
			materialGrid = new DataGrid();
			this.addChild(materialGrid);
			materialGrid.x = titleTextField.x -1;
			materialGrid.y = titleTextField.y + titleTextField.textHeight + 10;
			materialGrid.width = 266;
			materialGrid.height = 40;
			
			//家奇说这个和HeaderBar的字体不对称
//			materialGrid.addColumn("基础材料",88);
//			materialGrid.addColumn("需要数量",60);
//			materialGrid.addColumn("拥有数量",60);
			materialGrid.addColumn("基础材料",78);
			materialGrid.addColumn("需要数量",117);
			materialGrid.addColumn("拥有数量",70);
			materialGrid.itemHeight = 25;
			materialGrid.itemRenderer = MaterialItemRender;
			materialGrid.verticalScrollPolicy = ScrollPolicy.OFF;
            materialGrid.list.selected = false;
			/*materialGrid.mouseChildren = */materialGrid.mouseEnabled = false;
			
			//保留属性
			updateHeader = new HeaderBar();	
			this.addChild(updateHeader);
			updateHeader.x = materialGrid.x;
			updateHeader.y = materialGrid.y + materialGrid.height;
			updateHeader.width = 266;
			updateHeader.height = 23;
			updateHeader.addColumn("保留属性",78);
			updateHeader.addColumn("消耗材料",117);
			updateHeader.addColumn("当前数量",70);
			
			//保留属性
			checkBox = ComponentUtil.createCheckBox("保留品质",updateHeader.x + 5,updateHeader.y + updateHeader.height,this);
			checkBox.name = "property";
			//			checkBox.width = 78;
			checkBox.addEventListener(MouseEvent.CLICK,onCheckBoxHandler);
			propertyNeedTxt = ComponentUtil.createTextField("",checkBox.x + checkBox.width,checkBox.y,null,120,30,this);
			propertyHasTxt = ComponentUtil.createTextField("",propertyNeedTxt.x + propertyNeedTxt.width,propertyNeedTxt.y,null,70,30,this);
			drawLine(checkBox.x - 3,checkBox.y + checkBox.height + 5);
			
			//保留强化
			str_checkBox = ComponentUtil.createCheckBox("保留强化",checkBox.x,propertyHasTxt.y + propertyHasTxt.height +1,this);
			//			str_checkBox.width = 78;
			str_checkBox.name = "strenght";
			str_checkBox.addEventListener(MouseEvent.CLICK,onCheckBoxHandler);
			strNeedTxt = ComponentUtil.createTextField("",str_checkBox.x + str_checkBox.width,str_checkBox.y,null,120,30,this);
			strHasTxt = ComponentUtil.createTextField("",strNeedTxt.x + strNeedTxt.width,strNeedTxt.y,null,70,30,this);
			drawLine(checkBox.x - 3,strHasTxt.y + checkBox.height);
			
			//保留绑定
			bind_checkBox = ComponentUtil.createCheckBox("固定绑定属性",checkBox.x,strHasTxt.y + strHasTxt.height - 3,this);
			//			bind_checkBox.width = 78;
			bind_checkBox.name = "bind";
			//			bind_checkBox.setToolTip("不固定则重新随机赋予绑定属性");
			bind_checkBox.addEventListener(MouseEvent.CLICK,onCheckBoxHandler);
			bindNeedTxt = ComponentUtil.createTextField("",bind_checkBox.x + bind_checkBox.width,bind_checkBox.y,null,120,30,this);
			bindHasTxt = ComponentUtil.createTextField("",bindNeedTxt.x + bindNeedTxt.width,bind_checkBox.y,null,70,30,this);
			drawLine(checkBox.x - 3,bindHasTxt.y + checkBox.height);
			
			//保留五行
			five_checkBox = ComponentUtil.createCheckBox("保留五行",checkBox.x,bindHasTxt.y + bindHasTxt.height - 3,this);
			//			five_checkBox.width = 78;
			five_checkBox.name = "five";
			five_checkBox.addEventListener(MouseEvent.CLICK,onCheckBoxHandler);
			fiveNeedTxt = ComponentUtil.createTextField("",five_checkBox.x + five_checkBox.width,five_checkBox.y,null,120,30,this);
			fiveHasTxt = ComponentUtil.createTextField("",fiveNeedTxt.x + fiveNeedTxt.width,fiveNeedTxt.y,null,70,30,this);
			drawLine(checkBox.x - 3,fiveHasTxt.y + checkBox.height);
			
			//屏蔽铁匠铺上装备升级功能
			//深绿色背景
			var shieldBg:Sprite = Style.getBlackSprite(542,318,2,0.98);
			this.addChild(shieldBg);
			shieldBg.x = this.x - 275;
			shieldBg.y = this.y;
			var tf:TextFormat=new TextFormat("Tahoma", 12, 0xE8E7B7, true, null, null, null, null, TextFormatAlign.CENTER);
			var shieldDesc:TextField = ComponentUtil.createTextField("",40,int(shieldBg.height * 0.5),tf,shieldBg.width - 80,NaN,shieldBg);
			shieldDesc.wordWrap = true;
			shieldDesc.multiline = true;
			shieldDesc.mouseEnabled = true;
			shieldDesc.htmlText = "<font color=\"#FFFF00\">装备升级功能已经转至『天工炉』，" +
				"请点击打开<a href=\"event:OPEN_STOVE_WINDOW\"><font color=\"#3BE450\"><u>天工炉</u></font></a>升级装备。</font>";
			shieldDesc.addEventListener(TextEvent.LINK,onLinkEvent);
		}
		private function onLinkEvent(event:TextEvent):void{
			if(event.text == "OPEN_STOVE_WINDOW"){
				Dispatch.dispatch(ModuleCommand.OPEN_EQUIP_UPGRADE);
			}
		}
		/**
		 *勾选复选框的操作 
		 * @param evt
		 * 
		 */	
		private var isQulity:Boolean = false;
		private var isRefine:Boolean = false;
		private var isFive:Boolean = false;
		private var isBind:Boolean = false;
		private function onCheckBoxHandler(evt:MouseEvent):void{
			if(updateItem.data){
				if(evt.currentTarget.name == "property"){
					if(checkBox.selected){
						propertyHasTxt.text ="1/"+ totalNum;
						if(attachMaterialId != 0 && bindAttachMaterialId != 0 && (attachMaterialId == bindAttachMaterialId)){
							if(1 == totalNum){
								bind_checkBox.enable = false;
								B_boolean = true;
								textformate(0xff0000,4);
							}
						}
						isQulity = true;
					}else{
						propertyHasTxt.text ="0/"+ totalNum;
						if(attachMaterialId != 0 && bindAttachMaterialId != 0 && (attachMaterialId == bindAttachMaterialId)){
							if(0 <= totalNum){
								bind_checkBox.enable = true;
								textformate(0x00ff00,4);
							}
						}
						isQulity = false;
					}
					textformate(0x00ff00,1);
				}
				if(evt.currentTarget.name == "strenght"){
					if(str_checkBox.selected){
						isRefine = true;
					}else{
						isRefine = false;
					}
					
				}
				if(evt.currentTarget.name == "bind"){
					if(bind_checkBox.selected){
						if(attachMaterialId != 0 && bindAttachMaterialId != 0 && (attachMaterialId == bindAttachMaterialId)){
							bindHasTxt.text ="1/"+ totalNum;
							if(1 == totalNum && equipQulity !=2){
								checkBox.enable = false;
								Q_boolean = true;
								textformate(0xff0000,1);
							}
						}else{
							bindHasTxt.text ="1/"+ bind_totalNum;
						}
						isBind = true;
					}else{
						if(attachMaterialId != 0 && bindAttachMaterialId != 0 && (attachMaterialId == bindAttachMaterialId)){
							bindHasTxt.text ="0/"+ totalNum;
							if(0 <= totalNum && equipQulity !=2){
								checkBox.enable = true;
								textformate(0x00ff00,1);
							}
						}else{
							bindHasTxt.text ="0/"+ bind_totalNum;
						}
						isBind = false;
					}
					textformate(0x00ff00,4);
				}
				if(evt.currentTarget.name == "five"){
					if(five_checkBox.selected){
						isFive = true;
					}else{
						isFive = false;
					}
				}
				ForgeshopModule.getInstance().requestNextLvlEquip(equip_oid,isQulity,isRefine,isFive,isBind);
			}
		}
		
		//画分隔线
		private function drawLine(posX:int,posY:int):void{
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			this.addChild(line);
			line.width = updateHeader.width - 3;
			line.x = posX;
			line.y = posY;
		}
		/**
		 * 设置显示颜色
		 * 1:保留属性
		 * 2:保留强化
		 * 3:保留五行
		 * 4.保留绑定
		 */		
		private function textformate(color:uint,index:int=1):void{
			var formate:TextFormat = new TextFormat("Tahoma",12,color,null,null,null,null,null,TextFormatAlign.CENTER);
			if(index == 1){
				checkBox.textFormat = formate;
				propertyNeedTxt.setTextFormat(formate);
				propertyHasTxt.setTextFormat(formate);
			}
			
			if(index == 2){
				str_checkBox.textFormat = formate;
				strNeedTxt.setTextFormat(formate);
				strHasTxt.setTextFormat(formate);
			}
			
			if(index == 3){
				five_checkBox.textFormat = formate;
				fiveNeedTxt.setTextFormat(formate);
				fiveHasTxt.setTextFormat(formate);
			}
			if(index == 4){
				bind_checkBox.textFormat = formate;
				bindNeedTxt.setTextFormat(formate);
				bindHasTxt.setTextFormat(formate);
			}
			
			
		}
		/**
		 *赋值 
		 * @param equipVo
		 * @param baseArr
		 * 
		 */	
		private var startMaterialId:int;
		private var startAttachId:int;
		private var qulityAttachId:int;
		private var propertyNumber:int = 1;
		private var strengthNumber:int = 1;
		private var fiveNumber:int = 2;
		private var materialVo:p_equip_build_goods;
		private var equip_oid:int;
		private var material_typeId:int;
		private var attachMaterialId:int;
		private var strenghtId:int;
		private var five_attach_id:int;
		private var base_arr:Array = [];
		private var bindAttachMaterialId:int;
		public var isQ:Boolean = false;//是否需要保留品质
		public var isS:Boolean = false;
		public var isB:Boolean = false;
		public var isW:Boolean = false;
		public var Q_boolean:Boolean = false;//有材料但材料不足的情况
		public var S_boolean:Boolean = false;
		public var B_boolean:Boolean = false;
		public var W_boolean:Boolean = false;
		private var canChangeNum:int = 0;
		private var totalNum:int = 0;
		private var bind_totalNum:int=0;
		private var sameAttachID:int = 0;
		private var equipQulity:int = 0;
		public function setData(equipVo:EquipVO,baseArr:Array,attachArr:Array,strengthArr:Array,qualityArr:Array):void{
			isQulity = false;
			isRefine = false;
			isFive = false;
			isBind = false;
			isQ = false;
			isS = false;
			isB = false;
			isW = false;
			Q_boolean = false;//有材料但材料不足的情况
			S_boolean = false;
			B_boolean = false;
			W_boolean = false;
			base_arr = baseArr;
			equip_oid = equipVo.oid;
			var material_attach_arr:Array = ForgeshopUtils.getMaterialIdAndAttachIdByEquipMaterial(equipVo.material);
			startMaterialId = material_attach_arr[0];
			startAttachId = material_attach_arr[1];
			qulityAttachId = material_attach_arr[2];
			
			//获取附加材料(通过品质值)
			equipQulity = equipVo.quality;
			checkBox.enable = false;
			checkBox.selected = false;
			if(equipQulity != 0){
				var attachLvl:int = ForgeshopUtils.getAttachIdByQulity(equipQulity);
				if(attachLvl !=0){
					attachMaterialId = (qulityAttachId - 1) + attachLvl;
					var AttachMaterial:Object = ItemLocator.getInstance().getGeneral(attachMaterialId);
					propertyNeedTxt.text = AttachMaterial.name + "×" + propertyNumber;
					if(qualityArr.length != 0){//背包有附加材料
						for each(var attach_vo:p_equip_build_goods in qualityArr){
							if(attach_vo.type_id == attachMaterialId){
								checkBox.enable = true;
								totalNum = attach_vo.current_num;
								propertyHasTxt.text =canChangeNum+"/"+ String(attach_vo.current_num);
								textformate(0x00ff00,1);
								break;
							}else{
								checkBox.enable = false;
								Q_boolean = true;
								propertyHasTxt.text = "0";
								textformate(0xff0000,1);
							}
						}
					}else{//背包没有附加材料
						checkBox.enable = false;
						Q_boolean = true;
						propertyHasTxt.text = "0";
						textformate(0xff0000,1);
					}
					//绿色精良则不须要保留品质
					if(equipQulity == 2){
						checkBox.enable = false;
						Q_boolean = false;
						propertyNeedTxt.text = "该装备品质不须保留";
						propertyHasTxt.text = "";
						textformate(0x9b9b9b,1);
					}
					
				}else{//普通装备
					checkBox.enable = false;
					propertyNeedTxt.text = "该装备普通装备";
					propertyHasTxt.text = "";
					textformate(0x9b9b9b,1);
				}
				
			}else{
				checkBox.enable = false;
				propertyHasTxt.text = "0";
				textformate(0xff0000,1);
			}
			
			//获取强化石
			str_checkBox.enable = false;
			str_checkBox.selected = false;
			if(equipVo.reinforce_result!=0){
				var currentStrengthLvl:int = equipVo.reinforce_result/10;
				strenghtId = ForgeshopUtils.getStrengthIdByStrenghtLvl(currentStrengthLvl);
				var strenghtItem:Object = ItemLocator.getInstance().getGeneral(strenghtId);
				strNeedTxt.text = strenghtItem.name + "×" +strengthNumber;
				if(strengthArr.length !=0){//背包有强化石
					for each(var strengthVo:p_equip_build_goods in strengthArr){
						if(strengthVo.type_id == strenghtId){
							strHasTxt.text = strengthVo.current_num+"";
							if(strengthVo.current_num < strengthNumber){
								str_checkBox.enable = false;
								S_boolean = true;
								textformate(0xff0000,2);
							}else{
								str_checkBox.enable = true;
								textformate(0x00ff00,2);
							}
							break;
						}else{//有强化石，但没有是合适需要的
							str_checkBox.enable = false;
							S_boolean = true;
							strHasTxt.text = "0";
							textformate(0xff0000,2)
						}
					}
				}else{//没有强化石
					str_checkBox.enable = false;
					S_boolean = true;
					strHasTxt.text = "0";
					textformate(0xff0000,2);
				}
			}else{//没有强化过
				str_checkBox.enable = false;
				S_boolean = false;
				strNeedTxt.text = "该装备没有强化值";
				strHasTxt.text = "";
				textformate(0x9b9b9b,2);
			}
			
			//保留绑定属性
			bind_checkBox.enable = false;
			bind_checkBox.selected = false;
			if(equipVo.bind_arr.length !=0 && equipVo.bind!=false){//是绑定装备，但有绑定属性
				var attach_arr:Array = [];
				for each(var bindVo:p_equip_bind_attr in equipVo.bind_arr){
					attach_arr.push(bindVo.attr_level);
				}
				attach_arr.sort(Array.NUMERIC);
				var attach_level:int = attach_arr[attach_arr.length - 1];
				if(attach_level <= 2){
					attach_level = 1;
				}else{
					attach_level = attach_level -1;
				}
				bindAttachMaterialId = (startAttachId - 1)+attach_level;
				var bindMaterial:Object = ItemLocator.getInstance().getGeneral(bindAttachMaterialId);
				bindNeedTxt.text = bindMaterial.name + "×" + propertyNumber;
				if(attachArr.length !=0){//背包有该材料
					for each(var attach_vo2:p_equip_build_goods in attachArr){
						if(attach_vo2.type_id == bindAttachMaterialId){
							bind_checkBox.enable = true;
							bind_totalNum = attach_vo2.current_num;
							bindHasTxt.text =canChangeNum+"/"+ String(attach_vo2.current_num);
							if(attach_vo2.current_num >=1){
								textformate(0x00ff00,4);
							}else{
								textformate(0xff0000,4);
							}
							break;
						}else{
							bind_checkBox.enable = false;
							B_boolean = true;
							bindHasTxt.text = "0";
							textformate(0xff0000,4);
						}
					}
				}else{//背包没有该材料存在
					bind_checkBox.enable = false;
					B_boolean = true;
					bindHasTxt.text = "0";
					textformate(0xff0000,4);
				}
			}else{//没有绑定属性
				bind_checkBox.enable = false;
				B_boolean = false;
				bindNeedTxt.text = "没有绑定属性";
				bindHasTxt.text = "";
				textformate(0x9b9b9b,4);
			}
			
			//获取五行附加材料
			five_checkBox.enable = false;
			five_checkBox.selected = false;
			var fiveLvl:int = equipVo.five_level;
			if(fiveLvl != 0){
				five_attach_id = (startAttachId - 1) + fiveLvl;
				var fiveItem:Object = ItemLocator.getInstance().getGeneral(five_attach_id);
				fiveNeedTxt.text = fiveItem.name + "×" + fiveNumber;
				if(attachArr.length != 0){//背包有附加材料
					for each(var fiveVO:p_equip_build_goods in attachArr){
						if(fiveVO.type_id == five_attach_id){
							fiveHasTxt.text = fiveVO.current_num+"";
							if(fiveVO.current_num < fiveNumber){//数量不够
								five_checkBox.enable = false;
								W_boolean = true;
								textformate(0xff0000,3);
							}else{
								five_checkBox.enable = true;
								textformate(0x00ff00,3);
							}
							break;
						}else{//附加材料不是所需要的材料
							five_checkBox.enable = false;
							W_boolean = true;
							fiveHasTxt.text = "0";
							textformate(0xff0000,3);
						}
					}
				}else{//背包没有附加材料
					five_checkBox.enable = false;
					W_boolean = true;
					fiveHasTxt.text = "0";
					textformate(0xff0000,3);
				}
			}else{//装备没有五行属性
				five_checkBox.enable = false;
				fiveNeedTxt.text = "该装备没有五行属性";
				textformate(0x9b9b9b,3);
			}
			
		}
		
		/**
		 *新装备 
		 * 
		 */
		private var newEquip_id:int;
		public function setNewEquipData(equipVo:EquipVO,costTxt:TextField):void{
			var material_attach_arr:Array = ForgeshopUtils.getMaterialIdAndAttachIdByEquipMaterial(equipVo.material);
			startMaterialId = material_attach_arr[0];
			startAttachId = material_attach_arr[1];
			
			//获取基础材料
			materialVo = new p_equip_build_goods();
			material_typeId = (startMaterialId - 1) + ForgeshopUtils.getMaterialLvlByEquipLvl(equipVo.equipLvl);
            materialVo.type_id = material_typeId;
			var materialItem:Object = ItemLocator.getInstance().getGeneral(material_typeId);
			materialVo.name = materialItem.name;
			materialVo.needed_num = ForgeshopUtils.getMaterialNeedByEquipLvl(equipVo.equipLvl);
			for each(var vo:p_equip_build_goods in base_arr){
				if(vo.type_id == material_typeId){
					materialVo.current_num = vo.current_num;
				}
			}
            
			baseArray[0] =  materialVo;
			materialGrid.dataProvider = baseArray;
			newEquip_id = equipVo.typeId;
			if(updateItem && updateItem.data){
				updateItem.disposeContent();
			}
			updateItem.data = equipVo;
			//费用		
			costTxt.text = CostManager.equipUpgradeCost(equipVo);//DealConstant.silverToOtherString(equipVo.equipLvl * 100);
			
			//提示玩家升级的装备比玩家当前的等级要高，不能使用
			if(equipVo.equipLvl > GlobalObjectManager.getInstance().user.attr.level){
				tipTxt.visible = true;
			}else{
				tipTxt.visible = false;
			}
		}
		
		
		/**
		 *当该装备无法再升级的时需要处理 (已经最高级别了)
		 * @return 
		 * 
		 */	
		public function heigthestLvl():void{
			checkBox.enable = false;
			textformate(0x9b9b9b,1);
			str_checkBox.enable = false;
			textformate(0x9b9b9b,2);
			five_checkBox.enable = false;
			textformate(0x9b9b9b,3);
			bind_checkBox.enable = false;
			textformate(0x9b9b9b,4);
		}
		
		/**
		 *获取升级数据向服务端请求 
		 * @return 
		 * 
		 */
		public var isSelect_Q:Boolean = false;//是否勾选择了保留品质这一项
		public var isSelect_S:Boolean = false;
		public var isSelect_B:Boolean = false;
		public var isSelect_W:Boolean = false;
		public function getEquipUpdateInfo():m_equip_build_upgrade_tos{
			isSelect_Q = false;
			isSelect_S = false;
			isSelect_B = false;
			isSelect_W = false;
			var updateVo:m_equip_build_upgrade_tos = new m_equip_build_upgrade_tos();
			if(!ForgeshopModule.getInstance().isHasData()){//装备框框没装备
				Tips.getInstance().addTipsMsg("请在装备框放入你想要升级的装备");
				//				Alert.show("请在装备框放入你想要升级的装备!","提示",null,null,"确定","取消",null,false);
				updateVo = null;
			}else if(!ForgeshopModule.getInstance().isUpdateBoxHasData()){
				Tips.getInstance().addTipsMsg("该装备不能升级");
				updateVo = null;
			}else if(materialVo && (materialVo.needed_num > materialVo.current_num)){
				Tips.getInstance().addTipsMsg("基础材料不足");
				updateVo = null;
			}else{//确定该装备一定可以升级且基础材料也足够应付
				updateVo.equip_id = equip_oid;
				updateVo.new_type_id = newEquip_id;
				updateVo.base_type_id = material_typeId;
				if(checkBox.selected){
					updateVo.quality_type_id = attachMaterialId;
					isSelect_Q = true;
				}else {
					updateVo.quality_type_id = 0;
					isSelect_Q = false;
				}
				if(str_checkBox.selected){
					updateVo.reinforce_type_id = strenghtId;
					isSelect_S = true;
				}else{
					updateVo.reinforce_type_id = 0;
					isSelect_S = false;
				}
				if(five_checkBox.selected){
					updateVo.five_ele_type_id = five_attach_id;
					isSelect_W = true;
				}else{
					updateVo.five_ele_type_id = 0;
					isSelect_W = false;
				}
				if(bind_checkBox.selected){
					updateVo.bind_attr_type_id = bindAttachMaterialId;
					isSelect_B = true;
				}else{
					updateVo.bind_attr_type_id = 0;
					isSelect_B = false;
				}
			}
			
			if(checkBox.enable == true||Q_boolean){
				isQ = true;
			}if(str_checkBox.enable == true ||S_boolean){
				isS = true;
			}if(bind_checkBox.enable == true||B_boolean){
				isB = true;
			}if(five_checkBox.enable == true||W_boolean){
				isW = true;
			}
			return updateVo;
		}
		
		/**
		 *清空右边当切换或关闭时，清空所有数据 
		 */
		
		public function cleanAttach():void{
			var formate:TextFormat = new TextFormat("Tahoma",12,0xffffff);
			//保留品质
			checkBox.textFormat = formate;
			checkBox.enable = true;
			checkBox.selected = false;
			propertyNeedTxt.text = "";//消耗数量
			propertyHasTxt.text = "";//当前数量
			
			//保留强化
			str_checkBox.textFormat = formate;
			str_checkBox.enable = true;
			str_checkBox.selected = false;
			strNeedTxt.text = "";
			strHasTxt.text = "";
			
			//保留绑定属性
			bind_checkBox.textFormat = formate;
			bind_checkBox.enable = true;
			bind_checkBox.selected = false;
			bindHasTxt.text = "";
			bindNeedTxt.text = "";
			
			//保留五行属性
			five_checkBox.textFormat = formate;
			five_checkBox.enable = true;
			five_checkBox.selected = false;
			fiveHasTxt.text = "";
			fiveNeedTxt.text = "";
			
		}
		/**
		 *清除基础材料 
		 * 
		 */		
		public function cleanMaterial():void{
			if(materialGrid){
				materialGrid.dataProvider = [];
			}
		}
	}
}