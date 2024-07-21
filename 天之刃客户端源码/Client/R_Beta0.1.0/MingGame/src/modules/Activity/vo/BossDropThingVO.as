package modules.Activity.vo
{
	import com.utils.HtmlUtil;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.vo.BaseItemVO;

	public class BossDropThingVO
	{
		public var typeId:int;
		public var name:String;
		public var color:int;
		public function BossDropThingVO()
		{
			
		}
		
		private var _itemVO:BaseItemVO;
		public function get itemVO():BaseItemVO{
			if(_itemVO == null){
				_itemVO = ItemLocator.getInstance().getObject(typeId);
				_itemVO.color = color;
			}
			return _itemVO;
		}
		
		public function toString():String{
			return HtmlUtil.font(HtmlUtil.link(name,typeId.toString(),true),ItemConstant.COLOR_VALUES[color])+"；";
		}
	}
}