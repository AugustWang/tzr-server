package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flowers_give_world_broadcast_toc extends Message
	{
		public var broadcast:p_flowers_give_broadcast_info = null;
		public function m_flowers_give_world_broadcast_toc() {
			super();
			this.broadcast = new p_flowers_give_broadcast_info;

			flash.net.registerClassAlias("copy.proto.line.m_flowers_give_world_broadcast_toc", m_flowers_give_world_broadcast_toc);
		}
		public override function getMethodName():String {
			return 'flowers_give_world_broadcast';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_broadcast:ByteArray = new ByteArray;
			this.broadcast.writeToDataOutput(tmp_broadcast);
			var size_tmp_broadcast:int = tmp_broadcast.length;
			output.writeInt(size_tmp_broadcast);
			output.writeBytes(tmp_broadcast);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_broadcast_size:int = input.readInt();
			if (byte_broadcast_size > 0) {				this.broadcast = new p_flowers_give_broadcast_info;
				var byte_broadcast:ByteArray = new ByteArray;
				input.readBytes(byte_broadcast, 0, byte_broadcast_size);
				this.broadcast.readFromDataOutput(byte_broadcast);
			}
		}
	}
}
