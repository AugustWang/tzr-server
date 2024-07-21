package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_get_goods_tos extends Message
	{
		public var goods_id:int = 0;
		public function m_chat_get_goods_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_get_goods_tos", m_chat_get_goods_tos);
		}
		public override function getMethodName():String {
			return 'chat_get_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
		}
	}
}
