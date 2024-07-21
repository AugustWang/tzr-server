package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_faction_online_rank extends Message
	{
		public var faction_id:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var role_level:int = 0;
		public function p_faction_online_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_faction_online_rank", p_faction_online_rank);
		}
		public override function getMethodName():String {
			return 'faction_online_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.faction_id);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.faction_id = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.role_level = input.readInt();
		}
	}
}
