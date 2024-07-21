package com.common.dragManager
{
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.BaseItemVO;

	/**
	 * 判断是否可以让地图接受从窗口丢弃出来的物品 
	 * @author Administrator
	 * 
	 */
	public class DragOnMap
	{
		public function DragOnMap()
		{
		}
		
		public static function allowAccept(data:Object,name:String):Boolean{
			if(name == DragConstant.SPLIT_ITEM){
				var itemVO:BaseItemVO = PackManager.getInstance().getItemById(data.oid);
				PackManager.getInstance().updateGoods(itemVO.bagid,itemVO.position,itemVO);
			}
			return true;
		}
	}
}