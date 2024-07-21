package modules.forgeshop.views.items
{
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import modules.forgeshop.views.ForgeshopUtils;
	import modules.mypackage.ItemConstant;
	
	import proto.line.p_equip_build_equip;
	import proto.line.p_equip_build_goods;
	
	public class EquipItemRender  extends UIComponent implements IDataRenderer
	{
		private var equipType:TextField;
		private var equipName:TextField;
		private var equipGrade:TextField;
		
		public function EquipItemRender(){
			//装备类型
			equipType = createTextField(1,2,80);
			addChild(equipType);
			
			//装备名称
			equipName = createTextField(equipType.x + equipType.width,equipType.y,110);
			addChild(equipName);
			
			//装备等级
			equipGrade = createTextField(equipName.x + equipName.width,equipType.y,80);
			addChild(equipGrade);
		}
		
		public function createTextField(xValue:Number = NaN, yValue:Number = NaN,wValue:Number = NaN):TextField{
			var txt:TextField = new TextField();
			txt.width = wValue;
			txt.x = xValue;
			txt.y = yValue;
			txt.height = 25;
			txt.mouseEnabled = false;
			return txt;
		}
		
		private function changeTextColor(color:uint = 0x00ff00):void{
			var Format:TextFormat = new TextFormat("Tahoma",12,color,null,null,null,null,null,TextFormatAlign.CENTER);
			equipType.setTextFormat(Format);
			equipName.setTextFormat(Format);
			equipGrade.setTextFormat(Format);
			
		}
		
	    private  function setText(equipTypeText:String,equipNameText:String,equipGradeText:String):void{
			equipType.text= equipTypeText;
			equipName.text= equipNameText;
			equipGrade.text= equipGradeText;
		}
		
		
		
		override public function get data():Object{
	         return super.data;
		}
		
		override public function set data(value:Object):void{
			var equipExtendProto:EquipExtendProto = value as EquipExtendProto;
			var equip:p_equip_build_equip = equipExtendProto.build_equip;
			super.data = value; 
						
			setText(ItemConstant.getEquipKindName(equip.slot_num,equip.kind),equip.equip_name,""+equip.level);
			var materialId:int;
			var type_id:int;
			var needed_num:int = ForgeshopUtils.getNeededNumberBySegment(equipExtendProto.level); 
			
			switch(equip.material){
				case 1:
					materialId = 10402111;							
					break;
				case 2:
					materialId = 10402211;				
					break;
				case 3:
					materialId = 10402311;						
					break;
				case 4:
					materialId = 10402411;							
					break;
				case 5:
					materialId = 10402511;					
					break;
				
			}
			type_id = (materialId -1) + ForgeshopUtils.getMaterialGradeBySegment(equipExtendProto.level);
			changeTextColor(); 
//			if( equipExtendProto.base_list.length == 0){
//				changeTextColor(0xFF5151);
//			}else{
//				for each(var baseVO:p_equip_build_goods in equipExtendProto.base_list){  //当前拥有基础材料的数量
//					if((baseVO.type_id == type_id)&&(needed_num <= baseVO.current_num)){
//						changeTextColor(); 
//						break;
//					}else{
//						changeTextColor(0xFF5151); 
//					}
//					
//				}
//			}
		}
	 
	}
}