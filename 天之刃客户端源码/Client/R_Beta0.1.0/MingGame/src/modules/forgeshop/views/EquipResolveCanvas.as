package modules.forgeshop.views
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.broadcast.views.Tips;
	import modules.deal.DealConstant;
	import modules.forgeshop.CostManager;
	import modules.forgeshop.ForgeshopModule;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.EquipVO;
	
	import proto.line.m_equip_build_decompose_tos;

	/**
	 * 装备分解
	 * @author
	 * 
	 */	
	public class EquipResolveCanvas extends UIComponent{
		
		public function EquipResolveCanvas()
		{
			super();
			init();
		}
		private var tip_txt:TextField;
		
		private var attachName1:TextField;
		private var attachName2:TextField;
		private var attachName3:TextField;
		private var attachName4:TextField;
		private var attachPercent1:TextField;
		private var attachPercent2:TextField;
		private var attachPercent3:TextField;
		private var attachPercent4:TextField;
		private var textformate:TextFormat = new TextFormat("Tahoma",12,0x00ff00);
		private function init():void{
			var titleTextField:TextField = ComponentUtil.createTextField("分解该装备将有机会获得以下材料",8,5,new TextFormat("Tahoma",12,0xffcc00),260,30,this);
			titleTextField.wordWrap = true;
			

			var titletFormat:TextFormat = new TextFormat("Tahoma",12,0xFF5809);

			var lineSprite2:Bitmap= Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			this.addChild(lineSprite2);
			lineSprite2.width = 254;
			lineSprite2.x = titleTextField.x;
			lineSprite2.y = titleTextField.y + titleTextField.textHeight + 15; 
			var title2_txt:TextField = ComponentUtil.createTextField("可以获得以下附加材料",lineSprite2.x,lineSprite2.y + 10,titletFormat,210,20,this);
			attachName1 = ComponentUtil.createTextField("",title2_txt.x + 10,title2_txt.y + title2_txt.height,textformate,100,20,this);
			attachName2 = ComponentUtil.createTextField("",attachName1.x,attachName1.y + attachName1.height,textformate,100,20,this);
			attachName3 = ComponentUtil.createTextField("",attachName2.x,attachName2.y + attachName2.height,textformate,100,20,this);
			attachName4 = ComponentUtil.createTextField("",attachName3.x,attachName3.y + attachName3.height,textformate,100,20,this);
			
			attachPercent1 = ComponentUtil.createTextField("",attachName1.x + attachName1.width + 20,attachName1.y ,textformate,50,20,this);
			attachPercent2 = ComponentUtil.createTextField("",attachName2.x + attachName2.width + 20,attachName2.y ,textformate,50,20,this);
			attachPercent3 = ComponentUtil.createTextField("",attachName3.x + attachName3.width + 20,attachName3.y ,textformate,50,20,this);
			attachPercent4 = ComponentUtil.createTextField("",attachName4.x + attachName4.width + 20,attachName4.y ,textformate,50,20,this);
			
			tip_txt = ComponentUtil.createTextField("",title2_txt.x+10,attachName4.y + attachName4.height + 18,new TextFormat("Tahoma",12,0xD200D2),240,30,this);
		}
		
		private var equipLvl:int;
		private var startMaterialId:int;
		private var startAttachId:int;
		private var equipId:int = -1;
		private var equipColor:int = 3;//1白 2绿 3蓝 4紫 5橙 6金
		public function setData(equipVo:EquipVO,costText:TextField):void{
			equipLvl = equipVo.equipLvl;
			equipId = equipVo.oid;
			equipColor = equipVo.color;
			if(equipColor < 3){
				tip_txt.text = "* 只有蓝色或蓝色以上的装备才能分解";
				cleanRemoveData();
				return;
			}
			tip_txt.text = "";
			var material_attach_arr:Array = ForgeshopUtils.getMaterialIdAndAttachIdByEquipMaterial(equipVo.material);
			startMaterialId = material_attach_arr[0];
			startAttachId = material_attach_arr[1];
			
			
			var attach_typeId1:int;
			var attach_typeId2:int;
			var attach_typeId3:int;
			var attach_typeId4:int;
			
			//附加材料
			var refine_index:int = equipVo.refine_index;
			if(refine_index <=15){
				attachName1.text = ItemLocator.getInstance().getGeneral(startAttachId).name;
				attachName2.text = ItemLocator.getInstance().getGeneral(startAttachId + 1).name;
				attachName3.text = "";
				attachName4.text = "";
				
				attachPercent1.text = ""//"2.5%";
				attachPercent2.text = ""//"0.5%";
				attachPercent3.text = "";
				attachPercent4.text = "";
				if(refine_index>=6){
					attachName3.text = ItemLocator.getInstance().getGeneral(startAttachId + 2).name;
					attachPercent1.text = ""//"30%";
					attachPercent2.text = ""//"20%";
					attachPercent3.text = ""//"10%";
				}if(refine_index >=11){
					attachName4.text = ItemLocator.getInstance().getGeneral(startAttachId + 3).name;
					attachPercent1.text = ""//"40%";
					attachPercent2.text = ""//"30%";
					attachPercent3.text = ""//"20%";
					attachPercent4.text = ""//"10%";
				}
			}else if(refine_index>=16){
				attachName1.text = ItemLocator.getInstance().getGeneral(startAttachId + 1).name;
				attachName2.text = ItemLocator.getInstance().getGeneral(startAttachId + 2).name;
				attachName3.text = ItemLocator.getInstance().getGeneral(startAttachId + 3).name;
				attachName4.text = "";
				
				attachPercent1.text = ""//"20%";
				attachPercent2.text = ""//"30%";
				attachPercent3.text = ""//"50%";
				attachName4.text = "";
				if(refine_index>=21 && refine_index<=25){
					attachName1.text = ItemLocator.getInstance().getGeneral(startAttachId + 2).name;
					attachName2.text = ItemLocator.getInstance().getGeneral(startAttachId + 3).name;
					attachName3.text = ItemLocator.getInstance().getGeneral(startAttachId + 4).name;
				}
				if(refine_index>=26){
					attachName1.text = ItemLocator.getInstance().getGeneral(startAttachId + 3).name;
					attachName2.text = ItemLocator.getInstance().getGeneral(startAttachId + 4).name;
					attachName3.text = ItemLocator.getInstance().getGeneral(startAttachId + 5).name;
				}
			}
			
			//费用
			if(ForgeshopModule.getInstance().isHasData()){
				costText.text = CostManager.equpRemoveCost(equipVo.refine_index);//DealConstant.silverToOtherString(Math.pow(Math.ceil(equipVo.refine_index/5),3)*100);
			}else{
				costText.text = DealConstant.silverToOtherString(0);
			}
		}
		
		/**
		 *获取装备信息提交服务器 
		 * @return 
		 * 
		 */		
		public function equipDestroyInfo():m_equip_build_decompose_tos{
			var equip_destroy:m_equip_build_decompose_tos = new m_equip_build_decompose_tos();
			if(!ForgeshopModule.getInstance().isHasData()){//如果没放装备
				Tips.getInstance().addTipsMsg("请在装备框里放上你要分解的装备");
//				Alert.show("","提示",null,null,"确定","取消",null,false);
				equip_destroy = null;
			}else if(equipColor < 3){
				Tips.getInstance().addTipsMsg("只有蓝色以上的装备才能分解！");
//				Alert.show("","提示",null,null,"确定","取消",null,false);
				equip_destroy = null; 
			}else if(equipId == -1){
				equip_destroy = null;
			}else{
				equip_destroy.equip_id = equipId;
			}
			return equip_destroy;
		}
		/**
		 *清除数据 
		 * 
		 */		
		public function cleanRemoveData():void{
			
			attachName1.text = "";
			attachName2.text = "";
			attachName3.text = "";
			attachName4.text = "";
			attachPercent1.text = "";
			attachPercent2.text = "";
			attachPercent3.text = "";
			attachPercent4.text = "";
		}
	}
}