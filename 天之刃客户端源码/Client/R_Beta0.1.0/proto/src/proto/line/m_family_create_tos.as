package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_create_tos extends Message
	{
		public var family_name:String = "";
		public var public_notice:String = "";
		public var private_notice:String = "";
		public var is_invite:Boolean = true;
		public function m_family_create_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_create_tos", m_family_create_tos);
		}
		public override function getMethodName():String {
			return 'family_create';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.public_notice != null) {				output.writeUTF(this.public_notice.toString());
			} else {
				output.writeUTF("");
			}
			if (this.private_notice != null) {				output.writeUTF(this.private_notice.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_invite);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_name = input.readUTF();
			this.public_notice = input.readUTF();
			this.private_notice = input.readUTF();
			this.is_invite = input.readBoolean();
		}
	}
}
