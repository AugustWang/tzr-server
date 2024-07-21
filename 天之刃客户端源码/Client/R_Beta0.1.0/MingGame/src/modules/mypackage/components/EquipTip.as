package modules.mypackage.components
{
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	
	import proto.common.p_equip_five_ele;
	import proto.common.p_equip_whole_attr;
	import proto.common.p_property_add;
	
	public class EquipTip extends BaseTip
	{
		private var startY:Number = 8;
		
		private var equipName:TextField; //名称描述 和 打造描述
		private var border:Image;
		private var star:StarBox; //星星显示
		private var starDesc:TextField; //星星属性描述
		private var icon:GoodsImage; //装备图像
		private var equipBaseDesc:TextField; //装备基本描述 性别 类别 等级要求
		private var funcDesc:TextField; //基本附加能力描述
		private var stoneBox:StoneShowBox; //装备宝石显示情况
		private var equipDesc:TextField; //装备详细描述
		private var qualityDesc:TextField;//品质描述
		public var useDesc:String = "";
		public function EquipTip()
		{
			super();
			var tf:TextFormat = Style.textFormat;
			tf.leading = 4;
			equipName = ComponentUtil.createTextField("",8,0,tf,205,NaN,this,wrapperHandler);
			star = new StarBox();
			star.x = 8;
			addChild(star);
			starDesc = ComponentUtil.createTextField("",8,0,tf,205,NaN,this,wrapperHandler);
            qualityDesc = ComponentUtil.createTextField("",8,0,tf,205,NaN,this,wrapperHandler);
			icon = new GoodsImage();
			icon.width = icon.height = 55;
			icon.x = icon.y = 4;
			border = new Image();
			border.width = 65;
			border.height =  66;
			border.source = GameConfig.getBackImage("shopItemBg");
			border.x = 10;
			addChild(border);
			border.addChild(icon);
			equipBaseDesc = ComponentUtil.createTextField("",80,0,tf,205,NaN,this,wrapperHandler);
			funcDesc = ComponentUtil.createTextField("",8,0,tf,205,NaN,this,wrapperHandler);
			stoneBox = new StoneShowBox();
			stoneBox.x = 8;
			addChild(stoneBox);
			equipDesc = ComponentUtil.createTextField("",8,0,tf,200,NaN,this,wrapperHandler);
		}
		
		private function wrapperHandler(text:TextField):void{
			text.wordWrap = true;
		}
		
		override public function createItemTip(itemVo:BaseItemVO):void{
			clearTip();
			var equipVo:EquipVO = itemVo as EquipVO;
			if(equipVo == null)return;
			startY = 8;
			var color:String = ItemConstant.COLOR_VALUES[equipVo.color];
			var htmlText:String = "";
			// 名称描述 和 打造描述
			if(useDesc != ""){
				htmlText += useDesc;
			}
			if(equipVo.quality > 1){
				htmlText += getName(ItemConstant.ITEM_QUALITY[equipVo.color]+equipVo.name,color);
			}else{
				htmlText += getName(equipVo.name,color);
			}
			 
			if(equipVo.signature && equipVo.signature != ""){
				htmlText += wapper(""," "+equipVo.signature);
			}else if(type == CHAT_TOOLTIP){
				htmlText += wapper(""," "+roleName);
			}
			
			htmlText += getBindable(equipVo.bind,equipVo.use_bind);
		
			equipName.htmlText = htmlText;
			equipName.y = startY;
			
			startY  = startY + equipName.textHeight + 1;
			htmlText = "";
						
			icon.setImageContent(equipVo,equipVo.path);
			border.y = startY + 8;
			
			htmlText += wapper("装备类型：",ItemConstant.getEquipKindName(equipVo.putWhere,equipVo.kind));
			if(equipVo.sex != 0){
				var sexColor:String = "#ffffff";
				if(GlobalObjectManager.getInstance().user.base.sex != equipVo.sex){
					sexColor = "#ff0000"
				}
				htmlText += wapper("性别要求：",ItemConstant.SEX_NAMES[equipVo.sex],sexColor,sexColor);
			}
					
			//装备等级要求
			var levelColor:String="#ffaca";
			if(GlobalObjectManager.getInstance().user.attr.level<equipVo.minlvl)//不够等级显红色
			{
				levelColor = "#ff0000";
			}
			if(equipVo.maxlvl>=200)
			{
				if(equipVo.minlvl<=1)
				{
					htmlText+="";
				}
				if(equipVo.minlvl>1)
				{
					if((GlobalObjectManager.getInstance().user.attr.level<1)&&(GlobalObjectManager.getInstance().user.attr.level<200))
					{
						levelColor = "#ff0000";
					}
					htmlText += wapper("等级要求：",equipVo.minlvl.toString(),levelColor,levelColor);
				}
			}
			if(equipVo.maxlvl<200)
			{
				if(GlobalObjectManager.getInstance().user.attr.level>200)
				{
					levelColor = "#ff0000";
				}
				htmlText += wapper("等级要求：",(equipVo.minlvl.toString()+"-"+equipVo.maxlvl.toString()),levelColor,levelColor);
			}
			
			if(equipVo.add_property != null){
				htmlText += wapper("耐久度",Math.ceil((equipVo.current_endurance/1000))+" / "+Math.ceil((equipVo.endurance/1000)),enduranceColor,enduranceColor);
			}
			equipBaseDesc.htmlText = htmlText;
			equipBaseDesc.y = startY;
			
			startY  = startY + 70;
			htmlText = "";
					
			//品质显示和描述
			if(equipVo.quality_rate > 0 && equipVo.kind != ItemConstant.KIND_EQUIP_MOUNT && equipVo.
				kind != ItemConstant.KIND_FASHION && equipVo.kind != ItemConstant.KIND_SPECIAL){
				var qualityRateDesc:String = "品质加成：";
				if(equipVo.add_property.main_property == 1){
					qualityRateDesc = qualityRateDesc + "生命值 + ";
				}
				if(equipVo.add_property.main_property == 2){
					qualityRateDesc = qualityRateDesc + "外攻 + ";
				}
				if(equipVo.add_property.main_property == 3){
					qualityRateDesc = qualityRateDesc + "内攻 + ";
				}
				if(equipVo.add_property.main_property == 4){
					qualityRateDesc = qualityRateDesc + "外防 + ";
				}
				if(equipVo.add_property.main_property == 5){
					qualityRateDesc = qualityRateDesc + "内防 + ";
				}
				htmlText = "";
				htmlText = wapper("",qualityRateDesc + equipVo.quality_rate + "%","#ffffff","#ffffff");
				qualityDesc.htmlText = htmlText;
				qualityDesc.y = startY;
				startY  = startY + qualityDesc.textHeight;
				htmlText = "";
			}
			
			//星星显示  和描述
			if(equipVo.reinforce_result > 9){
				var starlevel:int = int(equipVo.reinforce_result.toString().substr(0,1));
				var starCount:int = int(equipVo.reinforce_result.toString().substr(1,1));
				star.setStar(starCount,starlevel);
				star.y = startY;
				
				startY  = startY + 16;
				htmlText = "";
				
				htmlText = wapper("",starlevel+"级"+starCount+"星强化，属性增强 "+equipVo.reinforce_rate+"%","#ffffff","#ffffff");
				starDesc.htmlText = htmlText;
				starDesc.y = startY;
				
				startY  = startY + starDesc.textHeight;
				htmlText = "";
			}
			
			var enduranceColor:String = "#ffffff";
			if(equipVo.current_endurance <= 0){
				enduranceColor = "#ff0000";
			}
            if(equipVo.add_property != null){
    			var propertys:p_property_add = equipVo.add_property; 
    			if(propertys.min_physic_att != 0 || propertys.max_physic_att != 0)
    				htmlText += wapper("外攻","+"+propertys.min_physic_att+"—"+propertys.max_physic_att,"#ffffff","#0099ff");
    			if(propertys.min_magic_att != 0 || propertys.max_magic_att != 0)
    				htmlText += wapper("内攻","+"+propertys.min_magic_att+"—"+propertys.max_magic_att,"#ffffff","#0099ff");
    			htmlText += wapperText("外防",propertys.physic_def);
    			htmlText += wapperText("内防",propertys.magic_def);
    			htmlText += wapperText("力量",propertys.power);
    			htmlText += wapperText("敏捷",propertys.agile);
    			htmlText += wapperText("智力",propertys.brain);
    			htmlText += wapperText("体质",propertys.vitality);
    			htmlText += wapperText("精神",propertys.spirit);
    			htmlText += wapperText("生命值",propertys.blood);
    			htmlText += wapperText("内力值",propertys.magic);
    			htmlText += wapperText("外攻百分比",propertys.physic_att_rate);
    			htmlText += wapperText("内攻百分比",propertys.magic_att_rate);
    			htmlText += wapperText("外防百分比",propertys.physic_def_rate);
    			htmlText += wapperText("内防百分比",propertys.magic_def_rate);
    			htmlText += wapperText("生命值百分比",propertys.blood_rate);
    			htmlText += wapperText("内力值百分比",propertys.magic_rate);
    			htmlText += wapperText("生命恢复速度",propertys.blood_resume_speed);
    			htmlText += wapperText("内力恢复速度",propertys.magic_resume_speed);
    			htmlText += wapperText("移动速度",propertys.move_speed);
    			htmlText += wapperText("攻击速度",propertys.attack_speed);
    			htmlText += wapperText("幸运",propertys.lucky);
    			htmlText += wapperText("重击",propertys.dead_attack/100,"%");
    			htmlText += wapperText("闪避",propertys.dodge/100,"%");
    			htmlText += wapperText("破甲",propertys.no_defence/100,"%");
    			htmlText += wapperText("击晕",propertys.dizzy/100,"%");
    			htmlText += wapperText("中毒",propertys.poisoning/100,"%");
    			htmlText += wapperText("冰冻",propertys.freeze/100,"%");
    			htmlText += wapperText("晕眩抗性",propertys.dizzy_resist/100,"%");
    			htmlText += wapperText("中毒抗性",propertys.poisoning_resist/100,"%");
    			htmlText += wapperText("冰冻抗性",propertys.freeze_resist/100,"%");
    			if(propertys.hurt > 0){
    				htmlText += wapper("伤害加深","造成"+(propertys.hurt/100)+"%的额外伤害","#0099ff","#0099ff");
    			}
    			if(propertys.hurt_shift > 0){
    				htmlText += wapper("伤害转化","将"+(propertys.hurt_shift/100)+"%伤害转化为内力损耗","#0099ff","#0099ff");
    			}
            }
			var fivearr:p_equip_five_ele = equipVo.five_arr;
			if(fivearr){
				var fiveColor:String = fivearr.active == 1 ? "#FF9000" : "#aaaaaa";
				if(fivearr.id > 0){
					htmlText += wapper("五行属性：","("+ItemConstant.FIVE_ELE[fivearr.id]+")",fiveColor,fiveColor,"");
				}
				if(fivearr.equip_name.length > 0){
					var typeName:String = ItemConstant.getNameByEquipType(fivearr.link_slot_num);
					htmlText += wapper("激活需要：",fivearr.whole_name+"·"+typeName+"("+ItemConstant.getFiveEleSource(fivearr.id)+")",fiveColor,fiveColor,"");
				}
				if(fivearr.phy_anti > 0){
					htmlText += wapper("激活属性：","外功伤害减免"+fivearr.phy_anti/100+"%",fiveColor,fiveColor,"");
				}
				if(fivearr.magic_anti > 0){
					htmlText += wapper("激活属性：","内功伤害减免"+fivearr.magic_anti/100+"%",fiveColor,fiveColor,"");
				}
				if(fivearr.hurt > 0){
					htmlText += wapper("激活属性：","造成"+fivearr.hurt/100+"%的额外伤害",fiveColor,fiveColor,"");
				}
				if(fivearr.no_defence > 0){
					htmlText += wapper("激活属性：","破甲"+fivearr.no_defence/100+"%",fiveColor,fiveColor,"");
				}
				if(fivearr.hurt_rebound > 0){
					htmlText += wapper("激活属性：","伤害反射"+fivearr.hurt_rebound/100+"%",fiveColor,fiveColor,"");
				}
			}
			if(equipVo.punch_num > 0){
				htmlText += wapper("灵石孔个数",equipVo.punch_num);
				funcDesc.htmlText = htmlText;
				funcDesc.height = funcDesc.textHeight + 5;
				funcDesc.y = startY;
				
				htmlText = "";
				startY = startY + funcDesc.height;
				
				stoneBox.drawStone(equipVo.punch_num,equipVo.stones);
				stoneBox.y = startY;
				
				startY = startY + stoneBox.height;
			}else{
				funcDesc.htmlText = htmlText;
				funcDesc.height = funcDesc.textHeight + 5;
				funcDesc.y = startY;
				
				htmlText = "";
				startY = startY + funcDesc.height;
			}
			
			var equipwhole:p_equip_whole_attr = equipVo.whole_attr;
			if(equipwhole){
				if(equipwhole.name != ""){
					htmlText += wapper("",equipwhole.name+"套装("+equipwhole.number+"/10)","#FFFF00","#FFFF00");
				}
				if(equipwhole.desc != ""){
					htmlText += wapper("",equipwhole.desc,"#FFFF00","#FFFF00","");
				}
			}
			
			if(equipVo.desc != ""){
				htmlText += wapper("",equipVo.desc,color,color);
			}
			if(type == ITEM_TOOLTIP && equipVo.unit_price > 0){
					htmlText += getUnitPrice(equipVo.unit_price, equipVo.price_type);
			}
			if(type == ITEM_TOOLTIP){ 
				htmlText += getMoneyDesc(equipVo.sellType,equipVo.getSellPrice());
				if(CursorManager.getInstance().currentCursor == CursorName.HAMMER){
					var fixPrice:Number = equipVo.getFixPrice();
					if(fixPrice != 0){
						htmlText += wapper("修理价格：",MoneyTransformUtil.silverToOtherString(fixPrice),"#0099ff","#0099ff");
					}else{
						htmlText += wapper("不需要修理","","#0099ff");
					}
				}
				htmlText += getItemStatus(equipVo);
				htmlText += wapper("","Ctrl+单击：发送到聊天");
			}
			htmlText = htmlText.split("\\n").join("\n");
			equipDesc.htmlText = htmlText;
			equipDesc.height = equipDesc.textHeight + 5;
			equipDesc.y = startY;
			
			startY = startY + equipDesc.textHeight + 5;
		}
		
		override protected function clearTip():void{
			equipName.htmlText = "";
			star.removeStars();
			starDesc.htmlText = "";
			equipBaseDesc.htmlText = "";
			funcDesc.htmlText = "";
			stoneBox.removeStones();
			equipDesc.htmlText = "";
            qualityDesc.htmlText = "";
		}
		
		override public function get height():Number{
			return startY + 5;
		}
		
		override public function get width():Number{
			return 210;
		}
	}
}