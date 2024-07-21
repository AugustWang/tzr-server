package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_warofcity_family_winner extends Message
	{
		public var family_id:int = 0;
		public var family_name:String = "";
		public function p_warofcity_family_winner() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_warofcity_family_winner", p_warofcity_family_winner);
		}
		public override function getMethodName():String {
			return 'warofcity_family_wi';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
		}
	}
}
