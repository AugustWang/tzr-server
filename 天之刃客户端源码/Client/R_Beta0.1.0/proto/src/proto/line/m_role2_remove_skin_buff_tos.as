package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_remove_skin_buff_tos extends Message
	{
		public function m_role2_remove_skin_buff_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_remove_skin_buff_tos", m_role2_remove_skin_buff_tos);
		}
		public override function getMethodName():String {
			return 'role2_remove_skin_buff';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
