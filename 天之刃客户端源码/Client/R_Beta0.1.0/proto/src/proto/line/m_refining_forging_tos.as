package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_forging_tos extends Message
	{
		public var bag_id:int = 0;
		public function m_refining_forging_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_forging_tos", m_refining_forging_tos);
		}
		public override function getMethodName():String {
			return 'refining_forging';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bag_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bag_id = input.readInt();
		}
	}
}
