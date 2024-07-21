package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_buy_guarder_toc extends Message
	{
		public var succ:Boolean = true;
		public var guarder_type:int = 0;
		public var reason:String = "";
		public function m_waroffaction_buy_guarder_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_buy_guarder_toc", m_waroffaction_buy_guarder_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_buy_guarder';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.guarder_type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.guarder_type = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
