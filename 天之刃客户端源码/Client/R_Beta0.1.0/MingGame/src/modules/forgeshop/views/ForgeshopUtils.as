package modules.forgeshop.views
{
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class ForgeshopUtils
	{
	 		
		public static const COORDINATE_Y:Number = 25;
		
		
		
		/**
		 *根据装备的等级判断材料的等级 
		 * @return 
		 * 
		 */		
		public static function getMaterailIdByEquipLvl(equipLvl:int):int{
			var material_index:int;
			if(equipLvl>=1 && equipLvl<=49){
				material_index = 1;
			}else if(equipLvl>=50 && equipLvl<=99){
				material_index = 2;
			}else if(equipLvl>=100 && equipLvl<=139){
				material_index = 3;
			}else if((equipLvl>=140 && equipLvl<=159) ||equipLvl>=160){
				material_index = 4;
			}
			return material_index;
		}
		
		/**
		 * 根据装备等级段取材料等级 
		 * @param index(为了方便判断，需要把等级段都向前推一位)
		 * @return int
		 * 
		 */		
		public static function getMaterialGradeBySegment(index:int):int{
			var cnt:int;
			
			if((index>=1)&&(index<=4)){//第一等级段1 ~ 39
				cnt = 1;
			}else if((index>=5)&&(index<=8)){
				cnt = 2;
			}else if((index>=9)&&(index<=12)){
				cnt = 3;
			}else if((index>=13)&&(index<=15)){
				cnt = 4;
			}else if((index>=16)&&(index<=18)){
				cnt = 5;
			}else if(index>=19){
				cnt = 6;
			}
			return cnt;
		}
		
		/**
		 * 根据装备等级段取需要数量 
		 * @param level
		 * @return int
		 * 
		 */		
		public static function getNeededNumberBySegment(level:int):int{
			if(level>=16 && level<=18){
				return level%5;
			}
			if(level >=19){
				return level%6;
			}
			if((level%4) != 0){
				return level%4;
			}else {
				return 4;
			}
		}
		
		/**
		 *通过装备等级获取所需基础材料数量
		 * @param equipLvl
		 * @return 
		 * 
		 */		
		public static function getMaterialNeedByEquipLvl(equipLvl:int):int{
			var need:int;
			if((equipLvl>=1 && equipLvl<=9) || 
				(equipLvl>=40 && equipLvl<=49) || 
				(equipLvl>=80 && equipLvl<=89) || 
				(equipLvl>=120 && equipLvl<=129) || 
				(equipLvl>=140 && equipLvl<=144) || 
				(equipLvl>=155 && equipLvl<=159)){
				
				need = 1;
			}else if((equipLvl >=10 && equipLvl<=19) || 
				(equipLvl>=50 && equipLvl<=59) || 
				(equipLvl>=90 && equipLvl<=99) || 
				(equipLvl>=130 && equipLvl<=134) || 
				(equipLvl>=145 && equipLvl<=149) || equipLvl>=160){
				
				need = 2;
			}else if(equipLvl >=20 && equipLvl<=29 || 
				(equipLvl>=60 && equipLvl<=69) || 
				(equipLvl>=100 && equipLvl<=109) || 
				(equipLvl>=135 && equipLvl<=139) || 
				(equipLvl>=150 && equipLvl<=154)){
				
				need = 3;
			}else if((equipLvl >=30 && equipLvl<=39) || 
				(equipLvl>=70 && equipLvl<=79) || 
				(equipLvl>=110 && equipLvl<=119)){
				
				need = 4;
			}
			return need;
		}
		
		/**
		 *通过装备等级获取材料等级 
		 * @param equipLvl
		 * @return 
		 * 
		 */		
		public static function getMaterialLvlByEquipLvl(equipLvl:int):int{
			var materialLvl:int;
			if(equipLvl>=1 && equipLvl<=39){
				materialLvl = 1;
			}else if(equipLvl>=40 && equipLvl<=79){
				materialLvl = 2;
			}else if(equipLvl>=80 && equipLvl<=119){
				materialLvl = 3;
			}else if(equipLvl>=120 && equipLvl<=139){
				materialLvl = 4;
			}else if(equipLvl>=140 && equipLvl<=154){
				materialLvl = 5;
			}else if(equipLvl>=155){
				materialLvl = 6;
			}
			return materialLvl;
		}
		/**
		 * 根据材质和材料ID获取到等级
		 * @param material
		 * 
		 */		
		public static function getAttachGrade(material:int,typeid:int):int{
			var startAttachId:int = 10404001;
			
			return typeid - startAttachId + 1 ;
		}
		
	 	
		/**
		 * 创建装备等级段 
		 * @return 
		 * 
		 */		
		public static function createGradeSegment():Array{
			
			var datas:Array = [];
			datas.push("1--9级");
			var i:int= 2;
			var temp:int =0;
			for(i;i<=10;i++){
				datas.push(((i-1)*10)+"--"+(i*10 -1) + "级");
			}
			/*for(i;i<=12;i++){
				datas.push(((i-1)*10)+"--"+(i*10 -1) + "级");
			}*/
			/*for(i;i<=16;i++){
				temp = (i-1)*10;
				datas.push(temp + "--"+(temp + 4) + "级");
				datas.push((temp + 5)+"--"+(temp + 9) + "级");
			}
			datas.push(">=160级");*/
			
			return datas;
		}
		
		/**
		 * 改变材料颜色
		 * @param level  材料等级
		 * @param whiteTextField
		 * @param greenTextField
		 * @param blueTextField
		 * @param purpleTextField
		 * @param orangeTextField
		 * 
		 */		
		public static function changeColorPercentage(level:int,greenTextField:TextField,blueTextField:TextField,purpleTextField:TextField,orangeTextField:TextField,glodTextField:TextField):void{
			switch(level){
				case 0:
					greenTextField.text = "";
					blueTextField.text = "";
					purpleTextField.text = "";
					orangeTextField.text = "";
					glodTextField.text = "";
					break;
				case 1:	
					greenTextField.text = "75%";
					blueTextField.text = "10%";
					purpleTextField.text = "";
					orangeTextField.text = "";
					glodTextField.text = "";
					break;
				case 2:	
					greenTextField.text = "55%";
					blueTextField.text = "40%";
					purpleTextField.text = "5%";
					orangeTextField.text = "";
					glodTextField.text = "";
					break;
				case 3:	
					greenTextField.text = "15%";
					blueTextField.text = "60%";
					purpleTextField.text = "25%";
					orangeTextField.text = "";
					glodTextField.text = "";
					break;
				case 4:	
					greenTextField.text = "";
					blueTextField.text = "20%";
					purpleTextField.text = "60%";
					orangeTextField.text = "20%";
					glodTextField.text = "";
					break;
				case 5:	
					greenTextField.text = "";
					blueTextField.text = "";
					purpleTextField.text = "25%";
					orangeTextField.text = "60%";
					glodTextField.text = "15%";
					break;
				case 6:	
					greenTextField.text = "";
					blueTextField.text = "";
					purpleTextField.text = "";
					orangeTextField.text = "20%";
					glodTextField.text = "80%";
					break;
			}
		}
		
		/**
		 * 
		 * @param level
		 * @param commoneTxt 普通
		 * @param fineTxt 精致
		 * @param wellTxt 无暇
		 * @param bestTxt 优质
		 * @param perfectTxt 完美
		 * 
		 */	
		public static function qualityPercent($parent:DisplayObjectContainer,level:int/*,commoneTxt:TextField,fineTxt:TextField,wellTxt:TextField,bestTxt:TextField,perfectTxt:TextField*/):void{
			var i:int=0;
			while($parent.numChildren>0){
				$parent.removeChildAt(0);
			}
			switch(level){
				case 0:
					/*commoneTxt.text = "";
					fineTxt.text = "";
					wellTxt.text = "";
					bestTxt.text = "";
					perfectTxt.text = "";*/
					for each(var s0:Sprite in SubPingzhiCanvas.gray_arr){
						$parent.addChild(s0);
					}
					break;
				case 1:
					/*commoneTxt.text = "80%";
					fineTxt.text = "20%";
					wellTxt.text = "";
					bestTxt.text = "";
					perfectTxt.text = "";*/
					for(i;i<5;i++){
						if(i==1){
							$parent.addChild(SubPingzhiCanvas.yellow_arr[i]);
						}else{
							$parent.addChild(SubPingzhiCanvas.gray_arr[i]);
						}
					}
					
					break;
				case 2:
					/*commoneTxt.text = "50%";
					fineTxt.text = "30%";
					wellTxt.text = "10%";
					bestTxt.text = "";
					perfectTxt.text = "";*/
					for(i;i<5;i++){
						if(i==1||i==2){
							$parent.addChild(SubPingzhiCanvas.yellow_arr[i]);
						}else{
							$parent.addChild(SubPingzhiCanvas.gray_arr[i]);
						}
					}
					break;
				case 3:
					/*commoneTxt.text = "";
					fineTxt.text = "60%";
					wellTxt.text = "40%";
					bestTxt.text = "";
					perfectTxt.text = "";*/
					for(i;i<5;i++){
						if(i==2||i==3){
							$parent.addChild(SubPingzhiCanvas.yellow_arr[i]);
						}else{
							$parent.addChild(SubPingzhiCanvas.gray_arr[i]);
						}
					}
					break;
				case 4:
					/*commoneTxt.text = "";
					fineTxt.text = "30%";
					wellTxt.text = "50%";
					bestTxt.text = "20%";
					perfectTxt.text = "";*/
					for(i;i<5;i++){
						if(i==3||i==4){
							$parent.addChild(SubPingzhiCanvas.yellow_arr[i]);
						}else{
							$parent.addChild(SubPingzhiCanvas.gray_arr[i]);
						}
					}
					break;
				case 5:
					/*commoneTxt.text = "";
					fineTxt.text = "";
					wellTxt.text = "30%";
					bestTxt.text = "50%";
					perfectTxt.text = "20%";*/
					for(i;i<5;i++){
						if(i==4){
							$parent.addChild(SubPingzhiCanvas.yellow_arr[i]);
						}else{
							$parent.addChild(SubPingzhiCanvas.gray_arr[i]);
						}
					}
					break;
				case 6:
					/*commoneTxt.text = "";
					fineTxt.text = "";
					wellTxt.text = "";
					bestTxt.text = "40%";
					perfectTxt.text = "60%";*/
					for(i;i<5;i++){
						if(i==4){
							$parent.addChild(SubPingzhiCanvas.yellow_arr[i]);
						}else{
							$parent.addChild(SubPingzhiCanvas.gray_arr[i]);
						}
					}
					break;
			}
			LayoutUtil.layoutHorizontal($parent,10,2);
		}
		/**
		 *装备分解得到基础材料的百分比 
		 * @param equipLvl
		 * @param material_base1_percent_txt
		 * 
		 */		
		public static function removeBasePercentByEquipLvl(equipLvl:int,material_base1_percent_txt:TextField):void{
			if((equipLvl >=1 && equipLvl<=9) || (equipLvl>=50 && equipLvl<=59) || (equipLvl>=100 && equipLvl<=109) || (equipLvl>=140 && equipLvl<=144)){
				material_base1_percent_txt.text = ""//"20%";
			}else if((equipLvl>=10 && equipLvl<=19) || (equipLvl>=60 && equipLvl<=69) || (equipLvl>=110 && equipLvl<=119) || (equipLvl>=145 && equipLvl<=149)){
				material_base1_percent_txt.text = ""//"35%";
			}else if((equipLvl>=20 && equipLvl<=29) || (equipLvl>=70 && equipLvl<=79) || (equipLvl>=120 && equipLvl<=129) || (equipLvl>=150 && equipLvl<=154)){
				material_base1_percent_txt.text = ""//"50%";
			}else if((equipLvl>=30 && equipLvl<=39) || (equipLvl>=80 && equipLvl<=89) || (equipLvl>=130 && equipLvl<=134) || (equipLvl>=155 && equipLvl<=159)){
				material_base1_percent_txt.text = ""//"65%";
			}else if((equipLvl>=40 && equipLvl<=49) || (equipLvl>=90 && equipLvl<=99) || (equipLvl>=135 && equipLvl<=139) || equipLvl>=160){
				material_base1_percent_txt.text = ""//"80%";
			}
		}
		
		/**
		 *分解获取附加材料的百分 
		 * @param refineIndex
		 * 
		 */		
		public function removeAttachPercentByRefineIndex(refineIndex:int):void{
			if(refineIndex <= 5){
			
			}else if(refineIndex >= 6 && refineIndex <= 10){
				
			}else if(refineIndex >=11 && refineIndex <= 15){
				
			}else if(refineIndex >= 16 && refineIndex <= 20){
				
			}else if(refineIndex >= 21 && refineIndex <=25){
				
			}else if(refineIndex >= 26){
				
			}
		}
		/**
		 * 分解获取附加材料的名字
		 * @param refineIndex
		 * 
		 */		
		public function removeAttachNameByRefineIndex(refineIndex:int):void{
			if(refineIndex <= 5){
				
			}else if(refineIndex >= 6 && refineIndex <= 10){
				
			}else if(refineIndex >=11 && refineIndex <= 15){
				
			}else if(refineIndex >= 16 && refineIndex <= 20){
				
			}else if(refineIndex >= 21 && refineIndex <=25){
				
			}else if(refineIndex >= 26){
				
			}
		}
		
		public static function getAttachIdByQulity(qulity:int):int{
			var attachLvl:int;
			switch(qulity){
				case 1:
					attachLvl = 0;
					break;
				case 2:
					attachLvl = 1;
					break;
				case 3:
					attachLvl = 2;
					break;
				case 4:
					attachLvl = 3;
					break;
				case 5:
					attachLvl = 4;
					break;
			}
			return attachLvl;
		}
		/**
		 *通过强化石ID获取强化石的等级 
		 * @param level
		 * @return 
		 * 
		 */		
		public static function getStrengthIdByStrenghtLvl(level:int):int{
			var strenghtLvl:int;
			switch(level){
				case 1:
					strenghtLvl = 10401001;
					break;
				case 2:
					strenghtLvl = 10401002;
					break;
				case 3:
					strenghtLvl = 10401003;
					break;
				case 4:
					strenghtLvl = 10401004;
					break;
				case 5:
					strenghtLvl = 10401005;
					break;
				case 6:
					strenghtLvl = 10401006;
					break;
			}
			return strenghtLvl;
		}
		
		/**
		 *获取基础材料和附加材料的ID通过装备材质 
		 * @param equipVo
		 * @return 
		 * 
		 */		
		public static function getMaterialIdAndAttachIdByEquipMaterial(equipVoMaterial:int):Array{
			var arr:Array = [];
			var materialId:int;
			var attachMaterialId:int;
			var qulityMaterIalId:int = 10404001;
			switch(equipVoMaterial){
				case 1://（金）
					materialId = 10402111;//生铁
					attachMaterialId = 10402121;//弦铁					
					break;
				case 2://（木）
					materialId = 10402211;//木材
					attachMaterialId = 10402221;//檀木					
					break;
				case 3://（皮）
					materialId = 10402311;//软皮
					attachMaterialId = 10402321;//硬皮					
					break;
				case 4://（布）
					materialId = 10402411;//布料
					attachMaterialId = 10402421;//丝绸					
					break;
				case 5://（玉）
					materialId = 10402511;//白玉
					attachMaterialId = 10402521;//翡翠					
					break;
			}
			
			arr[0] = materialId;
			arr[1] = attachMaterialId;
			arr[2] = qulityMaterIalId;
			return arr;
		}
	}
}