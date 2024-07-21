package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_agree_help_toc extends Message
	{
		public var again:Boolean = false;
		public var message:String = "";
		public var role_id:int = 0;
		public var reason:String = "";
		public function m_educate_agree_help_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_agree_help_toc", m_educate_agree_help_toc);
		}
		public override function getMethodName():String {
			return 'educate_agree_help';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.again);
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.again = input.readBoolean();
			this.message = input.readUTF();
			this.role_id = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
