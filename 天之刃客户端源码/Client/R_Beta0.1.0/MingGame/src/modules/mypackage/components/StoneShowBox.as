package modules.mypackage.components
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	
	import flash.accessibility.AccessibilityProperties;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.StoneVO;
	
	import proto.common.p_goods;
	
	public class StoneShowBox extends Sprite
	{
		private var items:Array;
		private var punchNum:int; //当前打孔个数
		private var stones:Array; //镶嵌宝石集合
		public function StoneShowBox()
		{
			super();
			this.mouseEnabled = false;
			items = [];
		}
		
		public function drawStone(_punchNum:int,_stones:Array):void{
			removeStones();
			punchNum = _punchNum;
			stones = _stones;
			var size:int = stones ? stones.length : 0;
			var startY:int = 0;
			for(var i:int=0;i<punchNum;i++){
				var holeItem:HoleItem = getHoleItem();
				holeItem.y = startY;
				if(i < size){
					var stoneVO:StoneVO = ItemConstant.wrapperItemVO(stones[i] as p_goods) as StoneVO;
					holeItem.createStone(stoneVO);
				}else{
					holeItem.createNullHole(i);
				}
				addChild(holeItem);
				startY += 28;
			}
		}
		
		public function removeStones():void{
			while(numChildren > 0){
				var s:DisplayObject = removeChildAt(0);
				items.push(s);
			}
		}
		
		override public function get height():Number{
			return numChildren*28;
		}
		
		public function getHoleItem():HoleItem{
			if(items.length > 0){
				return items.shift();
			}
			return new HoleItem();
		}
	}
}
import com.globals.GameConfig;
import com.ming.ui.controls.Image;
import com.utils.ComponentUtil;

import flash.display.Sprite;
import flash.text.TextField;

import modules.mypackage.vo.StoneVO;

class HoleItem extends Sprite{
	
	public static const PRO:Object = new Object();
	PRO["力量"] = "power";
	PRO["敏捷"] = "agile";
	PRO["智力"] = "brain";
	PRO["体质"] = "vitality";
	PRO["精神"] = "spirit";
	PRO["最小物攻"] = "min_physic_att";
	PRO["最大物攻"] = "max_physic_att";
	PRO["最小魔攻"] = "min_magic_att";
	PRO["最大魔攻"] = "max_magic_att";
	PRO["物防"] = "physic_def";
	PRO["魔防"] = "magic_def";
	PRO["生命值"] = "blood";
	PRO["魔法值"] = "magic";
	PRO["物攻百分比"] = "physic_att_rate";
	PRO["魔攻百分比"] = "magic_att_rate";
	PRO["物防百分比"] = "physic_def_rate";
	PRO["魔防"] = "magic_def_rate";
	PRO["生命值"] = "blood_rate";
	PRO["魔法值"] = "magic_rate";
	PRO["生命恢复速度"] = "blood_resume_speed";
	PRO["魔法恢复速度"] = "magic_resume_speed";
	PRO["暴击"] = "dead_attack";
	PRO["幸运"] = "lucky";
	PRO["移动速度"] = "move_speed";
	PRO["攻击速度"] = "attack_speed";
	PRO["闪避"] = "dodge";
	PRO["破防"] = "no_defence";
	PRO["击晕"] = "dizzy";
	PRO["中毒"] = "poisoning";
	PRO["冰冻"] = "freeze";
	PRO["伤害"] = "hurt";
	PRO["伤害转化"] = "hurt_shift";
	PRO["中毒抗性"] = "poisoning_resist";
	PRO["击晕抗性"] = "dizzy_resist";
	PRO["冰冻抗性"] = "freeze_resist";
	PRO["物理伤抗"] = "phy_anti";
	PRO["魔法伤抗"] = "magic_anti";
	PRO["伤害反射"] = "hurt_rebound";
	
	public static const RATES:Array = ["dead_attack","dodge","no_defence","dizzy","poisoning","freeze","dizzy_resist","poisoning_resist","freeze_resist"];
	private var holeImage:Image;
	private var stoneImage:Image;
	private var desc:TextField;
	public function HoleItem(){
		
	}
	
	public function createStone(stoneVO:StoneVO):void{
		if(holeImage == null){
			holeImage = new Image();
		}
		var stonelv:int = stoneVO.level;
		if(stonelv == 3 || stonelv == 5 || stonelv == 7){
			stonelv = stonelv - 1;
		}
		holeImage.source = GameConfig.getBackImage("hole_"+stonelv);
		if(stoneImage == null){
			stoneImage = new Image();
		}
		stoneImage.x = - 1;
		stoneImage.source = GameConfig.getBackImage("stone_"+stoneVO.type);
		addChild(holeImage);
		addChild(stoneImage);
		if(desc == null){
			desc = ComponentUtil.createTextField("",27,5,null,175,20,this);
			desc.textColor = 0xffff00;
		}
		desc.text = stoneVO.name+"   "+getAddProperty(stoneVO);
	}
	
	public function createNullHole(i:int):void{
		if(holeImage == null){
			holeImage = new Image();
			addChild(holeImage);
		}
		holeImage.source = GameConfig.getBackImage("hole_1");
		if(stoneImage){
			stoneImage.source = null;
		}
		if(desc == null){
			desc = ComponentUtil.createTextField("",27,5,null,150,20,this);
			desc.textColor = 0xffff00;
		}
		desc.text = "凹槽"+(i+1)+"，未镶嵌";
	}
	
	public function getAddProperty(stoneVO:StoneVO):String{
		var html:String = "";
		for(var zhName:String in PRO){
			var enName:String = PRO[zhName];	
			var value:int = stoneVO.add_property[enName];
			if(value > 0){
				if(enName == "min_physic_att" || enName == "max_physic_att"){
					html += "物攻";
				}else if(enName == "min_magic_att" || enName == "max_magic_att"){
					html += "魔攻";
				}else{
					html += zhName;
				}
				if(RATES.indexOf(enName) != -1){
					html += " +"+(value/100) +"%";
				}else{
					if(enName == "min_physic_att" || enName == "max_physic_att"){
						html += " +"+stoneVO.add_property["min_physic_att"]
					}else if(enName == "min_magic_att" || enName == "max_magic_att"){
						html += " +"+stoneVO.add_property["min_magic_att"]
					}
					html += " +"+value;
				}
				break;
			}
		}
		return html;
	}
}
