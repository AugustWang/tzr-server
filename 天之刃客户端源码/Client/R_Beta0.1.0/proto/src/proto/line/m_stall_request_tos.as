package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_request_tos extends Message
	{
		public var name:String = "";
		public var mode:int = 0;
		public var time_hour:int = 0;
		public function m_stall_request_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_request_tos", m_stall_request_tos);
		}
		public override function getMethodName():String {
			return 'stall_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.mode);
			output.writeInt(this.time_hour);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.name = input.readUTF();
			this.mode = input.readInt();
			this.time_hour = input.readInt();
		}
	}
}
