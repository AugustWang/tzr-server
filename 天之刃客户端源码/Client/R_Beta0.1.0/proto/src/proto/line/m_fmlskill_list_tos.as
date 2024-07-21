package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmlskill_list_tos extends Message
	{
		public function m_fmlskill_list_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmlskill_list_tos", m_fmlskill_list_tos);
		}
		public override function getMethodName():String {
			return 'fmlskill_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
