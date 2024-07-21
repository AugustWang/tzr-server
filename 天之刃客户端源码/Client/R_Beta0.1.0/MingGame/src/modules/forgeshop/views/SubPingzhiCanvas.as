package modules.forgeshop.views {

	import com.components.DataGrid;
	import com.components.HeaderBar;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.finery.MaterialID;
	import modules.forgeshop.CostManager;
	import modules.forgeshop.ForgeshopModule;
	import modules.forgeshop.views.items.AttachItemRender;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.EquipVO;
	
	import proto.line.m_equip_build_quality_tos;
	import proto.line.p_equip_build_goods;

	/**
	 * 品质改造
	 * @author
	 *
	 */

	public class SubPingzhiCanvas extends UIComponent {
		private var attachGrid:DataGrid;
		private var headerBar:HeaderBar;
		private var attachArr:Array=[];
		private var commonText:TextField;
		private var fineText:TextField;
		private var wellText:TextField;
		private var bestText:TextField;
		private var perfectText:TextField;
		public static var gray_arr:Array=[];
		public static var yellow_arr:Array=[];
		private var iconSprite:Sprite;

		public function SubPingzhiCanvas() {
			super();
			this.name="SubPingzhiCanvas";
			//灰色图标的数组
			for (var i:int=1; i < 6; i++) {
				gray_arr.push(Style.getBitmap(GameConfig.T1_VIEWUI,"quality_0" + i));
				yellow_arr.push(Style.getBitmap(GameConfig.T1_VIEWUI,"quality_00" + i));
			}
			//黄色图标的数组
			init();
		}

		private function init():void {
			//附加材料
			attachGrid=new DataGrid();
			this.addChild(attachGrid);
			attachGrid.x=0;
			attachGrid.y=0;
			attachGrid.width=266;
			attachGrid.height=172;
			attachGrid.addColumn("附加材料", 88);
			attachGrid.addColumn("消耗数量", 60);
			attachGrid.addColumn("拥有数量", 60);
			attachGrid.itemHeight=25;
			attachGrid.itemRenderer=AttachItemRender;
			attachGrid.verticalScrollPolicy=ScrollPolicy.OFF;
			attachGrid.pageCount=7;
			attachGrid.list.addEventListener(MouseEvent.CLICK, onClickHandler);

			iconSprite=new Sprite();
			this.addChild(iconSprite);
			iconSprite.mouseChildren=iconSprite.mouseEnabled=false;
			iconSprite.x=attachGrid.x+25;
			iconSprite.y=attachGrid.y + attachGrid.height + 10;
			for each (var bitmap:Bitmap in gray_arr) {
				iconSprite.addChild(bitmap);
			}
			LayoutUtil.layoutHorizontal(iconSprite, 10, 2);

//			品质
		/*headerBar = new HeaderBar();
		   this.addChild(headerBar);
		   headerBar.width = 266;
		   headerBar.height = 23;
		   headerBar.addColumn("普通",54);
		   headerBar.addColumn("精良",54);
		   headerBar.addColumn("优质",54);
		   headerBar.addColumn("无暇",54);
		   headerBar.addColumn("完美",54);
		   headerBar.x = attachGrid.x;
		   headerBar.y = attachGrid.y + attachGrid.height + 10;
		   headerBar.mouseChildren = headerBar.mouseEnabled = false;
		   headerBar.visible = false;

		   var textformate:TextFormat = new TextFormat("Tahoma",12,0xffffff,null,null,null,null,null,TextFormatAlign.CENTER);
		   commonText = ComponentUtil.createTextField("",headerBar.x,headerBar.y + headerBar.height,textformate,54,30,this);
		   fineText = ComponentUtil.createTextField("",commonText.x + commonText.width,commonText.y,textformate,54,30,this);
		   wellText = ComponentUtil.createTextField("",fineText.x + fineText.width,fineText.y,textformate,54,30,this);
		   bestText = ComponentUtil.createTextField("",wellText.x + wellText.width,wellText.y,textformate,54,30,this);
		 perfectText = ComponentUtil.createTextField("",bestText.x + bestText.width,bestText.y,textformate,54,30,this);*/
		}

		private var isSelcted:Boolean=false;
		private var currentNum:int; //当前拥有的数量
		private var attchRender:AttachItemRender;
		private var selectMaterialId:int; //先遣材料的ID
		private var material_lvl:int;

		/**
		 *单击材料会加列表的操作
		 * @param evt
		 *
		 */
		private var isBool:Boolean=false;
		private var moneyTxt:TextField;
		private var attachIndex:int=-1;

		public function onClickHandler(evt:MouseEvent=null):void {
			if (attachGrid.list.selectedItem == null) {
				return;
			}
			MaterialID.getInstance().typeId=attachGrid.list.selectedItem.type_id;
			material_lvl=MaterialID.getInstance().material_lvl;
			if (ForgeshopModule.getInstance().isHasData()) {
				/*var money:int = equipLvl*Math.pow(material_lvl,3)*2;
				 moneyTxt.text = DealConstant.silverToOtherString(money);*/
				moneyTxt.text=CostManager.qulityChangeCost(equipLvl, material_lvl);
			} else {
				moneyTxt.text=DealConstant.silverToOtherString(0);
			}

			if (attchRender) {
				if (attchRender == attachGrid.list.getItemByData(attachGrid.list.selectedItem) as AttachItemRender) {
					attchRender.checkBox.selected=!isBool;
				} else {
					attchRender.checkBox.selected=false;
				}
				attchRender=null;
				isSelcted=false;
			}
			attchRender=attachGrid.list.getItemByData(attachGrid.list.selectedItem) as AttachItemRender;
			isBool=attchRender.checkBox.selected;
			if (attchRender.checkBox.selected) {
				isSelcted=true;
				attachIndex=attachGrid.list.selectedIndex;
				currentNum=attachGrid.list.selectedItem.current_num;
				selectMaterialId=attachGrid.list.selectedItem.type_id;
				//品质的百分比
				ForgeshopUtils.qualityPercent(iconSprite, ForgeshopUtils.getAttachGrade(materialkind, attachGrid.list.selectedItem.
					type_id) /*,commonText,fineText,wellText,bestText,perfectText*/);
			} else {
				ForgeshopUtils.qualityPercent(iconSprite, 0 /*,commonText,fineText,wellText,bestText,perfectText*/);
				attachIndex=-1;
			}

		}
		//给品质的附加列表加数据
		private var startAttachId:int;
		private var materialkind:int;
		private var equipLvl:int;
		private var euqip_id:int;

		public function setListData(array:Array, equipVo:EquipVO, costTxt:TextField):void {
			materialkind=equipVo.material;
			if (materialkind == 0) {
				return;
			}
			equipLvl=equipVo.equipLvl;
			euqip_id=equipVo.oid;
			moneyTxt=costTxt;
			startAttachId=10404001; // 品质石

			for (var i:int=0; i < 6; i++) {
				var attchVo:p_equip_build_goods=new p_equip_build_goods();
				attchVo.type_id=startAttachId + i;
				var item:Object=ItemLocator.getInstance().getGeneral(attchVo.type_id);
				attchVo.name=item.name;
				attchVo.needed_num=1;

				for each (var addVO:p_equip_build_goods in array) {
					if (addVO.type_id == attchVo.type_id) {
						attchVo.current_num=addVO.current_num;
					}
				}
				attachArr[i]=attchVo;
			}

			attachGrid.dataProvider=attachArr;
			if (attachIndex != -1) {
				attachGrid.list.selectedItem=attachArr[attachIndex];
				attachGrid.list.validateNow();
				(attachGrid.list.getChildAt(attachIndex) as AttachItemRender).checkBox.selected=true;
				isBool=false;
				onClickHandler();
			}


			//费用

			//moneyTxt.text = DealConstant.silverToOtherString(0);*/
		}


		/**
		 * 获取信息向服务端提交
		 */
		public function getEquipChangeInfo():m_equip_build_quality_tos {
			var m_equip_change_tos:m_equip_build_quality_tos=new m_equip_build_quality_tos();
			if (!ForgeshopModule.getInstance().isHasData()) {
				Tips.getInstance().addTipsMsg("请在装备框里放上你要提升品质的装备");
//				Alert.show("请在装备框里放上你要提升品质的装备","提示",null,null,"确定","取消",null,false);
				m_equip_change_tos=null;
				return m_equip_change_tos;
			}
			if (isSelcted) {
				if (currentNum < 1) {
					Tips.getInstance().addTipsMsg("选择的附加材料数量不足");
//					Alert.show("选择的附加材料数量不足！","提示",null,null,"确定","取消",null,false);
					checkBoxState(true);
					m_equip_change_tos=null;
				} else {
					checkBoxState();
					m_equip_change_tos.equip_id=euqip_id;
					m_equip_change_tos.add_type_id=selectMaterialId;
				}
			} else {
				Tips.getInstance().addTipsMsg("请选择附加材料");
				m_equip_change_tos=null;
			}
			return m_equip_change_tos;
		}

		public function checkBoxState(bool:Boolean=false):void {
			isSelcted=bool;
			attchRender.checkBox.selected=bool;
		}

		/**
		 *清除右边的数据
		 */

		public function cleanAttach():void {
			if (attachGrid) {
				attachGrid.dataProvider=[];
			}
			ForgeshopUtils.qualityPercent(iconSprite, 0 /*,commonText,fineText,wellText,bestText,perfectText*/);
		}
	}

}