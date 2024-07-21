package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trainingcamp_start_tos extends Message
	{
		public var time:int = 0;
		public function m_trainingcamp_start_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trainingcamp_start_tos", m_trainingcamp_start_tos);
		}
		public override function getMethodName():String {
			return 'trainingcamp_start';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.time = input.readInt();
		}
	}
}
