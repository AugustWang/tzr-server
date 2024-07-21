package modules.forgeshop.views
{
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.ComboBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import modules.broadcast.views.Tips;
	import modules.forgeshop.CostManager;
	import modules.forgeshop.ForgeshopModule;
	import modules.forgeshop.views.items.AttachItemRender;
	import modules.forgeshop.views.items.EquipExtendProto;
	import modules.forgeshop.views.items.EquipItemRender;
	import modules.forgeshop.views.items.MaterialItemRender;
	import modules.mypackage.managers.ItemLocator;
	
	import proto.line.*;
	
	
	public class EquipCreateCanvas extends UIComponent
	{	 
	 	private var comboBox:ComboBox;
		private var equipGrid:DataGrid;
		private var materialGrid:DataGrid;
		private var attachGrid:DataGrid;
		private var colorHeader:HeaderBar;
	  
		private var greenTextField:TextField;
		private var blueTextField:TextField;
		private var purpleTextField:TextField;
		private var orangeTextField:TextField;
		private var glodTextField:TextField;
						
		private var startMaterialId:int;
		private var startAttachId:int;
		
		private var equipListDic:Dictionary = new Dictionary(); //缓存装备列表
		private var materialListArray:Array = [];             //需要的基本材料数组
		private var attachListArray:Array = [];               //附加材料数组
		public var base_list:Array = [];            //背包拥有基本材料的数量
		public var attach_list:Array = [];             //背包拥有附加材料的数量
		
		//打造的价格
//		public static const EQUIPBUILD_EXPENSE:Array = [10,100,500,1100,2200,3300,4400,5500,6600,7700,8800,9900,11000,12300,13400,14500,15600,17800,19000,21000];
		public function EquipCreateCanvas(w:Number = NaN, h:Number = NaN)	{
			super();
			this.name = "EquipCreateCanvas";
			init();
		}
		
		/**
		 *初始化DataGrid 
		 * 
		 */	
		private function createGrid($width:int,$height:int,posX:int,posY:int,pageCount:int,isOpenScroll:Boolean = true):DataGrid{
			var dataGrid:DataGrid = new DataGrid();
			this.addChild(dataGrid);
			dataGrid.width = $width;
			dataGrid.height = $height;
			dataGrid.x = posX;
			dataGrid.y = posY;
			dataGrid.itemHeight = 25;
			dataGrid.pageCount = pageCount;
			if(isOpenScroll){
				dataGrid.verticalScrollPolicy = ScrollPolicy.ON;
			}else{
				dataGrid.verticalScrollPolicy = ScrollPolicy.OFF;
			}
			return dataGrid;
		}
		
		private function init():void{ 
			//-等级下拉框
			comboBox = new ComboBox();
			addChild(comboBox);
			comboBox.x = 177;
			comboBox.y = 3;
			comboBox.width = 83;
			comboBox.height = 20;
			comboBox.dataProvider = ForgeshopUtils.createGradeSegment(); 
			if(GlobalObjectManager.getInstance().user.attr.level >=100){
				comboBox.selectedIndex = 9;
			}else{
				comboBox.selectedIndex = GlobalObjectManager.getInstance().user.attr.level/10;
			}
			comboBox.addEventListener(Event.CHANGE, onComboBoxChangeHandler);
			
			//左绿色背景
			var backUI:Sprite = Style.getBlackSprite(271,256,2);
			this.addChild(backUI);
			backUI.x = 0;
			backUI.y = comboBox.y + comboBox.height + 3;
			
			//装备列表
			equipGrid = this.createGrid(271,253,0,comboBox.y + comboBox.height + 3,10,true);
			equipGrid.addColumn("装备类型",80);
			equipGrid.addColumn("装备名称",110);
			equipGrid.addColumn("装备等级",80);
			equipGrid.itemRenderer = EquipItemRender;
			equipGrid.list.addEventListener(ItemEvent.ITEM_CLICK,onEquipListClickHandler);
			
			
			//需要材料（右边）
//			materialGrid = this.createGrid(266,40,equipGrid.x + equipGrid.width+2,2,0,false);
//			materialGrid.addColumn("基础材料",88);
//			materialGrid.addColumn("消耗数量",60);
//			materialGrid.addColumn("拥有数量",60);
//			materialGrid.itemRenderer = MaterialItemRender;
//			materialGrid.bgSkin = new Skin();
//			materialGrid.list.selected = false;
//			/*materialGrid.mouseChildren =*/ materialGrid.mouseEnabled = false;
			
			//附加材料
			attachGrid = this.createGrid(266,212,equipGrid.x + equipGrid.width+2,2,0,false);
			attachGrid.addColumn("附加材料",88);
			attachGrid.addColumn("消耗数量",60);
			attachGrid.addColumn("拥有数量",60);
			attachGrid.itemRenderer = AttachItemRender;
			attachGrid.list.addEventListener(MouseEvent.CLICK,onAttachListClickHandler);
			
			//颜色
			colorHeader = new HeaderBar();
			this.addChild(colorHeader);
			colorHeader.x = attachGrid.x;
			colorHeader.y = attachGrid.y + attachGrid.height;
			colorHeader.width = 266;
			colorHeader.height = 23;
			colorHeader.addColumn("绿色",54);
			colorHeader.addColumn("蓝色",54);
			colorHeader.addColumn("紫色",54);
			colorHeader.addColumn("橙色",54);
			colorHeader.addColumn("金色",54);
			colorHeader.mouseChildren = false;
			colorHeader.mouseEnabled = false;
			colorHeader.visible = false;
			
			//百分比
		 	var textFormate:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
			greenTextField = ComponentUtil.createTextField("",colorHeader.x,colorHeader.y+colorHeader.height,textFormate,54,23,this);
			blueTextField = ComponentUtil.createTextField("",greenTextField.x + greenTextField.width,colorHeader.y+colorHeader.height,textFormate,54,23,this);	
			purpleTextField= ComponentUtil.createTextField("",blueTextField.x + blueTextField.width,colorHeader.y+colorHeader.height,textFormate,54,23,this);	
			orangeTextField= ComponentUtil.createTextField("",purpleTextField.x + purpleTextField.width,colorHeader.y+colorHeader.height,textFormate,54,23,this);
			glodTextField = ComponentUtil.createTextField("",orangeTextField.x + orangeTextField.width,colorHeader.y+colorHeader.height,textFormate,54,23,this);	
			greenTextField.mouseEnabled = blueTextField.mouseEnabled = false;
			purpleTextField.mouseEnabled = orangeTextField.mouseEnabled = false;
			glodTextField.mouseEnabled = greenTextField.mouseEnabled = false;
			
			var tipTxt:TextField = ComponentUtil.createTextField("打造材料可在杂货铺购买，使用高级的附加材料将更容易获得高属性的装备",attachGrid.x,attachGrid.y + attachGrid.height+8,null,266,33,this);
			tipTxt.textColor = 0xffcc00;
			tipTxt.wordWrap = true;
			tipTxt.multiline = true;
			
		}
		
		/**
		 *下拉框事件，请求拥有材料列表 
		 */		
		private var cnt:int = 0;
		private function onComboBoxChangeHandler(event:Event):void{
			if(cnt != 0){
				if(attachIndex != -1){
					AttachItemRender(attachGrid.list.getChildAt(attachIndex)).checkBox.selected = false;
				}
				selectedIndex = attachIndex = -1;
				equipGrid.list.selectedIndex = -1;
				attachGrid.list.selectedIndex = -1;
				attachGrid.list.selectedItem = null;
				isSelcted = false;
				requestBuildEquipList(String(comboBox.selectedIndex + 1));  //请求打造装备列表
				equipGrid.list.selectedItem = null;
				cleanEquipCreateMaterial();
			}
			cnt++;
		}
		
		/**
		 *点击装备列表项事件，请求拥有材料列表  
		 */		
		private var selectedIndex:int = -1;
		private function onEquipListClickHandler(event:ItemEvent):void{
			if(event.selectItem == null){
				return;
			}
			selectedIndex = equipGrid.list.selectedIndex;
			showMaterialAndAttachMaterial();
		}
		
		
		/**
		 * 设置当前拥有材料列表的数据
		 * @param vo
		 * 
		 */		
		public function setCurrentMaterialList(baselist:Array,addlist:Array):void{
			if(ForgeshopWindows.isOpen){
				ForgeshopWindows.isOpen = false;
				if(GlobalObjectManager.getInstance().user.attr.level >=100){
					comboBox.selectedIndex = 9;
				}else{
					comboBox.selectedIndex = GlobalObjectManager.getInstance().user.attr.level/10;
				}
			}
			base_list = baselist;
			attach_list = addlist;
			showMaterialAndAttachMaterial(); 
			requestBuildEquipList(String(comboBox.selectedIndex + 1));  //请求打造装备列表
		}	
		
		/**
		 * 请求打造装备列表信息 
		 * @param buildLevel（装备的级别段）
		 * 
		 */		
		private function requestBuildEquipList(buildLevel:String):void{
			/*if(equipListDic.hasOwnProperty(buildLevel)){		 
				equipGrid.dataProvider =  equipListDic[buildLevel] as Array;	
			}else{	*/			
				ForgeshopModule.getInstance().requestBuildEquipList(int(buildLevel));
//			}
		}		
		/**
		 * 设置装备列表的数据
		 * @param vo
		 * 
		 */		
		public function setBuildEquipList(data:Object,costTxt:TextField):void{
			if(data != null){
				costTxt.text = CostManager.equipCreateCost(comboBox.selectedIndex);//DealConstant.silverToOtherString(EQUIPBUILD_EXPENSE[comboBox.selectedIndex]);
				var vo :m_equip_build_list_toc = data as m_equip_build_list_toc;
				var buildArray:Array = [];
				for each(var equipVO:p_equip_build_equip in vo.build_list){ 
					var equipExtendProto :EquipExtendProto = new EquipExtendProto();
					equipExtendProto.build_equip = equipVO;
					equipExtendProto.level = vo.build_level;
					equipExtendProto.base_list = base_list;
					buildArray.push(equipExtendProto);
				}
				equipListDic[vo.build_level] = buildArray;				
				equipGrid.dataProvider = buildArray;
				if(selectedIndex != -1){
					equipGrid.list.selectedIndex = selectedIndex;
				}
			}
		}
		
		/**
		 *点击附加材料列表项的事件(包括选中复选择按钮和显示百分比) 
		 */		
		public var isSelcted:Boolean = false;
		private var currentNum:int;//保存选中项的拥有数量
		private var selectEuquipId:int;//保存选中项的typeID
		private var attchRender:AttachItemRender;
		private var isBool:Boolean = false;
		public function onAttachListClickHandler(evt:MouseEvent = null):void{
			var equip:EquipExtendProto = equipGrid.list.selectedItem as EquipExtendProto;
			var attach:p_equip_build_goods = attachGrid.list.selectedItem as p_equip_build_goods;
			if(equip == null||attach == null){
				return;
			}
			if(attchRender){
				if(attchRender == attachGrid.list.getItemByData(attachGrid.list.selectedItem) as AttachItemRender){
					attchRender.checkBox.selected = !isBool;//操作的是同一个checkBox
				}else{//选择另外一个checkBox
					attchRender.checkBox.selected = false;
				}
				attchRender = null;
				isSelcted = false;
			}
			attchRender = attachGrid.list.getItemByData(attachGrid.list.selectedItem) as AttachItemRender;
			isBool = attchRender.checkBox.selected;
			if(attchRender.checkBox.selected){
				attachIndex = attachGrid.list.selectedIndex;
				isSelcted = true;
				currentNum = attachGrid.list.selectedItem.current_num;
				selectEuquipId = attachGrid.list.selectedItem.type_id;
//				ForgeshopUtils.changeColorPercentage(ForgeshopUtils.getAttachGrade(equip.build_equip.material,attachGrid.list.selectedItem.type_id),greenTextField,blueTextField,purpleTextField,orangeTextField,glodTextField);
			}else{
				attachIndex = -1;
//				ForgeshopUtils.changeColorPercentage(0,greenTextField,blueTextField,purpleTextField,orangeTextField,glodTextField);
			}
		}		
		
		/**
		 * 根据品质改变材料列表 
		 * @param material
		 * 
		 */		
		private function showMaterialAndAttachMaterial():void{
			var equip:EquipExtendProto = equipGrid.list.selectedItem as EquipExtendProto;
		  if(equip != null){
			  //获取到基础材料和附加材料的ID
			  var materail_attach_arr:Array = ForgeshopUtils.getMaterialIdAndAttachIdByEquipMaterial(equip.build_equip.material);
			  startMaterialId = materail_attach_arr[0];
			  startAttachId = materail_attach_arr[1];
			
			var materialVO:p_equip_build_goods = new p_equip_build_goods();
			//需要的材料
			materialVO.type_id = (startMaterialId -1) + ForgeshopUtils.getMaterialGradeBySegment(comboBox.selectedIndex + 1);
			var item:Object = ItemLocator.getInstance().getGeneral(materialVO.type_id);
			materialVO.name =  item.name;
			//需要消耗的材料
			materialVO.needed_num = ForgeshopUtils.getNeededNumberBySegment(comboBox.selectedIndex + 1);
			
			for each(var baseVO:p_equip_build_goods in base_list){  //当前拥有基础材料的数量
				if(baseVO.type_id == materialVO.type_id )
					materialVO.current_num = baseVO.current_num;
			}
			//基本材料
			materialListArray[0] = materialVO;
			
			for(var i:int=0;i<=5;i++){
				var attachVO:p_equip_build_goods = new p_equip_build_goods();
				attachVO.type_id = startAttachId + i;
				item = ItemLocator.getInstance().getGeneral(attachVO.type_id);
				attachVO.name = item.name;
				attachVO.needed_num = 1;
				for each(var addVO:p_equip_build_goods in attach_list){  //当前拥有附加材料的数量
					if(addVO.type_id == attachVO.type_id )
						attachVO.current_num = addVO.current_num;
				}
				//附加材料
				attachListArray[i]= attachVO;
			}
		 	
			//给需要的材料和附加材料两Grid赋值
			
//			materialGrid.dataProvider = materialListArray;
			attachGrid.dataProvider = attachListArray;
			if(attachIndex != -1){
				attachGrid.list.selectedItem = attachListArray[attachIndex];
				attachGrid.list.validateNow();
				AttachItemRender(attachGrid.list.getChildAt(attachIndex)).checkBox.selected = true;
				isBool = false;
				onAttachListClickHandler();
			}
		  }
		}
		
		/**
		 * 获取打造信息 提交给服务端
		 * @return 
		 * 
		 */
		private var attachIndex:int = -1;
		private var attachItem:AttachItemRender = null;
		public function getEquipBuildInfo():m_equip_build_build_tos{
			var equip_build_tos : m_equip_build_build_tos = new m_equip_build_build_tos();
			if(equipGrid.list.selectedItem == null){
				Tips.getInstance().addTipsMsg("请选择要打造的装备！");
//				Alert.show("请选择要打造的装备！","提示",null,null,"确定","取消",null,false);
				return null;
			}	
			
			//获取所需要量打造的装备的ID和等级段
			var equip:EquipExtendProto = equipGrid.list.selectedItem as EquipExtendProto;	
			equip_build_tos.equip_type_id = equip.build_equip.type_id;
			equip_build_tos.build_level = comboBox.selectedIndex + 1;
			
			//获取需要的材料的ID
//				var material:p_equip_build_goods =  materialListArray[0] as p_equip_build_goods;				
//				if(material.current_num < material.needed_num){
//					Tips.getInstance().addTipsMsg(material.name + "的数量不足！");
////					Alert.show( material.name + "的数量不足！","提示",null,null,"确定","取消",null,false);
//					return null;
//				}
//				equip_build_tos.base_type_id = material.type_id;
			
			//获得附加材料的信息
			if(isSelcted){
				isSelcted = false;
				if(currentNum <1){
					Tips.getInstance().addTipsMsg("选择的附加材料数量不足！");
//					Alert.show("选择的附加材料数量不足！","提示",null,null,"确定","取消",null,false);
					isSelcted = true;
					return null;
				}else{
					equip_build_tos.add_type_id = selectEuquipId;
				}
			}
			return equip_build_tos;
		}
		
		/**
		 *清除右边的数据 
		 */		
		public function cleanEquipCreateMaterial():void{
			if(materialGrid){
				materialGrid.dataProvider = [];
			}
			if(attachGrid){
				attachGrid.dataProvider = [];
			}
			
//			ForgeshopUtils.changeColorPercentage(0,greenTextField,blueTextField,purpleTextField,orangeTextField,glodTextField);
		}
	}
}