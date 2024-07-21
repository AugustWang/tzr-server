package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bgp_login_toc extends Message
	{
		public var id:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public function m_bgp_login_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bgp_login_toc", m_bgp_login_toc);
		}
		public override function getMethodName():String {
			return 'bgp_login';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
		}
	}
}
