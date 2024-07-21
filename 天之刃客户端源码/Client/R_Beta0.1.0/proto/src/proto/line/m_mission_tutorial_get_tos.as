package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_tutorial_get_tos extends Message
	{
		public function m_mission_tutorial_get_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_tutorial_get_tos", m_mission_tutorial_get_tos);
		}
		public override function getMethodName():String {
			return 'mission_tutorial_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
