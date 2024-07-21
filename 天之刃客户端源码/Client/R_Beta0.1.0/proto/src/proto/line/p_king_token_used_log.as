package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_king_token_used_log extends Message
	{
		public var king_last_used_time:int = 0;
		public var king_used_counter:int = 0;
		public var general_last_used_time:int = 0;
		public var general_used_counter:int = 0;
		public function p_king_token_used_log() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_king_token_used_log", p_king_token_used_log);
		}
		public override function getMethodName():String {
			return 'king_token_used';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.king_last_used_time);
			output.writeInt(this.king_used_counter);
			output.writeInt(this.general_last_used_time);
			output.writeInt(this.general_used_counter);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.king_last_used_time = input.readInt();
			this.king_used_counter = input.readInt();
			this.general_last_used_time = input.readInt();
			this.general_used_counter = input.readInt();
		}
	}
}
