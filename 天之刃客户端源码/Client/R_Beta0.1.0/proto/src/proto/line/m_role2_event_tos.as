package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_event_tos extends Message
	{
		public var event_id:int = 0;
		public function m_role2_event_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_event_tos", m_role2_event_tos);
		}
		public override function getMethodName():String {
			return 'role2_event';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.event_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.event_id = input.readInt();
		}
	}
}
