package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_letter_delete extends Message
	{
		public var letter_id:int = 0;
		public var is_self_send:Boolean = false;
		public var table:int = 0;
		public function p_letter_delete() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_letter_delete", p_letter_delete);
		}
		public override function getMethodName():String {
			return 'letter_de';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.letter_id);
			output.writeBoolean(this.is_self_send);
			output.writeInt(this.table);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.letter_id = input.readInt();
			this.is_self_send = input.readBoolean();
			this.table = input.readInt();
		}
	}
}
