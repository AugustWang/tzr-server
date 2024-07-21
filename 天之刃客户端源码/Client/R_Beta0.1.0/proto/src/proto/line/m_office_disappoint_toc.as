package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_disappoint_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var office_id:int = 0;
		public var office_name:String = "";
		public function m_office_disappoint_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_disappoint_toc", m_office_disappoint_toc);
		}
		public override function getMethodName():String {
			return 'office_disappoint';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.office_id);
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
			this.office_id = input.readInt();
			this.office_name = input.readUTF();
		}
	}
}
