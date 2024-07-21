package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_invite extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var office_name:String = "";
		public var level:int = 0;
		public function p_family_invite() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_invite", p_family_invite);
		}
		public override function getMethodName():String {
			return 'family_in';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.office_name = input.readUTF();
			this.level = input.readInt();
		}
	}
}
