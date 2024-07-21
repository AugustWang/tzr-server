package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_call_helper_toc extends Message
	{
		public var message:String = "";
		public var role_id:int = 0;
		public function m_educate_call_helper_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_call_helper_toc", m_educate_call_helper_toc);
		}
		public override function getMethodName():String {
			return 'educate_call_helper';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.message = input.readUTF();
			this.role_id = input.readInt();
		}
	}
}
