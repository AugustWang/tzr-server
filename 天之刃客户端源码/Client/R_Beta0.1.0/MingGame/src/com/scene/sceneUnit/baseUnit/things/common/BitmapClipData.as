package com.scene.sceneUnit.baseUnit.things.common
{
	
	import com.scene.sceneUnit.baseUnit.things.avatar.AvatarConstant;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	public class BitmapClipData
	{
		public var complete:Boolean = false;
		public var url:String;
		
		public var domain:ApplicationDomain;
		
		private var _source:MovieClip;
		private var _bitmapdatas:Dictionary;
		
		public function BitmapClipData()
		{
			
		}
		
		public function set source(mc:MovieClip):void{
			if(mc != null){
				_source = mc;
				_bitmapdatas = new Dictionary();
			}
		}
		
		public function getHeight():int{
			var elementVO:BitmapFrame = getFrame(AvatarConstant.ACTION_STAND + "_d" + AvatarConstant.DIR_UP + "_0");
			if( elementVO && elementVO.data ){
				return -elementVO.offsetY;
			}
			return 120;
		}
		
		public function getLight(value:String):int{
			if(_source && _source.hasOwnProperty(value.concat('_l'))){
				return _source[value.concat('_l')];
			}
			return 0;
		}
		
		public function getFrame(value:String):BitmapFrame{
			if(_bitmapdatas && _bitmapdatas.hasOwnProperty(value)){
				return _bitmapdatas[value];
			}else{
				var elementVO:BitmapFrame = new BitmapFrame();
				var cls:Class;
				//如果方向为左边的翻转
				try{
					if(value.indexOf('_d5') != -1 || value.indexOf('_d6') != -1 || value.indexOf('_d7') != -1){
						var valueTemp:String;
						valueTemp = value.replace('_d5','_d3').replace('_d6','_d2').replace('_d7','_d1');
						if(_bitmapdatas.hasOwnProperty(valueTemp)){
							elementVO.data =  flipHorizontal(_bitmapdatas[valueTemp].data);
						}else if(domain.hasDefinition(valueTemp)){
							cls = Class(domain.getDefinition(valueTemp));
							var newElementVO:BitmapFrame = new BitmapFrame();
							newElementVO.data =  new cls(0,0);
							newElementVO.offsetX = _source[valueTemp.concat('_x')];
							newElementVO.offsetY = _source[valueTemp.concat('_y')];
							_bitmapdatas[valueTemp] = newElementVO;
							elementVO.data =  flipHorizontal(newElementVO.data);
						}
						if(elementVO.data){
							elementVO.offsetX = -(elementVO.data.width + _source[valueTemp.concat('_x')]);
							elementVO.offsetY = _source[valueTemp.concat('_y')];
							_bitmapdatas[value] = elementVO;
						}
					}else if(domain.hasDefinition(value)){
						cls = Class(domain.getDefinition(value));
						elementVO.data =  new cls(0,0);
						elementVO.offsetX = _source[value.concat('_x')];
						elementVO.offsetY = _source[value.concat('_y')];
						_bitmapdatas[value] = elementVO;
					}
				}catch(error:Error){
					trace(error.getStackTrace())
				}
				return elementVO
			}
		}
		
		private static function flipHorizontal(bt:BitmapData):BitmapData
		{
			var bmd:BitmapData = new BitmapData(bt.width, bt.height, true, 0x00000000);
			var mat:Matrix=new Matrix()
			mat.scale(-1,1);
			mat.tx+=bt.width
			bmd.draw(bt,mat);
			return bmd;
		}
		
		public function unload():void{
			
		}
	}
}