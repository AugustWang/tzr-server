package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_callmember_toc extends Message
	{
		public var call_type:int = 1;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var message:String = "";
		public function m_family_callmember_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_callmember_toc", m_family_callmember_toc);
		}
		public override function getMethodName():String {
			return 'family_callmember';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.call_type);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.call_type = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.message = input.readUTF();
		}
	}
}
