package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_heartbeat_toc extends Message
	{
		public var time:int = 0;
		public var server_time:int = 0;
		public function m_system_heartbeat_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_system_heartbeat_toc", m_system_heartbeat_toc);
		}
		public override function getMethodName():String {
			return 'system_heartbeat';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.time);
			output.writeInt(this.server_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.time = input.readInt();
			this.server_time = input.readInt();
		}
	}
}
