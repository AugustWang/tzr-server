package modules.forgeshop.views
{
 
	import com.components.DataGrid;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.forgeshop.CostManager;
	import modules.forgeshop.ForgeshopModule;
	import modules.forgeshop.views.items.WuxingItemRender;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.EquipVO;
	
	import proto.line.m_equip_build_fiveele_tos;
	import proto.line.p_equip_build_goods;
	
	public class SubWuxinggCanvas extends UIComponent{
		private var attachGrid:DataGrid;
		public function SubWuxinggCanvas(){
			super();
			init();
		}
		
		private function init():void{
			var titleTextField:TextField = ComponentUtil.createTextField("\t使用五行珠刷新所有五行属性类型，使用附加材料只刷新属性范围。",5,3,new TextFormat("Tahoma",12,0xffcc00),265,50,this);
			titleTextField.wordWrap = true;
			
			attachGrid = new DataGrid();
			this.addChild(attachGrid);
			attachGrid.x = titleTextField.x - 4;
			attachGrid.y = titleTextField.y + titleTextField.textHeight + 10;
			attachGrid.width = 266;
			attachGrid.height = 168;
			attachGrid.addColumn("改造材料",88);
			attachGrid.addColumn("消耗数量",88);
			attachGrid.addColumn("拥有数量",88);
			attachGrid.itemHeight = 25;
			attachGrid.itemRenderer = WuxingItemRender;
			attachGrid.verticalScrollPolicy = ScrollPolicy.OFF;
			attachGrid.pageCount = 6;
			attachGrid.list.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
		}
		
		private var moneyTxt:TextField;
		private var isBool:Boolean = false;
		private var attchRender:WuxingItemRender;
		private var isSelect:Boolean = false;
		private var attachId:int;
		private var currentIndex:int = -1;
		private function onMouseClickHandler(evt:MouseEvent = null):void{
			if(attachGrid.list.selectedItem == null)return;
			if(WuxingItemRender(attachGrid.list.getItemByData(attachGrid.list.selectedItem)).checkBox.enable == false )return;
			if(attchRender){
				if(attchRender == attachGrid.list.getItemByData(attachGrid.list.selectedItem) as WuxingItemRender){
					attchRender.checkBox.selected = !isBool;
				}else{
					attchRender.checkBox.selected = false;
				}
				attchRender = null;
				isSelect = false;
			}
			attchRender = attachGrid.list.getItemByData(attachGrid.list.selectedItem) as WuxingItemRender;
			isBool = attchRender.checkBox.selected;
			if(attchRender.checkBox.selected){
				isSelect = true;
				currentIndex = attachGrid.list.selectedIndex;
				attachId = p_equip_build_goods(attachGrid.list.selectedItem).type_id;
				moneyTxt.text = CostManager.wuXingChangeCost(equipInfo,attachId);
			}else{
				currentIndex = attachGrid.list.selectedIndex = -1;
				moneyTxt.text = DealConstant.silverToOtherString(0);
			}
			
		}
		
		//1：金  2木：3  水：4  火  5：土
		private var startAttachId:int;
		private var attachArr:Array = [];
		private var equipInfo:EquipVO;
		private var five_num:int;//当前五行珠的数量
		public function setData(equipVo:EquipVO,attachList:Array,fiveStoneVo:p_equip_build_goods,costTxt:TextField):void{
			if(equipInfo /*&& equipInfo != equipVo*/){
				if(attachGrid){
					currentIndex = attachGrid.list.selectedIndex = -1;
					isSelect = false;
					moneyTxt.text = DealConstant.silverToOtherString(0);
				}
			}
			equipInfo = equipVo;
			moneyTxt = costTxt;
			switch(equipVo.material){
				case 1://金
					startAttachId = 10402122;//弦铁	
					break;
				case 2://木
					startAttachId = 10402222;//檀木
					break;
				case 3://皮
					startAttachId = 10402322;//硬皮
					break;
				case 4://布
					startAttachId = 10402422;//丝绸	
					break;
				case 5://玉
					startAttachId = 10402522;//翡翠	
					break;
			}
			//五行珠的信息
			var attchVo:p_equip_build_goods = new p_equip_build_goods();
			attchVo.name = "五行珠";
			attchVo.current_num = fiveStoneVo.current_num;
			five_num = fiveStoneVo.current_num;
			attchVo.needed_num = 1;
			attchVo.type_id = fiveStoneVo.type_id;
			attachArr[0] = attchVo;
			for(var i:int=1;i<=4;i++){
				attchVo = new p_equip_build_goods();
				attchVo.type_id = startAttachId + i;
				var item:Object = ItemLocator.getInstance().getGeneral(attchVo.type_id);
				attchVo.name = item.name;
				attchVo.needed_num = 5;
				
				for each(var addVO:p_equip_build_goods in attachList){
					if(addVO.type_id == attchVo.type_id){
						attchVo.current_num = addVO.current_num;
					}
				}
				attachArr[i] = attchVo;
			}
			
			attachGrid.dataProvider = attachArr;
			if(currentIndex !=-1){
				attachGrid.list.selectedItem = attachArr[currentIndex];
				attachGrid.list.validateNow();
				(attachGrid.list.getChildAt(currentIndex) as WuxingItemRender).checkBox.selected = true;
				onMouseClickHandler();
			}
		}
		
		/**
		 *向服务端请求数据 
		 * @return 
		 * 
		 */		
		public function getEquipWuXingInfo():m_equip_build_fiveele_tos{
			var vo:m_equip_build_fiveele_tos = new m_equip_build_fiveele_tos();
			if(!ForgeshopModule.getInstance().isHasData()){
				Tips.getInstance().addTipsMsg("请在装备框里放上你要提升品质的装备");
				return vo = null;
			}
			
			if(isSelect){
				vo.equip_id = equipInfo.oid;
				vo.good_type_id = attachId;
				if(attachId == 23200001){// 五行珠 1.第一次，2.重洗，3.升级
					if(equipInfo.five_arr.id != 0){//有五行属性
						vo.type = 2;
					}else{//没有五行属性
						vo.type = 1;
					}
				}else{
					if(equipInfo.five_arr.id != 0){
						vo.type = 3;
					}else{
						Tips.getInstance().addTipsMsg("当前装备没有五行属性，无法提升");
						vo = null;
					}
				}
			}else{
				if(equipInfo.five_arr.id == 0){//该装备没有五行属性
					if(five_num < 1){//没有五行珠
						Tips.getInstance().addTipsMsg("五行珠数量不足,无法五行改造");
					}else{//有五行珠
						Tips.getInstance().addTipsMsg("请选择五行珠进行改造");
					}
				}else{//有五行属性
					Tips.getInstance().addTipsMsg("请选择你需要附加材料进行五行改造，提升五行级别");
				}
				vo = null;
			}
			return vo;
		}
		
		public function checkBoxState(bool:Boolean = false):void{
			isSelect = bool;
			attchRender.checkBox.selected = bool;
		}
		
		/**
		 *清除右边的数据 
		 */		
		public function cleanData():void{
			if(attachGrid){
				attachGrid.dataProvider = [];
				attachGrid.list.selectedIndex = -1;
//				moneyTxt.text = "";
			}
		}
	}
}