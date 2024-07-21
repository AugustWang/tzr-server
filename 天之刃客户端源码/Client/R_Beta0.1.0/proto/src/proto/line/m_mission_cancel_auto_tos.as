package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_cancel_auto_tos extends Message
	{
		public var id:int = 0;
		public function m_mission_cancel_auto_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_cancel_auto_tos", m_mission_cancel_auto_tos);
		}
		public override function getMethodName():String {
			return 'mission_cancel_auto';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
		}
	}
}
