package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_broadcast_laba_tos extends Message
	{
		public var content:String = "";
		public var laba_id:int = 0;
		public function m_broadcast_laba_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_broadcast_laba_tos", m_broadcast_laba_tos);
		}
		public override function getMethodName():String {
			return 'broadcast_laba';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.laba_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.content = input.readUTF();
			this.laba_id = input.readInt();
		}
	}
}
