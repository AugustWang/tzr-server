package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_batch_sell_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var silver:int = 0;
		public var bind_silver:int = 0;
		public function m_item_batch_sell_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_batch_sell_toc", m_item_batch_sell_toc);
		}
		public override function getMethodName():String {
			return 'item_batch_sell';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
			output.writeInt(this.bind_silver);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.silver = input.readInt();
			this.bind_silver = input.readInt();
		}
	}
}
