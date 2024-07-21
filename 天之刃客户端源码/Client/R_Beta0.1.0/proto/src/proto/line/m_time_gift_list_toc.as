package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_time_gift_list_toc extends Message
	{
		public var gift:p_time_gift_info = null;
		public function m_time_gift_list_toc() {
			super();
			this.gift = new p_time_gift_info;

			flash.net.registerClassAlias("copy.proto.line.m_time_gift_list_toc", m_time_gift_list_toc);
		}
		public override function getMethodName():String {
			return 'time_gift_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_gift:ByteArray = new ByteArray;
			this.gift.writeToDataOutput(tmp_gift);
			var size_tmp_gift:int = tmp_gift.length;
			output.writeInt(size_tmp_gift);
			output.writeBytes(tmp_gift);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_gift_size:int = input.readInt();
			if (byte_gift_size > 0) {				this.gift = new p_time_gift_info;
				var byte_gift:ByteArray = new ByteArray;
				input.readBytes(byte_gift, 0, byte_gift_size);
				this.gift.readFromDataOutput(byte_gift);
			}
		}
	}
}
