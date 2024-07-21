package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_buy_guarder_tos extends Message
	{
		public var guarder_type:int = 0;
		public function m_waroffaction_buy_guarder_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_buy_guarder_tos", m_waroffaction_buy_guarder_tos);
		}
		public override function getMethodName():String {
			return 'waroffaction_buy_guarder';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.guarder_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.guarder_type = input.readInt();
		}
	}
}
