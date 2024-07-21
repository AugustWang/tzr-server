package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_unbund_change_tos extends Message
	{
		public var unbund:Boolean = true;
		public function m_role2_unbund_change_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_unbund_change_tos", m_role2_unbund_change_tos);
		}
		public override function getMethodName():String {
			return 'role2_unbund_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.unbund);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.unbund = input.readBoolean();
		}
	}
}
