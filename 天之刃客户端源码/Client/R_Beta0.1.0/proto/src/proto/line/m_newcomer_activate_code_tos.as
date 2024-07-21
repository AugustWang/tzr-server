package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_newcomer_activate_code_tos extends Message
	{
		public var code:String = "";
		public function m_newcomer_activate_code_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_newcomer_activate_code_tos", m_newcomer_activate_code_tos);
		}
		public override function getMethodName():String {
			return 'newcomer_activate_code';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.code != null) {				output.writeUTF(this.code.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.code = input.readUTF();
		}
	}
}
