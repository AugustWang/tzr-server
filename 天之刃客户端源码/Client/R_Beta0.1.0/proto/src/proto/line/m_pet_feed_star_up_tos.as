package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_feed_star_up_tos extends Message
	{
		public function m_pet_feed_star_up_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_feed_star_up_tos", m_pet_feed_star_up_tos);
		}
		public override function getMethodName():String {
			return 'pet_feed_star_up';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
