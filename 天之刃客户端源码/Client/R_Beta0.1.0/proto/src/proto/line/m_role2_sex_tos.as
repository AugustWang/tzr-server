package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_sex_tos extends Message
	{
		public function m_role2_sex_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_sex_tos", m_role2_sex_tos);
		}
		public override function getMethodName():String {
			return 'role2_sex';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
