package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_remote_depot_tos extends Message
	{
		public function m_vip_remote_depot_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vip_remote_depot_tos", m_vip_remote_depot_tos);
		}
		public override function getMethodName():String {
			return 'vip_remote_depot';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
