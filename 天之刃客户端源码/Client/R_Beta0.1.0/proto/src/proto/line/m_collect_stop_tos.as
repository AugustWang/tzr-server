package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_collect_stop_tos extends Message
	{
		public var id:int = 0;
		public function m_collect_stop_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_collect_stop_tos", m_collect_stop_tos);
		}
		public override function getMethodName():String {
			return 'collect_stop';
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
