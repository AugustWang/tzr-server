package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trainingcamp_stop_toc extends Message
	{
		public var succ:Boolean = true;
		public var training_point:int = 0;
		public var exp_get:int = 0;
		public var reason:String = "";
		public function m_trainingcamp_stop_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trainingcamp_stop_toc", m_trainingcamp_stop_toc);
		}
		public override function getMethodName():String {
			return 'trainingcamp_stop';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.training_point);
			output.writeInt(this.exp_get);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.training_point = input.readInt();
			this.exp_get = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
