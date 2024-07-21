package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_chat_tos extends Message
	{
		public var target_role_id:int = 0;
		public var content:String = "";
		public function m_stall_chat_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_chat_tos", m_stall_chat_tos);
		}
		public override function getMethodName():String {
			return 'stall_chat';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.target_role_id);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.target_role_id = input.readInt();
			this.content = input.readUTF();
		}
	}
}
