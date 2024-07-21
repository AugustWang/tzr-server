package proto.line {
	import proto.common.p_map_stall;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_request_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var stall_info:p_map_stall = null;
		public var silver:int = 0;
		public var bind_silver:int = 0;
		public function m_stall_request_toc() {
			super();
			this.stall_info = new p_map_stall;

			flash.net.registerClassAlias("copy.proto.line.m_stall_request_toc", m_stall_request_toc);
		}
		public override function getMethodName():String {
			return 'stall_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			var tmp_stall_info:ByteArray = new ByteArray;
			this.stall_info.writeToDataOutput(tmp_stall_info);
			var size_tmp_stall_info:int = tmp_stall_info.length;
			output.writeInt(size_tmp_stall_info);
			output.writeBytes(tmp_stall_info);
			output.writeInt(this.silver);
			output.writeInt(this.bind_silver);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			var byte_stall_info_size:int = input.readInt();
			if (byte_stall_info_size > 0) {				this.stall_info = new p_map_stall;
				var byte_stall_info:ByteArray = new ByteArray;
				input.readBytes(byte_stall_info, 0, byte_stall_info_size);
				this.stall_info.readFromDataOutput(byte_stall_info);
			}
			this.silver = input.readInt();
			this.bind_silver = input.readInt();
		}
	}
}
