package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_family_donate_info extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var donate_amount:int = 0;
		public function p_role_family_donate_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_family_donate_info", p_role_family_donate_info);
		}
		public override function getMethodName():String {
			return 'role_family_donate_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.donate_amount);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.donate_amount = input.readInt();
		}
	}
}
