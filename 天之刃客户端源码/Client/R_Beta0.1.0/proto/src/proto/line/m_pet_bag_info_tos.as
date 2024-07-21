package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_bag_info_tos extends Message
	{
		public function m_pet_bag_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_bag_info_tos", m_pet_bag_info_tos);
		}
		public override function getMethodName():String {
			return 'pet_bag_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
