package proto.proxy {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_server_disconnect_flash_toc extends Message
	{
		public var reason:String = "";
		public function m_server_disconnect_flash_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.proxy.m_server_disconnect_flash_toc", m_server_disconnect_flash_toc);
		}
		public override function getMethodName():String {
			return 'server_disconnect_flash';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.reason = input.readUTF();
		}
	}
}
