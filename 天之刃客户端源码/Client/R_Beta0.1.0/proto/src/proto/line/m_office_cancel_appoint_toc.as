package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_cancel_appoint_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var office_id:int = 0;
		public function m_office_cancel_appoint_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_cancel_appoint_toc", m_office_cancel_appoint_toc);
		}
		public override function getMethodName():String {
			return 'office_cancel_appoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.office_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.office_id = input.readInt();
		}
	}
}
