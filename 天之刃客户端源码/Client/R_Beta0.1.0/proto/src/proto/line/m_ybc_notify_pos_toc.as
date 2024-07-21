package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ybc_notify_pos_toc extends Message
	{
		public var map_id:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public function m_ybc_notify_pos_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ybc_notify_pos_toc", m_ybc_notify_pos_toc);
		}
		public override function getMethodName():String {
			return 'ybc_notify_pos';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.map_id);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.map_id = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
		}
	}
}
