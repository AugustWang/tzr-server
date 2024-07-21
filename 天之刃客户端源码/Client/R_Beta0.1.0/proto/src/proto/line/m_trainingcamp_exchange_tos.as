package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trainingcamp_exchange_tos extends Message
	{
		public var training_point:int = 0;
		public function m_trainingcamp_exchange_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trainingcamp_exchange_tos", m_trainingcamp_exchange_tos);
		}
		public override function getMethodName():String {
			return 'trainingcamp_exchange';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.training_point);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.training_point = input.readInt();
		}
	}
}
