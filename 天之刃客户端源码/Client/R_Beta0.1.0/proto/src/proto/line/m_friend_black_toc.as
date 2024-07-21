package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_black_toc extends Message
	{
		public var succ:Boolean = true;
		public var name:String = "";
		public var friend_info:p_friend_info = null;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public function m_friend_black_toc() {
			super();
			this.friend_info = new p_friend_info;

			flash.net.registerClassAlias("copy.proto.line.m_friend_black_toc", m_friend_black_toc);
		}
		public override function getMethodName():String {
			return 'friend_black';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_friend_info:ByteArray = new ByteArray;
			this.friend_info.writeToDataOutput(tmp_friend_info);
			var size_tmp_friend_info:int = tmp_friend_info.length;
			output.writeInt(size_tmp_friend_info);
			output.writeBytes(tmp_friend_info);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.name = input.readUTF();
			var byte_friend_info_size:int = input.readInt();
			if (byte_friend_info_size > 0) {				this.friend_info = new p_friend_info;
				var byte_friend_info:ByteArray = new ByteArray;
				input.readBytes(byte_friend_info, 0, byte_friend_info_size);
				this.friend_info.readFromDataOutput(byte_friend_info);
			}
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
		}
	}
}
