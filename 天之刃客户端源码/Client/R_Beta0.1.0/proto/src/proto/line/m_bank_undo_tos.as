package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bank_undo_tos extends Message
	{
		public var sheet_id:int = 0;
		public function m_bank_undo_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bank_undo_tos", m_bank_undo_tos);
		}
		public override function getMethodName():String {
			return 'bank_undo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.sheet_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.sheet_id = input.readInt();
		}
	}
}
