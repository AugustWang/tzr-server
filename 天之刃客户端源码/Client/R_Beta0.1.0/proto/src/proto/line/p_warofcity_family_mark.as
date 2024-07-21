package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_warofcity_family_mark extends Message
	{
		public var family_id:int = 0;
		public var family_name:String = "";
		public var marks:int = 0;
		public function p_warofcity_family_mark() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_warofcity_family_mark", p_warofcity_family_mark);
		}
		public override function getMethodName():String {
			return 'warofcity_family_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.marks);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.marks = input.readInt();
		}
	}
}
