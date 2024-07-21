package com.utils
{
	import flash.utils.ByteArray;
	
	/**
	 * 
	 * @author Sai
	 * @playerversion flashplayer 10
	 */	
	public class ObjectUtils
	{
		public function ObjectUtils()
		{
		}
		public static function copy(value:Object):Object
		{
			
			var buffer:ByteArray = new ByteArray();
			buffer.writeObject(value);
			buffer.position = 0;
			var result:Object = buffer.readObject();
			return result;
		}

	}
}