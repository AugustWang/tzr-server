package com.common.dragManager
{
	import com.ming.core.IDataRenderer;
	
	import flash.display.DisplayObject;
 
	public interface IDragItem extends IDataRenderer
	{
		/**
		 * 设置内容
		 */ 
		function setContent(content:*,_data:*):void;
		 /**
		 * 获取项目内容
		 */ 
		 function getContent():*;
		 /**
		 * 销毁项目内容( 例如：容器里面的装备图片)
		 */
		 function disposeContent():void;
		 /**
		  * 由于粘附拖拽，有些相同的拖拽容器项不能接受某些东西，（比如人物装备的容器项，他只能接受特定的装备类型）
		  * 所以此方法是提供给DragItemManager使用，用来判断是否可以放到点击或者释放到当前改容器中 
		  * @param data 数据
		  * @param name 名称(当前拖拽的物品是什么名称，可以认为是一种标识)
		  * @return true 可以接受 false 不可以接受
		  */		  
		 function allowAccept(data:Object,name:String):Boolean;
		 /**
		  * 在拖拽时，只要实现该接口，内容将会通过DragItemManager自动设置到这个方法里面 
		  * @param dragData 数据
		  * @param dragTarget 目标对象
		  * @param itemName 标识名称
		  * 
		  */		 
		 function dragDrop(dragData:Object,dragTarget:DisplayObject,itemName:String):void;
	}
}