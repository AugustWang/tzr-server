package com.ming.ui.skins
{
    import com.ming.core.IDisposable;
    import com.ming.ui.style.BitmapDataPool;
    import com.ming.utils.ScaleShape;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Rectangle;

	/**
	 * 所有UI组件的皮肤基类
	 */ 
    public class Skin extends Sprite implements IDisposable
    {
		/**
		 * 组件是否被锁定
		 */ 
        private var _enableMouse:Boolean = true;
		/**
		 * 皮肤数据
		 */ 
        private var _skinBitmapData:BitmapData;
		/**
		 * 皮肤实例
		 */ 
        private var _skinInstance:ScaleShape;
		/**
		 * 9切片 
		 */		
		private var rect:Rectangle;
		/**
		 * 所属对象 
		 */		
		public var owner:DisplayObject;
		/**
		 * @constructor
		 * @param skinClass 皮肤类
		 */ 
        public function Skin(_skinBitmapData:BitmapData = null,rect:Rectangle=null)
        {
            if (_skinBitmapData != null)
            {
				this.rect = rect;
				this.skinBitmapData = _skinBitmapData;
				mouseEnabled = mouseChildren = false;
            }
        }
		/**
		 * 设置和获取皮肤实例
		 * @param skin 皮肤实例
		 */ 
		public function set skinInstance(skin:ScaleShape) : void
		{
			this._skinInstance = skin;
		}
        public function get skinInstance() : ScaleShape
        {
            return _skinInstance;
        }
		/**
		 * 禁用和取消组件
		 */ 
        public function get enableMouse() : Boolean
        {
            return _enableMouse;
        }
        public function set enableMouse(value:Boolean) : void
        {
            _enableMouse = value;
			mouseEnabled = value;
        }
		/**
		 * @override 覆盖父类的设置宽度的方法 
		 */ 
		override public function set width(value:Number) : void
		{
			if (skinInstance == null) return;
			skinInstance.width = value;
		}
		
		override public function get width():Number{
			if (skinInstance == null) return 0;
			return skinInstance.width;
		}
		
		public function get realWidth():Number{
			if(_skinBitmapData){
				return _skinBitmapData.width;
			}
			return 0;
		}
		
		public function get realHeight():Number{
			if(_skinBitmapData){
				return _skinBitmapData.height;
			}
			return 0;
		}
		
		public function setSize(w:Number, h:Number):void
		{
			if(skinInstance != null){
				if(w != 0 && h != 0){
					skinInstance.setSize(w,h);
				}
			}
		}
		/**
		 * @override 覆盖父类的设置高度的方法 
		 */ 		
		override public function set height(value:Number) : void
		{
			if (skinInstance == null)return;
			skinInstance.height = value;
		}
		override public function get height():Number{
			if (skinInstance == null) return 0;
			return skinInstance.height;
		}		
		
		/**
		 * 设置皮肤类
		 * @param value 皮肤类
		 */ 
		public function set skinBitmapData(value:BitmapData) : void
		{
			dispose();
			_skinBitmapData = value;
			skinInstance = new ScaleShape(_skinBitmapData);
			skinInstance.x = 0;
			skinInstance.y = 0;
			skinInstance.setScale9Grid(rect);
			addChild(skinInstance);
			
		}
		
		public function dispose():void{

		}
    }
}
