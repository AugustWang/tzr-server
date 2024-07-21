package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_invite_tos extends Message
	{
		public var role_name:String = "";
		public function m_family_invite_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_invite_tos", m_family_invite_tos);
		}
		public override function getMethodName():String {
			return 'family_invite';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_name = input.readUTF();
		}
	}
}
