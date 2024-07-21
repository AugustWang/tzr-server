package modules.broadcast
{
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.loaders.ResourcePool;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class KeyWord
	{
		private var regexpWords:Array=['\\\\','\\\*','\\\$','\\\^','\\\!','\\\[','\\\]','\\\.']
		private static var _instance:KeyWord;
		public static const TALK_WORDS:String='TALK_WORDS';
		public static const AD_WORDS:String='AD_WORDS';
		public static const ALL_WORDS:String='ALL_WORDS';
		private var talk_words:Array = new Array;
		private var name_words:Array;
		private var ad_words:Array;
		
		
		public function KeyWord()
		{
			//init();
			initCL();
		}
		
		/**
		 * 明2的敏感词版本 
		 * 
		 */		
		public function init():void
		{
			var bytes:ByteArray=ResourcePool.get(GameConfig.WORDFILTER) as ByteArray;
			bytes.position=0;
			var str:String=bytes.readUTFBytes(bytes.length);
			//talk_words=str.split(',\n').join(',').split(',');
			talk_words=str.split('\r\n');
		}
		
		/**
		 * 明1的敏感词版本 
		 * 
		 */		
		public function initCL():void
		{
			var bytes:ByteArray=ResourcePool.get(GameConfig.WORDFILTER) as ByteArray;
			bytes.position=0;
			var str:String=bytes.readUTFBytes(bytes.length);
			var arr:Array = str.split('\r\n');
			var len:int = arr.length;
			for(var i:int=0; i<len; i++) {
				if (arr[i] != null && arr[i] != '') {
					var regStr:String = (arr[i] as String).split('').join('.*');
					var reg:RegExp = new RegExp(regStr,'gi');
					talk_words.push(reg);
				}
			}
//			if(GameParameters.getInstance().loginPage.indexOf("ming2game") == -1){
//				talk_words.push(new RegExp("m2_"));
//			}
		}
		
		public static function instance():KeyWord
		{
			if(_instance==null)_instance=new KeyWord;
			return _instance;
		}
		public function replace(str:String,type:String='ALL_WORDS'):String
		{
			return replacewords(this.talk_words,str);
		}
		
		private var dic:Dictionary
		private function replacewords(array:Array,str:String):String
		{
			var l:int = array.length;
			for(var i:int=0;i<l;i++)
			{
				if (array[i]) 
				{
					str=str.replace( array[i], "*");
				}
			}
			return str;
		}
		
		private function takeUnRegisterString_(array:Array,str:String):void
		{
			for(var i:int=0;i<array.length;i++)
			{
				if(array[i]!=null && array[i] != "")
				{
					var regExp:RegExp =array[i] as RegExp;
					regExp.lastIndex = 0;
					var boolean:Boolean=regExp.test(str);
					var newStr:String=str.substr(0,str.length);
					if(boolean==true)
					{
						newStr.replace(regExp,cleanFunc);
					}
				}
			}
		}
		
		private function cleanFunc(...arg):String
		{
			var strx:String=arg[0].split(' ').join('');
			dic[strx]==null?dic[strx]=strx:'';
			return strx;
		}
		public function takeUnRegisterString(str:String):String
		{
			dic=new Dictionary;
			var unstr:String='<FONT COLOR="#ffffff">包含以下非法字符：</FONT><FONT COLOR="#FF0000">';
			takeUnRegisterString_(talk_words,str);
			
			for(var j:String in dic ) {
				unstr+=j+' , ';
			}
			var index:int=unstr.lastIndexOf(',');
			index==-1?index=unstr.length:index=index;
			unstr=unstr.substr(0,index)+'</FONT>';
			return unstr;
		}
		
		private function hasUnRegisterString_(array:Array,str:String):Boolean
		{
			for(var i:int=0;i<array.length;i++)
			{
				if(array[i]!=null && array[i] != ""){
					var regExp:RegExp =array[i] as RegExp;
					if(regExp.test(str)){
						return true;
					}
				}
			}
			return false;
		}
		public function hasUnRegisterString(str:String):Boolean
		{
			if(hasUnRegisterString_(talk_words,str)) {
				return true;
			}
			return false;
		}
		private function toXingString(index:int):String
		{
			var s:String='';
			for(var i:int=0;i<index;i++)
			{
				s+='*';
			}
			return s;
		}
	}
}