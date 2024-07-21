package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_ybc_member_info extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var status:int = 0;
		public function p_family_ybc_member_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_family_ybc_member_info", p_family_ybc_member_info);
		}
		public override function getMethodName():String {
			return 'family_ybc_member_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.status);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.status = input.readInt();
		}
	}
}
