package modules.mypackage.vo
{
	import modules.mypackage.managers.ItemLocator;
	
	import proto.common.p_goods;

	/**
	 * 普通物品VO
	 */ 
	public class GeneralVO extends BaseItemVO
	{
		public var usenum:int = 0; //	使用次数
		public var effectType:int; //判断是什么物品
		public var minlvl:int; //要求最少等级
		public var maxlvl:int; //要求最大等级
		public var maxValue:int; //最大加成值
		public var currentValue:int; //当前已经加成值
		public function GeneralVO()
		{
			super();
		}
		
		override public function set typeId(value:int):void{
			super.typeId = value;
			var item:Object = ItemLocator.getInstance().getGeneral(typeId);
			kind = item.kind;
			name = item.name;
			color = item.color;
			usenum = item.usenum;
			minlvl = item.minlvl;
			maxlvl = item.maxlvl;
			path = item.path;
			effectType = item.effectType;
			desc = item.desc;
			maxico = item.maxico;
		}
		
		override public function copy(vo:p_goods):void{
			super.copy(vo);
			maxValue = vo.endurance;
			currentValue = vo.current_endurance;
		}	
	}
}