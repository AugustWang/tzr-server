package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_state_change_tos extends Message
	{
		public var letter_id:int = 0;
		public var state:int = 0;
		public var is_self_send:Boolean = false;
		public function m_letter_state_change_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_state_change_tos", m_letter_state_change_tos);
		}
		public override function getMethodName():String {
			return 'letter_state_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.letter_id);
			output.writeInt(this.state);
			output.writeBoolean(this.is_self_send);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.letter_id = input.readInt();
			this.state = input.readInt();
			this.is_self_send = input.readBoolean();
		}
	}
}
