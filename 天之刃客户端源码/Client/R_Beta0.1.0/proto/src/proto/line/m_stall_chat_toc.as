package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_chat_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var src_role_id:int = 0;
		public var src_role_name:String = "";
		public var content:String = "";
		public var time:int = 0;
		public function m_stall_chat_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_chat_toc", m_stall_chat_toc);
		}
		public override function getMethodName():String {
			return 'stall_chat';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.src_role_id);
			if (this.src_role_name != null) {				output.writeUTF(this.src_role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.src_role_id = input.readInt();
			this.src_role_name = input.readUTF();
			this.content = input.readUTF();
			this.time = input.readInt();
		}
	}
}
