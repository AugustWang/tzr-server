package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_waroffaction_rank extends Message
	{
		public var role_id:int = 0;
		public var faction_id:int = 0;
		public var score:int = 0;
		public var role_name:String = "";
		public function p_waroffaction_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_waroffaction_rank", p_waroffaction_rank);
		}
		public override function getMethodName():String {
			return 'waroffaction_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.faction_id);
			output.writeInt(this.score);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.faction_id = input.readInt();
			this.score = input.readInt();
			this.role_name = input.readUTF();
		}
	}
}
