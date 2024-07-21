package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_extractmoney_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var silver:int = 0;
		public var tax:int = 0;
		public var gold:int = 0;
		public function m_stall_extractmoney_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_extractmoney_toc", m_stall_extractmoney_toc);
		}
		public override function getMethodName():String {
			return 'stall_extractmoney';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
			output.writeInt(this.tax);
			output.writeInt(this.gold);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.silver = input.readInt();
			this.tax = input.readInt();
			this.gold = input.readInt();
		}
	}
}
