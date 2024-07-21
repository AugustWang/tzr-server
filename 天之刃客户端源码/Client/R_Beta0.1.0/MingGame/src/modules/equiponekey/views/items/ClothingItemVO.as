package modules.equiponekey.views.items
{
	import com.globals.GameConfig;
	
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;

	public class ClothingItemVO
	{
		public var suitId:int;  //套装ID
		public var equips_list:Array;
		private var _name:String; //套装名称
		public var path:BitmapData; //为了方便快捷栏取显示对象统一
		public function ClothingItemVO()
		{
		
		}
		
		public function get typeId():String{
			return ModuleCommand.CLOTHING_ID;
		}
		
		public function set name(value:String):void{
			_name = value;
		}
		public function get name():String{
			return _name;
		}
		
		public function draw(invalidate:Boolean=false):void{
			if(path != null && invalidate == false)return;
			var bitmapClass:Class = Style.getClass(GameConfig.T1_UI,"clothing");
			var bitmapData:BitmapData = new bitmapClass(0,0);
			if(_name && _name != ""){
				var txt:TextField = new TextField();
				txt.defaultTextFormat = new TextFormat("宋体",16,0x00ff00,true);
				txt.filters = [new GlowFilter(0x000000,1,3,3,4)];
				var reg:RegExp = new RegExp("第[一二三四五六七八]{1}套");
				if(reg.test(_name)){
					txt.text = _name.substr(1,1);
				}else{
					txt.text = _name.substr(0,1);
				}
				var matrix:Matrix = new Matrix();
				matrix.tx = (36 - txt.textWidth - 7)/2;
				matrix.ty = (36 - txt.textHeight - 7)/2;
				bitmapData.draw(txt,matrix);
			}
			path = bitmapData;
		}
	}
}