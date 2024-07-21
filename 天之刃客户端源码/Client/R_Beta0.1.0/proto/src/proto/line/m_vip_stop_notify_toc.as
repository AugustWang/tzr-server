package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_stop_notify_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var notify_type:int = 0;
		public function m_vip_stop_notify_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vip_stop_notify_toc", m_vip_stop_notify_toc);
		}
		public override function getMethodName():String {
			return 'vip_stop_notify';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.notify_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.notify_type = input.readInt();
		}
	}
}
