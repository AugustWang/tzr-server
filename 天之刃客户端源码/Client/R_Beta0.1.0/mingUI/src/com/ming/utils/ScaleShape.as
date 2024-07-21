package com.ming.utils {
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	
	public class ScaleShape extends Shape {
		
		protected var _originalBitmap : BitmapData;
		protected var _scale9Grid : Rectangle = null;
		protected var _w:Number = 0;
		protected var _h:Number = 0;
		
		
		function ScaleShape(bmpData : BitmapData = null) {
			_originalBitmap = bmpData;
		}

		public function set bitmapData(bmpData : BitmapData) : void {
			_originalBitmap = bmpData;
			if (_scale9Grid != null) {
				if (!validGrid(_scale9Grid)) {
					_scale9Grid = null;
				}
				setSize(bmpData.width, bmpData.height);
			}
		} 
		

		override public function set width(w : Number) : void {
			if (w != width) {
				setSize(w, height);
			}
		}
		
		override public function get width():Number{
			if(_w > 0){
				return _w;
			}else if(_originalBitmap){
				return _originalBitmap.width;
			}
			return 0;
		}
		
		override public function set height(h : Number) : void {
			if (h != height) {
				setSize(width, h);
			}
		}
		
		override public function get height():Number{
			if(_h > 0){
				return _h;
			}else if(_originalBitmap){
				return _originalBitmap.height;
			}
			return 0;
		}
		
		public function setScale9Grid(r : Rectangle):void{
			if(r){
				if (!validGrid(r)) {
					throw (new Error("#001 - 当前scale9Grid"+r.toString()+"参数设置和位图数据[w="+_originalBitmap.width+",h="+_originalBitmap.height+"]不匹配，请重设！"));
				}
				_scale9Grid = r.clone();
			}
		}
		

		override public function set scale9Grid(r : Rectangle) : void {
			if ((_scale9Grid == null && r != null) || (_scale9Grid != null && !_scale9Grid.equals(r))) {
				if (r == null) {
					var currentWidth : Number = width;
					var currentHeight : Number = height;
					_scale9Grid = null;
					setSize(currentWidth, currentHeight);
				} else {
					if (!validGrid(r)) {
						throw (new Error("#001 - 当前scale9Grid"+r.toString()+"参数设置和位图数据[w="+_originalBitmap.width+",h="+_originalBitmap.height+"]不匹配，请重设！"));
					}
					_scale9Grid = r.clone();
					resizeBitmap(width, height);
				}
			}
		}
		
		private function validGrid(r : Rectangle) : Boolean {
			return r.right <= _originalBitmap.width && r.bottom <= _originalBitmap.height;
		}
		
		override public function get scale9Grid() : Rectangle {
			return _scale9Grid;
		}
		
		public function setSize(w : Number, h : Number) : void {
			if(w == _w && _h == h)return;
			_w = w;
			_h = h;
			resizeBitmap(w, h);
		}
		
		public function getOriginalBitmapData() : BitmapData {
			return _originalBitmap;
		}
		
		protected function resizeBitmap(w : Number, h : Number) : void {
			graphics.clear();
			if(scale9Grid){
				BitmapUtils.scale9Fill(graphics,_originalBitmap,scale9Grid.top,_scale9Grid.right ,scale9Grid.left,scale9Grid.bottom,0,0,w,h);
			}else{
				w = Math.max(_originalBitmap.width,w);
				h = Math.max(_originalBitmap.height,h);
				BitmapUtils.fillBitmapData(graphics,_originalBitmap,0,0,w,h);
			}
		}
	}
}