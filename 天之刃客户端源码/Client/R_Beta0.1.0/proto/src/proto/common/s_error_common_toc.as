package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class s_error_common_toc extends Message
	{
		public var msg:String = "";
		public function s_error_common_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.common.s_error_common_toc", s_error_common_toc);
		}
		public override function getMethodName():String {
			return 'error_common';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.msg = input.readUTF();
		}
	}
}
