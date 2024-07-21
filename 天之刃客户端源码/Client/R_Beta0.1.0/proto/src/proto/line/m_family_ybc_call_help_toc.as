package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_call_help_toc extends Message
	{
		public var map_id:int = 0;
		public function m_family_ybc_call_help_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_call_help_toc", m_family_ybc_call_help_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_call_help';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.map_id = input.readInt();
		}
	}
}
