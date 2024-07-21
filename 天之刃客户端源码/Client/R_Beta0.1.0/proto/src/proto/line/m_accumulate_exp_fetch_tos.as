package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_accumulate_exp_fetch_tos extends Message
	{
		public var id:int = 0;
		public function m_accumulate_exp_fetch_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_accumulate_exp_fetch_tos", m_accumulate_exp_fetch_tos);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_fetch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
		}
	}
}
