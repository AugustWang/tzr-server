package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_random_start_tos extends Message
	{
		public var mission_id:int = 0;
		public function m_mission_random_start_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_random_start_tos", m_mission_random_start_tos);
		}
		public override function getMethodName():String {
			return 'mission_random_start';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mission_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mission_id = input.readInt();
		}
	}
}
