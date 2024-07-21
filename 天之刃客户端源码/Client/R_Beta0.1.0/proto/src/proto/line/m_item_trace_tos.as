package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_trace_tos extends Message
	{
		public var target_name:String = "";
		public var goods_id:int = 0;
		public function m_item_trace_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_trace_tos", m_item_trace_tos);
		}
		public override function getMethodName():String {
			return 'item_trace';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.target_name != null) {				output.writeUTF(this.target_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.target_name = input.readUTF();
			this.goods_id = input.readInt();
		}
	}
}
