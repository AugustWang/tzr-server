package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class s_chat_leave_channel_tos extends Message
	{
		public var role_id:int = 0;
		public var channel_sign:String = "";
		public function s_chat_leave_channel_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.common.s_chat_leave_channel_tos", s_chat_leave_channel_tos);
		}
		public override function getMethodName():String {
			return 'chat_leave_channel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.channel_sign = input.readUTF();
		}
	}
}
