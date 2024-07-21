package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_all_rank extends Message
	{
		public var ranking:int = 0;
		public var rank_name:String = "";
		public var key_value:int = 0;
		public var key_name:String = "";
		public function p_role_all_rank() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_all_rank", p_role_all_rank);
		}
		public override function getMethodName():String {
			return 'role_all_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.ranking);
			if (this.rank_name != null) {				output.writeUTF(this.rank_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.key_value);
			if (this.key_name != null) {				output.writeUTF(this.key_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ranking = input.readInt();
			this.rank_name = input.readUTF();
			this.key_value = input.readInt();
			this.key_name = input.readUTF();
		}
	}
}
