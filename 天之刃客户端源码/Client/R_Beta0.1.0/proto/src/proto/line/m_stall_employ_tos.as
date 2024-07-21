package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_employ_tos extends Message
	{
		public var hour:int = 0;
		public function m_stall_employ_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_employ_tos", m_stall_employ_tos);
		}
		public override function getMethodName():String {
			return 'stall_employ';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.hour);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.hour = input.readInt();
		}
	}
}
