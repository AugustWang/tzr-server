package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_warofcity_role_mark extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var family_id:int = 0;
		public var family_name:String = "";
		public var marks:int = 0;
		public function p_warofcity_role_mark() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_warofcity_role_mark", p_warofcity_role_mark);
		}
		public override function getMethodName():String {
			return 'warofcity_role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.marks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.marks = input.readInt();
		}
	}
}
