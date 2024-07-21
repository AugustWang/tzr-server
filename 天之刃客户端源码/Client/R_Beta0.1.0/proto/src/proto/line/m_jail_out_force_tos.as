package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_jail_out_force_tos extends Message
	{
		public function m_jail_out_force_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_jail_out_force_tos", m_jail_out_force_tos);
		}
		public override function getMethodName():String {
			return 'jail_out_force';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
