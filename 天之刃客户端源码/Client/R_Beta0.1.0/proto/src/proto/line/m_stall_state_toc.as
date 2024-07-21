package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_state_toc extends Message
	{
		public var stall_state:int = 0;
		public function m_stall_state_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_state_toc", m_stall_state_toc);
		}
		public override function getMethodName():String {
			return 'stall_state';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.stall_state);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.stall_state = input.readInt();
		}
	}
}
