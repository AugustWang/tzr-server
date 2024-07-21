package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_seed_info extends Message
	{
		public var seed_id:int = 0;
		public var seed_name:String = "";
		public var seed_type:int = 0;
		public var level:int = 0;
		public function p_seed_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_seed_info", p_seed_info);
		}
		public override function getMethodName():String {
			return 'seed_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.seed_id);
			if (this.seed_name != null) {				output.writeUTF(this.seed_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.seed_type);
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.seed_id = input.readInt();
			this.seed_name = input.readUTF();
			this.seed_type = input.readInt();
			this.level = input.readInt();
		}
	}
}
