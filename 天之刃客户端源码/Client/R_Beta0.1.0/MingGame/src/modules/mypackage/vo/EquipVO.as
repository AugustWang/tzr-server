package modules.mypackage.vo {
	import modules.mypackage.managers.ItemLocator;
	
	import proto.common.p_equip_five_ele;
	import proto.common.p_equip_whole_attr;
	import proto.common.p_goods;
	import proto.common.p_property_add;

	/**
	 * 装备VO对象定义
	 */
	public class EquipVO extends BaseItemVO {
		public var putWhere:int; //属于什么类型的装备
		public var loadposition:int; //装备穿在身上的位置
//		public var quality:int;	//品质
		public var current_endurance:int; //当前耐久度			
		public var endurance:int; //总耐久度
		public var forge_num:int; //当前锻造次数
		public var reinforce_result:int; //当前强化等级
		public var punch_num:int; //当前打孔个数		
		public var stone_num:int; //当前镶嵌宝石个数
		public var add_property:p_property_add; //装备额外附加属性
		public var stones:Array; //镶嵌的宝石 		
		public var minlvl:int; //要求最少等级
		public var maxlvl:int; //要求最大等级
		public var reinforce_rate:int; //当前强化百分比
		public var sex:int;
		public var signature:String;
		public var equipLvl:int;
		public var material:int //材质(1金,2木,3皮,4布,5玉)
		public var refine_index:int; //精炼系数
		public var five_level:int=-1; //五行等级
		public var sign_role_id:int; //已经签名的角色ID
		public var form:String;
		public var bind_arr:Array; //绑定属性数组
		public var five_arr:p_equip_five_ele; //五行属性
		public var whole_attr:p_equip_whole_attr; //装备套装的全部属性
		public var sub_quality:int; //装备子品质
		public var quality_rate:int; //装备品质加成值

		override public function set typeId(value:int):void {
			super.typeId=value;
			var item:Object=ItemLocator.getInstance().getEquip(typeId);
			name=item.name;
			kind=item.kind;
			minlvl=item.minlvl;
			maxlvl=item.maxlvl;
			color=item.color;
			putWhere=item.putWhere;
			path=item.path;
			sex=item.sex;
			desc=item.desc;
			material=item.material;
			form=item.form;
			maxico = item.maxico;
		}

		public function EquipVO() {

		}

		override public function copy(vo:p_goods):void {
			super.copy(vo);
			this.loadposition=vo.loadposition;
			this.quality=vo.quality;
			this.current_endurance=vo.current_endurance;
			this.color=vo.current_colour;
			this.forge_num=vo.forge_num;
			this.reinforce_result=vo.reinforce_result;
			this.punch_num=vo.punch_num;
			this.stone_num=vo.stone_num;
			this.add_property=vo.add_property;
			this.stones=vo.stones;
			this.reinforce_rate=vo.reinforce_rate;
			this.endurance=vo.endurance;
			this.signature=vo.signature;
			this.equipLvl=vo.level;
			this.refine_index=vo.refining_index;
			this.sign_role_id=vo.sign_role_id;
			if (vo.five_ele_attr != null) {
				this.five_level=vo.five_ele_attr.level;
				this.five_arr=vo.five_ele_attr;
			}
			this.bind_arr=vo.equip_bind_attr;
			this.whole_attr=vo.whole_attr;
			this.sub_quality=vo.sub_quality;
			this.quality_rate=vo.quality_rate;
		}

		public function getSellPrice():Number {
			var m:Number=(sellPrice * Math.pow(1.22, refine_index) * Math.pow(equipLvl / 5, 1.5) + Math.pow(color - 1, 4) * 10) * (current_endurance / endurance);
			return Math.ceil(m);
		}

		public function getFixPrice():Number {
			var m:Number=(sellPrice * Math.pow(1.22, refine_index) * Math.pow(equipLvl / 5, 1.5) + Math.pow(color - 1, 4) * 10) * 0.5 * ((endurance - current_endurance) / endurance);
			return Math.ceil(m);
		}
	}
}