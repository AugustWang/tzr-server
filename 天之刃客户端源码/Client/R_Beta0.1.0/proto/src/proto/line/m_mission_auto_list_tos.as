package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_auto_list_tos extends Message
	{
		public function m_mission_auto_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_auto_list_tos", m_mission_auto_list_tos);
		}
		public override function getMethodName():String {
			return 'mission_auto_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
