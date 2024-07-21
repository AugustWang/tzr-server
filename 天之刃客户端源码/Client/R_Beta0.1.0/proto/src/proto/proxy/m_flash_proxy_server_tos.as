package proto.proxy {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_flash_proxy_server_tos extends Message
	{
		public var servername:String = "";
		public function m_flash_proxy_server_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.proxy.m_flash_proxy_server_tos", m_flash_proxy_server_tos);
		}
		public override function getMethodName():String {
			return 'flash_proxy_server';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.servername != null) {				output.writeUTF(this.servername.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.servername = input.readUTF();
		}
	}
}
