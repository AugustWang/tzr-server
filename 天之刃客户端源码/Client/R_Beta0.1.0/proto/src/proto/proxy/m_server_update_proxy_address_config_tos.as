package proto.proxy {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_server_update_proxy_address_config_tos extends Message
	{
		public var type:int = 0;
		public var servername:String = "";
		public var ip:String = "";
		public var port:int = 0;
		public function m_server_update_proxy_address_config_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.proxy.m_server_update_proxy_address_config_tos", m_server_update_proxy_address_config_tos);
		}
		public override function getMethodName():String {
			return 'server_update_proxy_address_config';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			if (this.servername != null) {				output.writeUTF(this.servername.toString());
			} else {
				output.writeUTF("");
			}
			if (this.ip != null) {				output.writeUTF(this.ip.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.port);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.servername = input.readUTF();
			this.ip = input.readUTF();
			this.port = input.readInt();
		}
	}
}
