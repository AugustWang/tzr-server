package proto.login {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_line_info extends Message
	{
		public var guid:String = "";
		public var ip:String = "";
		public var port:int = 0;
		public var line:String = "";
		public function p_line_info() {
			super();

			flash.net.registerClassAlias("copy.proto.login.p_line_info", p_line_info);
		}
		public override function getMethodName():String {
			return 'line_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.guid != null) {				output.writeUTF(this.guid.toString());
			} else {
				output.writeUTF("");
			}
			if (this.ip != null) {				output.writeUTF(this.ip.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.port);
			if (this.line != null) {				output.writeUTF(this.line.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.guid = input.readUTF();
			this.ip = input.readUTF();
			this.port = input.readInt();
			this.line = input.readUTF();
		}
	}
}
