package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_invite_info extends Message
	{
		public var target_role_id:int = 0;
		public var family_id:int = 0;
		public var family_name:String = "";
		public var src_role_id:int = 0;
		public var src_role_name:String = "";
		public function p_family_invite_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_family_invite_info", p_family_invite_info);
		}
		public override function getMethodName():String {
			return 'family_invite_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.target_role_id);
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.src_role_id);
			if (this.src_role_name != null) {				output.writeUTF(this.src_role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.target_role_id = input.readInt();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.src_role_id = input.readInt();
			this.src_role_name = input.readUTF();
		}
	}
}
