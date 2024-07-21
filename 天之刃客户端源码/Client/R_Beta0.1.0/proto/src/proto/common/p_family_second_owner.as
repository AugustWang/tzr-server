package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_second_owner extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public function p_family_second_owner() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_second_owner", p_family_second_owner);
		}
		public override function getMethodName():String {
			return 'family_second_o';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
		}
	}
}
