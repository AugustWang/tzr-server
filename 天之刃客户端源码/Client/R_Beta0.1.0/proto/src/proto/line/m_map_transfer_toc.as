package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_transfer_toc extends Message
	{
		public var succ:Boolean = true;
		public var scroll_id:int = 0;
		public var reason:String = "";
		public function m_map_transfer_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_map_transfer_toc", m_map_transfer_toc);
		}
		public override function getMethodName():String {
			return 'map_transfer';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.scroll_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.scroll_id = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
