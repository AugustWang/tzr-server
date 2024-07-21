package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_stop_notify_tos extends Message
	{
		public var notify_type:int = 0;
		public function m_vip_stop_notify_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_vip_stop_notify_tos", m_vip_stop_notify_tos);
		}
		public override function getMethodName():String {
			return 'vip_stop_notify';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.notify_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.notify_type = input.readInt();
		}
	}
}
