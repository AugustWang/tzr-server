/**
 *
 *	ScaleBitmap
 *	
 * 	@version	1.1
 * 	@author 	Didier BRUN	-  http://www.bytearray.org
 * 	
 * 	@version	1.2.1
 * 	@author		Alexandre LEGOUT - http://blog.lalex.com
 *
 * 	@version	1.2.2
 * 	@author		Pleh
 * 	
 * 	Project page : http://www.bytearray.org/?p=118
 *
 */

package com.ming.utils {
	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.geom.Matrix;	import flash.geom.Point;	import flash.geom.Rectangle;	import flash.utils.getTimer;	

	public class ScaleBitmap extends Bitmap {

		// ------------------------------------------------
		//
		// ---o properties
		//
		// ------------------------------------------------

		protected var _originalBitmap : BitmapData;
		protected var _scale9Grid : Rectangle = null;
		protected var _w:Number;
		protected var _h:Number;
		// ------------------------------------------------
		//
		// ---o constructor
		//
		// ------------------------------------------------

		
		function ScaleBitmap(bmpData : BitmapData = null, pixelSnapping : String = "auto", smoothing : Boolean = false) {
			
			// super constructor
			super(bmpData, pixelSnapping, smoothing);
		
			// original bitmap
			_originalBitmap = bmpData;
		}

		// ------------------------------------------------
		//
		// ---o public methods
		//
		// ------------------------------------------------
		
		/**
		 * setter bitmapData
		 */
		override public function set bitmapData(bmpData : BitmapData) : void {
			_originalBitmap = bmpData;
			if (_scale9Grid != null) {
				if (!validGrid(_scale9Grid)) {
					_scale9Grid = null;
				}
				setSize(bmpData.width, bmpData.height);
			} else {
				assignBitmapData(_originalBitmap);
			}
		} 

		/**
		 * setter width
		 */
		override public function set width(w : Number) : void {
			if (w != width) {
				setSize(w, height);
			}
		}

		/**
		 * setter height
		 */
		override public function set height(h : Number) : void {
			if (h != height) {
				setSize(width, h);
			}
		}
		
		public function setScale9Grid(r : Rectangle):void{
			if(r){
				_scale9Grid = r.clone();
			}
		}
		
		/**
		 * set scale9Grid
		 */
		override public function set scale9Grid(r : Rectangle) : void {
			// Check if the given grid is different from the current one
			if ((_scale9Grid == null && r != null) || (_scale9Grid != null && !_scale9Grid.equals(r))) {
				if (r == null) {
					// If deleting scalee9Grid, restore the original bitmap
					// then resize it (streched) to the previously set dimensions
					var currentWidth : Number = width;					var currentHeight : Number = height;
					_scale9Grid = null;
					assignBitmapData(_originalBitmap);
					setSize(currentWidth, currentHeight);
				} else {
					if (!validGrid(r)) {
						throw (new Error("#001 - The _scale9Grid does not match the original BitmapData"));
						return;
					}
					
					_scale9Grid = r.clone();
					resizeBitmap(width, height);
					scaleX = 1;
					scaleY = 1;
				}
			}
		}

		/**
		 * assignBitmapData
		 * Update the effective bitmapData
		 */
		private function assignBitmapData(bmp : BitmapData) : void {
			//super.bitmapData.dispose(); 现已经改为多个ScaleBitamp共享一个BitmapData 所以不能进行数据销毁
			super.bitmapData = bmp;
		}

		private function validGrid(r : Rectangle) : Boolean {
			return r.right <= _originalBitmap.width && r.bottom <= _originalBitmap.height;
		}

		/**
		 * get scale9Grid
		 */
		override public function get scale9Grid() : Rectangle {
			return _scale9Grid;
		}

		
		/**
		 * setSize
		 */
		public function setSize(w : Number, h : Number) : void {
			if(w == _w && _h == h)return;
			if (_scale9Grid == null) {
				super.width = w;
				super.height = h;
			} else {
				w = Math.max(w, _originalBitmap.width - _scale9Grid.width);
				h = Math.max(h, _originalBitmap.height - _scale9Grid.height);
				resizeBitmap(w, h);
			}
			_w = w;
			_h = h;
		}

		/**
		 * get original bitmap
		 */
		public function getOriginalBitmapData() : BitmapData {
			return _originalBitmap;
		}

		// ------------------------------------------------
		//
		// ---o protected methods
		//
		// ------------------------------------------------
		
		/**
		 * resize bitmap
		 */
		protected function resizeBitmap(w : Number, h : Number) : void {
			var bmpData : BitmapData = new BitmapData(w, h, true, 0x00000000);
			
			var rows : Array = [0, _scale9Grid.top, _scale9Grid.bottom, _originalBitmap.height];
			var cols : Array = [0, _scale9Grid.left, _scale9Grid.right, _originalBitmap.width];
			
			var dRows : Array = [0, _scale9Grid.top, h - (_originalBitmap.height - _scale9Grid.bottom), h];
			var dCols : Array = [0, _scale9Grid.left, w - (_originalBitmap.width - _scale9Grid.right), w];
			
			var originx:Number,originy:Number,originW:Number,originH:Number;
			var drawx:Number,drawy:Number,drawW:Number,drawH:Number;
			var mat : Matrix = new Matrix();
			var drawRect:Rectangle = new Rectangle();
			bmpData.lock();
			for (var cx : int = 0;cx < 3; cx++) {
				for (var cy : int = 0 ;cy < 3; cy++) {
					originx = cols[cx];originy = rows[cy];originW = cols[cx + 1] - cols[cx];originH = rows[cy + 1] - rows[cy];
					drawx = dCols[cx];drawy = dRows[cy];drawW = dCols[cx + 1] - dCols[cx];drawH = dRows[cy + 1] - dRows[cy];
					mat.identity();
					mat.a = drawW / originW;
					mat.d = drawH / originH;
					mat.tx = drawx - originx*mat.a;
					mat.ty = drawy - originy*mat.d;
					drawRect.x = drawx;drawRect.y = drawy,drawRect.width = drawW;drawRect.height = drawH;
					bmpData.draw(_originalBitmap, mat, null, null, drawRect, smoothing);
				}
			}
			bmpData.unlock();
			assignBitmapData(bmpData);
		}
		/**
		 * (此方法可以取代resizeBitmap,因为当放大倍数过高的时候上面的方法就会出现分裂)。 
		 */		
//		private var bitmapdatas:Array;
//		protected function sliceBitmap():void{
//			bitmapdatas = [];	
//			
//			var rows : Array = [0, _scale9Grid.top, _scale9Grid.bottom, _originalBitmap.height];
//			var cols : Array = [0, _scale9Grid.left, _scale9Grid.right, _originalBitmap.width];
//			
//			for (var cx : int = 0;cx < 3; cx++) {
//				for (var cy : int = 0 ;cy < 3; cy++) {
//					var origin:Rectangle = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
//					var bmpData : BitmapData = new BitmapData(origin.width, origin.height, true, 0x00000000);
//					bmpData.copyPixels(_originalBitmap,origin,new Point(0,0));
//					bitmapdatas.push(bmpData);
//				}
//			}
//		}
//		
//		protected function resize9Bitmap(w:Number,h:Number):void{
//			if(bitmapdatas == null){
//				sliceBitmap();
//			}
//			var bmpData : BitmapData = new BitmapData(w, h, true, 0x00000000);
//	
//			var dRows : Array = [0, _scale9Grid.top, h - (_originalBitmap.height - _scale9Grid.bottom), h];
//			var dCols : Array = [0, _scale9Grid.left, w - (_originalBitmap.width - _scale9Grid.right), w];
//			
//			var draw : Rectangle;
//			
//			for (var cx : int = 0;cx < 3; cx++) {
//				for (var cy : int = 0 ;cy < 3; cy++) {
//					draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
//					var _oBitmap : BitmapData = bitmapdatas[cx*3 + cy];
//					bmpData.draw(_oBitmap,new Matrix(draw.width/_oBitmap.width,0,0,draw.height/_oBitmap.height,draw.x,draw.y), null, null, null, smoothing);
//				}
//			}
//			assignBitmapData(bmpData);
//		}
	}
}