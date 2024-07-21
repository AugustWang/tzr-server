package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trainingcamp_start_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var last_time:int = 0;
		public function m_trainingcamp_start_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trainingcamp_start_toc", m_trainingcamp_start_toc);
		}
		public override function getMethodName():String {
			return 'trainingcamp_start';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.last_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.last_time = input.readInt();
		}
	}
}
