package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_agree_appoint_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var role_name:String = "";
		public var office_name:String = "";
		public function m_office_agree_appoint_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_agree_appoint_toc", m_office_agree_appoint_toc);
		}
		public override function getMethodName():String {
			return 'office_agree_appoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.role_name = input.readUTF();
			this.office_name = input.readUTF();
		}
	}
}
