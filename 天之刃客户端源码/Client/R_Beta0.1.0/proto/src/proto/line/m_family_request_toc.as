package proto.line {
	import proto.common.p_family_request;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_request_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var request:p_family_request = null;
		public var family_id:int = 0;
		public function m_family_request_toc() {
			super();
			this.request = new p_family_request;

			flash.net.registerClassAlias("copy.proto.line.m_family_request_toc", m_family_request_toc);
		}
		public override function getMethodName():String {
			return 'family_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			var tmp_request:ByteArray = new ByteArray;
			this.request.writeToDataOutput(tmp_request);
			var size_tmp_request:int = tmp_request.length;
			output.writeInt(size_tmp_request);
			output.writeBytes(tmp_request);
			output.writeInt(this.family_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			var byte_request_size:int = input.readInt();
			if (byte_request_size > 0) {				this.request = new p_family_request;
				var byte_request:ByteArray = new ByteArray;
				input.readBytes(byte_request, 0, byte_request_size);
				this.request.readFromDataOutput(byte_request);
			}
			this.family_id = input.readInt();
		}
	}
}
