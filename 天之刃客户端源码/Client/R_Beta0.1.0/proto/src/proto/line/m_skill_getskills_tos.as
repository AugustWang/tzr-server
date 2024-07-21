package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_skill_getskills_tos extends Message
	{
		public function m_skill_getskills_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_skill_getskills_tos", m_skill_getskills_tos);
		}
		public override function getMethodName():String {
			return 'skill_getskills';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
