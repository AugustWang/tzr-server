package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_waroffaction_record extends Message
	{
		public var id:int = 0;
		public var faction_id:int = 0;
		public var tick:int = 0;
		public var content:String = "";
		public function p_waroffaction_record() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_waroffaction_record", p_waroffaction_record);
		}
		public override function getMethodName():String {
			return 'waroffaction_re';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.faction_id);
			output.writeInt(this.tick);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.faction_id = input.readInt();
			this.tick = input.readInt();
			this.content = input.readUTF();
		}
	}
}
