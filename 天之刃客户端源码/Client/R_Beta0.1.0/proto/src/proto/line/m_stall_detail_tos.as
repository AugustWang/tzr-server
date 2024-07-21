package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_detail_tos extends Message
	{
		public var role_id:int = 0;
		public function m_stall_detail_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_detail_tos", m_stall_detail_tos);
		}
		public override function getMethodName():String {
			return 'stall_detail';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
		}
	}
}
