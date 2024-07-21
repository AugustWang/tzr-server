package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trainingcamp_exchange_toc extends Message
	{
		public var succ:Boolean = true;
		public var gold:int = 0;
		public var gold_bind:int = 0;
		public var reason:String = "";
		public function m_trainingcamp_exchange_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trainingcamp_exchange_toc", m_trainingcamp_exchange_toc);
		}
		public override function getMethodName():String {
			return 'trainingcamp_exchange';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.gold);
			output.writeInt(this.gold_bind);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.gold = input.readInt();
			this.gold_bind = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
