package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_transfer_toc extends Message
	{
		public var succ:Boolean = true;
		public var map_id:int = 0;
		public var reason:String = "";
		public function m_waroffaction_transfer_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_transfer_toc", m_waroffaction_transfer_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_transfer';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.map_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.map_id = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
