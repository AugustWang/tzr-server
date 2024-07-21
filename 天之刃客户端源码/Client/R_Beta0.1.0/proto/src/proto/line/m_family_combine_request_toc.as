package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_combine_request_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var request_role_id:int = 0;
		public function m_family_combine_request_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_combine_request_toc", m_family_combine_request_toc);
		}
		public override function getMethodName():String {
			return 'family_combine_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.request_role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.request_role_id = input.readInt();
		}
	}
}
