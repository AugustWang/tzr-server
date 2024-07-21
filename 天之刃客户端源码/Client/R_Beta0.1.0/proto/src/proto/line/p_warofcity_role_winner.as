package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_warofcity_role_winner extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public function p_warofcity_role_winner() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_warofcity_role_winner", p_warofcity_role_winner);
		}
		public override function getMethodName():String {
			return 'warofcity_role_wi';
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
