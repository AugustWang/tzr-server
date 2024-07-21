package modules.mypackage.vo
{
	import modules.mypackage.managers.ItemLocator;
	
	import proto.common.p_goods;
	import proto.common.p_property_add;

	/**
	 * 宝石VO
	 */ 
	public class StoneVO extends BaseItemVO
	{
		public var usenum:int = 0; //	使用次数
//		public var level:int;	//宝石当前等级
		public var embe_pos:int;	//镶嵌位置
		public var embe_equipid:int;  //镶嵌的装备ID
		public var embe_equip_list:Array;
		public var add_property:p_property_add; //石头额外附加属性
		public function StoneVO()
		{
			super();
		}
		
		override public function set typeId(value:int):void{
			super.typeId = value;
			var item:Object = ItemLocator.getInstance().getStone(typeId);
			type = item.type;
			name = item.name;
			color = item.color;
			path = item.path;
			desc = item.desc;
			usenum = item.usenum;
			maxico = item.maxico;
			embe_equip_list = String(item.embe_equip_list).split(",");
		}
		
		override public function copy(vo:p_goods):void{
			super.copy(vo);
			this.level = vo.level;
			this.embe_pos = vo.embe_pos;
			this.embe_equipid = vo.embe_equipid;
			this.add_property = vo.add_property;
		}	
		
		override public function toCompare(item:BaseItemVO):Boolean{
			var stoneVO:StoneVO = item as StoneVO;
			if(stoneVO == null) return false;
			return super.toCompare(item) && level == stoneVO.level;
		}

	}
}