package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_refuse_tos extends Message
	{
		public var src_roleid:int = 0;
		public function m_exchange_refuse_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_refuse_tos", m_exchange_refuse_tos);
		}
		public override function getMethodName():String {
			return 'exchange_refuse';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.src_roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.src_roleid = input.readInt();
		}
	}
}
