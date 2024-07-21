package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_accept_tos extends Message
	{
		public var id:int = 0;
		public var reply_id:int = 0;
		public function m_flowers_accept_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_flowers_accept_tos", m_flowers_accept_tos);
		}
		public override function getMethodName():String {
			return 'flowers_accept';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.reply_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.reply_id = input.readInt();
		}
	}
}
