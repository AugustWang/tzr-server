package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bgp_login_tos extends Message
	{
		public var id:int = 0;
		public var host:String = "";
		public var port:int = 0;
		public function m_bgp_login_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bgp_login_tos", m_bgp_login_tos);
		}
		public override function getMethodName():String {
			return 'bgp_login';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			if (this.host != null) {				output.writeUTF(this.host.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.port);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.host = input.readUTF();
			this.port = input.readInt();
		}
	}
}
