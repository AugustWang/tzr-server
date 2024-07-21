package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_accumulate_exp_get_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var addexp:Number = 0;
		public function m_accumulate_exp_get_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_accumulate_exp_get_toc", m_accumulate_exp_get_toc);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeDouble(this.addexp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.addexp = input.readDouble();
		}
	}
}
