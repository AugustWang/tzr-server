package com.ming.utils
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

    /**
     * 主要是一些处理矩形区域的方法
     */	
    public final class RectUtil
    {
		
		/**
		 * 获得矩形（以父容器为基准）
		 * 当源是stage时，获取的将不是图形矩形，而是舞台的矩形。
		 * 
		 * @param obj	显示对象，
		 * @param targetSpace	当前坐标系，默认值为父显示对象
		 * @return 
		 * 
		 */		
		public static function getRect(obj:DisplayObject,space:DisplayObject=null):Rectangle
		{	
			if (!obj)
				return null;
	
			if (obj is Stage)
			{
				var stageRect:Rectangle = new Rectangle(0,0,(obj as Stage).stageWidth,(obj as Stage).stageHeight);//目标为舞台则取舞台矩形
				if (space)
					return localRectToContent(stageRect,obj as DisplayObject,space);
				else
					return stageRect;
			}else{
				if (!space)
					space = (obj as DisplayObject).parent;
				
				if (obj.width == 0 || obj.height == 0)//长框为0则只变换坐标
				{
					var p:Point = localToContent(new Point(),obj,space);
					return new Rectangle(p.x,p.y,0,0);
				}
				
				if ((obj as DisplayObject).scrollRect)//scrollRect有时候不会立即确认属性
					return localRectToContent((obj as DisplayObject).scrollRect,obj,space)
				else
					return obj.getRect(space);
			}
			return null;
		}
		
		
		/**
		 * 转换坐标到某个显示对象
		 * 
		 * @param pos	坐标
		 * @param source	源
		 * @param target	目标
		 * @return 
		 * 
		 */		
		public static function localToContent(pos:Point,source:DisplayObject,target:DisplayObject):Point
		{
			if (target && source)
				return target.globalToLocal(source.localToGlobal(pos));
			else if (source)
				return source.localToGlobal(pos);
			else if (target)
				return target.globalToLocal(pos);
			return null;
		}
		
		/**
		 * 转换矩形坐标到某个显示对象
		 * 
		 * @param rect	矩形
		 * @param source	源
		 * @param target	目标
		 * @return 
		 * 
		 */		
		public static function localRectToContent(rect:Rectangle,source:DisplayObject,target:DisplayObject):Rectangle
		{
			if (source == target)
				return rect;
			
			var topLeft:Point = localToContent(rect.topLeft,source,target);
			var bottomRight:Point = localToContent(rect.bottomRight,source,target);
			return new Rectangle(topLeft.x,topLeft.y,bottomRight.x - topLeft.x,bottomRight.y - topLeft.y);
		}
		

        /**
         * 获得中心点
         * 
         * @param obj	显示对象或者矩形
         * @return 
         * 
         */		
        public static function center(obj:DisplayObject,space:DisplayObject=null):Point
        {
        	var rect:Rectangle = getRect(obj,space);
        	return (rect)?new Point(rect.x + rect.width / 2, rect.y + rect.height / 2):null;
        }
    }
}


